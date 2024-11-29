#!/usr/bin/env bash

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

print_kik_version() {
  echo -e "${_PURPLE}$_APP_NAME CLI version $_TOOL_VERSION${_RESET}"
}
