#!/bin/bash
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2024 The ROMS/TOMS Group                         #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.txt                                              #
#######################################################################
#                                                                     #
# ROMS-UFS coupling setup. It needs to be run before excuting the     #
# coupling driver. It generates ROMS standard input scripts from      #
# template. User must tune the following parameters:                  #
#                                                                     #
# * Sets the number PETs partition in the X-direction (NtileI).       #
#                                                                     #
# * Sets the number PETs partition in the Y-direction (NtileJ).       #
#                                                                     #
# * Sets full or relative path (MyIRENEdir) for application data.     #
#   For example, it substitutes the value of MyIRENEdir with the      #
#                appropriate value, say ../..                         #
#                                                                     #
#   GRDNAME == MyIRENEdir/Data/ROMS/irene_roms_grid.nc                #
#                                                                     #
# Usage:                                                              #
#                                                                     #
#   ./job_setup.sh [options]                                          #
#                                                                     #
# Options:                                                            #
#                                                                     #
#   -d             IRENE Data full or relative path                   #
#                                                                     #
#                    job_setup -d ../..                    (default)  #
#                                                                     #
#   -t             IRENE templates scripts path                       #
#                                                                     #
#                    job_setup -d ../.. -t .               (default)  #
#                                                                     #
#   -pets          ROMS parallel tile partitions                      #
#                                                                     #
#                    job_setup -d ../.. -t . -pets 3x4     (default)  #
#                                                                     #
#######################################################################

# Initilialize.

IreneDir=../..                     # default MyIRENEdir value
TemplDir=.                         # default template scripts path
nPETsX=3                           # number PETs in the X-direction
nPETsY=4                           # number PETs in the Y-direction

while [ $# -gt 0 ]
do
  case "$1" in
    -d )
      shift
      IreneDir="$1"
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
      echo "  -d      IRENE test case 'Data' full or relative path"
      echo "            (default ../..)"
      echo "  -t      IRENE template scripts path"
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
echo "  IRENE Data path: ${IreneDir}"
echo "  ROMS partitions, nPETsX = ${nPETsX}, nPETxY = ${nPETsY}"

# Check if provided "Data" directory path is correct.

if [ ! -f "${IreneDir}/Data/ROMS/irene_roms_grid.nc" ]; then
  echo ""
  echo "  Cannot find file: ${IreneDir}/Data/ROMS/irene_roms_grid.nc"
  echo "  Correct the provided location of IRENE Data directory: ${IreneDir}"
  exit
fi

# Set tunable standard input parameters.

ROMS_InpTmpl=roms_irene.tmpl
ROMS_ObsTmpl=rbl4dvar.tmpl

DATM_Inml=datm_in.tmpl
DATM_ERA5=datm.streams_era5.tmpl
DATM_NARR=datm.streams_narr.tmpl

ROMS_Inp=`basename $ROMS_InpTmpl .tmpl`.in
ROMS_Obs=`basename $ROMS_ObsTmpl .tmpl`.in

datm_Inml=`basename $DATM_Inml .tmpl`
datm_ERA5=`basename $DATM_ERA5 _era5.tmpl`
datm_NARR=`basename $DATM_NARR .tmpl`

OuterLoop=1                        # outer loop counter (not used)
Phase4DVAR=1                       # 4D-Var phase (not used)

# Check if provided template scripts directory path is correct.

if [ ! -f "${TemplDir}/${ROMS_InpTmpl}" ]; then
  echo ""
  echo "  Cannot find template script: ${TemplDir}/${ROMS_InpTmpl}"
  echo "  Correct the provided location of IRENE template scripts: ${TemplDir}"
  exit
fi

# Generate ROMS standard input scripts from template.

echo
echo "  Generating '${ROMS_Inp}'      from template '${TemplDir}/${ROMS_InpTmpl}'"
 
cp -f ${TemplDir}/${ROMS_InpTmpl} ${ROMS_Inp}

perl -p0777 -i -e "s|MyNtileI|${nPETsX}|g"     ${ROMS_Inp}
perl -p0777 -i -e "s|MyNtileJ|${nPETsY}|g"     ${ROMS_Inp}
perl -p0777 -i -e "s|MyIRENEdir|${IreneDir}|g" ${ROMS_Inp}

# Generate ROMS standard input scripts from template.

echo "  Generating '${ROMS_Obs}'        from template '${TemplDir}/${ROMS_ObsTmpl}'"

cp -f ${TemplDir}/${ROMS_ObsTmpl} ${ROMS_Obs}

perl -p0777 -i -e "s|MyOuterLoop|${OuterLoop}|g"   ${ROMS_Obs}
perl -p0777 -i -e "s|MyPhase4DVAR|${Phase4DVAR}|g" ${ROMS_Obs}
perl -p0777 -i -e "s|MyIRENEdir|${IreneDir}|g"     ${ROMS_Obs}

# Generate DATA components scripts from templates.

echo "  Generating '${datm_Inml}'            from template '${TemplDir}/${DATM_Inml}'"

cp -f ${TemplDir}/${DATM_Inml} ${datm_Inml}

perl -p0777 -i -e "s|MyIRENEdir|${IreneDir}|g" ${datm_Inml}

echo "  Generating '${datm_ERA5}'       from template '${TemplDir}/${DATM_ERA5}'"

cp -f ${TemplDir}/${DATM_ERA5} ${datm_ERA5}

perl -p0777 -i -e "s|MyIRENEdir|${IreneDir}|g" ${datm_ERA5}

echo "  Generating '${datm_NARR}'  from template '${TemplDir}/${DATM_NARR}'"

cp -f ${TemplDir}/${DATM_NARR} ${datm_NARR}

perl -p0777 -i -e "s|MyIRENEdir|${IreneDir}|g" ${datm_NARR}

echo

exit 0
