#!/usr/bin/env bash

# =========================
# Deploy Notify Script
# =========================
# Notifies deployment events via webhook or local log.
# Compatible: macOS & Linux
# Dependencies: curl, git (optional)
# Author: Ali Tanwir
# =========================

# ---- config ----
SCRIPT_WEBHOOK_URL=""  # Set to your webhook endpoint, or leave empty to log locally
WEBHOOK_URL="${WEBHOOK_URL:-$SCRIPT_WEBHOOK_URL}"
LOG_FILE="./deploy_notify.log"

TARGETS=("Backend" "Frontend")

# ---- select_targets ----
select_targets() {
  local selected=()
  local choices=()
  local i=1

  echo "Select deployment targets (use space to select, enter to confirm):"
  for t in "${TARGETS[@]}"; do
    choices+=("$i) $t")
    ((i++))
  done

  # macOS/BSD read workaround
  if [[ "$OSTYPE" == "darwin"* ]]; then
    read_cmd="gread -p"
  else
    read_cmd="read -p"
  fi

  # Interactive menu
  while true; do
    for idx in "${!choices[@]}"; do
      if [[ " ${selected[*]} " == *" $((idx+1)) "* ]]; then
        echo " [x] ${choices[$idx]}"
      else
        echo " [ ] ${choices[$idx]}"
      fi
    done
    echo "Enter numbers separated by space (e.g. 1 3), or press enter to finish:"
    read -r -a input
    if [[ ${#input[@]} -eq 0 ]]; then
      break
    fi
    selected=()
    for num in "${input[@]}"; do
      if [[ $num =~ ^[0-9]+$ ]] && (( num >= 1 && num <= ${#choices[@]} )); then
        selected+=("$num")
      fi
    done
    clear
  done

  # Map numbers to target names
  SELECTED_TARGETS=()
  for idx in "${selected[@]}"; do
    SELECTED_TARGETS+=("${TARGETS[$((idx-1))]}")
  done

  if [[ ${#SELECTED_TARGETS[@]} -eq 0 ]]; then
    echo "No targets selected. Exiting."
    exit 0
  fi

  echo "Selected targets: ${SELECTED_TARGETS[*]}"
  echo -n "Proceed? [y/N]: "
  read -r confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
}

# ---- get_git_info ----
get_git_info() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null)
  else
    GIT_BRANCH=""
    GIT_COMMIT=""
  fi
}

# ---- build_payload ----
build_payload() {
  local targets_json
  targets_json=$(printf '"%s",' "${SELECTED_TARGETS[@]}")
  targets_json="[${targets_json%,}]"

  PAYLOAD=$(cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "user": "$USER",
  "targets": $targets_json,
  "git_branch": "${GIT_BRANCH:-null}",
  "git_commit": "${GIT_COMMIT:-null}"
}
EOF
)
}

# ---- send_notification ----
send_notification() {
  if [[ -n "$WEBHOOK_URL" ]]; then
    http_code=$(curl -s -o /tmp/deploy_notify_resp -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL")
    if [[ "$http_code" =~ ^2|^3 ]]; then
      echo "Notification sent successfully."
    else
      echo "Failed to send notification (HTTP $http_code). Logging locally."
      echo "$PAYLOAD" >> "$LOG_FILE"
    fi
    rm -f /tmp/deploy_notify_resp
  else
    echo "$PAYLOAD" >> "$LOG_FILE"
    echo "Notification written to $LOG_FILE"
  fi
}

# ---- main ----
main() {
  select_targets
  get_git_info
  build_payload
  send_notification
}

main "$@"