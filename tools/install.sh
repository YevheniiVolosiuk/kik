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

OS=$(uname -s) # Detect operating system

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
  printf '%s  ████╗  ████╗  ╔═█████═╗  ████╗  ████╗  %s\n' "$PURPLE" "$NC"
  printf '%s  ████║  ████║  ║ █████ ║  ████║  ████║  %s\n' "$PURPLE" "$NC"
  printf '%s  ████║ ████╔╝  ║ █████ ║  ████║ ████╔╝  %s\n' "$PURPLE" "$NC"
  printf '%s  ████║ ████╔╝  ║ █████ ║  ████║ ████╔╝  %s\n' "$PURPLE" "$NC"
  printf '%s  ██████╔╝      ║ █████ ║  █████╔╝       %s\n' "$PURPLE" "$NC"
  printf '%s  ██████╔╝      ║ █████ ║  █████╔╝       %s\n' "$PURPLE" "$NC"
  printf '%s  ████╔═████╗   ║ █████ ║  ████╔═████╗   %s\n' "$PURPLE" "$NC"
  printf '%s  ████╔═████╗   ║ █████ ║  ████╔═████╗   %s\n' "$PURPLE" "$NC"
  printf '%s  ████║  ████╗  ║ █████ ║  ████║  ████╗  %s\n' "$PURPLE" "$NC"
  printf '%s  ████║  ████╗  ║ █████ ║  ████║  ████╗  %s\n' "$PURPLE" "$NC"
  printf '%s  ╚═╝ ╚═╝  ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═╝  ╚═╝  %s\n' "$PURPLE" "$NC"
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
    Linux|Debian)
      if command -v apt &> /dev/null; then
       install_command="sudo apt update && sudo apt install -y"
      elif command brew -v &> /dev/null; then
       install_command="brew install"
      elif command -v pacman &> /dev/null; then
       install_command="sudo pacman -Sy --noconfirm"
      elif command -v dnf &> /dev/null; then
       install_command="sudo dnf install -y"
      else
       error "Could not determine package manager for $OS. Please install manually."
       return 1
      fi
      ;;
    Darwin)
      if ! command -v brew &> /dev/null; then
        error "Homebrew is not installed. Please install it from https://brew.sh/"
        return 1
      fi
      install_command="brew install"
      ;;
    *)
      error "Unsupported operating system: $OS. Please install manually."
      ;;
    esac

    # Attempt installation
    warn "$dep is not installed. Attempting to install..."
    if eval "$install_command $dep"; then
      success "$dep installed successfully."
    else
      error "Failed to install $dep. Please install it manually."
      return 1
    fi

  fi
}

check_gum_dependency(){
    local gum_install_docs_url="https://github.com/charmbracelet/gum?tab=readme-ov-file#installation"

    # Check if gum is installed
    if ! command -v gum &> /dev/null; then
      warn "The 'gum' tool is not installed. It's required for interactive prompts."
      warn "To install, please visit the following URL ↓"
      warn "$gum_install_docs_url"
      warn "Some features might not be available without 'gum'."
      exit 0;
    fi
}

# Check for essential dependencies
check_dependencies() {
  log "Checking dependencies..."

  check_gum_dependency
  install_dependency docker
  install_dependency bash
  install_dependency curl
  install_dependency git
  install_dependency jq

  success "All dependencies are installed."
}

delete_existing_installation() {
  if [[ -d "$kik_home_path" ]]; then
    warn "Existing installation detected at $kik_home_path."
    if rm -rf "$kik_home_path"; then
      success "Existing installation deleted successfully."
    else
      error "Failed to delete existing installation. Exiting."
      exit 1
    fi
  fi
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

  mkdir -p "$kik_home_path/config"
  mkdir -p "$kik_home_path/logs"

  success "Created necessary directories at $kik_home_path"
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

add_kik_path_to_user_shell() {
  # --- Determine the user's shell ---
  user_shell=$(basename "$SHELL")

  # --- Check if ~/.local/bin is in PATH ---
  if [[ ! ":$PATH:" =~ ":$HOME/.kik/bin:" ]]; then
    warn "~/.kik/bin is not in your PATH. Kik may not be accessible globally."

    # --- Prompt user for automatic PATH addition ---
    read -r -p "Do you want to add it to your PATH automatically? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY])
        case "$user_shell" in
          "bash" | "sh")
            echo "export PATH=\"\$HOME/.kik/bin:\$PATH\"" >> "$HOME/.bashrc"
            source "$HOME/.bashrc"
            success "Path added to ~/.bashrc. You might need to open a new terminal or run 'source ~/.bashrc'."
            ;;
          "zsh")
            echo "export PATH=\"\$HOME/.kik/bin:\$PATH\"" >> "$HOME/.zshrc"
            source "$HOME/.zshrc"
            success "Path added to ~/.zshrc. You might need to open a new terminal or run 'source ~/.zshrc'."
            ;;
          *)
            warn "Unsupported shell. Please add the following line to your shell's configuration file manually:"
            echo "export PATH=\"\$HOME/.kik/bin:\$PATH\""
            ;;
        esac
        ;;
      *)
        # --- Provide manual instructions ---
        warn "You can add it manually by running the following command:"
        case "$user_shell" in
          "bash" | "sh")
            echo "  echo 'export PATH=\"\$HOME/.kik/bin:\$PATH\"' >> ~/.bashrc"
            ;;
          "zsh")
            echo "  echo 'export PATH=\"\$HOME/.kik/bin:\$PATH\"' >> ~/.zshrc"
            ;;
          *)
            echo "  Please consult your shell's documentation on how to modify the PATH environment variable."
            ;;
        esac
        ;;
    esac
  else
    success "~/.kik/bin is already in your PATH."
  fi
}

# Make the CLI globally available by linking to /usr/local/bin
make_cli_global() {
  # --- Set the installation path to the user's .kik directory ---
  local cli_path="$HOME/.kik/kik" # Notice the 'kik' executable name at the end

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

#   backup_existing_installation
  delete_existing_installation

  # --- Clone the repository ---
  git clone -b "$branch" "$remote" "$kik_home_path"  || error "Failed to clone repository."
  get_kik_version

  prepare_directories
  create_default_config
#   install_optional_components
  make_cli_global
  add_kik_path_to_user_shell

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
