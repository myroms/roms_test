#!/bin/bash
#
# svn $Id: copyright.sh 1154 2023-02-17 20:52:30Z arango $
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Copyright (c) 2002-2023 The ROMS/TOMS Group                           :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::: David Robertson :::
#                                                                       :::
# ROMS/TOMS Copyright Update Script                                     :::
#                                                                       :::
# Script to update the copyright information on 'matlab' source files.  :::
# This script replaces the copyright string in the source files and     :::
# updates the copyright svn property. This script must be executed      :::
# from top level of the 'matlab' source code.                           :::
#                                                                       :::
# Usage:                                                                :::
#                                                                       :::
#    ./bin/copyright.sh [options]                                       :::
#                                                                       :::
# Options:                                                              :::
#                                                                       :::
#    -nosvn    skip updating of the svn properties. Meant for systems   :::
#                that don't have the comandline svn tools.              :::
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

setsvn=1
verbose=0

while [ $# -gt 0 ]
do
  case "$1" in
    -nosvn )
      shift
      setsvn=0
      ;;

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
      echo "-nosvn    skip updating of the svn properties. Meant for systems"
      echo "            that don't have the comandline svn tools."
      echo ""
      echo "-verbose  list files that are modified"
      echo ""
      exit 1
      ;;
  esac
done

echo -e "\nReplacing Copyright String in Files ...\n"

# The "! -path '*/.svn/*'" is there to keep it from messing with
# files in the .svn directories. The "! -name 'copyright.*'" is to
# keep it from messing with the file that's making the reaplacements.
# The "2>" redirects stderr so errors don't get put in FILE.

for FILE in `find ${c_dirs} ! -path '*/.svn/*' ! -name 'copyright.*' -type f -print 2> /dev/null`
do

# Double check that we're not changing a file in a .svn folder.

  if [ `echo $FILE | grep -vc '.svn/'` -gt 0 ]; then
    if [ $verbose -eq 1 ]; then
      grep -l "${search}" $FILE && sed -i -e "s|${search}|${replace}|g" $FILE
    else
      grep -l "${search}" $FILE > /dev/null && sed -i -e "s|${search}|${replace}|g" $FILE
    fi
  else
    echo "There is a .svn in the path: $FILE skipped"
  fi
done

echo -e "\nDone.\n"

if [ $setsvn -eq 1 ]; then
  svn propset copyright '(c) 2002-2023 The ROMS/TOMS Group' .
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' External
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' bin
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' basin
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' benchmark
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' bio_toy
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' bl_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' canyon
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' channel
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' DAMEE_4
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' double_gyre
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' dogbone
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' estuary_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' flt_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' grav_adj
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' inlet_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' IRENE
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' kelvin
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' lab_canyon
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' lake_jersey
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' lmd_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' riverplume
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' seamount
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' sed_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' shoreface
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' soliton
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' test_chan
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' test_head
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' upwelling
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' WC13
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' weddell
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' windbasin
else
  echo -e "Not updating svn properties.\n"
fi
