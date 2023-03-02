# Docker

### Table of Content
* [Multi arch containers](#multi-arch-containers)
* [Links](#links)

## Multi arch containers
```
# Using manifests
docker pull --platform "linux/amd64" example_image:latest
docker tag example_image:latest example_image:amd64
docker push example_image:amd64

docker pull --platform "linux/arm64/v8" example_image:latest
docker tag example_image:latest example_image:arm64
docker push example_image:arm64

docker manifest create example_image:multi \
  example_image:amd64 \
  example_image:arm64

docker manifest push example_image:multi

docker manifest inspect example_image:multi
```

## Links

* [Docker build optimizations](https://www.augmentedmind.de/2022/02/06/optimize-docker-image-size/)