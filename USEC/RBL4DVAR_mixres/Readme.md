<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Mixed-Resolution Test Case: Regional U.S. East Coast 3km and 6km Application

This directory illustrates how to configure **ROMS** split **RBL4D-Var**
mixed-resolution algorithm in a regional application. It uses our Coupled
Forecast Framework (**CFF**) configuration of the :us: U.S. East Coast (**USEC**)
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

---

### Important CPP options:

They are activated in the build scripts.

  ``` d
   USEC                    ROMS application CPP option
   BGQC                    Background quality control of observations
   BULK_FLUXES             Surface bulk fluxes parameterization, latest COARE 3.5
   DIURNAL_SRFLUX          Modulates shortwave radiation by the local diurnal cycle, if NAM forcing
   GRID_EXTRACT            Activates writing a decimated nonlinear trajectory for inner loops
   OMEGA_IMPLICIT          Adaptive, Courant-number-based implicit vertical advection, NLM kernel
   OUT_DOUBLE              Double precision output fields in NetCDF files
   PIO_LIBRARY             Using Parallel-IO from the PIO library
   RPCG                    Restricted B-preconditioned Lanczos minimization
   SPLIT_EXECUTABLE        Split 4D-Var executable for background/analysis phases
   SPLIT_RBL4DVAR          Split RBL4D-Var algorithm driver
  ```

The CPP option **SPLIT_EXECUTABLE** avoids allocating the control vectors and adjoint
state arrays in the high-resolution **Background** and **Analysis** phases to reduce memory
requirements. The pointers for such variables are available but unallocated since they are
unused. Otherwise, it would limit the running of larger applications because they do not
fit into the computer's memory. Notice that the **outer loop** grid is twice as large as
the **inner loop** grid.

### ROMS Input NetCDF files:
  ``` d
                       Grid File:  ../Data/GRD/usec3km_roms_grd.nc
                                   ../Data/GRD/usec6km_roms_grd.nc
                    Initial File:  ../Data/INI/usec3km_roms_dai_20190827.nc
                                   ../Data/INI/usec6km_roms_ini.nc (generic)
                   Boundary File:  ../Data/BRY/usec3km_roms_bry.nc
                                   ../Data/BRY/usec6km_roms_bry_empty.nc
                Climatology File:  ../Data/CLM/usec3km_roms_mercator_clm.nc
       Nudging Coefficients File:  ../Data/GRD/usec3km_roms_nudgcoef.nc
              River Forcing File:  ../Data/GRD/usec3km_roms_rivers.nc
              Tidal Forcing File:  ../Data/GRD/usec3km_roms_tides.nc

  ERA5 Atmospheric Forcing Files:  ../Data/FRC/era5_0825_0909_2019.nc

   NAM Atmospheric Forcing Files:  ../Data/FRC/lwrad_down_nam_0815_0915_2019.nc
                                   ../Data/FRC/swrad_daily_nam_0815_0915_2019.nc
                                   ../Data/FRC/Pair_nam_0815_0915_2019.nc
                                   ../Data/FRC/Qair_nam_0815_0915_2019.nc
                                   ../Data/FRC/Tair_nam_0815_0915_2019.nc
                                   ../Data/FRC/rain_nam_0815_0915_2019.nc
                                   ../Data/FRC/Uwind_nam_0815_0915_2019.nc
                                   ../Data/FRC/Vwind_nam_0815_0915_2019.nc

     Initial Conditions STD File:  ../Data/STD/usec3km_roms_std_i_20190827.nc
                                   ../Data/STD/usec3km_roms_std_i_20190830.nc
                                   ../Data/STD/usec6km_roms_std_i_20190827.nc
                                   ../Data/STD/usec6km_roms_std_i_20190830.nc
    Boundary Conditions STD File:  ../Data/STD/usec3km_roms_std_b_20190827.nc
                                   ../Data/STD/usec3km_roms_std_b_20190830.nc
                                   ../Data/STD/usec6km_roms_std_b_20190827.nc
                                   ../Data/STD/usec6km_roms_std_b_20190830.nc
        Surface Forcing STD File:  ../Data/STD/usec3km_roms_std_f_20190827.nc
                                   ../Data/STD/usec3km_roms_std_f_20190830.nc
                                   ../Data/STD/usec6km_roms_std_f_20190827.nc
                                   ../Data/STD/usec6km_roms_std_f_20190830.nc

    Initial Conditions Norm File:  ../Data/NRM/usec3km_roms_nrm_i.nc
                                   ../Data/NRM/usec6km_roms_nrm_i.nc
   Boundary Conditions Norm File:  ../Data/NRM/usec3km_roms_nrm_b.nc
                                   ../Data/NRM/usec6km_roms_nrm_b.nc
       Surface Forcing Norm File:  ../Data/NRM/usec3km_roms_nrm_f.nc
                                   ../Data/NRM/usec6km_roms_nrm_f.nc
               Observations File:  ../Data/OBS/usec3km_roms_obs_20190827.nc
                                   ../Data/OBS/usec3km_roms_obs_20190830.nc
                                   ../Data/OBS/usec6km_roms_obs_20190827.nc
                                   ../Data/OBS/usec6km_roms_obs_20190830.nc
  ```

