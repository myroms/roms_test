<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Tutorial: RBL4D-Var Forecast Cycle Observation Impacts - Exercise 8, Step 2

It sets and runs the **ROMS** Nonlinear model in forecast mode,
initialized with the **RBL4D-Var** analysis file **wc13_dai.nc**
to compute the Red Forecast curve trajectory shown below:

<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/e6e46069-f78a-4ffb-967f-4f45bf6960d2"> 

The **VERIFICATION** option is activated to interpolate the forecast
trajectory at the new observation locations **forecast_obs.nc**. The
nonlinear model values at the observation locations are stored in
**wc13_mod.nc**.

The surface forcing fields are read from **`../FCSTAT/wc13_fwd.nc`**,
**BULK_FLUXES** is NOT activated. This step is necessary because the
**red** and **BULK_FLUXES** forecasts must be subject to the same
surface and lateral boundary conditions.

### Important CPP Options:
```
   NLM_DRIVER              Nonlinear model driver
   ANA_SPONGE              Analytical enhanced viscosity/diffusion sponge
   FORWARD_WRITE           Write out the Forward solution for Tangent/Adjoint
   VERIFICATION            Process model solution at observation locations
   WC13                    Application CPP option
```

### Input NetCDF Files:
```
                       Grid File:  ../../Data/wc13_grd.nc
          Nonlinear Initial File:  wc13_ini.nc
                 Forcing File 01:  ../../Data/coamps_wc13_lwrad_down.nc
                 Forcing File 02:  ../../Data/coamps_wc13_Pair.nc
                 Forcing File 03:  ../../Data/coamps_wc13_Qair.nc
                 Forcing File 04:  ../../Data/coamps_wc13_rain.nc
                 Forcing File 05:  ../../Data/coamps_wc13_swrad.nc
                 Forcing File 06:  ../../Data/coamps_wc13_Tair.nc
                 Forcing File 07:  ../../Data/coamps_wc13_wind.nc
                   Boundary File:  ../../Data/wc13_ecco_bry.nc

               Observations File:  wc13_obs.nc
```

### Configuration and Input Scripts:
```
   build_roms.csh           ROMS GNU make compiling and linking CSH script
   build_roms.sh            ROMS GNU make compiling and linking BASH script
   cbuild_roms.csh          ROMS CMake compiling and linking CSH script
   cbuild_roms.sh           ROMS CMake compiling and linking BASH script
   job_fcsta.csh       job configuration script
   roms_wc13.in        ROMS standard input script for WC13
   s4dvar.in           4D-Var standard input script template
   wc13.h              WC13 header with CPP options
```

### How to Run this Application:

You need to take the following steps:

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
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DNLM_DRIVER"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DANA_SPONGE"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DFORWARD_WRITE"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DVERIFICATION"
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

- Customize the configuration script **job_fcsta.csh** and provide
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
  
- Run nonlinear **ROMS Red Forecast**:
  ```
      mpirun -np 8 romsM roms_wc13_daily.in > & log &

      or

      mpirun -np 8 romsM roms_wc13_2hours.in > & log &
  ```

---

### References:

- Drake, P., C.A. Edwards, H.G. Arango, J. Wilkin, T. TajalliBakhsh, B. Powell,
  and A.M. Moore, 2023: Forecast Sensitivity-based Observation Impact (FSOI)
  in an analysis–forecast system of the California Current Circulation, *Ocean
  Model.*, 182, https://doi.org/10.1016/j.ocemod.2022.102159.

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

