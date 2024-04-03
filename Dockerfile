# Build image
FROM debian:12 AS tor
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y apt-transport-https wget gnupg tor

FROM golang:1.20-bookworm as build
WORKDIR /src
COPY go.* /src/
RUN go mod download
COPY . /src/
ENV SKIP_FORWARDING_TESTS=1
RUN make all test

# Deploy image
FROM tor
RUN useradd --create-home -d /data -s /bin/bash onionpipe
COPY --from=build /src/onionpipe /onionpipe
VOLUME [ "/data" ]
WORKDIR /data
USER onionpipe
ENTRYPOINT [ "/onionpipe" ]
