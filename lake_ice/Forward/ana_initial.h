!
      SUBROUTINE ana_initial (ng, tile, model)
!
!! git $Id$
!! svn $Id$
!!======================================================================
!! Copyright (c) 2002-2024 The ROMS/TOMS Group                         !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.txt                                              !
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
#ifdef SPHERICAL
     &                            GRID(ng) % lonr,                      &
     &                            GRID(ng) % latr,                      &
#else
     &                            GRID(ng) % xr,                        &
     &                            GRID(ng) % yr,                        &
#endif
#ifdef SOLVE3D
     &                            GRID(ng) % z_r,                       &
     &                            OCEAN(ng) % u,                        &
     &                            OCEAN(ng) % v,                        &
     &                            OCEAN(ng) % t,                        &
#endif
     &                            OCEAN(ng) % ubar,                     &
     &                            OCEAN(ng) % vbar,                     &
     &                            OCEAN(ng) % zeta)
#ifdef TANGENT
      ELSE IF ((model.eq.iTLM).or.(model.eq.iRPM)) THEN
        CALL ana_TLMinitial_tile (ng, tile, model,                      &
     &                            LBi, UBi, LBj, UBj,                   &
     &                            IminS, ImaxS, JminS, JmaxS,           &
     &                            kstp(ng),                             &
# ifdef SOLVE3D
     &                            nstp(ng),                             &
     &                            OCEAN(ng) % tl_u,                     &
     &                            OCEAN(ng) % tl_v,                     &
     &                            OCEAN(ng) % tl_t,                     &
# endif
     &                            OCEAN(ng) % tl_ubar,                  &
     &                            OCEAN(ng) % tl_vbar,                  &
     &                            OCEAN(ng) % tl_zeta)
#endif
#ifdef ADJOINT
      ELSE IF (model.eq.iADM) THEN
        CALL ana_ADMinitial_tile (ng, tile, model,                      &
     &                            LBi, UBi, LBj, UBj,                   &
     &                            IminS, ImaxS, JminS, JmaxS,           &
     &                            knew(ng),                             &
# ifdef SOLVE3D
     &                            nstp(ng),                             &
     &                            OCEAN(ng) % ad_u,                     &
     &                            OCEAN(ng) % ad_v,                     &
     &                            OCEAN(ng) % ad_t,                     &
# endif
     &                            OCEAN(ng) % ad_ubar,                  &
     &                            OCEAN(ng) % ad_vbar,                  &
     &                            OCEAN(ng) % ad_zeta)
#endif
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
#ifdef SPHERICAL
     &                                lonr, latr,                       &
#else
     &                                xr, yr,                           &
#endif
#ifdef SOLVE3D
     &                                z_r,                              &
     &                                u, v, t,                          &
#endif
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
#ifdef CHANNEL
# ifdef DISTRIBUTE
      USE distribute_mod, ONLY : mp_bcasti
# endif
      USE erf_mod, ONLY : ERF
#endif
      USE stats_mod, ONLY : stats_2dfld
#ifdef SOLVE3D
      USE stats_mod, ONLY : stats_3dfld
#endif
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
!
#ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: h(LBi:,LBj:)
# ifdef SPHERICAL
      real(r8), intent(in) :: lonr(LBi:,LBj:)
      real(r8), intent(in) :: latr(LBi:,LBj:)
# else
      real(r8), intent(in) :: xr(LBi:,LBj:)
      real(r8), intent(in) :: yr(LBi:,LBj:)
# endif
# ifdef SOLVE3D
      real(r8), intent(in) :: z_r(LBi:,LBj:,:)

      real(r8), intent(out) :: u(LBi:,LBj:,:,:)
      real(r8), intent(out) :: v(LBi:,LBj:,:,:)
      real(r8), intent(out) :: t(LBi:,LBj:,:,:,:)
# endif
      real(r8), intent(out) :: ubar(LBi:,LBj:,:)
      real(r8), intent(out) :: vbar(LBi:,LBj:,:)
      real(r8), intent(out) :: zeta(LBi:,LBj:,:)
