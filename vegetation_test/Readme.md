<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Vegetation Test Case: Idealized Aquatic Vegetation Test 

This directory contains various files to simulate an idealized vegetation patch,
along with a marsh face at the southern edge. It tests the effect of vegetation
on the inducing momentum changes to hydrodynamics and wave-current interactions.
The presence of the marsh cells is used to compute the impact of wave thrust on
the marsh face (Beudin _et al._, 2017).

<img width="800" alt="image" src="https://github.com/user-attachments/assets/8c99e256-0bef-4e17-84e5-4a4c2ac8ad8a" />

---

The following CPP options are available **`vegetation`** model algorithm (Beudin _et al._,
2017; Kalra _et al._, 2021):

| CPP Option                  | Description               |
|-----------------------------|---------------------------|
| **ANA_VEGETATION**          | If analytical vegetation initial conditions |
| **MARSH_DYNAMICS**          | If marsh dynamics: erosion, accretion, or retreat |
| **MARSH_SED_EROSION**       | If marsh sediment export via bedload exchange |
| **MARSH_TIDAL_RANGE**       | If tallying marsh mean tidal range |
| **MARSH_VERT_GROWTH**       | If marsh vertical growth through biomass production |
| **MARSH_WAVE_THRUST**       | If lateral wave thrust effects on marsh cells |
| **VEGETATION**              | If activating submerged/emergent aquatic vegetation model |  
| **VEG_DRAG**                | If activating drag effects due to waves and vegetation |
| **WVEG_STREAMING**          | If currents and wave dissipation due to vegetation |

### Important CPP Options:
```
   DIAGNOSTICS_UV           Computing and writing momentum diagnostic terms
   GSL_MIXING               Generic Length-Scale turbulence closure
   MASKING                  Land/Sea masking
   UV_LOGDRAG               Logarithmic bottom stress
   VEGETATION               Activating the submerged/emergent aquatic vegetation model
   VEGETATION_TEST          Application CPP option
   VEG_DRAG                 Computing drag effects due to waves and vegetation   
   WET_DRY                  Wetting and drying masks 
```

### Input NetCDF Files:
```
   Grid File                roms_vegetation_test_grd.nc
   Initial Conditions File  roms_vegetation_test_ini.nc
```
### Configuration and Input Scripts:
```
   build_roms.csh           ROMS GNU make compiling and linking CSH script
   build_roms.sh            ROMS GNU make compiling and linking BASH script
   cbuild_roms.csh          ROMS CMake compiling and linking CSH script
   cbuild_roms.sh           ROMS CMake compiling and linking BASH script
   roms_vegetation_test.in  ROMS standard input script for VEGETATION_TEST
   vegetation_test.h        VEGETATION_TEST header file with CPP options
   vegetation_test.in.      Vegetation model standard input script
```

### How to Run this Application:

- To compile **ROMS** in parallel with the **PIO-NetCDF** library for output, use:
  ```
  build_roms.sh -pio -j 10
  ```

- Run **ROMS** with data assimilation:
  ```
  mpirun -np 8 romsM roms_vegetation_test.in > & log &
  ```

### Results:

The figure below shows the free-surface solution at **j=5** and time record **8**. It
is plotted with the **plot_shoreface.m** Matlab script.


 ---

### References:

- Beudin, A.,  Kalra, T.S., Ganju, N.K., Warner, J.C., 2017: Development of a
  coupled wave-flow-vegetation interaction model, _Computers & Geosciences_,
  Vol **100**, 76-86, **doi**:10.1016/j.cageo.2016.12.010.

- Kalra, T.S., Ganju, N.K., Aretxabaleta, A.L., Carr, J.A., Zafer, D., Moriarty,
  J.M., 2021: Modeling Marsh Dynamics Using a 3-D Coupled Wave-Flow-Sediment Model,
  _Front. Mar. Sci._, Vol **8**, **doi**:10.3389/fmars.2021.740921.
