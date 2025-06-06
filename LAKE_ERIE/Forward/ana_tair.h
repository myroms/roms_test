!!
      SUBROUTINE ana_tair (ng, tile, model)
!
!! git $Id$
!!======================================================================
!! Copyright (c) 2002-2025 The ROMS Group                              !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.txt                                              !
!=======================================================================
!                                                                      !
!  This routine sets surface air temperature (degC) using an           !
!  analytical expression.                                              !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_forces
      USE mod_ncparam
!
! Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
!
!  Local variable declarations.
!
      character (len=*), parameter :: MyFile =                          &
     &  __FILE__
!
#include "tile.h"
!
      CALL ana_tair_tile (ng, tile, model,                              &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    IminS, ImaxS, JminS, JmaxS,                   &
     &                    FORCES(ng) % Tair)
!
! Set analytical header file name used.
!
#ifdef DISTRIBUTE
      IF (Lanafile) THEN
#else
      IF (Lanafile.and.(tile.eq.0)) THEN
#endif
        ANANAME(32)=MyFile
      END IF
!
      RETURN
      END SUBROUTINE ana_tair
!
!***********************************************************************
      SUBROUTINE ana_tair_tile (ng, tile, model,                        &
     &                          LBi, UBi, LBj, UBj,                     &
     &                          IminS, ImaxS, JminS, JmaxS,             &
     &                          Tair)
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
      real(r8), intent(out) :: Tair(LBi:,LBj:)
#else
      real(r8), intent(out) :: Tair(LBi:UBi,LBj:UBj)
#endif
!
!  Local variable declarations.
!
      integer :: i, j

#include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Set analytical surface air temperature (degC).
!-----------------------------------------------------------------------
!
#if defined LAKE_ERIE
      DO j=JstrT,JendT
        DO i=IstrT,IendT
          Tair(i,j)=5.0_r8+15.0_r8*COS(2.0_r8*pi*(tdays(ng)-220.0_r8)/  &
     &              365.25_r8)
        END DO
      END DO
#else
      ana_tair.h: no values provided for Tair.
#endif
!
!  Exchange boundary data.
!
      IF (EWperiodic(ng).or.NSperiodic(ng)) THEN
         CALL exchange_r2d_tile (ng, tile,                              &
     &                           LBi, UBi, LBj, UBj,                    &
     &                           Tair)
      END IF

#ifdef DISTRIBUTE
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    Tair)
#endif
!
      RETURN
      END SUBROUTINE ana_tair_tile
