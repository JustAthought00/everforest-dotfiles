#!/usr/bin/python
"""Small, read-only media labels plus an explicit play/pause action."""
import html
import subprocess
import sys

def playerctl(*args):
    try:
        result = subprocess.run(['playerctl', *args], capture_output=True, text=True, timeout=2)
        return result.stdout.strip() if result.returncode == 0 else ''
    except (OSError, subprocess.TimeoutExpired):
        return ''

def selected_player():
    paused = None
    for player in playerctl('-l').splitlines():
        status = playerctl('-p', player, 'status')
        if status == 'Playing':
            return player, status
        if status == 'Paused' and paused is None:
            paused = player, status
    return paused

mode = sys.argv[1] if len(sys.argv) > 1 else 'track'
selected = selected_player()
if selected:
    player, status = selected
    if mode == 'toggle':
        playerctl('-p', player, 'play-pause')
    elif mode == 'control':
        print('  Pause' if status == 'Playing' else '  Play')
    else:
        title = playerctl('-p', player, 'metadata', 'xesam:title') or 'Media playback'
        artist = playerctl('-p', player, 'metadata', '--format', '{{artist}}')
        text = ' '.join((title + (' · ' + artist if artist else '')).split())
        text = text if len(text) <= 44 else text[:43] + '…'
        print(html.escape(text))
elif mode == 'track':
    print('No media playing')
