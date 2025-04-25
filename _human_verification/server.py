import os
import shutil
from flask import Flask, render_template, request, jsonify, send_from_directory

app = Flask(__name__)

VIDEO_ROOT = os.environ.get('VIDEO_ROOT', './videos')
REMOVED_DIR = "_removed_video"
VISITED_FILE = os.path.join('./_human_verification', "visited.txt")

def load_visited():
    if not os.path.exists(VISITED_FILE):
        return set()
    with open(VISITED_FILE, 'r', encoding='utf-8') as f:
        return set(line.strip() for line in f if line.strip())

def get_video_list():
    visited = load_visited()
    videos = []

    for root, dirs, files in os.walk(VIDEO_ROOT):
        rel_root = os.path.relpath(root, VIDEO_ROOT)
        if REMOVED_DIR in rel_root.split(os.sep):
            continue
        for f in files:
            if f.endswith(".mp4"):
                rel_path = os.path.join(rel_root, f)
                if rel_path in visited:
                    continue
                videos.append({
                    "path": rel_path.replace("\\", "/"),  # Windows兼容
                    "full_path": os.path.join(root, f)
                })

    return sorted(videos, key=lambda v: v["path"])

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/videos')
def list_videos():
    return jsonify(get_video_list())

@app.route('/api/move', methods=['POST'])
def move_videos():
    data = request.json
    selected = data.get('selected', [])
    current_page = data.get('currentPageVideos', [])

    for file_path in selected:
        src = os.path.join(VIDEO_ROOT, file_path)
        dst = os.path.join(VIDEO_ROOT, REMOVED_DIR, file_path)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.exists(src):
            shutil.move(src, dst)

    with open(VISITED_FILE, 'a', encoding='utf-8') as f:
        for p in current_page:
            f.write(p + '\n')

    return jsonify({"status": "success"})

@app.route('/videos/<path:filename>')
def serve_video(filename):
    return send_from_directory(VIDEO_ROOT, filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
