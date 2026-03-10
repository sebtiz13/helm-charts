# AGENTS.md — Helm Charts Repository

This file provides instructions and context for AI coding agents working on this repository.
Read it entirely before making any changes.

## Project Overview

This repository hosts a collection of Helm charts for Kubernetes deployments.
Charts are distributed via two channels: a traditional Helm repository (GitHub Pages)
and an OCI registry (GitHub Container Registry).

- **Kubernetes target version:** 1.35
- **Helm version:** v3.12.0
- **License:** MIT

---

## Repository Structure

```
.
├── charts/                    # Helm charts (one subdirectory per chart)
├── .github/
│   └── workflows/             # GitHub Actions CI/CD pipelines
├── ct.yaml                    # Chart Testing (ct) configuration
├── CONTRIBUTING.md            # Contribution guidelines
└── AGENTS.md                  # This file
```

Each chart directory must follow the standard Helm chart structure:

```
charts/<chart-name>/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   └── ...
└── README.md                  # Required for Artifact Hub
```

---

## Tooling

This project uses **mise-en-place (jdx)** as the version manager and **HK (jdx)** for Git hooks.
Do not manually install tools — always rely on mise to manage versions.

| Tool              | Purpose                              |
|-------------------|--------------------------------------|
| `mise`            | Version manager (replaces nvm/asdf)  |
| `hk`              | Git hook runner                      |
| `helm` v3.12.0    | Chart packaging and pushing          |
| `ct`              | Chart linting and testing            |
| `gh`              | GitHub CLI for releases              |

---

## Development Rules

### General
- Never modify files in the `gh-pages` branch directly — it is managed exclusively by the release workflow.
- Do not bump chart versions manually without also updating `Chart.yaml` accordingly.
- Keep `ct.yaml` as-is unless explicitly asked to change linting configuration.

### Chart Conventions
- All charts must pass `helm lint charts/<chart-name>` without errors before merging.
- Each `Chart.yaml` must include `appVersion`, `version`, `description`, and `maintainers`.
- Use semantic versioning (`MAJOR.MINOR.PATCH`) for chart versions.
- Templates must use named helpers defined in `_helpers.tpl`.
- All configurable values must be documented in `values.yaml` with inline comments.
- Each chart **must include a `values.schema.json`** to validate values structure and types.
  Helm enforces this schema at install/upgrade time (`helm install`, `helm upgrade`).
- A `README.md` is required per chart for Artifact Hub metadata support.

### Dependencies
- Chart dependencies (e.g., MariaDB, Redis for wallabag) must be declared in `Chart.yaml`
  under the `dependencies` key and locked via `Chart.lock`.
- Run `helm dependency update charts/<chart-name>` after modifying dependencies.

---

## CI/CD Workflows

### Workflow 1 — Linting (`check-files`)
**Triggers:** `pull_request`, `push` to `main`

Steps executed:
1. Checkout repository
2. Install mise and activate tools
3. Run `ct lint --all` using `ct.yaml` config

> **Agent rule:** `ct lint --all` runs only in CI. Locally, run `helm lint charts/<chart-name>`
> on the modified chart to validate rendering and structure before proposing changes.

### Workflow 2 — Release (`release-charts`)
**Triggers:** `push` on tags matching `v*`

Steps executed:
1. Set up Helm v3.12.0 and authenticate to GHCR
2. Package all charts: `helm package charts/*`
3. Push each chart to OCI: `helm push <chart>.tgz oci://ghcr.io/<owner>/<repo>`
4. Generate repository index: `helm repo index`
5. Switch to `gh-pages` branch, commit `index.yaml` and `.tgz` files
6. Create a GitHub Release with chart packages as artifacts

> **Agent rule:** Never touch workflow files without being explicitly asked.
> If asked to add a new chart, focus only on the `charts/` directory.
> The release process is fully automated via version tags.

---

## Release Process (for reference only)

Releases are triggered by pushing a version tag:

```bash
git tag v1.2.3
git push origin v1.2.3
```

The workflow will automatically:
- Package all charts in `charts/`
- Push to GHCR OCI registry (`ghcr.io`)
- Publish to GitHub Pages (Helm traditional repo)
- Create a GitHub Release with `.tgz` artifacts

---

## Adding a New Chart

When asked to create a new chart, follow these steps:

