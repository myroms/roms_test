#!/bin/bash
#
# git $Id$
# svn $Id: build_roms.sh 1184 2023-07-27 20:28:19Z arango $
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Copyright (c) 2002-2025 The ROMS Group                                :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::: Hernan G. Arango :::
#                                                                       :::
# ROMS Compiling BASH Script: Split Executables Algorithms              :::
#                                                                       :::
# Usage:                                                                :::
#                                                                       :::
#    ./build_split.sh [options]                                         :::
#                                                                       :::
# Options:                                                              :::
#                                                                       :::
#    -ad         Compile ROMS adjoint executable                        :::
#                                                                       :::
#                  build_split.sh -ad -j 10                             :::
#                                                                       :::
#    -nl         Compile ROMS nonlinear executable                      :::
#                                                                       :::
#                  build_split.sh -nl -j 10                             :::
#                                                                       :::
#                                                                       :::
#    -tl         Compile ROMS tangent linear executable                 :::
#                                                                       :::
#                  build_split.sh -ad -j 10                             :::
#                                                                       :::
#    -b          Compile a specific ROMS GitHub branch                  :::
#                                                                       :::
#                  build_split.sh -ad -j 10 -b feature/kernel           :::
#                                                                       :::
#    -j [N]      Compile in parallel using N CPUs                       :::
#                  omit argument for all available CPUs                 :::
#                                                                       :::
#    -p macro    Prints any Makefile macro value. For example,          :::
#                                                                       :::
#                  build_split.sh -p FFLAGS                             :::
#                                                                       :::
#    -noclean    Do not clean already compiled objects                  :::
#                                                                       :::
# Notice that sometimes the parallel compilation fail to find MPI       :::
# include file "mpif.h".                                                :::
#                                                                       :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

export which_MPI=openmpi                       # default, overwritten below

ad_exe=0
nl_exe=0
tl_exe=0
parallel=0
clean=1
dprint=0
branch=0

command="build_split.sh $@"

separator=`perl -e "print '<>' x 50;"`

export MY_CPP_FLAGS=

while [ $# -gt 0 ]
do
  case "$1" in
    -ad )
      shift
      ad_exe=1
      ;;

    -nl )
      shift
      nl_exe=1
      ;;

    -tl )
      shift
      tl_exe=1
      ;;

    -j )
      shift
      parallel=1
      test=`echo $1 | grep '^[0-9]\+$'`
      if [ "$test" != "" ]; then
        NCPUS="-j $1"
        shift
      else
        NCPUS="-j"
      fi
      ;;

    -p )
      shift
      clean=0
      dprint=1
      debug="print-$1"
      shift
      ;;

    -noclean )
      shift
      clean=0
      ;;

    -b )
      shift
      branch=1
      branch_name=`echo $1 | grep -v '^-'`
      if [ "$branch_name" == "" ]; then
	echo "Please enter a ROMS GitHub branch name."
	exit 1
      fi
      shift
      ;;
      
    * )
      echo ""
      echo "${separator}"
      echo "$0 : Unknown option [ $1 ]"
      echo ""
      echo "Available Options:"
      echo ""
      echo "-ad             Compile split ROMS adjoint executable"
      echo ""
      echo "-b branch_name  Compile specific ROMS GitHub branch name"
      echo "                  For example:  build_roms.sh -b feature/kernel"
      echo ""
      echo "-nl             Compile split ROMS nonlinear executable"
      echo ""
      echo "-tl             Compile split ROMS tangent linear executable"
      echo ""
      echo "-j [N]          Compile in parallel using N CPUs"
      echo "                  omit argument for all avaliable CPUs"
      echo ""
      echo "-p macro        Prints any Makefile macro value"
      echo "                  For example:  build_split.sh -p FFLAGS"
      echo ""
      echo "-noclean        Do not clean already compiled objects"
      echo ""
      exit 1
      ;;
  esac
done

if [[ $nl_exe == 1 && $ad_exe == 1 ]]; then
  echo "Cannot have -nl and -da options activated at the same time"
  exit 1
