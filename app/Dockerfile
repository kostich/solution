FROM golang:1.19 AS builder
WORKDIR /app
ARG CGO_ENABLED=0
COPY . .
RUN go test && go build

FROM scratch
WORKDIR /app
COPY --from=builder /app/test-app .
CMD ["/app/test-app"]
