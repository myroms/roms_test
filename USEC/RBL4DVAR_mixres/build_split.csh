#!/bin/csh -f
#
# git $Id$
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Copyright (c) 2002-2025 The ROMS Group                                :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.md                                                 :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::: Hernan G. Arango :::
#                                                                       :::
#                                                                       :::
# ROMS Compiling BASH Script: Split Executables Algorithms for 4D-Var   :::
# with possible mixed resolution or precision.                          :::
#                                                                       :::
# Usage:                                                                :::
#                                                                       :::
#    ./build_split.csh [options]                                        :::
#                                                                       :::
# Options:                                                              :::
#                                                                       :::
#    -da         Compile data assimilation executable (inner loops)     :::
#                                                                       :::
#                  build_split.csh -da -j 10                            :::
#                                                                       :::
#    -nl         Compile nonlinear trajectory executable (outer loops)  :::
#                                                                       :::
#                  build_split.csh -nl -j 10                            :::
#                                                                       :::
#    -b          Compile a specific ROMS GitHub branch                  :::
#                                                                       :::
#                  build_split.csh -nl -j 10 -b feature/kernel          :::
#                                                                       :::
#    -g          Compile with debug flag (slower code)                  :::
#                                                                       :::
#                  build_split.csh -g -nl -j 10                         :::
#                                                                       :::
#    -j [N]      Compile in parallel using N CPUs                       :::
#                  omit argument for all available CPUs                 :::
#                                                                       :::
#    -pio        Compile with PIO (Parallel I/O) NetCDF library         :::
#                  Otherwise, it used standard NetCDF library (slower)  :::
#                                                                       :::
#                  build_split.csh -nl -pio -j 10                       :::
#                                                                       :::
#    -p macro    Prints any Makefile macro value. For example,          :::
#                                                                       :::
#                  build_split.csh -p FFLAGS                            :::
#                                                                       :::
#    -noclean    Do not clean already compiled objects                  :::
#                                                                       :::
# Notice that sometimes the parallel compilation fail to find MPI       :::
# include file "mpif.h".                                                :::
#                                                                       :::
# The branch option -b is only possible for ROMS source code from       :::
# https://github.com/myroms. Such versions are under development        :::
# and targeted to advanced users, superusers, and beta testers.         :::
# Regular and novice users must use the default 'develop' branch.       :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setenv which_MPI openmpi                      #  default, overwritten below

set da_exe = 0
set nl_exe = 0
set g_flags = 0
set parallel = 0
set pio_lib = 0
set clean = 1
set dprint = 0
set branch = 0

set command = "build_split.csh $argv[*]"

set separator = `perl -e "print '<>' x 50;"`

setenv MY_CPP_FLAGS ''