1. Create the directory: `charts/<chart-name>/`
2. Scaffold using `helm create charts/<chart-name>` as a base, then clean up unused templates.
3. Fill in `Chart.yaml` with accurate metadata (name, version, appVersion, description, maintainers).
4. Define all values in `values.yaml` with comments explaining each field.
5. Create a `values.schema.json` that mirrors the structure of `values.yaml` and enforces
   types, required fields, and constraints using JSON Schema (draft-07).
6. Write a `README.md` with usage instructions and a values reference table.
7. If the chart has dependencies, declare them and run `helm dependency update`.
8. Ensure `ct lint --all` passes.

---

## Out of Scope for Agents

- Do not modify GitHub Actions workflow files unless explicitly instructed.
- Do not alter files out of the `charts/` directory without explicit instruction.
- Do not create, merge, or delete branches — only propose file changes.
- Do not generate Kubernetes manifests outside of Helm templates.

### Never modify without explicit instruction

| Path / Pattern              | Reason                                      |
|-----------------------------|---------------------------------------------|
| `.gitignore`                | Managed manually, project-wide impact       |
| `chart_schema.yaml`         | Defines validation rules for all charts     |
| `CONTRIBUTING.md`           | Human-facing documentation                  |
| `ct.yaml`                   | CI linting config, changes affect all PRs   |
| `.github/workflows/*.yaml`  | CI/CD pipelines, release-critical           |
| `mise.toml`                 | Toolchain versions, affects all developers  |
| `AGENTS.md`                 | Self-referential, never auto-modify         |

## Chart Examples

### `Chart.yaml`

❌ Bad — missing required fields, no semantic versioning:
```yaml
name: myapp
version: 1
```

✅ Good — complete metadata:
```yaml
apiVersion: v2
name: myapp
description: A Helm chart for deploying MyApp on Kubernetes
type: application
version: 1.0.0
appVersion: "2.3.1"
maintainers:
  - name: your-github-handle
    url: https://github.com/your-github-handle
```

---

### `values.yaml`

❌ Bad — no comments, ambiguous types, no structure:
```yaml
image: myapp:latest
port: 80
enabled: true
db: mydb
```

✅ Good — commented, structured, explicit types:
```yaml
image:
  repository: ghcr.io/my-org/myapp
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  # Port exposed by the Kubernetes service
  port: 80

# Enable ingress for external access
ingress:
  enabled: false
  hostname: myapp.example.com

database:
  host: ""
  port: 5432
  name: myapp
```

---

### `values.schema.json`

❌ Bad — no types, no required fields, no constraints:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "image": {},
    "service": {}
  }
}
```

✅ Good — types enforced, required fields declared, enum on known values:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["image", "service"],
  "properties": {
    "image": {
      "type": "object",
      "required": ["repository", "tag"],
      "properties": {
        "repository": { "type": "string" },
        "tag":        { "type": "string" },
        "pullPolicy": {
          "type": "string",
          "enum": ["Always", "IfNotPresent", "Never"]
        }
      }
    },
    "service": {
      "type": "object",
      "required": ["port"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["ClusterIP", "NodePort", "LoadBalancer"]
        },
        "port": {
          "type": "integer",
          "minimum": 1,
          "maximum": 65535
        }
      }
    }
  }
}
```

---

### Templates — `_helpers.tpl`

❌ Bad — hardcoded names, no reuse:
```yaml
# In deployment.yaml
name: myapp-deployment
labels:
  app: myapp
```

✅ Good — helpers used consistently across all templates:
```yaml
{{/* _helpers.tpl */}}
{{- define "myapp.fullname" -}}
{{ include "common.fullname" . }}
{{- end }}

{{- define "myapp.labels" -}}
helm.sh/chart: {{ include "myapp.chart" . }}
app.kubernetes.io/name: {{ include "myapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
```

```yaml
# In deployment.yaml
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
```

---

### Resource Limits

❌ Bad — no resource constraints (risk of node starvation):
```yaml
containers:
  - name: myapp
    image: myapp:1.0.0
```

✅ Good — requests and limits always defined via values:
```yaml
# values.yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```
```yaml
# deployment.yaml
resources:
  {{- toYaml .Values.resources | nindent 12 }}
```
### Dependencies

Prefer official or well-maintained community charts for common services (databases, caches, etc.)
rather than writing custom templates. Always expose an `enabled` condition per dependency
so the service can be toggled without removing it from `Chart.yaml`.

❌ Bad — custom MariaDB templates instead of reusing an existing chart:
```
charts/wallabag/
└── templates/
    ├── mariadb-deployment.yaml   # ❌ reinventing the wheel
    ├── mariadb-service.yaml
    └── mariadb-secret.yaml
```

