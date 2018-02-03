#!/usr/bin/env bash

## Local settings
build_tags_file="${PWD}/build.sh~tags"
docker_run_options='--detach'

## Settings initialization
set -e
set -x

source ${PWD}/_tools.sh

## Tests

#1 Test build successful
echo '-> 1 Test build successful'
[ -f "${build_tags_file}" ]

# Get main image
echo '-> Get main image'
image=`head --lines=1 "${build_tags_file}"`

#2 Test if GLPI successfully installed
echo '-> 2 Test if Transmission successfully installed'
image_name=transmission_2
docker run --rm $docker_run_options --name "${image_name}" "${image}" transmission-daemon -V


#3 Test web access
echo '-> 3 Test web access'
image_name=transmission_3
docker run $docker_run_options --name "${image_name}" --publish 8000:9091 "${image}"
wait_for_string_in_container_logs "${image_name}" 'Watching'
sleep 4
#test
if ! curl -v http://localhost:8000 2>&1 | grep --quiet 'transmission/web/'; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"
