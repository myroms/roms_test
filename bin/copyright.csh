#!/bin/csh -f
#
# git $Id$
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Copyright (c) 2002-2023 The ROMS/TOMS Group                           :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
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
#    ./bin/copyright.csh [options]                                      :::
#                                                                       :::
# Options:                                                              :::
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

# verbose is a csh command to print all lines of the script so I changed
# this variable to "verb".

set verb = 0

while ( ($#argv) > 0 )
  switch ($1)
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
      echo "-verbose  list files that are modified"
      echo ""
      exit 1
    breaksw

  endsw
end

echo ""
echo "Replacing Copyright String in Files ..."
echo ""

# The "! -path '*/.git/*'" is there to keep it from messing with
# files in the .git directories. The "! -name 'copyright.*'" is to
# keep it from messing with the file that's making the reaplacements.
# There is no way to redirect only stderr with csh.

foreach FILE ( `find ${c_dirs} ! -path '*/.git/*' ! -name 'copyright.*' -type f -print` )

# Double check that we're not changing a file in a .git folder.

  if ( `echo $FILE | grep -vc '.git/'` ) then
    if ( $verb == 1 ) then
      grep -l "${search}" $FILE && sed -i -e "s|${search}|${replace}|g" $FILE
    else
      grep -l "${search}" $FILE > /dev/null && sed -i -e "s|${search}|${replace}|g" $FILE
    endif
  else
    echo "There is a .git in the path: $FILE skipped"
  endif

end

echo ""
echo "Done."
echo ""


