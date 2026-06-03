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


def collect_index(paths: list[Path], key_path: tuple[str, ...]) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for path in paths:
        data = load_json(path)
        value: Any = data
        for key in key_path:
            if not isinstance(value, dict):
                value = None
                break
            value = value.get(key)
        if isinstance(value, str) and value:
            result[value] = data
    return result


def source_sections(raw: dict[str, Any]) -> dict[str, str]:
    result: dict[str, str] = {}
    for section in raw.get("sections") or []:
        key = section.get("key")
        body = section.get("body")
        if isinstance(key, str) and isinstance(body, str):
            result[key] = body.strip()
    return result


def summary_from_normalized(normalized: dict[str, Any]) -> str:
    traits = normalized.get("traits") or {}
    environment = normalized.get("environment") or {}

    energy = traits.get("energy_level")
    apartment = environment.get("apartment_friendly")
    space = environment.get("space_requirement")

    if energy == "low" and apartment is True:
        return "Небольшой спокойный companion для размеренного ритма жизни, который хорошо чувствует себя в квартире."
    if energy == "medium" and apartment is True:
        return "Компактная порода с умеренной активностью, которая обычно хорошо подходит для квартиры и спокойного домашнего ритма."
    if energy == "high" and apartment is True:
        return "Компактный, но очень энергичный companion, которому нужны регулярные активности и вовлеченный владелец."
    if energy == "medium" and space == "apartment_or_small_house":
        return "Дружелюбная порода с умеренной активностью, которой нужен регулярный уход и тесный контакт с владельцем."
    if energy == "high" and space == "large_house":
        return "Активная и требовательная порода, которой нужны пространство, регулярные нагрузки и вовлеченный владелец."
    return "Порода с выраженным темпераментом и требованиями к повседневному ритму, которую стоит оценивать вместе с образом жизни владельца."


def strengths_from_normalized(normalized: dict[str, Any]) -> list[str]:
    traits = normalized.get("traits") or {}
    environment = normalized.get("environment") or {}
    care = normalized.get("care") or {}

    strengths: list[str] = []

    if environment.get("apartment_friendly") is True:
        strengths.append("подходит для квартиры")

    energy = traits.get("energy_level")
    if energy == "low":
        strengths.append("подходит для размеренного ритма")
    elif energy == "medium":
        strengths.append("умеренный уровень активности")
    elif energy == "high":
        strengths.append("подходит для активного образа жизни")

    if traits.get("good_with_dogs") is True:
        strengths.append("обычно хорошо ладит с другими собаками")

    if environment.get("space_requirement") == "large_house":
        strengths.append("лучше чувствует себя в доме с большим пространством")
    elif environment.get("space_requirement") == "apartment_or_small_house":
        strengths.append("подходит для небольшого дома или просторной квартиры")

    if care.get("grooming_frequency") == "weekly":
        strengths.append("уход не требует ежедневного груминга")

    return strengths[:3]


def watchouts_from_normalized(normalized: dict[str, Any]) -> list[str]:
    traits = normalized.get("traits") or {}
    care = normalized.get("care") or {}

    watchouts: list[str] = []

    if care.get("grooming_frequency") == "daily":
        watchouts.append("требует ежедневного ухода за шерстью")
    elif care.get("grooming_frequency") in {"one_two_times_per_week", "two_three_times_per_week", "several_times_per_week"}:
        watchouts.append("нуждается в регулярном уходе за шерстью")

    if traits.get("mental_stimulation") == "high":
        watchouts.append("нуждается в занятиях, обучении и ментальной нагрузке")
    elif traits.get("mental_stimulation") == "medium":
        watchouts.append("нуждается в регулярной ментальной стимуляции")

    energy = traits.get("energy_level")
    if energy == "high":
        watchouts.append("не подойдет для пассивного ритма жизни")
    elif energy == "low":
        watchouts.append("может не подойти тем, кто ищет более активную породу")

    return watchouts[:3]


def monthly_cost_range(normalized: dict[str, Any]) -> dict[str, int] | None:
    monthly = ((normalized.get("costs") or {}).get("monthly_cost")) or {}
    min_value = monthly.get("min")
    max_value = monthly.get("max")
    if isinstance(min_value, int) and isinstance(max_value, int):
        return {"min": min_value, "max": max_value}
    return None


