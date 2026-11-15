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
  --set llamacpp.model.model=/models/mistral-7b.gguf \
  --set llamacpp.nGpuLayers=32 \
  --set llamacpp.context.size=4096 \
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
| `llamacpp.existingConfigMap` | Name of an existing ConfigMap containing llama-server environment variables | `""` |
| `llamacpp.nGpuLayers` | Number of GPU layers to offload (`0` = CPU only) | `0` |
| `llamacpp.nCpuFfn` | Keep dense FFN weights of the first N layers in the CPU (non-MoE counterpart of `nCpuLayers`) | `nil` |
| `llamacpp.parallelSlots` | Number of parallel request slots | `1` |
| `llamacpp.alias` | Model name alias exposed in the API (comma-separated) | `nil` |
| `llamacpp.timeout` | Server read/write timeout in seconds | `nil` |
| `llamacpp.threadsHttp` | Number of threads used to process HTTP requests | `nil` |
| `llamacpp.nPredict` | Number of tokens to predict (`-1` = infinity) | `nil` |
| `llamacpp.perf` | Enable internal libllama performance timings (`1` to enable) | `nil` |
| `llamacpp.threads` | Number of CPU threads to use for generation | `nil` |
| `llamacpp.mainGpu` | Index of the GPU to use as main GPU | `nil` |
| `llamacpp.threadsBatch` | Number of threads for batch / prompt processing (default: same as threads) | `nil` |
| `llamacpp.numa` | NUMA optimization strategy (`distribute`, `isolate`, `numactl`) | `nil` |
| `llamacpp.rpc` | Comma-separated list of RPC servers (`host:port`) for distributed inference | `nil` |
| `llamacpp.flashAttn` | Enable flash attention (`on` to enable) | `nil` |
| `llamacpp.cacheRam` | Amount of KV cache to keep in CPU RAM in MiB | `nil` |
| `llamacpp.kvUnified` | Enable unified KV cache across sequences (`1` to enable) | `nil` |
| `llamacpp.extraEnv` | Additional arbitrary env vars to inject (key: value map) | `{}` |

