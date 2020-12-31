error() {
  echo $1 >&2
  exit 1
}

confirm() {
  read -p "$1 ? [YyNn]" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi
  exit 0
}