def build_candidate(
    *,
    manifest_entry: dict[str, Any],
    raw: dict[str, Any],
    normalized: dict[str, Any],
) -> dict[str, Any]:
    sections = source_sections(raw)
    requirements = sections.get("requirements")
    suitable_for = sections.get("suitable_for")
    peculiarities = sections.get("peculiarities")
    expenses = sections.get("expenses")

    return {
        "breedId": manifest_entry["breedId"],
        "petType": "dog" if (normalized.get("identity") or {}).get("pet_type") == "dog" else "cat",
        "name": manifest_entry["name"],
        "source": {
            "origin": "pets_json+normalized_pets",
            "breedCode": raw.get("breed_code"),
            "breedName": raw.get("breed_name"),
            "petTypeRaw": raw.get("pet_type"),
            "normalizedIdentity": normalized.get("identity"),
        },
        "mediaDraft": {
            "imageUrl": raw.get("image_url"),
            "galleryImages": list((raw.get("gallery_images") or [])[:5]),
        },
        "contentDraft": {
            "summaryShort": summary_from_normalized(normalized),
            "strengths": strengths_from_normalized(normalized),
            "watchouts": watchouts_from_normalized(normalized),
        },
        "attributeExtractionHints": {
            "energyLevel": (normalized.get("traits") or {}).get("energy_level"),
            "activityLevel": (normalized.get("traits") or {}).get("activity_level"),
            "mentalStimulation": (normalized.get("traits") or {}).get("mental_stimulation"),
            "groomingFrequency": (normalized.get("care") or {}).get("grooming_frequency"),
            "apartmentFriendly": (normalized.get("environment") or {}).get("apartment_friendly"),
            "spaceRequirement": (normalized.get("environment") or {}).get("space_requirement"),
            "yardPreferred": (normalized.get("environment") or {}).get("yard_preferred"),
            "goodWithDogs": (normalized.get("traits") or {}).get("good_with_dogs"),
            "goodWithPets": (normalized.get("traits") or {}).get("good_with_pets"),
            "physicalActivityText": (((normalized.get("care") or {}).get("activity_duration")) or {}).get("label"),
            "coatNote": (normalized.get("care") or {}).get("coat_note"),
            "monthlyCostRangeGbp": monthly_cost_range(normalized),
            "requirementsText": requirements,
            "suitableForText": suitable_for,
            "peculiaritiesText": peculiarities,
            "expensesText": expenses,
            "matchingTags": ((normalized.get("ai") or {}).get("matching_tags")) or [],
        },
        "importStatus": {
            "contentReady": True,
            "mediaReady": True,
            "attributesReady": False,
            "flagsReady": False,
        },
        "quality": {
            "confidenceScore": 0.66,
            "sourceCount": 2,
            "sourceNotes": [
                "pets_json raw source",
                "normalized_pets structured hints",
            ],
            "needsReview": True,
            "version": 1,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        default="docs/backend/import_candidates/phase1_manifest.json",
    )
    parser.add_argument(
        "--pets-json-dir",
        default="/Users/andreydorofeev/Development/CLAUDE/pet_match_parser/pets_json",
    )
    parser.add_argument(
        "--normalized-dir",
        default="/Users/andreydorofeev/Development/CLAUDE/pet_match_parser/normalized_pets",
    )
    parser.add_argument(
        "--output-dir",
        default="docs/backend/import_candidates",
    )
    args = parser.parse_args()

    manifest = load_json(Path(args.manifest))
    raw_index = collect_index(
        sorted(Path(args.pets_json_dir).glob("*.json")),
        ("breed_code",),
    )
    normalized_index = collect_index(
        sorted(Path(args.normalized_dir).glob("*.json")),
        ("identity", "code"),
    )

    output_dir = Path(args.output_dir)

    for entry in manifest.get("candidates") or []:
        code = entry["sourceBreedCode"]
        raw = raw_index.get(code)
        normalized = normalized_index.get(code)
        if raw is None or normalized is None:
            raise SystemExit(f"Missing source data for {code}")

        candidate = build_candidate(
            manifest_entry=entry,
            raw=raw,
            normalized=normalized,
        )
        save_json(output_dir / f"candidate.{entry['breedId']}.json", candidate)
        print(f"generated {entry['breedId']}")


if __name__ == "__main__":
    main()
