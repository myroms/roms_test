#!/bin/csh -f
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2026 The ROMS Group                              #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.md                                               #
#######################################################################
#                                                                     #
# Incremental strong constraint I4D-Var job CSH script:               #
#                                                                     #
# This script NEEDS to be run before any run:                         #
#                                                                     #
#   (1) It copies a new clean nonlinear model initial conditions      #
#       file. The nonlinear model is initialized from the             #
#       background or reference state.                                #
#   (2) Specify initial conditions, boundary conditions, and surface  #
#       forcing error convariance input standard deviations files.    #
#   (3) Specify initial conditions, boundary conditions, and surface  #
#       forcing error convariance input/output normalization factors  #
#       files.                                                        #
#   (4) Copy a clean copy of the observations NetCDF file.            #
#   (5) Create 4D-Var input script "i4dvar.in" from template and      #
#       specify the error covariance standard deviation, error        #
#       covariance normalization factors, and observation files to    #
#       be used.                                                      #
#                                                                     #
#######################################################################

 echo ' '
 echo 'Incremental strong constraint I4D-Var Configuration:'
 echo ' '

# Set path definition to one directory up in the tree.

 set Dir=`dirname ${PWD}`

# Set string manipulations perl script.

 set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute

# Copy nonlinear model initial conditions file.

 cp -vp ${Dir}/Data/wc13_ini.nc wc13_ini.nc

# Set initial conditions, boundary conditions and surface forcing
# error covariance standard deviations files.

 set STDnameI=../Data/wc13_std_i.nc
 set STDnameB=../Data/wc13_std_b.nc
 set STDnameF=../Data/wc13_std_f.nc

# Set output file for standard deviation computed/modeled from background
# (prior) state.

 set STDnameC=wc13_std_computed.nc

# Set spatially-varying background-error correlation length scales.
# The spatial variability in the file is either is X- or Y-directions.
# The opposite axis has constant length scales.

 set multiscale = 0
#set multiscale = 1

 set b_axis = 0;                           # uniform, no variability file
#set b_axis = 1;                           # x- and y-axis variability
#set b_axis = 2;                           # x-axis variability
#set b_axis = 3;                           # y-axis variability

if ( ${b_axis} == 1) then
 set SVCname=../Data/wc13_Bcorr_xy.nc      # isotropic
else if ( ${b_axis} == 2) then
 set SVCname=../Data/wc13_Bcorr_x.nc       # anisotropic
else if ( ${b_axis} == 3) then
 set SVCname=../Data/wc13_Bcorr_y.nc       # anisotropic
else
 set SVCname=../Data/wc13_Bcorr.nc         # isotropic
endif

# Set model, initial conditions, boundary conditions and surface
# forcing error covariance normalization factors filenames.

if ( ${multiscale} == 1) then
 echo "Multi-scale configuration, multiscale = ${multiscale}"
 echo "b_axis = ${b_axis}"
 echo "SVCname = ${SVCname}"

 if ( ${b_axis} == 1) then
  echo "Spatially-varying correlation: x- and y-axis"
  set NRMnameI=../Data/wc13_nrm_xy_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_xy_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_xy_multiscale_f.nc
 else if ( ${b_axis} == 2) then
  echo "Spatially-varying correlation: x-axis"
  set NRMnameI=../Data/wc13_nrm_x_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_x_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_x_multiscale_f.nc
 else if ( ${b_axis} == 3) then
  echo "Spatially-varying correlation: y-axis"
  set NRMnameI=../Data/wc13_nrm_y_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_y_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_y_multiscale_f.nc
 else 
  echo "Uniform correlation: x- and y-axis"
  set NRMnameI=../Data/wc13_nrm_uniform_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_uniform_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_uniform_multiscale_f.nc
 endif
else
 echo "Mono-scale configuration, multiscale = ${multiscale}"
 set NRMnameI=../Data/wc13_nrm_i.nc
 set NRMnameB=../Data/wc13_nrm_b.nc
 set NRMnameF=../Data/wc13_nrm_f.nc
endif

# Set observations file.

 set OBSname=wc13_obs.nc

# Get a clean copy of the observation file.  This is really
# important since this file is modified.

 cp -vp ${Dir}/Data/${OBSname} .

# Modify 4D-Var template input script and specify above files.

 set I4DVAR=i4dvar.in
 if (-e $I4DVAR) then
   /bin/rm $I4DVAR
 endif
 cp -v s4dvar.in $I4DVAR

 $SUBSTITUTE $I4DVAR roms_svc.nc   $SVCname
 $SUBSTITUTE $I4DVAR roms_std_i.nc $STDnameI
 $SUBSTITUTE $I4DVAR roms_std_b.nc $STDnameB
 $SUBSTITUTE $I4DVAR roms_std_f.nc $STDnameF
 $SUBSTITUTE $I4DVAR roms_std_c.nc $STDnameC
 $SUBSTITUTE $I4DVAR roms_nrm_i.nc $NRMnameI
 $SUBSTITUTE $I4DVAR roms_nrm_b.nc $NRMnameB
 $SUBSTITUTE $I4DVAR roms_nrm_f.nc $NRMnameF
 $SUBSTITUTE $I4DVAR roms_obs.nc   $OBSname
 $SUBSTITUTE $I4DVAR roms_hss.nc   wc13_hss.nc
 $SUBSTITUTE $I4DVAR roms_lcz.nc   wc13_lcz.nc
 $SUBSTITUTE $I4DVAR roms_mod.nc   wc13_mod.nc
 $SUBSTITUTE $I4DVAR roms_err.nc   wc13_err.nc
