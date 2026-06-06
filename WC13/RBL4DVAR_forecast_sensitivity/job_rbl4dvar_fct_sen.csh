#!/bin/csh -f
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2026 The ROMS Group                              #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.md                                               #
#######################################################################
#                                                                     #
# Strong/Weak constraint RBL4D-Var forecast observation sensitivity   #
# job script:                                                         #
#                                                                     #
# This script NEEDS to be run before any run:                         #
#                                                                     #
#   (1) It copies a new clean nonlinear model initial conditions      #
#       file. The nonlinear model is initialized from the             #
#       background or reference state.                                #
#   (2) It copies Lanczos vectors from previous RBL4D-Var run. They   #
#       are stored in 4D-Var data assimilation file.                  #
#   (3) It copies the adjoint sensitivy functional file for the       #
#       observation impact or sensitivity.                            #
#   (4) Specify model, initial conditions, boundary conditions, and   #
#       surface forcing error convariance input standard deviations   #
#       files.                                                        #
#   (5) Specify model, initial conditions, boundary conditions, and   #
#       surface forcing error convariance input/output normalization  #
#       factors filenames.                                            #
#   (6) Copy a clean copy of the observations NetCDF file.            #
#   (7) Create 4D-Var input script "rbl4dvar.in" from template and    #
#       specify the error covariance standard deviation, error        #
#       covariance normalization factors, and observation files to    #
#       be used.                                                      #
#                                                                     #
#######################################################################

# Set forward file snapshots intervals:

#set NHIS='daily'                    # NHIS=48
 set NHIS='2hours'                   # NHIS=4

 echo ' '
 echo 'Case 1: Forecast Error in the 37N Transport Metric'
 if ($NHIS == 'daily') then
   echo '(Processing files from daily snapshots forward trajectory)'
 else
   echo '(Processing files from every 2-hours snapshots forward trajectory)'
 endif
 echo ' '

# Set path definition to one directory up in the tree.

 set Dir=`dirname ${PWD}`

# Set string manipulations perl script.

 set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute

# Copy nonlinear model initial conditions file.
# (Here, ROMS checks for wc13_ini.nc but it is not used)

 if ($NHIS == 'daily') then
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG/wc13_dai.nc wc13_ini.nc
 else
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG_b/wc13_dai.nc wc13_ini.nc
 endif

# Copy Lanczos vectors from previous RBL4D-Var run. They are stored
# in 4D-Var data assimilation file.

 if ($NHIS == 'daily') then
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG/wc13_mod.nc wc13_lcz.nc
 else
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG_b/wc13_mod.nc wc13_lcz.nc
 endif

# Copy adjoint sensitivity functionals.
# (Here, ROMS checks for wc13_ads.nc but it is not used)

 if ($NHIS == 'daily') then
   cp -v ${Dir}/Data/wc13_foi_A_daily.nc wc13_foi_A.nc
   cp -v ${Dir}/Data/wc13_foi_B_daily.nc wc13_foi_B.nc
   cp -v ${Dir}/Data/wc13_foi_B_daily.nc wc13_ads.nc
 else
   cp -v ${Dir}/Data/wc13_foi_A_2hours.nc wc13_foi_A.nc
   cp -v ${Dir}/Data/wc13_foi_B_2hours.nc wc13_foi_B.nc
   cp -v ${Dir}/Data/wc13_foi_B_2hours.nc wc13_ads.nc
 endif

# Copy the forecast trajectories.

 if ($NHIS == 'daily') then
   cp -v ${Dir}/RBL4DVAR_forecast_sensitivity/FCSTA/daily/wc13_fwd.nc wc13_fct_A.nc
   cp -v ${Dir}/RBL4DVAR_forecast_sensitivity/FCSTB/daily/wc13_fwd.nc wc13_fct_B.nc
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG/wc13_fwd_outer0.nc wc13_fwd.nc
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG/wc13_qck_outer0.nc wc13_qck.nc
 else
   cp -v ${Dir}/RBL4DVAR_forecast_sensitivity/FCSTA/2hours/wc13_fwd.nc wc13_fct_A.nc
   cp -v ${Dir}/RBL4DVAR_forecast_sensitivity/FCSTB/2hours/wc13_fwd.nc wc13_fct_B.nc
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG_b/wc13_fwd_outer0.nc wc13_fwd.nc
   cp -v ${Dir}/RBL4DVAR/EX3_RPCG_b/wc13_qck_outer0.nc wc13_qck.nc
 endif

# Set model, initial conditions, boundary conditions and surface
# forcing error covariance standard deviations files.

 set STDnameM=../Data/wc13_std_m.nc
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
  set NRMnameM=../Data/wc13_nrm_xy_multiscale_i.nc
  set NRMnameI=../Data/wc13_nrm_xy_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_xy_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_xy_multiscale_f.nc
 else if ( ${b_axis} == 2) then
  echo "Spatially-varying correlation: x-axis"
  set NRMnameM=../Data/wc13_nrm_x_multiscale_i.nc
  set NRMnameI=../Data/wc13_nrm_x_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_x_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_x_multiscale_f.nc
 else if ( ${b_axis} == 3) then
  echo "Spatially-varying correlation: y-axis"
  set NRMnameM=../Data/wc13_nrm_y_multiscale_i.nc
  set NRMnameI=../Data/wc13_nrm_y_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_y_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_y_multiscale_f.nc
 else 
  echo "Uniform correlation: x- and y-axis"
  set NRMnameM=../Data/wc13_nrm_uniform_multiscale_i.nc
  set NRMnameI=../Data/wc13_nrm_uniform_multiscale_i.nc
  set NRMnameB=../Data/wc13_nrm_uniform_multiscale_b.nc
  set NRMnameF=../Data/wc13_nrm_uniform_multiscale_f.nc
 endif
else
 echo "Mono-scale configuration, multiscale = ${multiscale}"
 set NRMnameM=../Data/wc13_nrm_m.nc
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

 set RBL4DVAR=rbl4dvar.in
 if (-e $RBL4DVAR) then
   /bin/rm $RBL4DVAR
 endif
 cp -v s4dvar.in $RBL4DVAR

 $SUBSTITUTE $RBL4DVAR roms_svc.nc   $SVCname
 $SUBSTITUTE $RBL4DVAR roms_std_m.nc $STDnameM
 $SUBSTITUTE $RBL4DVAR roms_std_i.nc $STDnameI
 $SUBSTITUTE $RBL4DVAR roms_std_b.nc $STDnameB
 $SUBSTITUTE $RBL4DVAR roms_std_f.nc $STDnameF
 $SUBSTITUTE $RBL4DVAR roms_std_c.nc $STDnameC
 $SUBSTITUTE $RBL4DVAR roms_nrm_m.nc $NRMnameM
 $SUBSTITUTE $RBL4DVAR roms_nrm_i.nc $NRMnameI
 $SUBSTITUTE $RBL4DVAR roms_nrm_b.nc $NRMnameB
 $SUBSTITUTE $RBL4DVAR roms_nrm_f.nc $NRMnameF
 $SUBSTITUTE $RBL4DVAR roms_obs.nc   $OBSname
 $SUBSTITUTE $RBL4DVAR roms_hss.nc   wc13_hss.nc
 $SUBSTITUTE $RBL4DVAR roms_lcz.nc   wc13_lcz.nc
 $SUBSTITUTE $RBL4DVAR roms_mod.nc   wc13_mod.nc
 $SUBSTITUTE $RBL4DVAR roms_err.nc   wc13_err.nc
