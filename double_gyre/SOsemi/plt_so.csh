#!/bin/csh -f

# git $Id$
#::::::::::::::::::::::::::::::::::::::::::::::::::::: Hernan G. Arango :::
# Copyright (c) 2002-2023 The ROMS/TOMS Group                           :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.md                                                 :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#                                                                       :::
# This script can use to plot the results for the Stochastic Optimals   :::
# (SO) Driver(s) using ROMS plotting package. The SOs are plotted from  :::
# a single or multiple NetCDF files.                                    :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if ( ($#argv) > 0 ) then
  set MyDir=${PWD}/$1
else
  set MyDir=${PWD}
endif

# Set NCAR plotting source.

set PLTSRC="${HOME}/ocean/repository/plot"

# Set various plotting set-up files.

set var_file=${PLTSRC}/Data/varid.dat
set pa1_file=${PLTSRC}/Palettes/natlan1.pal
set pa2_file=${PLTSRC}/Palettes/natlan2.pal
set bth_file=${PLTSRC}/Palettes/topo2.pal
set vel_file=${PLTSRC}/Palettes/vel.pal
set par_file=${PLTSRC}/Data/default.cnt
set cst_file=${PLTSRC}/Data/NAeast_full.cst

# Set plot standard output file name.

set LOG="plt.log"

# Set output NCAR filename.

set NCGM="ncgm"
setenv NCARG_GKS_OUTPUT $NCGM

# Set Application grid NetCDF file

set grd_file=gyre3d_grd.nc

# Set application title.

set TITLE1="ROMS 3.0"
set TITLE2="Double Gyre Test Case"
set TITLE3="Generalized Stability Theory"
set TITLE4=" "

# Set various plotting standard input parameters.

set YEAR=2011
set YDAY=-1

set VINT=0              # vertical interpolation scheme      

set GRID=1.0
set BLAT=0.0
set TLAT=0.0
set LLON=0.0
set RLON=0.0

# Set ROMS plotting package executables and scripts to convert NCAR
# CGM files to GIF,

set CCNT="$HOME/bin/ccnt"
set CSEC="$HOME/bin/csec"
set NCGM2GIF="$HOME/bin/ncgm2www"
set MED="/opt/gfortransoft/serial/ncl_ncarg-5.2.1/bin/med"
set CONVERT=0
setenv NCARG_ROOT /opt/gfortransoft/serial/ncl_ncarg-5.2.1

#  Set output GIF files resolution

set RESOLUTION=512x512

#---------------------------------------------------------------------
# Loop over each assimilation cycle.
#---------------------------------------------------------------------

if ( -e $LOG ) then
  /bin/rm $LOG
endif

echo " "

date >> $LOG

set DT=0        # plotting interval (plot all records
set REC=0       # Starting time record (minus 1) to process

# Set primary and secondary files to plot.

set pri_file=${MyDir}/gyre3d_tlm.nc
set sec_file=${MyDir}/gyre3d_tlm.nc

set Fzeta=`ncdump -v Fzeta   ${pri_file} | grep 'Fzeta ='   | grep -oP '\d+'`
set Fuvel=`ncdump -v Fuvel   ${pri_file} | grep 'Fuvel ='   | grep -oP '\d+'`
set Fvvel=`ncdump -v Fvvel   ${pri_file} | grep 'Fvvel ='   | grep -oP '\d+'`
set Ftvar=`ncdump -v Ftracer ${pri_file} | grep 'Ftracer =' | grep -oP '\d+'`
set Ftsur=`ncdump -v Fstflx  ${pri_file} | grep 'Fstflx ='  | grep -oP '\d+'`
set Fustr=`ncdump -v Fsustr  ${pri_file} | grep 'Fsustr ='  | grep -oP '\d+'`
set Fvstr=`ncdump -v Fsvstr  ${pri_file} | grep 'Fsvstr ='  | grep -oP '\d+'`

set Ftemp=`echo $Ftvar | cut -d ' ' -f1`
set Fsalt=`echo $Ftvar | cut -d ' ' -f2`

echo " Plotting ${pri_file} ..."
echo "  "
echo "   Fzeta = $Fzeta"
echo "   Fuvel = $Fuvel"
echo "   Fvvel = $Fvvel"
echo "   Ftvar = $Ftvar"
echo "   Ftemp = $Ftemp "
echo "   Fsalt = $Fsalt "
echo "   Ftsur = $Ftsur"
echo "   Fustr = $Fustr"
echo "   Fvstr = $Fvstr"

#=============================================================================

if ( $Fzeta == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Free Surface Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
21             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.fs

endif

#=============================================================================

if ( $Fuvel == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface U-momentum Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
1              field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.Usur

endif

#=============================================================================

if ( $Fvvel == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface V-momentum Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
2              field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.Vsur

endif

#=============================================================================

if ( $Ftemp == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface Temperature Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
23             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.Tsur

endif

#=============================================================================

if ( $Fsalt == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface Salinity Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
24             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.Ssur

endif

#=============================================================================

if ( $Fustr == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface U-momentum Stress Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
68             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.sustr

endif

#=============================================================================

if ( $Fvstr == 1 ) then

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface V-momentum Stress Eigenvectors
1     NFIELDS: number of fields to plot. Line below, field(s) types:
69             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$REC  FRSTD  : first day to plot
$REC  LASTD  : last day to plot
$DT   DSKIP  : plot every other DSKIP days (see below)
0     FINDX  : forecast record to process, if any (atmospheric files only).
$VINT VINTRP : vertical interpolation scheme: 0=linear, 1:cubic splines
0     PMIN   : field minimum value for color palette (0.0 for default)
0     PMAX   : field maximum value for color palette (0.0 for default)
0     ICNT   : draw contours between color bands: 0=no, 1=yes
0.0   ISOVAL : iso-surface value to process (see below)
1.2   VLWD   : vector line width (1.0 for default)
2.0   VLSCL  : vector length scale (1.0 for default)
2     IVINC  : vector grid sampling in the X-direction (1 for default)
2     JVINC  : vector grid sampling in the Y-direction (1 for default)
0     IREF   : secondary or reference field option (see below)
15    IDOVER : overlay field identification (for IREF=1,2 only)
0     LEVOVER: level of the overlay field (set to 0 if same as current FLDLEV)
0.0   RMIN   : overlay field minimum value to consider (0.0 for default)
0.0   RMAX   : overlay field maximum value to consider (0.0 for default)
$GRID LGRID  : Desired longitude/latitude grid spacing (degrees)
2     IPROJ  : map projection (see below).
0.0   PLON   : projection Pole longitude (west values are negative).
0.0   PLAT   : projection Pole latitude (south values are negative).
0.0   ROTA   : projection rotation angle (clockwise; degrees).
1     LMSK   : flag to color mask land: [0] no, [1] yes
-1    NPAGE  : number of plots per page (currently 1, 2, or 4)  
F     READGRD: logical switch to read in positions from grid NetCDF file.
F     PLTLOGO: logical switch draw Logo.
F     WRTHDR : logical switch to write out the plot header titles.
T     WRTBLAB: logical switch to write out the plot bottom title.
T     WRTRANG: logical switch to write out data range values and CI.
F     WRTFNAM: logical switch to write out input primary filename.
F     WRTDATE: logical switch to write out current date.
F     CST    : logical switch to read and plot coastlines and islands.
$BLAT $TLAT  : bottom and top map latitudes (south values are negative).
$LLON $RLON  : left and right map longitudes (west values are negative).
$var_file
$pa1_file
$par_file
$pri_file
$sec_file
$grd_file
$cst_file
EOF

mv -f $NCGM gmeta.svstr

endif
