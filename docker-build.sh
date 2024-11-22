#!/bin/bash
set -e

# Initialize script directory and color codes for output
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Set up error handling
handle_error() {
    echo -e "${RED} Error: Build failed at line $1${NC}"
    exit 1
}
trap 'handle_error $LINENO' ERR

# Start build process and display directory info
echo -e "${GREEN}Starting build process...${NC}"
echo -e "${GREEN}Script directory: ${SCRIPT_DIR}${NC}"

# Build React application with suppressed output, showing only build time
echo -e "${GREEN}Building React application...${NC}"
REACT_APP_DIR="${SCRIPT_DIR}/paper-studio"

if [ ! -d "$REACT_APP_DIR" ]; then
    echo -e "\n${RED}React app directory not found at: ${REACT_APP_DIR}${NC}"
    echo "Current directory structure:"
    ls -la "${SCRIPT_DIR}"
    handle_error $LINENO
fi

cd "$REACT_APP_DIR" || handle_error $LINENO
npm install --quiet --no-progress > /dev/null 2>&1 || handle_error $LINENO

# Handle Vite configuration for Docker build
echo -e "${GREEN}Switching to Docker Vite configuration${NC}"
if [ -f "$REACT_APP_DIR/vite.config.js" ]; then
    mv "$REACT_APP_DIR/vite.config.js" "$REACT_APP_DIR/vite.config.js_local"
fi
cp "$REACT_APP_DIR/vite.config.js_docker" "$REACT_APP_DIR/vite.config.js"

BUILD_OUTPUT=$(npm run build 2>&1) || handle_error $LINENO
BUILD_TIME=$(echo "$BUILD_OUTPUT" | grep -oE '[0-9.]+m?s$')
echo -e "${GREEN}Build completed in $BUILD_TIME${NC}"

# Restore local Vite configuration
echo -e "${GREEN}Restoring local Vite configuration${NC}"
if [ -f "$REACT_APP_DIR/vite.config.js_local" ]; then
    mv "$REACT_APP_DIR/vite.config.js" "$REACT_APP_DIR/vite.config.js_docker"
    mv "$REACT_APP_DIR/vite.config.js_local" "$REACT_APP_DIR/vite.config.js"
fi

cd "$SCRIPT_DIR" || handle_error $LINENO

# Install Python dependencies
echo -e "${GREEN}Installing Python dependencies${NC}"
if [ ! -f "${SCRIPT_DIR}/requirements.txt" ]; then
    echo -e "${RED}requirements.txt not found at: ${SCRIPT_DIR}/requirements.txt${NC}"
    echo "Current directory structure:"
    ls -la "${SCRIPT_DIR}"
    handle_error $LINENO
fi

python -m pip install --upgrade pip --quiet > /dev/null 2>&1 || handle_error $LINENO
python -m pip install -r "${SCRIPT_DIR}/requirements.txt" --quiet > /dev/null 2>&1 || handle_error $LINENO

# Start server with Gunicorn
echo -e "${GREEN}Starting server with Gunicorn${NC}"
if [ ! -f "${SCRIPT_DIR}/server.py" ]; then
    echo -e "${RED}server.py not found at: ${SCRIPT_DIR}/server.py${NC}"
    echo "Current directory structure:"
    ls -la "${SCRIPT_DIR}"
    handle_error $LINENO
fi

cd "${SCRIPT_DIR}" || handle_error $LINENO
# Start Gunicorn in the background with 4 workers, binding to all interfaces on port 5000
gunicorn --workers 4 --bind 0.0.0.0:4001 server:app --reload --daemon
echo -e "${GREEN}Gunicorn server started in background${NC}"

# Add final success message and exit code
echo -e "${GREEN}Build and deployment completed successfully${NC}"
exit 0