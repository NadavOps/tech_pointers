# Trivy

### Table of Content
* [Commands](#commands)

## Commands
```bash
## To get specifics severities
trivy -q image --severity HIGH,CRITICAL image_name

## To get only the summary for container scan
trivy -q image --format template --template '{{- $critical := 0 }}{{- $high := 0 }}{{- $medium := 0 }}{{- $low := 0 }}{{- $unknown := 0 }}{{- range . }}{{- range .Vulnerabilities }}{{- if eq .Severity "CRITICAL" }}{{- $critical = add $critical 1 }}{{- end }}{{- if eq .Severity "HIGH" }}{{- $high = add $high 1 }}{{- end }}{{- if eq .Severity "MEDIUM" }}{{- $medium = add $medium 1 }}{{- end }}{{- if eq .Severity "LOW" }}{{- $low = add $low 1 }}{{- end }}{{- if eq .Severity "UNKNOWN" }}{{- $unknown = add $unknown 1 }}{{- end }}{{- end }}{{- end }}Total: {{ add (add (add (add $critical $high) $medium) $low) $unknown }}, Critical: {{ $critical }}, High: {{ $high }}, Medium: {{ $medium }}, Low: {{ $low }}, Unknown: {{ $unknown }}' image_name
```

## Links
