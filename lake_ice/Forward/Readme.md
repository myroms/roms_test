<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Lake Ice: ROMS Native Sea Ice Model Test

This directory includes various files to run the idealized **`LAKE_ICE`** to test **ROMS**'s native sea ice model. The single-layer sea ice models were initially written by Paul Budgell (2005), maintained by Kate Hedstrom, and updated by Scott Durski (Durski and Kurapov, 2019, 2020). It is primarily based on Mellor and Kantha (1989) and Parkinson and Washington (1979).

The sea-ice model has been cleaned, documented, redesigned, and rewritten to facilitate adjoint-based applications in the future. It has only one expandable state variable **Si(:,:,itime,iSice)** and one expandable internal field variable **Fi(:,:,iFice)**, where **iSice** and **iFice** are the state and internal field indices. The derived-type structures for the ice model state and internal arrays are as follows:

```
     TYPE T_ICE
        real(r8), pointer :: Fi(:,:,:)               ! [i,j,1:nIceF]
        real(r8), pointer :: Si(:,:,:,:)             ! [i,j,1:2,1:nIceS]
      END TYPE T_ICENgrids
      TYPE (T_ICE), allocatable :: ICE(:)            ! [Ngrids]
```
The sea ice model state variables **iSice** indices are:

| iSice | Index      | Description        |
|-------|------------|--------------------|
| 1     | **isAice** | Ice concentration (grid cell fraction) |
| 2     | **isHice** | Average ice thickness (m), ice mass divided by area |
| 3     | **isHmel** | Surface meltwater thickness on ice (m) |
| 4     | **isHsno** | Average thickness of snow coverage (m), mass snow |
| 5     | **isIage** | Age of ice |
| 6     | **isISxx** | Internal ice stress, xx-component (N/m) |
| 7     | **isISxy** | Internal ice stress, xy-component (N/m) |
| 8     | **isISyy** | Internal ice stress, yy-component (N/m) |
| 9     | **isTice** | Ice interior temperature (Celsius) |
| 10    | **isUice** | Ice U-velocity (m/s) |
| 11    | **isVice** | Ice V-velocity (m/s) |
| 12    | **isEnth** | Enthalpy of the ice/brine system, ice heat content |
| 13    | **isHage** | Thickness associated with the age of ice (m) |                              
| 14    | **isUevp** | Elastic-viscous-plastic ice U-velocity (m/s) |
| 15    | **isVevp** | Elastic-viscous-plastic ice V-velocity (m/s) |

The sea ice model internal field **iFice** indices are:

| iFice | Index      | Description        |
|-------|------------|--------------------|
| 1    | **icAIus** | Surface Air-Ice U-stress (N/m2) |
| 2    | **icAIvs** | Surface Air-Ice V-stress (N/m2) |
| 3    | **icBvis** | Ice bulk viscosity |
| 4    | **icHsse** | Sea surface elevation (m) |
| 5    | **icIOfv** | Ice-Ocean friction velocity (m/s) |
| 6    | **icIOmf** | Ice-Ocean mass flux (m/s) |
| 7    | **icIOmt** | Ice-Ocean momentum transfer coefficient (m/s) |
| 8    | **icIOvs** | Ice-Ocean velocity shear magnitude (m/s) |
| 9    | **icIsst** | Temperature at the snow/atmosphere interface (Celsius) |
| 10   | **icPgrd** | Gridded ice strength parameter (unitless) |
| 11   | **icPice** | Ice pressure or strength (N/m2) |
| 12   | **icQcon** | Gradient heat conductivity over ice/snow (W/m2/K) |
| 13   | **icQrhs** | RHS surface net heat flux over ice/snow (W/m2) |
| 14   | **icSvis** | Ice shear viscosity |  
| 15   | **icS0mk** | Salinity of molecular sublayer under ice (unitless) |
| 16   | **icT0mk** | Temperature of molecular sublayer under ice (Celsius) |
| 17   | **icUavg** | Vertically averaged mixed-layer U-velocity (m/s) |
| 18   | **icVavg** | Vertically averaged mixed-layer V-velocity (m/s) |
| 19   | **icWdiv** | Rate of ice divergence (m3/s) |
| 20   | **icW_ai** | Rate of melt/freeze at Air/Ice edge (m3/s) |
| 21   | **icW_ao** | Rate of melt/freeze at Air/Ocean edge (m3/s) |
| 22   | **icW_fr** | Rate of ice accretion due to frazil growth (m3/s) |
| 23   | **icW_io** | Rate of melt/freeze at Ice/Ocean edge (m3/s) |
| 24   | **icW_ro** | Rate of melt/freeze runoff into the ocean (m3/s) |

The sea model is activated with the C-preprocessing option **`ICE_MODEL`**, and there are options for its configuration:

| CPP Option          | Description        |
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

