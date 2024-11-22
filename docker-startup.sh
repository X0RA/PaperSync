#!/bin/bash

# Repository configuration with optional GitHub token support
REPO_URL="https://github.com/X0RA/PaperSync.git"
if [ ! -z "$GITHUB_TOKEN" ]; then
    REPO_URL="https://${GITHUB_TOKEN}@github.com/X0RA/PaperSync.git"
fi
BRANCH="main"
SCRIPT_PATH="docker-build.sh"

# Set up global git configuration
git config --global credential.helper store
git config --global init.defaultBranch main
git config --global --add safe.directory /app/repo

# Initial repository setup and cloning
if [ ! -d "/app/repo/.git" ]; then
    echo "Repository doesn't exist or is invalid. Cleaning up and cloning..."
    rm -rf /app/repo
    git clone "$REPO_URL" /app/repo
    cd /app/repo
    git checkout main
else
    echo "Repository exists. Pulling latest changes..."
    cd /app/repo || exit 1
    git init
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REPO_URL"
    git fetch origin >/dev/null 2>&1
    git reset --hard origin/main
fi



# Initial run - execute script directly and wait for completion
echo "Performing initial setup and server start...."
if [ -f "$SCRIPT_PATH" ]; then
    bash "$SCRIPT_PATH"
    INITIAL_EXIT_CODE=$?
    if [ $INITIAL_EXIT_CODE -ne 0 ]; then
        echo "Initial setup failed with exit code $INITIAL_EXIT_CODE"
        exit $INITIAL_EXIT_CODE
    fi
else
    echo "Error: Script not found at $SCRIPT_PATH"
    echo "Current directory contents:"
    ls -la
    echo "python_server directory contents:"
    ls -la python_server/ || echo "python_server directory not found"
    exit 1
fi


# Update repository and restart server function
update_and_restart() {
    # Store current commit ID
    CURRENT_COMMIT=$(git rev-parse HEAD || echo "none")
    
    # Pull latest changes from GitHub
    git fetch origin main >/dev/null 2>&1
    git reset --hard origin/main > /dev/null 2>&1
    
    # Get new commit ID
    NEW_COMMIT=$(git rev-parse HEAD || echo "none")
    
    # Only restart if commits are different
    if [ "$CURRENT_COMMIT" != "$NEW_COMMIT" ]; then
        echo "Updates found, restarting server..."
        if [ -f "$SCRIPT_PATH" ]; then
            pkill -f "gunicorn" || true
            # Execute script and wait for it to complete
            bash "$SCRIPT_PATH"
            SCRIPT_EXIT_CODE=$?
            if [ $SCRIPT_EXIT_CODE -ne 0 ]; then
                echo "Script execution failed with exit code $SCRIPT_EXIT_CODE"
                exit $SCRIPT_EXIT_CODE
            fi
        else
            echo "Error: Script not found at $SCRIPT_PATH"
            echo "Current directory contents:"
            ls -la
            echo "python_server directory contents:"
            ls -la python_server/ || echo "python_server directory not found"
            exit 1
        fi
    else
        echo "No updates found, continuing with current version..."
    fi
}

# Continue with update loop
while true; do
    sleep 30
    update_and_restart
done