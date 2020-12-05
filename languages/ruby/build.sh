if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Missing params, can't build"
  exit
fi
bin_name=$1
version=$2
path=$3
echo "Build $bin_name version $version"

docker build -t "path_$bin_name:$version" \
  --build-arg USER_UID=`id -u` \
  --build-arg USER_GID=`id -g` \
  --build-arg USER_NAME=`id -un` \
  --build-arg VERSION=$2 \
  -f Dockerfile \
  .

if [ ! -d "$path/$bin_name/$version" ]; then
  # init folder and copy files in parent folder
  mkdir -p $path/$bin_name/$version
  content_bin_sh="#!/bin/sh"
  content_docker_generic='docker run -it --rm --network=host -v "/tmp:/tmp" -v "$HOME:$HOME" -v "$PWD:$PWD" -w $PWD -u `id -u` --env-file $DOCKER_ENV_FILE_PATH'

  declare -a bins=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` path_$bin_name:$version ls /usr/local/bin)
  for i in $bins; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    file_content="$content_bin_sh\n$content_docker_generic path_$bin_name:$version ${i%%[[:cntrl:]]}"
    file_content+=' "$@"'
    echo -e $file_content > $path/$bin_name/$version/${i%%[[:cntrl:]]}
    chmod +x $path/$bin_name/$version/${i%%[[:cntrl:]]}
  done
fi

if [ -d "$path/$bin_name/global" ]; then
  rm -rf "$path/$bin_name/global"
fi
cp -R $path/$bin_name/$version $path/$bin_name/global
