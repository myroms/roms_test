<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Tutorial: B-Normalization Factors and Correlation Dirac Testing

**Information**:  www.myroms.org/wiki/4DVar_Tutorial_Introduction

**Results**:      www.myroms.org/wiki/4DVar_Normalization_Tutorial

This directory generates various files needed to model the spreading of the background-error covariance matrix (**B**) in 4-dimensional data assimilation applications for the California Current System at 1/3-degree resolution ( :earth_americas: **WC13**). It also tests the associated error hypothesis for **B** using Dirac delta functions, with the specified correlation functions for each variable in the control vector.

Users can apply these instructions to model the background-error covariance in their applications. This is the first step in configuring a **ROMS 4D-Var** application. The algorithms used are complex. Several literature references are provided, and users are encouraged to review them to better understand the main objectives of this driver.

In **ROMS**, the **B** matrix is factorized according to Weaver and Courtier (2001) as follows:

$$ \boldsymbol{B = K_{b} \Sigma C \Sigma{^T} {K_{b}}^{T}} $$

Here, $\boldsymbol{K_b}$ represents the balanced components of the background error, $\boldsymbol{\Sigma}$ denotes the diagonal matrix of standard deviations, and $\boldsymbol{C}$ is the correlation matrix. Spreading is commonly modeled using pseudo-diffusion operators in the spatial correlation space, as outlined by Weaver and Coutier (2001), Weaver and Mirouze (2013), and Weaver *et al.* (2016, 2018). In these models, the diffusion coefficient, $\kappa$, is proportional to the square of the correlation length scale:

$$ {\delta\eta\over\delta{s}} - \nabla(\kappa\nabla\eta) = 0$$


A square root factorization of the correlation matrix $\boldsymbol{C}$ is employed to maintain symmetry despite rounding errors,

$$ \boldsymbol{ C = \Lambda {\mathcal{L}^{1/2}} {W^{-1}} {\mathcal{L}^{T/2}} \Lambda } $$

In this context, $\boldsymbol{\Lambda}$ is a diagonal matrix of the normalization factors ensuring that $\boldsymbol{C}$ ranges $\pm 1$, $\boldsymbol{\mathcal{L}}$ represents the matrix obtained by solving the linearized diffusion operator, and $\boldsymbol{W}$ is a diagonal matrix corresponding to the grid cell area or volume.

The objective is to compute the $\boldsymbol{\Lambda}$ normalization coefficients, which remain invariant for a fixed application grid and specified correlation scales. It is **advisable** to compute these coefficients independently of the **4D-Var** application, as computational costs increase with grid size. The normalization coefficients may be determined using either an **exact** or an **approximate** method. The **exact** approach is computationally intensive, as $\boldsymbol{\Lambda}$ is obtained by perturbing each model grid cell with a delta function scaled by the area (for 2D factors) or volume (for 3D factors), followed by convolution with the square-root diffusion operators. The **approximate** method is more computationally efficient and employs the **randomization** technique described by Fisher and Courtier (1995). In this approach, the grid is initialized with random numbers drawn from a normal distribution with zero mean and unit variance. These values are then scaled by the inverse of the square root of the cell area (for 2D factors) or volume (for 3D factors) and convolved with the square-root diffusion operator over a specified number of iterations, denoted as **Nrandom**.

Within **ROMS**, the background error covariance matrix may be represented using either a multi-scale or a mono-scale approach. The multi-scale formulation expresses **B** as a linear combination of distinct spatial scales, allowing representation of both broad structures and fine-scale features and reducing scale aliasing in the data assimilation cost function (Weaver *et al.*, 2016). In contrast, the mono-scale formulation employs a single spatial scale. The multi-scale approach, as described by Weaver *et al.* (2016), employs an implicit horizontal pseudo-diffusion operator implemented via a Lanczos formulation of the Conjugate Gradient (**CG**) and Chebyshev Iteration (**CI**) solvers, whereas the mono-scale default method uses an explicit horizontal algorithm. The **CG** solver computes the Ritz extrema eigenvalues required by the **CI** algorithm, which remain invariant for a fixed application grid and a given value of $\kappa$, allowing these estimates to be precomputed and stored. The **CG** algorithm is initialized with random vectors when computing the normalization factors, $\boldsymbol{\Lambda}$, which are computationally intensive. Error correlations are assumed to be separable in the horizontal and vertical directions. The vertical diffusion operator is implicit in both approaches. The multi-scale algorithm is activated by selecting the **MULTI_SCALE_B** option.

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

- **Case 0:** Default isotropic and uniform correlation in both the **x**- and **y**-directions (parameters specified in **`s4dvar.in`**).
- **Case 1**: Isotropic correlation with a spatially varying Rossby radius in both the **x**- and **y**-directions, where the values are equal (correlation file: **`wc13_Bcorr_xy.nc`**).
- **Case 2**: Anisotropic correlation with a spatially varying Rossby radius in the **x**-direction and a constant value of **30** km in the **y**-direction (correlation file: **`wc13_Bcorr_x.nc`**).
- **Case 3**: Anisotropic correlation with a spatially varying Rossby radius in the **y**-direction and a constant value of **30** km in the **x**-direction (correlation file: **`wc13_Bcorr_y.nc`**).

The following figure shows a map of the first baroclinic Rossby radius, with a lower limit of **30** km imposed by grid resolution. The spatially varying Rossby radius functions as a horizontal correlation scale.

<p align="center">
  <img width=50% height=50% alt="temp_Bcorr_RR" src="https://github.com/user-attachments/assets/c72c774e-9b92-4fd7-ac24-ec342c3c9971" />
</p>

