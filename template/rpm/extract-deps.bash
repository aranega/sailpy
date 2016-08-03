#!/usr/bin/env bash

[ -z "$VIRTUAL_ENV" ] && {
  echo "You must run this script in your project VirtualEnv." >&2
  echo "Please use 'sailpy workon YOUR_PROJECT_NAME' first" >&2
  exit 1
}

[ -z "$SAILFISHSDK" ] && {
  echo "You must run this script in your project VirtualEnv." >&2
  echo "Please use 'sailpy workon YOUR_PROJECT_NAME' first" >&2
  exit 1
}

[ -z "$DEST" ] && {
  DEST=./tmp-deps
  mkdir -p "$DEST"
  echo "Fetch dependencies from your requirement.txt and put them in $DEST"
}

SITEPACKAGE="$VIRTUAL_ENV"/lib/python*/site-packages

function get_files()
{
  local package="$1"
  local all_files=$(pip show -f "$package" | sed '/^Files:$/,/Entry-points:/!d' | grep -vE '^(\s)*\.|(Files:|Entry-points:|\.dist-info|__pycache__)')
  local result_files=""
  for file in $all_files; do

    file=${file/\/*}
    result_files="$SITEPACKAGE/$file $result_files"
  done
  echo "$result_files" | tr ' ' '\n' | sort -fd | uniq
}

function get_deps()
{
  local package="$1"
  local all_deps="$(get_files "$1")"
  local requires=$(pip show "$package" | grep Requires | tr ',' ' ')
  requires=${requires/Requires:}
  [ -z "$requires" ] && {
    echo "$all_deps"
    return 0
  }
  for dep in $requires; do
    all_deps="$all_deps $(get_deps "$dep")"
  done
  echo "$all_deps"
}

all_deps=""
for dep in $(cat requirements.txt | grep -v '^#'); do
  dep="${dep/\<*}"; dep="${dep/\=*}"; dep="${dep/\>*}"
  all_deps="$(get_deps $dep) $all_deps"
done

all_deps=$(echo "$all_deps" | tr ' ' '\n' | sort -fd | uniq)
echo "Copying Python packages..."

for dep in $all_deps; do
  echo "* ${dep/*\/}"
  cp -ar "$dep" "$DEST"
  find "$DEST/${dep/*\/}" -name __pycache__ -exec rm -r {} +
  find "$DEST/${dep/*\/}" -name _speedups. -exec rm -r {} +
done
