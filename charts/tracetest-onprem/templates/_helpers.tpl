{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tracetest-onprem.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tracetest-onprem.labels" -}}
helm.sh/chart: {{ include "tracetest-onprem.chart" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: tracetest-onprem
{{- end }}
