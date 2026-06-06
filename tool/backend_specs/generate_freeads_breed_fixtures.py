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


ATTRIBUTE_OVERRIDES: dict[str, dict[str, int]] = {
    "west_highland_white_terrier": {
        "size": 2,
        "apartmentSuitability": 4,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 4,
        "goodWithOtherPets": 3,
        "groomingNeeds": 5,
        "sheddingLevel": 3,
        "beginnerFriendly": 3,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 3,
        "temperamentCalm": 3,
    },
    "papillon": {
        "size": 1,
        "apartmentSuitability": 5,
        "exerciseNeeds": 4,
        "aloneTolerance": 2,
        "goodWithChildren": 3,
        "goodWithOtherPets": 4,
        "groomingNeeds": 3,
        "sheddingLevel": 2,
        "beginnerFriendly": 3,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 5,
        "temperamentCalm": 3,
    },
    "pomeranian": {
        "size": 1,
        "apartmentSuitability": 5,
        "exerciseNeeds": 2,
        "aloneTolerance": 3,
        "goodWithChildren": 2,
        "goodWithOtherPets": 3,
        "groomingNeeds": 4,
        "sheddingLevel": 2,
        "beginnerFriendly": 4,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 4,
        "temperamentCalm": 4,
    },
    "miniature_schnauzer": {
        "size": 2,
        "apartmentSuitability": 5,
        "exerciseNeeds": 3,
        "aloneTolerance": 4,
        "goodWithChildren": 3,
        "goodWithOtherPets": 3,
        "groomingNeeds": 4,
        "sheddingLevel": 1,
        "beginnerFriendly": 4,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 5,
        "temperamentCalm": 3,
    },
    "boston_terrier": {
        "size": 2,
        "apartmentSuitability": 5,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 3,
        "goodWithOtherPets": 3,
        "groomingNeeds": 1,
        "sheddingLevel": 2,
        "beginnerFriendly": 4,
        "maintenanceCost": 4,
        "noiseLevel": 3,
        "trainability": 4,
        "temperamentCalm": 3,
    },
    "staffordshire_bull_terrier": {
        "size": 3,
        "apartmentSuitability": 3,
        "exerciseNeeds": 4,
        "aloneTolerance": 3,
        "goodWithChildren": 4,
        "goodWithOtherPets": 2,
        "groomingNeeds": 1,
        "sheddingLevel": 3,
        "beginnerFriendly": 3,
        "maintenanceCost": 3,
        "noiseLevel": 3,
        "trainability": 3,
        "temperamentCalm": 3,
    },
    "akita": {
        "size": 5,
        "apartmentSuitability": 1,
        "exerciseNeeds": 5,
        "aloneTolerance": 4,
        "goodWithChildren": 2,
        "goodWithOtherPets": 1,
        "groomingNeeds": 3,
        "sheddingLevel": 5,
        "beginnerFriendly": 1,
        "maintenanceCost": 5,
        "noiseLevel": 2,
        "trainability": 3,
        "temperamentCalm": 4,
    },
}