fi

# Set the CPP option defining the particular application. This will
# determine the name of the ".h" header file with the application
# CPP definitions.

export   ROMS_APPLICATION=WC13

# Set a local environmental variable to define the path to the directories
# where the ROMS source code is located (MY_ROOT_DIR), and this project's
# configuration and files are kept (MY_PROJECT_DIR). Notice that if the
# User sets the ROMS_ROOT_DIR environment variable in their computer logging
# script describing the location from where the ROMS source code was cloned
# or downloaded, it uses that value.

if [ -n "${ROMS_ROOT_DIR:+1}" ]; then
  export      MY_ROOT_DIR=${ROMS_ROOT_DIR}
else
  export      MY_ROOT_DIR=${HOME}/ocean/repository/git
fi

export     MY_PROJECT_DIR=${PWD}

# The path to the user's local current ROMS source code.
#
# If downloading ROMS locally, this would be the user's Working Copy Path.
# One advantage of maintaining your source code copy is that when working
# simultaneously on multiple machines (e.g., a local workstation, a local
# cluster, and a remote supercomputer), you can update with the latest ROMS
# release and always get an up-to-date customized source on each machine.
# This script allows for differing paths to the code and inputs on other
# computers.

 export       MY_ROMS_SRC=${MY_ROOT_DIR}/roms
#export       MY_ROMS_SRC=${HOME}/ocean/repository/svn/branches/arango
#export       MY_ROMS_SRC=${HOME}/ocean/repository/git/roms_src

# Set path of the directory containing makefile configuration (*.mk) files.
# The user has the option to specify a customized version of these files
# in a different directory than the one distributed with the source code,
# ${MY_ROMS_SRC}/Compilers. If this is the case, you need to keep these
# configurations files up-to-date.

 export         COMPILERS=${MY_ROMS_SRC}/Compilers
#export         COMPILERS=${HOME}/Compilers/ROMS

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
#export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DAVERAGES"
#export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DDEBUGGING"
#
# can be used to write time-averaged fields. Notice that you can have as
# many definitions as you want by appending values.

if [ $ad_exe -eq 1 ]; then
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DADM_DRIVER"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DINITIALIZE_AUTOMATIC"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DFORWARD_FLUXES"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DFORWARD_READ"

# export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DAD_OUTPUT_STATE"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DOUT_DOUBLE"
# export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DSINGLE_PRECISION"
fi

if [ $nl_exe -eq 1 ]; then
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DNLM_DRIVER"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DBULK_FLUXES"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DDIURNAL_SRFLUX"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DEMINUSP"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DLONGWAVE_OUT"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DSOLAR_SOURCE"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DLIMIT_VDIFF"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DLIMIT_VVISC"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DFORWARD_WRITE"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DOUT_DOUBLE"
fi

if [ $tl_exe -eq 1 ]; then
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DTLM_DRIVER"

  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DFORWARD_FLUXES"
  export     MY_CPP_FLAGS="${MY_CPP_FLAGS} -DFORWARD_READ"

  export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DOUT_DOUBLE"
# export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DSINGLE_PRECISION"
fi

 export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DFORWARD_MIXING"

 export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DCHECKSUM"
 export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DOUTPUT_STATS"

 export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DDEBUGGING"
#export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DPOSITIVE_ZERO"

#export      MY_CPP_FLAGS="${MY_CPP_FLAGS} -DSINGLE_PRECISION"

#--------------------------------------------------------------------------
# Compiler options.
#--------------------------------------------------------------------------
#
# Other user defined environmental variables. See the ROMS makefile for
# details on other options the user might want to set here. Be sure to
# leave the switches meant to be off set to an empty string or commented
# out. Any string value (including off) will evaluate to TRUE in
# conditional if-statements.

 export           USE_MPI=on            # distributed-memory parallelism
 export        USE_MPIF90=on            # compile with mpif90 script
