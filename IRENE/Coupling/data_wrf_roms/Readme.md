<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Hurricane Irene Test Case: ESMF/NUOPC Coupling

This directory includes various files to run the **DATA-WRF-ROMS**
coupling system for Hurricane Irene using the **ESMF/NUOPC** library. It
uses our Coupled Forecast Framework (**CFF**) configuration for the
U.S. East Coast **`CFF-USEC7`** (**ROMS** 7km grid), and the simulation is
only ran for 42 hours as Hurricane Irene approached the Outer Banks
of North Carolina on August 27, 2011.

<img width="940" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/43010527-1cb7-4ba0-aec4-a888f46369c4">

**WRF** and **ROMS** grids are incongruent. The **WRF** grid is
larger than the **ROMS** grid. Therefore, the **DATA** model provides
SST values at the **WRF** grid locations not covered by the **ROMS**
grid. Thus, both **DATA** and **ROMS** SST values are melded with a
smooth transition at the **ROMS** domain boundaries, as shown in the
melding weights above.

Due to the strong hurricane winds, the **WRF** and **ROMS** timesteps
are 20 and 60 seconds for stable solutions.  The
coupling step is 60 seconds (same as **ROMS**).  The **WRF** values are
averaged every 60 seconds by activating the **RAMS**-averaged
diagnostics.

All the components interact with the same coupling time step.
The connector from **ROMS** to **WRF** is explicit, whereas the connector
from **WRF** to **ROMS** is semi-implicit.

It uses **ROMS**'s native, **NUOPC**-based coupling system. For more information,
visit **WikiROMS**:

https://www.myroms.org/wiki/Model_Coupling_ESMF

### Important CPP options:

They are activated in the build scripts.

  ```
   IRENE                   ROMS application CPP option
   DATA_COUPLING           Activates the DATA component
   ESMF_LIB                ESMF/NUOPC coupling library (version 8.0 and up)
   FRC_COUPLING            Activates surface forcing from the coupled system
   ROMS_STDOUT             ROMS standard output is written into 'log.roms'
   VERIFICATION            Interpolates ROMS solution at observation points
   WRF_COUPLING            Activates WRF component (version 4.1 and up)
   WRF_TIMEAVG             WRF exporting 60-sec time-averaged fields
  ```

