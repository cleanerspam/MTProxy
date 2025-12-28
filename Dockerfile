FROM golang:alpine AS builder

WORKDIR /app
RUN apk add --no-cache git make

RUN git clone https://github.com/9seconds/mtg.git .

ARG TARGETOS TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o mtg -ldflags "-s -w" .

FROM alpine:latest

RUN apk add --no-cache ca-certificates bash curl

WORKDIR /data
COPY --from=builder /app/mtg /usr/local/bin/mtg
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
