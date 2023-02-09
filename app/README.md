# What

Small test app that returns some data when queried via HTTP.

## How

## Build

```bash
docker build -t test-app:$(git rev-parse --short HEAD) .
```

## Run

```bash
docker run -d test-app:$(git rev-parse --short HEAD)
```

## Use

```bash
curl localhost:8080
```
