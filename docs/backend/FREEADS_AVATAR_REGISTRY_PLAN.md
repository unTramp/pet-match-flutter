# Freeads Avatar Registry Plan

Этот документ фиксирует, как использовать внешний CSV + `webp_512`
как канонический registry для breed slug-ов и story avatars.

## Goal

Построить единый foundation слой:
- `Freeads slug`
- `breed details URL`
- `story avatar file`
- `PetWise breedId -> Freeads slug` mapping

без смешивания этого слоя с canonical scoring truth.

## Why this matters

CSV и локальный `webp_512` pack дают:
- почти полный A-Z registry по породам
- единый slug для breed pages
- единый avatar asset для compact UI

Это особенно полезно для:
- `BreedStoryAvatar`
- suggestion cards
- future catalog breadth expansion

## Important rule

`storyAvatarUrl` не должен подменять:
- `imageUrl`
- `galleryImages`

`imageUrl` и `galleryImages` остаются hero/detail media.
`storyAvatarUrl` — это compact thumbnail / story avatar media.

## Foundation artifacts

### Full registry

- [import_candidates/freeads_full_manifest.v1.json](./import_candidates/freeads_full_manifest.v1.json)

Содержит:
- `freeadsSlug`
- `freeadsBreedName`
- `breedDetailsUrl`
- `freeadsImageUrl`
- `storyAvatar.fileName`
- `storyAvatar.suggestedUploadPath`

### Current catalog mapping

- [import_candidates/freeads_slug_mapping.v1.json](./import_candidates/freeads_slug_mapping.v1.json)

Содержит mapping текущих канонических `PetWise` пород:
- `petwiseBreedId`
- `petwiseBreedName`
- `freeadsSlug`
- `breedDetailsUrl`
- `storyAvatar.fileName`
- `matchType`

## Next safe step

1. Проверить mapping текущих `26` пород
2. Подготовить upload strategy для `story avatars`
3. Только потом вводить `storyAvatarUrl` в:
   - backend OpenAPI
   - DTO/domain entities
   - result UI

## Recommended usage order

1. Registry generation
2. Mapping verification
3. Media upload
4. Backend contract extension
5. Flutter UI integration
