<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## DuckNC Test Case: An Idealized Realistic Beach Test 

This directory includes various files to run an idealized coastal domain
configured with north-south periodic lateral boundary conditions and a
sloping beach on the western boundary that represents the bathymetry XZ-slice at
Duck, North Carolina, USA. This test is adapted from **COAWST**. It is forced with
wave data from the **SWAN** Model, which is read from an input NetCDF file. It is used to
test the **ROMS** Waves Effect on Currents (**WEC**) algorithm originally
reported by Uchiyama _et al._ (2010) and implemented in **ROMS** by Kumar _et al._
(2012) as part of the **COAWST** framework.

![ducknc_grd](https://github.com/user-attachments/assets/17739f45-a6f7-4c43-8755-987f4f84060e)

The following CPP options are available **`Vortex Force`** formulation of Uchiyama
_et al._ (2010) and Kumar _et al._ (2012) algorithm:

| CPP Option                  | Description               |
|-----------------------------|---------------------------|
| **BOTTOM_STREAMING**        | If wave current bottom streaming term |
| **ROLLER_SVENDSEN**         | If wave energy roller based on Svendsen (1984) |
| **ROLLER_MONO**             | if wave energy roller from monochromatic waves |
| **ROLLER_RENIERS**          | If wave energy roller based on Reniers (2004) |
| **SURFACE_STREAMERS**       | If wave current surface streaming term |
| **WAVE_MIXING**             | If enhanced vertical viscosity mixing from waves|
| **WDISS_CHURTHOR**          | If wave dissipation from Church and Thornton (1993) |
| **WDISS_GAMMA**             | If wave dissipation when using the **InWave** model |
| **WDISS_ROELVINK**          | If wave dissipation from Roelvink when using the **InWave** model |
| **WDISS_THORGUZA**          | If wave dissipation from Thornton and Guza (1986) |
| **WDISS_WAVEMOD**           | If wave dissipation is acquired from a coupled wave model |
| **WEC_VF**                  | If wave-current vortex force from Uchiyma _et al._  (2010) |
| **WEC**                     | **ROMS** internal option, which is activated in **globaldefs.h** |
| **WET_DRY**                 | If wetting and drying land/sea mask |

### Important CPP Options:
```
   DUCKNC                   Application CPP option
   WEC_VF                   Waves Effects on Currents, Vortex Force formulation
   DIAGNOSTICS_UV           Computing and writing momentum diagnostic terms
   GSL_MIXING               Generic Length-Scale turbulence closure
   MASKING                  Land/Sea masking
   ROLLER_RENIERS           Wave energy roller based on Reniers 2004
   SSW_BBL                  Sherwood/Signell/Warner Bottom Boundary Layer
   SSW_CALC_ZNOT            Internal computation of bottom roughness
   SSW_LOGINT               Bottom currents logarithmic interpolation
   SSW_LOGINT_WBL           Bottom currents logarithmic interpolation at wbl
   STATIONS                 Write out station data
   WET_DRY                  Wetting and drying masks 
```

### Input NetCDF Files:
```
   Grid File                Data/roms_duck94_grd.nc
   Initial Conditions File  Data/roms_duck94_ini_08302010.nc
   Forcing File 01:         Data/duck94_wind_08302010.nc
   Forcing File 02:         Data/wave_forcing_duck_02132010.nc
```
### Configuration and Input Scripts:
```
   build_roms.csh           ROMS GNU make compiling and linking CSH script
   build_roms.sh            ROMS GNU make compiling and linking BASH script
   cbuild_roms.csh          ROMS CMake compiling and linking CSH script
   cbuild_roms.sh           ROMS CMake compiling and linking BASH script
   ducknc.h                 DUCKNC header file with CPP options
   plot_ducknc.m            Matlab plotting script
   roms_ducknc.in           ROMS standard input script for DUCKNC
```

### How to Run this Application:

- To compile **ROMS** in parallel with the **PIO-NetCDF** library for output, use:
  ```
  build_roms.sh -pio -j 10
  ```

- Run **ROMS** with data assimilation:
  ```
  mpirun -np 4 romsM roms_ducknc.in > & log &
  ```

### Results:

- The figures below show the 2D slices from the **history NetCDF** file at **j=4** and
time record **10**. It is plotted using **plot_ducknc.m** Matlab script.
 
  |   NLM model               |  WEC model               |
  :--------------------------:|:-------------------------:
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/f5ddeeeb-c20a-488e-b0c6-cf4ccad12d9d"> | <img width="400" alt="image"  src="https://github.com/user-attachments/assets/5fbec408-457d-44e3-9dbd-38ad67f0d6e9"> |
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/7397d967-6607-453f-89cb-befc7b26e9b8"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/3b2f3d88-03da-46d1-9dd1-894b7fe5d89f"> |

- The figures below show the 2D slices from the **diagnostic NetCDF** file at **j=4** and
time record **10**. It plots various right-hand-side terms from the **u**-momentum governing equation.
They are also plotted using the **plot_ducknc.m** Matlab script.

  |   u-momentum Diagnostics  | u-momentum Diagnostics   |
  :--------------------------:|:-------------------------:
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/5c02c495-f902-4f3a-a152-b171b5503ff5"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/badfd967-961f-4b58-8804-016932734e63"> |
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/7edcc8dd-3728-4db2-934c-1c4231802775"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/7b10cd3f-816e-406c-af30-95780d1200c2"> |


 ---

### References:

- Kumar, N., G. Voulgaris, J.C. Warner, J.C., and M., Olabarrieta, 2012:
  Implementation of a vortex force formalism in the coupled 
  ocean-atmosphere-wave-sediment transport (COAWST) modeling system for
  inner-shelf and surf-zone applications, _Ocean Modeling_, **47**, 65-95,
  **doi**:10.1016/j.ocemod.2012.01.003

- Uchiyama, Y., J.C. McWilliams, and A.F. Shchepetkin, 2010:  Wave current
  interaction in an oceanic circulation model with a  vortex-force formalism:
  Applications to surf zone, _Ocean Modeling_, **34**, 16-35,
 **doi:** 10.1016/j.ocemod.2010.04.002.
