#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Installer script for the "kik" CLI tool
# Version: 0.0.1
# Author: Yevhenii Volosiuk
# Date: 2025
# ------------------------------------------------------------------------------

set -euo pipefail

kik_home_path="${kik_home_path:-$HOME/.kik}"
repo=${repo:-YevheniiVolosiuk/kik}
remote=${remote:-https://github.com/${repo}.git}
branch=${branch:-main}

# Color definitions for output
NC='\033[0m'        # No Color
GREEN='\033[0;32m'  # Success
RED='\033[0;31m'    # Error
YELLOW='\033[0;33m' # Warning
PURPLE='\033[35m'   # Highlight

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# Log file for installation process
install_log_file="$(mktemp)"

os=$(uname -s) # Detect operating system

# Installer version
installer_version="0.0.1"
kik_version=""

# Function to log messages to the console and log file
log() {
  echo -e "$@" >> "$install_log_file"
  echo -e "$@"
}

success() {
  log "${GREEN}[✔] $1${NC}"
}

error() {
  log "${RED}[✖] $1${NC}"
  log "${YELLOW}Installation log: ${install_log_file}${NC}"
  exit 1
}

warn() {
  log "${YELLOW}[!] $1${NC}"
}

show_kik_banner() {
  printf '\n'
  printf '%s  ████╗  ████╗  ╔═█████═╗  ████╗  ████╗  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████║  ████║  ║ █████ ║  ████║  ████║  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████║ ████╔╝  ║ █████ ║  ████║ ████╔╝  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████║ ████╔╝  ║ █████ ║  ████║ ████╔╝  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ██████╔╝      ║ █████ ║  █████╔╝       %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ██████╔╝      ║ █████ ║  █████╔╝       %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████╔═████╗   ║ █████ ║  ████╔═████╗   %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████╔═████╗   ║ █████ ║  ████╔═████╗   %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████║  ████╗  ║ █████ ║  ████║  ████╗  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ████║  ████╗  ║ █████ ║  ████║  ████╗  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '%s  ╚═╝ ╚═╝  ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═╝  ╚═╝  %s\n' "$PURPLE" "$RESET_COLOR"
  printf '\n'
}

# Check if the script is run as root (if necessary for global installations)
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use sudo)."
  fi
}

# Check for dependencies and install them if needed
install_dependency() {
  local dep="$1"
  if command -v "$dep" &> /dev/null; then
    success "$dep is already installed."
  else
    case "$OS" in
    Linux)
      warn "$dep is not installed. Attempting to install..."
      if sudo apt-get update && sudo apt-get install -y "$dep"; then
        success "$dep installed successfully."
      else
        error "Failed to install $dep. Please install it manually."
      fi
      ;;
    Darwin)
      warn "$dep is not installed. Attempting to install..."
      if brew install "$dep"; then
        success "$dep installed successfully."
      else
        error "Failed to install $dep using Homebrew. Please install it manually."
      fi
      ;;
    *)
      error "Unsupported operating system. Exiting."
      ;;
    esac
  fi
}

# Check for essential dependencies
check_dependencies() {
  log "Checking dependencies..."

  install_dependency docker
  install_dependency bash
  install_dependency curl
  install_dependency git
  install_dependency jq

  success "All dependencies are installed."
}

# Backup existing installation
backup_existing_installation() {
  if [[ -d "$kik_home_path" ]]; then
    local backup_dir="$HOME/.kik_backup_$(date +%Y%m%d_%H%M%S)"
    warn "Existing installation detected at $kik_home_path. Creating backup..."
    if mv "$kik_home_path" "$backup_dir"; then
      success "Backup created at $backup_dir."
    else
      error "Failed to create backup. Exiting."
    fi
  fi
}

# Create necessary directories
prepare_directories() {
  log "Preparing directories..."
  backup_existing_installation
  mkdir -p "$kik_home_path/config"
  mkdir -p "$kik_home_path/logs"
  success "Created necessary directories at $kik_home_path."
}

