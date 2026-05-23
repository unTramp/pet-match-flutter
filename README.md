# 🐾 Pet Match AI — Flutter (Тестовое Задание)
<p align="center">
  <img 
    src="https://i.ibb.co/3D09TnY/Chat-GPT-Image-24-2026-00-26-41.png"
    width="100%"
    alt="Pet Match AI"
  />
</p>

Flutter-приложение с Android-first фокусом, реализующее полный пользовательский сценарий Pet Match AI: welcome screen, анкету, анализ совместимости, результаты, детали породы и галерею.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Clean_Architecture-000000?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/flutter_bloc-0175C2?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Cubit-02569B?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/go_router-EA4335?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/get_it-6C63FF?style=for-the-badge"/>
</p>

---

## ✨ Возможности

- Полный flow согласно ТЗ: welcome, анкета, анализ, результат, детали породы и галерея.
- Работа с реальным dev API по умолчанию.
- Mock-режим для оффлайн-демо и тестирования.
- Resume текущей пользовательской сессии.
- Состояния загрузки, ошибок и повторной попытки.
- Polling совместимости с промежуточным состоянием `Analyzing`.
- Единая дизайн-система и переиспользуемые UI-компоненты.
- Android-first подход к интерфейсу и сборке.

---

## 🚀 Запуск

Установка зависимостей:

```bash
flutter pub get
```

Запуск приложения:

```bash
flutter run
```

По умолчанию приложение запускается с реальным dev API.

Запуск с конкретным `uid` из ТЗ:

```bash
flutter run --dart-define=PET_MATCH_EXTERNAL_ID=tester-12345
```

Запуск с mock-данными:

```bash
flutter run --dart-define=USE_MOCK=true
```

Сборка APK:

```bash
flutter build apk --release
```

---

## ⚙️ Build-time флаги

| Флаг | По умолчанию | Назначение |
|---|---|---|
| `USE_MOCK` | `false` | `false` — реальный dev API, `true` — mock-данные из `assets/mock/` |
| `API_BASE_URL` | `https://app-api.dev.pet-match.app/api/v1` | Базовый URL API |
| `PET_MATCH_EXTERNAL_ID` | — | Внешний идентификатор пользователя для запуска сценария из ТЗ |

---

## 🏗 Архитектура

<p align="left">
  <img src="https://img.shields.io/badge/Clean_Architecture-000000?style=flat-square"/>
  <img src="https://img.shields.io/badge/flutter_bloc-0175C2?style=flat-square"/>
  <img src="https://img.shields.io/badge/Cubit-02569B?style=flat-square"/>
  <img src="https://img.shields.io/badge/go_router-EA4335?style=flat-square"/>
  <img src="https://img.shields.io/badge/get_it-6C63FF?style=flat-square"/>
  <img src="https://img.shields.io/badge/AppFailure-FF6B6B?style=flat-square"/>
  <img src="https://img.shields.io/badge/Design_System-6750A4?style=flat-square"/>
</p>

Проект построен по принципам Clean Architecture: `data / domain / presentation` + `core`.


```txt
lib/
├── core/            DI, сеть, cache, дизайн-токены, shared-компоненты
├── data/            DTO, mappers, sources, repositories
├── domain/          entities, contracts, use cases
└── presentation/    router, cubits, screens, widgets
```

### Ключевые практики

- State management: `flutter_bloc` + `Cubit`
- Навигация: `go_router`
- Dependency Injection: `get_it`
- Типизированная обработка ошибок через `AppFailure`
- Разделение API-моделей, domain entities и UI state
- Единая дизайн-система: `UiButton`, `UiCard`, `UiStateView`, токены
- Централизованные shared-компоненты и инфраструктура в `core`

---

## 🔄 Работа с данными

По умолчанию приложение работает с реальным dev API:

```bash
--dart-define=USE_MOCK=false
```

Mock-режим доступен для оффлайн-демо, локальной проверки и тестирования:

```bash
--dart-define=USE_MOCK=true
```

Источник данных переключается build-флагом, поэтому основной flow можно проверить как с API, так и без сети.

---

## 🧠 Compatibility Polling

Polling совместимости встроен в пользовательский сценарий анкеты.

После завершения анкеты приложение переходит в состояние `Analyzing` и запрашивает актуальное состояние сессии:

```txt
GET /session
```

Параметры polling:

- интервал: `3 с`
- общий таймаут: `30 с`
- финальное состояние автоматически переводит пользователя на экран результата
- ошибки и timeout обрабатываются через общий failure flow

---

## ✅ Качество

- Реализован полный основной flow согласно ТЗ.
- Поддержаны состояния loading / error / retry.
- Поддержан resume текущей сессии.
- Состояние `Analyzing` встроено в UX анкеты.
- Покрыты ключевые модули: router, Cubit, mappers, shared UI, use cases.
- Android-сборка подготовлена для локальной проверки и ручного демо.

Проверки:

```bash
flutter analyze
flutter test
```

---

## 🎯 Scope и компромиссы

- Реализован основной flow из ТЗ: onboarding, анкета, анализ, результат, детали породы и галерея.
- Feedback/post-result flow не добавлялся, так как он прямо исключён из задания.
- Release APK собирается стандартными Flutter-командами.
- Отдельная production-подпись APK не требуется для тестового задания.
- Mock-режим оставлен как вспомогательный сценарий для оффлайн-демо.
- Основная проверка рассчитана на работу с dev API.

---

## 📚 Документация

- [Архитектура и соответствие ТЗ](docs/architecture-and-requirements.md)
- [Чек-лист ТЗ](docs/requirements-checklist.md)
- [Дизайн-система](docs/design-system.md)
- [Пользовательский сценарий](docs/user-flow.md)
