/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2023 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Idealized Weddell Sea Application: Tides and Ice Shelf Test.
**
** Application flag:   WEDDELL
** Input script:       roms_wedell.in
*/

#define UV_ADV
#define DJ_GRADPS
#define UV_COR
#define UV_QDRAG
#define SPLINES_VDIFF
#define SPLINES_VVISC
#define SOLVE3D
#define SALINITY
#define NONLIN_EOS
#define CURVGRID

#define ANA_GRID
#define ANA_INITIAL
#define ANA_FSOBC
#define ANA_M2OBC
#define ANA_SMFLUX
#define ANA_STFLUX
#define ANA_SSFLUX
#define ANA_SRFLUX
#define ANA_BSFLUX
#define ANA_BTFLUX