#export         which_MPI=intel         # compile with mpiifort library
#export         which_MPI=mpich         # compile with MPICH library
#export         which_MPI=mpich2        # compile with MPICH2 library
#export         which_MPI=mvapich2      # compile with MVAPICH2 library
 export         which_MPI=openmpi       # compile with OpenMPI library

#export        USE_OpenMP=on            # shared-memory parallelism

 export              FORT=ifort
#export              FORT=gfortran
#export              FORT=pgi

#export         USE_DEBUG=on            # use Fortran debugging flags
 export         USE_LARGE=on            # activate 64-bit compilation

#--------------------------------------------------------------------------
# Building the ROMS executable using the shared library is not recommended
# because it requires keeping track of the matching libROMS.{so|dylib}
# which is located in the Build_roms or Build_romsG directory and will be
# lost and/or replaced with each new build. The option to build the shared
# version of libROMS was introduced for use in model coupling systems.
#--------------------------------------------------------------------------

#export            SHARED=on            # build libROMS.{so|dylib}
 export            STATIC=on            # build libROMS.a

 export              EXEC=on            # build roms{G|M|O|S} executable

# ROMS I/O choices and combinations. A more complete description of the
# available options can be found in the wiki (https://myroms.org/wiki/IO).
# Most users will want to enable at least USE_NETCDF4 because that will
# instruct the ROMS build system to use nf-config to determine the
# necessary libraries and paths to link into the ROMS executable.

 export       USE_NETCDF4=on            # compile with NetCDF-4 library
#export   USE_PARALLEL_IO=on            # Parallel I/O with NetCDF-4/HDF5
#export           USE_PIO=on            # Parallel I/O with PIO library
#export       USE_SCORPIO=on            # Parallel I/O with SCORPIO library

# If any of the coupling component use the HDF5 Fortran API for primary
# I/O, we need to compile the main driver with the HDF5 library.

#export          USE_HDF5=on            # compile with HDF5 library

#--------------------------------------------------------------------------
# If coupling Earth System Models (ESM), set the location of the ESM
# component libraries and modules.
#--------------------------------------------------------------------------

source ${MY_ROMS_SRC}/ESM/esm_libs.sh ${MY_ROMS_SRC}/ESM/esm_libs.sh

#--------------------------------------------------------------------------
# If applicable, use my specified library paths.
#--------------------------------------------------------------------------

 export USE_MY_LIBS=no            # use system default library paths
#export USE_MY_LIBS=yes           # use my customized library paths

MY_PATHS=${COMPILERS}/my_build_paths.sh

if [ "${USE_MY_LIBS}" == "yes" ]; then
  source ${MY_PATHS} ${MY_PATHS}
fi

#--------------------------------------------------------------------------
# The rest of this script sets the path to the users header file and
# analytical source files, if any. See the templates in User/Functionals.
#--------------------------------------------------------------------------
#
# If applicable, use the MY_ANALYTICAL_DIR directory to place your
# customized biology model header file (like fennel.h, nemuro.h, ecosim.h,
# etc).

 export     MY_HEADER_DIR=${MY_PROJECT_DIR}

 export MY_ANALYTICAL_DIR=${MY_PROJECT_DIR}

# Put the binary to execute in the following directory.

 export            BINDIR=${MY_PROJECT_DIR}

if [ -n "${USE_DEBUG:+1}" ]; then
  if [ $ad_exe -eq 1 ]; then
    export            BIN=${BINDIR}/romsG_ad
  elif [ $tl_exe -eq 1 ]; then
    export            BIN=${BINDIR}/romsG_tl
  else
    export            BIN=${BINDIR}/romsG_nl
  fi
else
  if [ -n "${USE_MPI:+1}" ]; then
    if [ $ad_exe -eq 1 ]; then
      export          BIN=${BINDIR}/romsM_ad
    elif [ $tl_exe -eq 1 ]; then
      export          BIN=${BINDIR}/romsM_tl
    else
      export          BIN=${BINDIR}/romsM_nl
    fi
  else
    if [ $ad_exe -eq 1 ]; then
      export          BIN=${BINDIR}/romsS_ad
    elif [ $tl_exe -eq 1 ]; then
      export          BIN=${BINDIR}/romsS_tl
    else
      export          BIN=${BINDIR}/romsS_nl
    fi
  fi
