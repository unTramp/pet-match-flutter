# Freeads Candidates

Эта папка хранит результаты генерации `candidate.*.json` из raw snapshots
`Freeads`.

Она отделена от корневых `import_candidates`, чтобы:
- не перетирать уже существующие `pets_json` candidate files
- можно было сравнивать два ingestion source side-by-side

Текущий pilot batch:
- `maltese`
- `pug`
- `english_cocker_spaniel`
