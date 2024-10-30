/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2024 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Lake Erie Test.
**
** Application flag:   LAKE_ERIE
** Input script:       roms_lake_erie_1000m.in
**                     roms_lake_erie_1200m.in
*/

#define UV_ADV
#define UV_U3HADVECTION
#define UV_COR
#define UV_LDRAG
#define UV_VIS2
#define MIX_S_UV
#define DJ_GRADPS

#define TS_DIF2
#define MIX_GEO_TS
#define SALINITY
#define SOLAR_SOURCE

#define SOLVE3D
#define CURVILINEAR
#define MASKING

#define ANA_BTFLUX
#define ANA_BSFLUX

#ifdef ICE_MODEL
# define ICE_THERMO
# define ICE_MK
# define ICE_ALBEDO
# define ICE_ALB_EC92
# define ICE_MOMENTUM
# define ICE_MOM_BULK
# define ICE_EVP
# define ICE_ADVECT
# define ICE_SMOLAR
# define ICE_UPWIND
# define ICE_CONVSNOW
#endif

#ifdef BULK_FLUXES
# ifdef ICE_MODEL
#  define ICE_BULK_FLUXES
# endif
# define EMINUSP
# define SHORTWAVE
#endif

#if defined GLS_MIXING || defined MY25_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
#endif

#ifdef LMD_MIXING
# define LMD_RIMIX
# define LMD_CONVEC
# define LMD_SKPP
# define LMD_BKPP
# define LMD_NONLOCAL
# define RI_SPLINES
#endif

#if defined BIO_FENNEL  || defined ECOSIM || \
    defined NPZD_POWELL || defined NEMURO
# define ANA_BIOLOGY
# define ANA_SPFLUX
# define ANA_BPFLUX
# define ANA_SRFLUX
#endif

#if defined NEMURO
# define HOLLING_GRAZING
# undef  IVLEV_EXPLICIT
#endif

#ifdef BIO_FENNEL
# define CARBON
# define DENITRIFICATION
# define BIO_SEDIMENT
# define DIAGNOSTICS_BIO
#endif
