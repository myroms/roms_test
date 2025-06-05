/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Vegetation Test Case.
**
** Application flag:   VEGETATION_TEST
** Input script:       roms_vegetation_test.in
**                     sediment_vegetation_test.in
**                     vegetation.in
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

/* Vertical Mixing options */

#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
#endif

/* Bottom Boundary Layer options */

#ifdef SSW_BBL
# define SSW_CALC_ZNOT
# define SSW_LOGINT
# define SSW_LOGINT_WBL
#endif

/* Vegetation options */

#define VEGETATION
#ifdef VEGETATION
# define VEG_DRAG
# ifdef VEG_DRAG
#  define VEG_FLEX
#  define VEG_TURB
# endif
#endif


