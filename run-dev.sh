#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN} Starting build process...${NC}"

# Determine Python command
get_python_cmd() {
    if command -v python3 &> /dev/null; then
        echo "python3"
    elif command -v python &> /dev/null && [[ $(python --version 2>&1) == *"Python 3"* ]]; then
        echo "python"
    else
        echo -e "${RED} Python 3 not found${NC}"
        exit 1
    fi
}

PYTHON_CMD=$(get_python_cmd)
echo -e "${GREEN} Using Python command: ${PYTHON_CMD}${NC}"

# Function for error handling
handle_error() {
    echo -e "${RED} Error: Development setup failed at line $1${NC}"
    exit 1
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# Copy .env file to paper-studio directory
echo -e "${GREEN} Copying .env file to paper-studio directory...${NC}"
if [ -f .env ]; then
    cp .env paper-studio/ || handle_error $LINENO
else
    echo -e "${RED} Warning: No .env file found${NC}"
fi

# Set up Python environment
echo -e "${GREEN} Setting up Python environment...${NC}"
if [ ! -d "python_env" ]; then
    $PYTHON_CMD -m venv python_env || handle_error $LINENO
fi

# Activate virtual environment
source "$(pwd)/python_env/bin/activate" || handle_error $LINENO

# Install Python dependencies
python -m pip install --upgrade pip || handle_error $LINENO
python -m pip install -r requirements.txt || handle_error $LINENO

# Read port from .env file with fallback to 4001
echo -e "${GREEN} Reading server port configuration...${NC}"
if [ -f .env ]; then
    SERVER_PORT=$(grep SERVER_PORT .env | cut -d '=' -f2 || echo "4001")
else
    SERVER_PORT="4001"
fi
echo -e "${GREEN} Using port: ${SERVER_PORT}${NC}"

# Create new tmux session if not already in one
if [ -z "$TMUX" ]; then
    echo -e "${GREEN} Setting up tmux development environment...${NC}"
    
    # Create new tmux session
    tmux new-session -d -s dev
    
    # First pane: Flask server
    tmux send-keys -t dev:0.0 "cd $(pwd)" C-m
    tmux send-keys -t dev:0.0 "bash" C-m
    tmux send-keys -t dev:0.0 "source python_env/bin/activate" C-m
    tmux send-keys -t dev:0.0 "flask run --host=0.0.0.0 --port=${SERVER_PORT}" C-m
    
    # Split window horizontally for React dev server
    tmux split-window -h -t dev:0
    tmux send-keys -t dev:0.1 "bash" C-m
    tmux send-keys -t dev:0.1 "cd paper-studio" C-m
    tmux send-keys -t dev:0.1 "npm install" C-m
    tmux send-keys -t dev:0.1 "npm run dev" C-m
    
    # Attach to the tmux session
    tmux attach-session -t dev
else
    echo -e "${RED} Already in a tmux session. Please run outside of tmux.${NC}"
    exit 1
fi

# Cleanup function
cleanup() {
    echo -e "${GREEN} Cleaning up...${NC}"
    deactivate 2>/dev/null || true
}

trap cleanup EXIT