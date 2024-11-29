#!/usr/bin/env bash

#  KIK Installer
#  Requires Libs:     Gum UI bash kit - https://github.com/charmbracelet/gum?tab=readme-ov-file#installation

set -euo pipefail


# Configuration Constants
readonly INSTALL_BASE_PATH=${INSTALL_BASE_PATH:-$HOME/.kik}
readonly CACHE_DIR=${CACHE_DIR:-$INSTALL_BASE_PATH/cache}
readonly CONFIG_DIR=${CONFIG_DIR:-$INSTALL_BASE_PATH/config}
readonly CONFIG_PATH=${CONFIG_PATH:-$INSTALL_BASE_PATH/config/kik.example.conf}
readonly LOG_DIR=${LOG_DIR:-$INSTALL_BASE_PATH/logs}
readonly REPOSITORY_NAME=${REPOSITORY_NAME:-YevheniiVolosiuk/kik}
readonly REPOSITORY_REMOTE_URL=${REPOSITORY_REMOTE_URL:-https://github.com/${REPOSITORY_NAME}.git}
readonly REPOSITORY_BRANCH_NAME=${REPOSITORY_BRANCH_NAME:-main}
OS="$(uname -s)"


# Colors for output
setup_colors() {
  if [ -t 1 ]; then
    BOLD=$(printf '\033[1m')
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    BLUE=$(printf '\033[34m')
    RESET=$(printf '\033[m')
  else
    BOLD=""
    RED=""
    GREEN=""
    BLUE=""
    RESET=""
  fi
}



command_exists() {
  command -v "$@" >/dev/null 2>&1
}



print_kik_welcome_banner() {
  local title_color="--foreground 111"
  local text_color="--foreground 111"
  local feature_color="--foreground 148"
  local emoji_color="--foreground 208"

  gum style --border double --margin "1" --padding "1 2" \
    "                     Welcome to KIK Deploy Tool!          " \
    "" \
    "$(gum style $title_color '                 ████╗  ████╗  ╔═█████═╗  ████╗  ████╗ ')" \
    "$(gum style $title_color '                 ████║  ████║  ║ █████ ║  ████║  ████║ ')" \
    "$(gum style $title_color '                 ████║ ████╔╝  ║ █████ ║  ████║ ████╔╝ ')" \
    "$(gum style $title_color '                 ████║ ████╔╝  ║ █████ ║  ████║ ████╔╝ ')" \
    "$(gum style $title_color '                 ██████╔╝      ║ █████ ║  █████╔╝      ')" \
    "$(gum style $title_color '                 ██████╔╝      ║ █████ ║  █████╔╝      ')" \
    "$(gum style $title_color '                 ████╔═████╗   ║ █████ ║  ████╔═████╗  ')" \
    "$(gum style $title_color '                 ████╔═████╗   ║ █████ ║  ████╔═████╗  ')" \
    "$(gum style $title_color '                 ████║  ████╗  ║ █████ ║  ████║  ████╗ ')" \
    "$(gum style $title_color '                 ████║  ████╗  ║ █████ ║  ████║  ████╗ ')" \
    "$(gum style $title_color '                 ╚═╝ ╚═╝  ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═╝  ╚═╝ ')" \
    "" \
    "$(gum style $text_color '🚀 Your ultimate solution for fast, efficient, and hassle-free deployments.')" \
    "$(gum style $text_color '🌍 Designed to streamline multi-environment deployment processes and')" \
    "$(gum style $text_color '   ensure every launch is smooth and reliable.')" \
    "$(gum style $feature_color '💡 Key Features:')" \
    "$(gum style $feature_color '   - Simplifies deployment for multiple environments (dev, staging, production).')" \
    "$(gum style $feature_color '   - Speeds up the deployment process with intuitive commands.')" \
    "$(gum style $feature_color '   - "Kicks" away deployment issues and ensures reliability.')" \
    "$(gum style $emoji_color '😄 Remember:')" \
    "$(gum style $emoji_color '   "A smooth deployment is not magic, it is KIK!"')" \
    "$(gum style $emoji_color 'Let"s KIK deploy!')"
}

check_dependency() {
  local dependency_name="$1"
  gum style --foreground 111 --padding "0 2 0 2" "Checking dependency... Done"

  # Check if gum is installed
  if command_exists "$dependency_name" ; then
    gum style --foreground 10 --padding "0 2 0 2" "\"${dependency_name}\" is already installed."
  else
    gum style --foreground 214 --padding "0 2 0 2" "\"${dependency_name}\" is not installed."
    exit 0
  fi
}

check_dependencies(){
  check_dependency gum
  check_dependency git
  check_dependency docker
  check_dependency curl
}

# Check and install dependencies
#check_and_install_dependencies() {
#  gum style --foreground 111 --padding "0 2 0 2" "Checking dependencies..."
#
#  # Check if gum is installed
#  if ! command_exists gum; then
#    gum style --foreground 214 --padding "0 2 0 2" "Gum is not installed. Installing..."
#    install_gum
#  else
#    gum style --foreground 10 --padding "0 2 0 2" "Gum is already installed."
#  fi
#
#  install_dependency git
#  install_dependency docker
#}



# Check and install gum dependency
#install_gum() {
#  case "$OS" in
#  Linux)
#    if command_exists apt; then
#      # For Debian/Ubuntu (and derivatives)
#      if command_exists curl; then
#        echo "${BLUE}Setting up Gum for Debian/Ubuntu...${RESET}"
#        # Setup repository and install Gum for Debian/Ubuntu
#        sudo mkdir -p /etc/apt/keyrings
#        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
#        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
#        sudo apt update && sudo apt install -y gum
#      else
#        echo "${RED}curl is required for this installation method. Please install it first.${RESET}"
#        exit 1
#      fi
#    elif command_exists yum; then
#      # For Fedora/CentOS/RHEL (older) using YUM
#      echo "${BLUE}Setting up Gum for Fedora/CentOS/RHEL...${RESET}"
#      echo '[charm]
#        name=Charm
#        baseurl=https://repo.charm.sh/yum/
#        enabled=1
#        gpgcheck=1
#        gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
#      sudo rpm --import https://repo.charm.sh/yum/gpg.key
#      sudo yum install -y gum
#    elif command_exists dnf; then
#      # For Fedora/RHEL (newer) using DNF
#      echo "${BLUE}Setting up Gum for Fedora/RHEL...${RESET}"
#      echo '[charm]
#        name=Charm
#        baseurl=https://repo.charm.sh/yum/
#        enabled=1
#        gpgcheck=1
#        gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
#      sudo rpm --import https://repo.charm.sh/yum/gpg.key
#      sudo dnf install -y gum
#    elif command_exists zypper; then
#      # For openSUSE using Zypper
#      echo "${BLUE}Setting up Gum for openSUSE...${RESET}"
#      echo '[charm]
#        name=Charm
#        baseurl=https://repo.charm.sh/yum/
#        enabled=1
#        gpgcheck=1
#        gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/zypp/repos.d/charm.repo
#      sudo zypper refresh
#      sudo zypper install -y gum
#    else
#      echo "${RED}Unsupported Linux package manager. Please install Gum manually.${RESET}"
#      exit 1
#    fi
#    ;;
#  Darwin)
#    if command_exists brew; then
#      # For macOS using Homebrew
#      echo "${BLUE}Installing Gum via Homebrew...${RESET}"
#      brew install gum
#    else
#      echo "${RED}Homebrew is not installed. Please install it first.${RESET}"
#      exit 1
#    fi
#    ;;
#  *)
#    echo "${RED}Unsupported operating system. Please install Gum manually.${RESET}"
#    exit 1
#    ;;
#  esac
#}
#
#install_dependency() {
#  local dep=$1
#  if command_exists "$dep"; then
#    case $OS in
#    Linux)
#      warn "$dep is not installed. Installing..."
#      sudo apt-get install -y "$dep" || error "Failed to install $dep. Exiting."
#      ;;
#    Darwin)
#      warn "$dep is not installed. Installing..."
#      brew install "$dep" || error "Failed to install $dep. Exiting."
#      ;;
#    *)
#      error "Unsupported operating system. Exiting."
#      ;;
#    esac
#  else
#    success "$dep is already installed."
#  fi
#}

#install_kik() {
#
#}

print_summary() {
  local kik_info
  local gum_info
  local install_path
  local table_output
  local styled_gum_title
  local styled_gum_version
  local styled_kik_title
  local styled_kik_version
  local styled_install_path_title
  local styled_summary_title

  # Installation Path
  styled_install_path_title=$(gum style --foreground 34 --padding "1 0 0 2" "KIK Installation Path")
  install_path="${styled_install_path_title} | ${INSTALL_BASE_PATH}"

  # Check if `kik` command exists
  if command_exists kik; then
    local kik_version
    kik_version=$(kik --version | tail -n +2)
    styled_kik_title=$(gum style --foreground 34 "KIK Version")
    styled_kik_version=$(gum style "$kik_version")
    kik_info="${styled_kik_title} | ${kik_version} | Installed"
  else
    kik_info="${kik_version} | N/A | Not Found"
  fi

  # Check if `gum` command exists
  if command_exists gum; then
    local gum_version
    gum_version=$(gum --version | awk '{print $3}')
    styled_gum_title=$(gum style --foreground 34 "Gum Version")
    styled_gum_version=$(gum style "$gum_version")
    gum_info="${styled_gum_title} | ${styled_gum_version} | Installed"
  else
    gum_info="${styled_gum_title} | N/A | Not Found"
  fi

  styled_summary_title=$(gum style --foreground 111 --padding "0 2" "Summary:")
  # Combine all information into a single table
  table_output="${styled_summary_title}
  ${gum_info}
  ${kik_info}
  ${install_path}"

  # Display the table using gum style
  gum style --border normal --align left --width 50 --margin "1 2" --padding "1 2" \
    --border-foreground 34 \
    "$table_output"
}

print_success () {
    gum style \
    --foreground 15 --background 2 --border-foreground 34 --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    'Installation completed successfully!'
}

# Start Installation Workflow
setup_kik_installation() {
  # Final summary
  print_summary

  # Final confirmation
  print_success

}



# Main Execution
main() {
  gum spin --spinner dot --show-output --title "Preparing instaletion..." -- sleep 2

  #Colors for install.sh use
  setup_colors

  # Welcome banner
  print_kik_welcome_banner

  # Check and install Gum
  check_dependencies

  setup_kik_installation
  # Installation Choice
  #    action=$(gum choose "Install" "Exit")
  #
  #    case "${action}" in
  #        "Install")
  #            setup_kik_installation
  #            ;;
  #        "Exit")
  #            gum style --foreground 1 "Exiting installer"
  #            exit 0
  #            ;;
  #    esac
}

# Run the main function
main "$@"
