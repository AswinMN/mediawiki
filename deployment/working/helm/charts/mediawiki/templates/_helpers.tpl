{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
*/}}
{{- define "mediawiki.fullname" -}}
{{- $name := default .Release.Name .Values.nameOverride -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default unique persistent volume claim name
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mediawiki.claimname" -}}
{{- $name := default .Release.Name .Values.persistence.claimName -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default service account name unless one is specified
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mediawiki.saname" -}}
{{- $name := default .Chart.Name .Values.rbac.serviceAccountName -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Helper function to combine registry authentication values into an appropriate Secret object
*/}}
{{- define "mediawiki.imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.registry.name (printf "%s:%s" .Values.registry.user .Values.registry.password | b64enc) | b64enc }}
{{- end }}

{{/*
Helper function to generate an appropriate $wgServer config value
*/}}
{{- define "mediawiki.wgServer" -}}
{{ if .Values.mediawiki.wgServer }}
      $wgServer = {{ .Values.mediawiki.wgServer | quote }};
{{- else if and .Values.ingress.enabled .Values.ingress.tls | and .Values.ingress.hosts }}
      $wgServer = {{ printf "https://%s" (index .Values.ingress.hosts 0).hostname | quote }};
{{- else if and .Values.ingress.enabled .Values.ingress.hosts }}
      $wgServer = {{ printf "http://%s" (index .Values.ingress.hosts 0).hostname | quote }};
{{- end }}
{{- end }}

{{/*
Helper function to build a backup user htpasswd
*/}}
{{- define "mediawiki.backupHtpasswd" -}}
{{ if and .Values.backups.www .Values.backups.www.enabled | and .Values.backups.www.basic | and .Values.backups.www.basic.password }}{{ .Values.backups.www.basic.password | b64enc | quote }}{{- else }}""{{- end }}
{{- end }}