### Configuration and input scripts:

  ``` d
  build_split.csh               ROMS GNU Make compiling and linking CSH script
  build_split.sh                ROMS GNU Make compiling and linking BASH script
  plot_inc.m                    Matlab plotting script for 4D-Var increments and control vectors 
  roms_da_usec_era5.tmpl        ROMS data assimilation standard input template, ERA-5 forcing
  roms_nl_usec_era5.tmpl        ROMS nonlinear model standard input template, ERA-5 forcing
  roms_da_usec_nam.tmpl         ROMS data assimilation standard input template, NAM forcing
  roms_nl_usec_nam.tmpl         ROMS nonlinear model standard input template, NAM forcing
  s4dvar.in                     RBL4D-Var data assimilation template
  submit_mixres_rbl4dvar.sh     Job submission bash script
  usec.h                        ROMS header file
  ```
### How to Compile ROMS:
   
To compile **ROMS** data assimilation executables for **4D-Var** outer and inner loops, use:
  ``` d
    build_split.sh -nl -pio -j 10                 creates executable romsM_nl
    build_split.sh -da -pio -j 10                 creates executable romsM_da
  ```
That is, the **4D-Var split** scheme uses two different executables for **ROMS**:
  ``` d
      romsM_nl       Nonlinear driver for RBL4D-Var Background and Analysis phases, outer loops

      romsM_da       Data assimilation driver for RBL4D-Var Increment phase, inner loops
  ```
To submit the job on 12 CPUs via SLURM or not, use:
  ``` d
    sbatch submit_mixres_rbl4dvar.sh        or
    submit_mixres_rbl4dvar.sh > & log &
  ```
 You can modify **submit_mixres_rbl4dvar.sh** for your appropriate computer environment.

---

### ROMS Execution Sequence:

 The **submit_mixres_rbl4dvar.sh** script creates the **2019.08.27** and **2019.08.30**
 sub-directories for **RBL4D-Var** Cycle **1** and Cycle **2**, respectively. It includes
 all the required input scripts to run the **mixed-resolution RBL4D-Var** system. The input
 scripts are generated from the templates.  The **submit_mixres_rbl4dvar.sh** script is
 complex and designed to run sequential data assimilation 3-day cycles. It reports the
 execution sequence with detailed information:

``` d
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 ROMS Split RBL4D-Var Data Assimilation: USEC
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

                    ROMS Root: /home/arango/ocean/repository/git/roms
            ROMS Executable A: romsM_nl  (background, analysis)
            ROMS Executable B: romsM_da  (increment, post_error)

      RBL4D-Var Starting Date: 2019-08-27  datenum = 737664
   First RBL4D-Var Cycle Date: 2019-08-27  datenum = 737664
    Last RBL4D-Var Cycle Date: 2019-08-30  datenum = 737667
          ROMS Reference Date: 2006-01-01  datenum = 732678
       RBL4D-Var Cycle Window: 3 days
      Number of parallel PETs: 12  (3x4)
   Current Starting Directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres
         ROMS Application CPP: USEC
      Descriptor in filenames: usec3km  (outer loops grid)
      Descriptor in filenames: usec6km  (inner loops grid)

----------------------------------------------------------------------------------------------------

       RBL4D-Var Cycle Date: 2019-08-27 00  DayOfYear = 239  Cycle = 1
         Data sub-directory: ../../Data
          Run sub-directory: 2019.08.27
      Number of outer loops: 1
      Number of inner loops: 16
    NLM trajectory  writing: 30, 15 timesteps
    NLM quicksave   writing: 30, 15 timesteps
    NLM decimation  writing: 30, 15 timesteps
    TLM trajectory  writing: 30, 15 timesteps
    ADM trajectory  writing: 2160, 1080 timesteps
    SFF adjustment  writing: 30, 15 timesteps
    OBC adjustment  writing: 30, 15 timesteps
  NLM multi-file trajectory: 0, 0 timesteps
                ROMS DSTART: 4986.0d0
     Outer Loops Resolution: 3 km
     Inner Loops Resolution: 6 km
           I/O Files Prefix: usec3km  (outer loops grid)
           I/O Files Prefix: usec6km  (inner loops grid)
           I/O Files Suffix: 20190827
              ReferenceTime: 2006 01 01 00 00 00
        RBL4D-Var StartTime: 2019 08 27 00 00 00
        RBL4D-Var  StopTime: 2019 08 30 00 00 00
   ROMS outer loops Grid IC: ../../Data/INI/usec3km_roms_ini_20190827.nc
   ROMS inner loops Grid IC: ../../Data/INI/usec6km_roms_ini_20190827.nc
   NL Standard Input Script: roms_nl_usec_era5_20190827.in   (outer loops grid)
   DA Standard Input Script: roms_da_usec_era5_20190827.in   (inner loops grid)
  NL RBL4D-Var Input Script: rbl4dvar_nl.in  (outer loops grid)
  DA RBL4D-Var Input Script: rbl4dvar_da.in  (inner loops grid)

Cycle 1, Creating run sub-directory: 2019.08.27

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres/2019.08.27

   Creating NL ROMS Standard Input Script: roms_nl_usec_era5_20190827.in
   Creating DA ROMS Standard Input Script: roms_da_usec_era5_20190827.in
   Copying NLM IC file ../../Data/INI/usec3km_roms_ini_20190827.nc  as  usec3km_roms_ini_20190827.nc
   Copying NLM IC file ../../Data/INI/usec6km_roms_ini.nc  as  usec6km_roms_ini_20190827.nc
   Copying OBS    file ../../Data/OBS/usec3km_roms_obs_20190827.nc  as  usec3km_roms_obs_20190827.nc
   Copying OBS    file ../../Data/OBS/usec6km_roms_obs_20190827.nc  as  usec6km_roms_obs_20190827.nc

Running 4D-Var System:  Cycle = 1   Outer = 0   Phase = background

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 0  Phase = background
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190827)

   mpirun -np 12 romsM_nl roms_nl_usec_era5_20190827.in

   Renaming NLM trajectory usec6km_roms_fwd_20190827.nc  to  usec6km_roms_fwd_20190827_outer0.nc

Running 4D-Var System:  Cycle = 1   Outer = 1   Phase = increment

   Creating 4D-Var Input Script from Template: rbl4dvar_da.in   Outer = 1  Phase = increment
     (Resolution = 6 km, Fprefix = usec6km, Fsuffix = 20190827)

   mpirun -np 12 romsM_da roms_da_usec_era5_20190827.in

Running 4D-Var System:  Cycle = 1   Outer = 1   Phase = analysis

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 1  Phase = analysis
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190827)

   mpirun -np 12 romsM_nl roms_nl_usec_era5_20190827.in

   Renaming NLM trajectory usec6km_roms_fwd_20190827.nc  to  usec6km_roms_fwd_20190827_outer1.nc

Finished 4D-Var outer loops iterations

Finished RBL4D-Var Cycle 1,  Elapsed time = 02:39:40

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres

----------------------------------------------------------------------------------------------------

       RBL4D-Var Cycle Date: 2019-08-30 00  DayOfYear = 242  Cycle = 2
         Data sub-directory: ../../Data
          Run sub-directory: 2019.08.30
      Number of outer loops: 1
      Number of inner loops: 16
    NLM trajectory  writing: 30, 15 timesteps
    NLM quicksave   writing: 30, 15 timesteps
    NLM decimation  writing: 30, 15 timesteps
    TLM trajectory  writing: 30, 15 timesteps
    ADM trajectory  writing: 2160, 1080 timesteps
    SFF adjustment  writing: 30, 15 timesteps
    OBC adjustment  writing: 30, 15 timesteps
  NLM multi-file trajectory: 0, 0 timesteps
                ROMS DSTART: 4989.0d0
     Outer Loops Resolution: 3 km
     Inner Loops Resolution: 6 km
           I/O Files Prefix: usec3km  (outer loops grid)
           I/O Files Prefix: usec6km  (inner loops grid)
           I/O Files Suffix: 20190830
              ReferenceTime: 2006 01 01 00 00 00
        RBL4D-Var StartTime: 2019 08 30 00 00 00
        RBL4D-Var  StopTime: 2019 09 02 00 00 00
   ROMS outer loops Grid IC: ../2019.08.27/usec3km_roms_dai_20190827.nc
   ROMS inner loops Grid IC: ../2019.08.27/usec6km_roms_ini_20190830.nc
   NL Standard Input Script: roms_nl_usec_era5_20190830.in   (outer loops grid)
   DA Standard Input Script: roms_da_usec_era5_20190830.in   (inner loops grid)
  NL RBL4D-Var Input Script: rbl4dvar_nl.in  (outer loops grid)
  DA RBL4D-Var Input Script: rbl4dvar_da.in  (inner loops grid)

Cycle 2, Creating run sub-directory: 2019.08.30

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres/2019.08.30

   Creating NL ROMS Standard Input Script: roms_nl_usec_era5_20190830.in
   Creating DA ROMS Standard Input Script: roms_da_usec_era5_20190830.in
   Copying NLM IC file ../2019.08.27/usec3km_roms_dai_20190827.nc  as  usec3km_roms_dai_20190827.nc
   Copying NLM IC file ../../Data/INI/usec6km_roms_ini.nc  as  usec6km_roms_ini_20190830.nc
   Copying OBS    file ../../Data/OBS/usec3km_roms_obs_20190830.nc  as  usec3km_roms_obs_20190830.nc
   Copying OBS    file ../../Data/OBS/usec6km_roms_obs_20190830.nc  as  usec6km_roms_obs_20190830.nc

Running 4D-Var System:  Cycle = 2   Outer = 0   Phase = background

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 0  Phase = background
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190830)

   mpirun -np 12 romsM_nl roms_nl_usec_era5_20190830.in

   Renaming NLM trajectory usec6km_roms_fwd_20190830.nc  to  usec6km_roms_fwd_20190830_outer0.nc

Running 4D-Var System:  Cycle = 2   Outer = 1   Phase = increment

   Creating 4D-Var Input Script from Template: rbl4dvar_da.in   Outer = 1  Phase = increment
     (Resolution = 6 km, Fprefix = usec6km, Fsuffix = 20190830)

   mpirun -np 12 romsM_da roms_da_usec_era5_20190830.in

Running 4D-Var System:  Cycle = 2   Outer = 1   Phase = analysis

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 1  Phase = analysis
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190830)

   mpirun -np 12 romsM_nl roms_nl_usec_era5_20190830.in

   Renaming NLM trajectory usec6km_roms_fwd_20190830.nc  to  usec6km_roms_fwd_20190830_outer1.nc

Finished 4D-Var outer loops iterations

Finished RBL4D-Var Cycle 2,  Elapsed time = 02:41:15

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres

Finished computations, Total time = 05:20:55
```
---