> [!IMPORTANT]  
> :globe_with_meridians: Users are responsible for generating the input spatially varying decorrelation scales NetCDF file. The metadata schema, provided as a **CDL** file, is available in [s4dvar_Bcorrelation.cdl](https://github.com/myroms/roms/blob/develop/Data/ROMS/CDL/s4dvar_Bcorrelation.cdl).

The following table shows the uniform values of the horizontal and vertical correlation scales specified in the input data assimilation **`s4dvar.in`** script. It also includes the number of implicit applications ($M$) of the inverse horizontal diffusion operator for the multiscale background-error covariance solver. For two-dimensional correlation functions in **ROMS**, $M$ must be **even** and greater than **two**, due to square-root convolutions that iterate for only half $M$ steps in the tangent linear $\boldsymbol{\mathcal{L}^{1/2}}$ and adjoint $\boldsymbol{\mathcal{L}^{T/2}}$ diffusion operators. For $M\geq 10$, the correlation function approaches a Gaussian (asymptotic limit) and matches the explicit solution of the diffusion equation, which is the current default model for **B** in **ROMS**.

| Control Variable     | Hdecay (km)      | Hdecay-X  (km)   |  Hdecay-Y (km)      |  Vdecay (m)    |  M (Mlab) |
:---------------------:|:----------------:|:----------------:|:-------------------:|:--------------:|:----------:
| zeta                 | 50               | 50               | 50                  | N/A            | 10        |
| u                    | 50               | 50               | 50                  | 30             | 10        |
| v                    | 50               | 50               | 50                  | 30             | 10        |
| temp                 | 50               | 50               | 50                  | 30             | 10        |
| salt                 | 50               | 50               | 50                  | 30             | 10        |
| sustr                | 100              | 100              | 100                 | N/A            | 10        |
| svstr                | 100              | 100              | 100                 | N/A            | 10        |
| stflux               | 100              | 100              | 100                 | N/A            | 10        |
| ssflux               | 100              | 100              | 100                 | N/A            | 10        |

### Important CPP Options:
```
   NORMALIZATION         4D-Var error covariance normalization factors
   ADJUST_BOUNDARY       Including boundary conditions in 4D-Var state estimation
   ADJUST_STFLUX         Including surface tracer flux in 4D-Var state estimation
   ADJUST_WSTRESS        Including surface wind stress in 4D-Var state estimation
   BALANCE_OPERATOR      Error covariance multivariate Balance Operator
   DIRAC                 Background-error covariance spreading with Dirac delta functions
   MULTI_SCALE_B         Multi-scale background error covariance matrix modeling
   MULTI_SCALE_DEBUG     Multi-scale implicit solvers convergence reporting, fort.45
   NONUNIFORM_SCALES     Spatially varying decorrelation length scales from the NetCDF file
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

If the **BALANCE_OPERATOR** is enabled, $\boldsymbol{K_b}$, the standard deviations are defined based on the unbalanced background-error covariance. The balance operator imposes a multivariate constraint on the background-error covariance, enabling the extraction of information about unobserved variables from observed data by establishing balance relationships, such as **T-S** empirical formulas, hydrostatic balance, and geostrophic balance, with other state variables (Weaver *et al.*, 2005).

The following figures show the **WC13** standard deviation for free surface (m), surface temperature (Celsius), and surface salinity:

| Free Surface              | Surface Temperature      | Surface Salinity       |
:--------------------------:|:------------------------:|:-----------------------:
|<a href="https://github.com/user-attachments/assets/928b52e9-26f7-41e4-83ff-c2a9f4ff4aab"><img width="400" alt="zeta_std" src="https://github.com/user-attachments/assets/928b52e9-26f7-41e4-83ff-c2a9f4ff4aab"></a> | <a href="https://github.com/user-attachments/assets/c28665e9-62cd-49eb-80bb-a95369bb1baa"><img width="400" alt="temp_std" src="https://github.com/user-attachments/assets/c28665e9-62cd-49eb-80bb-a95369bb1baa"></a> | <a href="https://github.com/user-attachments/assets/a3c42ac2-c40a-406e-ae9b-a424c9b40530"><img width="400" alt="salt_std" src="https://github.com/user-attachments/assets/a3c42ac2-c40a-406e-ae9b-a424c9b40530"></a> |

### How to Compile ROMS:

- To compile **ROMS** background-error covariance matrix normalization factors and Dirac testing driver, use:
  ``` d
    build_split.sh -j 10                          creates executable romsM using the standard NetCDF library
    build_split.sh -pio -j 10                     creates executable romsM using both the standard NetCDF and PIO libraries
  ```

 Please review the **build** script, as it includes **CPP** options that the user can enable or disable.

- Examine the provided **`job_normalization.csh`** configuration script to turn on the desired options and generate the **`c4dvar.in`** input script from its template **`s4dvar.in`**. Then, execute the script before running:
  
  ``` d
    ./job_normalization.csh
  ```
  I am getting the following report for my modified set of options:

  ``` d
  4D-Var Error Covariance Normalization Coefficients Configuration:

  Multi-scale configuration, multiscale = 1
  b_axis = 1
  SVCname = ../Data/wc13_Bcorr_xy.nc
  Spatially-varying correlation: x- and y-axis
  's4dvar_norm.in' -> 'c4dvar.in'
  ```

- To execute **ROMS**, use:
  
   ``` d
   mpirun -n 12 romsM roms_wc13.in > & nrm.log &
   ``` 

> [!IMPORTANT]  
> :dragon The **`Nmethod=0`** (exact normalization approach) driver requires significant computational resources. For large application grids, **`Nmethod=1`** (approximated randomization approach) is recommended. Typically, the **`LdefNRM`** and **`Cnorm*(is…)`** switches are adjusted, and multiple jobs are submitted to compute normalization factors for each variable in the control vector.
>
>* Initially, submit a job to generate the output files required for computing normalization factors for the free-surface, 2D u-momentum, and 2D v-momentum. Enable **`CnormI(isFsur)`**, **`CnormI(isUbar)`**, and **`CnormI(isVbar)`**, while disabling all other **`Cnorm*`** switches. This step produces the necessary NetCDF files for the prior, model, surface-forcing adjustment, and lateral boundary condition adjustments.
>* Subsequently, disable all **`LdefNRM`** switches.
>* Submit additional jobs as required for the remaining variables in the control vector by enabling the corresponding **`Cnorm*(is…)`** switch. Note that computation of the 3D variables in the control vector may require additional time.

---

### Results: B-Normalization Factors

The following maps display the normalization factors necessary to model the spread of the background-error covariance matrix for the data-assimilation control vector, which includes free surface, u-momentum, v-momentum, potential temperature, salinity, surface u-stress, surface v-stress, surface heat flux, and surface freshwater flux. For three-dimensional variables, only surface values are presented. The normalization factors are calculated using the **exact** method. Each table column provides alternative distribution options for the spatially varying correlation length scales, including the **default** isotropic uniform distribution used in **ROMS** since its inception.

The normalization factors for the forcing control variables **sustr**, **svstr**, **shflux**, and **ssflux** are isotropic and uniformly distributed. These factors are included to demonstrate that the new multiscale implicit algorithms yield a distribution comparable to that produced by the explicit **default** pseudo-diffusion operators.

| Case 0               | Case 1           | Case 2           |  Case 3            |
:---------------------:|:----------------:|:----------------:|:-------------------:
|<a href="https://github.com/user-attachments/assets/1dbe157e-bea0-47e2-8c41-eb7d46869fbe"><img width="400" alt="zeta_mono" src="https://github.com/user-attachments/assets/1dbe157e-bea0-47e2-8c41-eb7d46869fbe" ></a> | <a href="https://github.com/user-attachments/assets/1bd59987-285e-47de-bf23-f8c952053930"><img width="400" alt="zeta_xy_multi" src="https://github.com/user-attachments/assets/1bd59987-285e-47de-bf23-f8c952053930" ></a> | <a href="https://github.com/user-attachments/assets/cfd19f2e-ecd3-40f0-a89e-60bc2fd3ba39"><img width="400" alt="zeta_x_multi" src="https://github.com/user-attachments/assets/cfd19f2e-ecd3-40f0-a89e-60bc2fd3ba39" ></a> | <a href="https://github.com/user-attachments/assets/6af3b9aa-f833-402c-b335-59cd85cf7df5"><img width="400" alt="zeta_y_multi" src="https://github.com/user-attachments/assets/6af3b9aa-f833-402c-b335-59cd85cf7df5" ></a> |
|<a href="https://github.com/user-attachments/assets/98927754-b888-4855-9bba-55a0db5e427a"><img width="400" alt="u_mono" src="https://github.com/user-attachments/assets/98927754-b888-4855-9bba-55a0db5e427a" ></a> | <a href="https://github.com/user-attachments/assets/d69274bb-8a16-43e7-a73a-4418e56aa727"><img width="400" alt="u_xy_multi" src="https://github.com/user-attachments/assets/d69274bb-8a16-43e7-a73a-4418e56aa727" ></a> | <a href="https://github.com/user-attachments/assets/33b1d6ce-8a1c-4869-addd-178500c8704c"><img width="400" alt="u_x_multi" src="https://github.com/user-attachments/assets/33b1d6ce-8a1c-4869-addd-178500c8704c" ></a> | <a href="https://github.com/user-attachments/assets/724cbe8f-5ae8-4f42-828f-1b9a466a997b"><img width="400" alt="u_y_multi" src="https://github.com/user-attachments/assets/724cbe8f-5ae8-4f42-828f-1b9a466a997b" ></a> |
|<a href="https://github.com/user-attachments/assets/d08f3ac7-2433-406a-844e-a8b3b1bee806"><img width="400" alt="v_mono" src="https://github.com/user-attachments/assets/d08f3ac7-2433-406a-844e-a8b3b1bee806" ></a> | <a href="https://github.com/user-attachments/assets/8657d517-da62-46f5-943a-5e7f4285ebb9"><img width="400" alt="v_xy_multi" src="https://github.com/user-attachments/assets/8657d517-da62-46f5-943a-5e7f4285ebb9" ></a> | <a href="https://github.com/user-attachments/assets/87ca41e0-6ca8-406a-a77d-90a5097647e2"><img width="400" alt="v_x_multi" src="https://github.com/user-attachments/assets/87ca41e0-6ca8-406a-a77d-90a5097647e2" ></a> | <a href="https://github.com/user-attachments/assets/c511d340-6909-4d0f-a7bb-2c940f155db4"><img width="400" alt="v_y_multi" src="https://github.com/user-attachments/assets/c511d340-6909-4d0f-a7bb-2c940f155db4" ></a> |
|<a href="https://github.com/user-attachments/assets/26be5485-6876-4d77-ae44-fc5553bf5afc"><img width="400" alt="temp_mono" src="https://github.com/user-attachments/assets/26be5485-6876-4d77-ae44-fc5553bf5afc" ></a> | <a href="https://github.com/user-attachments/assets/26c57bbe-5d70-405f-9d59-63ba0569ac48"><img width="400" alt="temp_xy_multi" src="https://github.com/user-attachments/assets/26c57bbe-5d70-405f-9d59-63ba0569ac48" ></a> | <a href="https://github.com/user-attachments/assets/aa4beacb-4ca5-4a14-8ce1-5af716a47fcb"><img width="400" alt="temp_x_multi" src="https://github.com/user-attachments/assets/aa4beacb-4ca5-4a14-8ce1-5af716a47fcb" ></a> | <a href="https://github.com/user-attachments/assets/540820eb-9323-41fe-b46c-7dac98184368"><img width="400" alt="temp_y_multi" src="https://github.com/user-attachments/assets/540820eb-9323-41fe-b46c-7dac98184368" ></a> |
|<a href="https://github.com/user-attachments/assets/7fbd1530-1b71-4092-bcfe-958b95cf5c25"><img width="400" alt="salt_mono" src="https://github.com/user-attachments/assets/7fbd1530-1b71-4092-bcfe-958b95cf5c25" ></a> | <a href="https://github.com/user-attachments/assets/1871a7dd-9148-4813-b63d-d826cba40d4f"><img width="400" alt="salt_xy_multi" src="https://github.com/user-attachments/assets/1871a7dd-9148-4813-b63d-d826cba40d4f" ></a> | <a href="https://github.com/user-attachments/assets/40648e7e-143a-41b5-9f9a-44f71e02b358"><img width="400" alt="salt_x_multi" src="https://github.com/user-attachments/assets/40648e7e-143a-41b5-9f9a-44f71e02b358" ></a> | <a href="https://github.com/user-attachments/assets/596850ca-0806-4623-93b7-365bff8cd57b"><img width="400" lt="salt_y_multi" src="https://github.com/user-attachments/assets/596850ca-0806-4623-93b7-365bff8cd57b" ></a> |
|<a href="https://github.com/user-attachments/assets/f329eb3a-a9ff-481d-84a5-cd58151647d5"><img width="400" alt="sustr_mono" src="https://github.com/user-attachments/assets/f329eb3a-a9ff-481d-84a5-cd58151647d5" ></a> | <a href="https://github.com/user-attachments/assets/d77868ac-b90f-439a-be46-7ed85e757e99"><img width="400" alt="sustr_xy_multi" src="https://github.com/user-attachments/assets/d77868ac-b90f-439a-be46-7ed85e757e99" ></a> | <a href="https://github.com/user-attachments/assets/fb177dd4-04be-4634-954a-ab2312c4d466"><img width="400" alt="sustr_x_multi" src="https://github.com/user-attachments/assets/fb177dd4-04be-4634-954a-ab2312c4d466" ></a> | <a href="https://github.com/user-attachments/assets/0fdc8a94-5c53-4f25-88b0-cd75fcf14393"><img width="400" alt="sustr_y_multi" src="https://github.com/user-attachments/assets/0fdc8a94-5c53-4f25-88b0-cd75fcf14393" ></a> |
|<a href="https://github.com/user-attachments/assets/c68a2081-2582-42bd-8dfe-291887e83840"><img width="400" alt="svstr_mono" src="https://github.com/user-attachments/assets/c68a2081-2582-42bd-8dfe-291887e83840" ></a> | <a href="https://github.com/user-attachments/assets/dd0122f6-2c21-4ce3-b51a-3a3cbb8390b8"><img width="400" alt="svstr_xy_multi" src="https://github.com/user-attachments/assets/dd0122f6-2c21-4ce3-b51a-3a3cbb8390b8" ></a> | <a href="https://github.com/user-attachments/assets/0b41ff1f-01f8-4c82-9139-240ee7c72a0d"><img width="400" alt="svstr_x_multi" src="https://github.com/user-attachments/assets/0b41ff1f-01f8-4c82-9139-240ee7c72a0d" ></a> | <a href="https://github.com/user-attachments/assets/f94cc20f-7d86-449a-a787-6d73c162c40f"><img width="400" alt="svstr_y_multi" src="https://github.com/user-attachments/assets/f94cc20f-7d86-449a-a787-6d73c162c40f" ></a> |
|<a href="https://github.com/user-attachments/assets/f5c1aeed-0a7b-4004-a8c6-aad8a0c56977"><img width="400" alt="shflux_mono" src="https://github.com/user-attachments/assets/f5c1aeed-0a7b-4004-a8c6-aad8a0c56977" ></a> | <a href="https://github.com/user-attachments/assets/c64a97bc-6536-4b2e-817d-9fb7e28a4d5e"><img width="400" alt="shflux_xy_multi" src="https://github.com/user-attachments/assets/c64a97bc-6536-4b2e-817d-9fb7e28a4d5e" ></a> | <a href="https://github.com/user-attachments/assets/4b14b6d9-56cc-4707-abb7-a5153b3c5e6c"><img width="400" alt="shflux_x_multi" src="https://github.com/user-attachments/assets/4b14b6d9-56cc-4707-abb7-a5153b3c5e6c" ></a> | <a href="https://github.com/user-attachments/assets/9e128cdf-8884-47e8-a006-213cec4a1f93"><img width="400" alt="shflux_y_multi" src="https://github.com/user-attachments/assets/9e128cdf-8884-47e8-a006-213cec4a1f93" ></a> |
|<a href="https://github.com/user-attachments/assets/6af3778e-7cb0-4414-b50b-5e866ede3db9"><img width="400" alt="ssflux_mono" src="https://github.com/user-attachments/assets/6af3778e-7cb0-4414-b50b-5e866ede3db9" ></a> | <a href="https://github.com/user-attachments/assets/3156490d-38ca-4ae7-b354-9aa1ed1ca3aa"><img width="400" alt="ssflux_xy_multi" src="https://github.com/user-attachments/assets/3156490d-38ca-4ae7-b354-9aa1ed1ca3aa" ></a> | <a href="https://github.com/user-attachments/assets/ee700642-a2dd-45e1-8c65-557711bdf9b9"><img width="400" alt="ssflux_x_multi" src="https://github.com/user-attachments/assets/ee700642-a2dd-45e1-8c65-557711bdf9b9" ></a> | <a href="https://github.com/user-attachments/assets/1f288379-aea5-4868-a6fd-24cc32905f51"><img width="400" alt="ssflux_y_multi" src="https://github.com/user-attachments/assets/1f288379-aea5-4868-a6fd-24cc32905f51" ></a> |


---

### Results: Correlation Dirac Testing

Evaluating the Dirac delta function results for each control vector variable facilitates assessment of the correlation parameters that model the effects of the background-error covariance matrix. The location of each delta function indicates how a specific observation influences the geometry of adjacent grid points and the associated dynamic features at that site during state estimation. Assuming that error correlations are separable in the horizontal and vertical directions, plotting horizontal and cross-sectional profiles is necessary to assess the spatial extent of influence under the specified hypothesis of data-assimilation error. This separability assumption poses substantial challenges for data assimilation and often requires extensive fine-tuning.

The following horizontal maps depict the influence of the background-error covariance matrix at hypothetical observation sites for each data-assimilation control-vector variable: free surface, u-momentum, v-momentum, potential temperature, salinity, surface u-stress, surface v-stress, surface heat flux, and surface freshwater flux. For variables defined in three dimensions, only surface maps are shown.


| Case 0               | Case 1           | Case 2           |  Case 3            |
:---------------------:|:----------------:|:----------------:|:-------------------:
|<a href="https://github.com/user-attachments/assets/fa1cba03-8ba6-49c6-9f2f-c2042e3eab30"><img width="400" alt="zeta_mono_dirac" src="https://github.com/user-attachments/assets/fa1cba03-8ba6-49c6-9f2f-c2042e3eab30" ></a> | <a href="https://github.com/user-attachments/assets/b16936b5-626c-4e6d-a205-45570a655dcb"><img width="400" alt="zeta_xy_dirac" src="https://github.com/user-attachments/assets/b16936b5-626c-4e6d-a205-45570a655dcb" ></a> | <a href="https://github.com/user-attachments/assets/f64b2019-48aa-4a3e-9ea0-e876dc5f3126"><img width="400" alt="zeta_x_dirac" src="https://github.com/user-attachments/assets/f64b2019-48aa-4a3e-9ea0-e876dc5f3126" ></a> | <a href="https://github.com/user-attachments/assets/0e30f6dd-ef03-497b-9bee-5da5bcaaebcb"><img width="400" alt="zeta_y_dirac" src="https://github.com/user-attachments/assets/0e30f6dd-ef03-497b-9bee-5da5bcaaebcb" ></a> |
|<a href="https://github.com/user-attachments/assets/6be36465-1b5f-4657-b747-e62514dd467b"><img width="400" alt="u_mono_dirac" src="https://github.com/user-attachments/assets/6be36465-1b5f-4657-b747-e62514dd467b" ></a> | <a href="https://github.com/user-attachments/assets/53e94791-3e7c-4bb2-93df-ea45d0c6edad"><img width="400" alt="u_xy_dirac" src="https://github.com/user-attachments/assets/53e94791-3e7c-4bb2-93df-ea45d0c6edad" ></a> | <a href="https://github.com/user-attachments/assets/58524db2-49a0-453b-9f47-d782919ccdbd"><img width="400" alt="u_x_dirac" src="https://github.com/user-attachments/assets/58524db2-49a0-453b-9f47-d782919ccdbd" ></a> | <a href="https://github.com/user-attachments/assets/da23251d-2817-407e-9c67-299eff82885a"><img width="400" alt="u_y_dirac" src="https://github.com/user-attachments/assets/da23251d-2817-407e-9c67-299eff82885a" ></a> |
|<a href="https://github.com/user-attachments/assets/4a3b37f8-a3c3-4354-a7f6-1adde327fa72"><img width="400" alt="v_mono_dirac" src="https://github.com/user-attachments/assets/4a3b37f8-a3c3-4354-a7f6-1adde327fa72" ></a> | <a href="https://github.com/user-attachments/assets/2e100290-fbb9-4dd9-9fba-874ba2541e5e"><img width="400" alt="v_xy_dirac" src="https://github.com/user-attachments/assets/2e100290-fbb9-4dd9-9fba-874ba2541e5e" ></a> | <a href="https://github.com/user-attachments/assets/757c678a-e481-4f9b-a292-ba97587d7351"><img width="400" alt="v_x_dirac" src="https://github.com/user-attachments/assets/757c678a-e481-4f9b-a292-ba97587d7351" ></a> | <a href="https://github.com/user-attachments/assets/b75c3e92-7817-4961-ba1a-92ac80fe5645"><img width="400" alt="v_y_dirac" src="https://github.com/user-attachments/assets/b75c3e92-7817-4961-ba1a-92ac80fe5645" ></a> |
|<a href="https://github.com/user-attachments/assets/cbf24732-1a32-4e95-bb12-889ca290397a"><img width="400" alt="temp_mono_dirac" src="https://github.com/user-attachments/assets/cbf24732-1a32-4e95-bb12-889ca290397a" ></a> | <a href="https://github.com/user-attachments/assets/3f5a62d5-5bd3-47ad-871e-7a3b37240e10"><img width="400" alt="temp_xy_dirac" src="https://github.com/user-attachments/assets/3f5a62d5-5bd3-47ad-871e-7a3b37240e10" ></a> | <a href="https://github.com/user-attachments/assets/a3ffc57e-d506-48f5-8339-1345d0827e99"><img width="400" alt="temp_x_dirac" src="https://github.com/user-attachments/assets/a3ffc57e-d506-48f5-8339-1345d0827e99" ></a> | <a href="https://github.com/user-attachments/assets/682abb90-5a60-488f-9f27-203c62e97b88"><img width="400" alt="temp_y_dirac" src="https://github.com/user-attachments/assets/682abb90-5a60-488f-9f27-203c62e97b88" ></a> |
|<a href="https://github.com/user-attachments/assets/23729218-a546-40e4-83e2-a4f058e743bb"><img width="400" alt="salt_mono_dirac" src="https://github.com/user-attachments/assets/23729218-a546-40e4-83e2-a4f058e743bb" ></a> | <a href="https://github.com/user-attachments/assets/d5e6cece-5978-4d47-9279-5f55bbdeeb06"><img width="400" alt="salt_xy_dirac" src="https://github.com/user-attachments/assets/d5e6cece-5978-4d47-9279-5f55bbdeeb06" ></a> | <a href="https://github.com/user-attachments/assets/71c9337c-5ab3-4f20-b420-6df569105665"><img width="400" alt="salt_x_dirac" src="https://github.com/user-attachments/assets/71c9337c-5ab3-4f20-b420-6df569105665" ></a> | <a href="https://github.com/user-attachments/assets/0b59f8b1-df21-4091-91e4-dcccfcf18f74"><img width="400" alt="salt_y_dirac" src="https://github.com/user-attachments/assets/0b59f8b1-df21-4091-91e4-dcccfcf18f74" ></a> |
|<a href="https://github.com/user-attachments/assets/0e5da390-eb44-4f1c-87b9-9d9e8a268d6f"><img width="400" alt="sustr_mono_dirac" src="https://github.com/user-attachments/assets/0e5da390-eb44-4f1c-87b9-9d9e8a268d6f" ></a> | <a href="https://github.com/user-attachments/assets/e602420f-62ed-4757-ae3d-bff5b9b2f1e9"><img width="400" alt="sustr_xy_dirac" src="https://github.com/user-attachments/assets/e602420f-62ed-4757-ae3d-bff5b9b2f1e9" ></a> | <a href="https://github.com/user-attachments/assets/b4e4c9d9-b160-4285-a3ca-74c362951636"><img width="400" alt="sustr_x_dirac" src="https://github.com/user-attachments/assets/b4e4c9d9-b160-4285-a3ca-74c362951636" ></a> | <a href="https://github.com/user-attachments/assets/11b34fa3-0e10-41a1-b8d9-2a3af86297cb"><img width="400" alt="sustr_y_dirac" src="https://github.com/user-attachments/assets/11b34fa3-0e10-41a1-b8d9-2a3af86297cb" ></a> |
|<a href="https://github.com/user-attachments/assets/b6298581-9c31-43f3-a518-340cd277def0"><img width="400" alt="svstr_mono_dirac" src="https://github.com/user-attachments/assets/b6298581-9c31-43f3-a518-340cd277def0" ></a> | <a href="https://github.com/user-attachments/assets/bd4ce534-e062-4277-a84e-22d95bce9aa6"><img width="400" alt="svstr_xy_dirac" src="https://github.com/user-attachments/assets/bd4ce534-e062-4277-a84e-22d95bce9aa6" ></a> | <a href="https://github.com/user-attachments/assets/9ae4f12a-9a8e-4b95-a59c-8e99cac59da0"><img width="400" alt="svstr_x_dirac" src="https://github.com/user-attachments/assets/9ae4f12a-9a8e-4b95-a59c-8e99cac59da0" ></a> | <a href="https://github.com/user-attachments/assets/f242969d-361c-4171-b4d3-ac1a67b0a345"><img width="400" alt="svstr_y_dirac" src="https://github.com/user-attachments/assets/f242969d-361c-4171-b4d3-ac1a67b0a345" ></a> |
|<a href="https://github.com/user-attachments/assets/2b9acb96-b915-4f7c-932b-0fd9254e20eb"><img width="400" alt="shflux_mono_dirac" src="https://github.com/user-attachments/assets/2b9acb96-b915-4f7c-932b-0fd9254e20eb" ></a> | <a href="https://github.com/user-attachments/assets/0adea52d-3cb8-467b-91d2-c74efdb778ea"><img width="400" alt="shflux_xy_dirac" src="https://github.com/user-attachments/assets/0adea52d-3cb8-467b-91d2-c74efdb778ea" ></a> | <a href="https://github.com/user-attachments/assets/c77797e9-5331-4737-b94e-97e131a48dbc"><img width="400" alt="shflux_x_dirac" src="https://github.com/user-attachments/assets/c77797e9-5331-4737-b94e-97e131a48dbc" ></a> | <a href="https://github.com/user-attachments/assets/89e2b730-6bf5-4fa6-8d10-4128e2f5e4ef"><img width="400" alt="shflux_y_dirac" src="https://github.com/user-attachments/assets/89e2b730-6bf5-4fa6-8d10-4128e2f5e4ef" ></a> |
|<a href="https://github.com/user-attachments/assets/a54b1914-947b-4969-af2b-d190f0ea7045"><img width="400" alt="ssflux_mono_dirac" src="https://github.com/user-attachments/assets/a54b1914-947b-4969-af2b-d190f0ea7045" ></a> | <a href="https://github.com/user-attachments/assets/4d9e9fae-d695-4af5-97d1-87d436988684"><img width="400" alt="ssflux_xy_dirac" src="https://github.com/user-attachments/assets/4d9e9fae-d695-4af5-97d1-87d436988684" ></a> | <a href="https://github.com/user-attachments/assets/e2652173-18ab-4957-a50f-05663893efd6"><img width="400" alt="ssflux_x_dirac" src="https://github.com/user-attachments/assets/e2652173-18ab-4957-a50f-05663893efd6" ></a> | <a href="https://github.com/user-attachments/assets/bbf368bc-8d45-4a4b-bc3f-c10f57761d68"><img width="400" alt="ssflux_y_dirac" src="https://github.com/user-attachments/assets/bbf368bc-8d45-4a4b-bc3f-c10f57761d68" ></a> |

The following cross-sections show the vertical extent of influence for observations at the surface:

| Default              | Case 1           | Case 2           |  Case 3            |
:---------------------:|:----------------:|:----------------:|:-------------------:
|<a href="https://github.com/user-attachments/assets/1de92f32-f99a-4052-993c-b4a2b71737e6"><img width="400" alt="u_sec_mono_dirac" src="https://github.com/user-attachments/assets/1de92f32-f99a-4052-993c-b4a2b71737e6" ></a> | <a href="https://github.com/user-attachments/assets/02a3d440-83a3-4e5f-ad74-e1078daf832a"><img width="400" alt="u_sec_xy_dirac" src="https://github.com/user-attachments/assets/02a3d440-83a3-4e5f-ad74-e1078daf832a" ></a> | <a href="https://github.com/user-attachments/assets/a5b65762-8ab0-4ab4-8a62-069e2ba0a530"><img width="400" alt="u_sec_x_dirac" src="https://github.com/user-attachments/assets/a5b65762-8ab0-4ab4-8a62-069e2ba0a530" ></a> | <a href="https://github.com/user-attachments/assets/dd2fa5c4-f6e4-486f-9a04-fe453e49b00a"><img width="400" alt="u_sec_y_dirac" src="https://github.com/user-attachments/assets/dd2fa5c4-f6e4-486f-9a04-fe453e49b00a" ></a> |
|<a href="https://github.com/user-attachments/assets/7b59956e-77c5-4ca3-9bd8-aaddcf903100"><img width="400" alt="v_sec_mono_dirac" src="https://github.com/user-attachments/assets/7b59956e-77c5-4ca3-9bd8-aaddcf903100" ></a> | <a href="https://github.com/user-attachments/assets/96a94810-0ba3-4e15-8a4c-aef88925bb8a"><img width="400" alt="v_sec_xy_dirac" src="https://github.com/user-attachments/assets/96a94810-0ba3-4e15-8a4c-aef88925bb8a" ></a> | <a href="https://github.com/user-attachments/assets/be94eb39-2e2d-47b4-9622-c1c268f08b8b"><img width="400" alt="v_sec_x_dirac" src="https://github.com/user-attachments/assets/be94eb39-2e2d-47b4-9622-c1c268f08b8b" ></a> | <a href="https://github.com/user-attachments/assets/0e88a343-f3dd-4e96-83b7-117f5a6cd54a"><img width="400" alt="v_sec_y_dirac" src="https://github.com/user-attachments/assets/0e88a343-f3dd-4e96-83b7-117f5a6cd54a" ></a> |
|<a href="https://github.com/user-attachments/assets/cf7d353d-1c46-43dc-a85a-cfdc8848a396"><img width="400" alt="temp_sec_mono_dirac" src="https://github.com/user-attachments/assets/cf7d353d-1c46-43dc-a85a-cfdc8848a396" ></a> | <a href="https://github.com/user-attachments/assets/1e204a54-6f91-4254-baa1-eb4b3b48b7fb"><img width="400" alt="temp_sec_xy_dirac" src="https://github.com/user-attachments/assets/1e204a54-6f91-4254-baa1-eb4b3b48b7fb" ></a> | <a href="https://github.com/user-attachments/assets/1b97281f-d816-40e4-ade5-2ce486154a16"><img width="400" alt="temp_sec_x_dirac" src="https://github.com/user-attachments/assets/1b97281f-d816-40e4-ade5-2ce486154a16" ></a> | <a href="https://github.com/user-attachments/assets/169e6ec0-66a0-4637-a5c2-e7c38609da8a"><img width="400" alt="temp_sec_y_dirac" src="https://github.com/user-attachments/assets/169e6ec0-66a0-4637-a5c2-e7c38609da8a" ></a> |
|<a href="https://github.com/user-attachments/assets/44370bf2-b8c9-45ad-8852-0adc7049d36f"><img width="400" alt="salt_sec_mono_dirac" src="https://github.com/user-attachments/assets/44370bf2-b8c9-45ad-8852-0adc7049d36f" ></a> | <a href="https://github.com/user-attachments/assets/ff68140e-1ce4-45f8-ab45-e734f07e2739"><img width="400" alt="salt_sec_xy_dirac" src="https://github.com/user-attachments/assets/ff68140e-1ce4-45f8-ab45-e734f07e2739" ></a> | <a href="https://github.com/user-attachments/assets/e09dabad-cc9e-42bf-9e4c-ba39ece24e59"><img width="400" alt="salt_sec_x_dirac" src="https://github.com/user-attachments/assets/e09dabad-cc9e-42bf-9e4c-ba39ece24e59" ></a> | <a href="https://github.com/user-attachments/assets/44342c17-f1c8-41f5-a5be-e6c4284cfa2a"><img width="400" alt="salt_sec_y_dirac" src="https://github.com/user-attachments/assets/44342c17-f1c8-41f5-a5be-e6c4284cfa2a" ></a> |

---

### ROMS Standard Output:

**ROMS** provides detailed information in its standard output file, which is redirected to **`norm.log`**. Please review this file to confirm that the configuration is correct.

``` d
 GET_STATE_NF90   - STD: IC correlation standard deviation,
                      (Grid 01, t = 13008.0000, File: wc13_std_i.nc, Rec=0001, Index=1)
                   - free-surface
                      (Min =  0.00000000E+00 Max =  8.78295600E-02)
                   - vertically integrated u-momentum component
                      (Min =  0.00000000E+00 Max =  0.00000000E+00)
                   - vertically integrated v-momentum component
                      (Min =  0.00000000E+00 Max =  0.00000000E+00)
                   - u-momentum component
                      (Min =  0.00000000E+00 Max =  2.83949524E-01)
                   - v-momentum component
                      (Min =  0.00000000E+00 Max =  5.92493832E-01)
                   - potential temperature
                      (Min =  0.00000000E+00 Max =  1.42421246E+00)
                   - salinity
                      (Min =  0.00000000E+00 Max =  7.37198234E-01)

  GET_STATE_NF90   - STD: OBC correlation standard deviation,
                      (Grid 01, t = 13008.0000, File: wc13_std_b.nc, Rec=0001, Index=1)
                   - zeta_obc
                      (Min =  0.00000000E+00 Max =  3.46887300E-02)
                   - ubar_obc
                      (Min =  0.00000000E+00 Max =  7.33580182E-03)
                   - vbar_obc
                      (Min =  0.00000000E+00 Max =  1.58224189E-02)
                   - u_obc
                      (Min =  0.00000000E+00 Max =  3.36119906E-02)
                   - v_obc
                      (Min =  0.00000000E+00 Max =  4.96306742E-02)
                   - temp_obc
                      (Min =  0.00000000E+00 Max =  1.18352115E+00)
                   - salt_obc
                      (Min =  0.00000000E+00 Max =  1.34063814E-01)

  GET_STATE_NF90   - STD: surface forcing correlation standard deviation,
                      (Grid 01, t = 13008.0000, File: wc13_std_f.nc, Rec=0001, Index=1)
                   - surface u-momentum stress
                      (Min =  0.00000000E+00 Max =  1.14277172E-04)
                   - surface v-momentum stress
                      (Min =  0.00000000E+00 Max =  1.54091192E-04)
                   - surface net heat flux
                      (Min =  0.00000000E+00 Max =  2.33505487E-05)
                   - kinematic surface net salt flux, SALT (E-P)/rhow
                      (Min =  0.00000000E+00 Max =  5.25535461E-06)

 MULTISCALE_GET_SCALES - SVC: Reading horizontal correlation length scales file:
                          (Grid 01, File: ../Data/wc13_Bcorr_xy.nc)
                       - free-surface horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - u-barotropic horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - u-barotropic horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - u-velocity horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - v-velocity horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - potential temperature horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - salinity horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  3.00000000E+04, Xmax =  6.39802453E+04
                                        Ymin =  3.00000000E+04, Ymax =  6.39802453E+04)
                       - surface u-stress horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  1.00000000E+05, Xmax =  1.00000000E+05
                                        Ymin =  1.00000000E+05, Ymax =  1.00000000E+05)
                       - surface v-stress horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  1.00000000E+05, Xmax =  1.00000000E+05
                                        Ymin =  1.00000000E+05, Ymax =  1.00000000E+05)
                       - surface heat flux horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  1.00000000E+05, Xmax =  1.00000000E+05
                                        Ymin =  1.00000000E+05, Ymax =  1.00000000E+05)
                       - surface salt flux horizontal background-error decorrelation length scales
                          (Bscale = 01, Xmin =  1.00000000E+05, Xmax =  1.00000000E+05
                                        Ymin =  1.00000000E+05, Ymax =  1.00000000E+05)

  DEF_NORM_NF90    - Creating prior B-normalization file:       ../Data/wc13_nrm_xy_multiscale_i.nc
  DEF_NORM_NF90    - Creating boundary B-normalization file:    ../Data/wc13_nrm_xy_multiscale_b.nc
  DEF_NORM_NF90    - Creating forcing B-normalization file:     ../Data/wc13_nrm_xy_multiscale_f.nc

 Ritz Extrema Eigenvalues Required by Implicit Chebyshev Iterations (CI) Solver:

    B-scale = 01, computing eigenspectrum for: zeta
    B-scale = 01, computing eigenspectrum for: ubar
    B-scale = 01, computing eigenspectrum for: vbar
    B-scale = 01, computing eigenspectrum for: u
    B-scale = 01, computing eigenspectrum for: v
    B-scale = 01, computing eigenspectrum for: temp
    B-scale = 01, computing eigenspectrum for: salt
    B-scale = 01, computing eigenspectrum for: zeta lateral boundaries
    B-scale = 01, computing eigenspectrum for: ubar lateral boundaries
    B-scale = 01, computing eigenspectrum for: vbar lateral boundaries
    B-scale = 01, computing eigenspectrum for: u lateral boundaries
    B-scale = 01, computing eigenspectrum for: v lateral boundaries
    B-scale = 01, computing eigenspectrum for: temp lateral boundaries
    B-scale = 01, computing eigenspectrum for: salt lateral boundaries
    B-scale = 01, computing eigenspectrum for: sustr
    B-scale = 01, computing eigenspectrum for: svstr
    B-scale = 01, computing eigenspectrum for: shflux
    B-scale = 01, computing eigenspectrum for: ssflux

 Writing extrema Ritz eigenvalues into prior B-normalization file:  ../Data/wc13_nrm_xy_multiscale_i.nc
   (Required by Implicit Chebyshev Iterations, CI, Solver)

    - zeta_eigen:                 Min =  1.00278458E+00,  Max =  2.76295931E+00
    - ubar_eigen:                 Min =  1.00399850E+00,  Max =  2.76359758E+00
    - vbar_eigen:                 Min =  1.00117970E+00,  Max =  2.77166712E+00
    - u_eigen:                    Min =  1.00137687E+00,  Max =  2.76375612E+00
    - v_eigen:                    Min =  1.00120604E+00,  Max =  2.77175571E+00
    - temp_eigen:                 Min =  1.00120847E+00,  Max =  2.76331804E+00
    - salt_eigen:                 Min =  1.00120847E+00,  Max =  2.76331804E+00

 Writing extrema Ritz eigenvalues into boundary B-normalization file:  ../Data/wc13_nrm_xy_multiscale_b.nc
   (Required by Implicit Chebyshev Iterations, CI, Solver)

    - zeta_obc_eigen:             Min =  1.00000603E+00,  Max =  4.81657448E+00
    - ubar_obc_eigen:             Min =  1.00102758E+00,  Max =  4.82034194E+00
    - vbar_obc_eigen:             Min =  1.00029446E+00,  Max =  4.79296753E+00
    - u_obc_eigen:                Min =  1.00000527E+00,  Max =  4.82474216E+00
    - v_obc_eigen:                Min =  9.99934866E-01,  Max =  4.79310342E+00
    - temp_obc_eigen:             Min =  1.00000018E+00,  Max =  4.81660071E+00
    - salt_obc_eigen:             Min =  9.99900892E-01,  Max =  4.81659553E+00

 Writing extrema Ritz eigenvalues into forcing B-normalization file:  ../Data/wc13_nrm_xy_multiscale_f.nc
   (Required by Implicit Chebyshev Iterations, CI, Solver)

    - sustr_eigen:                Min =  1.00894429E+00,  Max =  6.76156599E+00
    - svstr_eigen:                Min =  1.00619420E+00,  Max =  6.98312118E+00
    - shflux_eigen:               Min =  1.00386727E+00,  Max =  6.57858723E+00
    - ssflux_eigen:               Min =  1.00787196E+00,  Max =  6.57883654E+00

 Error Covariance Normalization Factors: Exact Method

    Computing initial conditions 2D normalization factors at RHO-points
    - zeta:                       Min =  4.18120172E+04,  Max =  1.60976432E+05,  CheckSum = 59441
       wrote  zeta  normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    Computing initial conditions 2D normalization factors at   U-points
    - ubar:                       Min =  4.94156290E+04,  Max =  1.60949973E+05,  CheckSum = 57588
       wrote  ubar  normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    Computing initial conditions 2D normalization factors at   V-points
    - vbar:                       Min =  0.00000000E+00,  Max =  1.61062222E+05,  CheckSum = 57366
       wrote  vbar  normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    Computing initial conditions 3D normalization factors at   U-points
    - u:                          Min =  6.11825521E+05,  Max =  3.59213132E+06,  CheckSum = 1735874
       wrote  u     normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    Computing initial conditions 3D normalization factors at   V-points
    - v:                          Min =  0.00000000E+00,  Max =  3.60136076E+06,  CheckSum = 1729320
       wrote  v     normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    Computing initial conditions 3D normalization factors at RHO-points
    - temp:                       Min =  3.76057116E+05,  Max =  3.60038617E+06,  CheckSum = 1784766
       wrote  temp  normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    - salt:                       Min =  3.76057116E+05,  Max =  3.60038617E+06,  CheckSum = 1784766
       wrote  salt  normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_i.nc
    Computing boundary conditions 2D normalization factors at RHO-points
    Computing boundary conditions 2D normalization factors at   U-points
    Computing boundary conditions 2D normalization factors at   V-points
    Computing boundary conditions 3D normalization factors at   U-points
    Computing boundary conditions 3D normalization factors at   V-points
    Computing boundary conditions 3D normalization factors at RHO-points
    Computing surface forcing 2D normalization factors at U-stress points
    - sustr:                      Min =  1.20448125E+05,  Max =  2.62503088E+05,  CheckSum = 59645
       wrote  sustr normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_f.nc
    Computing surface forcing 2D normalization factors at V-stress points
    - svstr:                      Min =  0.00000000E+00,  Max =  2.62175112E+05,  CheckSum = 59381
       wrote  svstr normalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_f.nc
    Computing surface forcing 2D normalization factors at RHO-points
    - shflux:                     Min =  9.47511752E+04,  Max =  2.62180464E+05,  CheckSum = 61093
       wrote  shfluxnormalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_f.nc
    - ssflux:                     Min =  9.47511777E+04,  Max =  2.62180475E+05,  CheckSum = 61107
       wrote  ssfluxnormalization factors into record 1, file: ../Data/wc13_nrm_xy_multiscale_f.nc

 Dirac Delta Function Perturbations:

 ANA_PERTURB - Tangent tl_ubar perturbed at (i,j) =               15  30
 ANA_PERTURB - Tangent tl_vbar perturbed at (i,j) =               15  35
 ANA_PERTURB - Tangent tl_zeta perturbed at (i,j) =               25  20
 ANA_PERTURB - Tangent tl_ustr perturbed at (i,j,ir) =            18  30   1
 ANA_PERTURB - Tangent tl_vstr perturbed at (i,j,ir) =            18  35   1
 ANA_PERTURB - Tangent tl_u perturbed at (i,j,k) =                15  30  30
 ANA_PERTURB - Tangent tl_v perturbed at (i,j,k) =                15  35  30
 ANA_PERTURB - Tangent tl_t perturbed at (i,j,k,itrc) =           30  20  30   1
 ANA_PERTURB - Tangent tl_t perturbed at (i,j,k,itrc) =           20  40  30   2
 ANA_PERTURB - Tangent tl_tflux perturbed at (i,j,ir,itrc) =      20  15   1   1
 ANA_PERTURB - Tangent tl_tflux perturbed at (i,j,ir,itrc) =      25  20   1   2

  TL_DEF_HIS_NF90  - creating tangent file,            Grid 01: wc13_tlm.nc

  TL_WRT_HIS_NF90  - writing history     fields (Index=2,2) in record = 1
    - sustr:                      Min =  3.77757524E-20,  Max =  9.99999727E-01,  CheckSum = 329425
    - svstr:                      Min =  0.00000000E+00,  Max =  9.99998902E-01,  CheckSum = 328210
    - shflux:                     Min =  5.56974263E-19,  Max =  1.00000000E+00,  CheckSum = 335735
    - ssflux:                     Min =  1.54268153E-17,  Max =  1.00000000E+00,  CheckSum = 339280
    - zeta:                       Min =  3.83914426E-33,  Max =  1.00000000E+00,  CheckSum = 66229
    - ubar:                       Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - DU_avg1:                    Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - DU_avg2:                    Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - vbar:                       Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - DV_avg1:                    Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - DV_avg2:                    Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - u:                          Min =  5.90631127E-46,  Max =  1.00000000E+00,  CheckSum = 1925886
    - v:                          Min =  0.00000000E+00,  Max =  1.00000000E+00,  CheckSum = 1917302
    - temp:                       Min =  2.54954585E-45,  Max =  1.00000000E+00,  CheckSum = 1975336
    - salt:                       Min =  1.14926279E-52,  Max =  1.00000000E+00,  CheckSum = 1970657
    - rho:                        Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - AKv:                        Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - AKt:                        Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
    - AKs:                        Min =  0.00000000E+00,  Max =  0.00000000E+00,  CheckSum = 0