while ( ($#argv) > 0 )
  switch ($1)
    case "-noclean"
      shift
      set clean = 0
    breaksw

    case "-da"
      shift
      set da_exe = 1
    breaksw

    case "-nl"
      shift
      set nl_exe = 1
    breaksw

    case "-g"
      shift
      set g_flags = 1
    breaksw

    case "-pio"
      shift
      set pio_lib = 1
    breaksw

    case "-p"
      shift
      set clean = 0
      set dprint = 1
      set debug = "print-$1"
      shift
    breaksw

    case "-j"
      shift
      set parallel = 1
      if (`echo $1 | grep '^[0-9]\+$'` != "" ) then
        set NCPUS = "-j $1"
        shift
      else
        set NCPUS = "-j"
      endif
    breaksw

    case "-b"
      shift
      set branch = 1
      set branch_name = `echo $1 | grep -v '^-'`
      if ( "$branch_name" == "" ) then
        echo "Please enter a branch name."
        exit 1
      endif
      shift
    breaksw

    case "-*":
      echo ""
      echo "${separator}"
      echo "$0 : Unknown option [ $1 ]"
      echo ""
      echo "Available Options:"
      echo ""
      echo "-da             Compile split data assimilation executable"
      echo ""
      echo "-b branch_name  Compile specific ROMS GitHub branch name"
      echo "                  For example:  build_roms.sh -b feature/kernel"
      echo ""
      echo "-g              Compile with debugging flags, slower code"
      echo ""
      echo "-nl             Compile split nonlinear trajectory executable"
      echo ""
      echo "-j [N]          Compile in parallel using N CPUs"
      echo "                  omit argument for all avaliable CPUs"
      echo ""
      echo "-pio            Compile with the PIO NetCDF Library"
      echo ""
      echo "-p macro        Prints any Makefile macro value"
      echo "                  For example:  build_split.sh -p FFLAGS"
      echo ""
      echo "-noclean        Do not clean already compiled objects"
      echo ""
      echo "${separator}"
      echo ""
      exit 1
    breaksw

  endsw
end

if ( $nl_exe == 1 && $da_exe == 1) then
  echo "  ERROR: Cannot have -nl and -da options activated at the same time!"
  exit 1
endif
if ( $nl_exe == 0 && $da_exe == 0) then
  echo "  ERROR: Must have -nl or -da option activated to compile!"
  exit 1
endif

# Set the CPP option defining the particular application. This will
# determine the name of the ".h" header file with the application
# CPP definitions.

setenv ROMS_APPLICATION      USEC

# Set a local environmental variable to define the path to the directories
# where the ROMS source code is located (MY_ROOT_DIR), and this project's
# configuration and files are kept (MY_PROJECT_DIR). Notice that if the
# User sets the ROMS_ROOT_DIR environment variable in their computer logging
# script describing the location from where the ROMS source code was cloned
# or downloaded, it uses that value.

if ($?ROMS_ROOT_DIR) then
  setenv MY_ROOT_DIR        ${ROMS_ROOT_DIR}
else
  setenv MY_ROOT_DIR        ${HOME}/ocean/repository/git
endif

setenv   MY_PROJECT_DIR     ${PWD}

# The path to the user's local current ROMS source code.
#
# If downloading ROMS locally, this would be the user's Working Copy Path.
# One advantage of maintaining your source code copy is that when working
# simultaneously on multiple machines (e.g., a local workstation, a local
# cluster, and a remote supercomputer), you can update with the latest ROMS
# release and always get an up-to-date customized source on each machine.
# This script allows for differing paths to the code and inputs on other
# computers.

 setenv  MY_ROMS_SRC        ${MY_ROOT_DIR}/roms

# Set path of the directory containing makefile configuration (*.mk) files.
# The user has the option to specify a customized version of these files
# in a different directory than the one distributed with the source code,
# ${MY_ROMS_SRC}/Compilers. If this is the case, you need to keep these
# configurations files up-to-date.

 setenv COMPILERS            ${MY_ROMS_SRC}/Compilers
#setenv COMPILERS            ${HOME}/Compilers/ROMS

#--------------------------------------------------------------------------
# Set tunable CPP options.
#--------------------------------------------------------------------------
#
# Sometimes it is desirable to activate one or more CPP options to run
# different variants of the same application without modifying its header
# file. If this is the case, specify each options here using the -D syntax.
# Notice also that you need to use shell's quoting syntax to enclose the
# definition.  Both single or double quotes work. For example,
#
#    setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DAVERAGES"
#    setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DDEBUGGING"
#
# can be used to write time-averaged fields. Notice that you can have as
# many definitions as you want by appending values.

if ( $da_exe == 1 ) then
  echo "Compiling 4D-Var Data Assimilation inner loops executable:"  
  echo
# setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DOUT_DOUBLE"
# setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSINGLE_PRECISION"
endif

if ( $nl_exe == 1 ) then
  echo "Compiling 4D-Var Data Assimilation outer loops executable:"  
  echo
  setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSPLIT_EXECUTABLE"

  setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DGRID_EXTRACT"

  setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DOMEGA_IMPLICIT"

  setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DDIURNAL_SRFLUX"   # NARR forcing

  setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DOUT_DOUBLE"
# setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSINGLE_PRECISION"
endif

if ( $pio_lib == 1 ) then
  setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DPIO_LIB"
endif

 setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSPLIT_RBL4DVAR"
 setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DINITIALIZE_AUTOMATIC"

 setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DALLOW_BOTTOM_OBS"
 setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DBGQC"
 setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DRPCG"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DTIME_CONV"

#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DADJUST_BOUNDARY"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DADJUST_STFLUX"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DADJUST_WSTRESS"

#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DROMS_STDOUT"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSUPPRESS_REPORT"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DCHECKSUM"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DOUTPUT_STATS"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DCHECK_OPEN_FILES"

#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DDEBUGGING"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DPOSITIVE_ZERO"

#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DGATHER_SENDRECV"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DSCATTER_BCAST"
 setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DCOLLECT_ALLREDUCE"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DREDUCE_ALLGATHER"
#setenv MY_CPP_FLAGS "${MY_CPP_FLAGS} -DMULTI_THREAD"

#--------------------------------------------------------------------------
# Compiler options.
#--------------------------------------------------------------------------
#
# Other user defined environmental variables. See the ROMS makefile for
# details on other options the user might want to set here. Be sure to
# leave the switches meant to be off set to an empty string or commented
# out. Any string value (including off) will evaluate to TRUE in
# conditional if-statements.

 setenv USE_MPI             on          # distributed-memory parallelism
 setenv USE_MPIF90          on          # compile with mpif90 script
#setenv which_MPI           intel       # compile with mpiifort library
#setenv which_MPI           mpich       # compile with MPICH library
#setenv which_MPI           mpich2      # compile with MPICH2 library
#setenv which_MPI           mvapich2    # compile with MVAPICH2 library
 setenv which_MPI           openmpi     # compile with OpenMPI library

#setenv USE_OpenMP          on          # shared-memory parallelism

#setenv FORT                ifx
 setenv FORT                ifort
#setenv FORT                gfortran
#setenv FORT                pgi

if ( $g_flags == 1 ) then
 setenv USE_DEBUG           on          # use Fortran debugging flags
endif
 setenv USE_LARGE           on          # activate 64-bit compilation

#--------------------------------------------------------------------------
# Building the ROMS executable using the shared library is not recommended
# because it requires keeping track of the matching libROMS.{so|dylib}
# which is located in the Build_roms or Build_romsG directory and will be
# lost and/or replaced with each new build. The option to build the shared
# version of libROMS was introduced for use in model coupling systems.
#--------------------------------------------------------------------------

#setenv SHARED              on          # build libROMS.{so|dylib}
 setenv STATIC              on          # build libROMS.a

 setenv EXEC                on          # build roms{G|M|O|S} executable

# ROMS I/O choices and combinations. A more complete description of the
# available options can be found in the wiki (https://myroms.org/wiki/IO).
# Most users will want to enable at least USE_NETCDF4 because that will
# instruct the ROMS build system to use nf-config to determine the
# necessary libraries and paths to link into the ROMS executable.

 setenv USE_NETCDF4         on          # compile with NetCDF-4 library
#setenv USE_PARALLEL_IO     on          # Parallel I/O with NetCDF-4/HDF5

if ( $pio_lib == 1 ) then
  setenv USE_PIO            on          # Parallel I/O with PIO library
endif

# If any of the coupling component use the HDF5 Fortran API for primary
# I/O, we need to compile the main driver with the HDF5 library.

#setenv USE_HDF5            on          # compile with HDF5 library

#--------------------------------------------------------------------------
# If coupling Earth Systems Models (ESM), set the location of the ESM
# component libraries and modules.
#--------------------------------------------------------------------------

source ${MY_ROMS_SRC}/ESM/esm_libs.csh ${MY_ROMS_SRC}/ESM/esm_libs.csh

#--------------------------------------------------------------------------
# If applicable, use my specified library paths.
#--------------------------------------------------------------------------

 setenv USE_MY_LIBS no           # use system default library paths
#setenv USE_MY_LIBS yes          # use my customized library paths

set MY_PATHS = ${COMPILERS}/my_build_paths.csh

if ($USE_MY_LIBS == 'yes') then
  source ${MY_PATHS} ${MY_PATHS}
endif

#--------------------------------------------------------------------------
# The rest of this script sets the path to the users header file and
# analytical source files, if any. See the templates in User/Functionals.
#--------------------------------------------------------------------------
#
# If applicable, use the MY_ANALYTICAL_DIR directory to place your
# customized biology model header file (like fennel.h, nemuro.h, ecosim.h,
# etc).

 setenv MY_HEADER_DIR       ${MY_PROJECT_DIR}

 setenv MY_ANALYTICAL_DIR   ${MY_PROJECT_DIR}

 echo ""
 echo "${separator}"

# Stop if activating both MPI and OpenMP at the same time.

if ( ${?USE_MPI} & ${?USE_OpenMP} ) then
  echo ""
  echo "You cannot activate USE_MPI and USE_OpenMP at the same time!"
  exit 1
endif

# Put the binary to execute in the following directory.

 setenv BINDIR              ${MY_PROJECT_DIR}

if ($?USE_DEBUG) then
  if ( $da_exe == 1 ) then
    setenv BIN              ${BINDIR}/romsG_da
  else
    setenv BIN              ${BINDIR}/romsG_nl
  endif
else
  if ( $da_exe == 1 ) then
    setenv BIN              ${BINDIR}/romsM_da
  else
    setenv BIN              ${BINDIR}/romsM_nl
  endif
endif

# Put the f90 files in a project specific Build directory to avoid conflict
# with other projects.

if ($?USE_DEBUG) then
  if ( $da_exe == 1 ) then
    setenv BUILD_DIR        ${MY_PROJECT_DIR}/Build_romsG_da
  else
    setenv BUILD_DIR        ${MY_PROJECT_DIR}/Build_romsG_nl
  endif
else
  if ( $da_exe == 1 ) then
    setenv BUILD_DIR        ${MY_PROJECT_DIR}/Build_roms_da
  else
    setenv BUILD_DIR        ${MY_PROJECT_DIR}/Build_roms_nl
  endif
endif

# If necessary, create ROMS build directory.

if ( ! -d $BUILD_DIR ) then
  echo ""
  echo "Creating ROMS build directory: ${BUILD_DIR}"
  echo ""
  mkdir $BUILD_DIR
endif

# Go to the users source directory to compile. The options set above will
# pick up the application-specific code from the appropriate place.

if ( $branch == 1 ) then

  # Check out requested branch from ROMS GitHub.

  if ( ! -d ${MY_PROJECT_DIR}/src ) then
    echo ""
    echo "Downloading ROMS source code from GitHub: https://github.com/myroms"
    echo ""
    git clone https://github.com/myroms/roms.git src
  endif
  echo ""
  echo "Checking out ROMS GitHub branch: $branch_name"
  echo ""
  cd src
  git checkout $branch_name

  # If we are using the COMPILERS from the ROMS source code
  # overide the value set above

  if ( ${COMPILERS} =~ ${MY_ROMS_SRC}* ) then
    setenv COMPILERS ${MY_PROJECT_DIR}/src/Compilers
  endif
  setenv MY_ROMS_SRC ${MY_PROJECT_DIR}/src

else
  echo ""
  echo "Using ROMS source code from: ${MY_ROMS_SRC}"
  echo ""
  cd ${MY_ROMS_SRC}
endif

#--------------------------------------------------------------------------
# Compile.
#--------------------------------------------------------------------------

# Remove build directory.

if ( $clean == 1 ) then
  echo ""
  echo "Cleaning ROMS build directory: ${BUILD_DIR}"
  echo ""
  make clean
endif

# Compile (the binary will go to BINDIR set above).

if ( $dprint == 1 ) then
  make $debug
else
  echo ""
  echo "Compiling ROMS source code:"
  echo ""
  if ( $parallel == 1 ) then
    make $NCPUS
  else
    make
  endif

  set HEADER = `echo ${ROMS_APPLICATION} | tr '[:upper:]' '[:lower:]'`.h

  echo ""
  echo "${separator}"
  echo "GNU Build script command:      ${command}"
  echo "ROMS source directory:         ${MY_ROMS_SRC}"
  echo "ROMS header file:              ${MY_HEADER_DIR}/${HEADER}"
  echo "ROMS build  directory:         ${BUILD_DIR}"
  echo "ROMS executable:               ${BIN}"
  if ( $branch == 1 ) then
    echo "ROMS downloaded from:          https://github.com/myroms/roms.git"
    echo "ROMS compiled branch:          $branch_name"
  endif
  echo "ROMS Application:              ${ROMS_APPLICATION}"
  set FFLAGS = `make print-FFLAGS | cut -d " " -f 3-`
  echo "Fortran compiler:              ${FORT}"
  echo "Fortran flags:                 ${FFLAGS}"
  if ($?MY_CPP_FLAGS) then
    echo "Added CPP Options:            ${MY_CPP_FLAGS}"
  endif
  echo "${separator}"
  echo ""
endif
