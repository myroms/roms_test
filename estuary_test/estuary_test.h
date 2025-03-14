/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for Estuary with Sediment Transport Test.
**
** Application flag:   ESTUARY_TEST
** Input script:       roms_estuary_test.in
**                     sediment_estuary_test.in
*/

#define UV_ADV
#define UV_LOGDRAG
#define SPLINES_VDIFF
#define SPLINES_VVISC
#define SALINITY
#define SOLVE3D

#define SEDIMENT
#ifdef SEDIMENT
# define SUSPLOAD
#endif

#if defined GLS_MIXING || defined MY25_MIXING
# define KANTHA_CLAYSON
# undef  CANUTO_A
# define N2S2_HORAVG
# define RI_SPLINES
#endif

#define ANA_GRID
#define ANA_INITIAL
#define ANA_SEDIMENT
#define ANA_SMFLUX
#define ANA_STFLUX
#define ANA_BTFLUX
#define ANA_SSFLUX
#define ANA_BSFLUX
#define ANA_SPFLUX
#define ANA_BPFLUX
#define ANA_FSOBC
#define ANA_M2OBC
#define ANA_TOBC
