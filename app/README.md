# What

Small test app that returns some data when queried via HTTP.

## How to use it locally

---
### Build

```bash
docker build -t test-app:$(git rev-parse --short HEAD) .
```
---
### Run

```bash
docker run -e HTTP_PORT=80 -p 8080:80 -d test-app:$(git rev-parse --short HEAD)
```
---
### Use

```bash
curl localhost:8080
```
