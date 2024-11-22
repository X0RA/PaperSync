#!/bin/bash
set -x
# Environment variables needed
# git@github.com:X0RA/PaperSync.git
REPO_URL="https://github.com/X0RA/PaperSync.git"
if [ ! -z "$GITHUB_TOKEN" ]; then
    REPO_URL="https://${GITHUB_TOKEN}@github.com/X0RA/PaperSync.git"
fi
BRANCH="main"
SCRIPT_PATH="docker-build.sh"

# Configure git
git config --global credential.helper store
git config --global init.defaultBranch main
git config --global --add safe.directory /app/repo

# Initial clone if repo doesn't exist
if [ ! -d "/app/repo" ]; then
    echo "Repository doesn't exist. Cloning..."
    git clone "$REPO_URL" /app/repo
    cd /app/repo
    git checkout main
else
    echo "Repository exists. Checking for updates..."
    cd /app/repo || exit 1
    # Initialize git if needed
    if [ ! -d ".git" ] || ! git remote get-url origin >/dev/null 2>&1; then
        rm -rf .git  # Remove any broken git initialization
        git init
        git remote add origin "$REPO_URL"
        git fetch origin
        git checkout -b main origin/main
    fi
fi

# Function to pull latest changes and restart server
update_and_restart() {
    # Fetch latest changes without merging
    git fetch origin main
    
    # Check if there are any changes
    LOCAL=$(git rev-parse HEAD || echo "none")
    REMOTE=$(git rev-parse origin/main || echo "none")
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "Updates found, pulling changes..."
        git reset --hard origin/main
    else
        echo "No updates found, continuing with current version..."
    fi

    # Always try to run the server
    if [ -f "$SCRIPT_PATH" ]; then
        echo "Starting/Restarting server..."
        pkill -f "$SCRIPT_PATH" || true
        bash "$SCRIPT_PATH"
    else
        echo "Error: Script not found at $SCRIPT_PATH"
        echo "Current directory contents:"
        ls -la
        echo "python_server directory contents:"
        ls -la python_server/ || echo "python_server directory not found"
    fi
}

# Initial server start
update_and_restart

# Set up a periodic check for updates (every 5 minutes)
while true; do
    sleep 300
    update_and_restart
done