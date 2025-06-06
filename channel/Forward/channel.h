/*
** git $Id$
*******************************************************************************
** Copyright (c) 2002-2025 The ROMS Group                                    **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.md                                                     **
*******************************************************************************
**
** Options for periodic uniform channel
**
** Application flag:   CHANNEL
** Input script:       roms_channel.in
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
**  Nonlinear basic state settings.
**-----------------------------------------------------------------------------
*/

#define UV_ADV
#define UV_COR
#define UV_LDRAG
#define UV_VIS2

#define ANA_GRID
#define ANA_INITIAL

#ifdef SOLVE3D
# define DJ_GRADPS
# define TS_DIF2
# define MIX_S_TS
# define MIX_S_UV
# define ANA_SMFLUX
# define ANA_STFLUX
# define ANA_BTFLUX
#endif

#ifdef NLM_DRIVER
# define AVERAGES
#endif

#define OUT_DOUBLE

/*
**-----------------------------------------------------------------------------
**  Adjoint-based algorithms settings.
**-----------------------------------------------------------------------------
*/

#ifdef OPT_PERTURBATION
# define FORWARD_READ
# define FORWARD_MIXING
#endif

