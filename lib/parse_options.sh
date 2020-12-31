parse_options() {
  # Parse action
  [[ $# -eq 0 ]] && usage
  case $1 in
    add|remove) action=$1; shift;;
    list|help) $1;;
    *) usage;;
  esac

  # Parse options
  [[ $# -eq 0 ]] && error "Error: Language is missing"
  while (( "$#" )); do
    [[ $1 =~ ^-a|--alpine$ ]] && { use_alpine=true; shift; continue; };
    [[ $1 =~ ^-b|--binary$ ]] && {
      if [[ -n $2 ]] && [[ ${2:0:1} != "-" ]]; then
        binary_name=$2; shift 2; continue;
      else
        error "Error: Argument for $1 is missing"
      fi
    };
    [[ $1 =~ ^-d|--debug$ ]] && { debug=true; shift; continue; };
    [[ $1 =~ ^-v|--verbose$ ]] && { verbose=true; shift; continue; };
    [[ ${1:0:1} == '-' ]] && error "Error: Unknown param $1"
    [[ -z $1 ]] && error "Error: Language is missing"
    language=$1
    version=$([[ -n $2 ]] && echo $2 || echo 'latest')
    break
  done
  [[ -z $language ]] && error "Error: Language is missing"
}

usage() {
  cat <<-EOF
USAGE:

lang_install help
    Show usage
lang_install list
    List installed languages
lang_install add [OPTIONS] LANGUAGE [VERSION]
    Install a new language / version 
lang_install remove [OPTIONS] LANGUAGE [VERSION]
    Remove an installed language

OPTIONS
  -a, --alpine
        Use alpine images
  -b <BINARY_NAME>, --binary <BINARY_NAME>
        Specify the main binary name. Default is equal to the language's name, can be configured in config/.config_aliases
  -d, --debug
      Debug mode. Show what binaries whould be installed
  -v, --verbose
      Show more logs
EOF
  exit 0
}