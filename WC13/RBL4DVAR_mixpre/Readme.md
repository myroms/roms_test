<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Tutorial: Exercise 3 and Exercise 4

**Technical Description**: [Exercise_3.pdf](https://github.com/myroms/roms_test/edit/feature/info/WC13/RBL4DVAR/Exercise_3.pdf), [Exercise_4.pdf](https://github.com/myroms/roms_test/edit/feature/info/WC13/RBL4DVAR/Exercise_4.pdf)

**Information**:  www.myroms.org/wiki/4DVar_Tutorial_Introduction

**Results**:      www.myroms.org/wiki/RBL4DVAR_Tutorial

This directory includes various files to run the strong/weak
constraint, dual form of 4-Dimensional Variational data (**4D-Var**)
assimilation based on the Restricted B-preconditioned Lanczos
(**RBL4D-Var**) algorithm in the California Current System, 1/3
degree resolution, application (**WC13**).

### Important CPP Options:
```
   RBL4DVAR                RBL4D-Var driver (observation space)
   ANA_SPONGE              Analytical enhanced viscosity/diffusion sponge
   BGQC                    Background quality control of observations
   MINRES                  Minimal Residual Method for minimization
   RPCG                    Restricted B-preconditioned Lanczos minimization
   POSTERIOR_EOFS          Estimate posterior analysis error
   POSTERIOR_ERROR_I       Estimate initial posterior analysis error
   TIME_CONV               Weak-constraint 4D-Var time convolution
   WC13                    Application CPP option
```

### Input NetCDF Files:
```
                       Grid File:  ../Data/wc13_grd.nc
          Nonlinear Initial File:  wc13_ini.nc
                 Forcing File 01:  ../Data/coamps_wc13_lwrad_down.nc
                 Forcing File 02:  ../Data/coamps_wc13_Pair.nc
                 Forcing File 03:  ../Data/coamps_wc13_Qair.nc
                 Forcing File 04:  ../Data/coamps_wc13_rain.nc
                 Forcing File 05:  ../Data/coamps_wc13_swrad.nc
                 Forcing File 06:  ../Data/coamps_wc13_Tair.nc
                 Forcing File 07:  ../Data/coamps_wc13_wind.nc
                   Boundary File:  ../Data/wc13_ecco_bry.nc

     Initial Conditions STD File:  ../Data/wc13_std_i.nc
                  Model STD File:  ../Data/wc13_std_m.nc
    Boundary Conditions STD File:  ../Data/wc13_std_b.nc
        Surface Forcing STD File:  ../Data/wc13_std_f.nc
    Initial Conditions Norm File:  ../Data/wc13_nrm_i.nc
                 Model Norm File:  ../Data/wc13_nrm_m.nc
   Boundary Conditions Norm File:  ../Data/wc13_nrm_b.nc
       Surface Forcing Norm File:  ../Data/wc13_nrm_f.nc
               Observations File:  wc13_obs.nc
```
### Configuration and Input Scripts:
```
   build_roms.csh       ROMS GNU make compiling and linking CSH script
   build_roms.sh        ROMS GNU make compiling and linking BASH script
   cbuild_roms.csh      ROMS CMake compiling and linking CSH script
   cbuild_roms.sh       ROMS CMake compiling and linking BASH script
   job_rbl4dvar.csh     job configuration script
   roms_wc13_daily.in   ROMS standard input script for WC13, NHIS=48,
                          daily forward trajectory snapshots
   roms_wc13_2hours.in  ROMS standard input script for WC13, NHIS=4,
                          two-hours forward trajectory snapshots
   s4dvar.in            4D-Var standard input script template
   wc13.h               WC13 header with CPP options
```

### How to Run this Application:

You need to take the following steps:

- We need to run the model application for a long period
  to compute meaningful circulation statistics,
  like mean and standard deviations for all prognostic state
  variables (**zeta**, **u**, **v**, **T**, and **S**). The standard deviations
  are written to NetCDF files and are read by the **4D-Var**
  algorithm to convert modeled error correlations to error
  covariances. The error covariance matrix, **D**, is very large
  and not well known. It is modeled as the solution of a
  diffusion equation as in Weaver and Courtier (2001).

  - In this application, we need standard deviations for
    initial conditions, surface forcing (**ADJUST_WSTRESS** and
    **ADJUST_STFLUX**), and open boundary conditions (**ADJUST_BOUNDARY**).
    The standard deviations for the initial and open boundary
    conditions are in terms of the unbalanced error covariance
    (**K D<sub>u</sub> K<sup>T</sup>**) since the balanced operator is activated
    (**BALANCE_OPERATOR** and **ZETA_ELLIPTIC**).

  - The balance operator imposes a multivariate constraint on
    the error covariance such that the unobserved variable
    information is extracted from observed data by establishing
    balance relationships (*i.e.*, **T-S** empirical formulas,
    hydrostatic balance, and geostrophic balance) with other
    state variables (Weaver *et al.*, 2005).

  - These standard deviations have already been created for you:
    ```
      ../Data/wc13_std_i.nc     initial conditions
      ../Data/wc13_std_m.nc     model error (if weak constraint)
      ../Data/wc13_std_b.nc     open boundary conditions
      ../Data/wc13_std_f.nc     surface forcing (wind stress and net heat flux)
    ```
- Since we are modeling the error covariance matrix, **D**, we
  need to compute the normalization coefficients to ensure
  that the diagonal elements of the associated correlation
  matrix **C** are equal to unity. There are two methods to compute
  normalization coefficients: **exact** and
  **randomization** (an approximation).

  - The **exact method** is very expensive on large grids. The
    normalization coefficients are computed by perturbing each
    model grid cell with a delta function scaled by the area
    (2D state variables) or volume (3D state variables), and
    then by convolving with the squared-root adjoint and tangent
    linear diffusion operators.

  - The **randomization method** is cheaper and an approximation.
    The normalization coefficients are computed using the approach
    of Fisher and Courtier (1995). The coefficients are initialized
    with random numbers having a uniform distribution (drawn from a
    normal distribution with zero mean and unit variance). Then,
    they are scaled by the inverse squared root of the cell area
    (2D state variable) or volume (3D state variable) and convolved
    with the squared-root adjoint and tangent diffusion operators
    over a specified number of iterations, **Nrandom**.

  Check the following parameters in the **4D-Var** input script
  **s4dvar.in**:
  ```
      Nmethod  == 0             ! normalization method
      Nrandom  == 5000          ! randomization iterations

      LdefNRM == F F F F        ! Create a new normalization files
      LwrtNRM == F F F F        ! Compute and write normalization

      CnormM(isFsur) =  T       ! Model, 2D variable at RHO-points
      CnormM(isUbar) =  T       ! Model, 2D variable at U-points
      CnormM(isVbar) =  T       ! Model, 2D variable at V-points
      CnormM(isUvel) =  T       ! Model, 3D variable at U-points
      CnormM(isVvel) =  T       ! Model, 3D variable at V-points
      CnormM(isTvar) =  T T     ! Model, NT tracers

      CnormI(isFsur) =  T       ! IC, 2D variable at RHO-points
      CnormI(isUbar) =  T       ! IC, 2D variable at U-points
      CnormI(isVbar) =  T       ! IC, 2D variable at V-points
      CnormI(isUvel) =  T       ! IC, 3D variable at U-points
      CnormI(isVvel) =  T       ! IC, 3D variable at V-points
      CnormI(isTvar) =  T T     ! IC, NT tracers

      CnormB(isFsur) =  T       ! OBC, 2D variable at RHO-points
      CnormB(isUbar) =  T       ! OBC, 2D variable at U-points
      CnormB(isVbar) =  T       ! OBC, 2D variable at V-points
      CnormB(isUvel) =  T       ! OBC, 3D variable at U-points
      CnormB(isVvel) =  T       ! OBC, 3D variable at V-points
      CnormB(isTvar) =  T T     ! OBC, NT tracers

      CnormF(isUstr) =  T       ! Surface Forcing, U-momentum stress
      CnormF(isVstr) =  T       ! Surface Forcing, V-momentum stress
      CnormF(isTsur) =  T T     ! Surface Forcing, NT tracers fluxes
  ```
  These normalization coefficients have already been computed for you
  (see **`../Normalization`**) using the **exact method** since this
  application has a small grid (**54x53x30**):
  ```
      ../Data/wc13_nrm_i.nc     initial conditions
      ../Data/wc13_nrm_m.nc     model error (if weak constraint)
      ../Data/wc13_nrm_b.nc     open boundary conditions
      ../Data/wc13_nrm_f.nc     surface forcing (wind stress and net heat flux)
  ```
  Notice that the switches **LdefNRM** and **LwrtNRM** are all **.FALSE.**
  (**F**) since we already computed these coefficients.

  The normalization coefficients need to be computed only once
  for a particular application provided that the grid, land/sea
  masking (if any), and decorrelation scales (**HdecayI**, **VdecayI**,
  **HdecayB**, **VdecayV**, and **HdecayF**) remain the same. Notice that
  large spatial changes in the normalization coefficient
  structure are observed near the open boundaries and land/sea
  masking regions.

- Customize your preferred **build** script and provide the
  appropriate values for:

  - Root directory, **MY_ROOT_DIR**
  - **ROMS** source code path, **MY_ROMS_SRC**
  - Fortran compiler, **FORT**
  - MPI flags, **USE_MPI** and **USE_MPIF90**
  - Path of **MPI**, **NetCDF**, and **ARPACK** libraries according to
    the compiler. Notice that you need to provide the
    correct locations of these libraries for your computer.
    If you want to ignore this section, comment (turn off) the
    assignment for the macro **USE_MY_LIBS**.

- Notice that the most important CPP options for this application
  are specified in the **build** script instead of the header file
  **wc13.h** allows flexibility with different CPP options:
  ```
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DRBL4DVAR"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DANA_SPONGE"
      #setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DMINRES"
      #setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DRPCG"
      #setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DTIME_CONV"

      #setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DBGQC"

      #setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DPOSTERIOR_EOFS"
      #setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DPOSTERIOR_ERROR_I"
  ```
  For this to work, however, any **#undef** directives **must** be
  avoided in the header file **wc13.h** since it has precedence
  during C-preprocessing.

- You **must** use any of the **build** scripts to compile.

- Customize the **ROMS** input script **roms_wc13.in** and specify
  the appropriate values for the distributed-memory tile partition.
  It is set by default to:
  ```
      NtileI == 2                               ! I-direction partition
      NtileJ == 4                               ! J-direction partition
  ```
  Notice that the adjoint-based algorithms can only be run
  in parallel using **MPI**.  This is because of the way that the
  adjoint model is constructed.

- Customize the configuration script **job_rbl4dvar.csh** and provide
  the appropriate place for the **substitute** Perl script:
  ```
      set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute
  ```
  This Perl script is distributed with **ROMS**, and it is found in the
  **ROMS/Bin** sub-directory. Alternatively, you can define
  **ROMS_ROOT** environmental variable in your login script. For example, I have:
  ```
     setenv ROMS_ROOT ${HOME}/ocean/repository/git/roms
  ```

- Execute the configuration **job_rbl4dvar.csh** `BEFORE` running
  the model.  It copies the required files and creates **i4dvar.in**
  input script from template **s4dvar.in**. This has to be done
  EVERY TIME that you run this application. We need a clean and
  fresh copy of the initial conditions and observation files
  since they are modified by **ROMS** during execution.

- Run **ROMS** with data assimilation:
  ```
      mpirun -np 8 romsM roms_wc13_daily.in > & log &

      or

      mpirun -np 8 romsM roms_wc13_2hours.in > & log &
  ```

  Notice that the nonlinear trajectory can be written either
  daily (**NHIS=48** if using **roms_wc13_daily.in**) or every
  two hours (**NHIS=4** if using **roms_wc13_2hours.in**). It is
  the basic state trajectory used to linearize the tangent linear
  and adjoint models.

  It turns out that the daily sampling is over the
  limit where the tangent linear approximation is valid. The
  results are much better when using the two-hour snapshots.
  The two set-ups are provided to make the user aware of the
  validity of the tangent linear approximation in highly
  nonlinear circulations. The differences will be noticeable
  when computing observation impacts and observation sensitivities.

- We recommend creating new subdirectories **EX3_CONGRAD**,
  **EXE_MINRES**, and **EX3_RPCG** (Tutorial Exercise **3** using
  default, **MINRES**, and **RPCG** algorithms) to save the solution
  in it for analysis and plotting to avoid overwriting output
  files when activating different CPP options and parameters.
  For example:
  ```
      mkdir EX3_RPCG
      mv Build_roms rbl4dvar.in *.nc log EX3_RPCG
      cp -p romsM roms_wc13.in EX3_RPCG
  ```
  Check Exercise **3** instructions for more details.

- Analyze the results using the plotting scripts (Matlab or
  **ROMS** plotting package) provided in the **`../plotting`** directory:

  - **`plot_rbl4dvar_cost.m`**:         plots **RBL4D-Var** cost function.

  - **`plot_rbl4dvar_increments.m`**:   plots **RBL4D-Var** increments to
                                        initial conditions.

  - **`plot_eof_eigenvalues.m`**:        plots the eigenvalues for each EOF
                                         of the analysis error covariance
                                         matrix and the randomized trace
                                         estimates
                                         (User needs to edit **Inp** file).

  - **`plot_posterior_EOF_fields.m`**:    plots selected **RBL4D-Var** analysis
                                          error covariance matrix EOF
                                          (User needs to edit **Inpa** file).

  - **`plot_prior_posterior_errors.m`**:  plots the difference between the
                                          prior and posterior error
                                          covariance deviations
                                          (User needs to edit **Inpa** file).

  - **`ccnt_rbl4dvar_increments.in`**:    plots **RBL4D-Var** initial conditions
                                          increments contours at **z=-100m**.

  - **`csec_rbl4dvar_increments.in`**:    plots **RBL4D-Var** initial conditions
                                          increments cross-sections along **37N**.

  - **`ccnt_posterior_EOF_fields.in`**:   plots selected **RBL4D-Var** analysis
                                          error covariance matrix EOF
                                          contours at **z=-100m**
                                          (User needs to change **R4DVAR**
                                          directory to **RBL4DVAR**).

   - **`csec_posterior_EOF_fields.in`**   plots selected **RBL4D-Var** analysis
                                          error covariance matrix EOF
                                          cross-sections along **37N**
                                          (User needs to change **R4DVAR**
                                           directory to **RBL4DVAR**).

 ---

### References:

- Moore, A.M., H.G. Arango, G. Broquet, B.S. Powell, A.T. Weaver,
  and J. Zavala-Garay, **2011**: The Regional Ocean Modeling System
  (ROMS)  4-dimensional variational data assimilation systems,
  Part I - System overview and formulation, *Prog. Oceanogr.*,
  **91**, 34-49, https://doi.org/10.1016/j.pocean.2011.05.004.

- Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani,
  B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson,
  **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional
  variational data assimilations systems, Part II - Performance
  and application to the California Current System, *Prog.
  Oceanogr.*, **91**, 50-73,
  https://doi.org/10.1016/j.pocean.2011.05.003.

- Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani,
  B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson,
  **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional
  variational data assimilations systems, Part III - Observation
  impact and observation sensitivity in the California Current
  System, *Prog. Oceanogr.*, **91**, 74-94,
  https://doi.org/10.1016/j.pocean.2011.05.005.

