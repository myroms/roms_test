/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2023 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Options for 4DVar Data Assimilation Toy.
**
** Application flag:   DOUBLE_GYRE
** Input script:       roms_double_gyre.in
**
**
** Available Driver options:  choose only one and activate it in the
**                            build.sh script (MY_CPP_FLAGS definition) 
**
** AD_SENSITIVITY             Adjoint Sensitivity
** AFT_EIGENMODES             Adjoint Finite Time Eigenmodes
** CORRELATION                Background-error Correlation Check
** GRADIENT_CHECK             TLM/ADM Gradient Check
** FORCING_SV                 Forcing Singular Vectors
** FT_EIGENMODES              Finite Time Eigenmodes
** I4DVAR_OLD                Old Incremental, strong constraint 4DVAR
** I4DVAR                    Incremental, strong constraint 4DVAR
** NLM_DRIVER                 Nonlinear Basic State trajectory
** OPT_PERTURBATION           Optimal perturbations
** PICARD_TEST                Picard Iterations Test
** R_SYMMETRY                 Representer Matrix Symmetry Test
** S4DVAR                     Strong constraint 4DVAR
** SANITY_CHECK               Sanity Check
** SO_SEMI                    Stochastic Optimals: Semi-norm
** TLM_CHECK                  Tangent Linear Model Check
** RBL4DVAR                    Weak constraint RBL4D-Var
** R4DVAR                     Weak constraint 4DVAR
*/

/*
**-----------------------------------------------------------------------------
**  Nonlinear basic state tracjectory.
**-----------------------------------------------------------------------------
*/

#if defined SOLVE3D                   /* 3D Application */
# define UV_ADV
# define UV_COR
# define UV_LDRAG
# define UV_VIS2
# define MIX_S_UV
# define DJ_GRADPS
# define SPLINES_VDIFF
# define SPLINES_VVISC
# define TS_DIF2
# define MIX_S_TS
# define TCLIMATOLOGY
# define TCLM_NUDGING
# define ANA_GRID
# define ANA_TCLIMA
# define ANA_SMFLUX
# define ANA_STFLUX
# define ANA_SSFLUX
# define ANA_BSFLUX
# define ANA_BTFLUX
#else                                 /* 2D Application */
# define UV_ADV
# define UV_COR
# define UV_LDRAG
# define UV_VIS2
# define ANA_GRID
# define ANA_SMFLUX
#endif

#ifdef NLM_DRIVER
# define AVERAGES
#endif

#ifdef VERIFICATION
# define FULL_GRID
#endif

/*
**-----------------------------------------------------------------------------
**  Variational Data Assimilation.
**-----------------------------------------------------------------------------
*/

/*
**  Options to compute error covariance normalization coefficients.
*/

#ifdef NORMALIZATION
# define CORRELATION
# define VCONVOLUTION
# define IMPLICIT_VCONV
# define FULL_GRID
# define FORWARD_WRITE
# define FORWARD_READ
# define FORWARD_MIXING
# define OUT_DOUBLE
#endif

/*
**  Options for adjoint-based algorithms sanity checks.
*/

#ifdef SANITY_CHECK
# define FULL_GRID
# define FORWARD_READ
# define FORWARD_WRITE
# define FORWARD_MIXING
# define OUT_DOUBLE
# define ANA_PERTURB
# define ANA_INITIAL
#endif


/*
**  Common options to all 4DVAR algorithms.
*/

#if defined ARRAY_MODES || defined CLIPPING            || \
    defined I4DVAR     || defined I4DVAR_ANA_SENSITIVITY || \
    defined RBL4DVAR     || defined RBL4DVAR_ANA_SENSITIVITY || \
    defined R4DVAR      || defined R4DVAR_ANA_SENSITIVITY
# define VCONVOLUTION
# define IMPLICIT_VCONV
# define BALANCE_OPERATOR
# ifdef BALANCE_OPERATOR
#  define ZETA_ELLIPTIC
# endif
# define FORWARD_WRITE
# define FORWARD_READ
# define FORWARD_MIXING
# define OUT_DOUBLE
#endif

/*
**  Special options for each 4DVAR algorithm.
*/

#if defined ARRAY_MODES || \
    defined R4DVAR      || defined R4DVAR_ANA_SENSITIVITY
# define RPM_RELAXATION
#endif


/*
**  Adjoint sensitivity.
*/

#if defined AD_SENSITIVITY
# define ANA_SCOPE
# define FORWARD_READ
# define OUT_DOUBLE
#endif

/*
**-----------------------------------------------------------------------------
**  Generalized Stability Theory analysis.
**-----------------------------------------------------------------------------
*/

#if defined AFT_EIGENMODES || defined FT_EIGENMODES    || \
    defined FORCING_SV     || defined OPT_PERTURBATION || \
    defined SO_SEMI
# define FORWARD_READ
#endif

