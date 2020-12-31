list() {
  find $LI_DOCKER_PATH_BINS -maxdepth 2 -type d ! -name "global" | sed -e "s|^$LI_DOCKER_PATH_BINS||" -e "s|^\/||" -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/└\1/"
  # tree -dC -L 2 -I global $LI_DOCKER_PATH_BINS
}

help() {
  usage
}

add_lang() {
  [[ -z $binary_name ]] && load_aliases_config
  : ${binary_name:=$language}

  build_file_name="build${use_alpine:+_alpine}.sh"
  if [[ -f "languages/$language/$build_file_name" ]]; then
    build_file_path="languages/$language/$build_file_name"
  elif [[ -f "languages/default/$build_file_name" ]]; then
    build_file_path="languages/default/$build_file_name"
  else
    error "Error: Build file $build_file_name not found"
  fi

  dockerfile_name="Dockerfile${use_alpine:+.alpine}"
  if [[ -f "languages/$language/$dockerfile_name" ]]; then
    dockerfile_path="languages/$language/$dockerfile_name"
  elif [[ -f "languages/default/$dockerfile_name" ]]; then
    dockerfile_path="languages/default/$dockerfile_name"
  else
    error "Error: Build file $dockerfile_name not found"
  fi

  : ${debug:=false}
  : ${verbose:=false}
  export_env_name="LI_${language}_export_env"

  declare -a mount_points_global=$(compgen -v | grep "LI_global_mount_.*")
  declare -a mount_points=$(compgen -v | grep "LI_${language}_mount_.*")
  mount_points+=($mount_points_global)

  for i in ${mount_points[@]}; do
    [[ -n $mount_list ]] && mount_list+=' '
    mount_list+=${!i}
  done

  additional_packages="LI_${language}_additional_packages_"
  if [[ -n $use_alpine ]]; then additional_packages+='alpine'; else additional_packages+='default'; fi

  ./$build_file_path $language $version $binary_name $dockerfile_path $debug $verbose "${!export_env_name}" "$mount_list" "${!additional_packages}"
  docker image prune -f
}

remove_lang() {
  if [[ $version != 'latest' ]]; then
    if [[ -d "bin/$language/$version" ]]; then
      confirm "Remove $language version $version"
      rm -r bin/$language/$version
      echo "$language version $version is removed"
    else
      error "Error: $language version $version is not installed"
    fi
  else
    if [[ -d "bin/$language" ]]; then
      confirm "Remove $language"
      rm -r bin/$language
      echo "$language is removed"
    else
      error "Error: $language is not installed"
    fi
  fi
}