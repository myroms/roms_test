<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Hurricane Irene: ESMF/NUOPC Coupling

This directory includes various files to run the **DATA-ROMS**
coupling for Hurricane Irene using the **ESMF/NUOPC** library. The
coupled simulation is only run for 42 hours as it approaches the
US East Coast on August 27, 2011.

The atmospheric forcing is exported to **ROMS** from the **DATA** model
with a coupling interval of 60 seconds (same as **ROMS** timestep). It
is a standard test of **ROMS** and **DATA** modules in the native coupling
system.

All the components interact with the same coupling time step.
The connector for **DATA** to **ROMS** is explicit, and it uses the same
forcing **NCEP-NARR** files used in the regular **`../../Forward`** solution,
except that the **ESMF/NUOCP** system is doing the spatial and temporal
interpolation. Alternatively, you may use ECMWF-ERA5 forcing.

For more information, visit **WikiROMS**:

https://www.myroms.org/wiki/Model_Coupling_ESMF
https://www.myroms.org/wiki/Model_Coupling_IRENE


### Important CPP options:

They are activated in the build scripts.

```
   IRENE                   ROMS application CPP option
   DATA_COUPLING           Activates DATA component
   ESMF_LIB                ESMF/NUOPC coupling library (version 8.0 and up)
   FRC_COUPLING            Activates surface forcing from coupled system
   ROMS_STDOUT             ROMS standard output is written into 'log.roms'
   VERIFICATION            Interpolates ROMS solution at observation points
```

### DATA component Input NetCDF files: ECMWF-ERA5 Forcing

```
                                   ../../Data/FRC/era5_IRENE.nc
```

### DATA component Input NetCDF files: NCEP-NARR Forcing

```
                                   ../../Data/FRC/lwrad_down_narr_IRENE.nc
                                   ../../Data/FRC/Pair_narr_IRENE.nc
                                   ../../Data/FRC/Qair_narr_IRENE.nc
                                   ../../Data/FRC/rain_narr_IRENE.nc
                                   ../../Data/FRC/swrad_daily_narr_IRENE.nc
                                   ../../Data/FRC/Tair_narr_IRENE.nc
                                   ../../Data/FRC/Uwind_narr_IRENE.nc
                                   ../../Data/FRC/Vwind_narr_IRENE.nc
```

### ROMS component Input NetCDF files:

```
                       Grid File:  ../../Data/ROMS/irene_roms_grid.nc
                    Initial File:  ../../Data/ROMS/irene_roms_ini_20110827_06.nc
                   Boundary File:  ../../Data/ROMS/irene_roms_bry.nc
                Climatology File:  ../../Data/ROMS/irene_roms_clm.nc
       Nudging Coefficients File:  ../../Data/ROMS/irene_roms_nudgcoef.nc
              River Forcing File:  ../../Data/ROMS/irene_roms_rivers.nc
              Tidal Forcing File:  ../../Data/ROMS/irene_roms_tides.nc
               Observations File:  ../../Data/OBS/irene_obs_20110827.nc
```

### Configuration and input scripts:

```
  build_roms.csh                ROMS GNU Make compiling and linking CSH script
  build_roms.csh                ROMS GNU Make compiling and linking BASH script
  build_wrf.csh                 WRF GNU Make compiling and linking CSH script
  build_wrf.csh                 WRF GNU Make compiling and linking BASH script
  cbuild_roms.csh               ROMS CMake compiling and linking CSH script
  cbuild_roms.csh               ROMS CMake compiling and linking BASH script
  coupling_esmf_era5.in         Coupling standard input script for ECMWF-ERA5 data
  coupling_esmf_era5.yaml       Coupling fields metdata YAML for ECMWF-ERA5 data
  coupling_esmf_narr.in         Coupling standard input script for NCEP-NARR data
  coupling_esmf_narr.yaml       Coupling fields metdata YAML for NECP-NARR data
  irene.h                       ROMS header file
  namelist.input                WRF standard input script
  rbl4dvar.in                   ROMS observation input script
  roms_irene.in                 ROMS standard input script
  submit.sh                     Job submission bash script
  data_explicit.runconfig       ESMF coupling Run Sequence
 ```
     
### How to Compile ROMS:

- **ROMS** is the driver of the coupling system.

  Notice that **bulk_flux = 1** activate **ROMS** CPP options: **BULK_FLUXES**, **COOL_SKIN**,
  **WIND_MINUS_CURRENT**, **EMINUSP**, and **LONGWAVE_OUT** in the **build** scripts.

  If running the NCEP-NARR forcing case, you need to activate **DIURNAL_SRFLUX** to
  modulate the net shortwave radiation daily cycle at every timestep from the NARR
  daily-averaged value. You need to deactive **DIURNAL_SRFLUX** if running the
  ECMWF-ERA5 hourly forcing.

- To compile **ROMS**, use:
   ```
    build_roms.csh -j 10
   ```
- To run, use:
   ```
    mpirun -n 12 romsM coupling_esmf_narr.in > & log &

   or

    mpirun -n 12 romsM coupling_esmf_era5.in > & log &
   ```

### The output Files:

- Standard Output Files:

  ```
    log                                           standard output/error
    log.coupler                                   coupler information
    log.esmf                                      ESMF/NUOPC information
    log.roms                                      ROMS standard output
  ```

- ROMS NetCDF Files:

  ```
    irene_avg.nc                                  6-hour averages
    irene_his.nc                                  hourly history
    irene_mod_20110827.nc                         model at observation locations
    irene_qck.nc                                  hourly surface fields quick save
    irene_rst.nc                                  restart
  ```
