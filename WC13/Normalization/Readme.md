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
   ADJUST_BOUNDARY       Including boundary conditions in 4D-Var state estimation
   ADJUST_STFLUX         Including surface tracer flux in 4D-Var state estimation
   ADJUST_WSTRESS        Including surface wind stress in 4D-Var state estimation
   DIRAC                 Background-error covariance spreading with Dirac delta functions
   MULTI_SCALE_B         Multi-scale background error covariance matrix modeling
   MULTI_SCALE_DEBUG     Multi-scale implicit solvers convergence reporting, fort.45
   NONUNIFORM_SCALES     Spatially-varying decorrelation length scales from the NetCDF file
   WC13                  Application CPP option
```

### Input NetCDF Files:
```
                       Grid File:  ../Data/wc13_grd.nc

     Initial Conditions STD File:  ../Data/wc13_std_i.nc
                  Model STD File:  ../Data/wc13_std_m.nc
    Boundary Conditions STD File:  ../Data/wc13_std_b.nc
        Surface Forcing STD File:  ../Data/wc13_std_f.nc

  Correlation Length Scales File:  ../Data/wc13_Bcorr_{xy, x, y}.nc
```

### Output NetCDF Files: (depends on configuration)
```
    Initial Conditions Norm File:  wc13_nrm_i.nc, wc13_nrm_monoscale_i.nc, wc13_nrm_{xy, x, y}_multiscale_i.nc
                 Model Norm File:  wc13_nrm_m.nc, wc13_nrm_monoscale_m.nc, wc13_nrm_{xy, x, y}_multiscale_m.nc
   Boundary Conditions Norm File:  wc13_nrm_b.nc, wc13_nrm_monoscale_b.nc, wc13_nrm_{xy, x, y}_multiscale_b.nc
       Surface Forcing Norm File:  wc13_nrm_f.nc, wc13_nrm_monoscale_f.nc, wc13_nrm_{xy, x, y}_multiscale_f.nc
       Dirac Tangent Linear File:  wc13_tlm.nc
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

Check the following parameters in the **4D-Var** input script **s4dvar.in**:
```
      Nmethod  == 0               ! normalization method (0: exact, 1:randomization)
      Nrandom  == 5000            ! randomization iterations

      LdefNRM == T F T T          ! Create a new normalization file(s)
      LwrtNRM == T F T T          ! Compute and write normalization

      CnormI(isFsur) =  T         ! 2D variable at RHO-points
      CnormI(isUbar) =  T         ! 2D variable at U-points
      CnormI(isVbar) =  T         ! 2D variable at V-points
      CnormI(isUvel) =  T         ! 3D variable at U-points
      CnormI(isVvel) =  T         ! 3D variable at V-points
      CnormI(isTvar) =  T T       ! NT tracers

      CnormB(isFsur) =  T          ! 2D variable at RHO-points
      CnormB(isUbar) =  T          ! 2D variable at U-points
      CnormB(isVbar) =  T          ! 2D variable at V-points
      CnormB(isUvel) =  T          ! 3D variable at U-points
      CnormB(isVvel) =  T          ! 3D variable at V-points
      CnormB(isTvar) =  T T        ! NT tracers

      CnormF(isUstr) =  T          ! surface U-momentum stress
      CnormF(isVstr) =  T          ! surface V-momentum stress
      CnormF(isTsur) =  T T        ! NT surface tracers flux

       Dirac(isFsur) == 25 20      ! free-surface (i,j)
       Dirac(isUbar) == 15 30      ! 2D U-momentum (i,j)
       Dirac(isVbar) == 15 35      ! 2D V-momentum (i,j)

       Dirac(isUvel) == 15 30 30   ! 3D U-momentum (i,j,k)
       Dirac(isVvel) == 15 35 30   ! 3D V-momentum (i,j,k)
       Dirac(isTvar) == 30 20 30 \ ! temperature (i,j,k)
                        20 40 30   ! salinity (i,j,k)

       Dirac(isTsur) == 20  15   \ ! surface heat flux (i,j)
                        25  20     ! surface salt flux (i,j)

       Dirac(isUstr) == 18  30     ! surface U-momentum stress (i,j)
       Dirac(isVstr) == 18  35     ! surface V-momentum stress (i,j)

              Nscale ==  1         ! number of B-multiscales
             NiterCG == 20         ! number of Lanczos CG solver iterations
             NiterCI == 20         ! number of Chebyshev Iterations (CI) steps
        Mlap(is....) == 10         ! number of implicit smoother applications

        Bwgt(is....) == 1.0d0      ! B-multiscales combination weights
```