### DATA component Input NetCDF file:
  ```
                        SST File:  ../../Data/HyCOM/hycom_mab3hours_sst_25aug2011_31aug2011.nc
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
### WRF component Input NetCDF files:
  ```
                    Initial File:  ../../Data/WRF/irene_wrf_inp_d01_20110827.nc
                   Boundary File:  ../../Data/WRF/irene_wrf_bdy_d01_20110827.nc
        SST Melding Weights File:  ../../Data/WRF/irene_wrf_meld_weights.nc
             Unused WPS SST File:  ../../Data/WRF/irene_wrf_sst_d01_20110827.nc
  ```

### Configuration and input scripts:

  ```
  build_roms.csh                ROMS GNU Make compiling and linking CSH script
  build_roms.sh                 ROMS GNU Make compiling and linking BASH script
  build_wrf.csh                 WRF GNU Make compiling and linking CSH script
  build_wrf.sh                  WRF GNU Make compiling and linking BASH script
  cbuild_roms.csh               ROMS CMake compiling and linking CSH script
  cbuild_roms.sh                ROMS CMake compiling and linking BASH script
  coupling_esmf_atm_sbl.in      Coupling standard input script (WRF SBL fluxes)
  coupling_esmf_atm_sbl_wmc.in  Coupling standard input script (WRF SBL fluxes)
                                  WIND_MINUS_CURRENT option
  coupling_esmf_bulk_flux.in    Coupling standard input script (ROMS bulk fluxes)
  coupling_esmf_wrf.yaml        Coupling fields exchange YAML metadata
  irene.h                       ROMS header file
  namelist.input                WRF standard input script
  rbl4dvar.in                   ROMS observation input script
  roms_irene.in                 ROMS standard input script
  submit.sh                     Job submission bash script
  wrf_implicit.runconfig        ESMF coupling Run Sequence
  ```

- To download **WRF** and **WPS** version 4.3, you may use:
  ```
    git clone  https://github.com/wrf-model/WRF WRF.4.3
    cd WRF.4.3
    git checkout tags/v4.3

    git clone  https://github.com/wrf-model/WPS WPS.4.3
    cd WPS.4.3
    git checkout tags/v4.3
  ```
- The strategy is to compile **WRF** from a directory other than where the
    source code is located. We use the **-move** option to **build_wrf.csh** or
    **build_wrf.sh** script. To compile **WRF**, use:

  ```
    build_wrf.csh -j 10 -move
  ```
    Please select from among the following Linux x86_64 options: for **ifort**
    we choose the **dmpar** (distributed-memory parallel) option:

  ```
    1.  (serial)   2. (smpar)   3. (dmpar)   4. (dm+sm)   PGI (pgf90/gcc)
    5.  (serial)   6. (smpar)   7. (dmpar)   8. (dm+sm)   PGI (pgf90/pgcc): SGI MPT
    9.  (serial)  10. (smpar)  11. (dmpar)  12. (dm+sm)   PGI (pgf90/gcc): PGI accelerator
    13. (serial)  14. (smpar)  15. (dmpar)  16. (dm+sm)   INTEL (ifort/icc)
                                            17. (dm+sm)   INTEL (ifort/icc): Xeon Phi
    18. (serial)  19. (smpar)  20. (dmpar)  21. (dm+sm)   INTEL (ifort/icc): Xeon (SNB with AVX mods)
    22. (serial)  23. (smpar)  24. (dmpar)  25. (dm+sm)   INTEL (ifort/icc): SGI MPT
    26. (serial)  27. (smpar)  28. (dmpar)  29. (dm+sm)   INTEL (ifort/icc): IBM POE
    30. (serial)               31. (dmpar)                PATHSCALE (pathf90/pathcc)
    32. (serial)  33. (smpar)  34. (dmpar)  35. (dm+sm)   GNU (gfortran/gcc)
    36. (serial)  37. (smpar)  38. (dmpar)  39. (dm+sm)   IBM (xlf90_r/cc_r)
    40. (serial)  41. (smpar)  42. (dmpar)  43. (dm+sm)   PGI (ftn/gcc): Cray XC CLE
    44. (serial)  45. (smpar)  46. (dmpar)  47. (dm+sm)   CRAY CCE (ftn $(NOOMP)/cc): Cray XE and XC
    48. (serial)  49. (smpar)  50. (dmpar)  51. (dm+sm)   INTEL (ftn/icc): Cray XC
    52. (serial)  53. (smpar)  54. (dmpar)  55. (dm+sm)   PGI (pgf90/pgcc)
    56. (serial)  57. (smpar)  58. (dmpar)  59. (dm+sm)   PGI (pgf90/gcc): -f90=pgf90
    60. (serial)  61. (smpar)  62. (dmpar)  63. (dm+sm)   PGI (pgf90/pgcc): -f90=pgf90
    64. (serial)  65. (smpar)  66. (dmpar)  67. (dm+sm)   INTEL (ifort/icc): HSW/BDW
    68. (serial)  69. (smpar)  70. (dmpar)  71. (dm+sm)   INTEL (ifort/icc): KNL MIC

    Enter selection [1-75] : 15
    Compile for nesting? (1=basic, 2=preset moves, 3=vortex following) [default 1]: 1
  ```
- **The WRF** executables will located in the sub-directory **Build_wrf/Bin**

- It is useful to define a **ltl** macro at login to avoid showing all the
    links files created by the build script and needed to run **WRF**:
  ```
    alias ltl '/bin/ls -ltHF | grep -v ^l'
  ```
### How to Compile ROMS:

- **ROMS** is the driver of the coupling system. In this application, the **WRF** Surface
    Boundary Layer (SBL) formulation is used to compute the atmospheric fluxes.
    Therefore, **bulk_flux = 0** in the build scripts.

    Notice that **bulk_flux = 1** activates **ROMS** CPP options: **BULK_FLUXES**, **COOL_SKIN**,
    **WIND_MINUS_CURRENT**, **EMINUSP**, and **LONGWAVE_OUT**.

    The option **bulk_flux = 1** in the **ROMS** build script IS NOT RECOMMENDED FOR THIS
    APPLICATION because the **bulk_flux.F** module is not tuned for Hurricane regimes,
    and will get the wrong solution

    To compile **ROMS**, use:
   ```
    build_roms.csh -j 10
   ```
  To submit the job on 32 CPUs via SLURM or not, use:
   ```
    sbatch submit.sh        or
    submit.sh > & log &
   ```
  You can modify **submit.sh** for your appropriate computer environment.

### The output Files:

- Standard Output Files:
   ```
    log.coupler                                   coupler information
    log.esmf                                      ESMF/NUOPC information
    log.roms                                      ROMS standard output
    log.wrf                                       WRF standard error/output
    namelist.output                               WRF configuration parameters
  ```

- **ROMS** NetCDF Files:

   ```
    irene_avg.nc                                  6-hour averages
    irene_his.nc                                  hourly history
    irene_mod_20110827.nc                         model at observation locations
    irene_qck.nc                                  hourly surface fields quick save
    irene_rst.nc                                  restart
   ```

- **WRF** NetCDF File:
   ```
    irene_wrf_his_d01_2011-08-27_06_00_00.nc      hourly history
   ```
