{{/*
Expand the name of the chart.
*/}}
{{- define "wallabag.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "wallabag.fullname" -}}
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
{{- define "wallabag.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "wallabag.labels" -}}
helm.sh/chart: {{ include "wallabag.chart" . }}
{{ include "wallabag.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "wallabag.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallabag.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Generate database credentials values
*/}}
{{- define "wallabag.db-credentials" -}}
SYMFONY__ENV__DATABASE_NAME: {{ .database | b64enc | quote }}
SYMFONY__ENV__DATABASE_USER: {{ .username | b64enc | quote }}
SYMFONY__ENV__DATABASE_PASSWORD: {{ .password | default "" | b64enc | quote }}
{{- end -}}

{{/*
Generate database configuration values
*/}}
{{- define "wallabag.db-config" -}}
{{- $driver := .driver | default "pdo_mysql" -}}
{{- $defaultPort := .port | default (ternary 5432 3306 (eq $driver "pdo_pgsql")) -}}
{{- if eq $driver "pdo_mysql" }}
SYMFONY__ENV__DATABASE_CHARSET: utf8mb4
{{- else }}
SYMFONY__ENV__DATABASE_CHARSET: utf8
{{- end }}
SYMFONY__ENV__DATABASE_DRIVER: {{ $driver | quote }}
SYMFONY__ENV__DATABASE_PORT: {{ $defaultPort | int | quote }}
{{- end -}}

{{/*
Generate redis credentials
*/}}
{{- define "wallabag.redis-credentials" -}}
SYMFONY__ENV__REDIS_PORT: {{ .port | default 6379 | int | b64enc | quote }}
SYMFONY__ENV__REDIS_PASSWORD: {{ .password | default "" | b64enc | quote }}
{{- end -}}

{{/*
Return the database type to use (postgresql, mariadb or external)
*/}}
{{- define "wallabag.database-type" -}}
{{- if .Values.postgresql.enabled -}}
{{- "postgresql" -}}
{{- else if .Values.mariadb.enabled -}}
{{- "mariadb" -}}
{{- else -}}
{{- "external" -}}
{{- end -}}
{{- end -}}

{{/*
Check if wallabag database admin password should be used
*/}}
{{- define "wallabag.use-db-admin" -}}
{{- $dbType := include "wallabag.database-type" . -}}
{{- if and (eq $dbType "postgresql") .Values.postgresql.auth.postgresPassword -}}
  true
{{- else if and (eq $dbType "mariadb") .Values.mariadb.auth.rootPassword -}}
  true
{{- else if and (eq $dbType "external") .Values.externalDatabase.rootPassword -}}
  true
{{- end -}}
{{- end -}}
