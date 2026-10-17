#!/usr/bin/env python3
"""Release checks for the publishable packages in this workspace.

  release.py verify <package> <version>   Check a release can go ahead; print
                                          `dir=<package dir>`.
  release.py notes <package> <version>    Print the version's CHANGELOG entry.
  release.py status                       Markdown table of what is ready.

A release publishes to pub.dev first and tags `<package>-v<version>` only
after that succeeded, so a tag always records something that shipped.
"""

import json
import pathlib
import re
import subprocess
import sys
import urllib.error
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent


def fail(message):
    print(f"::error::{message}", file=sys.stderr)
    sys.exit(1)


def read_pubspec(path):
    """The few pubspec fields needed here, without a YAML dependency."""
    text = path.read_text()

    def field(key):
        match = re.search(rf"^{key}:\s*(\S+)", text, re.M)
        return match[1] if match else None

    deps = re.search(r"^dependencies:\n((?:[ \t]+.*\n|\n)*)", text, re.M)
    names = re.findall(r"^  ([a-z0-9_]+):", deps[1], re.M) if deps else []
    return {
        "name": field("name"),
        "version": field("version"),
        "publish_to": field("publish_to"),
        "dependencies": names,
    }


def workspace_packages():
    """Publishable workspace packages by name, dependencies first."""
    root = (ROOT / "pubspec.yaml").read_text()
    members = re.findall(r"^  - (\S+)", root.split("workspace:", 1)[1], re.M)
    packages = {}
    for member in members:
        pubspec = read_pubspec(ROOT / member / "pubspec.yaml")
        if pubspec["publish_to"] != "none":
            packages[pubspec["name"]] = {**pubspec, "dir": member}

    ordered = {}

    def visit(name):
        if name in ordered:
            return
        for dep in packages[name]["dependencies"]:
            if dep in packages:
                visit(dep)
        ordered[name] = packages[name]

    for name in packages:
        visit(name)
    return ordered


def tag_name(name, version):
    return f"{name}-v{version}"


def published_versions(name):
    url = f"https://pub.dev/api/packages/{name}"
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            return {v["version"] for v in json.load(response)["versions"]}
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return set()
        raise


def tag_exists(tag):
    """Whether the tag exists on the remote (not just in a shallow clone)."""
    result = subprocess.run(
        ["git", "ls-remote", "--tags", "origin", f"refs/tags/{tag}"],
        cwd=ROOT, capture_output=True, text=True, check=True,
    )
    return bool(result.stdout.strip())


def unpublished_dependencies(package, packages):
    """Workspace dependencies whose local version isn't on pub.dev yet.

    The workspace was tested against those local versions, so they must be
    published before anything that depends on them.
    """
    return [
        f"{dep} {packages[dep]['version']}"
        for dep in package["dependencies"]
        if dep in packages
        and packages[dep]["version"] not in published_versions(dep)
    ]


def verify(name, version):
    packages = workspace_packages()
    if name not in packages:
        fail(f"'{name}' is not a publishable package: {', '.join(packages)}.")
    package = packages[name]
    if package["version"] != version:
        fail(
            f"Asked to release {version}, but {package['dir']}/pubspec.yaml "
            f"says {package['version']}. Bump the pubspec and merge first."
        )
    if version in published_versions(name):
        fail(f"{name} {version} is already on pub.dev.")
    if tag_exists(tag_name(name, version)):
        fail(
            f"Tag {tag_name(name, version)} already exists, but {version} isn't "
            "on pub.dev. Delete the stale tag or release a new version."
        )
    if not changelog_entry(package, version):
        fail(f"{package['dir']}/CHANGELOG.md has no '## {version}' entry.")
    missing = unpublished_dependencies(package, packages)
    if missing:
        fail(f"Release these first: {', '.join(missing)}.")
    print(f"dir={package['dir']}")


def changelog_entry(package, version):
    path = ROOT / package["dir"] / "CHANGELOG.md"
    if not path.exists():
        return None
    match = re.search(
        rf"^## {re.escape(version)}[^\n]*\n(.*?)(?=^## |\Z)",
        path.read_text(), re.M | re.S,
    )
    return match[1].strip() if match else None


def notes(name, version):
    packages = workspace_packages()
    if name not in packages:
        fail(f"'{name}' is not a publishable package.")
    entry = changelog_entry(packages[name], version)
    if entry is None:
        fail(f"No CHANGELOG entry for {name} {version}.")
    print(entry)


def status():
    packages = workspace_packages()
    rows = []
    for name, package in packages.items():
        version = package["version"]
        tagged = tag_exists(tag_name(name, version))
        if version in published_versions(name):
            state = "released" if tagged else (
                f"**published but not tagged**: re-run the failed "
                f"tag-and-release job, or tag the published commit as "
                f"`{tag_name(name, version)}`"
            )
        elif tagged:
            state = f"**stale tag** `{tag_name(name, version)}`: nothing was published"
        else:
            missing = unpublished_dependencies(package, packages)
            state = (
                f"waiting on {', '.join(missing)}"
                if missing
                else f"ready: run **Publish** with `{name}` / `{version}`"
            )
        rows.append(f"| `{name}` | {version} | {state} |")
    print("## Release status\n")
    print("| Package | Version | Status |\n| --- | --- | --- |")
    print("\n".join(rows))


if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) == 3 and args[0] == "verify":
        verify(args[1], args[2])
    elif len(args) == 3 and args[0] == "notes":
        notes(args[1], args[2])
    elif args == ["status"]:
        status()
    else:
        print(__doc__)
        sys.exit(2)
