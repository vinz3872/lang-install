#!/bin/sh

# load functions
. lib/build_helper.sh

parse_build_params "${@}"
build_image
find_binary_dirname

# debug
if [[ $debug == true ]]; then
  declare -a bins=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname ! -name "*.sh" ! -type d -exec basename {} \;)
  for i in $bins; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    debug_file_content
    echo -e "$file_content"
  done
else
  # remove folder if present
  [[ -d $bin_folder_path ]] && rm -r $bin_folder_path

  # init folder and copy files in parent folder
  mkdir -p $bin_folder_path
  declare -a bins=$(docker run -it --rm --network=host -v "$PWD:$PWD" -w $PWD -u `id -u` li_$language:$version find $dirname ! -name "*.sh" ! -type d -exec basename {} \;)
  for i in $bins; do
    # ${i%%[[:cntrl:]]}: remove \r (last elem)
    i=${i%%[[:cntrl:]]}
    [[ $verbose == true ]] && echo "Binary found: $i"
    add_binary
  done
  link_global_version
fi
