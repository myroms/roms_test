#!/bin/bash
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2023 The ROMS/TOMS Group                         #
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
#######################################################################

 echo
 echo "ROMS-UFS coupling Configuration:"

# Set Hurrican Irene application full or relative directory.

#IreneDir=~/ocean/repository/git/roms_test/IRENE
 IreneDir=../..

# Set ROMS path and Perl substitution script.

 ROMSroot=${ROMS_HOME}/roms
 SUBSTITUTE=${ROMSroot}/ROMS/Bin/substitute

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

 nPETsX=3                           # number PETs in the X-direction
 nPETsY=4                           # number PETs in the Y-direction

 OuterLoop=1                        # outer loop counter (not used)
 Phase4DVAR=1                       # 4D-Var phase (not used)

# Generate ROMS standard input scripts from template.

 echo
 echo "  Generating '${ROMS_Inp}'      from template '${ROMS_InpTmpl}'"
 
 cp -f ${ROMS_InpTmpl} ${ROMS_Inp}

 ${SUBSTITUTE} ${ROMS_Inp} MyNtileI      ${nPETsX}
 ${SUBSTITUTE} ${ROMS_Inp} MyNtileJ      ${nPETsY}
 ${SUBSTITUTE} ${ROMS_Inp} MyIRENEdir    ${IreneDir}

# Generate ROMS standard input scripts from template.

 echo "  Generating '${ROMS_Obs}'        from template '${ROMS_ObsTmpl}'"

 cp -f ${ROMS_ObsTmpl} ${ROMS_Obs}

 ${SUBSTITUTE} ${ROMS_Obs} MyOuterLoop   ${OuterLoop}
 ${SUBSTITUTE} ${ROMS_Obs} MyPhase4DVAR  ${Phase4DVAR}
 ${SUBSTITUTE} ${ROMS_Obs} MyIRENEdir    ${IreneDir}

# Generate DATA components scripts from templates.

 echo "  Generating '${datm_Inml}'            from template '${DATM_Inml}'"

 cp -f ${DATM_Inml} ${datm_Inml}

 ${SUBSTITUTE} ${datm_Inml} MyIRENEdir    ${IreneDir}

 echo "  Generating '${datm_ERA5}'       from template '${DATM_ERA5}'"

 cp -f ${DATM_ERA5} ${datm_ERA5}

 ${SUBSTITUTE} ${datm_ERA5} MyIRENEdir    ${IreneDir}

 echo "  Generating '${datm_NARR}'  from template '${DATM_NARR}'"

 cp -f ${DATM_NARR} ${datm_NARR}

 ${SUBSTITUTE} ${datm_NARR} MyIRENEdir    ${IreneDir}

 echo

 exit 0
