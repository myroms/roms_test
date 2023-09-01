<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## RBL4D-Var Forecast Cycle Observation Impacts: Step 2 (RED FORECAST)

Runs ROMS Nonlinear model in forcast mode by initializing with
the RBL4D-Var analysis (EX3_RPCG) file "wc13_dai.nc", red curve
forecast.

The VERIFICATION option is activated to interpolate the forecats
trajectory at the new observation locations "forecast_obs.nc". The
nonlinear model values at the observation locations are stored in
"wc13_mod.nc".

The surface forcing fields are read from "../FCSTAT/wc13_frw.nc",
BULK_FLUXES is NOT activated. This step is necessary because the
red forecast and green forecast must be subject to the same
surface and lateral boundary conditions.


4D-Var Tutorial: https://www.myroms.org/wiki/4DVar_Tutorial_Introduction
                 Exercise 08, Step 2


Important CPP options:

   NLM_DRIVER              Nonlinear model driver
   ANA_SPONGE              Analytical enhanced viscosity/diffusion sponge
   FORWARD_WRITE           Write out Forward solution for Tangent/Adjoint
   VERIFICATION            Proccess model solution at observation locations
   WC13                    Application CPP option

Input NetCDF files:

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

Currently, you can find the following files here:

   build_roms.csh      csh  script to compile application
   build_roms.sh       bash script to compile application
   cbuild_roms.csh     csh  CMake script to compile application
   cbuild_roms.sh      bash CMake script to compile application
   job_fcsta.csh       job configuration script
   roms_wc13.in        ROMS standard input script for WC13
   s4dvar.in           4D-Var standard input script template
   wc13.h              WC13 header with CPP options

To run this application you need to take the following steps:

  (1) Customize your preferred "build_roms" script and provide the
      appropriate values for:

      * Root directory, MY_ROOT_DIR
      * ROMS source code, MY_ROMS_SRC
      * Fortran compiler, FORT
      * MPI flags, USE_MPI and USE_MPIF90
      * Path of MPI, NetCDF, and ARPACK libraries according to
        the compiler. Notice that you need to provide the
        correct places of these libraries for your computer.
        If you want to ignore this section, set USE_MY_LIBS
        value to "no".

  (2) Notice that the most important CPP options for this application
      are specified in the "build_roms" script instead of "wc13.h":

       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DNLM_DRIVER"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DANA_SPONGE"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DFORWARD_WRITE"
       setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DVERIFICATION"

      this is to allow flexibility with different CPP options.

      For this to work, however, any "#undef" directives MUST be
      avoided in the header file "wc13.h" since it has precedence
      during C-preprocessing.

  (3) You MUST use the "build_roms" script to compile.

  (4) Customize the ROMS input script "roms_wc13.in" and specify
      the appropriate values for the distributed-memory partition.
      It is set by default to:

      NtileI == 2                               ! I-direction partition
      NtileJ == 4                               ! J-direction partition

      Notice that the adjoint-based algorithms can only be run
      in parallel using MPI.  This is because of the way that the
      adjoint model is constructed.

  (5) Customize the configuration script "job_fcsta.csh" and provide
      the appropriate place for the "substitute" Perl script:

      set SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute

      This script is distributed with ROMS and it is found in the
      ROMS/Bin sub-directory. Alternatively, you can define
      ROMS_ROOT environmental variable in your .cshrc login
      script. For example, I have:

      setenv ROMS_ROOT ${HOME}/ocean/repository/trunk

  (6) Execute the configuration "job_fcsta.csh" BEFORE running
      the model. It copies the required files and creates "rbl4dvar.in"
      input script from template "s4dvar.in". This has to be done
      EVERY TIME that you run this application. We need a clean and
      fresh copy of the initial conditions and observation files
      since they are modified by ROMS during execution.

  (7) Run ROMS with data assimilation:

      mpirun -np 8 romsM roms_wc13.in > & log &
