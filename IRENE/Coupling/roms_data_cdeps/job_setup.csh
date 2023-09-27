#!/bin/csh -f
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2023 The ROMS/TOMS Group                         #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.txt                                              #
#######################################################################
#                                                                     #
# ROMS-UFS coupling setup. It needs to be run before excuting the     #
# coupling driver.                                                    #
#                                                                     #
#######################################################################

 echo
 echo "ROMS-UFS coupling Configuration:"
 echo

# Set ROMS and UFS root directories.

 set ROMSroot=${ROMS_HOME}/roms
 set ROMStestroot=${ROMS_HOME}/roms_test
 set UFSroot=${ROMS_HOME}/ufs_coastal

 echo "ROMS root     directory: ${ROMSroot}"
 echo "ROMS testroot directory: ${ROMStestroot}"
 echo "UFS  root     directory: ${UFSroot}"
 echo

# Check for UFS driver.

 if ( -f ${UFSroot}/tests/ufs_coastal.exe ) then
   ln -fsv ${UFSroot}/tests/ufs_coastal.exe
 else
   echo "Cannot find UFS coupling driver: ${UFSroot}/tests/ufs_coastal.exe"
   echo "Please compile UFS driver"
 endif
 echo

# Get ROMS and UFS metadata files:

 if ( -f ${ROMStestroot}/External/varinfo.yaml ) then
   ln -fsv ${ROMStestroot}/External/varinfo.yaml
 else
   echo "Cannot find ROMS metadata file: ${ROMStestroot}/ROMS/External/varinfo.yaml"
 endif

 if ( -f ${ROMStestroot}/External/varinfo_daily.yaml ) then
   ln -fsv ${ROMStestroot}/External/varinfo_daily.yaml
 else
   echo "Cannot find ROMS metadata file: ${ROMStestroot}/External/varinfo_daily.yaml"
 endif

 if ( -f ${UFSroot}/tests/parm/fd_nems.yaml ) then
   ln -fsv ${UFSroot}/tests/parm/fd_nems.yaml
 else
   echo "Cannot find UFS metadata file: ${UFSroot}/tests/parm/fd_nems.yaml"
 endif
 echo

# Create CDEPS/CMEPS Restart directory.

 if ( ! -d Restart ) then
   mkdir Restart
   echo "Created Restart Directory: ${PWD}/Restart"
 endif
   
exit 0