```

---

### Convergence:

> [!IMPORTANT]  
> :earth_americas: We recommend activating the **`MULTI_SCALE_DEBUG`** option **only** when computing the normalization factors. Please note that **ROMS** will generate **extensive output** to Fortran Unit 45 (file **`fort.45`**), including detailed information on the convergence of the implicit **CG** algorithm. For example, for the free surface, the output includes:

``` d
CG_2d: Convergence for 'zeta', B-MultiScale = 1

       K-LAP  => iterDiff = 001  iter = 020  deps =  8.80229E-13
       K-LAP  => iterDiff = 002  iter = 020  deps =  8.40234E-13
       K-LAP  => iterDiff = 003  iter = 020  deps =  7.21216E-13
       K-LAP  => iterDiff = 004  iter = 020  deps =  5.71161E-13
       K-LAP  => iterDiff = 005  iter = 020  deps =  4.26397E-13
       K-LAP  => iterDiff = 006  iter = 020  deps =  3.05228E-13
       K-LAP  => iterDiff = 007  iter = 020  deps =  2.13038E-13
       K-LAP  => iterDiff = 008  iter = 020  deps =  1.47236E-13
       K-LAP  => iterDiff = 009  iter = 020  deps =  1.01729E-13
       K-LAP  => iterDiff = 010  iter = 020  deps =  7.03380E-14

       K-DIFF => iterDiff = 010  iter = 000  deps =  1.00000E+00
       K-DIFF => iterDiff = 010  iter = 001  deps =  6.36514E-02
       K-DIFF => iterDiff = 010  iter = 002  deps =  7.98343E-03
       K-DIFF => iterDiff = 010  iter = 003  deps =  1.52484E-03
       K-DIFF => iterDiff = 010  iter = 004  deps =  3.37602E-04
       K-DIFF => iterDiff = 010  iter = 005  deps =  8.23612E-05
       K-DIFF => iterDiff = 010  iter = 006  deps =  2.08667E-05
       K-DIFF => iterDiff = 010  iter = 007  deps =  5.14899E-06
       K-DIFF => iterDiff = 010  iter = 008  deps =  1.30401E-06
       K-DIFF => iterDiff = 010  iter = 009  deps =  3.19642E-07
       K-DIFF => iterDiff = 010  iter = 010  deps =  8.10830E-08
       K-DIFF => iterDiff = 010  iter = 011  deps =  1.95512E-08
       K-DIFF => iterDiff = 010  iter = 012  deps =  4.99654E-09
       K-DIFF => iterDiff = 010  iter = 013  deps =  1.24145E-09
       K-DIFF => iterDiff = 010  iter = 014  deps =  3.01005E-10
       K-DIFF => iterDiff = 010  iter = 015  deps =  7.75697E-11
       K-DIFF => iterDiff = 010  iter = 016  deps =  1.91668E-11
       K-DIFF => iterDiff = 010  iter = 017  deps =  4.70342E-12
       K-DIFF => iterDiff = 010  iter = 018  deps =  1.14870E-12
       K-DIFF => iterDiff = 010  iter = 019  deps =  2.80783E-13
       K-DIFF => iterDiff = 010  iter = 020  deps =  7.03380E-14
