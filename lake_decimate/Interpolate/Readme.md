<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Lake Decimate: ROMS Grid Extraction by Interpolation Test

This directory includes various files to run the idealized **`LAKE_DECIMATE`** to test **ROMS**'s solution extraction capabilities by decimation or horizontal interpolation, level-by-level, in 3D fields. It is activated with the **`GRID_EXTRACTION`** option. Here, we run the decimate case by coarsening the parent **1.0x1.0** km solution to **2.0x2.0** km, written into **lake_decimate_xtr.nc**.

▶️ The ROMS standard input script **`roms_lake_decimate.in`** includes new parameters:

 - **ExtractFlag:** ROMS solution extraction integer flag:

    - **`ExtractFlag = 1`**, extraction by horizontal interpolation, level-by-level. This option is not fully developed because a special interpolation algorithm is required in applications with land/sea masks. A generic remapping using the ESMF library is currently being developed for grid-to-grid interpolation, including land/sea masks.
    - **`ExtractFlag > 1`**, coarsening by decimation, level-by-level. For example, if **ExtractFlag=2**, the field data is sampled at every other point. This strategy is advantageous in mixed-resolution, split 4D-Var applications where the outer loop background (prior) trajectory may be computed at a higher resolution than in the inner loop minimization to accelerate the calculations. The decimated solution becomes the background nonlinear trajectory used to linearize the tangent linear (**TLM**) and adjoint (**ADM**) models.  In this case, to ensure that both fine and coarse grids at RHO points coincide at the domain boundary, the  following equalities must satisfied:
       - **MOD(Lm+1, ExtractFlag) = 0**
       - **MOD(Mm+1, ExtractFlag) = 0**

  - **GRXNAME:** The input extraction grid geometry NetCDF filename. It must be created with tools similar to the ROMS application grid and contained inside the parent grid.

   - **`XTRNAME:`** The output extracted solution NetCDF filename.

▶️ We provide the extraction fields geometry grid NetCDF file **`../Data/lake_decimate_grd_2km.nc`** at the input (**GRXNAME**). This grid must be created with tools like the parent **`../Data/lake_decimate_grd_1km.nc`** application grid and contained inside. 

### Test Important CPP options:

They are activated in the build scripts.

```
   AVERAGES                     Activates time-averaged output
   BULK_FLUXES                  Activates COARE bulk parameterization of surface fluxes
   CHECKSUM                     Reports checksum when processing I/O     
   GLS_MIXING                   Generic Length-Scale turbulence closure
   GRID_EXTRACT                 Writing output extraction history file
   LAKE_DECIMATE                ROMS application CPP option
   OUTPUT_STATS                 Reports output fields statistics
   STATIONS                     Activates output hourly station data
```

### Input NetCDF files:

```
                                ../Data/lake_decimate_grd_1km.nc
                                ../Data/lake_decimate_grd_2km.nc
                                ../Data/lake_decimate_ini_1km.nc
```

### Configuration and input scripts:

```
  ana_cloud.h                   Analytical cloud fraction
  ana_humidity.h                Analytical surface air humidity
  ana_pair.h                    Analytical surface air pressure
  ana_rain.h                    Analytical rain fall rate
  ana_smflux.h                  Analytical surface wind stress
  ana_srflux.h                  Analytical shortwace radiation
  ana_stflux.h                  Analytical surface heat flux
  ana_tair.h                    Analytical surface air temperature
  ana_winds.h                   Analytical surface wind components
  build_roms.csh, .sh           GNU Make compiling and linking CSH and BASH script
  cbuild_roms.csh, .sh          CMake compiling and linking CSH and BASH script
  lake_decimate.h               ROMS header file
  lake_decimate_stations.in     ROMS stations input script
  roms_lake_decimate.in         ROMS standard input script
 ```

### How to Compile and ROMS:

- Currently, the **GRID_EXTRACTION** capability is only available in the GitHub branch **`feature/decimate`**. You have the option of downloading the code and checkout the branch **`feature/decimate`** or using the build script:

 ```
 git clone https://github.com/myroms/roms.git
 cd roms
 git checkout feature/decimate

or

 build_roms.sh -j 10 -b feature/decimate
 cbuild_roms.sh -j 10 -b feature/decimate
  ```
- To run, use:

  ```
  mpirun -n 12 romsM < roms_lake_decimate.in > & log &
  ```

### The output Files:

```
 log                                              standard output/error
 lake_decimate_avg.nc                             ROMS 5-day average files
 lake_decimate_his.nc                             ROMS 5-day history files
 lake_decimate_rst.n                              ROMS restart file
 lake_decimate_sta.nc                             ROMS hourly stations file 
 lake_decimate_xtr.nc                             ROMS extracted history by decimation
 ```
----

### ROMS Grid Configuration:

The idealized horizontal lake grid is **360x300x20** at **1.0x1.0** km resolution:

<img width="600" alt="image" src="https://github.com/myroms/roms/assets/23062912/ed97d068-04f8-4e5e-9947-305c2e03b983">

### Results:
