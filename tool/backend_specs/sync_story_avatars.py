#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Copy mapped Freeads story avatar files into backend media root."
    )
    parser.add_argument(
        "--mapping",
        default="docs/backend/import_candidates/freeads_slug_mapping.v1.json",
        help="Path to freeads slug mapping JSON.",
    )
    parser.add_argument(
        "--source-dir",
        required=True,
        help="Directory with source .webp avatar files.",
    )
    parser.add_argument(
        "--output-dir",
        default="backend/media/story-avatars",
        help="Destination directory for synced avatars.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    mapping_path = Path(args.mapping)
    source_dir = Path(args.source_dir)
    output_dir = Path(args.output_dir)

    if not mapping_path.exists():
        raise SystemExit(f"Mapping file not found: {mapping_path}")
    if not source_dir.exists():
        raise SystemExit(f"Source directory not found: {source_dir}")

    data = json.loads(mapping_path.read_text(encoding="utf-8"))
    mappings = data.get("mappings", [])
    if not isinstance(mappings, list) or not mappings:
        raise SystemExit("Mapping file does not contain any mappings.")

    output_dir.mkdir(parents=True, exist_ok=True)

    copied = 0
    missing: list[str] = []
    for item in mappings:
        avatar = item.get("storyAvatar") or {}
        file_name = avatar.get("fileName")
        if not isinstance(file_name, str) or not file_name:
            continue

        source_file = source_dir / file_name
        if not source_file.exists():
            missing.append(file_name)
            continue

        shutil.copy2(source_file, output_dir / file_name)
        copied += 1

    print(
        json.dumps(
            {
                "copied": copied,
                "missingCount": len(missing),
                "missing": missing,
                "outputDir": str(output_dir),
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0 if not missing else 1


if __name__ == "__main__":
    raise SystemExit(main())
