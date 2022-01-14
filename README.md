# simple-php-builder
A docker image meant for building php applications, not intended for hosting in production.

## Building for multiple platforms
```shell
docker buildx build -t wildalaskan/simple-php-builder:latest --platform linux/arm64,linux/amd64 .
```

#### Note

If you're receiving an error like:

`error: multiple platforms feature is currently not supported for docker driver. Please switch to a different driver (eg. "docker buildx create --use")
`

Then you'll need to create a new builder and use it:

```
docker buildx create --name multibuilder
docker buildx use multibuilder
```

Then you can proceed with building for multiple platforms using the command above.
