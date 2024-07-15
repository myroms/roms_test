!
      SUBROUTINE ana_initial (ng, tile, model)
!
!! git $Id$
!!======================================================================
!! Copyright (c) 2002-2024 The ROMS/TOMS Group                         !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.md                                               !
!=======================================================================
!                                                                      !
!  This subroutine sets initial conditions for momentum and tracer     !
!  type variables using analytical expressions.                        !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_grid
      USE mod_ncparam
      USE mod_ocean
      USE mod_stepping
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
      IF (model.eq.iNLM) THEN
        CALL ana_NLMinitial_tile (ng, tile, model,                      &
     &                            LBi, UBi, LBj, UBj,                   &
     &                            IminS, ImaxS, JminS, JmaxS,           &
     &                            GRID(ng) % h,                         &
     &                            GRID(ng) % xr,                        &
     &                            GRID(ng) % yr,                        &
     &                            OCEAN(ng) % ubar,                     &
     &                            OCEAN(ng) % vbar,                     &
     &                            OCEAN(ng) % zeta)
      END IF
!
! Set analytical header file name used.
!
#ifdef DISTRIBUTE
      IF (Lanafile) THEN
#else
      IF (Lanafile.and.(tile.eq.0)) THEN
#endif
        ANANAME(10)=MyFile
      END IF
!
      RETURN
      END SUBROUTINE ana_initial
!
!***********************************************************************
      SUBROUTINE ana_NLMinitial_tile (ng, tile, model,                  &
     &                                LBi, UBi, LBj, UBj,               &
     &                                IminS, ImaxS, JminS, JmaxS,       &
     &                                h,                                &
     &                                xr, yr,                           &
     &                                ubar, vbar, zeta)
!***********************************************************************
!
      USE mod_param
      USE mod_parallel
      USE mod_grid
      USE mod_ncparam
      USE mod_iounits
      USE mod_scalars
!
      USE stats_mod, ONLY : stats_2dfld
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
!
#ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: h(LBi:,LBj:)
      real(r8), intent(in) :: xr(LBi:,LBj:)
      real(r8), intent(in) :: yr(LBi:,LBj:)

      real(r8), intent(out) :: ubar(LBi:,LBj:,:)
      real(r8), intent(out) :: vbar(LBi:,LBj:,:)
      real(r8), intent(out) :: zeta(LBi:,LBj:,:)
