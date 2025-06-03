/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Options for DUCK, NC Beach Test Case.
**
** Application flag:   DUCKNC
** Input scripts:      roms_ducknc.h
**
*/

#define UV_VIS2
#define MIX_S_UV
#define WET_DRY
#define UV_ADV
#define UV_C2ADVECTION
#define DJ_GRADPS
#define SOLVE3D
#define SPLINES_VVISC
#define SPLINES_VDIFF
#define MASKING

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

#if defined GLS_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
#endif

#ifdef SSW_BBL
# define SSW_CALC_ZNOT
# define SSW_LOGINT
#endif

#ifdef SEDIMENT
# define SUSPLOAD
# undef  BEDLOAD_SOULSBY
# undef  BEDLOAD_MPM
# define BEDLOAD_VANDERA
# ifdef BEDLOAD_VANDERA
#  define BEDLOAD_VANDERA_ASYM_LIMITS        /* define one or all 3 */
#  define BEDLOAD_VANDERA_SURFACE_WAVE
#  define BEDLOAD_VANDERA_WAVE_AVGD_STRESS
#  define BEDLOAD_VANDERA_MADSEN_UDELTA       /* define one of these 2 */
#  undef  BEDLOAD_VANDERA_DIRECT_UDELTA
# endif
# define SED_MORPH
# undef  SED_SLUMP
# undef  SLOPE_KIRWAN
# undef  SLOPE_NEMETH
# undef  SLOPE_LESSER
#endif

#if defined SEDIMENT || defined SG_BBL || defined MB_BBL || defined SSW_BBL
# define ANA_SEDIMENT
#endif
