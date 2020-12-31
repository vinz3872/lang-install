#!/bin/sh

# load functions
. lib/build_helper.sh

parse_build_params "${@}"
build_image
find_binary_dirname

# debug
if [[ $debug == true ]]; then
  declare -a bins1=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname  -name "pg*" -type f -exec basename {} \;)
  declare -a bins2=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find -L $dirname -samefile $dirname/../share/postgresql-common/pg_wrapper -exec basename {} \;)
  for i in $bins1; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    debug_file_content
    echo -e "$file_content"
  done
  for i in $bins2; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    debug_file_content
    echo -e "$file_content"
  done
else
  if [ ! -d $bin_folder_path ]; then
    # init folder and copy files in parent folder
    mkdir -p $bin_folder_path
    declare -a bins1=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname  -name "pg*" -type f -exec basename {} \;)
    declare -a bins2=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find -L $dirname -samefile $dirname/../share/postgresql-common/pg_wrapper -exec basename {} \;)
    for i in $bins1; do
      # ${i%%[[:cntrl:]]}: remove \r (last elem)
      i=${i%%[[:cntrl:]]}
      [[ $verbose == true ]] && echo "Binary found: $i"
      add_binary
    done
    for i in $bins2; do
      # ${i%%[[:cntrl:]]}: remove \r (last elem)
      i=${i%%[[:cntrl:]]}
      [[ $verbose == true ]] && echo "Binary found: $i"
      add_binary
    done
  fi
  link_global_version
fi
