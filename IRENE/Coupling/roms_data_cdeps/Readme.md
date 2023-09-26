<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Hurricane Irene: CDEPS Coupling Connectors

This directory includes various files to run the **DATA-ROMS** coupling for Hurricane Irene
using **CDEPS** **NUOPC**-based connectors. The **DATA** component is replacing the 
Atmosphere Model, using datasets from **NCEP-NARR** or **ECMWF-ERA5** products.
The coupled simulation only runs for 42 hours as Hurricane Irene approaches the US. 
East Coast on August 27, 2011.

For more information about the Community Data Models for Earth Predictive Systems
(**CDEPS**), visit:

https://escomp.github.io/CDEPS/versions/master/html/index.html

### Important CPP options:

They are activated in the build scripts.

```
   IRENE                   ROMS application CPP option
   CDEPS                   Activates the DATA component
   ESMF_LIB                ESMF/NUOPC coupling library (version 8.0 and up)
   FRC_COUPLING            Activates surface forcing from coupled system
   ROMS_STDOUT             ROMS standard output is written into 'log.roms'
   VERIFICATION            Interpolates ROMS solution at observation points
```

### ESMF Mesh Files:

```
                                   ../mesh_esmf/irene_roms_grid_rho_ESMFmesh.nc

                                   ../mesh_esmf/era5_IRENE_ESMFmesh.nc

                                   ../mesh_esmf/lwrad_down_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/lwrad_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/Pair_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/Qair_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/rain_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/swrad_daily_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/swrad_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/Tair_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/Uwind_narr_IRENE_ESMFmesh.nc
                                   ../mesh_esmf/Vwind_narr_IRENE_ESMFmesh.nc
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
  datm_in                       UFS DATA component configuration namelist
  datm.streams                  CDEPS DATA model streams configuration
  irene.h                       ROMS header file
  job_setup.csh                 Coupling set up script
  model_configure               UFS coupling configuration parameters
  nems.configure                UFS-NEMS run-time configuration paramters
  rbl4dvar.in                   ROMS observation input script
  roms_cdeps_era5.yaml          ROMS-CDEPS configuration YAML file for ECMWF-ERA5 data
  roms_cdeps_narr.yaml          ROMS-CDEPS configuration YAML file for NCEP-NARR data
  roms_irene.in                 ROMS standard input script
 ```
     
### How to Compile and Run UFS Coupling System:

- Clone UFS-coastal repository:
  ```
  git -c submodule.ADCIRC.update=none clone -b feature/coastal_app --recursive https://github.com/oceanmodeling/ufs-coastal
  ```
  Notice that omit to clone the ADCIRC component since it is still private and working with research
  branch **`feature/coastal_app`**.

- Load JEDI Spack-Stack modules. In Rutgers computers, we execute:
  ```
  module purge
  module load stack-intel
  module list
  ```
- Configure, compile, and link:
  ```
  cd ufs-coastal
  cd tests
  ./compile.sh "pontus" "-DAPP=CSTLR -DBULK_FLUX=ON" coastal intel NO NO
  ```
  It creates the **`build_ufs_coastal`** subdirectory and executable driver **`ufs_coastal.exe`**.

- To run, use:
  ```
  mpirun -n 12 ufs_coastal.exe > & log &
  ```

### The output Files:

- Standard Output Files:

  ```
    log                                           standard output/error
    log.coupler                                   coupler information
    log.esmf                                      ESMF/NUOPC information
    log.roms                                      ROMS standard output

    datm.log                                      DATA component standard output
  ```

- Coupling NetCDF Files:

  ```
    irene_avg.nc                                  ROMS 6-hour averages
    irene_his.nc                                  ROMS hourly history
    irene_mod_20110827.nc                         ROMS data at observation locations
    irene_qck.nc                                  ROMS hourly surface fields quick save
    irene_rst.nc                                  ROMS restart

    ufs.cpld.datm.r.2011-08-27-64800.nc           UFS restart 2011-08-27 18:00:00
    ufs.cpld.datm.r.2011-08-28-21600.nc           UFS restart 2011-08-28  6:00:00
    ufs.cpld.datm.r.2011-08-28-64800.nc           UFS restart 2011-08-28 18:00:00

    weightmatrix_ATM-TO-OCN_faxa_lwdn.nc          lwrad_down interpolation weights
    weightmatrix_ATM-TO-OCN_faxa_rain.nc          rain       interpolation weights
    weightmatrix_ATM-TO-OCN_faxa_swnet.nc         swrad      interpolation weights
    weightmatrix_ATM-TO-OCN_sa_pslv.nc            Pair       interpolation weights
    weightmatrix_ATM-TO-OCN_sa_q2m.nc             Qair       interpolation weights
    weightmatrix_ATM-TO-OCN_sa_t2m.nc             Tair       interpolation weights
    weightmatrix_ATM-TO-OCN_sa_u10m.nc            Uair       interpolation weights
    weightmatrix_ATM-TO-OCN_sa_v10m.nc            Vair       interpolation weights
  ```
