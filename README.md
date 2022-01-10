# simple-php-builder
A docker image meant for building php applications, not intended for hosting in production.

## Building for multiple platforms
```shell
docker buildx build -t wildalaskan/simple-php-builder:latest --platform linux/arm64,linux/amd64 .
```
