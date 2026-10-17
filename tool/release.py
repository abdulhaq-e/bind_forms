#!/usr/bin/env python3
"""Release checks for the publishable packages in this workspace.

  release.py verify-tag <tag>   Check a release tag can be published; print
                                `package=`, `version=` and `dir=` lines.
  release.py published <tag>    Exit 0 if the tag's version is on pub.dev, 1 if
                                not, 2 if pub.dev couldn't be checked.
  release.py notes <tag>        Print the tag's CHANGELOG entry.
  release.py status             Markdown table of what is ready to release.

A release tag is `<package>-v<version>`, e.g. `bind_forms_core-v0.1.0`,
matching the tag pattern configured for the package on pub.dev.
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


def parse_tag(tag):
    match = re.fullmatch(r"(.+)-v(\d+\.\d+\.\d+.*)", tag)
    if not match:
        fail(f"Tag '{tag}' is not <package>-v<version>.")
    return match.groups()


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


def changelog_entry(package, version):
    path = ROOT / package["dir"] / "CHANGELOG.md"
    if not path.exists():
        return None
    match = re.search(
        rf"^## {re.escape(version)}[^\n]*\n(.*?)(?=^## |\Z)",
        path.read_text(), re.M | re.S,
    )
    return match[1].strip() if match else None


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


def verify_tag(tag):
    name, version = parse_tag(tag)
    packages = workspace_packages()
    if name not in packages:
        fail(f"'{name}' is not a publishable package: {', '.join(packages)}.")
    package = packages[name]
    if package["version"] != version:
        fail(
            f"Tag says {version}, but {package['dir']}/pubspec.yaml says "
            f"{package['version']}."
        )
    if version in published_versions(name):
        fail(f"{name} {version} is already on pub.dev.")
    if not changelog_entry(package, version):
        fail(f"{package['dir']}/CHANGELOG.md has no '## {version}' entry.")
    missing = unpublished_dependencies(package, packages)
    if missing:
        fail(f"Release these first: {', '.join(missing)}.")
    print(f"package={name}")
    print(f"version={version}")
    print(f"dir={package['dir']}")


def published(tag):
    """Exit 0 if published, 1 if not, 2 if pub.dev couldn't be checked."""
    match = re.fullmatch(r"(.+)-v(\d+\.\d+\.\d+.*)", tag)
    if not match:
        sys.exit(1)  # Not a release tag, so nothing can have been published.
    name, version = match.groups()
    try:
        versions = published_versions(name)
    except Exception as error:  # noqa: BLE001 - any failure means "unknown"
        print(f"::error::Couldn't check pub.dev: {error}", file=sys.stderr)
        sys.exit(2)
    sys.exit(0 if version in versions else 1)


def notes(tag):
    name, version = parse_tag(tag)
    packages = workspace_packages()
    entry = changelog_entry(packages[name], version) if name in packages else None
    if entry is None:
        fail(f"No CHANGELOG entry for {name} {version}.")
    print(entry)


def status():
    packages = workspace_packages()
    rows = []
    for name, package in packages.items():
        version = package["version"]
        tag = f"{name}-v{version}"
        tagged = tag_exists(tag)
        if version in published_versions(name):
            state = "released"
        elif tagged:
            state = (
                f"**tag `{tag}` exists but {version} isn't on pub.dev**: a "
                "release is running, or its cleanup failed; delete the tag "
                "to retry"
            )
        else:
            missing = unpublished_dependencies(package, packages)
            state = (
                f"waiting on {', '.join(missing)}"
                if missing
                else f"ready: `git tag {tag} && git push origin {tag}`"
            )
        rows.append(f"| `{name}` | {version} | {state} |")
    print("## Release status\n")
    print("| Package | Version | Status |\n| --- | --- | --- |")
    print("\n".join(rows))


if __name__ == "__main__":
    commands = {"verify-tag": verify_tag, "published": published, "notes": notes}
    args = sys.argv[1:]
    if len(args) == 2 and args[0] in commands:
        commands[args[0]](args[1])
    elif args == ["status"]:
        status()
    else:
        print(__doc__)
        sys.exit(2)
