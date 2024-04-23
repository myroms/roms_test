<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Lake Decimate: ROMS Grid Extraction by Decimation Test

This directory includes various files to run the idealized **`LAKE_DECIMATE`** to test **ROMS**'s
solution extraction capabilities by decimation or horizontal interpolation, level-by-level, in
3D fields. It is activated with the **`GRID_EXTRACTION`** option.  The user needs to provide the
extraction fields geometry grid NetCDF file **GRXNAME** at the input. This grid needs to be created
with tools similar to the parent ROMS application grid and contained inside. 


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
 lake_decimate_avg.nc                             ROMS 5-day average files
 lake_decimate_his.nc                             ROMS 5-day history files
 lake_decimate_rst.n                              ROMS restart file
 lake_decimate_sta.nc                             ROMS hourly stations file 
 lake_decimate_xtr.nc                             ROMS extracted history by decimation
 ```
----

### ROMS Grid Configuration:

