#!/bin/bash
#
# git $Id$
#######################################################################
# Copyright (c) 2002-2024 The ROMS/TOMS Group                         #
#   Licensed under a MIT/X style license                              #
#   See License_ROMS.txt                                              #
#######################################################################
#                                                                     #
# CDEPS/CMEPS use mesh files to defined coupled component grid.       #
#                                                                     #
# This script creates grid mesh for DATA and ROMS components.         #
#                                                                     #
#######################################################################

# Set Hurricane Irene full or relative directory.

#IreneDir=~/ocean/repository/git/roms_test/IRENE
 IreneDir=../..

# Create DATA component MESH grids.

echo
echo "Creating ESMF MESH file for DATA component files:"
echo

for f in `ls -al ${IreneDir}/Data/FRC/*_IRENE.nc | awk '{print $9}'`
do
  bname=`basename $f .nc`
  out_file=${bname}_ESMFmesh.nc
  echo "  Procesing DATA file: $f"
  echo "  Creating  MESH file: $out_file"
  ncks -O --rgr infer --rgr scrip=scrip.nc $f foo.nc
  ESMF_Scrip2Unstruct scrip.nc ${out_file} 0
  rm -f foo.nc scrip.nc foo.nc ESMFmesh.nc PET*
done

# Create ROMS component MESH grid at RHO-points. Currently, it is
# only possible to the cell center in CMEPS.


echo
echo "Creating MESH file for DATA component files:"
echo

inp_file=${IreneDir}/Data/ROMS/irene_roms_grid.nc
out_file=`basename ${inp_file} .nc`_rho_ESMFmesh.nc

echo "  Processing DATA file: ${inp_file}"
echo "  Creating   MESH file: ${out_file}"

ncks -v lon_rho,lat_rho,mask_rho ${inp_file} grid.nc
ncrename -v lon_rho,lon -v lat_rho,lat -v mask_rho,mask grid.nc
ncks -O --rgr infer --rgr scrip=scrip.nc grid.nc foo.nc
ESMF_Scrip2Unstruct scrip.nc ${out_file} 0
rm -f foo.nc grid.nc scrip.nc PET*

exit 0