#else
      real(r8), intent(in) :: h(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: xr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: yr(LBi:UBi,LBj:UBj)

      real(r8), intent(out) :: ubar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: vbar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: zeta(LBi:UBi,LBj:UBj,:)
#endif
!
!  Local variable declarations.
!
      logical, save :: first = .TRUE.
!
      integer :: i, j
!
      real(r8) :: val1, val2, val3, val4, x, x0, y, y0
!
      TYPE (T_STATS), save :: Stats(7)   ! ubar, vbar, zeta, u, v, t, s

#include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Initialize field statistics structure.
!-----------------------------------------------------------------------
!
      IF (first) THEN
        first=.FALSE.
        DO i=1,SIZE(Stats,1)
          Stats(i) % checksum=0_i8b
          Stats(i) % count=0.0_r8
          Stats(i) % min=Large
          Stats(i) % max=-Large
          Stats(i) % avg=0.0_r8
          Stats(i) % rms=0.0_r8
        END DO
      END IF
!
!-----------------------------------------------------------------------
!  Initial conditions for 2D momentum (m/s) components.
!-----------------------------------------------------------------------
!
#if defined SOLITON
      x0=2.0_r8*xl(ng)/3.0_r8
!!    x0=3.0_r8*xl(ng)/4.0_r8
      y0=0.5_r8*el(ng)
      val1=0.395_r8
      val2=0.771_r8*(val1*val1)
      IF (ng.eq.1) THEN
        DO j=JstrT,JendT
          DO i=IstrP,IendT
            x=0.5_r8*(xr(i-1,j)+xr(i,j))-x0
            y=0.5_r8*(yr(i-1,j)+yr(i,j))-y0
            val3=EXP(-val1*x)
            val4=val2*((2.0_r8*val3/(1.0_r8+(val3*val3)))**2)
            ubar(i,j,1)=0.25_r8*val4*(6.0_r8*y*y-9.0_r8)*               &
     &                  EXP(-0.5_r8*y*y)
          END DO
        END DO
        DO j=JstrP,JendT
          DO i=IstrT,IendT
            x=0.5_r8*(xr(i,j-1)+xr(i,j))-x0
            y=0.5_r8*(yr(i,j-1)+yr(i,j))-y0
            val3=EXP(-val1*x)
            val4=val2*((2.0_r8*val3/(1.0_r8+(val3*val3)))**2)
            vbar(i,j,1)=2.0_r8*val4*y*(-2.0_r8*val1*TANH(val1*x))*      &
     &                  EXP(-0.5_r8*y*y)
          END DO
        END DO
      ELSE
        DO j=JstrT,JendT
          DO i=IstrP,IendT
            ubar(i,j,1)=0.0_r8
          END DO
        END DO
        DO j=JstrP,JendT
          DO i=IstrT,IendT
            vbar(i,j,1)=0.0_r8
          END DO
        END DO
      END IF
#else
      DO j=JstrT,JendT
        DO i=IstrP,IendT
          ubar(i,j,1)=0.0_r8
        END DO
      END DO
      DO j=JstrP,JendT
        DO i=IstrT,IendT
          vbar(i,j,1)=0.0_r8
        END DO
      END DO
#endif
!
!  Report statistics.
!
      CALL stats_2dfld (ng, tile, iNLM, u2dvar, Stats(1), 0,            &
     &                  LBi, UBi, LBj, UBj, ubar(:,:,1))
      IF (DOMAIN(ng)%NorthEast_Corner(tile)) THEN
        WRITE (stdout,10) TRIM(Vname(2,idUbar))//': '//                 &
     &                    TRIM(Vname(1,idUbar)),                        &
     &                     ng, Stats(1)%min, Stats(1)%max
      END IF
      CALL stats_2dfld (ng, tile, iNLM, v2dvar, Stats(2), 0,            &
     &                  LBi, UBi, LBj, UBj, vbar(:,:,1))
      IF (DOMAIN(ng)%NorthEast_Corner(tile)) THEN
        WRITE (stdout,10) TRIM(Vname(2,idVbar))//': '//                 &
     &                    TRIM(Vname(1,idVbar)),                        &
     &                     ng, Stats(2)%min, Stats(2)%max
      END IF
!
!-----------------------------------------------------------------------
!  Initial conditions for free-surface (m).
!-----------------------------------------------------------------------
!
#if defined SOLITON
      IF (ng.eq.1) THEN
        x0=2.0_r8*xl(ng)/3.0_r8
!!      x0=3.0_r8*xl(ng)/4.0_r8
        y0=0.5_r8*el(ng)
        val1=0.395_r8
        val2=0.771_r8*(val1*val1)
        DO j=JstrT,JendT
          DO i=IstrT,IendT
            x=xr(i,j)-x0
            y=yr(i,j)-y0
            val3=EXP(-val1*x)
            val4=val2*((2.0_r8*val3/(1.0_r8+(val3*val3)))**2)
            zeta(i,j,1)=0.25_r8*val4*(6.0_r8*y*y+3.0_r8)*               &
     &                  EXP(-0.5_r8*y*y)
          END DO
        END DO
      ELSE
        DO j=JstrT,JendT
          DO i=IstrT,IendT
            zeta(i,j,1)=0.0_r8
          END DO
        END DO
      END IF
#else
      DO j=JstrT,JendT
        DO i=IstrT,IendT
          zeta(i,j,1)=0.0_r8
        END DO
      END DO
#endif
!
!  Report statistics.
!
      CALL stats_2dfld (ng, tile, iNLM, r2dvar, Stats(3), 0,            &
     &                  LBi, UBi, LBj, UBj, zeta(:,:,1))
      IF (DOMAIN(ng)%NorthEast_Corner(tile)) THEN
        WRITE (stdout,10) TRIM(Vname(2,idFsur))//': '//                 &
     &                    TRIM(Vname(1,idFsur)),                        &
     &                     ng, Stats(3)%min, Stats(3)%max
      END IF
!
  10  FORMAT (3x,' ANA_INITIAL - ',a,/,19x,                             &
     &        '(Grid = ',i2.2,', Min = ',1p,e15.8,0p,                   &
     &                         ' Max = ',1p,e15.8,0p,')')
!
      RETURN
      END SUBROUTINE ana_NLMinitial_tile
