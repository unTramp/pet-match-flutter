#!/usr/bin/env python3

from __future__ import annotations

import argparse
import csv
import json
from datetime import date
from pathlib import Path
from typing import Any


CSV_SOURCE_PATH = Path(
    "/Users/andreydorofeev/Development/CLAUDE/dog_stories_avatar_images/freeads_dog_breeds.csv",
)
AVATAR_SOURCE_DIR = Path(
    "/Users/andreydorofeev/Development/CLAUDE/dog_stories_avatar_images/webp_512",
)
DEFAULT_FULL_MANIFEST = Path(
    "docs/backend/import_candidates/freeads_full_manifest.v1.json",
)
DEFAULT_MAPPING = Path(
    "docs/backend/import_candidates/freeads_slug_mapping.v1.json",
)
DEFAULT_CATALOG = Path("docs/backend/examples/catalog.v1.json")


MANUAL_SLUG_OVERRIDES = {
    "bernese_mountain_dog": "bernese-mountain",
    "doberman": "dobermann",
    "english_cocker_spaniel": "cocker-spaniel",
    "jack_russell_terrier": "jack-russell",
    "italian_greyhound": "italian-greyhounds",
    "west_highland_white_terrier": "west-highland-terrier",
}


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def read_freeads_rows(csv_path: Path) -> list[dict[str, str]]:
    with csv_path.open("r", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def read_catalog_breeds(catalog_path: Path) -> list[dict[str, Any]]:
    catalog = load_json(catalog_path)
    breeds: list[dict[str, Any]] = []
    base_dir = catalog_path.parent
    for entry in catalog["breeds"]:
        breed_file = base_dir / entry["file"]
        breeds.append(load_json(breed_file))
    return breeds


def build_full_manifest(rows: list[dict[str, str]], avatar_dir: Path) -> dict[str, Any]:
    avatar_files = {path.name for path in avatar_dir.glob("*.webp")}
    breeds = []
    missing_avatar_slugs = []

    for row in sorted(rows, key=lambda item: item["breed_slug"]):
        avatar_file_name = f"{row['breed_slug']}.webp"
        avatar_available = avatar_file_name in avatar_files
        if not avatar_available:
            missing_avatar_slugs.append(row["breed_slug"])

        breeds.append(
            {
                "freeadsSlug": row["breed_slug"],
                "freeadsBreedName": row["breed_name"],
                "breedDetailsUrl": row["url"],
                "freeadsImageUrl": row["image_url"],
                "storyAvatar": {
                    "fileName": avatar_file_name,
                    "available": avatar_available,
                    "localSourceDirName": avatar_dir.name,
                    "suggestedUploadPath": f"/media/story-avatars/{avatar_file_name}",
                },
            },
        )

    return {
        "source": "freeads",
        "version": 1,
        "generatedAt": date.today().isoformat(),
        "notes": [
            "Generated from the external Freeads CSV + webp_512 avatar pack.",
            "This registry is for slug/media coordination, not for canonical scoring truth.",
            "Story avatar media should stay separate from hero/gallery image fields.",
        ],
        "avatarSource": {
            "csvFile": str(csv_path_for_output()),
            "avatarDirName": avatar_dir.name,
            "avatarFormat": "webp",
            "entryCount": len(breeds),
            "missingAvatarSlugs": missing_avatar_slugs,
        },
        "breeds": breeds,
    }


def build_mapping(
    rows: list[dict[str, str]],
    catalog_breeds: list[dict[str, Any]],
) -> dict[str, Any]:
    by_slug = {row["breed_slug"]: row for row in rows}
    mappings = []
    unresolved = []

    for breed in sorted(catalog_breeds, key=lambda item: item["breedId"]):
        petwise_breed_id = breed["breedId"]
        exact_slug = petwise_breed_id.replace("_", "-")
        freeads_slug = MANUAL_SLUG_OVERRIDES.get(petwise_breed_id, exact_slug)
        row = by_slug.get(freeads_slug)

        if row is None:
            unresolved.append(
                {
                    "petwiseBreedId": petwise_breed_id,
                    "petwiseBreedName": breed["name"],
                    "attemptedSlug": freeads_slug,
                },
            )
            continue

        if petwise_breed_id in MANUAL_SLUG_OVERRIDES:
            match_type = "manual_override"
        elif exact_slug == freeads_slug:
            match_type = "exact_slug"
        else:
            match_type = "normalized_slug"

        mappings.append(
            {
                "petwiseBreedId": petwise_breed_id,
                "petwiseBreedName": breed["name"],
                "freeadsSlug": row["breed_slug"],
                "freeadsBreedName": row["breed_name"],
                "breedDetailsUrl": row["url"],
                "freeadsImageUrl": row["image_url"],
                "storyAvatar": {
                    "fileName": f"{row['breed_slug']}.webp",
                    "suggestedUploadPath": f"/media/story-avatars/{row['breed_slug']}.webp",
                },
                "matchType": match_type,
            },
        )

    return {
        "source": "freeads",
        "version": 1,
        "generatedAt": date.today().isoformat(),
        "notes": [
            "Maps current canonical PetWise breed IDs to Freeads slugs and avatar files.",
            "Use this mapping before introducing storyAvatarUrl into backend/app contracts.",
        ],
        "manualSlugOverrides": MANUAL_SLUG_OVERRIDES,
        "mappingCount": len(mappings),
        "unresolvedCount": len(unresolved),
        "mappings": mappings,
        "unresolved": unresolved,
    }


def csv_path_for_output() -> str:
    return str(CSV_SOURCE_PATH)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a full Freeads slug/media registry and current PetWise mapping.",
    )
    parser.add_argument("--csv", type=Path, default=CSV_SOURCE_PATH)
    parser.add_argument("--avatar-dir", type=Path, default=AVATAR_SOURCE_DIR)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--full-manifest-out", type=Path, default=DEFAULT_FULL_MANIFEST)
    parser.add_argument("--mapping-out", type=Path, default=DEFAULT_MAPPING)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rows = read_freeads_rows(args.csv)
    catalog_breeds = read_catalog_breeds(args.catalog)

    full_manifest = build_full_manifest(rows, args.avatar_dir)
    mapping = build_mapping(rows, catalog_breeds)

    save_json(args.full_manifest_out, full_manifest)
    save_json(args.mapping_out, mapping)

    print(
        f"generated full manifest -> {args.full_manifest_out} ({len(full_manifest['breeds'])} breeds)",
    )
    print(
        f"generated mapping -> {args.mapping_out} ({mapping['mappingCount']} mapped, {mapping['unresolvedCount']} unresolved)",
    )


if __name__ == "__main__":
    main()
