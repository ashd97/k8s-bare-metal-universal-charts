{{- define "default.labels" }}
app: {{ .Chart.Name }}
version: v1.18
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
