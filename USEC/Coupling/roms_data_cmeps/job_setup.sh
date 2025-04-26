#!/bin/bash
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2025 The ROMS Group                              #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.txt                                              #
#######################################################################
#                                                                     #
# ROMS-UFS coupling setup: U.S. East Coast (USEC) application         #
#                                                                     #
# This script must be run before excuting the coupling driver. It     #
# generates ROMS standard input scripts from template. User must      #
# tune the following parameters:                                      #
#                                                                     #
# * Sets the number PETs partition in the X-direction (NtileI).       #
#                                                                     #
# * Sets the number PETs partition in the Y-direction (NtileJ).       #
#                                                                     #
# * Sets full or relative path (MyUSECdir) for application data.      #
#   For example, it substitutes the value of MyUSECdir with the       #
#                appropriate value, say ../..                         #
#                                                                     #
#   GRDNAME == MyUSECdir/Data/ROMS/usec_roms_grid.nc                  #
#                                                                     #
# Usage:                                                              #
#                                                                     #
#   ./job_setup.sh [options]                                          #
#                                                                     #
# Options:                                                            #
#                                                                     #
#   -d             USEC Data full or relative path                    #
#                                                                     #
#                    job_setup -d ../..                    (default)  #
#                                                                     #
#   -t             USEC templates scripts path                        #
#                                                                     #
#                    job_setup -d ../.. -t .               (default)  #
#                                                                     #
#   -pets          ROMS parallel tile partitions                      #
#                                                                     #
#                    job_setup -d ../.. -t . -pets 3x4     (default)  #
#                                                                     #
#######################################################################

# Initilialize.

UsecDir=../..                      # default MyUSECdir value
TemplDir=.                         # default template scripts path
nPETsX=3                           # number PETs in the X-direction
nPETsY=4                           # number PETs in the Y-direction

while [ $# -gt 0 ]
do
  case "$1" in
    -d )
      shift
      UsecDir="$1"
      shift
      ;;

    -t )
      shift
      TemplDir="$1"
      shift
      ;;

    -pets )
      shift
      pets="$1"
      read nPETsX nPETsY <<<${pets//[^0-9]/ }
      shift
      ;;

    * )
      echo ""
      echo "Available Options:"
      echo ""
      echo "  -d      USEC test case 'Data' full or relative path"
      echo "            (default ../..)"
      echo "  -t      USEC template scripts path"
      echo "            (default ./)"
      echo "  -pets   ROMS parallel tile decomposition"
      echo "            (default 3x4)"
      exit 1
      ;;
  esac
done

echo
echo "ROMS-UFS coupling Configuration:"
echo
echo "  USEC Data path: ${UsecDir}"
echo "  ROMS partitions, nPETsX = ${nPETsX}, nPETxY = ${nPETsY}"

# Check if provided "Data" directory path is correct.

if [ ! -f "${UsecDir}/Data/ROMS/usec_roms_grid.nc" ]; then
  echo ""
  echo "  Cannot find file: ${UsecDir}/Data/ROMS/usec_roms_grid.nc"
  echo "  Correct the provided location of USEC Data directory: ${UsecDir}"
  exit
fi

# Set tunable standard input parameters.

ROMS_InpTmpl=roms_usec.tmpl
ROMS_ObsTmpl=rbl4dvar.tmpl

DATM_Inml=datm_in.tmpl
DATM_ERA5=datm.streams_era5.tmpl
DATM_NARR=datm.streams_narr.tmpl

ROMS_Inp=`basename $ROMS_InpTmpl .tmpl`.in
ROMS_Obs=`basename $ROMS_ObsTmpl .tmpl`.in

datm_Inml=`basename $DATM_Inml .tmpl`
datm_ERA5=`basename $DATM_ERA5 _era5.tmpl`

# Check if provided template scripts directory path is correct.

if [ ! -f "${TemplDir}/${ROMS_InpTmpl}" ]; then
  echo ""
  echo "  Cannot find template script: ${TemplDir}/${ROMS_InpTmpl}"
  echo "  Correct the provided location of USEC template scripts: ${TemplDir}"
  exit
fi

# Generate ROMS standard input scripts from template.

echo
echo "  Generating '${ROMS_Inp}'      from template '${TemplDir}/${ROMS_InpTmpl}'"

cp -f ${TemplDir}/${ROMS_InpTmpl} ${ROMS_Inp}

perl -p0777 -i -e "s|MyNtileI|${nPETsX}|g"     ${ROMS_Inp}
perl -p0777 -i -e "s|MyNtileJ|${nPETsY}|g"     ${ROMS_Inp}
perl -p0777 -i -e "s|MyUSECdir|${UsecDir}|g"   ${ROMS_Inp}

# Generate DATA components scripts from templates.

echo "  Generating '${datm_Inml}'            from template '${TemplDir}/${DATM_Inml}'"

cp -f ${TemplDir}/${DATM_Inml} ${datm_Inml}

perl -p0777 -i -e "s|MyUSECdir|${UsecDir}|g" ${datm_Inml}

echo "  Generating '${datm_ERA5}'       from template '${TemplDir}/${DATM_ERA5}'"

cp -f ${TemplDir}/${DATM_ERA5} ${datm_ERA5}

perl -p0777 -i -e "s|MyUSECdir|${UsecDir}|g" ${datm_ERA5}

echo

exit 0
