#!/bin/sh
main_path=$HOME/docker/path
gem_path=$HOME/.gems
docker_env_file_path=$HOME/work-conf/dockerfiles/env_file
mkdir -p $main_path

declare -a dirs=$(find $main_path -name "global")
current_path=$PATH
for i in $dirs; do
  # ${i%%[[:cntrl:]]}: remove \r (last elem)
  str=${i%%[[:cntrl:]]}
  current_path+=":$str"
done
current_path+=":$gem_path/bin"

env_file='load_env.sh'
echo "export GEM_HOME=$gem_path" > $env_file
echo "GEM_HOME=$gem_path" > $docker_env_file_path

echo "export GEM_PATH=$gem_path" >> $env_file
echo "GEM_PATH=$gem_path" >> $docker_env_file_path

echo "export BUNDLE_PATH=$gem_path" >> $env_file
echo "BUNDLE_PATH=$gem_path" >> $docker_env_file_path

echo "export DOCKER_PATH_BINS=$main_path" >> $env_file
echo "DOCKER_PATH_BINS=$main_path" >> $docker_env_file_path

echo "export PATH=$current_path" >> $env_file
echo "export DOCKER_ENV_FILE_PATH=$docker_env_file_path" >> $env_file
