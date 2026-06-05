#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


PLUGIN_NAME = "Freeads HTML capture"
CHALLENGE_TITLES = ("Just a moment", "Checking your browser")


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def osascript(script: str, *, ignore_errors: bool = False) -> str:
    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
        check=not ignore_errors,
    )
    if ignore_errors and result.returncode != 0:
        return ""
    return result.stdout.strip()


def run_osascript(script: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
        check=False,
    )


def safari_open(url: str) -> None:
    script = f'''
    tell application "Safari"
      activate
      if (count of windows) is 0 then
        make new document with properties {{URL:"{url}"}}
      else
        tell front window
          set URL of current tab to "{url}"
        end tell
      end if
    end tell
    '''
    osascript(script)


def safari_title() -> str:
    return osascript(
        '''
        tell application "Safari"
          if (count of windows) is 0 then return ""
          return name of current tab of front window
        end tell
        ''',
        ignore_errors=True,
    )


def safari_url() -> str:
    return osascript(
        '''
        tell application "Safari"
          if (count of windows) is 0 then return ""
          return URL of current tab of front window
        end tell
        ''',
        ignore_errors=True,
    )


def safari_html() -> str:
    return osascript(
        '''
        tell application "Safari"
          if (count of windows) is 0 then return ""
          return do JavaScript "document.documentElement.outerHTML" in current tab of front window
        end tell
        ''',
        ignore_errors=True,
    )


def safari_can_run_javascript() -> bool:
    result = run_osascript(
        '''
        tell application "Safari"
          if (count of windows) is 0 then return "ok"
          return do JavaScript "document.readyState" in current tab of front window
        end tell
        ''',
    )
    if result.returncode == 0:
        return True

    stderr = (result.stderr or "") + (result.stdout or "")
    return "Allow JavaScript from Apple Events" not in stderr


def is_challenge(title: str, html: str) -> bool:
    return any(marker.lower() in title.lower() for marker in CHALLENGE_TITLES) or (
        "Enable JavaScript and cookies to continue" in html
        or "challenge-platform" in html
    )


def looks_like_breed_page(html: str) -> bool:
    return "Facts &amp; Traits | Freeads" in html and "Characteristics" in html


def normalize_text(value: str) -> str:
    return "".join(char.lower() if char.isalnum() else " " for char in value)


def looks_like_expected_breed(title: str, html: str, current_url: str, expected_url: str, expected_name: str) -> bool:
    if not current_url or expected_url.rstrip("/") not in current_url.rstrip("/"):
        return False

    normalized_name = normalize_text(expected_name)
    normalized_title = normalize_text(title)
    normalized_html = normalize_text(html[:4000])

    tokens = [token for token in normalized_name.split() if token]
    if not tokens:
        return True

    title_hits = sum(token in normalized_title for token in tokens)
    html_hits = sum(token in normalized_html for token in tokens)
    return title_hits >= max(1, len(tokens) - 1) or html_hits >= max(1, len(tokens) - 1)


def wait_for_page(auto_wait_seconds: int, expected_url: str, expected_name: str) -> tuple[str, str, str]:
    deadline = time.time() + auto_wait_seconds
    last_title = ""
    last_html = ""
    last_url = ""

    while time.time() < deadline:
        last_title = safari_title()
        last_url = safari_url()
        last_html = safari_html()
        if (
            last_html
            and not is_challenge(last_title, last_html)
            and looks_like_breed_page(last_html)
            and looks_like_expected_breed(last_title, last_html, last_url, expected_url, expected_name)
        ):
            return last_title, last_html, last_url
        time.sleep(2)

    return last_title, last_html, last_url


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Capture Freeads breed pages via a normal Safari browser session.",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_phase1_manifest.v1.json"),
        help="Freeads manifest JSON.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("docs/backend/import_candidates/freeads_html"),
        help="Directory for saved HTML snapshots.",
    )
    parser.add_argument(
        "--breed-id",
        action="append",
        dest="breed_ids",
        help="Specific breedId to capture. Can be repeated.",
    )
    parser.add_argument(
        "--pause-seconds",
        type=int,
        default=90,
        help="Pause between breeds to reduce rate-limit risk.",
    )
    parser.add_argument(
        "--auto-wait-seconds",
        type=int,
        default=20,
        help="How long to auto-wait for a breed page before asking the user to confirm manually.",
    )
    return parser.parse_args()


def manifest_entries(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    entries = manifest.get("candidates")
    if isinstance(entries, list):
        return entries

    entries = manifest.get("breeds")
    if isinstance(entries, list):
        return entries

    raise KeyError("Manifest must contain a 'candidates' or 'breeds' array.")


def select_entries(manifest: dict[str, Any], breed_ids: list[str] | None) -> list[dict[str, Any]]:
    entries = manifest_entries(manifest)
    if not breed_ids:
        return entries
    wanted = set(breed_ids)
    return [entry for entry in entries if entry["breedId"] in wanted]


def main() -> None:
    if sys.platform != "darwin":
        raise SystemExit(f"{PLUGIN_NAME} currently supports macOS Safari only.")

    args = parse_args()
    manifest = load_json(args.manifest)
    entries = select_entries(manifest, args.breed_ids)
    if not entries:
        raise SystemExit("No matching breeds found in manifest.")

    print("Freeads browser capture starting.")
    print("Safari will open. If Cloudflare appears, wait or solve it, then press Enter here.")
    print("After a successful page load, HTML will be saved automatically.")

    if not safari_can_run_javascript():
        raise SystemExit(
            "Safari blocks DOM capture. Enable 'Allow JavaScript from Apple Events' in Safari Settings -> Developer, then run the collector again.",
        )

    for index, entry in enumerate(entries, start=1):
        breed_id = entry["breedId"]
        url = entry["breedDetailsUrl"]
        breed_name = entry["freeadsBreedName"]
        output_path = args.output_dir / f"freeads.{entry['freeadsSlug']}.html"
        print(f"\n[{index}/{len(entries)}] Opening {breed_id}: {url}")
        safari_open(url)
        title, html, current_url = wait_for_page(args.auto_wait_seconds, url, breed_name)

        if (
            not html
            or is_challenge(title, html)
            or not looks_like_breed_page(html)
            or not looks_like_expected_breed(title, html, current_url, url, breed_name)
        ):
            input(
                "Page is not ready yet. Finish the browser check / wait for breed facts to appear, then press Enter...",
            )
            title = safari_title()
            current_url = safari_url()
            html = safari_html()

        if not html or not looks_like_expected_breed(title, html, current_url, url, breed_name):
            print(f"Skipped {breed_id}: could not read page HTML.")
            continue

        save_text(output_path, html)
        print(f"Saved HTML for {breed_id} -> {output_path}")

        if index < len(entries):
            print(f"Sleeping {args.pause_seconds}s before the next breed...")
            time.sleep(args.pause_seconds)


if __name__ == "__main__":
    main()