```	   
---
### References:

Fisher, M. and P. Courtier, **1995**: Estimating the covariance matrices of analysis and forecast error in variational data assimilation, *ECMWF Technical Memoranda*, **220**, [doi:10.21957/1dxrasjit](https://doi.org/10.21957/1dxrasjit).

Moore, A.M., H.G. Arango, G. Broquet, B.S. Powell, A.T. Weaver, and J. Zavala-Garay, **2011**: The Regional Ocean Modeling System (ROMS)  4-dimensional variational data assimilation systems, Part I - System overview and formulation, *Prog. Oceanogr.*, **91**, 34-49, [doi:10.1016/j.pocean.2011.05.004](https://doi.org/10.1016/j.pocean.2011.05.004).

Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani, B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson, **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional variational data assimilations systems, Part II - Performance and application to the California Current System, *Prog.Oceanogr.*, **91**, 50-73,
  [doi:10.1016/j.pocean.2011.05.003](https://doi.org/10.1016/j.pocean.2011.05.003).

Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani, B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson, **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional variational data assimilations systems, Part III - Observation impact and observation sensitivity in the California Current System, *Prog. Oceanogr.*, **91**, 74-94, [doi:10.1016/j.pocean.2011.05.005](https://doi.org/10.1016/j.pocean.2011.05.005).

Weaver, A. and P. Courtier, **2001**: Correlation modeling on the sphere using a generalized diffusion equation, *Q.J.R. Meteorol. Soc.* **127**, 1815-1846, [doi:10.1002/qj.49712757518](https://doi.org/10.1002/qj.49712757518).
  
Weaver, A.T. and I. Mirouze, **2013**: On the diffusion equation and its application to isotropic and anisotropic correlation modeling in variational assimilation, _Q. J. R. Meteorol. Soc._, **139,** 242-260, [doi:10.1002/qj.1955](https://doi.org/10.1002/qj.1955).

Weaver, A.T., Tshimanga, J., and A. Piacentini, **2016**: Correlation operators based on an implicitly formulated diffusion equation solved with the Chebyshev iteration, _Q. J. R. Meteorol. Soc._, **142**, 455-471, [doi: 10.1002/qj.2664](https://doi.org/10.1002/qj.2664).

Weaver, A.T., Gürol, S., Tshimanga, J., Chrust, M., and A. Piacentini, **2018**: "Time"-parallel diffusion-based correlation operators, _Q. J. R. Meteorol. Soc._, **144**, 2067-2088, [doi: 10.1002/qj.3302](https://doi.org/10.1002/qj.3302).
