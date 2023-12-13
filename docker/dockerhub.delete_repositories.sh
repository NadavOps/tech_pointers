#!/bin/bash
DOCKER_USERNAME="change_here"
DOCKER_PASSWORD="change_here"
DOCKER_NAMESPACE="change_here"
DOCKER_ORG="change_here"

REQUEST_BODY="{\"username\":\"$DOCKER_USERNAME\",\"password\":\"$DOCKER_PASSWORD\"}"
TOKEN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$REQUEST_BODY" "https://hub.docker.com/v2/users/login")
DOCKER_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r .token)

PRIVATE_REPOS=( $(curl -s -H "Authorization: Bearer $DOCKER_TOKEN" "https://hub.docker.com/v2/namespaces/$DOCKER_NAMESPACE/repositories/" | jq -r '.results[] | select(.is_private == true) | .name') )
for repo in "${PRIVATE_REPOS[@]}"; do
    echo "delete repo: $repo. approve"
    read
    echo curl -X DELETE -s -H "Authorization: JWT ${DOCKER_TOKEN}" "https://hub.docker.com/v2/repositories/$DOCKER_NAMESPACE/$repo"
done

MORE_PRIVATE_REPOS=( $(curl -s -H "Authorization: JWT ${DOCKER_TOKEN}" "https://hub.docker.com/v2/repositories/$DOCKER_ORG?page_size=500" | jq -r '.results[] | select(.is_private == true) | .name') )
for repo in "${MORE_PRIVATE_REPOS[@]}"; do
    echo "delete repo: $repo. approve"
    read
    echo curl -X DELETE -s -H "Authorization: JWT ${DOCKER_TOKEN}" "https://hub.docker.com/v2/repositories/$DOCKER_ORG/$repo"
done
