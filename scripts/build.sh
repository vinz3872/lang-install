#!/bin/sh
# generate and export env variables
./init_docker_path.sh
. ./load_env.sh

bin_name=$1
version=$2
path=$DOCKER_PATH_BINS

if [[ -z "$path" ]]; then
  echo "Error: DOCKER_PATH_BINS empty"
elif [[ -z "$bin_name" || -z "$version" ]]; then
  echo "Usage: ./build.sh [bin_name] [version]"
elif [ -d "$bin_name" ]; then
  cd $bin_name && ./build.sh $bin_name $version $path
  # re-generate env variables
  cd .. && ./init_docker_path.sh
else
  echo "$bin_name not yet implemented"
fi
