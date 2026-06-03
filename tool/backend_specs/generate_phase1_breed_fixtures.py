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


def map_exercise(activity_level: str | None, fallback: int) -> int:
    mapping = {
        "low": 1,
        "medium": 3,
        "high": 5,
        "unknown": fallback,
        None: fallback,
    }
    return mapping.get(activity_level, fallback)


def map_apartment(space_requirement: str | None, apartment_friendly: bool | None, fallback: int) -> int:
    if apartment_friendly is True and space_requirement == "apartment":
        return 5
    if apartment_friendly is True and space_requirement == "apartment_or_small_house":
        return 4
    if apartment_friendly is False and space_requirement == "large_house":
        return 2
    return fallback


def map_grooming(grooming_frequency: str | None, fallback: int) -> int:
    mapping = {
        "daily": 5,
        "two_three_times_per_week": 4,
        "several_times_per_week": 4,
        "one_two_times_per_week": 3,
        "weekly": 2,
        "occasionally": 1,
        None: fallback,
    }
    return mapping.get(grooming_frequency, fallback)


def map_maintenance(monthly_cost: dict[str, Any] | None, fallback: int) -> int:
    if not isinstance(monthly_cost, dict):
        return fallback
    max_cost = monthly_cost.get("max")
    if not isinstance(max_cost, int):
        return fallback
    if max_cost <= 120:
        return 2
    if max_cost <= 180:
        return 3
    if max_cost <= 260:
        return 4
    return 5


def map_beginner(template_value: int, energy_level: str | None, mental: str | None, large_space: bool) -> int:
    if energy_level == "high" and mental == "high" and large_space:
        return min(template_value, 2)
    if energy_level == "high":
        return min(template_value, 3)
    if energy_level == "low":
        return max(template_value, 4)
    return template_value


def map_trainability(template_value: int, mental: str | None) -> int:
    derived = {
        "high": 4,
        "medium": 3,
        "low": 2,
        None: template_value,
    }.get(mental, template_value)
    return max(template_value, derived)


def map_temperament(energy_level: str | None, fallback: int) -> int:
    mapping = {
        "low": 5,
        "medium": 4,
        "high": 2,
        None: fallback,
    }
    return mapping.get(energy_level, fallback)


def map_alone_tolerance(template_value: int, independent: Any, tolerates_alone: Any, human_oriented: Any) -> int:
    if tolerates_alone is True or independent is True:
        return max(template_value, 4)
    if human_oriented is True:
        return min(template_value, 2)
    return template_value


def adaptation_tips(attributes: dict[str, int], content: dict[str, Any], candidate: dict[str, Any]) -> list[str]:
    tips: list[str] = []

    if attributes["exerciseNeeds"] >= 4:
        tips.append("заранее планировать активные прогулки и регулярную нагрузку")
    elif attributes["exerciseNeeds"] <= 2:
        tips.append("поддерживать короткий, но регулярный ритм прогулок и игр")

    if attributes["groomingNeeds"] >= 4:
        tips.append("закладывать время и бюджет на регулярный груминг")

    if attributes["apartmentSuitability"] <= 2:
        tips.append("лучше всего чувствует себя при доступе к пространству и регулярной активности")

    if attributes["trainability"] >= 4:
        tips.append("лучше раскрывается при раннем обучении и последовательной социализации")

    if not tips:
        tips.append("важно подстроить повседневный ритм и обучение под темперамент породы")

    return tips[:2]


