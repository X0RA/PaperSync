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
    echo -e "${RED} Error: Build failed at line $1${NC}"
    exit 1
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# Build React app
echo -e "${GREEN} Building React application...${NC}"
cd paper-studio || handle_error $LINENO
npm install --quiet || handle_error $LINENO
npm run build || handle_error $LINENO
cd ..

# Set up Python environment
echo -e "${GREEN} Setting up Python environment...${NC}"

if [ ! -d "python_env" ]; then
    echo "Creating new Python virtual environment..."
    $PYTHON_CMD -m venv python_env || handle_error $LINENO
fi

# Ensure we're using the virtual environment
VENV_PATH="$(pwd)/python_env"
source "$VENV_PATH/bin/activate" || handle_error $LINENO

# Verify we're in the virtual environment
if ! echo "$VIRTUAL_ENV" | grep -q "python_env"; then
    echo -e "${RED} Failed to activate virtual environment${NC}"
    exit 1
fi

echo -e "${GREEN} Virtual environment activated at: $VIRTUAL_ENV${NC}"

# Update pip and install requirements
echo -e "${GREEN} Installing Python dependencies...${NC}"
python -m pip install --upgrade pip || handle_error $LINENO
python -m pip install -r requirements.txt || handle_error $LINENO

# Read environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default port if SERVER_PORT is not set
SERVER_PORT=${SERVER_PORT:-4001}
echo -e "${GREEN} Using port: ${SERVER_PORT}${NC}"

# Start Gunicorn server
echo -e "${GREEN} Starting Gunicorn server on port ${SERVER_PORT}...${NC}"
gunicorn --bind "0.0.0.0:${SERVER_PORT}" --workers 4 --reload "app:app" || handle_error $LINENO

# Cleanup function
cleanup() {
    echo -e "${GREEN} Cleaning up...${NC}"
    deactivate 2>/dev/null || true
}

# Set up cleanup on script exit
trap cleanup EXIT