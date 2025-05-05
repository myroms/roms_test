/*
** svn $Id
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Mid-Atlantic Bight Application
**
** Application flag:   USEC
** Input script:       roms_nl_usec.in     ! not yet created
**                     roms_da_usec.in     ! not yet created
**
*/

/* Basic physics options */

#define UV_ADV
#define UV_COR
#define UV_VIS2
#define MIX_S_UV                  /* momentum mixing on s-surfaces */
#define TS_DIF2
#define MIX_GEO_TS                /* tracer mixing on constant z surfaces */
#define SOLVE3D
#define SALINITY
#define NONLIN_EOS

#define ATM_PRESS

/* Basic numerics options */

#define UV_U3HADVECTION
#define UV_C4VADVECTION
#define DJ_GRADPS
#define CURVGRID
#define MASKING


/* The following options are appropriate for NENA when run with 
   (1) HYCOM initial and open boundary data 
   (2) NCEP daily average surface marine atmospheric forcing data
   (3) tides */

/* Surface and bottom boundary conditions */

#define UV_QDRAG
#define GLS_MIXING
#define BULK_FLUXES

#define CRAIG_BANNER
#define CHARNOK
#define WIND_MINUS_CURRENT

#define PRIOR_BULK_FLUXES

#ifdef BULK_FLUXES
# undef  LONGWAVE        /* undef forces read net longwave */
# define LONGWAVE_OUT    /* define to read downward longwave, compute outgoing */
# define EMINUSP         /* evap from latent heat and combine with NCEP rain */
# undef  SRELAXATION
# undef  QCORRECTION
# undef  ANA_WINDS
#endif
#define SOLAR_SOURCE     /* solar shortwave distributed over water column */
#define ANA_BSFLUX
#define ANA_BTFLUX

/* Vertical subgridscale turbulence closure */

#ifdef MY25_MIXING
# define N2S2_HORAVG
# define KANTHA_CLAYSON
#endif
#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# undef  CANUTO_A
# define N2S2_HORAVG
#endif

/* Open boundary condition settings */

#define SSH_TIDES          /* Activated tides for initial, simple case */
#define UV_TIDES           /* Reactivated when tidal data acquired     */

#undef TIDE_GENERATING_FORCES

#ifdef SSH_TIDES
# undef RAMP_TIDES
# define ADD_FSOBC         /* Tide data is added to OBC from HYCOM */
#endif
#ifdef UV_TIDES
# define ADD_M2OBC         /* Tide data is added to OBC from HYCOM */
#endif

/*
**  Common options to all 4DVAR algorithms.
*/

#if defined ARRAY_MODES              || \
    defined CLIPPING                 || \
    defined I4DVAR                   || \
    defined I4DVAR_ANA_SENSITIVITY   || \
    defined RBL4DVAR                 || \
    defined RBL4DVAR_ANA_SENSITIVITY || \
    defined RBL4DVAR_FCT_SENSITIVITY || \
    defined R4DVAR                   || \
    defined R4DVAR_ANA_SENSITIVITY   || \
    defined SPLIT_I4DVAR             || \
    defined SPLIT_RBL4DVAR           || \
    defined SPLIT_R4DVAR
# define PRIOR_BULK_FLUXES
# define FORWARD_FLUXES
# define VCONVOLUTION
# define IMPLICIT_VCONV
# ifdef BALANCE_OPERATOR
#  define ZETA_ELLIPTIC
# endif
# define FORWARD_WRITE
# define FORWARD_READ
# define FORWARD_MIXING
#endif

/*
**  I/O files.
*/

#define NO_LBC_ATT

