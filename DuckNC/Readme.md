<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Shoreface Test Case: An Idealized Planar Beach Test 

This directory includes various files to run an idealized coastal domain
configured with north-south periodic lateral boundary conditions and a
linearly sloping beach on the eastern boundary. It is forced with wave data from
the **SWAN** Model, which is read from an input NetCDF file. It is used to
test the **ROMS** Waves Effect on Currents (**WEC**) algorithm originally
reported by Uchiyama _et al._ (2010) and implemented in **ROMS** by Kumar _et al._
(2012) as part of the **COAWST** framework.

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
   WEC_VF                   Waves Effects on Currents, Vortex Force formulation
   GSL_MIXING               Generic Length-Scale turbulence closure
   MASKING                  Land/Sea masking
   SEDIMENT                 Cohesive and noncohesive sediments
   SHOREFACE                Application CPP option
   STATIONS                 Write out station data    
   UV_QDRAG                 Quadratic bottom stress
   WET_DRY                  Wetting and drying masks 
```

### Input NetCDF Files:
```
   Forcing File 01:         Data/swan_shoreface_angle_forc.nc
```
### Configuration and Input Scripts:
```
   build_roms.csh           ROMS GNU make compiling and linking CSH script
   build_roms.sh            ROMS GNU make compiling and linking BASH script
   cbuild_roms.csh          ROMS CMake compiling and linking CSH script
   cbuild_roms.sh           ROMS CMake compiling and linking BASH script
   plot_shoreface.m         Matlab plotting script
   roms_shoreface.in        ROMS standard input script for SHOREFACE
   sediment_shoreface.in.   ROMS sediment input configuration parameters
   shoreface.h              SHOREFACE header file with CPP options
   stations.in              Output station configuration parameters
```

### How to Run this Application:

- To compile **ROMS** in parallel with the **PIO-NetCDF** library for output, use:
  ```
  build_roms.sh -pio -j 10
  ```

- Run **ROMS** with data assimilation:
  ```
  mpirun -np 2 romsM shoreface.in > & log &
  ```

### Results:

The figure below shows the free-surface solution at **j=5** and time record **8**. It
is plotted with the **plot_shoreface.m** Matlab script.


![shoreface](https://github.com/user-attachments/assets/60d532da-2db0-46d9-b8d3-132dbf2ec841)

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
