#!/usr/bin/env python3
"""
Simple image optimizer for Today We Ate assets.

Reads original artwork from the repository root `assets/` folder and writes
optimized web versions into `app/assets/images` for Rails Propshaft to serve.

Requires: Pillow (`python3 -m pip install --user pillow`).
"""
from pathlib import Path
from typing import Optional
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets"
DEST = ROOT / "app" / "assets" / "images"
JUMBO = DEST / "jumbotron"
LANDING = DEST / "landing"

DEST.mkdir(parents=True, exist_ok=True)
JUMBO.mkdir(parents=True, exist_ok=True)
LANDING.mkdir(parents=True, exist_ok=True)


def save_png(img: Image.Image, path: Path, *, max_width: Optional[int] = None):
    if max_width and img.width > max_width:
        ratio = max_width / img.width
        img = img.resize((max_width, int(img.height * ratio)), Image.LANCZOS)
    img.save(path, optimize=True)


def save_webp(img: Image.Image, path: Path, *, max_width: int, quality: int = 82):
    if img.width > max_width:
        ratio = max_width / img.width
        img = img.resize((max_width, int(img.height * ratio)), Image.LANCZOS)
    img.save(path, format="WEBP", quality=quality, method=6)


def process_logo(src_logo: Path):
    img = Image.open(src_logo).convert("RGBA")
    # Create two PNG sizes for crisp rendering in header and retina displays
    save_png(img, DEST / "logo.png", max_width=200)
    save_png(img, DEST / "logo@2x.png", max_width=400)
    # And a WebP variant for potential future use
    save_webp(img, DEST / "logo.webp", max_width=400, quality=86)
    # Favicons
    img_small = img.copy()
    img_small = img_small.resize((32, 32), Image.LANCZOS)
    img_small.save(DEST / "favicon-32.png", optimize=True)
    img_apple = img.copy()
    img_apple = img_apple.resize((180, 180), Image.LANCZOS)
    img_apple.save(DEST / "favicon-180.png", optimize=True)


def process_banner(src_banner: Path):
    img = Image.open(src_banner).convert("RGB")
    # Responsive WebP sizes (small/medium/large)
    save_webp(img, DEST / "banner-800.webp", max_width=800, quality=82)
    save_webp(img, DEST / "banner-1600.webp", max_width=1600, quality=82)
    save_webp(img, DEST / "banner-2400.webp", max_width=2400, quality=80)
    # A fallback JPEG for older browsers
    jpeg_path = DEST / "banner-1600.jpg"
    if img.width > 1600:
        ratio = 1600 / img.width
        img = img.resize((1600, int(img.height * ratio)), Image.LANCZOS)
    img.save(jpeg_path, format="JPEG", quality=86, optimize=True, progressive=True)


def process_banners_sheet(src_sheet: Path):
    """Split a vertical sheet of banners into separate jumbotron images.

    Expects a tall PNG with 3 equally sized banners stacked vertically.
    """
    sheet = Image.open(src_sheet).convert("RGB")
    w, h = sheet.size
    rows = 3
    slice_h = h // rows
    def trim_whitespace(img: Image.Image, thresh: int = 245) -> Image.Image:
        # Convert to grayscale and create a mask of non-white pixels, then crop to bbox
        gray = img.convert("L")
        # Anything brighter than threshold is considered background
        mask = gray.point(lambda p: 0 if p >= thresh else 255)
        bbox = mask.getbbox()
        return img.crop(bbox) if bbox else img

    for i in range(rows):
        crop = sheet.crop((0, i * slice_h, w, (i + 1) * slice_h))
        crop = trim_whitespace(crop)
        # Save high-res JPEG and WebP variants
        base = JUMBO / f"jumbo-{i+1}"
        crop.save(f"{base}.jpg", format="JPEG", quality=88, optimize=True, progressive=True)
        crop.save(f"{base}.webp", format="WEBP", quality=84, method=6)


def process_jumbotron_folder(src_dir: Path):
    def trim_whitespace(img: Image.Image, thresh: int = 245) -> Image.Image:
        gray = img.convert("L")
        mask = gray.point(lambda p: 0 if p >= thresh else 255)
        bbox = mask.getbbox()
        return img.crop(bbox) if bbox else img

    for path in sorted(src_dir.glob("*")):
        if path.suffix.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
            continue
        img = Image.open(path).convert("RGB")
        img = trim_whitespace(img)
        base = JUMBO / path.stem
        img.save(f"{base}.jpg", format="JPEG", quality=88, optimize=True, progressive=True)
        img.save(f"{base}.webp", format="WEBP", quality=84, method=6)


def process_landing_sheet(sheet_path: Path, cols: int = 2, rows: int = 3):
    """Split a grid sheet into individual landing images (landing-1..n).

    Designed for the 1024x1536 PNG shared (2 columns x 3 rows) with white gutters.
    We divide evenly, shave a small inner margin, then trim any remaining white.
    """
    def trim_whitespace(img: Image.Image, thresh: int = 245) -> Image.Image:
        gray = img.convert("L")
        mask = gray.point(lambda p: 0 if p >= thresh else 255)
        bbox = mask.getbbox()
        return img.crop(bbox) if bbox else img

    sheet = Image.open(sheet_path).convert("RGB")
    w, h = sheet.size
    cell_w, cell_h = w // cols, h // rows
    # Inner gutter to avoid the white columns/rows in the grid
    margin = max(8, int(min(cell_w, cell_h) * 0.02))

    idx = 0
    for r in range(rows):
        for c in range(cols):
            x0 = c * cell_w + margin
            y0 = r * cell_h + margin
            x1 = (c + 1) * cell_w - margin
            y1 = (r + 1) * cell_h - margin
            crop = sheet.crop((x0, y0, x1, y1))
            crop = trim_whitespace(crop)
            idx += 1
            base = LANDING / f"landing-{idx}"
            crop.save(f"{base}.jpg", format="JPEG", quality=90, optimize=True, progressive=True)
            crop.save(f"{base}.webp", format="WEBP", quality=86, method=6)


def main():
    if (SRC / "logo.png").exists():
        process_logo(SRC / "logo.png")
        print("Optimized logo -> app/assets/images/logo*.{png,webp}")
    else:
        print("No logo.png found in assets/")

    if (SRC / "banner.png").exists():
        process_banner(SRC / "banner.png")
        print("Optimized banner -> app/assets/images/banner-*.{webp,jpg}")
    else:
        print("No banner.png found in assets/")

    if (SRC / "banners.png").exists():
        process_banners_sheet(SRC / "banners.png")
        print("Split banners.png -> app/assets/images/jumbotron/jumbo-*.{jpg,webp}")

    # Optional: process individual hero images under assets/jumbotron/*
    if (SRC / "jumbotron").exists():
        process_jumbotron_folder(SRC / "jumbotron")
        print("Processed assets/jumbotron/* -> app/assets/images/jumbotron/*.{jpg,webp}")

    # Landing grid (2x3) into individual landing-N files
    candidates = [
        SRC / "landing.png",
        SRC / "landing.jpg",
        SRC / "landing-grid.png",
        SRC / "landing_grid.png",
        SRC / "landing-sheet.png",
        SRC / "banners-2.png",
    ]
    for cand in candidates:
        if cand.exists():
            process_landing_sheet(cand)
            print("Split landing sheet -> app/assets/images/landing/landing-*.{jpg,webp}")
            break
    else:
        print("No landing sheet found in assets/. Place e.g. assets/landing.png (2x3 grid) and rerun.")


if __name__ == "__main__":
    main()
