#!/bin/sh
set -eu

BASE_URL="${BASE_URL:-http://127.0.0.1}"
EXPECTED_TOP_BREED="${EXPECTED_TOP_BREED:-}"
WAIT_SECONDS="${WAIT_SECONDS:-60}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

need_cmd curl
need_cmd jq

echo "Waiting for $BASE_URL/health ..."
i=0
while [ "$i" -lt "$WAIT_SECONDS" ]; do
  if curl -fsS "$BASE_URL/health" >/dev/null 2>&1; then
    break
  fi
  i=$((i + 1))
  sleep 1
done

if [ "$i" -ge "$WAIT_SECONDS" ]; then
  echo "Service did not become healthy in $WAIT_SECONDS seconds" >&2
  exit 1
fi

echo "Health:"
curl -sS "$BASE_URL/health" | jq

echo "Readiness:"
curl -sS "$BASE_URL/ready" | jq

PROFILE_RESPONSE="$(mktemp)"
MATCH_RESPONSE="$(mktemp)"
STORED_RESPONSE="$(mktemp)"
trap 'rm -f "$PROFILE_RESPONSE" "$MATCH_RESPONSE" "$STORED_RESPONSE"' EXIT

curl -sS -X POST "$BASE_URL/questionnaire/profile" \
  -H "Content-Type: application/json" \
  --data @- >"$PROFILE_RESPONSE" <<'EOF'
{
  "questionnaireVersion": 1,
  "answers": [
    { "questionId": "pet_type", "selectedOptionIds": ["dog"] },
    { "questionId": "home_type", "selectedOptionIds": ["apartment"] },
    { "questionId": "daily_activity", "selectedOptionIds": ["30_60"] },
    { "questionId": "alone_time", "selectedOptionIds": ["4_8"] },
    { "questionId": "children", "selectedOptionIds": ["no"] },
    { "questionId": "other_pets", "selectedOptionIds": ["cat"] },
    { "questionId": "grooming_tolerance", "selectedOptionIds": ["minimal"] },
    { "questionId": "shedding_tolerance", "selectedOptionIds": ["hate_it"] },
    { "questionId": "preferred_size", "selectedOptionIds": ["medium"] },
    { "questionId": "experience", "selectedOptionIds": ["first_pet"] },
    { "questionId": "budget", "selectedOptionIds": ["medium"] },
    {
      "questionId": "priorities",
      "selectedOptionIds": ["apartment_friendly", "low_grooming", "quiet"]
    }
  ]
}
EOF

echo "Profile response:"
cat "$PROFILE_RESPONSE" | jq

jq -n \
  --argjson profile "$(jq '.userProfile' "$PROFILE_RESPONSE")" \
  '{
    questionnaireVersion: 1,
    userProfile: $profile
  }' | curl -sS -X POST "$BASE_URL/match/preview" \
  -H "Content-Type: application/json" \
  --data @- >"$MATCH_RESPONSE"

echo "Match response:"
cat "$MATCH_RESPONSE" | jq

TOP_BREED="$(jq -r '.topMatch.breedId' "$MATCH_RESPONSE")"
RESULT_ID="$(jq -r '.resultId' "$MATCH_RESPONSE")"

if [ -n "$EXPECTED_TOP_BREED" ] && [ "$TOP_BREED" != "$EXPECTED_TOP_BREED" ]; then
  echo "Unexpected top breed: got '$TOP_BREED', expected '$EXPECTED_TOP_BREED'" >&2
  exit 1
fi

curl -sS "$BASE_URL/matches/$RESULT_ID" >"$STORED_RESPONSE"

echo "Stored match response:"
cat "$STORED_RESPONSE" | jq

STORED_RESULT_ID="$(jq -r '.resultId' "$STORED_RESPONSE")"
if [ "$STORED_RESULT_ID" != "$RESULT_ID" ]; then
  echo "Stored result mismatch: got '$STORED_RESULT_ID', expected '$RESULT_ID'" >&2
  exit 1
fi

echo "Smoke test passed."