If **NONUNIFORM_SCALES** is not enabled, you must specify the horizontal **isotropic** decorrelation scales **HdecayM**, **HdecayI**, and **HdecayF** (default monoscale case) in the **`s4dvar.in`** input script. If, in addition, **MULTI_SCALE_B** is enabled, **ROMS** will read the uniform **X**- and **Y**-direction decorrelation pairs (**HdecayMX**, **HdecayMY**), (**HdecayIX**, **HdecayIY**), and (**HdecayFX**, **HdecayFY**) from the **`s4dvar.in`** script for the multiscale case. When the **X**- and **Y**-direction scales differ, the resulting correlation shapes are **anisotropic**. Otherwise, they will be **isotropic**. The multiscale correlation concept does not apply to the unidirectional lateral boundary condition scales (**HdecayB**) in the control vector.

If **Nscale** is greater than **1**, you must specify distinct decorrelation scales in the **X**- and **Y**-directions for the cumulative multiscale **B**. This is necessary because broad structures and fine-scale features are combined in the data assimilation error hypothesis.

Because background-error correlations are treated as separable in the horizontal and vertical directions, you must always specify the vertical decorrelation scales **VdecayM**, **VdecayI**, and **VdecayB** in the **`s4dvar.in`** input script. The multiscale concept does not apply to the vertical pseudo-diffusion operators.

### Requirements

Before executing this driver, relevant circulation statistics, including the mean and standard deviation, $\boldsymbol{\Sigma}$, for all variables in the control vector (**zeta**, **u**, **v**, **T**, and **S**) must be determined. These statistical fields are extracted from **ROMS** long, nonlinear climatological solutions corresponding to the intended data-assimilation application grid. The standard deviations for the prior (initial conditions), model error (weak constraint formulation), surface forcing (**ADJUST_STFLUX** and **ADJUST_WSTRESS**), and lateral open boundary conditions (**ADJUST_BOUNDARY**) are read from separate input NetCDF files, as mentioned above.

If the **BALANCE_OPERATOR** is enabled, $\boldsymbol{K_b}$, the standard deviations are defined based on the unbalanced background-error covariance. The balance operator imposes a multivariate constraint on the background-error covariance, enabling the extraction of information about unobserved variables from observed data by establishing balance relationships, such as **T-S** empirical formulas, hydrostatic balance, and geostrophic balance, with other state variables (Weaver et al., 2005).

The following figures show the **WC13** standard deviation for free surface (m), surface temperature (Celsius), and surface salinity:

| Free Surface              | Surface Temperature      | Surface Salinity       |
:--------------------------:|:------------------------:|:-----------------------:
|<img width="400" alt="zeta+std" src="https://github.com/user-attachments/assets/928b52e9-26f7-41e4-83ff-c2a9f4ff4aab"> | <img width="400" alt="temp_std" src="https://github.com/user-attachments/assets/c28665e9-62cd-49eb-80bb-a95369bb1baa"> | <img width="400" alt="salt_std" src="https://github.com/user-attachments/assets/a3c42ac2-c40a-406e-ae9b-a424c9b40530"> |


### How to Run this Application:





---

### References:

Moore, A.M., H.G. Arango, G. Broquet, B.S. Powell, A.T. Weaver, and J. Zavala-Garay, **2011**: The Regional Ocean Modeling System (ROMS)  4-dimensional variational data assimilation systems, Part I - System overview and formulation, *Prog. Oceanogr.*, **91**, 34-49, [doi:10.1016/j.pocean.2011.05.004](https://doi.org/10.1016/j.pocean.2011.05.004).

Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani, B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson, **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional variational data assimilations systems, Part II - Performance and application to the California Current System, *Prog.Oceanogr.*, **91**, 50-73,
  [doi:10.1016/j.pocean.2011.05.003](https://doi.org/10.1016/j.pocean.2011.05.003).

Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani, B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson, **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional variational data assimilations systems, Part III - Observation impact and observation sensitivity in the California Current System, *Prog. Oceanogr.*, **91**, 74-94, [doi:10.1016/j.pocean.2011.05.005](https://doi.org/10.1016/j.pocean.2011.05.005).
  
Weaver, A.T. and I. Mirouze, **2013**: On the diffusion equation and its application to isotropic and anisotropic correlation modeling in variational assimilation, _Q. J. R. Meteorol. Soc._, **139,** 242-260, [doi:10.1002/qj.1955](https://doi.org/10.1002/qj.1955).

Weaver, A.T., Tshimanga, J., and A. Piacentini, **2016**: Correlation operators based on an implicitly formulated diffusion equation solved with the Chebyshev iteration, _Q. J. R. Meteorol. Soc._, **142**, 455-471, [doi: 10.1002/qj.2664](https://doi.org/10.1002/qj.2664).

