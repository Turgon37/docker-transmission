#!/usr/bin/env bash

## Global settings
# image name
DOCKER_IMAGE="${DOCKER_REPO:-transmission}"
# use dockefile
DOCKERFILE_PATH=Dockerfile

## Initialization
set -e

## Local settings
alpine_version=`cat Dockerfile | grep --perl-regexp --only-matching '(?<=FROM alpine:)[0-9.]+'`
arch=`uname --machine`

## Settings initialization
set -e

# If empty version, fetch the latest from repository
if [ -z "$TRANSMISSION_VERSION" ]; then
  TRANSMISSION_VERSION=`curl --fail -s "https://pkgs.alpinelinux.org/packages?name=transmission&branch=v${alpine_version}&repo=main&arch=${arch}" | grep --perl-regexp --only-matching '(?<=<td class="version">)[a-z0-9.-]+' | uniq`
  test -n "$TRANSMISSION_VERSION"
fi
echo "-> selected Transmission version ${TRANSMISSION_VERSION}"

# If empty commit, fetch the current from local git rpo
if [ -n "${SOURCE_COMMIT}" ]; then
  VCS_REF="${SOURCE_COMMIT}"
elif [ -n "${TRAVIS_COMMIT}" ]; then
  VCS_REF="${TRAVIS_COMMIT}"
else
  VCS_REF="`git rev-parse --short HEAD`"
fi
test -n "${VCS_REF}"
echo "-> current vcs reference '${VCS_REF}'"

# Get the current image static version
image_version=`cat VERSION`
echo "-> use image version '${image_version}'"

# Compute variant from dockerfile name
if ! [ -f ${DOCKERFILE_PATH} ]; then
  echo 'You must select a valid dockerfile with DOCKERFILE_PATH' 1>&2
  exit 1
fi

image_building_name="${DOCKER_IMAGE}:building"
echo "-> use image name '${image_building_name}' for build"

## Build image
echo "=> building '${image_building_name}' with image version '${image_version}'"
docker build --build-arg "TRANSMISSION_VERSION=${TRANSMISSION_VERSION}" \
             --label "org.label-schema.build-date=`date -u +'%Y-%m-%dT%H:%M:%SZ'`" \
             --label 'org.label-schema.name=transmission' \
             --label 'org.label-schema.description=This image contains the Bittorent Transmission web application' \
             --label 'org.label-schema.url=https://github.com/Turgon37/docker-transmission' \
             --label "org.label-schema.vcs-ref=${VCS_REF}" \
             --label 'org.label-schema.vcs-url=https://github.com/Turgon37/docker-transmission' \
             --label 'org.label-schema.vendor=Pierre GINDRAUD' \
             --label "org.label-schema.version=${image_version}" \
             --label 'org.label-schema.schema-version=1.0' \
             --label "application.transmission.version=${TRANSMISSION_VERSION}" \
             --tag "${image_building_name}" \
             --file "${DOCKERFILE_PATH}" \
             .
