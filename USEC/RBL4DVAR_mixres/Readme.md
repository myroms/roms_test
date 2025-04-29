<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Mixed-Resolution Test Case: Regional U.S. East Coast 3km and 6km Application

This directory illustrates how to configure **ROMS** split **RBL4D-Var**
mixed-resolution algorithm in a regional application. It uses our Coupled
Forecast Framework (**CFF**) configuration of the U.S. East Coast (**USEC**)
grids at 3km (**CFF-USEC3**) and 6km (**CFF-USEC6**) resolution during the
Hurricane Dorian period Aug 27 - Sep 2, 2019. In the **mixed-resolution** scheme,
the **4D-Var** outer loops (**Background** and **Analysis** phases) are run at 3km
grid (**561x243x50**) resolution (**CFF-USEC3**). In contrast, the inner loops
(**Increment** phase) are run at a coarser 6km grid (**281x122x50**) resolution to
accelerate the computations. The coarse **grid 4D-Var increment**s are interpolated to
the finer grid in the **Analysis** phase using the **roms_interp** and **roms2roms**
CLASS objects. For details, please check the **roms_interp.F** and **state_regrid.F**﻿
modules.

| Hurricane Dorian | CFF-USEC3 and CFF-USEC6 Grids |
:-----------------:|:-------------------------:
|<img width="600" alt="image" src="https://github.com/user-attachments/assets/430d8ff1-431b-4ab1-933e-09a979d93190"> | <img width="600" alt="image" src="https://github.com/user-attachments/assets/a28d91f6-24ab-440b-bb91-0313361a25c1"> |

In the **Background** phase, the coarse grid trajectory needed to linearize the tangent
linear (**TLM**) and adjoint (**ADM**) model kernels is extracted by a decimation of the
3km grid solution using the CPP option **GRID_EXTRACT**. Grid decimation is only possible
if the parent grid (**CFF-USEC3**, **Lm=559** and **Mm=241**) size satisfies
**MOD(Lm+1, 2) = 0** and **MOD(Mm+1, 2) = 0**. Please check
https://github.com/myroms/roms/pull/32 for more information. Currently, we only
support **ExtractFlag=2** for decimation in the **mixed-resolution** split **4D-Var** scheme
because the land/sea masking complicates extraction at factors larger than two.

The **mixed-resolution** split **4D-Var** data assimilation strategy improves the
computational efficiency as shown in the following table for a single **3**-day **4D-Var**
data assimilation cycle from a desktop Linux box (16 CPUs and 1 GPU with 384 CUDA cores, NVIDIA)
on **12** CPUs with a **3x4** partition compiled with **ifort** (Spack-Stack 1.9).

<img width="940" alt="image" src="https://github.com/user-attachments/assets/aaf2ba95-1378-4636-a135-360dc3186c71" />

The **mixed resolution** algorithm improves this application's computational efficiency by
over **88** percent (**Case 8**) compared to the **3**km non-splitted **4D-Var** in double precision
(**Case 5**). In some cases, **mixed-precision** outer loops (**double**) and inner loops (**single**)
are possible but **not recommended** because they affect the stability of the tangent linear
and adjoint trajectories. It improves the efficiency by an additional **3** percent. However,
stability of the solution takes precedence.

In this test case, data is provided for two **3**-day data assimilation cycles:

- **4D-Var Cycle 1**: Aug 27 - Aug 30, 2019 (execution creates sub-directory **2019.08.27**)
- **4D-Var Cycle 2**: Aug 30 - Sep 02, 2019 (execution creates sub-directory **2019.08.30**)

to demonstrate how to configure continuous data assimilation cycles that use the **Analysis**
file (**DAINAME**) to initialize the next **4D-Var** cycle.

### Important CPP options:

They are activated in the build scripts.

  ```
   IRENE                   ROMS application CPP option
   BGQC                    Background quality control of observations
   DATA_COUPLING           Activates DATA component
   ESMF_LIB                ESMF/NUOPC coupling library (version 8.0 and up)
   FRC_COUPLING            Activates surface forcing from coupled system
   FORWARD_FLUXES          Use nonlinear Forward fluxes for Tangent/Adjoint
   ROMS_STDOUT             ROMS standard output is written into 'log.roms'
   RPCG                    Restricted B-preconditioned Lanczos minimization
   SPLIT_RBL4DVAR          Split RBL4D-Var algorithm driver
   VERIFICATION            Interpolates ROMS solution at observation points
   WRF_COUPLING            Activates WRF component (version 4.1 and up)
   WRF_TIMEAVG             WRF exporting 60-sec time-averaged fields
  ```

### DATA component Input NetCDF file:
  ```
                        SST File:  ../Data/HyCOM/hycom_mab3hours_sst_25aug2011_31aug2011.nc
  ```
