#!/usr/bin/env bash

## Global settings
# image name
DOCKER_IMAGE="${DOCKER_REPO:-transmission}"

## Initialization
set -e

image_building_name="${DOCKER_IMAGE}:building"
docker_run_options='--detach'
echo "-> use image name '${image_building_name}' for tests"


## Prepare
if [[ -z $(which container-structure-test 2>/dev/null) ]]; then
  echo "Retrieving structure-test binary...."
  if [[ -n "${TRAVIS_OS_NAME}" && "$TRAVIS_OS_NAME" != 'linux' ]]; then
    echo "container-structure-test only released for Linux at this time."
    echo "To run on OSX, clone the repository and build using 'make'."
    exit 1
  else
    curl -sS -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 \
    && chmod +x container-structure-test-linux-amd64 \
    && sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
  fi
fi

# Download tools shim.
if [[ ! -f _tools.sh ]]; then
  curl -L -o ${PWD}/_tools.sh https://gist.github.com/Turgon37/2ba8685893807e3637ea3879ef9d2062/raw
fi
source ${PWD}/_tools.sh


## Test
container-structure-test \
    test --image "${image_building_name}" --config ./tests.yml

#2 Test if Transmission successfully installed
echo '-> 2 Test if Transmission successfully installed'
image_name=transmission_2
docker run --rm "${image_building_name}" transmission-daemon -V

#3 Test web access
echo '-> 3 Test web access'
image_name=transmission_3
docker run $docker_run_options --name "${image_name}" --publish 8000:9091 "${image_building_name}"
wait_for_string_in_container_logs "${image_building_name}" 'Watching'
sleep 4
#test
if ! curl -v http://localhost:8000 2>&1 | grep --quiet 'transmission/web/'; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"
