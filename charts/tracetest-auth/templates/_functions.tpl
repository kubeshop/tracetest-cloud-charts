{{- define "tracetest-auth.kratos_postgres_dsn" -}}
{{- $defaultDSN := include "tracetest-common.postgres_dsn" . }}
{{- $config := (default (dict) .Values.config ) }}
{{- $dsn := dig "kratos" "postgresDsnOverride" $defaultDSN $config }}
{{- printf $dsn }}
{{- end -}}

{{- define "tracetest-auth.keto_postgres_dsn" -}}
{{- $defaultDSN := include "tracetest-common.postgres_dsn" . }}
{{- $config := (default (dict) .Values.config ) }}
{{- $dsn := dig "keto" "postgresDsnOverride" $defaultDSN $config }}
{{- printf $dsn }}
{{- end -}}