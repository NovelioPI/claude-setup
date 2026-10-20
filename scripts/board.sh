#!/bin/bash
# The GitHub Projects board that tracks features across repos.
# usage: board.sh setup | add <issue-url> | move <issue-url> <status>
# Exits 1 with a message on any failure, so a card never drifts silently.
set -uo pipefail

TITLE=${BOARD_TITLE:-Work}
STATUSES="Backlog Planning Ready Building Verifying Blocked Done"

fail() { echo "board.sh: $1" >&2; exit 1; }

command -v gh >/dev/null 2>&1 || fail "gh is missing"
command -v jq >/dev/null 2>&1 || fail "jq is missing"
gh auth status 2>&1 | grep -q "'project'" || fail "gh token lacks the project scope; run: gh auth refresh -s project"

project_number() {
  gh project list --owner @me --format json --limit 100 \
    | jq -r --arg t "$TITLE" '.projects[] | select(.title == $t) | .number' | head -1
}

number=$(project_number)

setup() {
  if [ -z "$number" ]; then
    gh project create --owner @me --title "$TITLE" >/dev/null || fail "cannot create project $TITLE"
    number=$(project_number)
  fi
  local field
  field=$(gh project field-list "$number" --owner @me --format json \
    | jq -r '.fields[] | select(.name == "Status") | .id')
  [ -n "$field" ] || fail "project $TITLE has no Status field"
  # Reason: GitHub replaces the whole option list, so every status is sent each time.
  printf '%s\n' $STATUSES | jq -R '{name: ., color: "GRAY", description: ""}' | jq -s \
    --arg f "$field" '{
      query: "mutation($f: ID!, $o: [ProjectV2SingleSelectFieldOptionInput!]) { updateProjectV2Field(input: {fieldId: $f, singleSelectOptions: $o}) { clientMutationId } }",
      variables: {f: $f, o: .}}' \
    | gh api graphql --input - >/dev/null || fail "cannot set Status options"
  echo "Project $TITLE (#$number): $STATUSES"
}

move() {
  local url=$1 status=$2
  case " $STATUSES " in *" $status "*) ;; *) fail "unknown status $status; use one of: $STATUSES" ;; esac
  gh project item-edit "$number" --owner @me --url "$url" --field Status --value "$status" >/dev/null \
    || fail "cannot move $url to $status"
  echo "$url -> $status"
}

case "${1:-}" in
  setup) setup ;;
  add)
    [ -n "$number" ] || fail "no project titled $TITLE; run: board.sh setup"
    [ -n "${2:-}" ] || fail "usage: board.sh add <issue-url>"
    gh project item-add "$number" --owner @me --url "$2" >/dev/null || fail "cannot add $2"
    move "$2" Backlog ;;
  move)
    [ -n "$number" ] || fail "no project titled $TITLE; run: board.sh setup"
    [ $# -eq 3 ] || fail "usage: board.sh move <issue-url> <status>"
    move "$2" "$3" ;;
  *) fail "usage: board.sh setup | add <issue-url> | move <issue-url> <status>" ;;
esac
