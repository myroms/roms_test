!
      SUBROUTINE ana_wwave (ng, tile, model)
!
!! git $Id$
!!======================================================================
!! Copyright (c) 2002-2025 The ROMS Group                              !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.md                                               !
!=======================================================================
!                                                                      !
!  This subroutine sets wind induced wave amplitude, direction and     !
!  period to be used in the bottom boundary layer formulation.         !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_forces
      USE mod_grid
      USE mod_ncparam
!
! Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
!
! Local variable declarations.
!
      character (len=*), parameter :: MyFile =                          &
     &  __FILE__
!
#include "tile.h"
!
      CALL ana_wwave_tile (ng, tile, model,                             &
     &                     LBi, UBi, LBj, UBj,                          &
     &                     IminS, ImaxS, JminS, JmaxS,                  &
#if defined BBL_MODEL || defined WEC
     &                     FORCES(ng) % Dwave,                          &
#endif
#if defined WAVES_OCEAN || (defined WEC_VF && defined BOTTOM_STREAMING)
     &                     FORCES(ng) % Dissip_fric,                    &
#endif
#if defined TKE_WAVEDISS   || defined WAVES_OCEAN    || \
    defined WDISS_THORGUZA || defined WDISS_CHURTHOR || \
    defined WAVES_DISS
     &                     FORCES(ng) % Dissip_break,                   &
     &                     FORCES(ng) % Dissip_wcap,                    &
#endif
#ifdef WAVES_HEIGHT
     &                     FORCES(ng) % Hwave,                          &
#endif
#ifdef WAVES_LENGTH
     &                     FORCES(ng) % Lwave,                          &
#endif
#ifdef WAVES_LENGTHP
     &                     FORCES(ng) % Lwavep,                         &
#endif
#ifdef WAVES_TOP_PERIOD
     &                     FORCES(ng) % Pwave_top,                      &
#endif
#ifdef WAVES_BOT_PERIOD
     &                     FORCES(ng) % Pwave_bot,                      &
#endif
#ifdef WAVES_UB
     &                     FORCES(ng) % Uwave_rms,                      &
#endif
     &                     GRID(ng) % angler,                           &
     &                     GRID(ng) % h)
!
! Set analytical header file name used.
!
#ifdef DISTRIBUTE
      IF (Lanafile) THEN
#else
      IF (Lanafile.and.(tile.eq.0)) THEN
#endif
        ANANAME(37)=MyFile
      END IF
!
      RETURN
      END SUBROUTINE ana_wwave
!
!***********************************************************************
      SUBROUTINE ana_wwave_tile (ng, tile, model,                       &
     &                           LBi, UBi, LBj, UBj,                    &
     &                           IminS, ImaxS, JminS, JmaxS,            &
#if defined BBL_MODEL || defined WEC
     &                           Dwave,                                 &
#endif
#if defined WAVES_OCEAN || (defined WEC_VF && defined BOTTOM_STREAMING)
     &                           Dissip_fric,                           &
#endif
#if defined TKE_WAVEDISS   || defined WAVES_OCEAN    || \
    defined WDISS_THORGUZA || defined WDISS_CHURTHOR || \
    defined WAVES_DISS
     &                           Dissip_break, Dissip_wcap,             &
#endif
#ifdef WAVES_HEIGHT
     &                           Hwave,                                 &
#endif
#ifdef WAVES_LENGTH
     &                           Lwave,                                 &
#endif
#ifdef WAVES_LENGTHP
     &                           Lwavep,                                &
#endif
#ifdef WAVES_TOP_PERIOD
     &                           Pwave_top,                             &
#endif
#ifdef WAVES_BOT_PERIOD
     &                           Pwave_bot,                             &
#endif
#ifdef WAVES_UB
     &                           Uwave_rms,                             &
#endif
     &                           angler, h)
!***********************************************************************
!
      USE mod_param
      USE mod_scalars
!
      USE exchange_2d_mod, ONLY : exchange_r2d_tile
#ifdef DISTRIBUTE
      USE mp_exchange_mod, ONLY : mp_exchange2d
#endif
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
!
#ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: angler(LBi:,LBj:)
      real(r8), intent(in) :: h(LBi:,LBj:)
# if defined BBL_MODEL || defined WEC
      real(r8), intent(inout) :: Dwave(LBi:,LBj:)
# endif
# if defined WAVES_OCEAN || (defined WEC_VF && defined BOTTOM_STREAMING)
      real(r8), intent(inout) :: Dissip_fric(LBi:,LBj:)
# endif
# if defined TKE_WAVEDISS   || defined WAVES_OCEAN || \
     defined WDISS_THORGUZA || defined WDISS_CHURTHOR || \
     defined WAVES_DISS
      real(r8), intent(inout) :: Dissip_break(LBi:,LBj:)
      real(r8), intent(inout) :: Dissip_wcap(LBi:,LBj:)
# endif
# ifdef WAVES_HEIGHT
      real(r8), intent(inout) :: Hwave(LBi:,LBj:)
# endif
# ifdef WAVES_LENGTH
      real(r8), intent(inout) :: Lwave(LBi:,LBj:)
