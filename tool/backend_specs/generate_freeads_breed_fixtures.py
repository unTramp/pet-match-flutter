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
    "basset_hound": {
        "size": 3,
        "apartmentSuitability": 3,
        "exerciseNeeds": 2,
        "aloneTolerance": 3,
        "goodWithChildren": 4,
        "goodWithOtherPets": 4,
        "groomingNeeds": 1,
        "sheddingLevel": 3,
        "beginnerFriendly": 3,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 2,
        "temperamentCalm": 4,
    },
    "irish_setter": {
        "size": 4,
        "apartmentSuitability": 2,
        "exerciseNeeds": 5,
        "aloneTolerance": 2,
        "goodWithChildren": 4,
        "goodWithOtherPets": 4,
        "groomingNeeds": 3,
        "sheddingLevel": 3,
        "beginnerFriendly": 2,
        "maintenanceCost": 4,
        "noiseLevel": 2,
        "trainability": 4,
        "temperamentCalm": 3,
    },
    "coton_de_tulear": {
        "size": 1,
        "apartmentSuitability": 5,
        "exerciseNeeds": 2,
        "aloneTolerance": 2,
        "goodWithChildren": 4,
        "goodWithOtherPets": 4,
        "groomingNeeds": 5,
        "sheddingLevel": 1,
        "beginnerFriendly": 4,
        "maintenanceCost": 3,
        "noiseLevel": 2,
        "trainability": 3,
        "temperamentCalm": 4,
    },
    "english_bulldog": {
        "size": 3,
        "apartmentSuitability": 4,
        "exerciseNeeds": 1,
        "aloneTolerance": 3,
        "goodWithChildren": 3,
        "goodWithOtherPets": 3,
        "groomingNeeds": 2,
        "sheddingLevel": 2,
        "beginnerFriendly": 2,
        "maintenanceCost": 5,
        "noiseLevel": 2,
        "trainability": 2,
        "temperamentCalm": 5,
    },
    "shetland_sheepdog": {
        "size": 2,
        "apartmentSuitability": 4,
        "exerciseNeeds": 4,
        "aloneTolerance": 2,
        "goodWithChildren": 3,
        "goodWithOtherPets": 4,
        "groomingNeeds": 4,
        "sheddingLevel": 4,
        "beginnerFriendly": 3,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 5,
        "temperamentCalm": 3,
    },
    "havanese": {
        "size": 1,
        "apartmentSuitability": 5,
        "exerciseNeeds": 2,
        "aloneTolerance": 2,
        "goodWithChildren": 4,
        "goodWithOtherPets": 4,
        "groomingNeeds": 5,
        "sheddingLevel": 1,
        "beginnerFriendly": 4,
        "maintenanceCost": 3,
        "noiseLevel": 2,
        "trainability": 4,
        "temperamentCalm": 4,
    },
    "greyhound": {
        "size": 4,
        "apartmentSuitability": 4,
        "exerciseNeeds": 2,
        "aloneTolerance": 3,
        "goodWithChildren": 2,
        "goodWithOtherPets": 2,
        "groomingNeeds": 1,
        "sheddingLevel": 2,
        "beginnerFriendly": 3,
        "maintenanceCost": 4,
        "noiseLevel": 1,
        "trainability": 3,
        "temperamentCalm": 5,
    },
    "cane_corso": {
        "size": 5,
        "apartmentSuitability": 1,
        "exerciseNeeds": 4,
        "aloneTolerance": 3,
        "goodWithChildren": 2,
        "goodWithOtherPets": 2,
        "groomingNeeds": 2,
        "sheddingLevel": 2,
        "beginnerFriendly": 1,
        "maintenanceCost": 5,
        "noiseLevel": 2,
        "trainability": 4,
        "temperamentCalm": 4,
    },
    "samoyed": {
        "size": 4,
        "apartmentSuitability": 2,
        "exerciseNeeds": 4,
        "aloneTolerance": 2,
        "goodWithChildren": 4,
        "goodWithOtherPets": 4,
        "groomingNeeds": 5,
        "sheddingLevel": 5,
        "beginnerFriendly": 2,
        "maintenanceCost": 4,
        "noiseLevel": 4,
        "trainability": 4,
        "temperamentCalm": 3,
    },
    "great_dane": {
        "size": 5,
        "apartmentSuitability": 2,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 4,
        "goodWithOtherPets": 3,
        "groomingNeeds": 1,
        "sheddingLevel": 2,
        "beginnerFriendly": 2,
        "maintenanceCost": 5,
        "noiseLevel": 2,
        "trainability": 3,
        "temperamentCalm": 5,
    },
    "dalmatian": {
        "size": 3,
        "apartmentSuitability": 2,
        "exerciseNeeds": 5,
        "aloneTolerance": 2,
        "goodWithChildren": 4,
        "goodWithOtherPets": 3,
        "groomingNeeds": 1,
        "sheddingLevel": 5,
        "beginnerFriendly": 2,
        "maintenanceCost": 4,
        "noiseLevel": 3,
        "trainability": 4,
        "temperamentCalm": 2,
    },
    "newfoundland": {
        "size": 5,
        "apartmentSuitability": 1,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 5,
        "goodWithOtherPets": 4,
        "groomingNeeds": 4,
        "sheddingLevel": 5,
        "beginnerFriendly": 2,
        "maintenanceCost": 5,
        "noiseLevel": 2,
        "trainability": 4,
        "temperamentCalm": 5,
    },
    "welsh_corgi_pembroke": {
        "size": 2,
        "apartmentSuitability": 4,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 3,
        "goodWithOtherPets": 3,
        "groomingNeeds": 2,
        "sheddingLevel": 4,
        "beginnerFriendly": 3,
        "maintenanceCost": 3,
        "noiseLevel": 4,
        "trainability": 5,
        "temperamentCalm": 3,
    },
    "shiba_inu": {
        "size": 2,
        "apartmentSuitability": 4,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 2,
        "goodWithOtherPets": 2,
        "groomingNeeds": 3,
        "sheddingLevel": 4,
        "beginnerFriendly": 2,
        "maintenanceCost": 3,
        "noiseLevel": 2,
        "trainability": 2,
        "temperamentCalm": 3,
    },
    "bernese_mountain_dog": {
        "size": 5,
        "apartmentSuitability": 2,
        "exerciseNeeds": 3,
        "aloneTolerance": 3,
        "goodWithChildren": 5,
        "goodWithOtherPets": 4,
        "groomingNeeds": 5,
        "sheddingLevel": 5,
        "beginnerFriendly": 3,
        "maintenanceCost": 5,
        "noiseLevel": 2,
        "trainability": 4,
        "temperamentCalm": 4,
    },
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
    "basset_hound": {
        "isVocal": True,
        "isHighPreyDrive": True,
        "isSensitive": False,
        "isEscapeProne": True,
        "isSuitableForFirstTimeOwners": True,
    },
    "irish_setter": {
        "isVocal": False,
        "isHighPreyDrive": True,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "coton_de_tulear": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "english_bulldog": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "shetland_sheepdog": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "havanese": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "greyhound": {
        "isVocal": False,
        "isHighPreyDrive": True,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "cane_corso": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "samoyed": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "great_dane": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "dalmatian": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "newfoundland": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
    "welsh_corgi_pembroke": {
        "isVocal": True,
        "isHighPreyDrive": False,
        "isSensitive": False,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": True,
    },
    "shiba_inu": {
        "isVocal": False,
        "isHighPreyDrive": True,
        "isSensitive": False,
        "isEscapeProne": True,
        "isSuitableForFirstTimeOwners": False,
    },
    "bernese_mountain_dog": {
        "isVocal": False,
        "isHighPreyDrive": False,
        "isSensitive": True,
        "isEscapeProne": False,
        "isSuitableForFirstTimeOwners": False,
    },
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
    "basset_hound": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "irish_setter": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "coton_de_tulear": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "english_bulldog": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "shetland_sheepdog": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "havanese": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "greyhound": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "cane_corso": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "samoyed": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "great_dane": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "dalmatian": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "newfoundland": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "welsh_corgi_pembroke": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "shiba_inu": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
    "bernese_mountain_dog": {
        "confidenceScore": 0.72,
        "sourceCount": 2,
    },
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
        "basset_hound": [
            "лучше всего раскрывается в спокойном домашнем ритме с размеренными прогулками, безопасным контролем на запахе и владельцем, который не ждёт высокой уступчивости в обучении",
            "важно заранее принять более громкий hound-голос, склонность идти за запахом и то, что спокойный темп не делает породу полностью беспроблемной для компактной квартиры",
        ],
        "irish_setter": [
            "лучше всего раскрывается у активного владельца или семьи, которым нравятся длинные прогулки, работа в движении и more sporting daily rhythm, а не просто дружелюбная большая собака дома",
            "важно заранее принять более высокую нагрузку, уход за длинной шерстью и то, что мягкий family-friendly характер не делает породу по-настоящему лёгкой для новичка или долгого одиночества",
        ],
        "coton_de_tulear": [
            "лучше всего раскрывается в спокойном домашнем ритме, где собаке дают много контакта с людьми и заранее принимают регулярный уход за белой шерстью",
            "важно не путать very light shedding с отсутствием бытовых затрат: линьки мало, но груминг, внимание и мягкая социализация остаются обязательными",
        ],
        "english_bulldog": [
            "лучше всего чувствует себя в спокойном домашнем ритме без перегрева, с короткими прогулками и владельцем, готовым к заметным health-related расходам",
            "важно заранее принять, что низкая активность и мягкий характер не делают породу дешёвой или по-настоящему беспроблемной для новичка",
        ],
        "shetland_sheepdog": [
            "лучше всего раскрывается у владельца, который любит короткие регулярные занятия, чувствительный контакт и готов к более голосистому herding-профилю дома",
            "важно заранее принять линьку, регулярный уход за шерстью и то, что компактный размер не делает породу простой декоративной собакой",
        ],
        "havanese": [
            "лучше всего раскрывается в спокойном домашнем ритме, где собаке дают много контакта с людьми и не оставляют надолго в одиночестве",
            "важно заранее принять регулярный уход за шерстью и не путать very light shedding с отсутствием груминга",
        ],
        "greyhound": [
            "лучше всего раскрывается у владельца, который хочет спокойную дома, но всё же крупную собаку и готов к безопасным прогулкам с учётом prey drive",
            "важно заранее принять размер, более высокую стоимость содержания и то, что мягкий характер не всегда означает идеальный fit для маленьких детей и свободного контакта с кошками",
        ],
        "cane_corso": [
            "лучше всего чувствует себя у очень последовательного владельца, который готов к крупной guardian-породе, ранней социализации и чётким правилам дома",
            "важно заранее принять размер, стоимость содержания и то, что породе обычно нужен не просто выгул, а управляемая дисциплина и взрослое руководство",
        ],
        "samoyed": [
            "лучше всего раскрывается у активного владельца, который готов к плотной рутине, обильной линьке и регулярному уходу за густой шерстью",
            "важно заранее принять более шумный spitz-профиль, работу с самоконтролем и то, что породе обычно тяжело без занятости и включённости в жизнь семьи",
        ],
        "great_dane": [
            "лучше всего чувствует себя в просторном доме или очень продуманном большом жилье, где готовы подстраивать быт под giant breed и очень высокую стоимость содержания",
            "важно заранее учитывать размер, транспорт, суставы, мягкую социализацию и то, что спокойный характер не отменяет потребности в дисциплине и рутине",
        ],
        "dalmatian": [
            "лучше всего раскрывается у активного владельца, который любит длинные прогулки, занятия и не ждёт спокойного домашнего ритма без нагрузки",
            "важно заранее принять тяжёлую линьку, внимательность к рутине и то, что породе обычно нужно больше движения, чем ожидают по внешнему виду",
        ],
        "newfoundland": [
            "лучше всего чувствует себя в просторном доме, где готовы к очень крупному размеру, линьке и заметным бытовым расходам",
            "важно заранее учитывать температуру, транспорт, нагрузку на суставы и спокойную последовательную социализацию",
        ],
        "welsh_corgi_pembroke": [
            "лучше всего раскрывается при коротких регулярных занятиях, спокойной дисциплине и готовности к более громкому голосу дома",
            "важно учитывать herding-drive, склонность контролировать происходящее и регулярную линьку",
        ],
        "shiba_inu": [
            "лучше всего раскрывается у владельца, который спокойно относится к самостоятельности, линьке и не ожидает высокой уступчивости в обучении",
            "важно заранее работать с безопасными прогулками, самоконтролем и границами с другими животными",
        ],
        "bernese_mountain_dog": [
            "лучше всего чувствует себя в семье, готовой к большому размеру, тяжёлой линьке и регулярным спокойным прогулкам",
            "стоит заранее учитывать пространство дома, затраты на уход и мягкую последовательную социализацию",
        ],
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
    if breed_id == "basset_hound":
        return (
            "Невысокий, спокойный и очень nose-driven hound-companion, которому лучше всего подходят размеренные прогулки, "
            "домашний ритм без спешки и владелец, готовый к более громкому голосу и менее уступчивому обучению."
        )
    if breed_id == "irish_setter":
        return (
            "Крупный, очень активный и эффектный gundog-companion, которому лучше всего подходят длинные прогулки, "
            "много движения, семейный ритм с высокой вовлечённостью и владелец, готовый к более demanding sporting-профилю."
        )
    if breed_id == "coton_de_tulear":
        return (
            "Небольшой, мягкий и very low-shedding companion для квартиры, которому лучше всего подходят спокойный семейный ритм, "
            "много контакта с человеком и готовность к регулярному уходу за длинной шерстью."
        )
    if breed_id == "english_bulldog":
        return (
            "Коренастый, очень спокойный и low-energy companion, которому лучше всего подходят короткие прогулки, "
            "спокойный квартирный или домашний ритм и владелец, готовый к высоким health-related расходам."
        )
    if breed_id == "shetland_sheepdog":
        return (
            "Компактный, очень умный и заметно vocal herding-companion, которому лучше всего подходят регулярные занятия, "
            "спокойная дисциплина и владелец, готовый к линьке и чувствительному характеру."
        )
    if breed_id == "havanese":
        return (
            "Маленький, мягкий и people-oriented companion для квартиры, которому лучше всего подходят спокойный семейный ритм, "
            "много контакта с человеком и готовность к регулярному уходу за шерстью."
        )
    if breed_id == "greyhound":
        return (
            "Крупный, очень спокойный дома и surprisingly low-energy hound-companion, которому лучше всего подходят "
            "тихий ритм жизни, безопасные прогулки и владелец, готовый учитывать prey drive и крупный размер."
        )
    if breed_id == "cane_corso":
        return (
            "Очень крупный и собранный guardian-companion mastiff-типа, которому лучше всего подходят пространство, "
            "взрослое ответственное руководство и спокойная, но строгая последовательная социализация."
        )
    if breed_id == "samoyed":
        return (
            "Крупный, очень пушистый и более vocal spitz-companion, которому лучше всего подходит активный ритм жизни, "
            "много вовлечённости и готовность к тяжёлой линьке круглый год."
        )
    if breed_id == "great_dane":
        return (
            "Очень крупный, спокойный и впечатляюще размеренный companion, которому лучше всего подходит "
            "просторный дом, мягкая последовательная социализация и владелец, готовый к giant-breed быту."
        )
    if breed_id == "dalmatian":
        return (
            "Активный, athletic и заметно линяющий companion среднего размера, которому лучше всего подходит "
            "подвижный образ жизни, понятная рутина и владелец, готовый к высокой ежедневной нагрузке."
        )
    if breed_id == "newfoundland":
        return (
            "Очень крупный, мягкий и family-oriented working companion с умеренной активностью, "
            "тяжёлой линькой и очень высокой стоимостью содержания, но спокойным домашним профилем."
        )
    if breed_id == "welsh_corgi_pembroke":
        return (
            "Компактный, очень сообразительный herding-companion с умеренной активностью, "
            "заметной линькой и более громким голосом, чем ожидают от его размера."
        )
    if breed_id == "shiba_inu":
        return (
            "Компактный, чистоплотный и самостоятельный spitz-компаньон с заметной линькой, "
            "более сдержанным характером и не самым простым обучением для новичка."
        )
    if breed_id == "bernese_mountain_dog":
        return (
            "Крупный, мягкий и family-oriented working companion с умеренной активностью, "
            "тяжёлой линькой и высокой стоимостью содержания, но очень приятным семейным профилем."
        )
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
    if breed_id == "basset_hound":
        return [
            "обычно остаётся более спокойным и low-key family hound-профилем, чем многие другие охотничьи собаки",
            "часто хорошо чувствует себя в доме с детьми и другими собаками при нормальной рутине",
            "уход за шерстью обычно остаётся простым и не требует сложного груминга",
        ]
    if breed_id == "irish_setter":
        return [
            "обычно хорошо раскрывается в активной семье или у владельца, который любит длинные прогулки и насыщенный outdoor-ритм",
            "часто остаётся мягким и people-oriented sporting-companion профилем при нормальной рутине и социализации",
            "может хорошо откликаться на обучение и совместные занятия, если собаке дают достаточно движения и включённости",
        ]
    if breed_id == "coton_de_tulear":
        return [
            "обычно хорошо подходит для квартирного и семейного ритма жизни",
            "почти не линяет и часто хорошо переносится людьми, которым важен very low-shedding small-companion профиль",
            "обычно остаётся мягким, контактным и достаточно дружелюбным companion-псом для дома с детьми и другими питомцами",
        ]
    if breed_id == "english_bulldog":
        return [
            "обычно хорошо подходит для спокойного домашнего ритма и не требует высокой ежедневной активности",
            "часто остаётся очень спокойным и предсказуемым companion-профилем",
            "может хорошо вписываться в квартиру или дом, если нагрузки остаются умеренными",
        ]
    if breed_id == "shetland_sheepdog":
        return [
            "обычно очень хорошо поддается обучению и любит интеллектуальные занятия",
            "может хорошо жить в компактном формате при достаточной рутине и ментальной нагрузке",
            "часто остаётся очень внимательным и включённым companion-профилем для вовлечённого владельца",
        ]
    if breed_id == "havanese":
        return [
            "обычно хорошо подходит для квартирного и семейного ритма жизни",
            "часто остаётся мягким и обучаемым small-companion профилем",
            "почти не линяет и обычно хорошо уживается в доме с другими питомцами",
        ]
    if breed_id == "greyhound":
        return [
            "часто оказывается более спокойным и квартирно-совместимым, чем ожидают от быстрой спортивной породы",
            "уход за шерстью обычно остаётся простым и ненавязчивым",
            "может хорошо подходить для тихого домашнего ритма при нормальных прогулках и мягком обращении",
        ]
    if breed_id == "cane_corso":
        return [
            "обычно выглядит более собранным и спокойным, чем многие другие крупные активные working-породы",
            "может хорошо откликаться на обучение при уверенной последовательной работе",
            "лучше всего чувствует себя в доме с пространством и понятной структурой дня",
        ]
    if breed_id == "samoyed":
        return [
            "обычно остаётся дружелюбным и вовлечённым companion-профилем для активной семьи",
            "часто хорошо откликается на обучение и совместные занятия, если рутина стабильна",
            "может хорошо жить с детьми и в семье, где любят прогулки и постоянный контакт с собакой",
        ]
    if breed_id == "great_dane":
        return [
            "часто остаётся более спокойным giant-companion профилем, чем ожидают по размеру",
            "может хорошо вписываться в семейный ритм при достаточном пространстве и понятной рутине",
            "уход за шерстью обычно остаётся проще, чем у многих других очень крупных пород",
        ]
    if breed_id == "dalmatian":
        return [
            "обычно хорошо раскрывается у активного владельца и любит насыщенный ритм жизни",
            "часто хорошо откликается на обучение и совместные занятия",
            "может быть сильным family-companion профилем в доме, где любят движение и прогулки",
        ]
    if breed_id == "newfoundland":
        return [
            "обычно очень мягок в семейном ритме и хорошо чувствует себя рядом с детьми",
            "может быть спокойным и обучаемым giant-companion профилем",
            "лучше всего раскрывается в просторном доме и размеренном повседневном ритме",
        ]
    if breed_id == "welsh_corgi_pembroke":
        return [
            "обычно очень хорошо поддается обучению",
            "может хорошо жить и в доме, и в квартире при достаточной рутине",
            "даёт много отклика на взаимодействие и короткие интеллектуальные занятия",
        ]
    if breed_id == "shiba_inu":
        return [
            "обычно очень чистоплотен и не слишком шумный в быту",
            "подходит для более спокойного ритма активности, чем многие рабочие и sporting-породы",
            "может хорошо жить в компактном формате при уважении к его самостоятельности",
        ]
    if breed_id == "bernese_mountain_dog":
        return [
            "обычно очень хорошо подходит для семейного ритма и спокойного контакта с детьми",
            "может быть мягким и обучаемым крупным companion-псом",
            "чаще раскрывается в доме с пространством и размеренным образом жизни",
        ]
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
    if breed_id == "basset_hound":
        return [
            "спокойный темп не означает quiet profile: hound-голос, вой и работа носом могут заметно мешать в квартире или при чувствительных соседях",
            "не лучший выбор для владельца, который ждёт высокой обучаемости, прогулок без контроля на запахе и беспроблемной свободы без поводка",
        ]
    if breed_id == "irish_setter":
        return [
            "не лучший выбор для спокойной квартиры, пассивного ритма жизни и владельца, который хочет large family dog без очень высокой ежедневной нагрузки",
            "дружелюбный характер не отменяет sporting-drive: длинные прогулки, уход за шерстью и более слабая переносимость одиночества обычно требуют больше быта и дисциплины, чем у retriever-style companions",
        ]
    if breed_id == "coton_de_tulear":
        return [
            "очень низкая линька не делает породу low-maintenance: длинная шерсть всё равно требует регулярного ухода, времени и бюджета",
            "долгое одиночество и хаотичный ритм жизни обычно переносятся хуже, чем кажется по маленькому размеру и мягкому характеру",
        ]
    if breed_id == "english_bulldog":
        return [
            "не лучший выбор для жаркого климата, длинных активных прогулок и владельца, который хочет low-cost собаку без health-related забот",
            "спокойный характер не отменяет заметных ветеринарных и бытовых расходов, а обучаемость обычно не такая лёгкая, как у более eager-to-please companion-пород",
        ]
    if breed_id == "shetland_sheepdog":
        return [
            "может быть заметно более шумным, чувствительным и линяющим, чем ожидают от маленькой красивой herding-породы",
            "не лучший выбор для пассивного ритма жизни и владельца, который не хочет заниматься шерстью, рутиной и самоконтролем",
        ]
    if breed_id == "havanese":
        return [
            "не лучший выбор для владельца, который не хочет регулярный груминг и плотный контакт с собакой",
            "долгое одиночество и хаотичный ритм жизни обычно переносятся хуже, чем кажется по компактному размеру",
        ]
    if breed_id == "greyhound":
        return [
            "с кошками, маленькими животными и очень свободными прогулками лучше заранее учитывать высокий prey drive",
            "не лучший выбор для тех, кто ждёт дешёвую крупную собаку или полностью беспроблемный fit с маленькими детьми",
        ]
    if breed_id == "cane_corso":
        return [
            "не лучший выбор для новичка, маленькой квартиры и дома без ранней последовательной социализации",
            "очень крупный размер, very high cost to keep и guardian-профиль требуют серьёзной бытовой и поведенческой готовности",
        ]
    if breed_id == "samoyed":
        return [
            "тяжёлая линька, груминг и более шумный spitz-характер требуют высокой бытовой готовности заранее",
            "не лучший выбор для очень спокойной квартиры, редких прогулок и владельца, который хочет собаку с высокой самостоятельностью",
        ]
    if breed_id == "great_dane":
        return [
            "огромный размер и very high cost to keep требуют серьёзной бытовой готовности заранее",
            "не лучший выбор для маленькой квартиры, новичка без поддержки и дома, где не хотят строить быт вокруг giant breed",
        ]
    if breed_id == "dalmatian":
        return [
            "не лучший выбор для спокойного квартирного ритма без долгих прогулок, задач и регулярной активности",
            "тяжёлая линька и более возбудимый athletic-профиль требуют бытовой готовности и последовательной рутины",
        ]
    if breed_id == "newfoundland":
        return [
            "огромный размер, линька и стоимость содержания требуют высокой бытовой готовности заранее",
            "не лучший выбор для маленькой квартиры, жары и владельца, который не хочет подстраивать быт под giant breed",
        ]
    if breed_id == "welsh_corgi_pembroke":
        return [
            "может быть заметно более голосистым и линяющим, чем кажется по милому компактному виду",
            "лучше не считать его чисто декоративной породой: ему нужны правила, занятия и контроль herding-привычек",
        ]
    if breed_id == "shiba_inu":
        return [
            "не лучший выбор для новичка, который ждёт высокой уступчивости и лёгкого обучения",
            "линька, prey drive и более независимый характер требуют готовности к управлению и рутине",
        ]
    if breed_id == "bernese_mountain_dog":
        return [
            "тяжёлая линька, груминг и стоимость содержания требуют осознанной готовности заранее",
            "не лучший выбор для маленькой квартиры, жары и владельца, который не готов к очень крупной собаке",
        ]
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
