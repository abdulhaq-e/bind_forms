#!/usr/bin/env python3
"""Release checks for the publishable packages in this workspace.

  release.py verify-tag <tag>   Check a release tag, print `package=<name>`.
  release.py status             Markdown table of what is ready to release.

A release tag is `<package>-v<version>`, e.g. `bind_forms_core-v0.1.0`,
matching the tag pattern configured for the package on pub.dev.
"""

import json
import pathlib
import re
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
    field = lambda key: (re.search(rf"^{key}:\s*(\S+)", text, re.M) or [None, None])[1]
    deps = re.search(r"^dependencies:\n((?:[ \t]+.*\n|\n)*)", text, re.M)
    names = re.findall(r"^  ([a-z0-9_]+):", deps[1], re.M) if deps else []
    return {
        "name": field("name"),
        "version": field("version"),
        "publish_to": field("publish_to"),
        "dependencies": names,
    }


def workspace_packages():
    """Publishable workspace packages, by name."""
    root = (ROOT / "pubspec.yaml").read_text()
    members = re.findall(r"^  - (\S+)", root.split("workspace:", 1)[1], re.M)
    packages = {}
    for member in members:
        pubspec = read_pubspec(ROOT / member / "pubspec.yaml")
        if pubspec["publish_to"] != "none":
            packages[pubspec["name"]] = {**pubspec, "dir": member}
    return packages


def published_versions(name):
    url = f"https://pub.dev/api/packages/{name}"
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            return {v["version"] for v in json.load(response)["versions"]}
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return set()
        raise


def unpublished_dependencies(package, packages):
    """Workspace dependencies whose local version isn't on pub.dev yet.

    The workspace was tested against those local versions, so they must be
    published before anything that depends on them.
    """
    missing = []
    for dep in package["dependencies"]:
        if dep in packages and packages[dep]["version"] not in published_versions(dep):
            missing.append(f"{dep} {packages[dep]['version']}")
    return missing


def verify_tag(tag):
    match = re.fullmatch(r"(.+)-v(\d+\.\d+\.\d+.*)", tag)
    if not match:
        fail(f"Tag '{tag}' is not <package>-v<version>.")
    name, version = match.groups()
    packages = workspace_packages()
    if name not in packages:
        fail(f"'{name}' is not a publishable package: {', '.join(packages)}.")
    package = packages[name]
    if package["version"] != version:
        fail(f"Tag says {version}, but {package['dir']}/pubspec.yaml says {package['version']}.")
    if version in published_versions(name):
        fail(f"{name} {version} is already on pub.dev.")
    missing = unpublished_dependencies(package, packages)
    if missing:
        fail(f"Publish these first: {', '.join(missing)}.")
    print(f"package={name}")
    print(f"dir={package['dir']}")


def status():
    packages = workspace_packages()
    rows = []
    for name, package in packages.items():
        version = package["version"]
        if version in published_versions(name):
            state = "published"
        else:
            missing = unpublished_dependencies(package, packages)
            tag = f"{name}-v{version}"
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
    if len(sys.argv) == 3 and sys.argv[1] == "verify-tag":
        verify_tag(sys.argv[2])
    elif len(sys.argv) == 2 and sys.argv[1] == "status":
        status()
    else:
        print(__doc__)
        sys.exit(2)
