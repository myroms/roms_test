#!/bin/csh -f
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2024 The ROMS/TOMS Group                         #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.md                                               #
#######################################################################
#                                                                     #
# Strong/Weak constraint RBL4D-Var job CSH script:                    #
#                                                                     #
# This script NEEDS to be run before any run:                         #
#                                                                     #
#   (1) It copies a new clean nonlinear model initial conditions      #
#       file. The nonlinear model is initialized from the             #
#       background or reference state.                                #
#   (2) Specify model, initial conditions, boundary conditions, and   #
#       surface forcing error convariance input standard deviations   #
#       files.                                                        #
#   (3) Specify model, initial conditions, boundary conditions, and   #
#       surface forcing error convariance input/output normalization  #
#       factors files.                                                #
#   (4) Copy a clean copy of the observations NetCDF file.            #
#   (5) Create 4D-Var input script "rbl4dvar.in" from template and    #
#       specify the error covariance standard deviation, error        #
#       covariance normalization factors, and observation files to    #
#       be used.                                                      #
#                                                                     #
#######################################################################

 echo ' '
 echo 'Strong/Weak Constraint RBL4D-Var Configuration:'
 echo ' '

# Set path definition to one directory up in the tree.

 set Dir=`dirname ${PWD}`

# Set string manipulations perl script.

 set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute

# Set NetCDF file suffix.

 set Fsuffix="_20040103"

# Copy nonlinear model initial conditions file.

cp -vp ${Dir}/Data/wc13_roms_ini${Fsuffix}.nc wc13_roms_ini${Fsuffix}.nc

# Set model, initial conditions, boundary conditions and surface
# forcing error covariance standard deviations files.

 set STDnameM=../Data/wc13_std_m.nc
 set STDnameI=../Data/wc13_std_i.nc
 set STDnameB=../Data/wc13_std_b.nc
 set STDnameF=../Data/wc13_std_f.nc

# Set output file for standard deviation computed/modeled from background
# (prior) state.

 set STDnameC=wc13_std_computed.nc

# Set model, initial conditions, boundary conditions and surface
# forcing error covariance normalization factors files.

 set NRMnameM=../Data/wc13_nrm_m.nc
 set NRMnameI=../Data/wc13_nrm_i.nc
 set NRMnameB=../Data/wc13_nrm_b.nc
 set NRMnameF=../Data/wc13_nrm_f.nc

# Set observations file.

 set OBSname=wc13_obs${Fsuffix}.nc

# Get a clean copy of the observation file.  This is really
# important since this file is modified.

 cp -vp ${Dir}/Data/${OBSname} .

# Modify 4D-Var template input script and specify above files.

 set RBL4DVAR=rbl4dvar.in
 if (-e $RBL4DVAR) then
   /bin/rm $RBL4DVAR
 endif
 cp -v s4dvar.in $RBL4DVAR

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
 $SUBSTITUTE $RBL4DVAR roms_hss.nc   wc13_hss${Fsuffix}.nc
 $SUBSTITUTE $RBL4DVAR roms_lcz.nc   wc13_lcz${Fsuffix}.nc
 $SUBSTITUTE $RBL4DVAR roms_lze.nc   wc13_lze${Fsuffix}.nc
 $SUBSTITUTE $RBL4DVAR roms_mod.nc   wc13_mod${Fsuffix}.nc
 $SUBSTITUTE $RBL4DVAR roms_err.nc   wc13_err${Fsuffix}.nc
