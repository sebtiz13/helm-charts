# Example Chart

A sample Helm chart demonstrating best practices for Kubernetes applications.

## Features

- Standard Kubernetes deployment with configurable replicas
- Service with configurable type and port
- Optional ingress configuration
- Horizontal pod autoscaling support
- Configurable resource limits and requests

## Installation

```bash
helm repo add my-repo https://username.github.io/helm-charts/
helm repo update
helm install my-release my-repo/example-chart
```

## Configuration

See the [values.yaml](values.yaml) file for all configuration options.

### Common Configuration

```yaml
replicaCount: 3

image:
  repository: my-custom-image
  tag: v1.2.3

service:
  type: LoadBalancer
  port: 8080

ingress:
  enabled: true
  hosts:
    - host: mydomain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Container image tag | `""` (uses appVersion) |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `false` |

## License

MIT License - see LICENSE file for details.