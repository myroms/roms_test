#!/bin/csh -f

# git $Id$
#::::::::::::::::::::::::::::::::::::::::::::::::::::: Hernan G. Arango :::
# Copyright (c) 2002-2023 The ROMS/TOMS Group                           :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.md                                                 :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#                                                                       :::
# This script can use to plot the results for the Finite Time           :::
# Eigenmodes (FTE) Driver using ROMS plotting package. The FTEs         :::
# are plotted from a single or multiple NetCDF files.                   :::
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

set NCGM="gmeta"
setenv NCARG_GKS_OUTPUT $NCGM

# Set Application grid NetCDF file

set grd_file=gyre3d_grd.nc

# Set application title.

set TITLE1=" "
set TITLE2=" "
set TITLE3=" "
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

# Set primary and secondary files to plot.

set pri_file=${MyDir}/gyre3d_tlm.nc
set sec_file=${MyDir}/gyre3d_adj.nc

set Lmulti=`ncdump -v LmultiGST ${pri_file} | grep 'LmultiGST =' | grep -oP '\d+'`
set   Nvec=`ncdump -v NEV       ${pri_file} | grep 'NEV ='       | grep -oP '\d+'`

echo " Lmulti = ${Lmulti} "
echo " Nvec   = ${Nvec} "

if ( $Lmulti == 1 ) then
  set Nrec=`ls -1 ${MyDir}/*_tlm_*.nc | wc -l`      # count files
  echo " Nfiles = ${Nrec} "
else
  set Nrec=`ncdump -h ${pri_file} | grep currently | grep -oP '\d+'`
  echo " Nrec   = ${Nrec} "
endif

echo " "

#=============================================================================

set n=0

while ($n < $Nrec)

  if ( $Lmulti == 1 ) then
    @ n += 1
    set vec=`printf "%03d" ${n}`
    set pri_file=${MyDir}/gyre3d_tlm_${vec}.nc
    set sec_file=${MyDir}/gyre3d_adj_${vec}.nc
    set Srec=-1
    set Erec=-`ncdump -h ${pri_file} | grep currently | grep -oP '\d+'`
    set DT=1
    if ( $Erec == -2 ) then
      set eigenvector="$n (real)"
    else
      set eigenvector="$n (complex)"
    endif
    echo " Plotting   ${pri_file},  Erec = ${Erec} ..."
  else
    @ n += 1
    if ( $n == 1 ) then
      set eigenvector=$n
      echo " Plotting   ${pri_file} ..."
    else
      @ eigenvector = (${n} + 1) / 2
    endif
    set Srec=-$n
    set Erec=-$n
    set DT=1
  endif


  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Free Surface Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
21             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.fs
else
  med -e 'r gmeta' -e 'a gmeta.fs' >> & $LOG
endif

#=============================================================================

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Vertically-Integrated U-momentum Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
13             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.ubar
else
  med -e 'r gmeta' -e 'a gmeta.ubar' >> & $LOG
endif

#=============================================================================

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Vertically-Integrated V-momentum Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
14             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.vbar
else
  med -e 'r gmeta' -e 'a gmeta.vbar' >> & $LOG
endif

#=============================================================================

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface U-momentum Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
1              field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.Usur
else
  med -e 'r gmeta' -e 'a gmeta.Usur' >> & $LOG
endif

#=============================================================================

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface U-momentum Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
2              field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.Vsur
else
  med -e 'r gmeta' -e 'a gmeta.Vsur' >> & $LOG
endif

#=============================================================================

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface Temperature Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
23             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.Tsur
else
  med -e 'r gmeta' -e 'a gmeta.Tsur' >> & $LOG
endif

#=============================================================================

  $CCNT >> & $LOG << EOF
$YEAR $YDAY
$TITLE1
$TITLE2
$TITLE3
Surface Salinity Eigenvector $eigenvector
1     NFIELDS: number of fields to plot. Line below, field(s) types:
24             field identification: FLDID(1:NFIELDS)
1     NLEVELS: number of depths/levels/isopycnals to plot (0 for all levels)
4              depths (<0), levels (>0) or isopycnals (>1000) to plot
$Srec FRSTD  : first day to plot
$Erec LASTD  : last day to plot
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
T     WRTHDR : logical switch to write out the plot header titles.
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

if ( $n == 1) then
  mv -f $NCGM gmeta.Ssur
else
  med -e 'r gmeta' -e 'a gmeta.Ssur' >> & $LOG
endif

# End of while loop.

end

/bin/rm gmeta
