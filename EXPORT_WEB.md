# Web (HTML5) Export — itch.io

## Godot setup
1. Install **Godot 4.5** with the **Web export template**.
2. Open this project → **Project → Export → Web (itch.io)**.
3. Export to `build/web/index.html`.
4. Zip the **contents** of `build/web/` so `index.html` sits at the ZIP root.

## itch.io page
- **Kind of project:** HTML
- **Viewport:** 960×540 (2× of 480×270) or Fullscreen
- **SharedArrayBuffer:** leave **off** unless you enable COOP/COEP; this preset uses `variant/thread_support=false`
- Cover: `1280×720`; screenshots: same size

## Targets
- Build size **< 50 MB**
- Cold load ideally **< 5 s** on mid desktop + decent connection
- Session length **5–8 min** (tune `data/config.json` energy drain)
