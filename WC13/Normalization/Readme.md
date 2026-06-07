<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Tutorial: B-Normalization Factors and Dirac Testing

**Information**:  www.myroms.org/wiki/4DVar_Tutorial_Introduction

**Results**:      www.myroms.org/wiki/4DVar_Normalization_Tutorial

This directory includes various files needed to model the spreading of the background-error covariance matrix (**B**) in 4-dimensional data assimilation applications for the California Current System at 1/3-degree resolution (**WC13**). It also tests the associated error hypothesis for **B** using Dirac delta functions, with the specified correlation functions for each variable in the control vector.

In **ROMS**, the **B** matrix is factorized according to Weaver and Courtier (2001) as follows:

$$ \boldsymbol{B = K_{b} \Sigma C \Sigma{^T} {K_{b}}^{T}} $$

Here, $\boldsymbol{K_b}$ represents the balanced components of the background error, $\boldsymbol{\Sigma}$ denotes the diagonal matrix of standard deviations, and $\boldsymbol{C}$ is the correlation matrix. Spreading is commonly modeled using pseudo-diffusion operators in the spatial correlation space, as outlined by Weaver and Coutier (2001), Weaver and Mirouze (2013), and Weaver et al. (2016, 2018). In these models, the diffusion coefficient, $\kappa$, is proportional to the square of the correlation length scale:

$$ {\delta\eta\over\delta{s}} - \nabla(\kappa\nabla\eta) = 0$$


A square root factorization of the correlation matrix $\boldsymbol{C}$ is employed to maintain symmetry despite rounding errors,

$$ \boldsymbol{ C = \Lambda {\mathcal{L}^{1/2}} {W^{-1}} {\mathcal{L}^{T/2}} \Lambda } $$

In this context, $\boldsymbol{\Lambda}$ is a diagonal matrix of the normalization factors ensuring that $\boldsymbol{C}$ ranges $\pm 1$, $\boldsymbol{\mathcal{L}}$ represents the matrix obtained by solving the linearized diffusion operator, and $\boldsymbol{W}$ is a diagonal matrix corresponding to the grid cell area or volume.

The objective is to compute the $\boldsymbol{\Lambda}$ normalization coefficients, which remain invariant for a fixed application grid and specified correlation scales. It is **advisable** to compute these coefficients independently of the 4D-Var application, as computational costs increase with grid size. The normalization coefficients may be determined using either an **exact** or an **approximate** method. The **exact** approach is computationally intensive, as $\boldsymbol{\Lambda}$ is obtained by perturbing each model grid cell with a delta function scaled by the area (for 2D factors) or volume (for 3D factors), followed by convolution with the square-root diffusion operators. The **approximate** method is more computationally efficient and employs the **randomization** technique described by Fisher and Courtier (1995). In this approach, the grid is initialized with random numbers drawn from a normal distribution with zero mean and unit variance. These values are then scaled by the inverse of the square root of the cell area (for 2D factors) or volume (for 3D factors) and convolved with the square-root diffusion operator over a specified number of iterations, denoted as **Nrandom**.

Within **ROMS**, the background error covariance matrix may be represented using either a multi-scale or a mono-scale approach. The multi-scale formulation expresses **B** as a linear combination of distinct spatial scales, allowing representation of both broad structures and fine-scale features and reducing scale aliasing in the data assimilation cost function (Weaver et al., 2016). In contrast, the mono-scale formulation employs a single spatial scale. The multi-scale approach, as described by Weaver _et al._ (2016), employs an implicit horizontal pseudo-diffusion operator implemented via a Lanczos formulation of the Conjugate Gradient (**CG**) and Chebyshev Iteration (**CI**) solvers, whereas the mono-scale default method uses an explicit horizontal algorithm. The **CG** solver computes the Ritz extrema eigenvalues required by the **CI** algorithm, which remain invariant for a fixed application grid and a given value of $\kappa$, allowing these estimates to be precomputed and stored. The **CG** algorithm is initialized with random vectors when computing the normalization factors, $\boldsymbol{\Lambda}$, which are computationally intensive. Error correlations are assumed to be separable in the horizontal and vertical directions. The vertical diffusion operator is implicit in both approaches. The multi-scale algorithm is activated by selecting the **MULTI_SCALE_B** option.

The multi-scale concept, represented as $\boldsymbol{B = \sum_{i}^{ns} {W_i} {B_i}}$, involves a weighted sum of $\boldsymbol{B_i}$ values across multiple $\boldsymbol{ns}$ scales. In practical applications, two or more distinct scales are typically combined. The weight coefficients must sum to unity, $\boldsymbol{\sum_{i}^{ns} {W_i}= 1}$.

A primary advantage of the implicit horizontal multi-scale operator is its ability to accommodate spatially varying correlation length scales for the $\kappa$-diffusion coefficient tensor. When the **NONUNIFORM_SCALES** option is enabled, a horizontal map of **isotropic** or **anisotropic** correlations can be specified and imported from an input NetCDF file.

