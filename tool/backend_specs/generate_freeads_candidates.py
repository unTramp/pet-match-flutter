#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def as_clean_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [item.strip() for item in value if isinstance(item, str) and item.strip()]


def map_label(mapping: dict[str, int], raw: Any) -> int | None:
    if not isinstance(raw, str):
        return None
    return mapping.get(raw.strip().lower())


def map_size_label(raw: Any) -> int | None:
    if not isinstance(raw, str):
        return None

    normalized = raw.strip().lower()
    direct = SIZE_MAP.get(normalized)
    if direct is not None:
        return direct

    parts = [part.strip() for part in normalized.replace("/", ",").split(",") if part.strip()]
    values = [SIZE_MAP[part] for part in parts if part in SIZE_MAP]
    if not values:
        return None

    # Prefer the larger bucket when the source expresses a range like "small, medium".
    return max(values)


SIZE_MAP = {
    "toy": 1,
    "small": 2,
    "medium": 3,
    "large": 4,
    "giant": 5,
}

EXERCISE_MAP = {
    "very low": 1,
    "low": 2,
    "medium": 3,
    "high": 5,
    "very high": 5,
}

TRAINABILITY_MAP = {
    "hard": 2,
    "medium": 3,
    "high": 5,
    "very easy": 5,
    "very high": 5,
}

SHEDDING_MAP = {
    "very light": 1,
    "light": 2,
    "medium": 3,
    "heavy": 5,
    "very heavy": 5,
    "high": 5,
}

GROOMING_MAP = {
    "very low": 1,
    "low": 2,
    "medium": 3,
    "high": 5,
    "very high": 5,
}

CHILDREN_MAP = {
    "unsuited to children": 1,
    "requires supervision": 2,
    "suited to older children": 3,
    "good with children": 4,
    "excellent family dog": 5,
    "suited to all ages of children": 5,
}

COST_MAP = {
    "very low": 1,
    "low": 2,
    "medium": 3,
    "high": 5,
    "very high": 5,
}

ALONE_MAP = {
    "low anxiety": 4,
    "medium": 3,
    "high anxiety": 1,
    "calm": 4,
    "very calm": 5,
}


def strengths_from_characteristics(characteristics: dict[str, Any]) -> list[str]:
    strengths: list[str] = []

    exercise = (characteristics.get("exerciseNeeds") or "").strip().lower()
    trainability = (characteristics.get("easyToTrain") or "").strip().lower()
    children = (characteristics.get("goodWithChildren") or "").strip().lower()
    alone = (characteristics.get("toleratesBeingAlone") or "").strip().lower()

    if exercise == "low":
        strengths.append("подходит для более спокойного ритма жизни")
    elif exercise == "medium":
        strengths.append("умеренный уровень активности")
    elif exercise == "high":
        strengths.append("подходит для активного образа жизни")

    if trainability == "high":
        strengths.append("обычно хорошо поддается обучению")
    elif trainability == "medium":
        strengths.append("способна хорошо учиться при регулярной работе")

    if children in {"good with children", "excellent family dog"}:
        strengths.append("может хорошо подойти для семейной среды")

    if alone == "low anxiety":
        strengths.append("обычно легче переносит короткие периоды одиночества")

    return strengths[:3]


def watchouts_from_characteristics(characteristics: dict[str, Any]) -> list[str]:
    watchouts: list[str] = []

    grooming = (characteristics.get("groomingNeeds") or "").strip().lower()
    shedding = (characteristics.get("shedding") or "").strip().lower()
    exercise = (characteristics.get("exerciseNeeds") or "").strip().lower()
    cost = (characteristics.get("costToKeep") or "").strip().lower()
    alone = (characteristics.get("toleratesBeingAlone") or "").strip().lower()

    if grooming == "high":
        watchouts.append("требует регулярного и заметного ухода за шерстью")
    elif grooming == "medium":
        watchouts.append("нуждается в регулярном уходе за шерстью")

    if shedding == "high":
        watchouts.append("может активно линять")

    if exercise == "high":
        watchouts.append("не подойдет для пассивного ритма жизни")

    if cost == "high":
        watchouts.append("содержание может обходиться дороже среднего")

    if alone == "high anxiety":
        watchouts.append("может тяжело переносить одиночество")

    return watchouts[:3]


def summary_from_raw(summary: Any, characteristics: dict[str, Any]) -> str | None:
    if isinstance(summary, str) and summary.strip():
        text = " ".join(summary.strip().split())
        if len(text) <= 180:
            return text
        return f"{text[:177].rstrip()}..."

    if not characteristics:
        return None

    exercise = (characteristics.get("exerciseNeeds") or "").strip().lower()
    grooming = (characteristics.get("groomingNeeds") or "").strip().lower()

    if exercise == "low":
        return "Порода с более спокойным повседневным ритмом, которую стоит оценивать через бытовую совместимость и требования к уходу."
    if exercise == "high":
        return "Активная порода, которой обычно нужны регулярные нагрузки, вовлеченный владелец и понятный повседневный ритм."
    if grooming == "high":
        return "Порода с заметными требованиями к уходу, которую лучше оценивать не только по внешности, но и по бытовой совместимости."
    return "Порода с выраженными особенностями характера и ухода, которую стоит оценивать вместе с образом жизни владельца."


