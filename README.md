# PaperSync
A powerful web-based editor and server application for managing e-ink displays, featuring real-time layout editing, Spotify integration, and an intuitive drag-and-drop interface.

## Overview
PaperSync combines a React-based visual editor with a Python backend server to create and manage content for e-ink displays. The system allows users to design layouts visually and instantly push updates to connected e-ink displays running the PaperView client software.

### Technical Details

- Frontend: React with Ant Design components
- Backend: Flask-based Python server
- Communication: RESTful API with JSON payload
- Image Processing
  - Packs images into a 4-bit grayscale format (16 grayscales) with two pixels packed per byte
  - Analyses image to find best ajustments
    - Floyd-Steinberg / Sierra dithering for grayscale images
    - Contrast
    - Brightness
- Container: Docker with multi-stage builds

## Key Features

### Visual Layout Editor

- Drag-and-drop interface for precise element placement
- Real-time preview of display layout
- Support for text, buttons, and images
- Fine-grained control over element properties and positioning

### Smart Display Management

- JSON-based communication protocol for efficient data transfer
- Automatic image encoding
- Support for multiple display layouts
- Live updates to connected displays

### Spotify Integration

- Real-time display of currently playing tracks
- Automatic album artwork fetching and formatting
- Dynamic updates as songs change

### Flexible Deployment

- Docker support for easy deployment
- Local development environment
- Configurable server settings

## Getting Started

### Prerequisites

- Docker (for containerized deployment)
- Python 3.x (for local development)
- Node.js and npm (for frontend development)
- Spotify Developer API credentials (for music integration)


### Quick Start

Clone the repository:

```bash
git clone https://github.com/X0RA/PaperSync.git
cd PaperSync
```

#### Docker Compose
```bash
docker compose up --build
```

#### Local Development
```bash
./local-build.sh
```

### Configuration

#### Set up your Spotify API credentials:    
- Create a Spotify Developer account
- Create a new application
- Add your credentials to the environment variables (TODO: Add instructions for this and where to put them)
