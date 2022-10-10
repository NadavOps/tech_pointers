# Git

### Table of Content
* [Github actions](#git-actions)
  * [Rest APIs](#rest-apis)
  * [Workflows](#workflows)
* [Links](#links)

## Github actions
## Rest APIs

## Workflows
Get OIDC JWT token to output for debugging purposes
```
      - name: Dump JWT
        run: |
          IDTOKEN=$(curl -s -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com"|jq -r ".|.value")
          echo $IDTOKEN
          jwtd() {
              if [[ -x $(command -v jq) ]]; then
                  jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "${1}"
                  echo "Signature: $(echo "${1}" | awk -F'.' '{print $3}')"
              fi
          }
          jwtd $IDTOKEN
          echo "::set-output name=idToken::${IDTOKEN}"
```

Delete Workflows or just the logs
```
## Set params
gh_owner_name=""
gh_repo_name=""
gh_token=""

# https://docs.github.com/en/rest/actions/workflow-runs#list-workflow-runs-for-a-repository
## Delete all workflows run logs (runs will remian without the logs)
for workflow_id in $(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $gh_token" \
  "https://api.github.com/repos/$gh_owner_name/$gh_repo_name/actions/runs?per_page=100" | jq -r ".workflow_runs[].id" | sort -u); do
    echo "$workflow_id"
    curl -s\
      -X DELETE \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $gh_token" \
      https://api.github.com/repos/$gh_owner_name/g$gh_repo_name/actions/runs/$workflow_id/logs
done

## Delete all workflows runs
for workflow_id in $(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $gh_token" \
  "https://api.github.com/repos/$gh_owner_name/$gh_repo_name/actions/runs?per_page=100" | jq -r ".workflow_runs[].id" | sort -u); do
    echo "$workflow_id"
    curl -s \
      -X DELETE \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $gh_token" \
      https://api.github.com/repos/$gh_owner_name/$gh_repo_name/actions/runs/$workflow_id
done
```

## Links

* [Set multiple ssh keys for multiple github accounts](https://gist.github.com/jexchan/2351996).
* [Good oidc sketch for github actions](https://blog.codecentric.de/secretless-connections-from-github-actions-to-aws-using-oidc).
* [Github actions tips for triggers and more](https://yonatankra.com/7-github-actions-tricks-i-wish-i-knew-before-i-started/).
* [differences between composite action and reuseable workflow](https://dev.to/n3wt0n/composite-actions-vs-reusable-workflows-what-is-the-difference-github-actions-11kd#:%7E:text=With%20Reusable%20workflows%20you%20have,if%20it%20contains%20multiple%20steps.)

composite actions:
https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#runs-for-composite-actions