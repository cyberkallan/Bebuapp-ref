#!/usr/bin/env python3
"""Build the Avatar Studio asset pack from Microsoft Fluent Emoji (MIT).

Sparse-checks-out only the 3D renders we use, resizes them, and writes WebP
files plus a manifest.json into:

  bebu/backend/assets/avatar-studio/   (served at /avatar-studio, seeds the catalog)
  bebu/app/assets/avatar_studio/       (bundled in the app for instant rendering)

Run from anywhere:  python3 bebu/tools/build_avatar_assets.py
Requires: git, Pillow.
"""
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BACKEND_OUT = ROOT / "backend" / "assets" / "avatar-studio"
APP_OUT = ROOT / "app" / "assets" / "avatar_studio"
REPO = "https://github.com/microsoft/fluentui-emoji.git"
WORK = Path("/tmp/fluentui-emoji-sparse")

# key, display name, fluent folder (skin-tone folders use "<Name>/<Tone>"), coins, rarity, gender
# coins 0 = free. Rarity drives the card glow: common / rare / epic / legendary.
AVATARS = [
    # ---- male (first three are free and double as the "studio off" presets)
    ("m_classic", "Classic", "Man/Medium", 0, "common", "male"),
    ("m_light", "Fair", "Man/Light", 0, "common", "male"),
    ("m_deep", "Deep", "Man/Medium-Dark", 0, "common", "male"),
    ("m_beard", "Beard", "Man beard/Medium", 120, "rare", "male"),
    ("m_curly", "Curls", "Man curly hair/Medium-Dark", 120, "rare", "male"),
    ("m_red", "Ginger", "Man red hair/Light", 120, "rare", "male"),
    ("m_tech", "Coder", "Man technologist/Medium", 180, "rare", "male"),
    ("m_singer", "Rockstar", "Man singer/Medium-Light", 220, "rare", "male"),
    ("m_detective", "Detective", "Man detective/Medium", 220, "rare", "male"),
    ("m_pilot", "Captain", "Man pilot/Medium-Dark", 260, "rare", "male"),
    ("m_tuxedo", "Black tie", "Man in tuxedo/Medium", 320, "epic", "male"),
    ("m_elf", "Elf", "Man elf/Light", 320, "epic", "male"),
    ("m_mage", "Mage", "Man mage/Medium", 360, "epic", "male"),
    ("m_vampire", "Vampire", "Man vampire/Light", 360, "epic", "male"),
    ("m_hero", "Hero", "Man superhero/Medium", 420, "epic", "male"),
    ("m_prince", "Prince", "Prince/Medium", 700, "legendary", "male"),
    ("m_astro", "Astronaut", "Man astronaut/Medium-Dark", 800, "legendary", "male"),
    ("m_ninja", "Ninja", "Ninja/Medium", 900, "legendary", "male"),
    # ---- female
    ("f_classic", "Classic", "Woman/Medium", 0, "common", "female"),
    ("f_light", "Fair", "Woman/Light", 0, "common", "female"),
    ("f_deep", "Deep", "Woman/Medium-Dark", 0, "common", "female"),
    ("f_curly", "Curls", "Woman curly hair/Medium", 120, "rare", "female"),
    ("f_red", "Ginger", "Woman red hair/Light", 120, "rare", "female"),
    ("f_blonde", "Blonde", "Woman blonde hair/Medium-Light", 120, "rare", "female"),
    ("f_scarf", "Headscarf", "Woman with headscarf/Medium", 150, "rare", "female"),
    ("f_tech", "Coder", "Woman technologist/Medium", 180, "rare", "female"),
    ("f_singer", "Popstar", "Woman singer/Medium-Light", 220, "rare", "female"),
    ("f_detective", "Detective", "Woman detective/Medium", 220, "rare", "female"),
    ("f_pilot", "Captain", "Woman pilot/Medium-Dark", 260, "rare", "female"),
    ("f_dancer", "Dancer", "Woman dancing/Medium", 300, "epic", "female"),
    ("f_veil", "Bride", "Woman with veil/Medium", 320, "epic", "female"),
    ("f_elf", "Elf", "Woman elf/Light", 320, "epic", "female"),
    ("f_fairy", "Fairy", "Woman fairy/Medium-Light", 360, "epic", "female"),
    ("f_mage", "Sorceress", "Woman mage/Medium", 360, "epic", "female"),
    ("f_hero", "Hero", "Woman superhero/Medium", 420, "epic", "female"),
    ("f_princess", "Princess", "Princess/Medium", 700, "legendary", "female"),
    ("f_astro", "Astronaut", "Woman astronaut/Medium-Dark", 800, "legendary", "female"),
    ("f_vampire", "Vampire", "Woman vampire/Light", 900, "legendary", "female"),
]

