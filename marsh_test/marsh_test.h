/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Marsh Dynamics Test Case.
**
** Application flag:   MARSH_TEST
** Input script:       roms_marsh_test.in
**                     sediment_marsh_test.in
**                     vegetation_marsh_test.in
*/

#define UV_VIS2
#define MIX_S_UV
#define MASKING
#define WET_DRY
#define UV_ADV
#define DJ_GRADPS
#define SOLVE3D
#define SPLINES_VVISC
#define SPLINES_VDIFF

/* Analytical Options */

#define ANA_FSOBC
#define ANA_M2OBC
#define ANA_SMFLUX
#define ANA_STFLUX
#define ANA_SSFLUX
#define ANA_BPFLUX
#define ANA_BTFLUX
#define ANA_BSFLUX
#define ANA_SPFLUX
#define ANA_SRFLUX
#define ANA_SEDIMENT

#define ANA_WWAVE
#define WAVES_HEIGHT
#define WAVES_LENGTH

/* Vertical Mixing options */

#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# ifndef VEG_TURB
#  define N2S2_HORAVG
# endif
# define RI_SPLINES
#endif

/* Bottom Boundary Layer options */

#ifdef SSW_BBL
# define SSW_CALC_ZNOT
# define SSW_LOGINT
#endif

/* Vegetation options */

#ifdef VEGETATION
# define VEG_DRAG
# define MARSH_DYNAMICS
# define MARSH_BIOMASS_VEG
# define MARSH_SED_EROSION
# define MARSH_TIDAL_RANGE
# define MARSH_TIDAL_RANGE_INTERNAL
# define MARSH_VERT_GROWTH
# define MARSH_WAVE_THRUST
#endif

/* Vegetation options */

#ifdef SEDIMENT
# define SED_MORPH
# define SUSPLOAD
# define BEDLOAD_SOULSBY
# ifdef BEDLOAD_VANDERA
#  define BEDLOAD_VANDERA_ASYM_LIMITS
#  define BEDLOAD_VANDERA_SURFACE_WAVE
#  define BEDLOAD_VANDERA_WAVE_AVGD_STRESS
# endif
#endif
