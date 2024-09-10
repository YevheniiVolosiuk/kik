#!/usr/bin/env bash

set -e

# ========================================
# Docker Command Configuration
# ========================================
# Set up the command for Docker Compose with a default value
export COMPOSE_CMD="${COMPOSE_CMD:-"docker compose"}"

# ========================================
# User and Group Information
# ========================================
# Export the current user and group ID for deployment tasks
export KIK_USER_ID="${KIK_USER_ID:-$(id -u)}"
export KIK_GROUP_ID="${KIK_GROUP_ID:-$(id -g)}"

# ========================================
# Environment Configuration
# ========================================
# Deployment environment (e.g., dev, prod, stage)
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Application-specific settings
APP_NAME="KIK_APP"  # Name of the application being deployed
APP_VERSION="${APP_VERSION:-'v0.0.1'}"  # Version of the application being deployed

# Path to the environment-specific configuration file
TEMPLATES_DIR="$KIK_ROOT_DIR/templates"
log_debug "$TEMPLATES_DIR"
# Log file for capturing deployment output
LOG_FILE="/var/log/$APP_NAME-deploy.log"

# ========================================
# Remote Deployment Settings
# ========================================
# Remote server hostname or IP address
REMOTE_HOST="192.168.1.10"

# Path to the SSH private key for remote access
SSH_KEY="$HOME/.ssh/deploy_key"

# ========================================
# Backup and Rollback Settings
# ========================================
# Directory where backups will be stored
BACKUP_DIR="/backups/$APP_NAME"

# Whether to enable rollback in case of deployment failure
ROLLBACK_ENABLED=true

# ========================================
# Deployment Configuration
# ========================================
# Directory for deployment
DEPLOY_DIR="/var/www/$APP_NAME"

# Type of deployment (e.g., full, incremental, hotfix)
DEPLOYMENT_TYPE="full"

# Timeout value in seconds for operations
TIMEOUT=30

# Number of retries for failed operations
RETRY_LIMIT=3

# ========================================
# Package Manager and Database Settings
# ========================================
# Package manager to use (e.g., apt, yum)
PACKAGE_MANAGER="apt"

# Database connection details
DB_CONNECTION_STRING="user:password@tcp(localhost:3306)/mydatabase"

# ========================================
# Notification Settings
# ========================================
# Email address for deployment notifications
EMAIL_NOTIFICATION="devops@example.com"

# ========================================
# Debug Configuration
# ========================================
# Set to true to enable debug mode
DEBUG_MODE=false
