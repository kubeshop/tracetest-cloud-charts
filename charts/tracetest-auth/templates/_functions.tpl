{{- define "tracetest-auth.kratos_postgres_dsn" -}}
{{- if .Values.config.kratos.postgresDsnOverride }}
  {{- .Values.config.kratos.postgresDsnOverride }}
{{- else }}
  {{ include "tracetest-common.postgres_dsn" }
{{- end -}}
{{- end -}}

{{- define "tracetest-auth.keto_postgres_dsn" -}}
{{- if .Values.config.keto.postgresDsnOverride }}
  {{- .Values.config.keto.postgresDsnOverride }}
{{- else }}
  {{ include "tracetest-common.postgres_dsn" }
{{- end -}}
{{- end -}}