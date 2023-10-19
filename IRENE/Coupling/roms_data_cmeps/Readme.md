<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Hurricane Irene: CMEPS Coupling Connectors

This directory includes various files to run the **DATA-ROMS** coupling for Hurricane Irene
using **CMEPS** **NUOPC**-based mediator. The **DATA** component is replacing the 
Atmosphere Model, using datasets from **NCEP-NARR** or **ECMWF-ERA5** products.
The coupled simulation only runs for 42 hours as Hurricane Irene approaches the US 
East Coast on August 27, 2011.

For more information about the  Community Mediator for Earth Prediction Systems 
(**CMEPS**), visit:

https://escomp.github.io/CMEPS/versions/master/html/index.html

### Important CPP options:

They are activated in the build scripts.

```
   IRENE                   ROMS application CPP option
   BULK_FLUXES             Activates COARE bulk parameterization of surface fluxes
   CMEPS                   Activates the coupling mediator
   ESMF_LIB                ESMF/NUOPC coupling library (version 8.0 and up)
   FRC_COUPLING            Activates surface forcing from coupled system
   ROMS_STDOUT             ROMS standard output is written into 'log.roms'
   VERIFICATION            Interpolates ROMS solution at observation points
```

### ESMF Mesh Files:

:earth_americas: :globe_with_meridians: The output **mesh** files have already been created
for you using the **`../mesh_esmf/create_mesh.sh`** script, and are located in the sub-directory
**`../../Data/ESMF`**.
```
                                   ../../Data/ESMF/irene_roms_grid_rho_ESMFmesh.nc

                                   ../../Data/ESMF/era5_IRENE_ESMFmesh.nc

                                   ../../Data/ESMF/lwrad_down_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/lwrad_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/Pair_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/Qair_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/rain_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/swrad_daily_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/swrad_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/Tair_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/Uwind_narr_IRENE_ESMFmesh.nc
                                   ../../Data/ESMF/Vwind_narr_IRENE_ESMFmesh.nc
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
  build_ufs.sh                  UFS CMake compiling and linking BASH script
  datm_in                       UFS DATA component configuration namelist
  datm.streams                  CDEPS DATA model streams configuration
  irene.h                       ROMS header file
  job_setup.sh                  Creates configuration scripts from templates
  model_configure               UFS coupling configuration parameters
  nems.configure                UFS-NEMS run-time configuration paramters
  rbl4dvar.in                   ROMS observation input script
  roms_cdeps_era5.yaml          ROMS-CDEPS configuration YAML file for ECMWF-ERA5 data
  roms_cdeps_narr.yaml          ROMS-CDEPS configuration YAML file for NCEP-NARR data
  roms_irene.in                 ROMS standard input script
 ```

### Configuration template scripts:

The **User** must run **`job_setup.sh`** bash script to generate the needed configuration scripts
from templates. It facilitates customizing the location of Hurricane Irene's input NetCDF files.
For example, it uses Perl to replace the value of **`MyIRENEdir`** in the template scripts.

```
  datm_in.tmpl                  UFS DATA component namelist template
  datm.streams_era5.tmpl        CDEPS DATA model ECMWF-ERA5 streams template
  datm.streams_narr.tmpl        CDEPS DATA model NCEP-NARR  streams template
  rbl4dvar.in.tmpl              ROMS observation input template
  roms_irene.in.tmpl            ROMS standard input template
 ```
     
### How to Compile and Run UFS Coupling System:

- Clone **UFS-coastal** repository:
  ```
  git -c submodule.ADCIRC.update=none clone -b feature/coastal_app --recursive https://github.com/oceanmodeling/ufs-coastal
  ```
  Notice that omit to clone the **ADCIRC** component since it is still private and working with research
  branch **`feature/coastal_app`**.

- Load **Spack-Stack** modules. In Rutgers computers, we load the **JEDI Spack/Stack** modules using:
  ```
  module purge
  module load stack-intel
  module list
  ```
- Configure, compile, and link. We provide the **`build_ufs.sh`** to facilitate configuring and compiling a generic
  **ROMS** application coupled to the **`UFS-coastal`** framework.
  ```
  build_ufs.sh -j 10
  ```
  It creates the **`Build_ufs`** sub-directory and executable driver **`ufs_model`**.

  In addition, you could compile with a specific **ROMS** branch from https://github.com/myroms/roms. For example:
  ```
  build_ufs.sh -j 10 -b feature/kernel
  ```

- Execute **job_setup.csh** to generate the required **UFS-ROMS** input scripts from templates:
  ```
  ./job_setup.sh

  or

  ./job_setup.sh -pets 3x4 -d /home/CaptainCook/IRENE
  ```

- To run, use:
  ```
  mpirun -n 12 ufs_model > & log &
  ```

### The output Files:

- Standard Output Files:

  ```
    log                                           standard output/error
    log.coupler                                   coupler information
    log.esmf                                      ESMF/NUOPC information
    log.roms                                      ROMS standard output

    mediator.log                                  CMEPS mediator standard output

    ESMF_LogFile                                  ESMF single log file
  ```

- Coupling NetCDF Files:

  ```
    irene_avg.nc                                  ROMS 6-hour averages
    irene_his.nc                                  ROMS hourly history
    irene_mod_20110827.nc                         ROMS data at observation locations
    irene_qck.nc                                  ROMS hourly surface fields quick save
    irene_rst.nc                                  ROMS restart

    ufs.cpld.cpl.hi.*.nc                          UFS history, exchanged fields

    ufs.cpld.datm.r.2011-08-29-00000.nc           UFS restart 2011-08-29 00:00:00
  ```
