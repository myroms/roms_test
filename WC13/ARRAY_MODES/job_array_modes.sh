#!/bin/bash
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2026 The ROMS Group                              #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.md                                               #
#######################################################################
#                                                                     #
# Stabilized representer matrix array modes job BASH script:          #
#                                                                     #
# This script NEEDS to be run before any run:                         #
#                                                                     #
#   (1) It copies a new clean nonlinear model initial conditions      #
#       file. The nonlinear model is initialized from the             #
#       background or reference state.                                #
#   (2) It copies representer model initial condition, same as        #
#       nonlinear model.                                              #
#   (3) It copies Lanczos vectors from previous R4D-Var run. They     #
#       are stored in 4D-Var data assimilation file.                  #
#   (4) Specify model, initial conditions, boundary conditions, and   #
#       surface forcing error convariance input standard deviations   #
#       files.                                                        #
#   (5) Specify model, initial conditions, boundary conditions, and   #
#       surface forcing error convariance input/output normalization  #
#       factors filenames.                                            #
#   (6) Copy a clean copy of the observations NetCDF file.            #
#   (7) Create 4D-Var input script "r4dvar.in" from template and      #
#       specify the error covariance standard deviation, error        #
#       covariance normalization factors, and observation files to    #
#       be used.                                                      #
#                                                                     #
# Options:                                                            #
#                                                                     #
#  -ioda                 Configure for IODA-type observations         #
#                          job_rbl4dvar -ioda                         #
#                                                                     #
#  -mono                 Configure for Monoscale B                    #
#                          default: multiscale B                      #
#                                                                     #
#######################################################################

ioda=0
multiscale=1

while [ $# -gt 0 ]
do
  case "$1" in
    -ioda )
      shift
      ioda=1
      ;;

    -mono )
      shift
      multiscale=0
      ;;
  esac
done

 echo
 echo 'Array Modes Configuration:'
 echo

# Set forward file snapshots intervals:

#NHIS='daily'                        # NHIS=48
 NHIS='2hours'                       # NHIS=4

# Set path definition to one directory up in the tree.

 Dir=`dirname ${PWD}`

# Set string manipulations perl script.

 SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute

# Set NetCDF file suffix.

 Fsuffix="20040103"

# Copy nonlinear model initial conditions file.

 cp -vp ${Dir}/Data/INI/wc13_ini.nc wc13_ini.nc

# Copy representer model initial conditions file, same as nonlinear
# model.

 cp -p ${Dir}/Data/INI/wc13_ini.nc wc13_irp.nc

# Copy Lanczos vectors from previous RBL4D-Var run. They are stored
# in 4D-Var data assimilation file.

 if [[ ${NHIS} -eq 'daily' ]]; then
   cp -vp ${Dir}/RBL4DVAR/EX3_RPCG/wc13_mod.nc wc13_lcz.nc
 else
   cp -vp ${Dir}/RBL4DVAR/EX3_RPCG_b/wc13_mod.nc wc13_lcz.nc
 fi

# Set model, initial conditions, boundary conditions and surface
# forcing error covariance standard deviations files.

 STDnameM="../Data/STD/wc13_std_m.nc"
 STDnameI="../Data/STD/wc13_std_i.nc"
 STDnameB="../Data/STD/wc13_std_b.nc"
 STDnameF="../Data/STD/wc13_std_f.nc"

# Set output file for standard deviation computed/modeled from background
# (prior) state.

 STDnameC="wc13_std_computed.nc"

# Set spatially-varying background-error horizontal correlation length
# scales. The spatial variability in the file is either is X- or
# Y-directions. The opposite axis has constant length scales.
#
#   CorrType = 0            uniform, no correlation variability file
#   CorrType = 1            x- and y-axis correlation variability
#   CorrType = 2            x-axis correlation variability
#   CorrType = 3            y-axis correlation variability

#CorrType=0
 CorrType=1
#CorrType=2
#CorrType=3

if [[ ${CorrType} -eq 1 ]]; then
 SVCname="../Data/GRD/wc13_Bcorr_xy.nc"      # isotropic
elif [[ ${CorrType} -eq 2 ]]; then
 SVCname="../Data/GRD/wc13_Bcorr_x.nc"       # anisotropic
elif [[ ${CorrType} -eq 3 ]]; then
 SVCname="../Data/GRD/wc13_Bcorr_y.nc"       # anisotropic
else
 SVCname="../Data/GRD/wc13_Bcorr.nc"         # isotropic
fi

# Set model, initial conditions, boundary conditions and surface
# forcing error covariance normalization factors filenames.

