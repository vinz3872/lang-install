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

docker build -t "li_$language:$version" \
  --build-arg USER_UID=`id -u` \
  --build-arg USER_GID=`id -g` \
  --build-arg USER_NAME=`id -un` \
  --build-arg VERSION=$version \
  --build-arg LANGUAGE=$language \
  -f $dockerfile_path \
  .

dirname=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version bash -c "which $binary_name | xargs dirname")
dirname=${dirname%%[[:cntrl:]]}

# debug
if [[ $debug == true ]]; then
  content_bin_sh="#!/bin/sh"
  content_docker_generic='docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u`'

  declare -a bins1=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname  -name "pg*" -type f -exec basename {} \;)
  declare -a bins2=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find -L $dirname -samefile $dirname/../share/postgresql-common/pg_wrapper -exec basename {} \;)
  for i in $bins1; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    file_content="$content_bin_sh\n$content_docker_generic li_$language:$version ${i%%[[:cntrl:]]}"
    file_content+=' "$@"'
    echo -e $file_content
  done
  for i in $bins2; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    file_content="$content_bin_sh\n$content_docker_generic li_$language:$version ${i%%[[:cntrl:]]}"
    file_content+=' "$@"'
    echo -e $file_content
  done
else
  bin_folder_path=$LI_DOCKER_PATH_BINS/$language/$version
  global_bin_folder_path=$LI_DOCKER_PATH_BINS/$language/global
  if [ ! -d $bin_folder_path ]; then
    # init folder and copy files in parent folder
    mkdir -p $bin_folder_path
    content_bin_sh="#!/bin/sh"
    content_docker_generic='docker run -it --rm --network=host -v "/tmp:/tmp" -v "$HOME:$HOME" -v "$PWD:$PWD" -w $PWD -u `id -u` --env-file $LI_DOCKER_ENV_FILE_PATH'

    declare -a bins1=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname  -name "pg*" -type f -exec basename {} \;)
    declare -a bins2=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find -L $dirname -samefile $dirname/../share/postgresql-common/pg_wrapper -exec basename {} \;)
    for i in $bins1; do
      # ${i%%[[:cntrl:]]}: remove \r (last elem)
      i=${i%%[[:cntrl:]]}
      [[ $verbose == true ]] && echo "Binary found: $i"
      file_content="$content_bin_sh\n$content_docker_generic li_$language:$version $i"
      file_content+=' "$@"'
      echo -e $file_content > $bin_folder_path/$i
      chmod +x $bin_folder_path/$i
    done
    for i in $bins2; do
      # ${i%%[[:cntrl:]]}: remove \r (last elem)
      i=${i%%[[:cntrl:]]}
      [[ $verbose == true ]] && echo "Binary found: $i"
      file_content="$content_bin_sh\n$content_docker_generic li_$language:$version $i"
      file_content+=' "$@"'
      echo -e $file_content > $bin_folder_path/$i
      chmod +x $bin_folder_path/$i
    done
  fi

  if [ -d $global_bin_folder_path ]; then
    rm -rf $global_bin_folder_path
  fi
  cp -R $bin_folder_path $global_bin_folder_path
fi
