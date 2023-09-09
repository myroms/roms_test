<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Tutorial: Exercise 7

 
**Information**:  www.myroms.org/wiki/4DVar_Tutorial_Introduction

**Results**:      www.myroms.org/wiki/Array_Modes_Tutorial


This directory includes various files to run the Strong/Weak
constraint, 4-Dimensional Variational data (**4D-Var**) assimilation
stabilized representer matrix array modes in the California
Current System, 1/3 degree resolution, application (**WC13**).

### Important CPP Options:
```
   ARRAY_MODES             Representer Matrix Array Modes driver
   ANA_SPONGE              Analytical enhanced viscosity/diffusion sponge
   ARRAY_MODES_SPLIT       Analysis due to IC, surface forcing, and OBC
   RPCG                    Restricted B-preconditioned Lanczos minimization
   SKIP_NLM                Skipping running NLM, reading NLM state trajectory
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

        Adjoint Sensitivity File:  wc13_ads.nc
     Initial Conditions STD File:  ../Data/wc13_std_i.nc
                  Model STD File:  ../Data/wc13_std_m.nc
    Boundary Conditions STD File:  ../Data/wc13_std_b.nc
        Surface Forcing STD File:  ../Data/wc13_std_f.nc
    Initial Conditions Norm File:  ../Data/wc13_nrm_i.nc
                 Model Norm File:  ../Data/wc13_nrm_m.nc
   Boundary Conditions Norm File:  ../Data/wc13_nrm_b.nc
       Surface Forcing Norm File:  ../Data/wc13_nrm_f.nc
               Observations File:  wc13_obs.nc
            Lanczos Vectors File:  wc13_lcz.nc
```

### Configuration and Input Scripts:

```
   build_roms.csh       csh  script to compile application
   build_roms.sh        bash script to compile application
   cbuild_roms.csh      csh  CMake script to compile application
   cbuild_roms.sh       bash CMake script to compile application
   job_array_modes.csh  job configuration script
   roms_wc13.in         ROMS standard input script for WC13
   s4dvar.in            4D-Var standard input script template
   wc13.h               WC13 header with CPP options
```

### How to Run this Application:

You need to take the following steps:

- We need to run the model application for a period that is
      long enough to compute meaningful circulation statistics,
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
      (**K Du K'**) since the balanced operator is activated
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
    **s4dvar.in** (see input script for details):
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

 - Before you run this application, you need to execute the job
   script:
   ```
      job_array_modes.csh
   ```
   In **RBL4D-Var** (observation space minimization, dual formulation), the Lanczos
   vectors are stored in output **4D-Var** NetCDF file **wc13_mod.nc**.
  
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
    **wc13.h** allow flexibility with different CPP options:
    ```
      setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DARRAY_MODES"
      setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DANA_SPONGE"
      setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DARRAY_MODES_SPLIT"
      setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DRPCG"
      setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSKIP_NLM"
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

  - Customize the configuration script **job_array_modes.csh** and provide
    the appropriate place for the **substitute** Perl script:
    ```
      set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute
    ```
    This Perl script is distributed with **ROMS**, and it is found in the
    **ROMS/Bin** sub-directory. Alternatively, you can define
    **ROMS_ROOT** environmental variable in your login script. For example,
    I have:
    ```
      setenv ROMS_ROOT ${HOME}/ocean/repository/git/roms
    ```
  - The only change you need to make is to **s4dvar.in**, where you
    will select the array mode you wish to calculate (you may
    only calculate one mode at a time). The choice of array mode is
    determined by the parameter **Nvct**. The array modes are referenced
    in reverse order, so choosing **Nvct=Ninner-1** is the significant array
    mode. Note that **Nvct** must be assigned a numeric value
    (i.e. **Nvct=10** for the **RBL4D-Var** tutorial). 

 - Execute the configuration **job_array_modes.csh** `BEFORE` running
   the model.  It copies the required files and creates **rbl4dvar.in**
   input script from template **s4dvar.in**. This has to be done
   EVERY TIME that you run this application. We need a clean and
   fresh copy of the initial conditions and observation files
   since they are modified by **ROMS** during execution.

 - Run **ROMS** with data assimilation:
    ```
      mpirun -np 4 romsM roms_wc13.in > & log &
    ```
 - We recommend creating a new subdirectory **EX7** (Tutorial Exercise 7),
   and saving the solution in it for analysis and plotting to avoid
   overwriting output files when playing with different CPP options
   and parameters. For example:
   ```
      mkdir EX7
      mv Build_roms rbl4var.in *.nc log EX7
      cp -p romsM roms_wc13.in EX7
   ```
 - Analyze the results using the plotting scripts (Matlab or
   **ROMS** plotting package) provided in the **../plotting** directory:
   
   - **plot_array_modes.m**: plots chosen stabilized representer matrix array modes.
  
   - **plot_array_modes_spectrum.m**:  Plots array modes eigenvalues spectrum.

   - **ccnt_array_modes_[*].in**: plots chosen stabilized representer
                                  matrix array modes maps at the
                                  surface or at **z=-100m**.

   - **csec_array_modes_[*].in**: plots chosen stabilized representer
                                  matrix array modes cross-sections
                                  along **37N**.
---

### References:

- Moore, A.M., H.G. Arango, C.A. Edwards, **2017**: Reduced-Rank
  Array Modes of the California Current Observing System,
  *J. Geophys. Res. Ocean*, **122**, 
  https://doi.org/10.1002/2017JC013172.

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