def build_candidate(manifest_entry: dict[str, Any], raw: dict[str, Any]) -> dict[str, Any]:
    facts = raw.get("facts") or {}
    characteristics = raw.get("characteristics") or {}
    source = raw.get("source") or {}
    identity = raw.get("identity") or {}

    size_draft = map_size_label(facts.get("breedSize"))
    exercise_draft = map_label(EXERCISE_MAP, characteristics.get("exerciseNeeds"))
    trainability_draft = map_label(TRAINABILITY_MAP, characteristics.get("easyToTrain"))
    shedding_draft = map_label(SHEDDING_MAP, characteristics.get("shedding"))
    grooming_draft = map_label(GROOMING_MAP, characteristics.get("groomingNeeds"))
    children_draft = map_label(CHILDREN_MAP, characteristics.get("goodWithChildren"))
    cost_draft = map_label(COST_MAP, characteristics.get("costToKeep"))
    alone_draft = map_label(ALONE_MAP, characteristics.get("toleratesBeingAlone"))

    summary = summary_from_raw(raw.get("summary"), characteristics)
    strengths = strengths_from_characteristics(characteristics)
    watchouts = watchouts_from_characteristics(characteristics)
    page_warnings = as_clean_list((raw.get("quality") or {}).get("pageWarnings"))

    has_trait_block = bool(characteristics)
    has_summary = bool(isinstance(summary, str) and summary.strip())

    content_ready = has_summary or bool(strengths) or bool(watchouts)
    media_ready = raw.get("heroImageUrl") is not None

    if has_trait_block:
        confidence_score = 0.71
    elif has_summary:
        confidence_score = 0.58
    else:
        confidence_score = 0.34

    return {
        "breedId": manifest_entry["breedId"],
        "petType": manifest_entry["petType"],
        "name": manifest_entry["name"],
        "source": {
            "origin": "freeads",
            "breedDetailsUrl": manifest_entry["breedDetailsUrl"],
            "urlStatus": source.get("urlStatus") or manifest_entry.get("urlStatus"),
            "freeadsBreedName": manifest_entry["freeadsBreedName"],
            "freeadsSlug": manifest_entry["freeadsSlug"],
            "rawIdentity": identity,
        },
        "sourceFacts": {
            "aliases": as_clean_list(facts.get("otherNames")),
            "breedGroup": facts.get("breedGroup"),
            "breedType": facts.get("breedType"),
            "breedSize": facts.get("breedSize"),
            "lifespan": facts.get("lifespan"),
            "weight": facts.get("weight"),
            "height": facts.get("height"),
            "pedigree": facts.get("pedigree"),
            "healthTestsAvailable": facts.get("healthTestsAvailable"),
        },
        "mediaDraft": {
            "imageUrl": raw.get("heroImageUrl"),
            "galleryImages": as_clean_list(raw.get("galleryImages")),
        },
        "contentDraft": {
            "summaryShort": summary,
            "strengths": strengths,
            "watchouts": watchouts,
        },
        "attributeExtractionHints": {
            "sizeDraft": size_draft,
            "exerciseNeedsDraft": exercise_draft,
            "trainabilityDraft": trainability_draft,
            "sheddingLevelDraft": shedding_draft,
            "groomingNeedsDraft": grooming_draft,
            "goodWithChildrenDraft": children_draft,
            "maintenanceCostDraft": cost_draft,
            "aloneToleranceDraft": alone_draft,
            "intelligenceLabel": characteristics.get("intelligence"),
            "healthOfBreedLabel": characteristics.get("healthOfBreed"),
            "rawCharacteristics": characteristics,
        },
        "importStatus": {
            "contentReady": content_ready,
            "mediaReady": media_ready,
            "attributesReady": False,
            "flagsReady": False,
        },
        "quality": {
            "confidenceScore": confidence_score,
            "sourceCount": 1,
            "sourceNotes": [
                "freeads breed page",
                "structured traits normalized into draft hints",
            ],
            "pageWarnings": page_warnings,
            "needsReview": True,
            "version": 1,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        default="docs/backend/import_candidates/freeads_phase1_manifest.v1.json",
    )
    parser.add_argument(
        "--raw-dir",
        default="docs/backend/import_candidates/freeads_raw",
    )
    parser.add_argument(
        "--output-dir",
        default="docs/backend/import_candidates",
    )
    args = parser.parse_args()

    manifest = load_json(Path(args.manifest))
    raw_dir = Path(args.raw_dir)
    output_dir = Path(args.output_dir)

    missing_raw: list[str] = []

    for entry in manifest.get("candidates") or []:
        raw_path = raw_dir / f"freeads.{entry['freeadsSlug']}.json"
        if not raw_path.exists():
            missing_raw.append(str(raw_path))
            continue

        raw = load_json(raw_path)
        candidate = build_candidate(entry, raw)
        save_json(output_dir / f"candidate.{entry['breedId']}.json", candidate)
        print(f"generated {entry['breedId']}")

    if missing_raw:
        print("\nSkipped candidates with missing raw snapshots:")
        for path in missing_raw:
            print(f"- {path}")


if __name__ == "__main__":
    main()
