/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2023 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Options for Upwelling Test.
**
** Application flag:   UPWELLING
** Input script:       roms_upwelling.in
*/

#define UV_ADV
#define UV_COR
#define DJ_GRADPS
#define SPLINES_VDIFF
#define SPLINES_VVISC

#define SALINITY
#define SOLVE3D

#define ANA_GRID
#define ANA_INITIAL
#define ANA_SMFLUX
#define ANA_STFLUX
#define ANA_SSFLUX
#define ANA_BTFLUX
#define ANA_BSFLUX

#if defined GLS_MIXING || defined MY25_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
#else
# define ANA_VMIX
#endif

#if defined BIO_FENNEL  || defined ECOSIM      || \
    defined NEMURO      || defined NPZD_FRANKS || \
    defined NPZD_IRON   || defined NPZD_POWELL 
# define ANA_BIOLOGY
# define ANA_SPFLUX
# define ANA_BPFLUX
# define ANA_SRFLUX
# ifdef NPZD_IRON
#  define IRON_LIMIT
#  define IRON_RELAX
# endif
#endif

#if defined NEMURO
# define HOLLING_GRAZING
# undef  IVLEV_EXPLICIT
#endif

#ifdef BIO_FENNEL
# define CARBON
# define OXYGEN
# define DENITRIFICATION
# define BIO_SEDIMENT
# define DIAGNOSTICS_BIO
#endif

#ifdef ECOSIM
# define ANA_CLOUD
# define ANA_HUMIDITY
# define ANA_PAIR
# define ANA_TAIR
# define ANA_WINDS
#endif
