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
- **Main** (`main.yml`): the same checks, a Linux release build of the example (which compiles every showcased plugin), and a release-status summary.
- **Publish** (`publish.yml`, run by hand): verifies and tests one package, publishes it to pub.dev, and only then tags `<package>-v<version>` and creates the GitHub Release. A failed publish leaves no tag behind.

### Releasing

1. In a PR, bump `version` in the package's `pubspec.yaml` and add a `## <version>` entry to its `CHANGELOG.md`. Merge it.
2. In Actions, run **Publish** on `main` with the package and version. The main run's summary lists what is ready.
3. If only the tag step failed, use **Re-run failed jobs**: it tags the commit that was published.

Release `bind_forms_core` before the packages that depend on it; Publish refuses a package whose workspace dependencies aren't on pub.dev yet, a version that is already published or tagged, and a version without a CHANGELOG entry. `python3 tool/release.py status` shows the summary locally.

### One-time setup

pub.dev's GitHub Actions publishing only accepts runs triggered by a tag push, which would put the tag first. Publish instead impersonates a Google Cloud service account through Workload Identity Federation, so there are still no stored secrets.

1. Publish the first version of each package by hand (`dart pub publish` in its directory); automated publishing can only be enabled on an existing package.
2. In a Google Cloud project, create the service account and allow this repository to impersonate it and mint ID tokens for it:

   ```sh
   PROJECT_ID=your-project-id
   gcloud config set project "$PROJECT_ID"

   gcloud services enable iamcredentials.googleapis.com
   gcloud iam service-accounts create pub-dev --display-name=pub-dev

   gcloud iam workload-identity-pools create github --location=global
   gcloud iam workload-identity-pools providers create-oidc bind-forms \
     --location=global --workload-identity-pool=github \
     --issuer-uri=https://token.actions.githubusercontent.com \
     --attribute-mapping=google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner \
     --attribute-condition="assertion.repository_owner == 'abdulhaq-e'"

   POOL=$(gcloud iam workload-identity-pools describe github --location=global --format='value(name)')
   for role in roles/iam.workloadIdentityUser roles/iam.serviceAccountTokenCreator; do
     gcloud iam service-accounts add-iam-policy-binding "pub-dev@$PROJECT_ID.iam.gserviceaccount.com" \
       --role=$role --member="principalSet://iam.googleapis.com/$POOL/attribute.repository/abdulhaq-e/bind_forms"
   done
   ```

3. On pub.dev, for each package: **Admin → Automated publishing → Enable publishing with Google Cloud Service account**, with `pub-dev@<project>.iam.gserviceaccount.com`.
4. In the GitHub repository, add two Actions **variables** (not secrets; neither is sensitive):
   - `GCP_WORKLOAD_IDENTITY_PROVIDER`: the output of `gcloud iam workload-identity-pools providers describe bind-forms --location=global --workload-identity-pool=github --format='value(name)'`
   - `PUB_DEV_SERVICE_ACCOUNT`: `pub-dev@<project>.iam.gserviceaccount.com`
5. Create the `pub.dev` environment in the repository settings, ideally with yourself as a required reviewer, so every publish waits for approval.