def build_fixture(candidate: dict[str, Any], template: dict[str, Any], catalog_version: int) -> dict[str, Any]:
    template_attributes = dict(template["attributes"])
    template_flags = dict(template["flags"])

    hints = candidate["attributeExtractionHints"]
    energy_level = hints.get("energyLevel")
    activity_level = hints.get("activityLevel")
    mental = hints.get("mentalStimulation")
    grooming_frequency = hints.get("groomingFrequency")
    apartment_friendly = hints.get("apartmentFriendly")
    space_requirement = hints.get("spaceRequirement")
    large_space = space_requirement == "large_house"
    good_with_dogs = hints.get("goodWithDogs")
    good_with_pets = hints.get("goodWithPets")

    attributes = dict(template_attributes)
    attributes["exerciseNeeds"] = map_exercise(activity_level, attributes["exerciseNeeds"])
    attributes["apartmentSuitability"] = map_apartment(
        space_requirement,
        apartment_friendly,
        attributes["apartmentSuitability"],
    )
    attributes["groomingNeeds"] = map_grooming(
        grooming_frequency,
        attributes["groomingNeeds"],
    )
    attributes["maintenanceCost"] = map_maintenance(
        hints.get("monthlyCostRangeGbp"),
        attributes["maintenanceCost"],
    )
    attributes["beginnerFriendly"] = map_beginner(
        attributes["beginnerFriendly"],
        energy_level,
        mental,
        large_space,
    )
    attributes["trainability"] = map_trainability(attributes["trainability"], mental)
    attributes["temperamentCalm"] = map_temperament(
        energy_level,
        attributes["temperamentCalm"],
    )
    attributes["aloneTolerance"] = map_alone_tolerance(
        attributes["aloneTolerance"],
        hints.get("independent"),
        hints.get("toleratesAloneTime"),
        hints.get("humanOriented"),
    )

    if good_with_dogs is True or good_with_pets is True:
        attributes["goodWithOtherPets"] = max(attributes["goodWithOtherPets"], 4)

    explicit_attribute_overrides = {
        "maltese": {
            "size": 1,
            "sheddingLevel": 1,
            "goodWithChildren": 3,
            "noiseLevel": 3,
        },
        "pug": {
            "size": 2,
            "sheddingLevel": 4,
            "goodWithOtherPets": 4,
            "noiseLevel": 3,
            "maintenanceCost": 4,
        },
        "jack_russell_terrier": {
            "size": 1,
            "apartmentSuitability": 4,
            "exerciseNeeds": 4,
            "goodWithChildren": 3,
            "maintenanceCost": 3,
            "noiseLevel": 4,
            "trainability": 4,
            "temperamentCalm": 2,
            "beginnerFriendly": 2,
        },
        "english_cocker_spaniel": {
            "size": 3,
            "goodWithChildren": 4,
            "goodWithOtherPets": 4,
            "beginnerFriendly": 4,
            "maintenanceCost": 4,
            "trainability": 4,
        },
        "doberman": {
            "size": 5,
            "goodWithChildren": 3,
            "goodWithOtherPets": 2,
            "sheddingLevel": 2,
            "noiseLevel": 3,
            "trainability": 5,
            "temperamentCalm": 2,
            "beginnerFriendly": 1,
        },
        "yorkshire_terrier": {
            "size": 1,
            "apartmentSuitability": 5,
            "exerciseNeeds": 2,
            "goodWithChildren": 2,
            "goodWithOtherPets": 3,
            "sheddingLevel": 1,
            "maintenanceCost": 4,
            "noiseLevel": 4,
            "trainability": 4,
            "temperamentCalm": 3,
            "beginnerFriendly": 3,
        },
        "american_cocker_spaniel": {
            "size": 3,
            "apartmentSuitability": 4,
            "exerciseNeeds": 5,
            "aloneTolerance": 2,
            "goodWithChildren": 4,
            "goodWithOtherPets": 4,
            "sheddingLevel": 3,
            "maintenanceCost": 5,
            "noiseLevel": 3,
            "trainability": 4,
            "temperamentCalm": 3,
            "beginnerFriendly": 3,
        },
        "rottweiler": {
            "size": 5,
            "apartmentSuitability": 2,
            "exerciseNeeds": 5,
            "aloneTolerance": 3,
            "goodWithChildren": 3,
            "goodWithOtherPets": 2,
            "groomingNeeds": 2,
            "sheddingLevel": 3,
            "beginnerFriendly": 1,
            "maintenanceCost": 5,
            "noiseLevel": 3,
            "trainability": 5,
            "temperamentCalm": 4,
        },
    }
    attributes.update(explicit_attribute_overrides.get(candidate["breedId"], {}))

    explicit_flag_overrides = {
        "maltese": {
            "isVocal": False,
            "isHighPreyDrive": False,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": True,
        },
        "pug": {
            "isVocal": False,
            "isHighPreyDrive": False,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": True,
        },
        "jack_russell_terrier": {
            "isVocal": True,
            "isHighPreyDrive": True,
            "isSensitive": False,
            "isEscapeProne": True,
            "isSuitableForFirstTimeOwners": False,
        },
        "english_cocker_spaniel": {
            "isVocal": False,
            "isHighPreyDrive": True,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": True,
        },
        "doberman": {
            "isVocal": False,
            "isHighPreyDrive": False,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": False,
        },
        "yorkshire_terrier": {
            "isVocal": True,
            "isHighPreyDrive": False,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": True,
        },
        "american_cocker_spaniel": {
            "isVocal": False,
            "isHighPreyDrive": True,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": False,
        },
        "rottweiler": {
            "isVocal": False,
            "isHighPreyDrive": False,
            "isSensitive": True,
            "isEscapeProne": False,
            "isSuitableForFirstTimeOwners": False,
        },
    }
    flags = explicit_flag_overrides.get(candidate["breedId"], template_flags)

    content = {
        "summaryShort": candidate["contentDraft"]["summaryShort"],
        "strengths": candidate["contentDraft"]["strengths"],
        "watchouts": candidate["contentDraft"]["watchouts"],
        "adaptationTips": adaptation_tips(attributes, candidate["contentDraft"], candidate),
    }

    return {
        "breedId": candidate["breedId"],
        "petType": candidate["petType"],
        "name": candidate["name"],
        "aliases": candidate["source"].get("normalizedIdentity", {}).get("name_en")
        and [candidate["source"]["normalizedIdentity"]["name_en"]]
        or candidate["source"].get("aliases")
        or [],
        "group": candidate["source"].get("group") or candidate.get("group") or "unknown",
        "attributes": attributes,
        "flags": flags,
        "content": content,
        "quality": {
            "confidenceScore": 0.69,
            "sourceCount": 3,
            "sourceNotes": [
                "template breed baseline",
                "pets_json raw source",
                "normalized_pets structured hints",
            ],
            "needsReview": True,
            "version": catalog_version,
        },
        "imageUrl": candidate["mediaDraft"]["imageUrl"],
        "galleryImages": candidate["mediaDraft"]["galleryImages"],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        default="docs/backend/import_candidates/phase1_manifest.json",
    )
    parser.add_argument(
        "--candidate-dir",
        default="docs/backend/import_candidates",
    )
    parser.add_argument(
        "--examples-dir",
        default="docs/backend/examples",
    )
    parser.add_argument(
        "--catalog-path",
        default="docs/backend/examples/catalog.v1.json",
    )
    args = parser.parse_args()

    manifest = load_json(Path(args.manifest))
    candidate_dir = Path(args.candidate_dir)
    examples_dir = Path(args.examples_dir)
    catalog = load_json(Path(args.catalog_path))
    catalog_version = int(catalog.get("catalogVersion", 1))

    template_index = {}
    for path in examples_dir.glob("breed.*.json"):
        data = load_json(path)
        template_index[data["breedId"]] = data

    for entry in manifest.get("candidates") or []:
        candidate_path = candidate_dir / f"candidate.{entry['breedId']}.json"
        candidate = load_json(candidate_path)
        candidate["group"] = entry.get("group")
        if entry.get("aliases"):
            candidate.setdefault("source", {})["aliases"] = entry["aliases"]
        template = template_index[entry["templateBreedId"]]
        fixture = build_fixture(candidate, template, catalog_version)
        output_path = examples_dir / f"breed.{entry['breedId']}.json"
        save_json(output_path, fixture)
        print(f"generated {output_path.name}")


if __name__ == "__main__":
    main()
