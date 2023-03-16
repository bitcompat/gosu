# syntax=docker/dockerfile:1.4
FROM golang:1.20-bullseye AS golang-builder

ARG PACKAGE=gosu
ARG TARGET_DIR=common
# renovate: datasource=github-releases depName=tianon/gosu
ARG VERSION=1.14.0
ARG REF=1.14
ARG CGO_ENABLED=0

RUN mkdir -p /opt/bitnami
RUN --mount=type=cache,target=/root/.cache/go-build <<EOT /bin/bash
    set -ex

    rm -rf ${PACKAGE} || true
    mkdir -p ${PACKAGE}
    git clone -b "${REF}" https://github.com/tianon/gosu ${PACKAGE}

    pushd ${PACKAGE}
    go mod download
    go build -v -ldflags '-d -s -w' .

    mkdir -p /opt/bitnami/${TARGET_DIR}/licenses
    mkdir -p /opt/bitnami/${TARGET_DIR}/bin
    cp -f LICENSE /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.txt
    echo "gosu-${VERSION},GPL3,https://github.com/tianon/gosu/archive/${REF}.tar.gz" > /opt/bitnami/common/licenses/gpl-source-links.txt
    cp -f ${PACKAGE} /opt/bitnami/${TARGET_DIR}/bin/gosu
    popd

    rm -rf ${PACKAGE}
EOT

FROM bitnami/minideb:bullseye as stage-0

COPY --link --from=golang-builder /opt/bitnami /opt/bitnami