ITEMS = {
    "pet": [
        ("pet_dog", "Puppy", "Dog face", 0, "common"),
        ("pet_cat", "Kitten", "Cat face", 0, "common"),
        ("pet_hamster", "Hamster", "Hamster", 80, "rare"),
        ("pet_rabbit", "Bunny", "Rabbit face", 80, "rare"),
        ("pet_parrot", "Parrot", "Parrot", 120, "rare"),
        ("pet_fox", "Fox", "Fox", 200, "epic"),
        ("pet_panda", "Panda", "Panda", 250, "epic"),
        ("pet_koala", "Koala", "Koala", 250, "epic"),
        ("pet_tiger", "Tiger", "Tiger face", 400, "legendary"),
        ("pet_unicorn", "Unicorn", "Unicorn", 600, "legendary"),
    ],
    "vehicle": [
        ("veh_bicycle", "Bicycle", "Bicycle", 0, "common"),
        ("veh_scooter", "Scooter", "Kick scooter", 0, "common"),
        ("veh_auto", "Auto", "Auto rickshaw", 100, "rare"),
        ("veh_bike", "Motorbike", "Motorcycle", 150, "rare"),
        ("veh_car", "Hatchback", "Automobile", 200, "rare"),
        ("veh_sail", "Sailboat", "Sailboat", 250, "rare"),
        ("veh_suv", "SUV", "Sport utility vehicle", 300, "epic"),
        ("veh_boat", "Speedboat", "Motor boat", 400, "epic"),
        ("veh_race", "Supercar", "Racing car", 450, "epic"),
        ("veh_rocket", "Rocket", "Rocket", 900, "legendary"),
    ],
    "home": [
        ("home_hut", "Cabin", "Hut", 0, "common"),
        ("home_house", "House", "House", 150, "rare"),
        ("home_villa", "Villa", "House with garden", 400, "epic"),
        ("home_tower", "Penthouse", "Office building", 500, "epic"),
        ("home_jp", "Pagoda castle", "Japanese castle", 700, "legendary"),
        ("home_castle", "Castle", "Castle", 900, "legendary"),
    ],
    "sky": [
        ("sky_heli", "Helicopter", "Helicopter", 450, "epic"),
        ("sky_jet", "Private jet", "Small airplane", 500, "epic"),
        ("sky_jumbo", "Jumbo jet", "Airplane", 800, "legendary"),
        ("sky_ufo", "Flying saucer", "Flying saucer", 1000, "legendary"),
    ],
    "accessory": [
        ("acc_shades", "Shades", "Sunglasses", 60, "rare"),
        ("acc_grad", "Grad cap", "Graduation cap", 100, "rare"),
        ("acc_tophat", "Top hat", "Top hat", 120, "rare"),
        ("acc_sunhat", "Sun hat", "Womans hat", 120, "rare"),
        ("acc_headphone", "Headphones", "Headphone", 150, "rare"),
        ("acc_crown", "Crown", "Crown", 500, "legendary"),
    ],
}

# Backgrounds are gradient scenes rendered by the app; `decor` is a Fluent
# scenery emoji drawn softly behind the home.
BACKGROUNDS = [
    ("bg_midnight", "Midnight", ["#1B1033", "#3A1C71", "#0E0B14"], "Night with stars", 0, "common"),
    ("bg_sunset", "Sunset", ["#FF7E5F", "#FEB47B", "#4B1D3F"], "Sunrise over mountains", 0, "common"),
    ("bg_beach", "Beach", ["#2BC0E4", "#EAECC6", "#1C7C9C"], "Beach with umbrella", 150, "rare"),
    ("bg_island", "Island", ["#11998E", "#38EF7D", "#0B3D3A"], "Desert island", 200, "rare"),
    ("bg_city", "Neon city", ["#0F2027", "#2C5364", "#FF2E93"], "Cityscape at dusk", 350, "epic"),
    ("bg_rainbow", "Rainbow", ["#FDC830", "#F37335", "#7B2FF7"], "Rainbow", 350, "epic"),
    ("bg_galaxy", "Galaxy", ["#0B0B2B", "#4C1D95", "#DB2777"], "Milky way", 700, "legendary"),
]

