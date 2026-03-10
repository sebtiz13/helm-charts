# Helm Charts Repository

A collection of Helm charts for Kubernetes applications.

## Usage

### Traditional Helm Repository (GitHub Pages)

Add this repository to Helm:

```bash
helm repo add sebtiz13 https://sebtiz13.github.io/helm-charts/
helm repo update
helm search repo sebtiz13
```

### OCI Registry (GitHub Container Registry)

Add and use the OCI registry:

```bash
# Add the OCI repository
helm registry login ghcr.io
helm pull oci://ghcr.io/sebtiz13/my-chart --version 0.1.0

# Or install directly
helm install my-release oci://ghcr.io/sebtiz13/my-chart --version 0.1.0
```

## Charts

- **example-chart**: A sample Helm chart demonstrating best practices

## License

MIT License - see LICENSE file for details.
