#!/usr/bin/env bash

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

print_kik_version() {
  echo -e "${PURPLE}$APP_NAME CLI version $TOOL_VERSION${RESET}"
}
