# load functions
. lib/utils.sh

parse_build_params() {
  [[ $# < 9 ]] && error "Missing params, can't build"

  language=$1
  version=$2
  binary_name=$3
  dockerfile_path=$4
  debug=$5
  verbose=$6
  declare -a export_env=$7
  declare -a mount_list=$8
  additional_packages=$(sed -e 's/^"//' -e 's/"$//' <<< "$9")

  if [[ -n $export_env ]]; then
    for i in $export_env; do
      env_variables+="-e $i=\$$(sed -e 's/^"//' -e 's/"$//' <<< "$i") "
    done
  fi

  if [[ -n $mount_list ]]; then
    for i in $mount_list; do
      mount_str+="--mount $(sed -e 's/^"//' -e 's/"$//' <<< "$i") "
    done
  fi

  bin_folder_path=$LI_DOCKER_PATH_BINS/$language/$version
  global_bin_folder_path=$LI_DOCKER_PATH_BINS/$language/global
}

build_image() {
  docker build -t "li_$language:$version" \
    --build-arg USER_UID=`id -u` \
    --build-arg USER_GID=`id -g` \
    --build-arg USER_NAME=`id -un` \
    --build-arg VERSION=$version \
    --build-arg LANGUAGE=$language \
    --build-arg ADDITIONAL_PACKAGES=$additional_packages \
    -f $dockerfile_path \
    .
}

find_binary_dirname() {
  dirname=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version sh -c "which $binary_name | xargs dirname")
  dirname=${dirname%%[[:cntrl:]]}
}

link_global_version() {
  echo $version > $LI_DOCKER_PATH_BINS/$language/.version

  if [ -d $global_bin_folder_path ]; then
    rm -rf $global_bin_folder_path
  fi
  cp -R $bin_folder_path $global_bin_folder_path
}

debug_file_content() {
  file_content=$(cat <<-EOT
#!/bin/sh
if [[ -t 0 ]] || [[ \$- == *i* ]] || [[ -n "\$PS1" ]]; then
  docker run -it --rm --network=host ${mount_str}-v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
else
  docker run -i --rm --network=host ${mount_str}-v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
fi
EOT
)
}

add_binary() {
  cat <<EOT >> $bin_folder_path/$i
#!/bin/sh
if [[ -t 0 ]] || [[ \$- == *i* ]] || [[ -n "\$PS1" ]]; then
  docker run -it --rm --network=host ${mount_str}-v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
else
  docker run -i --rm --network=host ${mount_str}-v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
fi
EOT
  chmod +x $bin_folder_path/$i
}