### How to Compile and ROMS:

- The sea ice model is only available in the GitHub branch **`feature/seaice`**. You have the option of downloading the code and checkout the branch **`feature/seaice`** or using the build script:

 ```
 git clone https://github.com/myroms/roms.git
 cd roms
 git checkout feature/seaice

or

 build_roms.sh -j 10 -b feature/main
 cbuild_roms.sh -j 10 -b feature/main
  ```
- To run, use:

  ```
  mpirun -n 12 romsM < roms_lake_ice.in > & log &
  ```

### The output Files:

```
 log                                              standard output/error
 roms_lake_ice_avg_0001.nc to *_0005.nc           ROMS 5-day average files
 roms_lake_ice_his_0001.nc to *_0005.nc           ROMS 5-day history files
 roms_lake_ice_qck_0001.nc to *_0005.nc           ROMS daily quicksave files for sea ice model
 roms_lake_ice_rst.nc                             ROMS restart file
 roms_lake_ice_sta.nc                             ROMS hourly stations file 
 ```
----

### ROMS Grid Configuration:

The idealized horizontal lake grid is **200x100x30** at **1.0x1.0** km resolution:

<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/210c9c80-d409-4f3a-808e-b3532c38eef2">

The locations of the output stations are denoted as **S1**, **S2**, **S3**, **S4**, **S5**, and **S6**. The sea ice model fields are written hourly at the selected stations. The vertical grid is well resolved in the upper **20 m** with a bathymetry range between **20-200 m**.

<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/a80725bc-fd73-4a75-bf14-72d75fa20339">

### Results:

Below are maps illustrating the solution's freezing and melting cycle in winter for year 2. ROMS was initialized on Jan 1, 2010, with idealized temperature and salinity profiles.

| Ice Concentration and Age | Winter Year 2            |
:--------------------------:|:-------------------------:
|<img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/90e90864-30e3-41b2-bc3a-979fd518fcf2"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/618e748e-32d4-41a8-badc-0f7d1e16b509"> |
|<img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/62ed6768-58e1-41e0-91c6-ab5fe2f8f7b9"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/d063e79a-8caf-4fc8-9770-0d3f3f853844"> |

| Ice and Meltwater Thicknesses | Winter Year 2            |
:------------------------------:|:-------------------------:
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/e919e475-771c-4fd1-bf10-950d57ee6427"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/fee07f8d-05b8-4531-b913-a16506a20868"> |
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/1d7a45f1-1bfa-4b39-90d4-c56353fd18d5"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/8af33698-50d5-45e0-9b23-9db8ec66c18a"> |

----

The **`STATION`** option was activated to output the ice model solution time series for 800 days of solution at hourly intervals.

| Heat Fluxes Forcing           | Wind Stress Forcing      |
:------------------------------:|:-------------------------:
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/a8b5bc20-ae27-4968-8742-4c3f6646d390"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/4288c57a-fa0c-4eeb-adbc-58488b4c58d0"> |

| Ice Concentration             | Ice Age.                 |
:------------------------------:|:-------------------------:
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ea79b196-a011-4c5f-b798-a859257528b4"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/6baf61c4-ff53-4fc1-bd89-0d0a07487dc4"> |

| Melt/Freeze Rates             | Meltponds Thickness      |
:------------------------------:|:-------------------------:
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/683a61f7-0b52-4a7b-9b1b-7d29c1cba997"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/6307e361-1015-46e9-91d0-e01e15d08c7d"> |

| Interior Ice Temperature      | Surface Ice/Snow Temperature |
:------------------------------:|:-----------------------------:
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/a8b04f08-c7db-4a1d-8906-86e8c8ab1cbf"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/132e9d1c-d632-44f9-b46c-4e1e31b5847f"> |

| Ice Velocity.                 | Free Surface              |
:------------------------------:|:--------------------------:
| <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/b22d3ac3-fc64-4386-9ca4-b07f7425d644"> | <img width="400" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/5da528b6-c647-42a4-a989-cffe6b5f6158"> |



---- 

**References:**

Durski, S.M., and A.L. Kurapov, 2019: A high-resolution coupled ice-ocean model of winter circulation on the Bering sea shelf. Part I: Ice model refinements and skill assessments, _Ocean Modelling_, **133**, 145-161, **doi**:10.1016/j.ocemod.2018.11.004.

Durski, S.M., and A.L. Kurapov, 2020: A high-resolution coupled ice-ocean model of winter circulation on the Bering Sea Shelf. Part II: Polynyas and the shelf salinity distribution, _Ocean Modelling_, 156, 101696, **doi:**/10.1016/j.ocemod.2020.101696.

Mellor, G.L. and L. Kantha, 1989: An Ice-Ocean Coupled Model, _J. Geophys. Res._, **94**, 10937-10954. 
