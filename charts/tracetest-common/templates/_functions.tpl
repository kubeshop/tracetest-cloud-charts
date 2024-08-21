{{- define "tracetest-common.postgres_dsn" -}}
{{- $global := .Values.global.postgresql.auth -}}
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
  {{- printf "postgresql://%s:%s@%s:%s/%s?%s" $global.username $global.password $global.host $global.port $global.dbname $options_str -}}
{{- else }}
  {{- printf "postgresql://%s:%s@%s:%s/%s" $global.username $global.password $global.host $global.port $global.dbname -}}
{{- end -}}
{{- end -}}

{{- define "tracetest-common.mongodb_dsn" -}}
{{- $global := .Values.global.mongodb.auth -}}
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
  {{- printf "%s://%s:%s@%s/%s?%s" $global.protocol $global.username $global.password $global.host $global.database $options_str -}}
{{- else }}
  {{- printf "%s://%s:%s@%s/%s" $global.protocol $global.username $global.password $global.host $global.database -}}
{{- end -}}
{{- end -}}

{{/*
Create a URI from a given object containing protocol, hostname, port, and path.
*/}}
{{- define "tracetest-common.url" -}}
{{- $protocol := default "http" .protocol }}
{{- $hostname := .hostname }}
{{- $port := default "80" .port }}
{{- $path := .path }}
{{- if and (or (and (eq $protocol "https") (eq $port "443")) (and (eq $protocol "http") (eq $port "80"))) }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "%s://%s:%s%s" $protocol $hostname $port $path }}
{{- end }}
{{- end }}

{{- define "tracetest-common.nats_endpoint" -}}
{{- if .Values.global.natsEndpointOverride }}
  {{- .Values.global.natsEndpointOverride }}
{{- else }}
  {{- $releaseName := .Release.Name -}}
  {{- $releaseNamespace := .Release.Namespace -}}
  {{- printf "nats://%s-nats.%s" $releaseName $releaseNamespace }}
{{- end }}
{{- end }}