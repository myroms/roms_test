/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Wind-Driven Constant Coriolis Basin Test.
**
** Application flag:   WINDBASIN
** Input script:       roms_windbasin.in
*/

#define UV_COR
#define UV_QDRAG
#define SPLINES_VDIFF
#define SPLINES_VVISC
#define SOLVE3D
#define ANA_GRID
#define ANA_INITIAL
#define ANA_SMFLUX
#define ANA_STFLUX
#define ANA_BTFLUX

