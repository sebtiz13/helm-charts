# Wallabag Helm Chart

This Helm chart deploys [wallabag](https://wallabag.org/) with flexible database and Redis configurations.

## Features

- **Multiple Database Options**: MariaDB, PostgreSQL subcharts or external databases
- **Flexible Redis**: Redis subchart or external Redis
- **Persistent Storage**: Configurable persistent volume for wallabag data
- **Ingress Support**: Ingress configuration with optional TLS
- **Comprehensive Configuration**: Extensive wallabag-specific settings

## Prerequisites

- Kubernetes 1.35+
- Helm 3+
- PV provisioner support in the underlying infrastructure (for persistence)

## Installation

### Using External Database and Redis (Recommended for Production)

```bash
helm install wallabag oci://ghcr.io/sebtiz13/helm-charts/wallabag \
  --set externalDatabase.host="your-mysql-host" \
  --set externalDatabase.password="your-mysql-password" \
  --set externalRedis.host="your-redis-host" \
  --set ingress.enabled=true \
  --set ingress.host="wallabag.yourdomain.com" \
  --set ingress.tls.enabled=true
```

### Using MariaDB Subchart

```bash
helm install wallabag oci://ghcr.io/sebtiz13/helm-charts/wallabag \
  --set mariadb.enabled=true \
  --set mariadb.auth.password="your-mariadb-password" \
  --set ingress.enabled=true \
  --set ingress.host="wallabag.yourdomain.com"
```

### Using PostgreSQL Subchart

```bash
helm install wallabag oci://ghcr.io/sebtiz13/helm-charts/wallabag \
  --set postgresql.enabled=true \
  --set postgresql.auth.password="your-postgres-password" \
  --set postgresql.auth.postgresPassword="your-postgres-admin-password" \
  --set ingress.enabled=true \
  --set ingress.host="wallabag.yourdomain.com"
```

### Using Redis Subchart

```bash
helm install wallabag oci://ghcr.io/sebtiz13/helm-charts/wallabag \
  --set redis.enabled=true \
  --set redis.auth.password="your-redis-password" \
  --set externalDatabase.driver="pdo_mysql" \
  --set externalDatabase.host="your-mysql-host" \
  --set externalDatabase.password="your-mysql-password" \
  --set ingress.enabled=true \
  --set ingress.host="wallabag.yourdomain.com"
```

## Configuration

### Common Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mariadb.enabled` | Enable MariaDB subchart | `false` |
| `mariadb.auth.password` | MariaDB password | `""` (required) |
| `mariadb.auth.rootPassword` | MariaDB root password | `""` (required) |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.host` | Ingress host | `"wallabag.example.com"` |
| `ingress.tls.enabled` | Enable TLS | `false` |
| `persistence.enabled` | Enable persistence | `false` |
| `wallabag.serverName` | Instance name for 2FA | `"Your wallabag instance"` |
| `wallabag.secret` | Security token secret | `"ovmpmAWXRCabNlMgzlzFXDYmCFfzGv"` |
| `wallabag.fos.userRegistration` | Enable public registration | `false` |
| `wallabag.fos.userConfirmation` | Enable email confirmation | `true` |

### MariaDB Subchart Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mariadb.enabled` | Enable MariaDB subchart | `false` |
| `mariadb.architecture` | MariaDB architecture | `standalone` |
| `mariadb.auth.database` | Database name | `wallabag` |
| `mariadb.auth.username` | Database username | `wallabag` |
| `mariadb.auth.password` | Database password | `""` (required) |
| `mariadb.auth.rootPassword` | Root password | `""` (required) |
| `mariadb.primary.persistence.enabled` | Enable persistence | `true` |
| `mariadb.primary.persistence.size` | Volume size | `8Gi` |

### PostgreSQL Subchart Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable PostgreSQL subchart | `false` |
| `postgresql.architecture` | PostgreSQL architecture | `standalone` |
| `postgresql.auth.database` | Database name | `wallabag` |
| `postgresql.auth.username` | Database username | `wallabag` |
| `postgresql.auth.password` | Database password | `""` (required) |
| `postgresql.auth.postgresPassword` | PostgreSQL admin password | `""` (required) |
| `postgresql.auth.existingSecret` | Existing secret name | `""` |
| `postgresql.primary.persistence.enabled` | Enable persistence | `true` |
| `postgresql.primary.persistence.size` | Volume size | `8Gi` |

### Redis Subchart Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Enable Redis subchart | `false` |
| `redis.architecture` | Redis architecture | `standalone` |
| `redis.auth.enabled` | Enable Redis authentication | `false` |
| `redis.auth.password` | Redis password | `""` |
| `redis.master.persistence.enabled` | Enable persistence | `true` |
| `redis.master.persistence.size` | Volume size | `1Gi` |

### External Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalDatabase.driver` | Database driver | `"pdo_mysql"` |
| `externalDatabase.host` | Database host | `""` (required) |
| `externalDatabase.port` | Database port | `3306` |
| `externalDatabase.database` | Database name | `"wallabag"` |
| `externalDatabase.username` | Database username | `"wallabag"` |
| `externalDatabase.password` | Database password | `""` (required) |
| `externalDatabase.rootPassword` | Root password | `""` |
| `externalDatabase.existingSecret` | Existing secret name | `""` |
| `externalDatabase.existingAdminSecret` | Existing admin secret name | `""` |

### External Redis Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalRedis.host` | Redis host | `""` (required) |
| `externalRedis.port` | Redis port | `6379` |
| `externalRedis.password` | Redis password | `""` |
| `externalRedis.existingSecret` | Existing secret name | `""` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.host` | Ingress host | `"wallabag.example.com"` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls.enabled` | Enable TLS | `false` |
| `ingress.tls.secretName` | TLS secret name | `""` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `false` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Volume size | `10Gi` |

### Wallabag Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `wallabag.domainName` | Domain name override (by default use `ingress.host` if enabled) | `""` |
| `wallabag.memoryLimit` | PHP memory limit | `"128M"` |
| `wallabag.serverName` | Instance name for 2FA | `"Your wallabag instance"` |
| `wallabag.secret` | Security token secret | `"ovmpmAWXRCabNlMgzlzFXDYmCFfzGv"` |
| `wallabag.locale` | Default language | `"en"` |
| `wallabag.fromEmail` | From email address | `"no-reply@wallabag.org"` |
| `wallabag.twofactorSender` | 2FA email sender | `"no-reply@wallabag.org"` |
| `wallabag.mailerDsn` | Mailer DSN | `"smtp://127.0.0.1"` |
| `wallabag.sentryDsn` | Sentry DSN | `""` |
| `wallabag.fos.userRegistration` | Enable public registration | `false` |
| `wallabag.fos.userConfirmation` | Enable email confirmation | `true` |

### Custom Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Wallabag image repository | `wallabag/wallabag` |
| `image.tag` | Wallabag image tag | `""` (uses chart appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

## License

This Helm chart is released under the MIT License.