if [[ ${multiscale} -eq 1 ]]; then
 echo
 echo "Multi-scale configuration, multiscale = ${multiscale}"
 echo

 if [[ ${CorrType} -eq 1 ]]; then
  echo "  CorrType = ${CorrType}, Spatially-varying correlation: x- and y-axis"
  NRMnameM="../Data/NRM/wc13_nrm_xy_multiscale_i.nc"
  NRMnameI="../Data/NRM/wc13_nrm_xy_multiscale_i.nc"
  NRMnameB="../Data/NRM/wc13_nrm_xy_multiscale_b.nc"
  NRMnameF="../Data/NRM/wc13_nrm_xy_multiscale_f.nc"
 elif [[ ${CorrType} -eq 2 ]]; then
  echo "  CorrType = ${CorrType}, Spatially-varying correlation: x-axis"
  NRMnameM="../Data/NRM/wc13_nrm_x_multiscale_i.nc"
  NRMnameI="../Data/NRM/wc13_nrm_x_multiscale_i.nc"
  NRMnameB="../Data/NRM/wc13_nrm_x_multiscale_b.nc"
  NRMnameF="../Data/NRM/wc13_nrm_x_multiscale_f.nc"
 elif [[ ${CorrType} == 3 ]]; then
  echo "  CorrType = ${CorrType}, Spatially-varying correlation: y-axis"
  NRMnameM="../Data/NRM/wc13_nrm_y_multiscale_i.nc"
  NRMnameI="../Data/NRM/wc13_nrm_y_multiscale_i.nc"
  NRMnameB="../Data/NRM/wc13_nrm_y_multiscale_b.nc"
  NRMnameF="../Data/NRM/wc13_nrm_y_multiscale_f.nc"
 else 
  echo "  CorrType = ${CorrType}, Uniform correlation: x- and y-axis"
  NRMnameM="../Data/NRM/wc13_nrm_uniform_multiscale_i.nc"
  NRMnameI="../Data/NRM/wc13_nrm_uniform_multiscale_i.nc"
  NRMnameB="../Data/NRM/wc13_nrm_uniform_multiscale_b.nc"
  NRMnameF="../Data/NRM/wc13_nrm_uniform_multiscale_f.nc"
 fi
else
 echo
 echo "Mono-scale configuration, multiscale = ${multiscale}"
 NRMnameM="../Data/NRM/wc13_nrm_monoscale_i.nc"
 NRMnameI="../Data/NRM/wc13_nrm_monoscale_i.nc"
 NRMnameB="../Data/NRM/wc13_nrm_monoscale_b.nc"
 NRMnameF="../Data/NRM/wc13_nrm_monoscale_f.nc"

#NRMnameI="../Data/NRM/wc13_nrm_i.nc
#NRMnameB="../Data/NRM/wc13_nrm_b.nc
#NRMnameF="../Data/NRM/wc13_nrm_f.nc
fi

echo
echo "  SVCname  = ${SVCname}"
echo "  NRMnameM = ${NRMnameM}"
echo "  NRMnameI = ${NRMnameI}"
echo "  NRMnameB = ${NRMnameB}"
echo "  NRMnameF = ${NRMnameF}"
echo

# Set observations file.

 echo "Observation files:"
 echo

 if [[ ${ioda} -eq 1 ]]; then
   OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_adt_${Fsuffix}.nc4"
#  OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_adt_area_${Fsuffix}.nc4"
#  OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_adt_time_${Fsuffix}.nc4"

   OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_sst_${Fsuffix}.nc4"
#  OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_sst_area_${Fsuffix}.nc4"
#  OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_sst_area_time12_${Fsuffix}.nc4"
#  OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_sst_time12_${Fsuffix}.nc4"

   OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_temp_${Fsuffix}.nc4"

   OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_salt_${Fsuffix}.nc4"

#  OBSname[${#OBSname[@]}]="../Data/OBS/wc13_obs_uv_codar_${Fsuffix}.nc4"
   OBSname[${#OBSname[@]}]="../Data/OBS/wc13_superobs_uv_codar_${Fsuffix}.nc4"

   NobsFiles=${#OBSname[@]}
 else
   OBSname="wc13_obs_${Fsuffix}.nc"
#  OBSname="wc13_obs_6hours.nc"
   NobsFiles=1
 fi

 echo "  NobsFiles = ${NobsFiles}"
 for obs in ${OBSname[@]}; do
   echo "  OBSname: ${obs}"
 done
 echo

# Get a clean copy of the observation file.  This is really
# important since this file is modified.

 if [[ ${ioda} -eq 0 ]]; then
   cp -vp ${Dir}/Data/OBS/${OBSname} .
 fi

# Modify 4D-Var template input script and specify above files.

 RBL4DVAR="rbl4dvar.in"
 if [[ -f ${RBL4DVAR} ]]; then
   /bin/rm ${RBL4DVAR}
 fi
 cp -v s4dvar.in ${RBL4DVAR}

 $SUBSTITUTE ${RBL4DVAR}  roms_svc.nc   ${SVCname}
 $SUBSTITUTE ${RBL4DVAR}  roms_std_m.nc ${STDnameM}
 $SUBSTITUTE ${RBL4DVAR}  roms_std_i.nc ${STDnameI}
 $SUBSTITUTE ${RBL4DVAR}  roms_std_b.nc ${STDnameB}
 $SUBSTITUTE ${RBL4DVAR}  roms_std_f.nc ${STDnameF}
 $SUBSTITUTE ${RBL4DVAR}  roms_std_c.nc ${STDnameC}
 $SUBSTITUTE ${RBL4DVAR}  roms_nrm_m.nc ${NRMnameM}
 $SUBSTITUTE ${RBL4DVAR}  roms_nrm_i.nc ${NRMnameI}
 $SUBSTITUTE ${RBL4DVAR}  roms_nrm_b.nc ${NRMnameB}
 $SUBSTITUTE ${RBL4DVAR}  roms_nrm_f.nc ${NRMnameF}
 $SUBSTITUTE ${RBL4DVAR}  MyNobsFiles   ${NobsFiles}
 $SUBSTITUTE ${RBL4DVAR}  roms_obs.nc   ${OBSname[@]}
 $SUBSTITUTE ${RBL4DVAR}  roms_hss.nc   wc13_hss.nc
 $SUBSTITUTE ${RBL4DVAR}  roms_lcz.nc   wc13_lcz.nc
 $SUBSTITUTE ${RBL4DVAR}  roms_lze.nc   wc13_lze.nc
 $SUBSTITUTE ${RBL4DVAR}  roms_mod.nc   wc13_mod_array_modes.nc
 $SUBSTITUTE ${RBL4DVAR}  roms_err.nc   wc13_err.nc
