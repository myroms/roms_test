/*
** svn $Id: test_chan.h 1154 2023-02-17 20:52:30Z arango $
*******************************************************************************
** Copyright (c) 2002-2023 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Options for Sediment Test Channel Case.
**
** Application flag:   TEST_CHAN
** Input scripts:      roms_test_chan.in
**                     sediment_test_chan.in
*/

#define UV_ADV
#define UV_LOGDRAG
#define SPLINES_VDIFF
#define SPLINES_VVISC
#define SOLVE3D

#define ANA_GRID
#define ANA_INITIAL
#define ANA_SMFLUX
#define ANA_STFLUX
#define ANA_BTFLUX
#ifdef SALINITY
# define ANA_SSFLUX
# define ANA_BSFLUX
#endif
#define ANA_SPFLUX
#define ANA_BPFLUX

#define ANA_FSOBC
#define ANA_M2OBC

#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
#endif

#ifdef SEDIMENT
# define ANA_SEDIMENT
# define SUSPLOAD
#endif