#else
# ifdef SPHERICAL
      real(r8), intent(in) :: lonr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: latr(LBi:UBi,LBj:UBj)
# else
      real(r8), intent(in) :: xr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: yr(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(in) :: h(LBi:UBi,LBj:UBj)
# ifdef SOLVE3D
      real(r8), intent(in) :: z_r(LBi:UBi,LBj:UBj,N(ng))

      real(r8), intent(out) :: u(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(out) :: v(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(out) :: t(LBi:UBi,LBj:UBj,N(ng),3,NT(ng))
# endif
      real(r8), intent(out) :: ubar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: vbar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: zeta(LBi:UBi,LBj:UBj,:)
#endif
!
!  Local variable declarations.
!
      logical, save :: first = .TRUE.
!
      integer :: i, itrc, j, k
!
      real(r8) :: val
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
#if defined LAKE_ICE
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
#if defined LAKE_ICE
      DO j=JstrT,JendT
        DO i=IstrT,IendT
          zeta(i,j,1)=0.0_r8
        END DO
      END DO
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

#ifdef SOLVE3D
!
!-----------------------------------------------------------------------
!  Initial conditions for 3D momentum components (m/s).
!-----------------------------------------------------------------------
!
# if defined LAKE_ICE
      DO k=1,N(ng)
        DO j=JstrT,JendT
          DO i=IstrP,IendT
            u(i,j,k,1)=0.0_r8
          END DO
        END DO
        DO j=JstrP,JendT
          DO i=IstrT,IendT
            v(i,j,k,1)=0.0_r8
          END DO
        END DO
      END DO
# else
      DO k=1,N(ng)
       DO j=JstrT,JendT
         DO i=IstrP,IendT
            u(i,j,k,1)=0.0_r8
          END DO
        END DO
        DO j=JstrP,JendT
          DO i=IstrT,IendT
            v(i,j,k,1)=0.0_r8
          END DO
        END DO
      END DO
# endif
!
!  Report statistics.
!
      CALL stats_3dfld (ng, tile, iNLM, u3dvar, Stats(4), 0,            &
     &                  LBi, UBi, LBj, UBj, 1, N(ng), u(:,:,:,1))
      IF (DOMAIN(ng)%NorthEast_Corner(tile)) THEN
        WRITE (stdout,10) TRIM(Vname(2,idUvel))//': '//                 &
     &                    TRIM(Vname(1,idUvel)),                        &
     &                    ng, Stats(4)%min, Stats(4)%max
      END IF
      CALL stats_3dfld (ng, tile, iNLM, v3dvar, Stats(5), 0,            &
     &                  LBi, UBi, LBj, UBj, 1, N(ng), v(:,:,:,1))
      IF (DOMAIN(ng)%NorthEast_Corner(tile)) THEN
        WRITE (stdout,10) TRIM(Vname(2,idVvel))//': '//                 &
     &                    TRIM(Vname(1,idVvel)),                        &
     &                    ng, Stats(5)%min, Stats(5)%max
      END IF
!
!-----------------------------------------------------------------------
!  Initial conditions for tracer type variables.
!-----------------------------------------------------------------------
!
!  Set initial conditions for potential temperature (Celsius) and
!  salinity (PSU).
!
# if defined LAKE_ICE
      DO k=1,N(ng)
        DO j=JstrT,JendT
          DO i=IstrT,IendT
            val=TANH(0.5_r8*z_r(i,j,k)+12.0_r8)
            t(i,j,k,1,itemp)=3.0_r8+2.25_r8*val
#  ifdef SALINITY
            t(i,j,k,1,isalt)=10.0_r8-0.75_r8*val
#  endif
          END DO
        END DO
      END DO
# else
      DO k=1,N(ng)
        DO j=JstrT,JendT
          DO i=IstrT,IendT
            t(i,j,k,1,itemp)=T0(ng)
#  ifdef SALINITY
            t(i,j,k,1,isalt)=S0(ng)
#  endif
          END DO
        END DO
      END DO
# endif
!
!  Report statistics.
!
      DO itrc=1,NAT
        CALL stats_3dfld (ng, tile, iNLM, r3dvar, Stats(itrc+5), 0,     &
     &                    LBi, UBi, LBj, UBj, 1, N(ng), t(:,:,:,1,itrc))
        IF (DOMAIN(ng)%NorthEast_Corner(tile)) THEN
          WRITE (stdout,10) TRIM(Vname(2,idTvar(itrc)))//': '//         &
     &                      TRIM(Vname(1,idTvar(itrc))),                &
     &                      ng, Stats(itrc+5)%min, Stats(itrc+5)%max
        END IF
      END DO
#endif
!
  10  FORMAT (3x,' ANA_INITIAL - ',a,/,19x,                             &
     &        '(Grid = ',i2.2,', Min = ',1p,e15.8,0p,                   &
     &                         ' Max = ',1p,e15.8,0p,')')
!
      RETURN
      END SUBROUTINE ana_NLMinitial_tile

#ifdef TANGENT
!
!***********************************************************************
      SUBROUTINE ana_TLMinitial_tile (ng, tile, model,                  &
     &                                LBi, UBi, LBj, UBj,               &
     &                                IminS, ImaxS, JminS, JmaxS,       &
     &                                kstp,                             &
# ifdef SOLVE3D
     &                                nstp,                             &
     &                                tl_u, tl_v, tl_t,                 &
# endif
     &                                tl_ubar, tl_vbar, tl_zeta)
!***********************************************************************
!
      USE mod_param
      USE mod_scalars
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
      integer, intent(in) :: kstp
# ifdef SOLVE3D
      integer, intent(in) :: nstp
# endif
!
# ifdef ASSUMED_SHAPE
#  ifdef SOLVE3D
      real(r8), intent(out) :: tl_u(LBi:,LBj:,:,:)
      real(r8), intent(out) :: tl_v(LBi:,LBj:,:,:)
      real(r8), intent(out) :: tl_t(LBi:,LBj:,:,:,:)
#  endif
      real(r8), intent(out) :: tl_ubar(LBi:,LBj:,:)
      real(r8), intent(out) :: tl_vbar(LBi:,LBj:,:)
      real(r8), intent(out) :: tl_zeta(LBi:,LBj:,:)
# else
#  ifdef SOLVE3D
      real(r8), intent(out) :: tl_u(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(out) :: tl_v(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(out) :: tl_t(LBi:UBi,LBj:UBj,N(ng),3,NT(ng))
#  endif
      real(r8), intent(out) :: tl_ubar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: tl_vbar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: tl_zeta(LBi:UBi,LBj:UBj,:)
# endif
!
!  Local variable declarations.
!
      integer :: i, itrc, j, k

# include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Initial conditions for tangent linear 2D momentum (s/m) components.
!-----------------------------------------------------------------------
!
      DO j=JstrT,JendT
        DO i=IstrP,IendT
          tl_ubar(i,j,kstp)=0.0_r8
        END DO
      END DO
      DO j=JstrP,JendT
        DO i=IstrT,IendT
          tl_vbar(i,j,kstp)=0.0_r8
        END DO
      END DO
!
!-----------------------------------------------------------------------
!  Initial conditions for tangent linear free-surface (1/m).
!-----------------------------------------------------------------------
!
      DO j=JstrT,JendT
        DO i=IstrT,IendT
          tl_zeta(i,j,kstp)=0.0_r8
        END DO
      END DO
# ifdef SOLVE3D
!
!-----------------------------------------------------------------------
!  Initial conditions for tangent linear 3D momentum components (s/m).
!-----------------------------------------------------------------------
!
      DO k=1,N(ng)
       DO j=JstrT,JendT
         DO i=IstrP,IendT
            tl_u(i,j,k,nstp)=0.0_r8
          END DO
        END DO
        DO j=JstrP,JendT
          DO i=IstrT,IendT
            tl_v(i,j,k,nstp)=0.0_r8
          END DO
        END DO
      END DO
!
!-----------------------------------------------------------------------
!  Initial conditions for tangent linear active tracers (1/Tunits).
!-----------------------------------------------------------------------
!
      DO itrc=1,NAT
        DO k=1,N(ng)
          DO j=JstrT,JendT
            DO i=IstrT,IendT
              tl_t(i,j,k,nstp,itrc)=0.0_r8
            END DO
          END DO
        END DO
      END DO
# endif
!
      RETURN
      END SUBROUTINE ana_TLMinitial_tile
#endif

#ifdef ADJOINT
!
!***********************************************************************
      SUBROUTINE ana_ADMinitial_tile (ng, tile, model,                  &
     &                                LBi, UBi, LBj, UBj,               &
     &                                IminS, ImaxS, JminS, JmaxS,       &
     &                                knew,                             &
# ifdef SOLVE3D
     &                                nstp,                             &
     &                                ad_u, ad_v, ad_t,                 &
# endif
     &                                ad_ubar, ad_vbar, ad_zeta)
!***********************************************************************
!
      USE mod_param
      USE mod_scalars
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
      integer, intent(in) :: knew
# ifdef SOLVE3D
      integer, intent(in) :: nstp
# endif
!
# ifdef ASSUMED_SHAPE
#  ifdef SOLVE3D
      real(r8), intent(out) :: ad_u(LBi:,LBj:,:,:)
      real(r8), intent(out) :: ad_v(LBi:,LBj:,:,:)
      real(r8), intent(out) :: ad_t(LBi:,LBj:,:,:,:)
#  endif
      real(r8), intent(out) :: ad_ubar(LBi:,LBj:,:)
      real(r8), intent(out) :: ad_vbar(LBi:,LBj:,:)
      real(r8), intent(out) :: ad_zeta(LBi:,LBj:,:)
# else
#  ifdef SOLVE3D
      real(r8), intent(out) :: ad_u(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(out) :: ad_v(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(out) :: ad_t(LBi:UBi,LBj:UBj,N(ng),3,NT(ng))
#  endif
      real(r8), intent(out) :: ad_ubar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: ad_vbar(LBi:UBi,LBj:UBj,:)
      real(r8), intent(out) :: ad_zeta(LBi:UBi,LBj:UBj,:)
# endif
!
!  Local variable declarations.
!
      integer :: i, itrc, j, k

# include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Initial conditions for adjoint 2D momentum (s/m) components.
!-----------------------------------------------------------------------
!
      DO j=JstrT,JendT
        DO i=IstrP,IendT
          ad_ubar(i,j,knew)=0.0_r8
        END DO
      END DO
      DO j=JstrP,JendT
        DO i=IstrT,IendT
          ad_vbar(i,j,knew)=0.0_r8
        END DO
      END DO
!
!-----------------------------------------------------------------------
!  Initial conditions for adjoint free-surface (1/m).
!-----------------------------------------------------------------------
!
      DO j=JstrT,JendT
        DO i=IstrT,IendT
          ad_zeta(i,j,knew)=0.0_r8
        END DO
      END DO
# ifdef SOLVE3D
!
!-----------------------------------------------------------------------
!  Initial conditions for adjoint 3D momentum components (s/m).
!-----------------------------------------------------------------------
!
      DO k=1,N(ng)
        DO j=JstrT,JendT
          DO i=IstrP,IendT
            ad_u(i,j,k,nstp)=0.0_r8
          END DO
        END DO
        DO j=JstrP,JendT
          DO i=IstrT,IendT
            ad_v(i,j,k,nstp)=0.0_r8
          END DO
        END DO
      END DO
!
!-----------------------------------------------------------------------
!  Initial conditions for adjoint active tracers (1/Tunits).
!-----------------------------------------------------------------------
!
      DO itrc=1,NAT
        DO k=1,N(ng)
          DO j=JstrT,JendT
            DO i=IstrT,IendT
              ad_t(i,j,k,nstp,itrc)=0.0_r8
            END DO
          END DO
        END DO
      END DO
# endif
!
      RETURN
      END SUBROUTINE ana_ADMinitial_tile
#endif
