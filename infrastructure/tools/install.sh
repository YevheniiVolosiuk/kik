#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Installer script for the "kik" CLI tool
# Version: 0.0.1
# Author: Yevhenii Volosiuk
# Date: 2024
# ------------------------------------------------------------------------------

set -e

# Default settings
KIK_HOME_PATH=${KIK_HOME_PATH:-$HOME/.kik}
REPO=${REPO:-YevheniiVolosiuk/kik}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-main}

# Color definitions for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
PURPLE='\033[35m'     # Purple color
RESET_COLOR='\033[0m' # No Color

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# Log file for installation process
INSTALL_LOG_FILE="$HOME/tmp/kik_install.log"

# Detect the operating system
OS=$(uname -s)

# Installer version
INSTALLER_VERSION="0.0.1"

# Function to log messages to the console and the log file
log() {
  echo -e "$1" | tee -a "$INSTALL_LOG_FILE"
}

success() {
  log "${GREEN}[✔] $1${NC}"
}

error() {
  log "${RED}[✖] $1${NC}"
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
  local dep=$1
  if command_exists "$dep"; then
    case $OS in
    Linux)
      warn "$dep is not installed. Installing..."
      sudo apt-get install -y "$dep" || error "Failed to install $dep. Exiting."
      ;;
    Darwin)
      warn "$dep is not installed. Installing..."
      brew install "$dep" || error "Failed to install $dep. Exiting."
      ;;
    *)
      error "Unsupported operating system. Exiting."
      ;;
    esac
  else
    success "$dep is already installed."
  fi
}

# Check for essential dependencies
check_dependencies() {
  log "Checking dependencies..."
  install_dependency docker
  install_dependency bash
  install_dependency curl
  install_dependency git
  success "All dependencies are installed."
}

# Create necessary directories and backup existing installation
prepare_directories() {
  BACKUP_DIR="$HOME/.kik_backup_$(date +%Y%m%d_%H%M%S)"

  if [ -d "$HOME/.kik" ]; then
    warn "Existing installation detected. Creating backup..."
    mv "$HOME/.kik" "$BACKUP_DIR" || error "Failed to create backup. Exiting."
    success "Backup created at $BACKUP_DIR."
  fi

  mkdir -p "$HOME/.kik/config"
  mkdir -p "$HOME/.kik/logs"
  success "Created necessary directories at $HOME/.kik."
}

# Create default .env and config files with optional customization
create_default_config() {
  local ENV_FILE="$HOME/.kik/config/.env"

  if [ -f "$ENV_FILE" ]; then
    warn "Configuration file already exists. Skipping creation."
  else
    echo "DOCKER_USER=$(whoami)" >"$ENV_FILE"
    echo "DOCKER_ENV=development" >>"$ENV_FILE"
    echo "DEFAULT_PORT=8080" >>"$ENV_FILE"
    success "Default .env file created."
  fi
}

# Function to prompt for optional service installation (e.g., Docker, Postgres)
install_optional_components() {
  local install_docker

  log "Do you want to install optional components? (Docker, etc.)"
  read -pr "Install Docker (y/n)? " install_docker
  if [ "$install_docker" = "y" ]; then
    install_dependency docker
  fi

  # You can extend this to prompt for other components (e.g., Postgres)
}

# Make the CLI globally available by linking to /usr/local/bin
make_cli_global() {
  local CLI_PATH="/usr/local/bin/kik"

  if [ -f "$CLI_PATH" ]; then
    warn "kik is already installed globally. Overwriting..."
    rm "$CLI_PATH"
  fi

  chmod +x kik
  ln -s "$(pwd)/kik" /usr/local/bin/kik
  success "kik CLI tool is now globally accessible."
}

# Display installation summary and logs
installation_summary() {

  show_kik_banner

  log "\n--- Installation Summary ---"
  log "Installation Log: $LOG_FILE"
  log "Backup Directory: $BACKUP_DIR"
  success "kik CLI installed successfully. Run 'kik --help' to get started."
}

# Main installation function
main() {
  log "\nStarting kik CLI installation (v$INSTALLER_VERSION)..."

  check_root
  check_dependencies
  prepare_directories
  create_default_config
  install_optional_components
  make_cli_global
  installation_summary
}

# Allow for silent installations (non-interactive)
if [ "$1" == "--silent" ]; then
  log "Running in silent mode..."
  main &>/dev/null
else
  main
fi
