# Contributing to Helm Charts Repository

Thank you for your interest in contributing to this Helm charts repository!

## Repository Structure

### Main Branch
```
.
├── .github/workflows/            # GitHub Actions workflows
│   ├── release.yml               # Release automation (includes index generation)
│   └── yamllint.yml              # YAML linting workflow
├── charts/                       # Helm charts directory
│   └── my-chart/                 # Chart directory
│       ├── templates/            # Kubernetes templates
│       ├── artifacthub-pkg.yml   # ArtifactHub package metadata
│       ├── Chart.yaml            # Chart definition
│       ├── README.md             # Chart documentation
│       └── values.yaml           # Default values
├── .editorconfig                 # Editor configuration
├── .gitignore                    # Git ignore rules
├── .helmignore                   # Helm ignore rules
├── .yamllint.yaml                # YAML lint configuration
├── CONTRIBUTING.md               # Development and contribution guidelines
├── hk.pkl                        # Git Hook Manager configuration
├── mise.toml                     # Runtime tool management
├── LICENSE                       # Repository license
└── README.md                     # This file
```

### gh-pages Branch (GitHub Pages)
```
.
├── artifacthub-repo.yml          # ArtifactHub repository metadata
├── index.yaml                    # Helm repository index
└── *.tgz                         # Packaged Helm charts
```

## Code Quality

This repository uses `helm lint` and `chart-testing` for chart validation to ensure consistent formatting and catch potential issues early.

### Pre-commit Hooks

The repository includes a pre-commit hook that automatically run `helm lint` on all charts before each commit. This helps maintain code quality and consistency.

### Setup with mise (recommended)

```bash
# Install mise (runtime manager)
curl https://mise.run | sh

# Install tools and setup environment
mise install
# This automatically:
# - Installs hk and pkl
# - Sets up pre-commit hook
```

## Adding a New Chart

1. **Create a new directory** in the `charts/` directory
2. **Scaffold the chart** using Helm:
   ```bash
   helm create my-new-chart
   ```
3. **Update the chart**:
   - Modify `values.yaml` with sensible defaults
   - Update templates in the `templates/` directory
   - Add comprehensive documentation in `README.md`
4. **Add ArtifactHub metadata** in `artifacthub-pkg.yml`
5. **Update documentation**: Add your chart to the main `README.md`

## Chart Guidelines

### Best Practices

- Follow Helm best practices for chart structure
- Use semantic versioning for chart releases
- Include comprehensive documentation
- Add appropriate labels and annotations
- Test charts thoroughly before releasing

### Chart Structure

```
my-chart/
├── templates/          # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration values
├── README.md           # Chart documentation
├── artifacthub-pkg.yml # ArtifactHub metadata
└── charts/             # Optional dependencies
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes and ensure tests pass
4. Update documentation as needed
5. Submit a pull request to the main branch
6. Wait for code review and CI checks to pass

## Publishing Charts

Charts are automatically published to BOTH GitHub Pages AND GitHub OCI Registry when tagged releases are created.

### Creating a Release

```bash
# Create a new tag (follow semantic versioning)
git tag v1.0.0

# Push the tag to trigger the release workflow
git push origin v1.0.0
```

### Release Process

The GitHub Actions workflow will automatically:

1. **Package all charts** in the `charts/` directory
2. **Push charts to GitHub OCI Registry** (`ghcr.io`)
3. **Generate the Helm repository index**
4. **Publish to GitHub Pages** (gh-pages branch)
5. **Create a GitHub release** with the chart packages

## Code of Conduct

Please note that this project is released with a [Contributor Covenant](https://www.contributor-covenant.org/). By participating in this project you agree to abide by its terms.

## Support

If you have questions or need help, please open an issue with the "question" label.
