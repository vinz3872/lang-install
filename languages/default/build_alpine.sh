#!/bin/sh

if [[ $# < 6 ]]; then
  echo "Missing params, can't build"
  exit 1
fi

language=$1
version=$2
binary_name=$3
dockerfile_path=$4
debug=$5
verbose=$6
declare -a export_env=$7

docker build -t "li_$language:$version" \
  --build-arg USER_UID=`id -u` \
  --build-arg USER_GID=`id -g` \
  --build-arg USER_NAME=`id -un` \
  --build-arg VERSION=$version \
  --build-arg LANGUAGE=$language \
  -f $dockerfile_path \
  .

if [[ -n $export_env ]]; then
  for i in $export_env; do
    env_variables+="-e $i=\$$i "
  done
fi

dirname=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version sh -c "which $binary_name | xargs dirname")
dirname=${dirname%%[[:cntrl:]]}

# debug
if [[ $debug == true ]]; then
  declare -a bins=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname ! -name "*.sh" ! -type d -exec basename {} \;)
  for i in $bins; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    file_content=$(cat <<-END
#!/bin/sh
if [[ -t 0 ]] || [[ \$- == *i* ]] || [[ -n "\$PS1" ]]; then
  docker run -it --rm --network=host -v "/tmp:/tmp" -v "\$HOME:\$HOME" -v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
else
  docker run -i --rm --network=host -v "/tmp:/tmp" -v "\$HOME:\$HOME" -v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
fi
END
)
    echo -e "$file_content"
  done
else
  bin_folder_path=$LI_DOCKER_PATH_BINS/$language/$version
  global_bin_folder_path=$LI_DOCKER_PATH_BINS/$language/global

  # remove folder if present
  [[ -d $bin_folder_path ]] && rm -r $bin_folder_path

  # init folder and copy files in parent folder
  mkdir -p $bin_folder_path
  declare -a bins=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname ! -name "*.sh" ! -type d -exec basename {} \;)
  for i in $bins; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    [[ $verbose == true ]] && echo "Binary found: $i"
    cat <<EOT >> $bin_folder_path/$i
#!/bin/sh
if [[ -t 0 ]] || [[ \$- == *i* ]] || [[ -n "\$PS1" ]]; then
  docker run -it --rm --network=host -v "/tmp:/tmp" -v "\$HOME:\$HOME" -v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
else
  docker run -i --rm --network=host -v "/tmp:/tmp" -v "\$HOME:\$HOME" -v "\$PWD:\$PWD" -w \$PWD -u \`id -u\` ${env_variables}--env-file \$LI_DOCKER_ENV_FILE_PATH li_$language:$version $i "\$@"
fi
EOT
    chmod +x $bin_folder_path/$i
  done

  if [ -d $global_bin_folder_path ]; then
    rm -rf $global_bin_folder_path
  fi
  cp -R $bin_folder_path $global_bin_folder_path
fi