In the **WC13** configuration, **B**-spreading and smoothing are scaled according to the local Rossby radius, as described below. At present, the spatially varying correlations are strictly two-dimensional, and their values are replicated at each vertical level for three-dimensional variables in the control vector. The distribution of horizontal correlation scales is read from the input NetCDF file. For temperature, the following NetCDF schema applies:

``` d
	double temp_Bcorr(Nscale, axis, eta_rho, xi_rho) ;
		temp_Bcorr:long_name = "potential temperature horizontal background-error decorrelation length scales" ;
		temp_Bcorr:units = "meter" ;
		temp_Bcorr:standard_name = "sea_water_potential_temperature" ;
		temp_Bcorr:grid = "grid" ;
		temp_Bcorr:location = "face" ;
		temp_Bcorr:axis = "1: abscissa, 2: ordinate" ;
		temp_Bcorr:depth = "replicated" ;
		temp_Bcorr:coordinates = "lon_rho lat_rho axis Nscale" ;
		temp_Bcorr:_FillValue = 1.e+37 ;
```

The **axis** dimension is set to **2**, where **1** corresponds to the **x**-axis (abscissa, **i**-index) and **2** to the **y**-axis (ordinate, **j**-index) of the correlation map. The **Nscale** dimension specifies the number ($\boldsymbol{ns}$) of **B** scales to be combined. If the values for the **x**- and **y**-axes are identical, the resulting correlation shapes are **isotropic**. Otherwise, the map yields **anisotropic** correlations. Several input files are provided as follows:

- Isotropic correlation with a spatially varying Rossby radius in both the **x**- and **y**-directions, where the values are equal (**`wc13_Bcorr_xy.nc`** file).
- Anisotropic correlation with a spatially varying Rossby radius in the **x**-direction and a constant value of **30** km in the **x**-direction (**`wc13_Bcorr_x.nc`** file).
- Anisotropic correlation with a spatially varying Rossby radius in the **y**-direction and a constant value of **30** km in the **y**-direction (**`wc13_Bcorr_y.nc`** file).

The following figure shows a map of the first baroclinic Rossby radius, with a lower limit of **30** km imposed by grid resolution. The spatially varying Rossby radius functions as a horizontal correlation scale.

<p align="center">
  <img width="600" alt="temp_Bcorr_RR" src="https://github.com/user-attachments/assets/c72c774e-9b92-4fd7-ac24-ec342c3c9971" />
</p>

