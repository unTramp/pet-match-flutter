# Pet Match - Flutter

Flutter-приложение с Android-first фокусом, реализующее полный пользовательский сценарий Pet Match AI: Welcome, анкета, результаты совместимости, детали породы и галерея.

## Запуск

```bash
flutter pub get
flutter run
```

Для запуска с реальным API:

```bash
flutter run --dart-define=USE_MOCK=false
```

Сборка APK:

```bash
flutter build apk --release
```

## Build-time флаги

| Флаг | По умолчанию | Назначение |
|---|---|---|
| `USE_MOCK` | `true` | `true` - данные из `assets/mock/`, `false` - реальный dev API |
| `API_BASE_URL` | `https://app-api.dev.pet-match.app/api/v1` | Базовый URL API |
| `MOCK_FAIL_RATE` | `0` | Вероятность сетевой ошибки в mock-режиме |

## Архитектура

Проект построен по Clean Architecture: `data / domain / presentation` + `core`.

```
lib/
├── core/            DI, сеть, cache, дизайн-токены, shared-компоненты
├── data/            DTO, mappers, sources, repositories
├── domain/          entities, contracts, use cases
└── presentation/    router, cubits, screens, widgets
```

Ключевые практики:
- State management: `flutter_bloc` (Cubit).
- Навигация: `go_router`.
- DI: `get_it`.
- Типизированная обработка ошибок (`AppFailure`).
- Единая дизайн-система (`UiButton`, `UiCard`, `UiStateView`, токены).

## Качество

- Реализован полный flow согласно ТЗ.
- Поддержаны сценарии загрузки, ошибок и retry.
- Поддержан resume текущей сессии.
- Покрыты ключевые модули (роутер, Cubit, мапперы, shared UI, use-cases).

Проверки:

```bash
flutter analyze
flutter test
```

## Документация

- Архитектура и соответствие ТЗ: [docs/АРХИТЕКТУРА_И_СООТВЕТСТВИЕ_ТЗ.md](docs/АРХИТЕКТУРА_И_СООТВЕТСТВИЕ_ТЗ.md)
- Чек-лист ТЗ: [docs/tz-compliance.md](docs/tz-compliance.md)
- Дизайн-система: [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)

## Скриншоты

<table>
  <tr>
    <td align="center">
      <img src="docs/screenshots/welcome.png" alt="Welcome" width="180"><br>
      Welcome
    </td>
    <td align="center">
      <img src="docs/screenshots/intro-how-it-works.png" alt="Как это работает" width="180"><br>
      Как это работает
    </td>
    <td align="center">
      <img src="docs/screenshots/question-single.png" alt="Анкета: одиночный выбор" width="180"><br>
      Анкета: одиночный выбор
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="docs/screenshots/question-multi-selected.png" alt="Анкета: множественный выбор" width="180"><br>
      Анкета: множественный выбор
    </td>
    <td align="center">
      <img src="docs/screenshots/result-main.png" alt="Результат" width="180"><br>
      Результат
    </td>
    <td align="center">
      <img src="docs/screenshots/result-details.png" alt="Факторы совпадения" width="180"><br>
      Факторы совпадения
    </td>
  </tr>
</table>
