# Wallabag Helm Chart

This Helm chart deploys [wallabag](https://wallabag.org/) with optional MySQL and Redis configurations.

## Features

- **Flexible Database**: Use external MariaDB/MySQL or enable MariaDB subchart
- **Flexible Redis**: Use external Redis or enable Redis subchart
- **Persistent Storage**: Configurable persistent volume for wallabag data
- **Ingress Support**: TLS-enabled ingress configuration
- **Subchart Dependencies**: Optional MariaDB and Redis subcharts with conditional installation
- **Customizable**: Extensive configuration options

## Prerequisites

- Kubernetes 1.35+
- Helm 3+
- PV provisioner support in the underlying infrastructure (for persistence)

## Installation

### Using External MariaDB and Redis (Default)

```bash
helm install wallabag wallabag \
  --set externalDatabase.password="your-mysql-password" \
  --set ingress.hosts[0].host="wallabag.yourdomain.com"
```

### Using MariaDB Subchart

```bash
helm install wallabag wallabag \
  --set mariadb.enabled=true \
  --set mariadb.auth.password="your-mariadb-password" \
  --set ingress.hosts[0].host="wallabag.yourdomain.com"
```

### Using Redis Subchart

```bash
helm install wallabag wallabag \
  --set redis.enabled=true \
  --set ingress.hosts[0].host="wallabag.yourdomain.com"
```

### Using Both Subcharts

```bash
helm install wallabag wallabag \
  --set mariadb.enabled=true \
  --set mariadb.auth.password="your-mariadb-password" \
  --set redis.enabled=true \
  --set ingress.hosts[0].host="wallabag.yourdomain.com"
```

## Configuration

See [values.yaml](values.yaml) for all configuration options.

### Key Configuration Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Wallabag image repository | `wallabag/wallabag` |
| `image.tag` | Wallabag image tag | `""` (uses appVersion) |
| `mariadb.enabled` | Enable MariaDB subchart | `false` |
| `redis.enabled` | Enable Redis subchart | `false` |
| `externalDatabase.host` | External database host | `"mysql"` |
| `externalDatabase.port` | External database port | `3306` |
| `externalRedis.host` | External Redis host | `"redis"` |
| `externalRedis.port` | External Redis port | `6379` |
| `persistence.enabled` | Enable persistence | `false` |
| `persistence.size` | Persistent volume size | `10Gi` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.host` | Ingress host | `wallabag.example.com` |

## Upgrading

```bash
helm upgrade wallabag wallabag \
  --set database.externalPassword="your-new-password"
```

## Uninstalling

```bash
helm uninstall wallabag
```

## License

This Helm chart is released under the MIT License.
