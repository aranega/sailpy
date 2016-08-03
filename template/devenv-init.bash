#!/usr/bin/env bash
#
# This script is provided for people who might clone/get your code without using
# SailPy
#
# It will init your dev environment for the project if you haven't created it
# with "SailPy". It will create a Python virtualenv and install all the
# "requirements.txt" dependencies.
#
# Change the SAILFISHSDK so it points to your actual Sailfish SDK install, only
# if you get those sources from a third party and you didn't use "sailpy" in the
# first place.
#

SAILFISHSDK=~/SailfishOS   # CHANGEME

name="$(pwd)"
name="${name/*\/}"

[ "${VIRTUAL_ENV/*\/}" == "$name" ] && [ -f ".sailpy-init" ] && {
  echo "You already are in context of your project $name"
  echo "Just try make"
  exit 0
}

[ -f ".sailpy-init" ] && {
  echo "Your project as already been init, use pew or sailpy instead of this script"
  echo "$ pew workon $name"
  echo "or"
  echo "$ sailpy workon $name"
  exit 0
}

pytoninstall=$(which python3 2> /dev/null)
[ -z "$pytoninstall" ] && {
  echo "Python3 is required to init this project (and to use pyotherside)" >&2
  exit 1
}

pewinstall=$(which pew 2> /dev/null)
[ -z "$pewinstall" ] && {
  echo "Pew is missing, please install it" >&2
  exit 2
}

pewenv=$(pew show "$name" 2> /dev/null)
[ ! -z "$pewenv" ] && {
  echo "Pew already owns a $name virtualenv. If it is related to this project, please, use either"
  echo "$ pew workon $name"
  echo "or"
  echo "$ sailpy workon $name"
  exit 0
}

# Create the dedicated virtualenv
pew new -r "requirements.txt" -p "$pythoninstall" "$name" && {
  # The project is now in a sailpy initialized state
  echo "$SAILFISHSDK" > .sailpy-init
}