### The output Files:

- Standard Output Files:
  ``` d
    log_outer0.nl                                 Outer loop 0, Background phase, NLM trajectory
    log_outer1.da                                 Outer loop 1, Increment phase, TLM/ADM inner loops
    log_outer1.nl                                 Outer loop 1, Analysis phase
  ```

- **ROMS** NetCDF Files:
  ``` d
   usec3km_roms_dai_20190827.nc                   Next DA cycle 3km initial state
   usec3km_roms_fwd_20190827_outer0.nc            Outer loop 0, 3km NLM trajectory
   usec3km_roms_fwd_20190827_outer1.nc            Outer loop 1, 3km NLM trajectory
   usec3km_roms_ini_20190827.nc                   NLM 3km initial conditions
   usec3km_roms_itl_20190827.nc                   TLM 3km increments
   usec3km_roms_mod_20190827.nc                   RBL4D-Var model/observations control vectors
   usec3km_roms_obs_20190827.nc                   3km observation vectors
   usec3km_roms_qck_20190827_outer0.nc            Outer loop 0, NLM QuickSave 3km history
   usec3km_roms_qck_20190827_outer1.nc            Outer loop 1, NLM QuickSave 3km history
   usec3km_roms_rst_20190827.nc                   3km NLM restart

   usec6km_roms_adj_20190827.nc                   ADM 6km gradients
   usec6km_roms_fwd_20190827_outer0.nc            Outer loop 0, NLM 6km decimated trajectory
   usec6km_roms_fwd_20190827_outer1.nc            Outer loop 1, NLM 6km decimated trajectory
   usec6km_roms_ini_20190827.nc                   Inner loops,  NLM 6km initial conditions and prior 
   usec6km_roms_itl_20190827.nc                   TLM 6km increments
   usec6km_roms_obs_20190827.nc                   6km observation vectors
   usec6km_roms_tlf_20190827.nc                   Adjoint impulse forcing, TLM forcing
  ```