#### Model loading

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.model.hf` | Hugging Face model repository | `nil` |
| `llamacpp.model.model` | Model path inside the container | `nil` |
| `llamacpp.model.modelUrl` | URL to download model from (direct download, alternative to `--hf-repo`) | `nil` |
| `llamacpp.model.hfFile` | HuggingFace model filename / glob pattern to select a specific GGUF file | `nil` |
| `llamacpp.model.mmproj` | Path to a multimodal projector file | `nil` |
| `llamacpp.model.mmprojUrl` | URL to download multimodal projector from | `nil` |
| `llamacpp.model.mmprojAuto` | Whether to use multimodal projector file if available, useful when using hf model (`1` = enabled / `0` = disabled) | `nil` |
| `llamacpp.model.overrideTensor` | Override tensor buffer type (e.g. `ATTN=CPU`) | `nil` |
| `llamacpp.model.loadMode` | Model loading mode (`auto`, `mmap`, `direct`) | `nil` |
| `llamacpp.model.lazyMode` | On-demand tensor reading per-layer (`auto`, `1`, `0`) | `nil` |
| `llamacpp.model.repack` | Whether to enable weight repacking (`1` = enabled / `0` = disabled) | `nil` |
| `llamacpp.model.modelsDir` | Directory to scan for GGUF model files (enables model listing endpoint) | `nil` |
| `llamacpp.model.modelsMax` | Maximum number of models loaded simultaneously | `nil` |
| `llamacpp.model.modelsMemoryMargin` | VRAM margin reserved for non-model use when auto-loading in MiB | `nil` |
| `llamacpp.model.modelsAutoload` | Auto-load models on first request (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.model.dockerRepo` | Docker Hub image repository used by the model router | `nil` |
| `llamacpp.model.tags` | Model tags to attach, comma-separated (used in model listing) | `nil` |
| `llamacpp.model.mmprojOffload` | Whether to offload the multimodal projector to GPU (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.model.imageMaxTokens` | Maximum number of image tokens to generate per image (`0` = from model) | `nil` |
| `llamacpp.model.imageMinTokens` | Minimum number of image tokens per image (`0` = from model) | `nil` |
| `llamacpp.model.mtmdBatchMaxTokens` | Maximum tokens in one multimodal batch (`0` = unlimited) | `nil` |

#### Context & memory

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.context.size` | Context window size | `4096` |
| `llamacpp.context.shift` | Enable context-shift when context is full (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.context.cachePrompt` | Enable KV cache reuse for identical prompt prefixes (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.context.cacheReuse` | Minimum number of prefix tokens to reuse from the KV cache | `nil` |
| `llamacpp.context.cacheIdleSlots` | Maximum number of idle slots whose KV cache to keep in memory (`-1` = all) | `nil` |
| `llamacpp.context.kvUnifiedPerSlot` | Unified KV cache size per slot in tokens (overrides `context.size` per slot) | `nil` |
| `llamacpp.context.kvOffload` | Whether to enable KV cache offloading to GPU (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.context.swaFull` | Use full-size SWA (Sliding Window Attention) cache (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.context.checkpoints` | Whether to enable context-state checkpoints for recompute (`1` = enable / `0` = disabled) | `nil` |
| `llamacpp.context.checkpointMinSpacingNt` | Minimum token spacing between context checkpoints | `nil` |
| `llamacpp.context.slotSavePath` | Path to save/restore slot state (KV cache) for resume support | `nil` |
| `llamacpp.context.ropeScalingType` | RoPE frequency scaling method (`none`, `linear`, `yarn`) | `nil` |
| `llamacpp.context.ropeScale` | RoPE context scaling factor, expands context by factor N | `nil` |
| `llamacpp.context.ropeFreqBase` | RoPE base frequency for NTK-aware scaling | `nil` |
| `llamacpp.context.ropeFreqScale` | RoPE frequency scaling factor, expands context by 1/N | `nil` |
| `llamacpp.context.yarnOrigCtx` | YaRN: original context size of the model (`0` = training context) | `nil` |
| `llamacpp.context.yarnExtFactor` | YaRN: extrapolation mix factor (`0` = full interpolation) | `nil` |
| `llamacpp.context.yarnAttnFactor` | YaRN: scale sqrt(t) or attention magnitude | `nil` |
| `llamacpp.context.yarnBetaSlow` | YaRN: high correction dim or alpha | `nil` |
| `llamacpp.context.yarnBetaFast` | YaRN: low correction dim or beta | `nil` |

#### Fit controls

| Parameter                | Description                                              | Default |
| ------------------------ | -------------------------------------------------------- | ------- |
| `llamacpp.fit.enabled`   | Auto-fit model to available VRAM (`on`, `off`)           | `nil`   |
| `llamacpp.fit.fitCtx`    | Target context size when using `--fit`                   | `nil`   |
| `llamacpp.fit.fitTarget` | Target VRAM usage ratio when using `--fit` (e.g. `0.90`) | `nil`   |

#### Split model

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.split.mode` | How to split the model across GPUs (`none`, `layer`, `row`, `tensor`) | `nil` |
| `llamacpp.split.tensor` | Fraction of the model to offload to each GPU (comma-separated) | `nil` |
| `llamacpp.split.device` | Comma-separated list of GPU devices to use for offloading | `nil` |

#### MoE (Mixture of Experts)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.moe.cpuOffload`    | Keep **all** MoE feed-forward weights in CPU RAM instead of VRAM (`1` to enable). Useful for large MoE models on GPUs with limited VRAM. | `nil`   |
| `llamacpp.moe.nCpuLayers`    | Keep MoE weights of the **first N layers** in CPU RAM. Provides granular VRAM/RAM split control.                                         | `nil`   |
| `llamacpp.moe.cacheMib`      | GPU cache size in MiB dedicated to frequently used MoE experts (`0` = disabled). Shared across GPUs in multi-GPU setups.                 | `nil`   |
| `llamacpp.moe.cacheCpuShare` | Share/ratio for MoE cache misses handled via CPU memory (float, e.g. `0.5`).                                                             | `nil`   |

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
| `llamacpp.speculativeDraft.draftModel` | Path to the draft model for speculative decoding | `nil` |
| `llamacpp.speculativeDraft.draftHfRepo` | HuggingFace repo for the draft model (`USER/MODEL[:Q]`) | `nil` |
| `llamacpp.speculativeDraft.draftNgl` | Number of draft model layers to store in VRAM | `nil` |
| `llamacpp.speculativeDraft.draftNMin` | Minimum number of draft tokens to use | `nil` |
| `llamacpp.speculativeDraft.draftNMax` | Maximum number of draft tokens to generate | `nil` |
| `llamacpp.speculativeDraft.draftPMin` | Minimum draft acceptance probability | `nil` |
| `llamacpp.speculativeDraft.draftNUbatch` | Physical max batch size for the draft context | `nil` |
| `llamacpp.speculativeDraft.draftPSplit` | Speculative decoding split probability | `nil` |
| `llamacpp.speculativeDraft.draftSampling` | How the draft is sampled (`greedy`, `probabilistic`) | `nil` |
| `llamacpp.speculativeDraft.draftBackendSampling` | Offload draft token sampling to the backend (`1` to enable) | `nil` |
| `llamacpp.speculativeDraft.draftCpuMoe` | Keep all MoE weights in CPU for the draft model (`1` to enable) | `nil` |
| `llamacpp.speculativeDraft.draftNCpuMoe` | Keep MoE weights of first N layers in CPU for the draft model | `nil` |
| `llamacpp.speculativeDraft.synthLen` | Target mean synthetic acceptance length (benchmarking only) | `nil` |
| `llamacpp.speculativeDraft.synthRates` | Per-position synthetic acceptance probabilities (benchmarking only) | `nil` |
| `llamacpp.speculativeDraft.cacheType.key` | KV cache quantization type for draft model keys | `nil` |
| `llamacpp.speculativeDraft.cacheType.value` | KV cache quantization type for draft model values | `nil` |

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

#### Web UI

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.webui.enabled` | Whether to enable the Web UI (`1` = enable, `0` = disabled) | `"0"` |
| `llamacpp.webui.uiConfig` | Inline JSON string of default Web UI preferences | `nil` |
| `llamacpp.webui.uiConfigFile` | Path to a JSON file of default Web UI preferences | `nil` |
| `llamacpp.webui.mcpProxy` | Expose an MCP proxy endpoint in the Web UI (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.webui.staticPath` | Path to serve static files from (Web UI assets) | `nil` |

#### MCP (Model Context Protocol)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.mcp.serversConfigFile` | Path to MCP servers JSON config file | `nil` |
| `llamacpp.mcp.serversJson` | Inline JSON string describing MCP servers to connect to | `nil` |

#### Networking

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.network.apiKeyFile` | File containing API keys for authentication (one per line) | `nil` |
| `llamacpp.network.apiPrefix` | Prefix path the server serves from, without trailing slash | `nil` |
| `llamacpp.network.connect` | Connect to a remote llama.cpp server instead of running locally (`HOST:PORT`) | `nil` |
| `llamacpp.network.connectCode` | Authentication code for `--connect` | `nil` |
| `llamacpp.network.sslCertFile` | Path to the PEM-encoded TLS certificate file | `nil` |
| `llamacpp.network.sslKeyFile` | Path to the PEM-encoded TLS private key file | `nil` |
| `llamacpp.network.corsOrigins` | Allowed CORS origins, comma-separated (default: `*`) | `nil` |
| `llamacpp.network.corsHeaders` | Allowed CORS headers | `nil` |
| `llamacpp.network.corsMethods` | Allowed CORS methods | `nil` |
| `llamacpp.network.corsCredentials` | Whether to allow CORS credentials (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.network.reusePort` | Enable SO_REUSEPORT so multiple instances can bind the same port (`1` to enable) | `nil` |
| `llamacpp.network.noHost` | Bypass host buffer, allowing extra buffers to be used (`1` to enable) | `nil` |
| `llamacpp.network.ssePingInterval` | Interval between SSE keep-alive pings in seconds | `nil` |
| `llamacpp.network.offline` | Disable any network access: HF downloads, model router, etc. (`1` to enable) | `nil` |

#### Logging

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.logging.verbosity` | Log verbosity level: `-1` = error, `0` = info (default), `1` = debug, `2` = trace | `nil` |
| `llamacpp.logging.file` | Path to write log output to a file | `nil` |
| `llamacpp.logging.jsonl` | Output logs in JSONL format (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.logging.colors` | Use ANSI colors in log output (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.logging.prefix` | Add a module/function prefix to log lines (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.logging.timestamps` | Add timestamps to log lines (`1` = enable, `0` = disabled) | `nil` |

#### Endpoints

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.endpoints.metrics` | Enable or disable the `/metrics` (Prometheus) endpoint (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.endpoints.slots` | Enable or disable the `/slots` endpoint (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.endpoints.props` | Enable or disable the `/props` endpoint (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.endpoints.reranking` | Enable the `/rerank` endpoint for cross-encoder reranking (`1` to enable) | `nil` |

#### Chat template & tool use

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.tools.chatTemplate` | Custom Jinja2 chat template string (default: taken from model metadata) | `nil` |
| `llamacpp.tools.chatTemplateFile` | Path to a file containing a custom Jinja2 chat template | `nil` |
| `llamacpp.tools.chatTemplateKwargs` | Extra `key=value` pairs passed to the Jinja2 template renderer | `nil` |
| `llamacpp.tools.jinja` | Whether to use the Jinja2 template engine for chat (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.tools.skipChatParsing` | Force pure content parser, disables reasoning/tool extraction (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.tools.prefillAssistant` | Whether to prefill assistant response from last assistant message (`1` = enable, `0` = disabled) | `nil` |
| `llamacpp.tools.tools` | Comma-separated list of tool names or JSON tool definitions to expose | `nil` |
| `llamacpp.tools.toolsRuntime` | Tool calling runtime (e.g. `native`, `python`) | `nil` |
| `llamacpp.tools.agent` | Agentic loop configuration (tool use automation) | `nil` |

#### Video

| Parameter | Description | Default |
|-----------|-------------|---------|
| `llamacpp.video.ffmpegDir` | Path to ffmpeg binaries for video frame extraction | `nil` |
| `llamacpp.video.fps` | Frames per second to extract from video inputs (default: 1) | `nil` |
| `llamacpp.video.timestampInterval` | Interval in seconds between frame timestamps in prompts | `nil` |

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

### Presets Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `presets.enabled` | Enable model presets configuration | `false` |
| `presets.existingConfigMap` | Name of an existing ConfigMap containing presets.ini | `""` |
| `presets.default` | Global default options applied to all preset models (`[*]` section) | `{}` |
| `presets.models` | Map of model presets with model names as sections and parameter maps as values | `{}` |
| `presets.rawContent` | Raw INI content for presets (takes precedence over `default` and `models`) | `""` |

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
