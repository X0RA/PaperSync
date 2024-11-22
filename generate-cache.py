import spotipy
from spotipy.oauth2 import SpotifyOAuth
import os

# Spotify API credentials
os.environ['SPOTIPY_CLIENT_ID'] = 'c6a9ec79cc81470d88656fd7d3c84f5d'
os.environ['SPOTIPY_CLIENT_SECRET'] = '33af11922cfd4587b71540d04a21c874'
os.environ['SPOTIPY_REDIRECT_URI'] = 'http://localhost:8888/callback'

def generate_cache():
    """Generate Spotify authentication cache file."""
    print("Initializing Spotify authentication...")
    
    auth_manager = SpotifyOAuth(
        scope="user-read-playback-state user-modify-playback-state user-read-currently-playing",
        open_browser=False,
        cache_path=os.path.join(os.getcwd(), "cache")
    )
    
    # Create Spotify client and test with currently playing track
    sp = spotipy.Spotify(auth_manager=auth_manager)
    
    # Get currently playing track
    current_track = sp.current_user_playing_track()
    
    if current_track is not None:
        track_name = current_track['item']['name']
        artist_name = current_track['item']['artists'][0]['name']
        print(f"\nCurrently playing: {track_name} by {artist_name}")
    else:
        print("\nNo track currently playing")
    
    print("\nCache file generated successfully!")
    print("You can now use the Spotify integration.")

if __name__ == "__main__":
    generate_cache()
