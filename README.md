# bind_forms

Model-driven forms for Flutter that bind to real widgets instead of wrapping them.

| Package | Description |
| --- | --- |
| [`bind_forms_core`](packages/bind_forms_core) | Pure Dart form model: controls, groups, arrays, validators. |
| [`bind_forms`](packages/bind_forms) | Flutter adapters over the core: text controllers, value notifiers, focus, `control.listenable`. |
| [`bind_forms_signals`](packages/bind_forms_signals) | Any control's state as signals (`control.signals`). Pure Dart. |

[`packages/bind_forms/example`](packages/bind_forms/example) showcases the widgets covered by reactive_forms_widgets (49 of its 52 widget packages; the rest are empty or no longer compile), bound without wrappers, plus the same login form with `Listenable`s and with signals.

## CI and releases

- **Pull requests** (`.github/workflows/pr.yml`): formatting, `dart analyze --fatal-infos`, every package's tests, and a `pub publish --dry-run` per package.
- **Main** (`main.yml`): the same checks, a Linux release build of the example (which compiles every showcased plugin), and a release-status summary of what is ready to release.
- **Publish** (`publish.yml`): pushing a tag `<package>-v<version>` verifies and tests that package, publishes it to pub.dev, and only then creates the GitHub Release. If anything fails before pub.dev accepts the package, the workflow deletes the tag again, so a failed release leaves nothing behind.

### Releasing

1. In a PR, bump `version` in the package's `pubspec.yaml` and add a `## <version>` entry to its `CHANGELOG.md`. Merge it.
2. Push the tag the main run's summary shows, e.g.:

   ```sh
   git tag bind_forms_core-v0.1.0 && git push origin bind_forms_core-v0.1.0
   ```

3. If the release fails, the tag is deleted: fix the problem and push the tag again. If only the GitHub Release step failed (the package did ship), re-run that job.

Release `bind_forms_core` before the packages that depend on it; Publish refuses a package whose workspace dependencies aren't on pub.dev yet, a version that is already published, and a version without a CHANGELOG entry. `python3 tool/release.py status` shows the summary locally.

### One-time setup

1. Publish the first version of each package by hand (`dart pub publish` in its directory); pub.dev only enables automated publishing on an existing package.
2. On pub.dev, for each package: **Admin → Automated publishing → Enable publishing from GitHub Actions**, with repository `abdulhaq-e/bind_forms`, tag pattern `<package>-v{{version}}` (e.g. `bind_forms_core-v{{version}}`), and **Require GitHub Actions environment** set to `pub.dev`.
3. In the GitHub repository settings, create the `pub.dev` environment, ideally with yourself as a required reviewer so every publish waits for approval. Rejecting the approval counts as a failed release: the tag is deleted.