fi

# Put the f90 files in a project specific Build directory to avoid conflict
# with other projects.

if [ -n "${USE_DEBUG:+1}" ]; then
  if [ $ad_exe -eq 1 ]; then
    export    SCRATCH_DIR=${MY_PROJECT_DIR}/Build_romsG_ad
  elif [ $tl_exe -eq 1 ]; then
    export    SCRATCH_DIR=${MY_PROJECT_DIR}/Build_romsG_tl
  else
    export    SCRATCH_DIR=${MY_PROJECT_DIR}/Build_romsG_nl
  fi
else
  if [ $ad_exe -eq 1 ]; then
    export    SCRATCH_DIR=${MY_PROJECT_DIR}/Build_roms_ad
  elif [ $tl_exe -eq 1 ]; then
    export    SCRATCH_DIR=${MY_PROJECT_DIR}/Build_roms_tl
  else
    export    SCRATCH_DIR=${MY_PROJECT_DIR}/Build_roms_nl
  fi
fi

# If necessary, create ROMS build directory.

if [ ! -d ${BUILD_DIR} ]; then
  echo ""
  echo "Creating ROMS build directory: ${BUILD_DIR}"
  echo ""
  mkdir $BUILD_DIR
fi

# Go to the users source directory to compile. The options set above will
# pick up the application-specific code from the appropriate place.

if [ $branch -eq 1 ]; then

  # Check out requested branch from ROMS GitHub.

  if [ ! -d ${MY_PROJECT_DIR}/src ]; then
    echo ""
    echo "Downloading ROMS source code from GitHub: https://www.github.com/myroms"
    echo ""
    git clone https://www.github.com/myroms/roms.git src
  fi
  echo ""
  echo "Checking out ROMS GitHub branch: $branch_name"
  echo ""
  cd src
  git checkout $branch_name

  # If we are using the COMPILERS from the ROMS source code
  # overide the value set above

  if [[ ${COMPILERS} == ${MY_ROMS_SRC}* ]]; then
    export COMPILERS=${MY_PROJECT_DIR}/src/Compilers
  fi
  export MY_ROMS_SRC=${MY_PROJECT_DIR}/src

else
  echo ""
  echo "Using ROMS source code from: ${MY_ROMS_SRC}"
  echo ""
  cd ${MY_ROMS_SRC}
fi

#--------------------------------------------------------------------------
# Compile.
#--------------------------------------------------------------------------

# Remove build directory.

if [ $clean -eq 1 ]; then
  echo ""
  echo "Cleaning ROMS build directory: ${BUILD_DIR}"
  echo ""
  make clean
fi

# Compile (the binary will go to BINDIR set above).

if [ $dprint -eq 1 ]; then
  make $debug
else
  echo ""
  echo "Compiling ROMS source code:"
  echo ""
  if [ $parallel -eq 1 ]; then
    make $NCPUS
  else
    make
  fi

  echo ""
  echo "${separator}"
  echo "GNU Build script command:      ${command}"
  echo "ROMS source directory:         ${MY_ROMS_SRC}"
  echo "ROMS build  directory:         ${BUILD_DIR}"
  if [ $branch -eq 1 ]; then
    echo "ROMS downloaded from:          https://github.com/myroms/roms.git"
    echo "ROMS compiled branch:          $branch_name"
  fi
  echo "ROMS Application:              ${ROMS_APPLICATION}"
  FFLAGS=`make print-FFLAGS | cut -d " " -f 3-`
  echo "Fortran compiler:              ${FORT}"
  echo "Fortran flags:                 ${FFLAGS}"
  if [ -n "${MY_CPP_FLAGS:+1}" ]; then
    echo "Added CPP Options:            ${MY_CPP_FLAGS}"
  fi
  echo "${separator}"
  echo ""
fi
