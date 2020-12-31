#!/bin/sh

. scripts/load_versions.sh
. scripts/parse_yaml.sh

env_file_path=$PWD/config/load_env.sh
docker_env_file_path=$PWD/config/env_file
bin_folder=$PWD/bin

echo "# This file is auto generated, do not modify it." > $env_file_path
echo "# This file is auto generated, do not modify it." > $docker_env_file_path

# Add project env variables
echo "export LI_DOCKER_PATH_BINS=$bin_folder" >> $env_file_path
echo "LI_DOCKER_PATH_BINS=$bin_folder" >> $docker_env_file_path
echo "export LI_DOCKER_ENV_FILE_PATH=$docker_env_file_path" >> $env_file_path

declare -a env_vars=$(compgen -v | grep "LI_.*_env_")
for i in $env_vars; do
  env_name=${i#*_env_}
  value=$(sed -e 's/^"//' -e 's/"$//' <<< "${!i}")
  echo "export ${env_name^^}=$(echo $value | envsubst)" >> $env_file_path
  echo ${env_name^^}=$(echo $value | envsubst) >> $docker_env_file_path
done

declare -a versions=$(compgen -v | grep "LI_.*_VERSION")
for i in $versions; do
  value=${!i}
  echo "export $i=$value" >> $env_file_path
  echo $i=$value >> $docker_env_file_path
done

# Add installed languages binaries in path
declare -a dirs=$(find $bin_folder -name "global")
current_path='$PATH'
for i in $dirs; do
  # ${i%%[[:cntrl:]]}: remove \r (last elem)
  str=${i%%[[:cntrl:]]}
  current_path+=":$str"
done

echo "export PATH=$current_path" >> $env_file_path
