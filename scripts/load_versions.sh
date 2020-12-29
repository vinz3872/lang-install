declare -a dirs=$(find bin -type f -name ".version")

for i in $dirs; do
  dir_name=$(awk -F'/' '{print $(NF-1)}' <<< $i)
  version=$(cat $i)
  export LI_${dir_name^^}_VERSION="$version"
done