SIZES = {"avatar": 512, "pet": 320, "vehicle": 384, "home": 384, "sky": 320, "accessory": 256, "bg": 384}


def fluent_path(folder: str) -> str:
    """'Man beard/Medium' -> assets/Man beard/Medium/3D/man_beard_3d_medium.png"""
    if "/" in folder:
        name, tone = folder.split("/", 1)
        slug = name.lower().replace(" ", "_").replace(":", "").replace("’", "").replace("'", "")
        return f"assets/{name}/{tone}/3D/{slug}_3d_{tone.lower()}.png"
    slug = folder.lower().replace(" ", "_").replace(":", "").replace("’", "").replace("'", "")
    return f"assets/{folder}/3D/{slug}_3d.png"


def main() -> None:
    wanted = {}
    for key, _, folder, *_ in AVATARS:
        wanted[key] = ("avatar", fluent_path(folder))
    for cat, rows in ITEMS.items():
        for key, _, folder, *_ in rows:
            wanted[key] = (cat, fluent_path(folder))
    for key, _, _, decor, *_ in BACKGROUNDS:
        wanted[key] = ("bg", fluent_path(decor))

    if not (WORK / ".git").exists():
        subprocess.run(["git", "clone", "-q", "--depth", "1", "--filter=blob:none", "--no-checkout", REPO, str(WORK)], check=True)
    subprocess.run(["git", "-C", str(WORK), "sparse-checkout", "init", "--no-cone"], check=True)
    dirs = sorted({os.path.dirname(p) for _, p in wanted.values()})
    subprocess.run(["git", "-C", str(WORK), "sparse-checkout", "set", *dirs], check=True)
    subprocess.run(["git", "-C", str(WORK), "checkout", "-q"], check=True)

    for out in (BACKEND_OUT, APP_OUT):
        out.mkdir(parents=True, exist_ok=True)

    missing = []
    for key, (cat, rel) in wanted.items():
        src = WORK / rel
        if not src.exists():
            missing.append(rel)
            continue
        size = SIZES[cat]
        im = Image.open(src).convert("RGBA")
        # Trim transparent margins so items sit tight in their cards.
        bbox = im.getbbox()
        if bbox:
            im = im.crop(bbox)
        w, h = im.size
        scale = size / max(w, h)
        im = im.resize((max(1, round(w * scale)), max(1, round(h * scale))), Image.LANCZOS)
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        canvas.paste(im, ((size - im.width) // 2, (size - im.height) // 2), im)
        for out in (BACKEND_OUT, APP_OUT):
            canvas.save(out / f"{key}.webp", "WEBP", quality=88, method=6)

    if missing:
        print("MISSING:", *missing, sep="\n  ", file=sys.stderr)
        sys.exit(1)

    items = []
    order = 0
    for key, name, _, coins, rarity, gender in AVATARS:
        order += 1
        items.append({"key": key, "category": "avatar", "name": name, "coins": coins, "rarity": rarity, "gender": gender, "sortOrder": order})
    for cat, rows in ITEMS.items():
        for key, name, _, coins, rarity in rows:
            order += 1
            items.append({"key": key, "category": cat, "name": name, "coins": coins, "rarity": rarity, "gender": "any", "sortOrder": order})
    for key, name, colors, _, coins, rarity in BACKGROUNDS:
        order += 1
        items.append({"key": key, "category": "background", "name": name, "coins": coins, "rarity": rarity, "gender": "any", "sortOrder": order, "colors": colors})

    manifest = {
        "source": "Microsoft Fluent Emoji 3D (MIT) — https://github.com/microsoft/fluentui-emoji",
        "presets": {"male": ["m_classic", "m_light", "m_deep"], "female": ["f_classic", "f_light", "f_deep"]},
        "items": items,
    }
    for out in (BACKEND_OUT, APP_OUT):
        (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    total = sum(f.stat().st_size for f in APP_OUT.glob("*.webp"))
    print(f"{len(items)} items, {len(list(APP_OUT.glob('*.webp')))} images, {total / 1e6:.1f} MB")


if __name__ == "__main__":
    main()
