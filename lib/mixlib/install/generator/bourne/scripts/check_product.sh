# Check for product installation in various locations
install_paths="/opt/$project/bin"

for path in $install_paths; do
  if [ -d "$path" ] && [ "$install_strategy" = "once" ]; then
    echo "$project installation detected at $path"
    echo "install_strategy set to 'once'"
    echo "Nothing to install"
    exit
  fi
done
