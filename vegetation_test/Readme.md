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
   plot_vegetation.m        A Matlab script to plot the solution
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

The figures below show the impact of waves and a submerged vegetation patch
1.5 hours after initialization. These plots were generated from the output history NetCDF
file using the **plot_vegetation.m** Matlab script.

  |   U-momentum              |    V-momentum            |
  :--------------------------:|:-------------------------:
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/da54534c-1232-4e9f-915d-5e4e38b1f5e8"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/605bfcbc-1255-4b6e-9e35-9d48f69b36f1"> |
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/8e238058-ae64-4fe3-9550-4abbc4a2b117"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/fb7c0a77-7e32-47e9-aa2a-d0e6b513e01c"> |
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/19c5ee80-b2ed-4c77-a174-7664c5afcbfb"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/12c95a23-a63e-47b9-99e1-71a56cd8dd63"> |

The magnitude of the drag force terms in the momentum equations is shown in the figures
below, 1.5 hours after initialization. Their values represent averaged time values for ten
minutes (600 time steps). These plots were generated from the output NetCDF file for
diagnostic terms using the **plot_vegetation.m** Matlab script.

  |   U-momentum Diagnostics  |  V-momentum Diagnostics  |
  :--------------------------:|:-------------------------:
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/82658dea-ae22-4df7-be6d-097e546b878f"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/29f61753-399d-4bea-b080-f2a5c9a0944f"> |
  |<img width="400" alt="image" src="https://github.com/user-attachments/assets/afac7169-cc05-4e74-acba-dd1c337298eb"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/842ddc6e-88df-4bc4-b7d0-4373a74c8f90"> |
  
 ---

### References:

- Beudin, A.,  Kalra, T.S., Ganju, N.K., Warner, J.C., 2017: Development of a
  coupled wave-flow-vegetation interaction model, _Computers & Geosciences_,
  Vol **100**, 76-86, **doi**:10.1016/j.cageo.2016.12.010.

- Kalra, T.S., Ganju, N.K., Aretxabaleta, A.L., Carr, J.A., Zafer, D., Moriarty,
  J.M., 2021: Modeling Marsh Dynamics Using a 3-D Coupled Wave-Flow-Sediment Model,
  _Front. Mar. Sci._, Vol **8**, **doi**:10.3389/fmars.2021.740921.
