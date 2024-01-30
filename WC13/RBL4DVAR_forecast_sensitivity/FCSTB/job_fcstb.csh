#!/bin/csh -f
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2024 The ROMS/TOMS Group                         #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.md                                               #
#######################################################################
#                                                                     #
# Strong/Weak constraint RBL4D-Var forecast observation impact job    #
# script: Step 3 (GREEN FORECAST)                                     #
#                                                                     #
# This script NEEDS to be run before any run:                         #
#                                                                     #
#   (1) It copies a new clean nonlinear model initial conditions      #
#       file. The nonlinear model is initialized from the previous    #
#       cycle RBL4D-Var analysis.                                     #
#   (2) Sets the observation file to carry out VERIFICATION, which    #
#       interpolates NLM forecast at the observation locations.       #
#   (3) Copy a clean copy of the observations NetCDF file.            #
#   (4) Create 4D-Var input script "rbl4dvar.in" from template and    #
#       specify observation file to be used.                          #
#                                                                     #
#######################################################################

 echo ' '
 echo 'RBL4D-Var Forecast Observation Impact Configuration: Step 3'
 echo ' '

# Set path definition to two directories up in the tree.

 set Dir=`dirname ${PWD}`
 set Dir=`dirname ${Dir}`

# Set string manipulations perl script.

 set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute

# Set observations file for verification.

 set OBSname=forecast_obs.nc

# Get a clean copy of the observation file.  This is really
# important since this file is modified.

 cp -v ${Dir}/Data/${OBSname} .

# Modify 4D-Var template input script and specify above files

 set RBL4DVAR=rbl4dvar.in
 if (-e $RBL4DVAR) then
   /bin/rm $RBL4DVAR
 endif
 cp -v s4dvar.in $RBL4DVAR

 $SUBSTITUTE $RBL4DVAR roms_obs.nc $OBSname
 $SUBSTITUTE $RBL4DVAR roms_mod.nc wc13_mod.nc
