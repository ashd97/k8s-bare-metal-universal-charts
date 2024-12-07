{{- define "image.appName" -}}  # Defines a template function "image.appName" to extract the application name from the image path.
{{- $appNameVersion := regexReplaceAll "^.*/" .Values.projectApp.deployment.image "" -}}  # Removes everything before and including the last '/' from the image path to get the name with the version (e.g., "app:1.0.0").
{{- $appName := regexReplaceAll ":.*$" $appNameVersion "" | replace "/" "" -}}  # Removes the version and any ':' from the string to get only the application name (e.g., "app").
{{- $appName -}}  # Returns the extracted application name.
{{- end -}}  # Ends the "image.appName" template function.

{{- define "image.appVersion" -}}  # Defines a template function "image.appVersion" to extract the version from the image path.
{{- $appVersion := regexFind "[0-9]+\\.[0-9]+\\.[0-9]+" .Values.projectApp.deployment.image -}}  # Finds a semantic version (e.g., "1.0.0") in the image path using a regular expression.
{{- $appVersion -}}  # Returns the extracted version.
{{- end -}}  # Ends the "image.appVersion" template function.

{{- define "image.appReleaseType" -}}  # Defines a template function "image.appReleaseType" to determine the release type of the image.
{{- $appReleaseType := regexFind "^[^.]+\\b" .Values.projectApp.deployment.image -}}  # Finds the first part of the image path before any dots to identify the release type (e.g., "beta").
{{- $appReleaseType -}}  # Returns the extracted release type.
{{- end -}}  # Ends the "image.appReleaseType" template function.

{{- define "default.labels" }}  # Defines a template function "default.labels" to create default labels for Kubernetes resources.
app: {{ template "image.appName" . }}  # Sets the "app" label to the application name extracted using "image.appName".
Version: {{ template "image.appVersion" . }}  # Sets the "Version" label to the version extracted using "image.appVersion".
chart: {{ template "image.appName" . }}  # Sets the "chart" label to the application name again.
{{- end -}}  # Ends the "default.labels" template function.
