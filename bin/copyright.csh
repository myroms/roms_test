#!/bin/csh -f
#
# svn $Id: copyright.csh 1154 2023-02-17 20:52:30Z arango $
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
# from the top level 'matlab' source code.                              :::
#                                                                       :::
# Usage:                                                                :::
#                                                                       :::
#    ./bin/copyright.csh [options]                                      :::
#                                                                       :::
# Options:                                                              :::
#                                                                       :::
#    -nosvn    skip updating of the svn properties. Meant for systems   :::
#                that don't have the comandline svn tools.              :::
#                                                                       :::
#    -verbose  list files that are modified.                            :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set search = "2002-2022 The ROMS/TOMS"
set replace = "2002-2023 The ROMS/TOMS"

# Directories to search for replacements.

set c_dirs = "External bin"
set c_dirs = "$c_dirs basin"
set c_dirs = "$c_dirs benchmark"
set c_dirs = "$c_dirs bio_toy"
set c_dirs = "$c_dirs bl_test"
set c_dirs = "$c_dirs canyon"
set c_dirs = "$c_dirs channel"
set c_dirs = "$c_dirs DAMEE_4"
set c_dirs = "$c_dirs dogbone"
set c_dirs = "$c_dirs double_gyre"
set c_dirs = "$c_dirs estuary_test"
set c_dirs = "$c_dirs flt_test"
set c_dirs = "$c_dirs grav_adj"
set c_dirs = "$c_dirs inlet_test"
set c_dirs = "$c_dirs IRENE"
set c_dirs = "$c_dirs kelvin"
set c_dirs = "$c_dirs lab_canyon"
set c_dirs = "$c_dirs lake_jersey"
set c_dirs = "$c_dirs lmd_test"
set c_dirs = "$c_dirs riverplume"
set c_dirs = "$c_dirs seamount"
set c_dirs = "$c_dirs sed_test"
set c_dirs = "$c_dirs shoreface"
set c_dirs = "$c_dirs soliton"
set c_dirs = "$c_dirs test_chan"
set c_dirs = "$c_dirs test_head"
set c_dirs = "$c_dirs upwelling"
set c_dirs = "$c_dirs WC13"
set c_dirs = "$c_dirs weddell"
set c_dirs = "$c_dirs windbasin"

set setsvn = 1

# verbose is a csh command to print all lines of the script so I changed
# this variable to "verb".

set verb = 0

while ( ($#argv) > 0 )
  switch ($1)
    case "-nosvn":
      shift
      set setsvn = 0
    breaksw

    case "-verbose":
      shift
      set verb = 1
    breaksw

    case "-*":
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
    breaksw

  endsw
end

echo ""
echo "Replacing Copyright String in Files ..."
echo ""

# The "! -path '*/.svn/*'" is there to keep it from messing with
# files in the .svn directories. The "! -name 'copyright.*'" is to
# keep it from messing with the file that's making the reaplacements.
# There is no way to redirect only stderr with csh.

foreach FILE ( `find ${c_dirs} ! -path '*/.svn/*' ! -name 'copyright.*' -type f -print` )

# Double check that we're not changing a file in a .svn folder.

  if ( `echo $FILE | grep -vc '.svn/'` ) then
    if ( $verb == 1 ) then
      grep -l "${search}" $FILE && sed -i -e "s|${search}|${replace}|g" $FILE
    else
      grep -l "${search}" $FILE > /dev/null && sed -i -e "s|${search}|${replace}|g" $FILE
    endif
  else
    echo "There is a .svn in the path: $FILE skipped"
  endif

end

echo ""
echo "Done."
echo ""

if ( $setsvn == 1 ) then
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
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' dogbone
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' double_gyre
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' estuary_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' flt_test
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' grav_adj
  svn propset -R copyright '(c) 2002-2023 The ROMS/TOMS Group' inlet_test
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
  echo ""
  echo "Not updating svn properties."
  echo ""
endif

