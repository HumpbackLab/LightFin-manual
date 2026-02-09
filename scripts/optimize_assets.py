#!/usr/bin/env python3
import argparse
import fnmatch
import re
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN_TYP = ROOT / "main.typ"


PROFILES = {
    "lite": {"max_width": 2400, "jpeg_quality": 88},
    "balanced": {"max_width": 1920, "jpeg_quality": 82},
    "aggressive": {"max_width": 1600, "jpeg_quality": 74},
    "aggressive-plus": {
        "max_width": 1400,
        "jpeg_quality": 68,
        "force_lossy_globs": [
            "assets/inav-*.png",
            "assets/annotation_*.png",
            "assets/pcb-*.png",
            "assets/debug-probe.png",
            "assets/product-overview.png",
            "assets/elrs-config*.png",
        ],
        "custom_width": {
            "assets/product-overview.png": 1200,
            "assets/debug-probe.png": 1200,
        },
    },
    "ultra": {
        "max_width": 1200,
        "jpeg_quality": 62,
        "force_lossy_globs": [
            "assets/inav-*.png",
            "assets/annotation_*.png",
            "assets/pcb-*.png",
            "assets/debug-probe.png",
            "assets/product-overview.png",
            "assets/elrs-config*.png",
            "assets/usb-to-ttl.png",
            "assets/sh1.0-to-2.54.png",
            "assets/battery.png",
        ],
        "custom_width": {
            "assets/product-overview.png": 1000,
            "assets/debug-probe.png": 1000,
        },
    },
}


def run(cmd):
    subprocess.run(cmd, check=True)


def file_size(path):
    return path.stat().st_size if path.exists() else 0


def mib(size):
    return f"{size / 1024 / 1024:.2f} MiB"


def detect_alpha(path):
    result = subprocess.run(
        ["sips", "-g", "hasAlpha", str(path)],
        capture_output=True,
        text=True,
        check=True,
    )
    out = result.stdout.lower()
    return "hasalpha: yes" in out


def collect_referenced_assets(main_typ):
    text = main_typ.read_text(encoding="utf-8")
    pattern = re.compile(r'"(assets/[^"]+\.(?:png|jpg|jpeg|webp))"')
    refs = []
    for rel in pattern.findall(text):
        path = ROOT / rel
        if path.exists() and path.is_file():
            refs.append(rel)
    # preserve order and uniqueness
    ordered_unique = list(dict.fromkeys(refs))
    return ordered_unique


def should_force_lossy(rel, conf):
    for pattern in conf.get("force_lossy_globs", []):
        if fnmatch.fnmatch(rel, pattern):
            return True
    return False


def build_profile(profile_name, compile_pdf=True):
    conf = PROFILES[profile_name]
    max_width = conf["max_width"]
    quality = conf["jpeg_quality"]

    references = collect_referenced_assets(MAIN_TYP)
    mapping = {}

    for rel in references:
        src = ROOT / rel
        stem = src.stem
        ext = src.suffix.lower()
        alpha = detect_alpha(src) if ext == ".png" else False
        profile_max_width = conf.get("custom_width", {}).get(rel, max_width)
        force_lossy = should_force_lossy(rel, conf)
        use_lossy = force_lossy or not alpha

        if not use_lossy:
            out_rel = f"assets/{stem}.{profile_name}.png"
            out = ROOT / out_rel
            run(["sips", "-Z", str(profile_max_width), str(src), "--out", str(out)])
        else:
            out_rel = f"assets/{stem}.{profile_name}.jpg"
            out = ROOT / out_rel
            run(
                [
                    "sips",
                    "-s",
                    "format",
                    "jpeg",
                    "-s",
                    "formatOptions",
                    str(quality),
                    "-Z",
                    str(profile_max_width),
                    str(src),
                    "--out",
                    str(out),
                ]
            )

        # never keep a larger transformed file
        if file_size(out) >= file_size(src):
            out = ROOT / f"assets/{stem}.{profile_name}{ext}"
            out_rel = f"assets/{stem}.{profile_name}{ext}"
            shutil.copy2(src, out)

        mapping[rel] = out_rel

    main_text = MAIN_TYP.read_text(encoding="utf-8")
    variant_text = main_text
    for src_rel, out_rel in mapping.items():
        variant_text = variant_text.replace(f'"{src_rel}"', f'"{out_rel}"')

    variant_typ = ROOT / f"main.{profile_name}.typ"
    variant_pdf = ROOT / f"main.{profile_name}.pdf"
    variant_typ.write_text(variant_text, encoding="utf-8")

    if compile_pdf:
        run(["typst", "compile", str(variant_typ), str(variant_pdf)])

    return {
        "profile": profile_name,
        "variant_typ": variant_typ,
        "variant_pdf": variant_pdf,
        "pdf_size": file_size(variant_pdf),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--profiles",
        default="lite,balanced,aggressive",
        help="comma-separated profile names",
    )
    parser.add_argument(
        "--no-compile",
        action="store_true",
        help="generate assets and typ variants without compiling pdf",
    )
    args = parser.parse_args()

    selected = [name.strip() for name in args.profiles.split(",") if name.strip()]
    unknown = [name for name in selected if name not in PROFILES]
    if unknown:
        raise SystemExit(f"Unknown profiles: {', '.join(unknown)}")

    base_pdf = ROOT / "main.pdf"
    if not base_pdf.exists() and not args.no_compile:
        run(["typst", "compile", str(MAIN_TYP), str(base_pdf)])

    results = []
    for profile in selected:
        results.append(build_profile(profile, compile_pdf=not args.no_compile))

    print("\\nPDF size comparison")
    if base_pdf.exists():
        print(f"- main.pdf: {file_size(base_pdf)} bytes ({mib(file_size(base_pdf))})")
    for item in results:
        print(
            f"- {item['variant_pdf'].name}: {item['pdf_size']} bytes ({mib(item['pdf_size'])})"
        )


if __name__ == "__main__":
    main()
