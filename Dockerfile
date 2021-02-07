FROM golang:1.13-alpine AS build_deps

RUN apk add --no-cache git alpine-sdk wget make python2 python2-dev
RUN wget https://launchpad.net/bzr/2.7/2.7.0/+download/bzr-2.7.0.tar.gz && \
    tar -xf bzr-2.7.0.tar.gz && \
    cd bzr-2.7.0/ && \
    python setup.py install

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.9

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

ENTRYPOINT ["webhook"]
