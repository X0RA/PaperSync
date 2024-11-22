# PaperSync

A Python server application that manages and transmits JSON-encoded display elements to e-ink displays running PaperView.

## Overview

PaperSync serves as the backend server component for e-ink display systems. It processes and sends formatted data that can be rendered on e-ink displays running the PaperView client software.

## Features
- JSON-based communication protocol
- Simple server-client architecture
- Lightweight data transmission
- Image (and icon), text, and button elements
- Encodes images to eink display format
- Has spotify api integration for album art and currently playing song

## Prerequisites

- Python 3.x
- Network connectivity between server and e-ink display

## Installation / Usage

```bash
git clone https://github.com/yourusername/PaperSync.git
cd PaperSync
```

### Docker

```bash
docker compose up --build
```

### Local

```bash
./local-build.sh
```

Will be now available at http://localhost:5000


## Configuration

Will need to set up a spotify api key

## Contributing

Feel free to open issues or submit pull requests.