FLAG_OVERRIDES: dict[str, dict[str, bool]] = {
    "west_highland_white_terrier": {
        "isVocal": True,
        "isHighPreyDrive": True,
        "isSensitive": False,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "papillon": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "pomeranian": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "miniature_schnauzer": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": False,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "boston_terrier": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "staffordshire_bull_terrier": {
        "isVocal": False,
        "isHighPreyDrive": True,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "akita": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": False,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
}


QUALITY_OVERRIDES: dict[str, dict[str, Any]] = {
    "west_highland_white_terrier": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "papillon": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "pomeranian": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "miniature_schnauzer": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "boston_terrier": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "staffordshire_bull_terrier": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "akita": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
}


def story_avatar_url(candidate: dict[str, Any]) -> str:
    slug = candidate["source"]["freeadsSlug"]
    return f"https://petwise-api.65-109-135-215.sslip.io/media/story-avatars/{slug}.webp"


def adaptation_tips(breed_id: str) -> list[str]:
    tips = {
        "west_highland_white_terrier": [
            "лучше всего чувствует себя в доме, где готовы к регулярному грумингу и terrier-упрямству",
            "важно заранее работать с голосистостью, самоконтролем и знакомством с другими животными",
        ],
        "papillon": [
            "лучше всего раскрывается при ежедневной ментальной нагрузке и коротких активных прогулках",
            "важно заранее поработать с возбуждением и шумностью дома, несмотря на миниатюрный размер",
        ],
        "pomeranian": [
            "важно заранее принять более шумный toy-ритм и короткие, но регулярные прогулки",
            "сразу закладывать время на уход за шерстью и аккуратную социализацию",
        ],
        "miniature_schnauzer": [
            "лучше всего раскрывается при регулярных коротких занятиях и понятной рутине",
            "стоит заранее закладывать груминг и работу с голосистостью дома",
        ],
        "boston_terrier": [
            "хорошо чувствует себя в квартирном ритме, если поддерживать умеренную активность",
            "важно избегать перегрева и внимательно относиться к дыханию в жаркую погоду",
        ],
        "staffordshire_bull_terrier": [
            "лучше всего чувствует себя при последовательной социализации, понятных границах и ежедневной активности",
            "стоит заранее планировать работу с самоконтролем и аккуратное знакомство с другими животными",
        ],
        "akita": [
            "нужны пространство, стабильная социализация и владелец, готовый к самостоятельному характеру породы",
            "лучше заранее закладывать активный ритм, контроль контактов с другими животными и уход за шерстью",
        ],
    }
    return tips[breed_id]


def summary_short(candidate: dict[str, Any], breed_id: str) -> str:
    if breed_id == "west_highland_white_terrier":
        return (
            "Небольшой, уверенный и более упрямый terrier-companion, которому подходят умеренная активность, "
            "регулярный груминг и владелец, готовый к более выраженному характеру."
        )
    if breed_id == "papillon":
        return (
            "Очень маленький, но surprisingly активный и очень обучаемый toy-companion, "
            "которому важны занятия, вовлечённость и аккуратная работа с возбуждением."
        )
    if breed_id == "pomeranian":
        return (
            "Очень маленький, заметно более vocal toy-companion для квартиры, "
            "который хорошо обучается, но требует регулярного ухода за шерстью."
        )
    if breed_id == "miniature_schnauzer":
        return (
            "Компактная и сообразительная utility-порода с умеренной активностью, "
            "низкой линькой и заметной потребностью в регулярном груминге."
        )
    if breed_id == "boston_terrier":
        return (
            "Компактный, дружелюбный и квартирный companion с умеренной активностью "
            "и простым уходом, но с чувствительностью к здоровью и перегреву."
        )
    if breed_id == "staffordshire_bull_terrier":
        return (
            "Компактный muscular terrier-family companion с заметной вовлечённостью в людей, "
            "умеренно высокой активностью и простым уходом за шерстью."
        )
    if breed_id == "akita":
        return (
            "Крупная самостоятельная utility-порода с высокой нагрузкой, тяжёлой линькой "
            "и требовательностью к социализации, опыту и контролю окружения."
        )
    return candidate["contentDraft"]["summaryShort"]


def strengths(candidate: dict[str, Any], breed_id: str) -> list[str]:
    if breed_id == "west_highland_white_terrier":
        return [
            "подходит для компактного формата жизни при достаточной рутине",
            "обычно остаётся бодрым и вовлечённым companion-терьером",
            "может хорошо жить в семье, если заранее заложен груминг и правила",
        ]
    if breed_id == "papillon":
        return [
            "очень хорошо поддается обучению",
            "подходит для квартиры при достаточной вовлечённости",
            "даёт много отклика на игры и ментальную нагрузку",
        ]
    if breed_id == "pomeranian":
        return [
            "подходит для квартиры",
            "обычно хорошо поддается обучению",
            "подходит для более спокойного ритма жизни",
        ]
    if breed_id == "miniature_schnauzer":
        return [
            "умеренная активность для компактной собаки",
            "низкая линька",
            "обычно хорошо поддается обучению",
        ]
    if breed_id == "boston_terrier":
        return [
            "подходит для квартиры",
            "обычно хорошо поддается обучению",
            "уход за шерстью остается простым",
        ]
    if breed_id == "staffordshire_bull_terrier":
        return [
            "обычно очень ориентирован на людей",
            "прост в базовом уходе за шерстью",
            "может быть хорошим активным семейным компаньоном при ответственной социализации",
        ]
    if breed_id == "akita":
        return [
            "лучше раскрывается у владельца, готового к дисциплине и активному ритму",
            "обычно сохраняет собранность и независимость в знакомой рутине",
            "хорошо подходит для крупного protective-профиля",
        ]
    return candidate["contentDraft"]["strengths"]


def watchouts(candidate: dict[str, Any], breed_id: str) -> list[str]:
    if breed_id == "west_highland_white_terrier":
        return [
            "регулярный груминг и уход за шерстью лучше считать обязательной частью жизни с породой",
            "может быть более шумным, упрямым и terrier-like, чем ожидают от маленькой белой собаки",
        ]
    if breed_id == "papillon":
        return [
            "может оказаться гораздо активнее и шумнее, чем ожидают от toy-породы",
            "лучше чувствует себя при уважительном обращении и без грубого контакта с маленькими детьми",
        ]
    if breed_id == "pomeranian":
        return [
            "может быть заметно более шумным, чем кажется по размеру",
            "требует регулярного ухода за шерстью",
            "с маленькими детьми лучше чувствует себя при спокойном и уважительном обращении",
        ]
    if breed_id == "miniature_schnauzer":
        return [
            "регулярный груминг лучше закладывать заранее",
            "может быть более голосистым и внимательным к окружению",
        ]
    if breed_id == "boston_terrier":
        return [
            "лучше чувствует себя с детьми постарше и при спокойном обращении",
            "нужна внимательность к дыханию и перегреву",
        ]
    if breed_id == "staffordshire_bull_terrier":
        return [
            "не лучший выбор для слабой дисциплины и хаотичной социализации",
            "контакт с другими животными лучше выстраивать осторожно и последовательно",
        ]
    if breed_id == "akita":
        return [
            "не лучший выбор для новичков или дома с несколькими животными без опытного управления",
            "тяжёлая линька, нагрузка и стоимость содержания требуют готовности заранее",
        ]
    return candidate["contentDraft"]["watchouts"]


def build_fixture(candidate: dict[str, Any], template: dict[str, Any], group: str) -> dict[str, Any]:
    breed_id = candidate["breedId"]
    aliases = candidate["sourceFacts"].get("aliases") or []

    return {
        "breedId": breed_id,
        "petType": candidate["petType"],
        "name": candidate["name"],
        "aliases": aliases,
        "group": group,
        "attributes": ATTRIBUTE_OVERRIDES[breed_id],
        "flags": FLAG_OVERRIDES[breed_id],
        "content": {
            "summaryShort": summary_short(candidate, breed_id),
            "strengths": strengths(candidate, breed_id),
            "watchouts": watchouts(candidate, breed_id),
            "adaptationTips": adaptation_tips(breed_id),
        },
        "quality": {
            "confidenceScore": QUALITY_OVERRIDES[breed_id]["confidenceScore"],
            "sourceCount": QUALITY_OVERRIDES[breed_id]["sourceCount"],
            "sourceNotes": [
                "template breed baseline",
                "freeads browser capture review",
            ],
            "needsReview": True,
            "version": template["quality"]["version"],
        },
        "imageUrl": None,
        "galleryImages": [],
        "storyAvatarUrl": story_avatar_url(candidate),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        default="docs/backend/import_candidates/freeads_phase2_import_manifest.v1.json",
    )
    parser.add_argument(
        "--candidate-dir",
        default="docs/backend/import_candidates/freeads_candidates",
    )
    parser.add_argument(
        "--examples-dir",
        default="docs/backend/examples",
    )
    args = parser.parse_args()

    manifest = load_json(Path(args.manifest))
    candidate_dir = Path(args.candidate_dir)
    examples_dir = Path(args.examples_dir)

    template_index: dict[str, dict[str, Any]] = {}
    for path in examples_dir.glob("breed.*.json"):
        data = load_json(path)
        template_index[data["breedId"]] = data

    for entry in manifest["candidates"]:
        candidate = load_json(candidate_dir / f"candidate.{entry['breedId']}.json")
        template = template_index[entry["templateBreedId"]]
        fixture = build_fixture(candidate, template, entry["group"])
        output_path = examples_dir / f"breed.{entry['breedId']}.json"
        save_json(output_path, fixture)
        print(f"generated {output_path.name}")


if __name__ == "__main__":
    main()
