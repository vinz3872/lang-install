load_config() {
  refresh_env_file
  . ./config/load_env.sh

  while IFS= read -r line; do
    export "$line"
  done <<< "$(parse_yaml $PWD/config/.config.yaml "LI_")"
}

load_aliases_config() {
  var_name="LI_${language}_alias"
  binary_name=${!var_name}
}

load_versions() {
  # unset old env variables
  declare -a env_vars=$(compgen -v | grep "LI_.*VERSION")
  for i in $env_vars; do
    unset $i
  done

  declare -a dirs=$(find bin -type f -name ".version")
  for i in $dirs; do
    dir_name=$(awk -F'/' '{print $(NF-1)}' <<< $i)
    version=$(cat $i)
    export LI_${dir_name^^}_VERSION="$version"
  done
}

# https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script/21189044#21189044
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

refresh_env_file() {
  load_versions

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
}