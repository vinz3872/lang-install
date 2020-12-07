#!/bin/sh

env_file_path=$PWD/config/load_env.sh
docker_env_file_path=$PWD/config/env_file
bin_folder=$PWD/bin

echo "# This file is auto generated, do not modify it." > $env_file_path
echo "# This file is auto generated, do not modify it." > $docker_env_file_path

# Add project env variables
echo "export LI_DOCKER_PATH_BINS=$bin_folder" >> $env_file_path
echo "LI_DOCKER_PATH_BINS=$bin_folder" >> $docker_env_file_path
echo "export LI_DOCKER_ENV_FILE_PATH=$docker_env_file_path" >> $env_file_path

# Import env variables from config/.config
while read -r env_name value; do
  ([[ $env_name == '#' ]] || [[ -z $env_name ]] || [[ -z $value ]]) && continue
  echo "export ${env_name^^}=${value}" >> $env_file_path
  echo ${env_name^^}=${value} >> $docker_env_file_path
done < config/.config

# Add installed languages binaries in path
declare -a dirs=$(find $bin_folder -name "global")
current_path='$PATH'
for i in $dirs; do
  # ${i%%[[:cntrl:]]}: remove \r (last elem)
  str=${i%%[[:cntrl:]]}
  current_path+=":$str"
done

echo "export PATH=$current_path" >> $env_file_path
# TODO: check if gem_path is needed in PATH variable