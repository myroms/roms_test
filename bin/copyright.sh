#!/bin/bash
#
# git $Id$
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Copyright (c) 2002-2023 The ROMS/TOMS Group                           :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.md                                                 :::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::: David Robertson :::
#                                                                       :::
# ROMS/TOMS Copyright Update Script                                     :::
#                                                                       :::
# Script to update the copyright information on 'matlab' source files.  :::
# This script replaces the copyright string in the test files. It must  :::
# be executed from the top level 'roms_test' repository.                :::
#                                                                       :::
# Usage:                                                                :::
#                                                                       :::
#    ./bin/copyright.sh [options]                                       :::
#                                                                       :::
# Options:                                                              :::
#                                                                       :::
#    -verbose  list files that are modified.                            :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

search="2002-2022 The ROMS/TOMS"
replace="2002-2023 The ROMS/TOMS"

# Directories to search for replacements.

c_dirs="External bin"
c_dirs="$c_dirs basin"
c_dirs="$c_dirs benchmark"
c_dirs="$c_dirs bio_toy"
c_dirs="$c_dirs bl_test"
c_dirs="$c_dirs canyon"
c_dirs="$c_dirs channel"
c_dirs="$c_dirs DAMEE_4"
c_dirs="$c_dirs dogbone"
c_dirs="$c_dirs double_gyre"
c_dirs="$c_dirs estuary_test"
c_dirs="$c_dirs flt_test"
c_dirs="$c_dirs grav_adj"
c_dirs="$c_dirs inlet_test"
c_dirs="$c_dirs IRENE"
c_dirs="$c_dirs kelvin"
c_dirs="$c_dirs lab_canyon"
c_dirs="$c_dirs lake_jersey"
c_dirs="$c_dirs lmd_test"
c_dirs="$c_dirs riverplume"
c_dirs="$c_dirs seamount"
c_dirs="$c_dirs sed_test"
c_dirs="$c_dirs shoreface"
c_dirs="$c_dirs soliton"
c_dirs="$c_dirs test_chan"
c_dirs="$c_dirs test_head"
c_dirs="$c_dirs upwelling"
c_dirs="$c_dirs WC13"
c_dirs="$c_dirs weddell"
c_dirs="$c_dirs windbasin"

verbose=0

while [ $# -gt 0 ]
do
  case "$1" in
    -verbose )
      shift
      verbose=1
      ;;

    * )
      echo ""
      echo "$0 : Unknown option [ $1 ]"
      echo ""
      echo "Available Options:"
      echo ""
      echo "-verbose  list files that are modified"
      echo ""
      exit 1
      ;;
  esac
done

echo -e "\nReplacing Copyright String in Files ...\n"

# The "! -path '*/.git/*'" is there to keep it from messing with
# files in the .git directories. The "! -name 'copyright.*'" is to
# keep it from messing with the file that's making the reaplacements.
# The "2>" redirects stderr so errors don't get put in FILE.

for FILE in `find ${c_dirs} ! -path '*/.git/*' ! -name 'copyright.*' -type f -print 2> /dev/null`
do

# Double check that we're not changing a file in a .git folder.

  if [ `echo $FILE | grep -vc '.git/'` -gt 0 ]; then
    if [ $verbose -eq 1 ]; then
      grep -l "${search}" $FILE && sed -i -e "s|${search}|${replace}|g" $FILE
    else
      grep -l "${search}" $FILE > /dev/null && sed -i -e "s|${search}|${replace}|g" $FILE
    fi
  else
    echo "There is a .git in the path: $FILE skipped"
  fi
done

echo -e "\nDone.\n"
