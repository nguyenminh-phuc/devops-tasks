{{/*
Expand the name of the chart.
*/}}
{{- define "processed-kconsumer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "processed-kconsumer.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "processed-kconsumer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "processed-kconsumer.labels" -}}
helm.sh/chart: {{ include "processed-kconsumer.chart" . }}
{{ include "processed-kconsumer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "processed-kconsumer.metricLabels" -}}
{{ include "processed-kconsumer.labels" . }}
shortener/service-type: metrics
{{- end }}

{{/*
Selector labels
*/}}
{{- define "processed-kconsumer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "processed-kconsumer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "processed-kconsumer.selectorMetricLabels" -}}
{{ include "processed-kconsumer.selectorLabels" . }}
shortener/service-type: metrics
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "processed-kconsumer.serviceAccountName" -}}
{{- include "processed-kconsumer.fullname" . }}
{{- end }}
