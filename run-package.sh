#!/bin/bash

user=$1
container_name="$2"
package_name="${3:-$2}"

# run docker cli within a limited environment so that the container can initialize itself safely
docker run --privileged --name "$container_name-container" --rm \
    -v "$(pwd)/$package_name:/app:ro" \
    -v "/$container_name:/$container_name" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w "/app" -it docker:cli "sh" "/app/run.sh"