# Create default .env and config files with optional customization
create_default_config() {
  local env_file="$kik_home_path/config/.env"

  if [[ -f "$env_file" ]]; then
    warn "Configuration file '$env_file' already exists. Skipping creation."
  else

    cat > "$env_file" <<EOF
DOCKER_USER=$(whoami)
DOCKER_ENV=development
DEFAULT_PORT=8080
EOF
    success "Default .env file created at $env_file"
  fi
}

# Function to prompt for optional service installation (e.g., Docker, Postgres)
install_optional_components() {
  local component

  for component in "docker"; do
    read -r -p "Install $component? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            install_dependency "$component"
            ;;
        *)
            warn "Skipping installation of $component."
            ;;
    esac
  done
}

# Make the CLI globally available by linking to /usr/local/bin
make_cli_global() {
  # --- Default installation path ---
  local default_cli_path="/usr/local/bin/kik"
  local cli_path="$default_cli_path"

  # --- Check if a custom path is provided as an argument ---
  if [[ $# -gt 0 ]]; then
    cli_path="$1"
  fi

  # --- Prompt for installation path if not provided as argument ---
  if [[ -z "$cli_path" ]]; then
    # You can use Gum for a visual prompt here
    read -r -p "Enter desired installation path (default: $default_cli_path): " cli_path
    # If the user presses Enter without typing anything, use the default.
    [[ -z "$cli_path" ]] && cli_path="$default_cli_path"
  fi

  # --- Validation: Ensure the provided path is a valid directory ---
  if [[ ! -d "$(dirname "$cli_path")" ]]; then
    error "Invalid installation path: $(dirname "$cli_path") is not a directory."
  fi

  # --- Ensure the directory exists, create it if necessary ---
  mkdir -p "$(dirname "$cli_path")" || error "Failed to create directory: $(dirname "$cli_path")"

  # --- Create the symlink ---
  if ln -s "$kik_home_path/kik.sh" "$cli_path"; then
    success "kik CLI tool installed at: $cli_path"
  else
    error "Failed to create symlink for kik. Please ensure you have write permissions."
  fi
}

get_install_version() {
  # --- Priority 1: User-specified version (using TAG) ---
  if [[ ! -z "$TAG" ]]; then
    echo "$TAG"
    return 0
  fi

  # --- Priority 2:  User-specified branch (using BRANCH) ---
  if [[ ! -z "$BRANCH" ]]; then
    echo "$BRANCH"
    return 0
  fi

  # --- Priority 3: Default to latest release based on track ---
  local release_data api_url
  if [ "$TRACK" = "beta" ]; then
    api_url="https://api.github.com/repos/$REPO/releases"
  else
    api_url="https://api.github.com/repos/$REPO/releases/latest"
  fi
  release_data=$(curl --silent -H "Accept: application/vnd.github.v3+json" "$api_url")
  echo "$release_data" | jq -r '.tag_name'
}

# KIK version from the repository
get_kik_version() {
  kik_version=$(git -C "$kik_home_path" describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
}

# Display installation summary and logs
installation_summary() {
  show_kik_banner
  log "\n--- Installation Summary ---"
  log "kik version:        $kik_version"
  log "Installation Path:  $kik_home_path"
  log "Installation Log:   $install_log_file"
  success "kik CLI installed successfully. Run 'kik --help' to get started."
}

# Main installation function
main() {
  # --- Argument parsing ---
  # Handle arguments like --silent, --prefix, etc. here

  log "Starting kik CLI installation (installer v$installer_version)..."

  # --- Check root only if needed ---
  # check_root  # Uncomment if you need root privileges

  check_dependencies

  # --- Clone the repository ---
  git clone -b "$branch" "$remote" "$kik_home_path"  || error "Failed to clone repository."
  get_kik_version

  prepare_directories
  create_default_config
  install_optional_components
  make_cli_global
  installation_summary
}

cleanup() {
  # --- Remove the temporary log file ---
  rm "$install_log_file"
}

trap cleanup EXIT

main "$@"

# Allow for silent installations (non-interactive)
# if [ "$1" == "--silent" ]; then
#   log "Running in silent mode..."
#   main &>/dev/null
# else
#   main
# fi
