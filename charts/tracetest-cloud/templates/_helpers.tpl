{{/*
Expand the name of the chart.
*/}}
{{- define "tracetest-cloud.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "tracetest-cloud.postgres_dsn" -}}
{{- $global := .Values.global.postgres -}}
{{- $options := $global.options | default dict -}}
{{- $options_str := "" -}}
{{- range $key, $value := $options -}}
  {{- if $options_str }}
    {{- $options_str = printf "%s&%s=%s" $options_str $key $value -}}
  {{- else }}
    {{- $options_str = printf "%s=%s" $key $value -}}
  {{- end -}}
{{- end -}}
{{- if $options_str }}
  {{- printf "postgresql://%s:%s@%s/%s?%s" $global.user $global.password $global.host $global.dbname $options_str -}}
{{- else }}
  {{- printf "postgresql://%s:%s@%s/%s" $global.user $global.password $global.host $global.dbname -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tracetest-cloud.fullname" -}}
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
{{- define "tracetest-cloud.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tracetest-cloud.labels" -}}
helm.sh/chart: {{ include "tracetest-cloud.chart" . }}
{{ include "tracetest-cloud.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tracetest-cloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tracetest-cloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}