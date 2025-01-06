{{/*
Expand the name of the chart.
*/}}
{{- define "raw-kconsumer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "raw-kconsumer.fullname" -}}
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
{{- define "raw-kconsumer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "raw-kconsumer.labels" -}}
helm.sh/chart: {{ include "raw-kconsumer.chart" . }}
{{ include "raw-kconsumer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "raw-kconsumer.metricLabels" -}}
{{ include "raw-kconsumer.labels" . }}
shortener/service-type: metrics
{{- end }}

{{/*
Selector labels
*/}}
{{- define "raw-kconsumer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "raw-kconsumer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "raw-kconsumer.selectorMetricLabels" -}}
{{ include "raw-kconsumer.selectorLabels" . }}
shortener/service-type: metrics
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "raw-kconsumer.serviceAccountName" -}}
{{- include "raw-kconsumer.fullname" . }}
{{- end }}
