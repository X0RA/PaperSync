# flask run --host=0.0.0.0
import sys
import os
import logging
from flask import Flask, send_from_directory
from routes.spotify import spotify
from routes.layout import layout

from routes.pages import pages
from routes.images import images
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
port = int(os.getenv('SERVER_PORT', 4001))

# Add react app build
app = Flask(__name__, static_folder='./paper-studio/dist')

# other routes
app.register_blueprint(spotify, url_prefix='/spotify')
app.register_blueprint(layout, url_prefix='/layout')
# esp routes
app.register_blueprint(pages, url_prefix='/pages')
app.register_blueprint(images, url_prefix='/image')

# Add a new route for the root path
@app.route('/')
def home():
    return "Up and running :smile:"

# Add a new route specifically for assets
@app.route('/assets/<path:filename>')
def serve_assets(filename):
    return send_from_directory(os.path.join(app.static_folder, 'assets'), filename)

# Serve the main app
@app.route('/create', defaults={'path': ''})
@app.route('/create/<path:path>')
def serve_react(path):
    if path and os.path.exists(os.path.join(app.static_folder, path)):
        return send_from_directory(app.static_folder, path)
    return send_from_directory(app.static_folder, 'index.html')

if __name__ == '__main__':
    try:
        app.run(host='0.0.0.0', port=port, debug=True)
    except Exception as e:
        logging.error(f"Error starting server: {str(e)}")
        sys.exit(1)