from __future__ import annotations

import argparse
import fnmatch
from pathlib import Path

# Flutter projects create a lot of local cache/build output. Keep those out of
# the tree so the result stays useful for planning, reviews, and AI handoff.
IGNORE_DIRS = {
    ".git",
    ".idea",
    ".vscode",
    ".dart_tool",
    ".gradle",
    ".pub",
    ".pub-cache",
    ".symlinks",
    ".cxx",
    "__pycache__",
    "build",
    "captures",
    "coverage",
    "DerivedData",
    "ephemeral",
    "intermediates",
    "node_modules",
    "outputs",
    "Pods",
    "xcuserdata",
}

IGNORE_FILES = {
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "flutter_export_environment.sh",
    "Generated.xcconfig",
    "local.properties",
    "GeneratedPluginRegistrant.java",
    "GeneratedPluginRegistrant.h",
    "GeneratedPluginRegistrant.m",
    "GeneratedPluginRegistrant.swift",
    "generated_plugin_registrant.cc",
    "generated_plugin_registrant.h",
    "generated_plugins.cmake",
}

IGNORE_PATTERNS = {
    "*.iml",
    "*.lockfile",
    "*_tree.txt",
    "*.xcuserstate",
}

PLATFORM_DIRS = {
    "android",
    "ios",
    "linux",
    "macos",
    "web",
    "windows",
}

KEEP_EXT = {
    ".c",
    ".cc",
    ".cpp",
    ".css",
    ".dart",
    ".entitlements",
    ".gradle",
    ".h",
    ".html",
    ".java",
    ".js",
    ".json",
    ".kt",
    ".manifest",
    ".md",
    ".plist",
    ".properties",
    ".rc",
    ".storyboard",
    ".swift",
    ".toml",
    ".xml",
    ".xcconfig",
    ".yaml",
    ".yml",
}

KEEP_NAMES = {
    ".gitattributes",
    ".gitignore",
    ".metadata",
    "analysis_options.yaml",
    "AndroidManifest.xml",
    "build.gradle",
    "CMakeLists.txt",
    "firebase.json",
    "flutter_launcher_icons.yaml",
    "google-services.json",
    "GoogleService-Info.plist",
    "gradle.properties",
    "gradlew",
    "gradlew.bat",
    "key.properties.example",
    "Podfile",
    "Podfile.lock",
    "pubspec.lock",
    "pubspec.yaml",
    "README.md",
    "settings.gradle",
}


def is_ignored_name(name: str) -> bool:
    if name in IGNORE_FILES:
        return True
    return any(fnmatch.fnmatch(name, pattern) for pattern in IGNORE_PATTERNS)


def should_ignore_path(
    path: Path,
    root: Path,
    output_path: Path | None,
    app_only: bool,
) -> bool:
    rel = path.relative_to(root)

    if output_path is not None and path.resolve() == output_path:
        return True

    if any(part in IGNORE_DIRS for part in rel.parts):
        return True

    if app_only and rel.parts and rel.parts[0] in PLATFORM_DIRS:
        return True

    if path.is_file() and is_ignored_name(path.name):
        return True

    return False


def should_keep_file(path: Path) -> bool:
    name = path.name

    if name in KEEP_NAMES:
        return True

    if name.startswith(".env"):
        return True

    return path.suffix.lower() in KEEP_EXT


def sorted_entries(path: Path) -> list[Path]:
    return sorted(path.iterdir(), key=lambda entry: (entry.is_file(), entry.name.lower()))


def build_tree(
    root: Path,
    depth: int,
    output_path: Path | None = None,
    app_only: bool = False,
    show_empty_dirs: bool = False,
    unicode_tree: bool = False,
) -> list[str]:
    root = root.resolve()
    output_path = output_path.resolve() if output_path is not None else None

    tee = "├── " if unicode_tree else "|-- "
    last_branch = "└── " if unicode_tree else "`-- "
    pipe = "│   " if unicode_tree else "|   "
    space = "    "

    lines: list[str] = [root.name + "/"]

    def collect(cur: Path, level: int) -> list[tuple[Path, list]]:
        if level > depth:
            return []

        try:
            entries = sorted_entries(cur)
        except PermissionError:
            return []

        visible: list[tuple[Path, list]] = []
        for entry in entries:
            if should_ignore_path(entry, root, output_path, app_only):
                continue

            if entry.is_file():
                if should_keep_file(entry):
                    visible.append((entry, []))
                continue

            children = collect(entry, level + 1) if level < depth else []
            if children or show_empty_dirs or level == depth:
                visible.append((entry, children))

        return visible

    def render(entries: list[tuple[Path, list]], prefix: str) -> None:
        for index, (entry, children) in enumerate(entries):
            is_last = index == len(entries) - 1
            branch = last_branch if is_last else tee
            lines.append(prefix + branch + entry.name + ("/" if entry.is_dir() else ""))

            if entry.is_dir() and children:
                render(children, prefix + (space if is_last else pipe))

    render(collect(root, 1), "")
    return lines


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a clean Flutter project tree.")
    parser.add_argument("--root", default=".", help="Root Flutter project folder.")
    parser.add_argument("--depth", type=int, default=6, help="Max tree depth.")
    parser.add_argument("--out", default="nut_tree.txt", help="Output file path.")
    parser.add_argument(
        "--app-only",
        action="store_true",
        help="Hide platform folders and show only app-level source/docs/config.",
    )
    parser.add_argument(
        "--show-empty-dirs",
        action="store_true",
        help="Show directories even when no kept files are visible inside them.",
    )
    parser.add_argument(
        "--unicode",
        action="store_true",
        help="Use box-drawing tree characters instead of ASCII branches.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root = Path(args.root)

    if not root.exists():
        raise SystemExit(f"Error: root path does not exist: {root}")

    if not root.is_dir():
        raise SystemExit(f"Error: root path is not a directory: {root}")

    output_path = Path(args.out)
    lines = build_tree(
        root=root,
        depth=args.depth,
        output_path=output_path,
        app_only=args.app_only,
        show_empty_dirs=args.show_empty_dirs,
        unicode_tree=args.unicode,
    )

    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {len(lines)} lines to {output_path}")


if __name__ == "__main__":
    main()
