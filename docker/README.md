# Docker

### Table of Content
* [Commands](#commands)
* [Multi arch containers](#multi-arch-containers)
* [Links](#links)

## Commands
```bash
docker history image_id --format "{{.CreatedBy}}" --no-trunc > history.csv
docker history image_id --format "table{{.ID}}, {{.CreatedBy}}" --no-trunc > history.csv
```

## Multi arch containers
```bash
# Using manifests
container_image="example_image:latest"
private_registry="input_here"
manifest_tag="multi"

docker pull --platform "linux/amd64" "$container_image"
docker tag "$container_image" "$private_registry":amd64
docker push "$private_registry":amd64

docker pull --platform "linux/arm64/v8" "$container_image"
docker tag "$container_image" "$private_registry":arm64
docker push "$private_registry":arm64

docker manifest create "$private_registry":"$manifest_tag" \
  "$private_registry":amd64 \
  "$private_registry":arm64

docker manifest push "$private_registry":"$manifest_tag"

docker manifest inspect "$private_registry":"$manifest_tag"
```

## Links

* [Docker build optimizations](https://www.augmentedmind.de/2022/02/06/optimize-docker-image-size/)
* [Docker context Explanations]
  * [Article 1](https://www.howtogeek.com/devops/how-to-use-multiple-docker-build-contexts-to-streamline-image-assembly/)
  * [Article 1](https://www.docker.com/blog/dockerfiles-now-support-multiple-build-contexts/)
* [Docker compose general guide](https://gabrieltanner.org/blog/docker-compose/)
* [Local registry commands](https://stackoverflow.com/questions/31251356/how-to-get-a-list-of-images-on-docker-registry-v2)
