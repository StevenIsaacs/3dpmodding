#!/bin/bash
# Set or get a sticky variable.
# This script is intended to be used called from a makefile.
#
# A sticky variable once set defaults to its previous value.
# Parameters:
#  1 = A variable name and possibly its value.
#      <var>=<val>   Makes the variable stick.
#      <var>         Retrieves the previous value.
#  2 = The directory in which to store the sticky variable.
__v=(${1//=/ })
if [ "$2" == "" ]; then
  echo "Sticky directory must be specified." 1>&2
  exit 1
fi
if [ "${__v[1]}" == "" ]; then
  # The variable should have been previously set.
  if [ -f $2/${__v[0]} ]; then
    cat $2/${__v[0]}
  else
    echo Sticky variable ${__v[0]} has not been set 1>&2
  fi
else
  # Set the variable.
  mkdir -p $2
  echo ${__v[1]} > $2/${__v[0]}
  echo ${__v[1]}
fi
