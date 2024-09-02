{{/*
Expand the name of the chart.
*/}}
{{- define "pokeshop-demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pokeshop-demo.fullname" -}}
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
{{- define "pokeshop-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels (Pokeshop)
*/}}
{{- define "pokeshop-demo.labels" -}}
helm.sh/chart: {{ include "pokeshop-demo.chart" . }}
{{ include "pokeshop-demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (Pokeshop)
*/}}
{{- define "pokeshop-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pokeshop-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels (API)
*/}}
{{- define "pokeshop-demo.api.labels" -}}
helm.sh/chart: {{ include "pokeshop-demo.chart" . }}
{{ include "pokeshop-demo.api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (API)
*/}}
{{- define "pokeshop-demo.api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pokeshop-demo.name" . }}-api
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels (Queue Worker)
*/}}
{{- define "pokeshop-demo.queueworker.labels" -}}
helm.sh/chart: {{ include "pokeshop-demo.chart" . }}
{{ include "pokeshop-demo.queueworker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (Queue Worker)
*/}}
{{- define "pokeshop-demo.queueworker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pokeshop-demo.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels (Stream)
*/}}
{{- define "pokeshop-demo.stream.labels" -}}
helm.sh/chart: {{ include "pokeshop-demo.chart" . }}
{{ include "pokeshop-demo.stream.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (Stream)
*/}}
{{- define "pokeshop-demo.stream.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pokeshop-demo.name" . }}-stream
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels (Stream Worker)
*/}}
{{- define "pokeshop-demo.streamworker.labels" -}}
helm.sh/chart: {{ include "pokeshop-demo.chart" . }}
{{ include "pokeshop-demo.streamworker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (Stream Worker)
*/}}
{{- define "pokeshop-demo.streamworker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pokeshop-demo.name" . }}-streamworker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels (Tracetest Agent)
*/}}
{{- define "pokeshop-demo.tracetestAgent.labels" -}}
helm.sh/chart: {{ include "pokeshop-demo.chart" . }}
{{ include "pokeshop-demo.tracetestAgent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (Tracetest Agent)
*/}}
{{- define "pokeshop-demo.tracetestAgent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pokeshop-demo.name" . }}-agent
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
