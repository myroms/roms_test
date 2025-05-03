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
CLASS objects. For details, please check the **ROMS/Utility/roms_interp.F** and
**ROMS/Utility/state_regrid.F**﻿ modules.

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
file (**DAINAME**) to initialize the next **4D-Var** cycle. The atmospheric forcing is from
the **NAM** or the **ERA-5** fields. The solutions below are for the **NAM** forcing
configured with **Nouter=1** and **Ninner=16**.

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
   PIO_LIB                 Using Parallel-IO from the PIO library
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
  usec.h                        ROMS header file, USEC application
  ```
The **submit_mixres_rbl4dvar.sh** script is complex.  Please study it carefully. You can modify
for your appropriate computer environment and **RBL4D-Var** running parameters. There is a
user-customizable section above the following heading:

  ``` sh
  #######################################################################
  ## Main body of script starts here. It is very unlikely that the USER
  ## needs to modify it.
  #######################################################################
  ```
It uses the following **Perl** scripts: **substitute** and **dates**, which are distributed in
**ROMS** source code. They are located in **${ROMS_ROOT}/ROMS/Bin**. Thus, you must set
**ROMS_ROOT** to the appropriate path in the user-customizable section.


### How to Compile ROMS:
   
To compile **ROMS** data assimilation executables for **4D-Var** outer and inner loops, use:
  ``` d
    build_split.sh -nl -pio -j 10                 creates executable romsM_nl
    build_split.sh -da -pio -j 10                 creates executable romsM_da
  ```
Notice it asks to compile with the **PIO-NetCDF** library (**-pio** option) to speed up the
computations. Also, the **4D-Var split** scheme uses two different executables for **ROMS**:
  ``` d
      romsM_nl       Nonlinear driver for RBL4D-Var Background and Analysis phases, outer loops

      romsM_da       Data assimilation driver for RBL4D-Var Increment phase, inner loops
  ```
Please review the **build** script because it contains **CPP** options for each executable. Also, it
sets standard **CPP** options for both executables. This strategy is preferable to having a **ROMS**
header file for the 3km and 6km grids.

To submit the job on 12 CPUs via SLURM or not, use:
  ``` d
    sbatch submit_mixres_rbl4dvar.sh        or
    submit_mixres_rbl4dvar.sh > & log &
  ```
Users may modify the number of processors to use in the **submit_mixres_rbl4dvar.sh** script.

---

### ROMS Execution Sequence:

 The **submit_mixres_rbl4dvar.sh** script creates the **2019.08.27** and **2019.08.30**
 sub-directories for **RBL4D-Var** Cycle **1** and Cycle **2**, respectively. It includes
 all the required input scripts to run the **mixed-resolution RBL4D-Var** system. The input
 scripts are generated from the templates.  The **submit_mixres_rbl4dvar.sh** script is
 designed to run sequential data assimilation 3-day cycles. It reports the execution sequence
 with detailed information. It can be executed in dry run mode (**DRYRUN=1**) to print its
 configuration without running. Please do it before submitting a large job, since
 it will take some computer resources and time.

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
   NL Standard Input Script: roms_nl_usec_nam_20190827.in   (outer loops grid)
   DA Standard Input Script: roms_da_usec_nam_20190827.in   (inner loops grid)
  NL RBL4D-Var Input Script: rbl4dvar_nl.in  (outer loops grid)
  DA RBL4D-Var Input Script: rbl4dvar_da.in  (inner loops grid)

Cycle 1, Creating run sub-directory: 2019.08.27

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres/2019.08.27

   Creating NL ROMS Standard Input Script: roms_nl_usec_nam_20190827.in
   Creating DA ROMS Standard Input Script: roms_da_usec_nam_20190827.in
   Copying NLM IC file ../../Data/INI/usec3km_roms_ini_20190827.nc  as  usec3km_roms_ini_20190827.nc
   Copying NLM IC file ../../Data/INI/usec6km_roms_ini.nc  as  usec6km_roms_ini_20190827.nc
   Copying OBS    file ../../Data/OBS/usec3km_roms_obs_20190827.nc  as  usec3km_roms_obs_20190827.nc
   Copying OBS    file ../../Data/OBS/usec6km_roms_obs_20190827.nc  as  usec6km_roms_obs_20190827.nc

Running 4D-Var System:  Cycle = 1   Outer = 0   Phase = background

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 0  Phase = background
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190827)

   mpirun -np 12 romsM_nl roms_nl_usec_nam_20190827.in

   Renaming NLM trajectory usec6km_roms_fwd_20190827.nc  to  usec6km_roms_fwd_20190827_outer0.nc

Running 4D-Var System:  Cycle = 1   Outer = 1   Phase = increment

   Creating 4D-Var Input Script from Template: rbl4dvar_da.in   Outer = 1  Phase = increment
     (Resolution = 6 km, Fprefix = usec6km, Fsuffix = 20190827)

   mpirun -np 12 romsM_da roms_da_usec_nam_20190827.in

Running 4D-Var System:  Cycle = 1   Outer = 1   Phase = analysis

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 1  Phase = analysis
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190827)

   mpirun -np 12 romsM_nl roms_nl_usec_nam_20190827.in

   Renaming NLM trajectory usec6km_roms_fwd_20190827.nc  to  usec6km_roms_fwd_20190827_outer1.nc

Finished 4D-Var outer loops iterations

Finished RBL4D-Var Cycle 1,  Elapsed time = 02:38:49

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
   NL Standard Input Script: roms_nl_usec_nam_20190830.in   (outer loops grid)
   DA Standard Input Script: roms_da_usec_nam_20190830.in   (inner loops grid)
  NL RBL4D-Var Input Script: rbl4dvar_nl.in  (outer loops grid)
  DA RBL4D-Var Input Script: rbl4dvar_da.in  (inner loops grid)

Cycle 2, Creating run sub-directory: 2019.08.30

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres/2019.08.30

   Creating NL ROMS Standard Input Script: roms_nl_usec_nam_20190830.in
   Creating DA ROMS Standard Input Script: roms_da_usec_nam_20190830.in
   Copying NLM IC file ../2019.08.27/usec3km_roms_dai_20190827.nc  as  usec3km_roms_dai_20190827.nc
   Copying NLM IC file ../../Data/INI/usec6km_roms_ini.nc  as  usec6km_roms_ini_20190830.nc
   Copying OBS    file ../../Data/OBS/usec3km_roms_obs_20190830.nc  as  usec3km_roms_obs_20190830.nc
   Copying OBS    file ../../Data/OBS/usec6km_roms_obs_20190830.nc  as  usec6km_roms_obs_20190830.nc

Running 4D-Var System:  Cycle = 2   Outer = 0   Phase = background

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 0  Phase = background
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190830)

   mpirun -np 12 romsM_nl roms_nl_usec_nam_20190830.in

   Renaming NLM trajectory usec6km_roms_fwd_20190830.nc  to  usec6km_roms_fwd_20190830_outer0.nc

Running 4D-Var System:  Cycle = 2   Outer = 1   Phase = increment

   Creating 4D-Var Input Script from Template: rbl4dvar_da.in   Outer = 1  Phase = increment
     (Resolution = 6 km, Fprefix = usec6km, Fsuffix = 20190830)

   mpirun -np 12 romsM_da roms_da_usec_nam_20190830.in

Running 4D-Var System:  Cycle = 2   Outer = 1   Phase = analysis

   Creating 4D-Var Input Script from Template: rbl4dvar_nl.in   Outer = 1  Phase = analysis
     (Resolution = 3 km, Fprefix = usec3km, Fsuffix = 20190830)

   mpirun -np 12 romsM_nl roms_nl_usec_nam_20190830.in

   Renaming NLM trajectory usec6km_roms_fwd_20190830.nc  to  usec6km_roms_fwd_20190830_outer1.nc

Finished 4D-Var outer loops iterations

Finished RBL4D-Var Cycle 2,  Elapsed time = 02:40:10

Changing to directory: /home/arango/ROMS/Projects/USEC/RBL4DVAR_mixres

Finished computations, Total time = 05:18:59
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
---

### Results

- **4D-Var Cycle 1**: Aug 27 - Aug 30, 2019, **NAM** forcing. Top-to-bottom figures showing 3km and 6km increments for free surface, potential temperature, salinity, u-velocity, and v-velocity at 20m depth. Notice that higher and lower resolution increments are indistinguishable. They are plotted with the provided **plot_state.m** Matlab script.
  
| 3km Increments at z=20m   | 6km Increments at z=20m  |
:--------------------------:|:-------------------------:
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/848ab5a3-af57-4b59-a361-f77724054f2d"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/0b462249-815a-456f-844a-4db6822417d0"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/d32b2ada-f68e-44e2-8a62-e7706ce45c98"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/d1e9ea1b-2949-40fb-bf2c-0aa458380923"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/17692b87-208c-44c1-a3d4-6f0cc2dad284"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/f801aacc-21e4-4fa7-92a1-0e6aa7f2298c"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/c66c39ad-1e88-4c3a-aadf-b9a89d0da21f"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/7dad24ab-9a1f-4a7a-a3c5-d2ce1bf06bfc"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/4eb6bb6f-5ac3-4cd1-86ff-ef6f6c682c80"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/880d475a-2fa5-4748-bd68-9e7bd295088e"> |

- **4D-Var Cycle 2**: Aug 30 - Sep 2, 2019, **NAM** forcing. Top-to-bottom figures showing 3km and 6km increments for free surface, potential temperature, salinity, u-velocity, and v-velocity at 20m depth. Notice that higher and lower resolution increments are indistinguishable.

| 3km Increments at z=20m   | 6km Increments at z=20m  |
:--------------------------:|:-------------------------:
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/24bcefe1-5b7f-4367-8192-794a7da96b40"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/73c68de5-703b-469d-896d-b3662bd28d47"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/48f16b58-bd31-4f65-9e93-e71e4bed8f47"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/18be6301-b85c-4093-89d1-fd6922187aca"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/2b2c3ef7-6986-4e96-bb7f-99a65fae4e9a"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/6afc291b-1419-4745-839c-b4e530c6ec11"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/58e31ff7-181f-4a63-9ce1-084ef6a63af7"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/b68a3bdc-7270-434b-a16c-aecd2d1be293"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/f4750e53-f257-47a4-ae0d-b55f83b72429"> | <img width="400" alt="image" src="https://github.com/user-attachments/assets/8a1943f7-e816-4f14-b4fd-3a13ad9c7cf8"> |

- **4D-Var Penalty Function**: The figures below show the various cost functions for **NAM** forced **4D-Var** cycles 1 and 2 and how they compare with **Nouter=2** and **Ninner=8** solutions. Notice that the y-axis is on a logarithmic scale. They are plotted using the **plot_penalty.m** Matlab script.

| 4D-Var Cycle 1            | 4D-Var Cycle 2           |
:--------------------------:|:-------------------------:
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/d81bfd9d-0974-4756-a8e3-effd124f3f53"> | <img title="image" width="400" alt="image" src="https://github.com/user-attachments/assets/a7e30cd8-5bf6-4c9a-a72f-cd1affcc87b4"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/9c28e615-7f13-4ced-aa9d-e784376d269c"> | <img title="image" width="400" alt="image" src="https://github.com/user-attachments/assets/bbfecc10-06ea-439c-b503-d372f22c3312"> |

- **Minimization control vectors**: Innovations (Observations minus Background), Increment (Analysis minus Background), Residual (observation minus Analysis), and prescribed background error standard deviations for the **NAM** forced case. The assimilated observations include SSH altimetry, HF Radar surface currents, satellite SST, and insitu Temperature and salinity. They are plotted with **plot_4dvar_vectors.m** Matlab script.

| 4D-Var Cycle 1            | 4D-Var Cycle 2           |
:--------------------------:|:-------------------------:
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/bc525126-b0f6-44da-8136-7474ed7adfa5"> | <img title="image" width="400" alt="image" src="https://github.com/user-attachments/assets/914e421f-848c-470f-9ed5-a720fddde6e5"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/04146fba-30d5-43bb-a1ac-5d0d9154d2f2"> | <img title="image" width="400" alt="image" src="https://github.com/user-attachments/assets/adfffb46-b80d-457b-8ed4-4df1c7c3c01f"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/166118ed-fc15-4f57-9b75-8de6cfb5490e"> | <img title="image" width="400" alt="image" src="https://github.com/user-attachments/assets/795745d9-61d3-4836-a76d-77ebec407e78"> |
|<img width="400" alt="image" src="https://github.com/user-attachments/assets/ae94b5ae-d3ee-4b4b-b853-b5516b3c65fc"> | <img title="image" width="400" alt="image" src="https://github.com/user-attachments/assets/aa11aaa3-6c91-4a30-a535-0625c6754ee5"> |

- **Desroziers _et al._ (2005) Diagnostics**: It computes the diagnosed observation and background variances per datum type associated with the control vector and compares them with the values used in the **4D-Var** minimization (**NAM** forced case). It measures how correct or incorrect the specified error hypothesis is regarding the 4D-Var data assimilation cycles **Innovation**, **Increment**, and **Residual** vectors. Here, the diagnostics are computed for the two data assimilation cycles using **plot_desroziers.m** Matlab script.

<img width="600" alt="image" src="https://github.com/user-attachments/assets/320d8da5-8a63-4281-8a38-17d4adfbfdf5">