> [!IMPORTANT]  
> Users are responsible for generating the input spatially varying decorrelation scales NetCDF file. The metadata schema, provided as a **CDL** file, is available in [s4dvar_Bcorrelation.cdl](https://github.com/myroms/roms/blob/develop/Data/ROMS/CDL/s4dvar_Bcorrelation.cdl).




### Important CPP Options:
```
   NORMALIZATION         4D-Var error covariance normalization factors
   WC13                  Application CPP option
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
```

### Output NetCDF Files:
```
    Initial Conditions Norm File:  wc13_nrm_i.nc
                 Model Norm File:  wc13_nrm_m.nc
   Boundary Conditions Norm File:  wc13_nrm_b.nc
       Surface Forcing Norm File:  wc13_nrm_f.nc
```
### Configuration and Input Scripts:
```
   build_roms.csh         ROMS GNU make compiling and linking CSH script
   build_roms.sh          ROMS GNU make compiling and linking BASH script
   cbuild_roms.csh        ROMS CMake compiling and linking CSH script
   cbuild_roms.sh         ROMS CMake compiling and linking BASH script
   job_normalization.csh  job configuration script
   roms_wc13.in           ROMS standard input script for WC13
   s4dvar.in              4D-Var standard input script template
   wc13.h                 WC13 header with CPP options
```
### Important Parameters:

Since we are modeling the error covariance matrix, **D**, we need to
compute the normalization coefficients to ensure that the diagonal
elements of the associated correlation matrix **C** are equal to unity.
There are two methods to compute normalization coefficients: **exact**
and **randomization** (an approximation).

The **exact method** is very expensive on large grids. The normalization
coefficients are computed by perturbing each model grid cell with a
delta function scaled by the area (2D state variables) or volume
(3D state variables), and then by convolving with the squared-root
adjoint and tangent linear diffusion operators.

The **randomization method** is cheaper. The normalization coefficients
are computed using the approach of Fisher and Courtier
(1995). The coefficients are initialized with random numbers having
a uniform distribution (drawn from a normal distribution with zero
mean and unit variance). Then, they are scaled by the inverse
squared-root of the cell area (2D state variable) or volume (3D state
variable) and convolved with the squared-root adjoint and tangent
diffusion operators over a specified number of iterations, **Nrandom**.

Check the following parameters in the **4D-Var** input script **s4dvar.in**:
```
      Nmethod  == 0             ! normalization method
      Nrandom  == 5000          ! randomization iterations

      LdefNRM == T T T T        ! Create a new normalization files
      LwrtNRM == T T T T        ! Compute and write normalization

      CnormI(isFsur) =  T       ! 2D variable at RHO-points
      CnormI(isUbar) =  T       ! 2D variable at U-points
      CnormI(isVbar) =  T       ! 2D variable at V-points
      CnormI(isUvel) =  T       ! 3D variable at U-points
      CnormI(isVvel) =  T       ! 3D variable at V-points
      CnormI(isTvar) =  T T     ! NT tracers

      CnormB(isFsur) =  T       ! 2D variable at RHO-points
      CnormB(isUbar) =  T       ! 2D variable at U-points
      CnormB(isVbar) =  T       ! 2D variable at V-points
      CnormB(isUvel) =  T       ! 3D variable at U-points
      CnormB(isVvel) =  T       ! 3D variable at V-points
      CnormB(isTvar) =  T T     ! NT tracers

      CnormF(isUstr) =  T       ! surface U-momentum stress
      CnormF(isVstr) =  T       ! surface V-momentum stress
      CnormF(isTsur) =  T T     ! NT surface tracers flux
```

This directory computes the normalization coefficients using the
**exact** method since this application has a small grid (**54x53x30**)
and creates the following files:

```
      wc13_nrm_i.nc             initial conditions
      wc13_nrm_m.nc             model error (weak constraint)
      wc13_nrm_b.nc             open boundary conditions
      wc13_nrm_f.nc             surface forcing (wind stress and net heat flux)
```

The normalization coefficients need to be computed only once
for a particular application provided that the grid, land/sea
masking (if any), and decorrelation scales (**HdecayI**, **VdecayI**,
**HdecayB**, **VdecayV**, and **HdecayF**) remain the same. Notice that
large spatial changes in the normalization coefficient
structure are observed near the open boundaries and land/sea
masking regions.

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
    (**K D<sub>u</sub> K<sup>T</sup>**) since the balanced operator is activated
    (**BALANCE_OPERATOR** and **ZETA_ELLIPTIC**).

  - The balance operator imposes a multivariate constraint on
    the error covariance such that the unobserved variable
    information is extracted from observed data by establishing
    balance relationships (*i.e.*, **T-S** empirical formulas,
    hydrostatic balance, and geostrophic balance) with other
    state variables (Weaver *et al.*, 2005).

  - These standard deviations `have already been created` for you:
    ```
      ../Data/wc13_std_m.nc     model error
      ../Data/wc13_std_i.nc     initial conditions
      ../Data/wc13_std_b.nc     open boundary conditions
      ../Data/wc13_std_f.nc     surface forcing (wind stress and net heat flux)
    ```

- The model error normalization coefficients are computed if
  **NADJ < NTIMES** in **roms_wc13.in**. In this application,
  **NADJ = 48** to force the computation of model error, **Q**,
  normalization coefficients.
  ```
      NTIMES == 192
      ...
        NADJ == 48      ! force to compute model error normalization factors
      ! NADJ == 192     ! avoid computing  model error normalization factors
  ```
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
      setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DNORMALIZATION"
  ```
  For this to work, however, any **#undef** directives **must** be
  avoided in the header file **wc13.h** since it has precedence
  during C-preprocessing.

- You **must** use any of the **build** scripts to compile.

- Customize the **ROMS** input script **roms_wc13.in** and specify
  the appropriate values for the distributed-memory tile partition.
  It is set by default to:
  ```
      NtileI == 1                               ! I-direction partition
      NtileJ == 8                               ! J-direction partition
  ```
  Notice that the adjoint-based algorithms can only be run
  in parallel using **MPI**.  This is because of the way that the
  adjoint model is constructed.

- Customize the configuration script **job_normalization.csh** and provide
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
- Execute the configuration **job_normalization.csh** `BEFORE`
  running the model.  It copies the required files and
  creates **c4dvar.in** input script from template **s4dvar.in**.

- Run **ROMS** data assimilation normalization:
  ```
      mpirun -np 8 romsM roms_wc13.in > & log &
  ```

- We recommend creating a new subdirectory **exact** or **random**,
  and saving the solution in it for analysis and plotting to avoid
  overwriting output files when playing with different CPP options
  and parameters. For example:
  ```
      mkdir exact
      mv Build_roms c4dvar.in *.nc log exact
      cp -p romsM roms_wc13.in exact
  ```
  The Normalization coefficients have already been computed for
  the **WC13** application using the exact method.

- Analyze the results using the plotting scripts (**ROMS** plotting
  package) provided in the **`../plotting`** directory:

  - **`ccnt_normalization_f.in`**:  plots error covariance normalization
                                    coefficients for surface forcing.

  - **`ccnt_normalization_i.in`**:  plots error covariance normalization
                                    coefficients for initial conditions
                                    at the surface or at **z=-100m**.

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
