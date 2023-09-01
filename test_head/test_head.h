/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2023 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Sediment Test Headland Case.
**
** Application flag:   TEST_HEAD
** Input scripts:      roms_test_head.in
**                     coupling_test_head.in
**                     sediment_test_head.in
*/

#define UV_ADV
#define DJ_GRADPS
#define SOLVE3D
#define MASKING
#define WET_DRY

#define SSH_TIDES
#define UV_TIDES

#define ANA_FSOBC
#define ANA_M2OBC

#ifdef SWAN_COUPLING
# define MCT_LIB
#endif

#ifdef MB_BBL
# define MB_CALC_ZNOT
#endif

#ifdef SG_BBL
# define SG_CALC_ZNOT
#endif

#ifdef SSW_BBL
# define SSW_CALC_ZNOT
#endif

#ifdef SOLVE3D

# define SPLINES_VDIFF
# define SPLINES_VVISC

# ifdef SEDIMENT
#  define SED_MORPH
# endif

# if defined GLS_MIXING || defined MY25_MIXING
#  define KANTHA_CLAYSON
#  define N2S2_HORAVG
#  define RI_SPLINES
# endif

# define ANA_STFLUX
# define ANA_SSFLUX
# define ANA_BPFLUX
# define ANA_BTFLUX
# define ANA_BSFLUX
# define ANA_SPFLUX
# define ANA_SRFLUX

#define UV_TIDES

#endif

#define ANA_SMFLUX

