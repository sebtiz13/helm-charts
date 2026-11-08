# llamacpp Helm Chart

A Helm chart for deploying [llama.cpp](https://github.com/ggml-org/llama.cpp) server (`llama-server`) on Kubernetes.

`llama-server` is a lightweight HTTP API server built on top of llama.cpp that exposes an OpenAI-compatible REST interface for local LLM inference.

## Prerequisites

- Kubernetes 1.19+
- Helm v3.12.0+
- A GGUF model file accessible to the cluster (loaded into the PVC after deployment)

## Installation

Add the repository and install the chart:

```bash
helm repo add sebtiz13 https://sebtiz13.github.io/helm-charts
helm repo update
helm install my-llamacpp sebtiz13/llamacpp
```

Or install directly from source:

```bash
helm install my-llamacpp ./charts/llamacpp
```

### Custom values example

```bash
helm install my-llamacpp sebtiz13/llamacpp \
  --set llamacpp.model=/models/mistral-7b.gguf \
  --set llamacpp.nGpuLayers=32 \
  --set llamacpp.contextSize=4096 \
  --set persistence.size=50Gi
```

## Loading a Model

After installation, copy a GGUF model into the PVC:

```bash
POD=$(kubectl get pod -l app.kubernetes.io/instance=my-llamacpp -o jsonpath="{.items[0].metadata.name}")
kubectl cp /path/to/model.gguf default/$POD:/models/model.gguf
```

## Accessing the API

For a ClusterIP service, use port-forward:

```bash
kubectl port-forward svc/my-llamacpp 8080:8080
curl http://127.0.0.1:8080/health
```

## Values Reference

### llama.cpp configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.hf` | Hugging Face model repository | `nil` |
| `llamacpp.model` | Model path inside the container | `nil` |
| `llamacpp.host` | Host to bind the server to | `0.0.0.0` |
| `llamacpp.port` | Port the server listens on | `9931` |
| `llamacpp.webui` | Whether to enable the Web UI ( `0` = disabled ) | `0` |
| `llamacpp.nGpuLayers` | Number of GPU layers to offload (`0` = CPU only) | `0` |
| `llamacpp.contextSize` | Context window size | `2048` |
| `llamacpp.parallelSlots` | Number of parallel request slots | `1` |
| `llamacpp.threads` | Number of CPU threads to use for generation | `nil` |
| `llamacpp.mainGpu` | Index of the GPU to use as main GPU | `nil` |
| `llamacpp.flashAttn` | Enable flash attention (`on` to enable) | `nil` |
| `llamacpp.cacheRam` | Amount of KV cache to keep in CPU RAM in MiB | `nil` |
| `llamacpp.kvUnified` | Enable unified KV cache across sequences (`1` to enable) | `nil` |
| `llamacpp.extraEnv` | Additional arbitrary env vars to inject (key: value map) | `{}` |


#### Split model

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.split.mode` | How to split the model across GPUs (`none`, `layer`, `row`) | `nil` |
| `llamacpp.split.tensor` | Fraction of the model to offload to each GPU (comma-separated) | `nil` |

#### Cache type

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.cacheType.k` | KV cache quantization type for keys (e.g. `f16`, `q8_0`, `q4_0`) | `nil` |
| `llamacpp.cacheType.v` | KV cache quantization type for values (e.g. `f16`, `q8_0`, `q4_0`) | `nil` |

#### batching

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.batching.batch` | Logical maximum batch size | `nil` |
| `llamacpp.batching.ubatch` | Physical maximum batch size | `nil` |
| `llamacpp.batching.contBatching` | Enable continuous batching (`1` to enable) | `nil` |


#### Speculative Draft

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.speculativeDraft.type` | Speculative decoding type (e.g. `draft-mtp`) | `nil` |
| `llamacpp.speculativeDraft.draftNMax` | Maximum number of draft tokens to generate | `nil` |
| `llamacpp.speculativeDraft.draftPMin` | Minimum draft acceptance probability | `nil` |

#### Sampling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.sampling.temperature` | Sampling temperature | `nil` |
| `llamacpp.sampling.topP` | Top-P nucleus sampling threshold | `nil` |
| `llamacpp.sampling.topK` | Top-K sampling threshold | `nil` |
| `llamacpp.sampling.minP` | Min-P sampling threshold | `nil` |
| `llamacpp.sampling.repeatPenalty` | Penalize repeat sequence of tokens | `nil` |
| `llamacpp.sampling.presencePenalty` | Repeat alpha presence penalty | `nil` |
| `llamacpp.sampling.frequencyPenalty` | Repeat alpha frequency penalty | `nil` |

#### Reasoning

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.reasoning.enabled` | Toggle reasoning/thinking features | `nil` |
| `llamacpp.reasoning.format` | Reasoning format / thought parsing | `nil` |
| `llamacpp.reasoning.effort` | Reasoning effort level given to the chat template: 'default' to keep the template default | `nil` |
| `llamacpp.reasoning.budget` | Token budget for thinking: `-1` for unrestricted, `0` for immediate end, `N>0` for token budget | `nil` |
| `llamacpp.reasoning.budgetMessage` | Message injected before the end-of-thinking tag when reasoning budget is exhausted | `nil` |
| `llamacpp.reasoning.preserve` | preserve reasoning trace in the full history, not just the last assistant message | `nil` |

#### Embeddings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.embedding.enabled` | Restrict to only support embedding use case; use only with dedicated embedding models | `nil` |
| `llamacpp.embedding.pooling` | Pooling type for embeddings, use model default if unspecified | `nil` |

### Common configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas for the llama-server deployment | `1` |
| `image.repository` | Container image repository | `ghcr.io/ggml-org/llama.cpp` |
| `image.tag` | Image tag; defaults to chart `appVersion` when empty | `""` |
| `image.pullPolicy` | Image pull policy (`Always`, `IfNotPresent`, `Never`) | `IfNotPresent` |
| `imagePullSecrets` | List of image pull secrets | `[]` |
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full release name | `""` |
| `strategy` | Configuration for the deployment strategy | `{}` |
| `annotations` | Annotations for the Deployment resource | `{}` |

### Custom Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Wallabag image repository | `ghcr.io/ggml-org/llama.cpp` |
| `image.tag` | Wallabag image tag | Image tag; defaults to chart `appVersion` when empty |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.host` | Ingress host | `"llamacpp.example.com"` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls.enabled` | Enable TLS | `false` |
| `ingress.tls.host` | Overrides TLS host | `""` |
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

### Probes Configuration

#### Liveness Probe

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.enabled` | Enable or disable the liveness probe | `true` |
| `livenessProbe.httpGet.path` | Liveness probe HTTP path | `/health` |
| `livenessProbe.httpGet.port` | Liveness probe port name | `http` |
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
| `readinessProbe.enabled` | Enable or disable the liveness probe | `true` |
| `readinessProbe.httpGet.path` | Liveness probe HTTP path | `/health` |
| `readinessProbe.httpGet.port` | Liveness probe port name | `http` |
| `readinessProbe.httpGet.scheme` | Scheme for liveness probe | `"HTTP"` |
| `readinessProbe.initialDelaySeconds` | Initial delay for liveness probe | `nil` |
| `readinessProbe.periodSeconds` | Period for liveness probe | `nil` |
| `readinessProbe.timeoutSeconds` | Timeout for liveness probe | `nil` |
| `readinessProbe.successThreshold` | Success threshold for liveness probe | `nil` |
| `readinessProbe.failureThreshold` | Failure threshold for liveness probe | `nil` |

```yaml
readinessProbe:
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

### GPU resource

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gpu.vendor` | GPU vendor: `nvidia` or `amd` | `nil` |
| `gpu.runtimeClassName` | Pod runtime class name (defaults to `nvidia` if `gpu.vendor` is nvidia) | `nil` |
| `gpu.count` | Number of GPUs to allocate | `nil` |

## License

This Helm chart is released under the MIT License.
