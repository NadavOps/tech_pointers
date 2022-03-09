Bash
===========

<!--ts-->
  * [Examples](#examples)
  * [13 Best Practices for using Helm](#13-best-practices-for-using-helm)
  * [Links](#links)
<!--te-->

Examples
====
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

13 Best Practices for using Helm
====
* [13 Best Practices for using Helm](https://codersociety.com/blog/articles/helm-best-practices).
  * [Subcharts](https://codersociety.com/blog/articles/helm-best-practices#2-use-subcharts-to-manage-your-dependencies).
  * [Resource deletion protection](https://codersociety.com/blog/articles/helm-best-practices#9-opt-out-of-resource-deletion-with-resource-policies).

Links
====
* [13 Best Practices for using Helm](https://codersociety.com/blog/articles/helm-best-practices).
* [Go template language](https://pkg.go.dev/text/template)
* [Spring template library](https://masterminds.github.io/sprig/)
* [Lookup as a way to skip resource creation](https://stackoverflow.com/questions/57909821/how-to-tell-helm-to-not-create-change-resource-if-it-already-exists)
