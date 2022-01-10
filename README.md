# simple-php-builder
A docker image meant for building php applications, not intended for hosting in production.

## Building for multiple platforms
```shell
docker buildx build -t wildalaskan/simple-php-builder:latest --platform linux/arm64,linux/amd64 .
```
Adding the `--push` flag will automatically push built versions if logged into the [WAC Docker Hub account](https://hub.docker.com/repository/docker/wildalaskan/simple-php-builder) 
locally.
```shell
docker buildx build -t wildalaskan/simple-php-builder:latest --platform linux/arm64,linux/amd64 --push .
```
