#!/bin/csh -f
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2023 The ROMS/TOMS Group                         #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.txt                                              #
#######################################################################
#                                                                     #
#  Generalized Stability Theory: Optimal Perturbations                #
#                                                                     #
#  This script is used to set-up ROMS optimal perturbations           #
#  algorithm.                                                         #
#                                                                     #
#######################################################################

# Set ROOT of the directory to run application.  The following
# "dirname" command returns a path by removing any suffix from
# the last slash ('/').  It returns a path above current diretory.

set Dir=`dirname ${PWD}`

# Set basic state trajectory, forward file:

#set HISname=${Dir}/Forward/channel_his.nc
 set HISname=${Dir}/Data/channel_fwd_analytical.nc

 set FWDname=channel_fwd.nc

if (-e $FWDname) then
  /bin/rm $FWDname
endif
ln -s -v $HISname $FWDname

# Set tangent linear model initial conditions file: zero fields.

set ITLname=channel_itl.nc
if (-e $ITLname) then
  /bin/rm $ITLname
endif
ln -s -v ${Dir}/Data/channel_ini_zero.nc $ITLname
