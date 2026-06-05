#!/usr/bin/env python3

from __future__ import annotations

import argparse
import html
import json
import re
from pathlib import Path
from typing import Any


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def clean(value: str | None) -> str | None:
    if value is None:
        return None
    value = html.unescape(re.sub(r"<[^>]+>", " ", value))
    value = re.sub(r"\s+", " ", value).strip()
    return value or None


def extract_meta_description(page: str) -> str | None:
    match = re.search(r'<meta name="description" content="([^"]+)"', page, re.I)
    return clean(match.group(1)) if match else None


def extract_h1(page: str) -> str | None:
    match = re.search(r"<h1[^>]*>(.*?)</h1>", page, re.I | re.S)
    return clean(match.group(1)) if match else None


def extract_image(page: str) -> str | None:
    match = re.search(
        r'data-src=["\'](?://asset\.freeads\.co\.uk/v6/css/images/dog-breed/[^"\']+)["\']',
        page,
        re.I,
    )
    if not match:
        return None
    raw = match.group(0)
    url = re.search(r'(?://asset\.freeads\.co\.uk[^"\']+)', raw)
    if not url:
        return None
    return "https:" + url.group(0)


def extract_first_value_after_label(page: str, label_pattern: str, window: int = 800) -> str | None:
    match = re.search(label_pattern, page, re.I | re.S)
    if not match:
        return None
    snippet = page[match.end() : match.end() + window]
    value_match = re.search(r'<(?:span|div) class="text-muted"[^>]*>(.*?)</(?:span|div)>', snippet, re.I | re.S)
    return clean(value_match.group(1)) if value_match else None


def extract_weight_or_height(page: str, label: str) -> str | None:
    match = re.search(rf">{label}</div>", page, re.I | re.S)
    if not match:
        return None
    snippet = page[match.end() : match.end() + 400]
    values = re.findall(r'<div class="text-muted"[^>]*>(.*?)</div>', snippet, re.I | re.S)
    if not values:
        return None
    return "; ".join(clean(value) for value in values if clean(value))


def extract_other_names(page: str) -> list[str]:
    raw = extract_first_value_after_label(page, r">Other names</div>")
    if not raw:
        return []
    return [item.strip() for item in raw.split(",") if item.strip()]


def build_raw_snapshot(page: str, manifest_entry: dict[str, Any], existing: dict[str, Any] | None) -> dict[str, Any]:
    slug = manifest_entry["freeadsSlug"]
    breed_name = manifest_entry["freeadsBreedName"]

    snapshot = existing or {}
    snapshot["source"] = {
        "origin": "freeads",
        "url": manifest_entry["breedDetailsUrl"],
        "scrapedAt": "2026-06-05",
        "urlStatus": "verified_via_browser_capture",
    }
    snapshot["identity"] = {
        "breedName": breed_name,
        "slug": slug,
        "petType": manifest_entry["petType"],
    }
    snapshot["summary"] = extract_meta_description(page)
    snapshot["heroImageUrl"] = extract_image(page)
    snapshot["galleryImages"] = []
    snapshot["facts"] = {
        "otherNames": extract_other_names(page),
        "breedGroup": extract_first_value_after_label(page, r">Breed group</div>"),
        "breedType": extract_first_value_after_label(page, r">Breed Type</div>"),
        "breedSize": extract_first_value_after_label(page, r">Breed Size</div>"),
        "lifespan": extract_first_value_after_label(page, r">Lifespan</div>"),
        "weight": extract_weight_or_height(page, "Weight"),
        "height": extract_weight_or_height(page, "Height"),
        "pedigree": extract_first_value_after_label(page, r">Pedigree</div>"),
        "healthTestsAvailable": extract_first_value_after_label(page, r">Health tests available</div>"),
    }
    snapshot["characteristics"] = {
        "exerciseNeeds": extract_first_value_after_label(page, r">Exercise(?:&nbsp;|\s)*needs</div>"),
        "easyToTrain": extract_first_value_after_label(page, r">Easy(?:&nbsp;|\s)*to(?:&nbsp;|\s)*train</div>"),
        "shedding": extract_first_value_after_label(page, r">Shedding</div>"),
        "groomingNeeds": extract_first_value_after_label(page, r">Grooming(?:\s|&nbsp;|<br[^>]*>)*needs</div>"),
        "goodWithChildren": extract_first_value_after_label(page, r">Good(?:&nbsp;|\s)*with(?:\s|&nbsp;|<br[^>]*>)*Children</div>"),
        "healthOfBreed": extract_first_value_after_label(page, r">Health(?:&nbsp;|\s)*of(?:&nbsp;|\s)*breed</div>"),
        "costToKeep": extract_first_value_after_label(page, r">Cost(?:&nbsp;|\s)*to(?:&nbsp;|\s)*keep</div>"),
        "intelligence": extract_first_value_after_label(page, r">Intelligence</div>"),
        "toleratesBeingAlone": extract_first_value_after_label(page, r">Tolerates(?:&nbsp;|\s)*being(?:&nbsp;|\s)*alone</div>"),
    }
    snapshot["quality"] = {
        "pageWarnings": ["Captured manually after Cloudflare browser pass."],
    }
    return snapshot


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Parse saved Freeads HTML into raw snapshot JSON files.")
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_phase1_manifest.v1.json"),
        help="Freeads manifest JSON.",
    )
    parser.add_argument(
        "--html-dir",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_html"),
        help="Directory with saved HTML files from browser capture.",
    )
    parser.add_argument(
        "--raw-dir",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_raw"),
        help="Directory where raw Freeads JSON snapshots are stored.",
    )
    parser.add_argument(
        "--breed-id",
        action="append",
        dest="breed_ids",
        help="Specific breedId to parse. Can be repeated.",
    )
    return parser.parse_args()


def manifest_entries(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    entries = manifest.get("candidates")
    if isinstance(entries, list):
        return entries

    entries = manifest.get("breeds")
    if isinstance(entries, list):
        return entries

    raise KeyError("Manifest must contain a 'candidates' or 'breeds' array.")


def select_entries(manifest: dict[str, Any], breed_ids: list[str] | None) -> list[dict[str, Any]]:
    entries = manifest_entries(manifest)
    if not breed_ids:
        return entries
    wanted = set(breed_ids)
    return [entry for entry in entries if entry["breedId"] in wanted]


def main() -> None:
    args = parse_args()
    manifest = load_json(args.manifest)
    entries = select_entries(manifest, args.breed_ids)
    if not entries:
        raise SystemExit("No matching breeds found in manifest.")

    for entry in entries:
        html_path = args.html_dir / f"freeads.{entry['freeadsSlug']}.html"
        if not html_path.exists():
            print(f"skip {entry['breedId']}: HTML not found at {html_path}")
            continue

        raw_path = args.raw_dir / f"freeads.{entry['freeadsSlug']}.json"
        existing = load_json(raw_path) if raw_path.exists() else None
        page = html_path.read_text(encoding="utf-8", errors="ignore")
        snapshot = build_raw_snapshot(page, entry, existing)
        save_json(raw_path, snapshot)
        print(f"parsed {entry['breedId']} -> {raw_path}")


if __name__ == "__main__":
    main()