# endif
# ifdef WAVES_LENGTHP
      real(r8), intent(inout) :: Lwavep(LBi:,LBj:)
# endif
# ifdef WAVES_TOP_PERIOD
      real(r8), intent(inout) :: Pwave_top(LBi:,LBj:)
# endif
# ifdef WAVES_BOT_PERIOD
      real(r8), intent(inout) :: Pwave_bot(LBi:,LBj:)
# endif
# ifdef WAVES_UB
      real(r8), intent(inout) :: Uwave_rms(LBi:,LBj:)
# endif

#else

      real(r8), intent(in) :: angler(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: h(LBi:UBi,LBj:UBj)
# if defined BBL_MODEL || defined WEC
      real(r8), intent(inout) :: Dwave(LBi:UBi,LBj:UBj)
# endif
# if defined WAVES_OCEAN || (defined WEC_VF && defined BOTTOM_STREAMING)
      real(r8), intent(inout) :: Dissip_fric(LBi:UBi,LBj:UBj)
# endif
# if defined TKE_WAVEDISS   || defined WAVES_OCEAN    || \
     defined WDISS_THORGUZA || defined WDISS_CHURTHOR || \
     defined WAVES_DISS
      real(r8), intent(inout) :: Dissip_break(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: Dissip_wcap(LBi:UBi,LBj:UBj)
# endif
# ifdef WAVES_HEIGHT
      real(r8), intent(inout) :: Hwave(LBi:UBi,LBj:UBj)
# endif
# ifdef WAVES_LENGTH
      real(r8), intent(inout) :: Lwave(LBi:UBi,LBj:UBj)
# endif
# ifdef WAVES_LENGTHP
      real(r8), intent(inout) :: Lwavep(LBi:UBi,LBj:UBj)
# endif
# ifdef WAVES_TOP_PERIOD
      real(r8), intent(inout) :: Pwave_top(LBi:UBi,LBj:UBj)
# endif
# ifdef WAVES_BOT_PERIOD
      real(r8), intent(inout) :: Pwave_bot(LBi:UBi,LBj:UBj)
# endif
# ifdef WAVES_UB
      real(r8), intent(inout) :: Uwave_rms(LBi:UBi,LBj:UBj)
# endif
#endif
!
!  Local variable declarations.
!
      integer :: i, j
!
      real(r8) :: cff, wdir
#if defined LAKE_SIGNELL
      real(r8) :: cff1, mxst, ramp_u, ramp_time, ramp_d
#endif

#include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Set wind induced wave amplitude (m), direction (radians) and
!  period (s) at RHO-points.
!-----------------------------------------------------------------------
!
#if defined MARSH_TEST
      DO j=JstrT,JendT
        DO i=IstrT,IendT
          Hwave(i,j)=0.4_r8
          Dwave(i,j)=0.0_r8*deg2rad
          Pwave_bot(i,j)=8.0_r8
          Lwave(i,j)=20.0_r8
        END DO
      END DO
#else
      ana_wwave: no values provided for Hwave, Dwave, Pwave, Lwave.
#endif
!
!  Exchange boundary data.
!
      IF (EWperiodic(ng).or.NSperiodic(ng)) THEN
# if defined WAVES_DIR
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Dwave)
# endif
# if defined WAVES_OCEAN || (defined WEC_VF && defined BOTTOM_STREAMING)
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Dissip_fric)
# endif
# if defined TKE_WAVEDISS || defined WAVES_OCEAN || \
     defined WDISS_THORGUZA || defined WDISS_CHURTHOR || \
     defined WAVES_DISS
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Dissip_break)
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Dissip_wcap)
# endif
# ifdef WAVES_HEIGHT
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Hwave)
# endif
# ifdef WAVES_LENGTH
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Lwave)
# endif
# ifdef WAVES_LENGTHP
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Lwavep)
# endif
# ifdef WAVES_TOP_PERIOD
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Pwave_top)
# endif
# ifdef WAVES_BOT_PERIOD
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Pwave_bot)
# endif
# ifdef WAVES_UB
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        Uwave_rms)
# endif
      END IF
#if defined DISTRIBUTE
# if defined WAVES_DIR
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Dwave)
# endif
# if defined WAVES_OCEAN || (defined WEC_VF && defined BOTTOM_STREAMING)
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Dissip_fric)
# endif
# if defined TKE_WAVEDISS || defined WAVES_OCEAN || \
     defined WDISS_THORGUZA || defined WDISS_CHURTHOR || \
     defined WAVES_DISS
      CALL mp_exchange2d (ng, tile, model, 2,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Dissip_break, Dissip_wcap)
# endif
# ifdef WAVES_HEIGHT
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Hwave)
# endif
# ifdef WAVES_LENGTH
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Lwave)
# endif
# ifdef WAVES_LENGTHP
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Lwavep)
# endif
# ifdef WAVES_TOP_PERIOD
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Pwave_top)
# endif
# ifdef WAVES_BOT_PERIOD
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Pwave_bot)
# endif
# ifdef WAVES_UB
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Uwave_rms)
# endif
#endif
!
      RETURN
      END SUBROUTINE ana_wwave_tile
