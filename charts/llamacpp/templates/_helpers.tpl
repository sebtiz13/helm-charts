{{/*
Expand the name of the chart.
*/}}
{{- define "llamacpp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains the chart name it will be used as a full name.
*/}}
{{- define "llamacpp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "llamacpp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "llamacpp.labels" -}}
helm.sh/chart: {{ include "llamacpp.chart" . }}
{{ include "llamacpp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
RuntimeClassName resolution.
Can be explicitly set via .Values.gpu.runtimeClassName,
or defaults according to .Values.gpu.vendor:
  nvidia → nvidia
*/}}
{{- define "llamacpp.runtimeClassName" -}}
{{- if .Values.gpu -}}
{{- if .Values.gpu.runtimeClassName -}}
  {{- .Values.gpu.runtimeClassName -}}
{{- else if eq (default "" .Values.gpu.vendor) "nvidia" -}}
  nvidia
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Image tag resolution.
Defaults to server-<AppVersion>, or server-cuda-<AppVersion> if runtimeClassName is nvidia.
*/}}
{{- define "llamacpp.imageTag" -}}
{{- if .Values.image.tag -}}
  {{- .Values.image.tag -}}
{{- else -}}
  {{- if eq (include "llamacpp.runtimeClassName" .) "nvidia" -}}
    {{- printf "server-cuda-%s" .Chart.AppVersion -}}
  {{- else -}}
    {{- printf "server-%s" .Chart.AppVersion -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "llamacpp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llamacpp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
GPU resource limits and requests.
Resolves the vendor-specific resource key from .Values.gpu.vendor:
  nvidia → nvidia.com/gpu
  amd    → amd.com/gpu
Rendered as a full resources block (limits + requests) so it can be
merged with the user-supplied .Values.resources via the deployment template.
Usage: {{ include "llamacpp.gpuResources" . }}
*/}}
{{- define "llamacpp.gpuResources" -}}
{{- if .Values.gpu }}
{{- $vendor := .Values.gpu.vendor | required "gpu.vendor is required when gpu is set (nvidia or amd)" -}}
{{- $count  := .Values.gpu.count  | required "gpu.count is required when gpu is set" | toString -}}
{{- $key := "" -}}
{{- if eq $vendor "nvidia" -}}
  {{- $key = "nvidia.com/gpu" -}}
{{- else if eq $vendor "amd" -}}
  {{- $key = "amd.com/gpu" -}}
{{- else -}}
  {{- fail (printf "gpu.vendor must be 'nvidia' or 'amd', got: %s" $vendor) -}}
{{- end -}}
limits:
  {{ $key }}: {{ $count }}
requests:
  {{ $key }}: {{ $count }}
{{- end -}}
{{- end -}}

{{/*
Generate a probe configuration
*/}}
{{- define "llamacpp.probe" -}}
{{- $httpGet := .httpGet | default dict -}}
  httpGet:
    path: {{ $httpGet.path | default "/health" }}
    port: {{ $httpGet.port | default "http" }}
    {{- if $httpGet.scheme }}
    scheme: {{ $httpGet.scheme }}
    {{- end }}
{{- if .initialDelaySeconds }}
  initialDelaySeconds: {{ .initialDelaySeconds }}
{{- end }}
{{- if .periodSeconds }}
  periodSeconds: {{ .periodSeconds }}
{{- end }}
{{- if .timeoutSeconds }}
  timeoutSeconds: {{ .timeoutSeconds }}
{{- end }}
{{- if .successThreshold }}
  successThreshold: {{ .successThreshold }}
{{- end }}
{{- if .failureThreshold }}
  failureThreshold: {{ .failureThreshold }}
{{- end }}
{{- end -}}
