#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


COMPARABLE_FIELDS = {
    "size": "sizeDraft",
    "exerciseNeeds": "exerciseNeedsDraft",
    "aloneTolerance": "aloneToleranceDraft",
    "goodWithChildren": "goodWithChildrenDraft",
    "groomingNeeds": "groomingNeedsDraft",
    "sheddingLevel": "sheddingLevelDraft",
    "maintenanceCost": "maintenanceCostDraft",
    "trainability": "trainabilityDraft",
}

REVIEW_REQUIRED_FIELDS = [
    "apartmentSuitability",
    "goodWithOtherPets",
    "beginnerFriendly",
    "noiseLevel",
    "temperamentCalm",
]


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False, indent=2)
        file.write("\n")


def normalized_group(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    return value.strip().lower().replace(" ", "_")


def compare_numeric(canonical: int, draft: int | None) -> dict[str, Any]:
    if draft is None:
        return {
            "canonical": canonical,
            "freeadsDraft": None,
            "status": "missing_from_source",
            "difference": None,
        }

    difference = abs(canonical - draft)
    if difference == 0:
        status = "match"
    elif difference == 1:
        status = "near_match"
    else:
        status = "drift"

    return {
        "canonical": canonical,
        "freeadsDraft": draft,
        "status": status,
        "difference": difference,
    }


def build_review_pack(canonical: dict[str, Any], candidate: dict[str, Any]) -> dict[str, Any]:
    canonical_attributes = canonical["attributes"]
    extraction_hints = candidate["attributeExtractionHints"]
    field_comparison: dict[str, Any] = {}

    drift_count = 0
    near_match_count = 0
    missing_count = 0

    for canonical_field, draft_field in COMPARABLE_FIELDS.items():
        result = compare_numeric(
            canonical_attributes[canonical_field],
            extraction_hints.get(draft_field),
        )
        field_comparison[canonical_field] = result
        if result["status"] == "drift":
            drift_count += 1
        elif result["status"] == "near_match":
            near_match_count += 1
        elif result["status"] == "missing_from_source":
            missing_count += 1

    for field in REVIEW_REQUIRED_FIELDS:
        field_comparison[field] = {
            "canonical": canonical_attributes[field],
            "freeadsDraft": None,
            "status": "review_required_not_in_source",
            "difference": None,
        }

    canonical_group = canonical.get("group")
    freeads_group = normalized_group(candidate["sourceFacts"].get("breedGroup"))
    group_status = "missing_from_source"
    if freeads_group is not None:
        group_status = "match" if canonical_group == freeads_group else "review_required_group_mismatch"

    content_draft = candidate["contentDraft"]
    import_status = candidate["importStatus"]
    page_warnings = candidate["quality"].get("pageWarnings") or []

    if drift_count > 0:
        review_priority = "high"
    elif missing_count >= 4 or not import_status.get("contentReady", False):
        review_priority = "medium"
    else:
        review_priority = "normal"

    return {
        "breedId": canonical["breedId"],
        "petType": canonical["petType"],
        "name": canonical["name"],
        "reviewPriority": review_priority,
        "sources": {
            "canonicalFile": f"docs/backend/examples/breed.{canonical['breedId']}.json",
            "freeadsCandidateFile": (
                f"docs/backend/import_candidates/freeads_candidates/candidate.{canonical['breedId']}.json"
            ),
            "freeadsUrl": candidate["source"]["breedDetailsUrl"],
            "freeadsUrlStatus": candidate["source"]["urlStatus"],
        },
        "groupComparison": {
            "canonical": canonical_group,
            "freeadsDraft": freeads_group,
            "status": group_status,
        },
        "fieldComparison": field_comparison,
        "contentComparison": {
            "canonicalSummaryShort": canonical["content"].get("summaryShort"),
            "freeadsSummaryShort": content_draft.get("summaryShort"),
            "freeadsStrengths": content_draft.get("strengths") or [],
            "freeadsWatchouts": content_draft.get("watchouts") or [],
            "contentReady": bool(import_status.get("contentReady", False)),
        },
        "quality": {
            "canonicalConfidenceScore": canonical["quality"].get("confidenceScore"),
            "freeadsConfidenceScore": candidate["quality"].get("confidenceScore"),
            "freeadsNeedsReview": candidate["quality"].get("needsReview", True),
            "pageWarnings": page_warnings,
            "driftCount": drift_count,
            "nearMatchCount": near_match_count,
            "missingFromSourceCount": missing_count,
        },
        "recommendedActions": build_recommended_actions(
            drift_count=drift_count,
            missing_count=missing_count,
            content_ready=bool(import_status.get("contentReady", False)),
            url_status=candidate["source"]["urlStatus"],
        ),
    }


def build_recommended_actions(
    *,
    drift_count: int,
    missing_count: int,
    content_ready: bool,
    url_status: str | None,
) -> list[str]:
    actions: list[str] = []

    if drift_count > 0:
        actions.append("review numeric attribute drifts before trusting Freeads draft values")
    if missing_count > 0:
        actions.append("fill PetWise-only fields via rubric review")
    if not content_ready:
        actions.append("capture richer breed page data before using Freeads for content enrichment")
    if url_status in {"needs_browser_capture", "index_verified_only"}:
        actions.append("prefer browser-assisted capture for a stronger raw snapshot")

    if not actions:
        actions.append("candidate is ready for focused reviewer pass")

    return actions


def build_summary(review_packs: list[dict[str, Any]]) -> dict[str, Any]:
    summary = {
        "version": 1,
        "breedCount": len(review_packs),
        "highPriority": [],
        "mediumPriority": [],
        "normalPriority": [],
        "browserCaptureComplete": 0,
        "snippetComplete": 0,
        "pendingCapture": 0,
    }

    for pack in review_packs:
        priority = pack["reviewPriority"]
        summary_key = {
            "high": "highPriority",
            "medium": "mediumPriority",
            "normal": "normalPriority",
        }[priority]
        summary[summary_key].append(pack["breedId"])

        url_status = pack["sources"]["freeadsUrlStatus"]
        if url_status == "verified_via_browser_capture":
            summary["browserCaptureComplete"] += 1
        elif url_status == "verified_via_search_snippet":
            summary["snippetComplete"] += 1
        else:
            summary["pendingCapture"] += 1

    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate review packs comparing canonical breeds with Freeads candidates.",
    )
    parser.add_argument(
        "--catalog",
        type=Path,
        default=Path("docs/backend/examples/catalog.v1.json"),
        help="Path to the canonical catalog manifest.",
    )
    parser.add_argument(
        "--candidate-dir",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_candidates"),
        help="Directory with generated Freeads candidates.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_review_pack"),
        help="Directory where review packs will be written.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    catalog = load_json(args.catalog)
    review_packs: list[dict[str, Any]] = []

    for breed in catalog["breeds"]:
        breed_id = breed["breedId"]
        candidate_path = args.candidate_dir / f"candidate.{breed_id}.json"
        if not candidate_path.exists():
            continue

        canonical_path = args.catalog.parent / breed["file"]
        canonical = load_json(canonical_path)
        candidate = load_json(candidate_path)
        review_pack = build_review_pack(canonical, candidate)
        review_packs.append(review_pack)
        save_json(args.output_dir / f"review.{breed_id}.json", review_pack)

    summary = build_summary(review_packs)
    save_json(args.output_dir / "summary.v1.json", summary)


if __name__ == "__main__":
    main()
