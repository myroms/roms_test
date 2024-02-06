<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Lake Ice: ROMS Native Sea Ice Model Test

This directory includes various files to run the idealized **`LAKE_ICE`** to test **ROMS**'s native sea ice model. The single-layer sea ice models were initially written by Paul Budgell (2005), maintained by Kate Hedstrom, and updated by Scott Durski (Durski and Kurapov, 2019, 2020). It is primarily based on Mellor and Kantha (1989) and Parkinson and Washington (1979).

The sea-ice model has been cleaned, documented, and redesigned to facilitate adjoint-based applications in the future. It has only two state variables, **Fi** and **Si**, that can be expanded. The original code has at least 39 arrays. It can be activated with the **`ICE_MODEL`** option.

```
! Define derived-type structure ice model state and internal arrays.
 
     TYPE T_ICE
        real(r8), pointer :: Fi(:,:,:)               ! [i,j,1:nIceF]
        real(r8), pointer :: Si(:,:,:,:)             ! [i,j,1:2,1:nIceS]
      END TYPE T_ICENgrids
      TYPE (T_ICE), allocatable :: ICE(:)            ! [Ngrids]

! Ice model state prognostic variables indices.

      integer, parameter :: nIceS = 15  ! number of ice state variables
      integer :: iSice(nIceS)           ! state I/O indices
      integer, parameter :: isAice =  1 ! ice concentration
      integer, parameter :: isHice =  2 ! ice thickness
      integer, parameter :: isHmel =  3 ! melt water thickness on ice
      integer, parameter :: isHsno =  4 ! snow thickness
      integer, parameter :: isIage =  5 ! ice age
      integer, parameter :: isISxx =  6 ! internal ice xx-stress
      integer, parameter :: isISxy =  7 ! internal ice xy-stress
      integer, parameter :: isISyy =  8 ! internal ice yy-stress
      integer, parameter :: isTice =  9 ! ice interior temperature
      integer, parameter :: isUice = 10 ! ice U-velocity
      integer, parameter :: isVice = 11 ! ice V-velocity
      integer, parameter :: isEnth = 12 ! ice/brine enthalpy
      integer, parameter :: isHage = 13 ! thickness linked with ice age
      integer, parameter :: isUevp = 14 ! EVP ice U-velocity
      integer, parameter :: isVevp = 15 ! EVP ice V-velocity

! Ice model internal variables indices.

      integer, parameter :: nIceF = 24  ! number of ice field variables
      integer :: iFice(nIceF)           ! internal fields I/O indices
      integer, parameter :: icAIus =  1 ! surface Air-Ice U-stress
      integer, parameter :: icAIvs =  2 ! surface Air-Ice V-stress
      integer, parameter :: icBvis =  3 ! ice bulk viscosity
      integer, parameter :: icHsse =  4 ! sea surface elevation
      integer, parameter :: icIOfv =  5 ! Ice-Ocean friction velocity
      integer, parameter :: icIOmf =  6 ! Ice-Ocean mass flux
      integer, parameter :: icIOmt =  7 ! Ice-Ocean momentum transfer
      integer, parameter :: icIOvs =  8 ! Ice-Ocean velocity shear
      integer, parameter :: icIsst =  9 ! ice/snow surface temperature
      integer, parameter :: icPgrd = 10 ! gridded ice strength
      integer, parameter :: icPice = 11 ! ice pressure or strength
      integer, parameter :: icQcon = 12 ! ice/snow heat conductivity
      integer, parameter :: icQrhs = 13 ! RHS heat flux over ice/snow
      integer, parameter :: icSvis = 14 ! ice shear viscosity
      integer, parameter :: icS0mk = 15 ! molecular sublayer salinity
      integer, parameter :: icT0mk = 16 ! molecular sublayer temperature
      integer, parameter :: icUavg = 17 ! average mixed-layer U-velocity
      integer, parameter :: icVavg = 18 ! average mixed-layer V-velocity
      integer, parameter :: icWdiv = 19 ! ice divergence rate
      integer, parameter :: icW_ai = 20 ! melt/freeze rate at Air/Ice
      integer, parameter :: icW_ao = 21 ! melt/freeze rate at Air/Ocean
      integer, parameter :: icW_fr = 22 ! ice accretion rate by Frazil
      integer, parameter :: icW_io = 23 ! melt/freeze rate at Ice/Ocean
      integer, parameter :: icW_ro = 24 ! melt/freeze rate runoff
```

**Sea Ice Model Associated Options:**

| Option              | Description        |
|---------------------|--------------------|
| **ALBEDO_CSIM**        | if CSIM albedo formulation |
| **ALBEDO_CURVE**       | if seawater albedo from curve |
| **ALBEDO_SZO**         | if zenith angle from Briegleb et al. (1986) |
| **ICE_MODEL**          | To activate ROMS native sea-ice model |
| **ICE_THERMO**         | If thermodynamic component |
| **ICE_MK**             | If Mellor-Kantha thermodynamics (only choice) |
| **ICE_ALBEDO**         | if surface albedo over water, snow, or ice |
| **ICE_ALB_EC92**       | If albedo computation from Ebert and Curry |
| **ICE_MOMENTUM**       | If momentum component |
| **ICE_MOM_BULK**       | If alternate ice-water stress computation |
| **ICE_EVP**            | If elastic-viscous-plastic rheology |
| **ICE_ADVECT**         | If advection of ice tracers |
| **ICE_SMOLAR**         | If MPDATA advection scheme |
| **ICE_UPWIND**         | If upwind advection scheme |
| **ICE_BULK_FLUXES**    | If ice part of bulk flux computation |
| **ICE_CONVSNOW**       | If the conversion of flooded snow to ice |
| **ICE_STRENGTH_QUAD**  | If quadratic ice strength, a function of thickness |
| **NO_SCORRECTION_ICE** | If no salinity correction under the ice |
| **OUTFLOW_MASK**       | If Hibler-style outflow cells |

### Test Important CPP options:

They are activated in the build scripts.

```
   AVERAGES                     Activates time-averaged output
   LAKE_ICE                     ROMS application CPP option
   BULK_FLUXES                  Activates COARE bulk parameterization of surface fluxes
   ICE_MODEL                    Includes Sea Ice Model kernel
   LMD_MIXING                   K-profile parameterization mixing (Large et al., 1994)
   STATIONS                     Activates output hourly station data
```

### Input NetCDF files:

```
                                ../Data/FRC/lake_ice_grd.nc
```

### Configuration and input scripts:

```
  build_roms.csh, .sh           GNU Make compiling and linking CSH and BASH script
  cbuild_roms.csh, .sh          CMake compiling and linking CSH and BASH script
  lake_ice.h                    ROMS header file
  lake_ice_stations.in          ROMS stations input script
  roms_lake_ice.in              ROMS standard input script
 ```


**References:**

Durski, S.M., and A.L. Kurapov, 2019: A high-resolution coupled ice-ocean model of winter circulation on the Bering sea shelf. Part I: Ice model refinements and skill assessments, _Ocean Modelling_, **133**, 145-161, **doi**:10.1016/j.ocemod.2018.11.004.

Durski, S.M., and A.L. Kurapov, 2020: A high-resolution coupled ice-ocean model of winter circulation on the Bering Sea Shelf. Part II: Polynyas and the shelf salinity distribution, _Ocean Modelling_, 156, 101696, **doi:**/10.1016/j.ocemod.2020.101696.

Mellor, G.L. and L. Kantha, 1989: An Ice-Ocean Coupled Model, _J. Geophys. Res._, **94**, 10937-10954. 
