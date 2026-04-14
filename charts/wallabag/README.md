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
| `annotations` | Annotations for the deployment | `{}` |
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
| `persistence.labels` | Custom labels for the main PVC | `{}` |
| `persistence.annotations` | Custom annotations for the main PVC | `{}` |

### Persistence Extra Volumes Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.extraVolumes` | Additional volumes for custom storage (e.g., cache, logs) | `[]` |
| `persistence.extraVolumes[].name` | Name of the volume (required) | `""` |
| `persistence.extraVolumes[].mountPath` | Path where the volume will be mounted in the container (required) | `""` |
| `persistence.extraVolumes[].accessMode` | Access mode for the PVC (optional) | `"ReadWriteOnce"` |
| `persistence.extraVolumes[].size` | Storage size for the PVC (required) | `""` |
| `persistence.extraVolumes[].storageClass` | Storage class for the PVC (optional) | `""` |
| `persistence.extraVolumes[].labels` | Custom labels for the PVC (optional) | `{}` |
| `persistence.extraVolumes[].annotations` | Custom annotations for the PVC (optional) | `{}` |

```yaml
persistence:
  extraVolumes:
    - name: wallabag-cache
      mountPath: /var/www/wallabag/var/cache
      accessMode: ReadWriteOnce
      size: 1Gi
      storageClass: "local-path"
      labels:
        app.kubernetes.io/component: cache
        backup: "false"
    - name: wallabag-logs
      mountPath: /var/www/wallabag/var/logs
      accessMode: ReadWriteOnce
      size: 5Gi
      labels:
        app.kubernetes.io/component: logs
```

### Extra Volumes Configuration

Additional generic volumes can be added to the pod and mounted to the main container using `extraVolumes`. This accepts standard Kubernetes `volume` properties within the `.volume` mapping, alongside root-level mount configurations.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extraVolumes` | Additional volumes to attach to the pod and mount in the main container | `[]` |
| `extraVolumes[].name` | Name of the volume (required) | `""` |
| `extraVolumes[].mountPath` | Path where the volume will be mounted in the container (required) | `""` |
| `extraVolumes[].readOnly` | Mount the volume as read-only (optional) | `false` |
| `extraVolumes[].subPath` | Sub-path of the volume to mount (optional) | `""` |
| `extraVolumes[].subPathExpr` | Sub-path expression of the volume to mount (optional) | `""` |
| `extraVolumes[].volume` | Standard Kubernetes volume definition (e.g., `emptyDir`, `configMap`, `secret`) (required) | `{}` |

```yaml
extraVolumes:
  - name: extras
    mountPath: /usr/share/extras
    readOnly: true
    volume:
      emptyDir: {}
```

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

### Probes Configuration

#### Liveness Probe

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.enabled` | Enable liveness probe | `true` |
| `livenessProbe.httpGet.path` | HTTP path for liveness probe | `"/api/info"` |
| `livenessProbe.httpGet.port` | Port for liveness probe | `"http"` |
| `livenessProbe.httpGet.scheme` | Scheme for liveness probe | `"HTTP"` |
| `livenessProbe.initialDelaySeconds` | Initial delay for liveness probe | `nil` |
| `livenessProbe.periodSeconds` | Period for liveness probe | `nil` |
| `livenessProbe.timeoutSeconds` | Timeout for liveness probe | `nil` |
| `livenessProbe.successThreshold` | Success threshold for liveness probe | `nil` |
| `livenessProbe.failureThreshold` | Failure threshold for liveness probe | `nil` |

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: "/api/healthz"
    port: "http"
    scheme: "HTTPS"
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
```

#### Readiness Probe

| Parameter | Description | Default |
|-----------|-------------|---------|
| `readinessProbe.enabled` | Enable readiness probe | `true` |
| `readinessProbe.httpGet.path` | HTTP path for readiness probe | `"/api/info"` |
| `readinessProbe.httpGet.port` | Port for readiness probe | `"http"` |
| `readinessProbe.httpGet.scheme` | Scheme for readiness probe | `"HTTP"` |
| `readinessProbe.initialDelaySeconds` | Initial delay for readiness probe | `nil` |
| `readinessProbe.periodSeconds` | Period for readiness probe | `nil` |
| `readinessProbe.timeoutSeconds` | Timeout for readiness probe | `nil` |
| `readinessProbe.successThreshold` | Success threshold for readiness probe | `nil` |
| `readinessProbe.failureThreshold` | Failure threshold for readiness probe | `nil` |

```yaml
readinessProbe:
  enabled: true
  httpGet:
    path: "/api/ready"
    port: "http"
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3
```

#### Startup Probe

| Parameter | Description | Default |
|-----------|-------------|---------|
| `startupProbe.enabled` | Enable startup probe | `false` |
| `startupProbe.httpGet.path` | HTTP path for startup probe | `"/api/info"` |
| `startupProbe.httpGet.port` | Port for startup probe | `"http"` |
| `startupProbe.httpGet.scheme` | Scheme for startup probe | `"HTTP"` |
| `startupProbe.initialDelaySeconds` | Initial delay for startup probe | `nil` |
| `startupProbe.periodSeconds` | Period for startup probe | `nil` |
| `startupProbe.timeoutSeconds` | Timeout for startup probe | `nil` |
| `startupProbe.successThreshold` | Success threshold for startup probe | `nil` |
| `startupProbe.failureThreshold` | Failure threshold for startup probe | `nil` |

```yaml
startupProbe:
  enabled: true
  httpGet:
    path: "/api/info"
    port: "http"
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 30
```

## License

This Helm chart is released under the MIT License.
