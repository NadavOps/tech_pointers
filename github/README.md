# Github

### Table of Content
* [Github keys](#github-keys)
* [Github actions](#github-actions)
  * [Rest APIs](#rest-apis)
  * [Workflows](#workflows)
  * [Useful built in env vars](#useful-built-in-env-vars)
* [Links](#links)

## Github keys
```
ssh-keygen -t rsa -b 4096
git config --global user.signingkey ~/.ssh/key_name.pub
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

## Github actions
## Rest APIs

## Workflows

```
# Get OIDC JWT token to output for debugging purposes
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

```
## Dispatch/ trigger a workflow
gh_owner_name=""
gh_repo_name=""
gh_token=""
workflow_filename=""
branch_name=""

curl -s \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $gh_token" \
  "https://api.github.com/repos/$gh_owner_name/$gh_repo_name/actions/workflows/$workflow_filename/dispatches" \
  -d '{"ref":"'$branch_name'","inputs":{"name":"Mona the Octocat","home":"San Francisco, CA"}}'
```

## Useful built in env vars
```
$GITHUB_EVENT_PATH -> path to a local run file with the event information
$GITHUB_TRIGGERING_ACTOR -> the one triggered the action
  to set him in git we can use the following:
     git config user.email "${GITHUB_TRIGGERING_ACTOR}@users.noreply.github.com"
     git config user.name "$GITHUB_TRIGGERING_ACTOR"
$GITHUB_CONTEXT -> context of the run
  can be set like so:
    env: 
      GITHUB_CONTEXT: ${{ toJson(github) }}
    steps:
      - name: Git github context
        run: |
          echo context: $GITHUB_CONTEXT
```

## Links

* [Set multiple ssh keys for multiple github accounts](https://gist.github.com/jexchan/2351996).
* [Good oidc sketch for github actions](https://blog.codecentric.de/secretless-connections-from-github-actions-to-aws-using-oidc).
* [Github actions tips for triggers and more](https://yonatankra.com/7-github-actions-tricks-i-wish-i-knew-before-i-started/).
* [differences between composite action and reuseable workflow](https://dev.to/n3wt0n/composite-actions-vs-reusable-workflows-what-is-the-difference-github-actions-11kd#:%7E:text=With%20Reusable%20workflows%20you%20have,if%20it%20contains%20multiple%20steps.)
* [Helped me understand how to share multiple actions](https://dev.to/robmulpeter/getting-started-with-github-action-workflows-3ehn)
* Mail and gpg
  * [gpg](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key?platform=mac)
  * [set noreply email](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address)
  * [ssh signing](https://dev.to/li/correctly-telling-git-about-your-ssh-key-for-signing-commits-4c2c)
* OIDC solution for github runner and AWS
  * [Explanation](https://www.jerrychang.ca/writing/security-harden-github-actions-deployments-to-aws-with-oidc)
  * [assuming a role using a role behind API gateway](https://github.com/glassechidna/ghaoidc)
* [Awsome runner solutions](https://github.com/jonico/awesome-runners)
  * [Most used](https://github.com/actions-runner-controller/actions-runner-controller)

composite actions:
https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#runs-for-composite-actions