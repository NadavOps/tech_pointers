# Helm

### Table of Content
* [Commands](#commands)
* [Examples](#examples)
* [Code Snippets](#code-snippets)
* [13 Best Practices for using Helm](#13-best-practices-for-using-helm)
* [Links](#links)

## Commands
helm search repo <reponame>/<chartname> --versions     --> show available version for a chart

## Examples
* Defining variables
* Compare operator
* Built-in Functions -> fail with printf inside of it
```
{{- $NAME := .Values.Name -}}
{{- $NAME_LENGTH := len $NAME -}}
{{- $NAME_MAX_LENGTH := 20 -}}
{{- if gt $NAME_LENGTH $NAME_MAX_LENGTH -}}
  {{ fail (printf "Value for %s should be less or equal to %d" $NAME_LENGTH $NAME_MAX_LENGTH) }}
{{- end -}}
```

## Code Snippets
```bash
# Delete releases based on their prefix
prefix_of_releases_to_delete="CHANGE_HERE"
json_output=$(helm ls -A --no-headers -f $prefix_of_releases_to_delete --output json)

echo "$json_output" | jq -r '.[] | "\(.namespace) \(.name)"' | while read -r namespace name; do
    helm uninstall -n$namespace $name
done
```

## 13 Best Practices for using Helm
* [13 Best Practices for using Helm](https://codersociety.com/blog/articles/helm-best-practices).
  * [Subcharts](https://codersociety.com/blog/articles/helm-best-practices#2-use-subcharts-to-manage-your-dependencies).
  * [Resource deletion protection](https://codersociety.com/blog/articles/helm-best-practices#9-opt-out-of-resource-deletion-with-resource-policies).

## Links
* [13 Best Practices for using Helm](https://codersociety.com/blog/articles/helm-best-practices).
* [Go template language](https://pkg.go.dev/text/template)
  * [Helm template cheat sheet](https://lzone.de/cheat-sheet/Helm%20Templates)
* [Spring template library](https://masterminds.github.io/sprig/)
* [Lookup as a way to skip resource creation](https://stackoverflow.com/questions/57909821/how-to-tell-helm-to-not-create-change-resource-if-it-already-exists)
