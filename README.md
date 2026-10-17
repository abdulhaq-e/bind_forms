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
- **Main** (`main.yml`): the same checks, a Linux release build of the example (which compiles every showcased plugin), and a release-status summary of which package versions aren't on pub.dev yet.
- **Publish** (`publish.yml`): pushing a tag `<package>-v<version>` verifies and tests that package, then publishes it to pub.dev with automated publishing (GitHub OIDC, no secrets).

To release, bump `version` and `CHANGELOG.md` in the package, merge to main, then push the tag the main run's summary shows:

```sh
git tag bind_forms_core-v0.1.0 && git push origin bind_forms_core-v0.1.0
```

Publish `bind_forms_core` before the packages that depend on it; the publish workflow refuses a package whose workspace dependencies aren't on pub.dev yet. `tool/release.py status` shows the same summary locally.

One-time setup per package: publish the first version by hand (`dart pub publish` in the package directory), then on pub.dev enable **Admin → Automated publishing** for this repository with tag pattern `<package>-v{{version}}`. Optionally require the `pub.dev` GitHub environment there and add reviewers to it in the repository settings.