❌ Bad — dependency declared without condition or alias:
```yaml
# Chart.yaml
dependencies:
  - name: mariadb
    version: "11.x.x"
    repository: https://charts.bitnami.com/bitnami
```

✅ Good — dependency with condition, alias, and repository:
```yaml
# Chart.yaml
dependencies:
  - name: mariadb
    version: "11.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: mariadb.enabled
    alias: mariadb

  - name: redis
    version: "18.x.x"
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
    alias: redis
```

✅ Good — corresponding `values.yaml` toggles with sane defaults:
```yaml
# values.yaml

# Enable the built-in MariaDB subchart.
# Set to false to use an external database via externalDatabase.*
mariadb:
  enabled: true
  auth:
    database: wallabag
    username: wallabag
    # password: "" — override at install time, never commit secrets

# Enable the built-in Redis subchart.
# Set to false to use an external Redis instance via externalRedis.*
redis:
  enabled: true

# Used only when mariadb.enabled is false
externalDatabase:
  host: ""
  port: 3306
  name: wallabag
  username: wallabag
  password: ""

# Used only when redis.enabled is false
externalRedis:
  host: ""
  port: 6379
  password: ""
```

✅ Good — template referencing the dependency conditionally:
```yaml
# templates/deployment.yaml
env:
  - name: DATABASE_HOST
    value: {{ if .Values.mariadb.enabled }}
              {{- include "wallabag.fullname" . }}-mariadb
           {{- else }}
              {{- .Values.externalDatabase.host }}
           {{- end }}
```

> **Agent rule:** When adding a dependency, always:
> 1. Declare it in `Chart.yaml` with a `condition` and an `alias`.
> 2. Add an `<alias>.enabled` boolean toggle in `values.yaml` (default `true`).
> 3. Add a corresponding `external<Service>.*` block in `values.yaml` for when the subchart is disabled.
> 4. Run `helm dependency update charts/<chart-name>` to generate/update `Chart.lock`.
> 5. Never commit credentials — document password fields with empty defaults and a comment.

### Secrets

Never create a Secret unconditionally. Always provide an `existingSecret` option per service
so users can supply their own secret (e.g. from Vault, Sealed Secrets, or an external operator)
without the chart overwriting it.

❌ Bad — secret always created, no way to bring your own:
```yaml
# templates/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "wallabag.fullname" . }}-db
type: Opaque
stringData:
  password: {{ .Values.mariadb.auth.password }}
```

✅ Good — secret creation is conditional on `existingSecret` being empty:
```yaml
# templates/secret.yaml
{{- if not .Values.mariadb.existingSecret }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "wallabag.fullname" . }}-db
  labels:
    {{- include "wallabag.labels" . | nindent 4 }}
type: Opaque
stringData:
  password: {{ .Values.mariadb.auth.password | required "mariadb.auth.password is required when mariadb.existingSecret is not set" | quote }}
{{- end }}
```

✅ Good — deployment resolves the secret name dynamically:
```yaml
# templates/deployment.yaml
env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.mariadb.existingSecret | default (printf "%s-db" (include "wallabag.fullname" .)) }}
        key: password
```

✅ Good — corresponding `values.yaml` with documentation:
```yaml
mariadb:
  enabled: true
  auth:
    database: wallabag
    username: wallabag
    # password: "" — required if existingSecret is not set. Never commit this value.
    # existingSecret: "" — name of an existing Secret containing a `password` key.
    #                      If set, no Secret will be created by this chart.
    existingSecret: ""
```

✅ Good — `values.schema.json` reflects the mutual exclusivity:
```json
"auth": {
  "type": "object",
  "properties": {
    "password":       { "type": "string" },
    "existingSecret": { "type": "string" }
  },
  "if":   { "properties": { "existingSecret": { "const": "" } } },
  "then": { "required": ["password"] }
}
```

> **Agent rule:** For every service that requires credentials:
> 1. Add an `existingSecret` field under the service key in `values.yaml` (default `""`).
> 2. Wrap the `Secret` template with `{{- if not .Values.<service>.existingSecret }}`.
> 3. In all templates consuming the secret, resolve the name with:
>    `{{ .Values.<service>.existingSecret | default (printf "%s-<suffix>" (include "<chart>.fullname" .)) }}`
> 4. Use `| required "..."` on password fields to fail fast with a clear error message
>    when neither `password` nor `existingSecret` is provided.
> 5. Reflect the conditional requirement in `values.schema.json` using `if/then`.