### ROMS component Input NetCDF files:
  ```
                       Grid File:  ../Data/ROMS/irene_roms_grid.nc
                    Initial File:  ../Data/ROMS/irene_roms_ini_20110827_06.nc
                   Boundary File:  ../Data/ROMS/irene_roms_bry.nc
                Climatology File:  ../Data/ROMS/irene_roms_clm.nc
       Nudging Coefficients File:  ../Data/ROMS/irene_roms_nudgcoef.nc
              River Forcing File:  ../Data/ROMS/irene_roms_rivers.nc
              Tidal Forcing File:  ../Data/ROMS/irene_roms_tides.nc

     Initial Conditions STD File:  ../Data/STD/irene_std_i.nc
                  Model STD File:  ../Data/STD/irene_std_m.nc
    Boundary Conditions STD File:  ../Data/STD/irene_std_b.nc
        Surface Forcing STD File:  ../Data/STD/irene_std_f.nc
    Initial Conditions Norm File:  ../Data/NRM/irene_nrm_40-15k10m.nc
                 Model Norm File:  ../Data/NRM/irene_nrm_40-15k10m.nc
   Boundary Conditions Norm File:  ../Data/NRM/irene_nrm_b_40-15k10m.nc
       Surface Forcing Norm File:  ../Data/NRM/irene_nrm_f_100k.nc
               Observations File:  ../Data/OBS/irene_obs_20110827.nc
  ```

### WRF component Input NetCDF files:
  ```
                    Initial File:  ../Data/WRF/irene_wrf_inp_d01_20110827.nc
                   Boundary File:  ../Data/WRF/irene_wrf_bdy_d01_20110827.nc
        SST Melding Weights File:  ../Data/WRF/irene_wrf_meld_weights.nc
             Unused WPS SST File:  ../Data/WRF/irene_wrf_sst_d01_20110827.nc
  ```

### Configuration and input scripts:

  ```
  build_split.csh               ROMS GNU Make compiling and linking CSH script
  build_split.sh                ROMS GNU Make compiling and linking BASH script
  build_wrf.csh                 WRF GNU Make compiling and linking CSH script
  build_wrf.sh                  WRF GNU Make compiling and linking BASH script
  coupling_esmf_atm_sbl.tmp     Coupling standard input template (WRF SBL fluxes)
  coupling_esmf_atm_sbl_wmc.tmp Coupling standard input template (WRF SBL fluxes)
                                  WIND_MINUS_CURRENT option
  coupling_esmf_bulk_flux.tmp   Coupling standard input template (ROMS bulk fluxes)
  coupling_esmf_wrf.yaml        Coupling fields exchange YAML metadata
  irene.h                       ROMS header file
  namelist.input.tmp            WRF standard input tempate
  s4dvar.in                     RBL4D-Var data assimilation template
  roms_nl_irene.in              ROMS nonlinear model standard input template
  roms_da_irene.in              ROMS data assimilation standard input template
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

- It is helpful to define a **ltl** macro at login to avoid showing all the
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
    APPLICATION because the **bulk_flux.F** module is not tunned for Hurricane regimes,
    and will get the wrong solution
   
    To compile **ROMS** coupling (nonlinear kernel) and data assimilation kernels, use:
   ```
    build_split.csh -nl -j 10                     creates executable romsM_nl
    build_split.csh -da -j 10                     creates executable romsM_da
   ```
    That is, the **4D-Var split** scheme uses two different executables for **ROMS**:
   ```
      romsM_nl       Coupling driver for RBL4D-Var background phase

      romsM_da       Data assimilation driver for RBL4D-Var increment and analysis
                       phases
   ```
   To submit the job on 32 CPUs via SLURM or not, use:
   ```
    sbatch submit.sh        or
    submit.sh > & log &
   ```
    You can modify **submit.sh** for your appropriate computer environment.
  
    The **submit.sh** script creates the sub-directory **2011.08.27** and includes all
    the required input scripts to run the **coupled/RBL4D-Var** system. The input
    scripts are generated from the templates.  The **submit.sh** script is quite
    complex and designed to run sequential coupling/assimilation windows
    (cycles). However, it only runs a single cycle for Hurricane Irene.

    Generated input scripts:
   ```
      coupling_esmf_atm_sbl_20110827.in
      namelist.input.20110827
      roms_da_irene_20110827.in
      roms_nl_irene_20110827.in
   ```

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
    irene_mod_20110827.nc                         RBL4D-Var model/obs vectors
    irene_roms_adj_20110827.nc                    ADM fields
    irene_roms_avg_20110827_outer0.nc             6-hour averages, outer = 0
    irene_roms_avg_20110827_outer1.nc             6-hour averages, outer = 0
    irene_roms_dai_20110827.nc                    Next cycle DA initialization
    irene_roms_fwd_20110827_outer0.nc             hourly forward trajectory, outer = 0
    irene_roms_fwd_20110827_outer1.nc             hourly forward trajectory, outer = 1
    irene_roms_ini_20110827_06.nc                 initial conditions and increment
    irene_roms_itl_20110827.nc                    TLM initialization
    irene_roms_qck_20110827_outer0.nc             hourly surface fields, outer = 0
    irene_roms_qck_20110827_outer1.nc             hourly surface fields, outer = 1
    irene_roms_rst_20110827.nc                    restart
    irene_roms_tlf_20110827.nc			              TLM forcing
  ```

- **WRF** NetCDF File:
  ```
    irene_wrf_his_d01_20110827.nc                 hourly history
  ```
