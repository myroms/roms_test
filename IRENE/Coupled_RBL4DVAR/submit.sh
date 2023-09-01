#!/bin/bash
#
# git $Id$
#######################################################################
## Copyright (c) 2002-2023 The ROMS/TOMS Group                        #
##   Licensed under a MIT/X style license                             #
##   See License_ROMS.md                                              #
################################################## Hernan G. Arango ###
##                                                                    #
## ROMS Coupled RBL4D-Var Data Assimilation running BASH script:      #
##                                                                    #
## The RBL4D-Var is split in several phases and executables:          #
##                                                                    #
##   1) background                          ROMS_EXE_A                #
##   2) increment                           ROMS_EXE_B                #
##   3) analysis                            ROMS_EXE_C                #
##   4) posterior_error (if activated)      ROMS_EXE_B                #
##                                                                    #
## The 4D-Var algorithm is split into Executable A and B:             #
##                                                                    #
## ROMS_EXE_A: Computes ROMS NLM trajectory used to linearize the     #
##             TLM and ADM kernels used in the 4D-Var minimization.   #
##             It interpolates the NLM solution to the observation    #
##             locations in space and time. The NLM is a component    #
##             in an ESM coupled system. It may include nested grids. #
##                                                                    #
##             Here, the ESMF/NUOPC library is use to couple          #
##             DATA-WRF-ROMS                                          #
##                                                                    #
## ROMS_EXE_B: It is used in the "increment" and "posterior_error"    #
##             phases. The 4D-Var increment is obtained by minimizing #
##             the cost function over Ninner loops. It is possible to #
##             use a coarser grid resolution in the iterations of the #
##             inner loops. If so, the "background" trajectory needs  #
##             to be interpolated into the coarser grid. Then, after  #
##             the inner loops, the coarser grid increment needs to   #
##             be interpolated to the finer grid before the "analysis"#
##             phase. The "increment" phase could be run at a lower   #
##             precision.                                             #
##                                                                    #
## Notice that this script has a customizable function, My4DVarScript,#
## at the top that creates "rbl4dvar.in" from a template, which is    #
## overwritten in each phase. The "rbl4dvar.in" passes to ROMS the    #
## phase and outer loop value to compute.                             #
##                                                                    #
## Then, there is the customizable section for the computer batch     #
## directives and the tunable parameters.                             #
##                                                                    #
## RBL4D-Var phases workflow:                                         #
##                                                                    #
##   CALL prior_error                                                 #
##                                                                    #
##   CALL background (outer=0, RunInterval)                           #
##                                                                    #
##   OuterLoop : DO outer=1:Nouter                                    #
##     CALL increment (outer, RunInterval)               Inner-loops  #
##     CALL analysis (outer, RunInterval)                             #
##   END DO OuterLoop                                                 #
##                                                                    #
##   CALL posterior_error (RunInterval)                  if requested #
##                                                                    #
#######################################################################

##  SLURM configuration for amarel:
##
##  Use 'sbatch submit.sh' to queue the job
##  Use 'squeue -p p_omg_1'                     to check our group jobs (including JOBID)
##  Use 'sacct -j JOBID -l'                     to check job accounting data
##  Use 'scontrol show job JOBID'               to check job configuration
##  Use 'sinfo JOBID'                           to check job information
##  Use 'scancel JOBID'                         to cancel a job

#SBATCH --exclusive                     # don't run on nodes with other jobs running
#SBATCH --constraint=cascadelake        # choose phase2=skylake (old) phase3=cascadelake (new)
#SBATCH --partition=p_omg_1             # Partition (job queue), NodeList: 108,116-120
#SBATCH --requeue                       # Return job to the queue if preempted
#SBATCH --job-name=Coupled_RBL4DVAR     # Assign an short name to your job
#SBATCH --nodes=1                       # Number of nodes you require (each has 32 PETs)
#SBATCH --ntasks=32                     # Total number of tasks you'll launch
#SBATCH --ntasks-per-node=32            # Number of tasks you'll launch on each node
#SBATCH --cpus-per-task=1               # Cores per task (>1 if multithread tasks)
#SBATCH --mem=177000                    # Real memory (RAM) required (MB)
#SBATCH --time=02-00:00:00              # Total run time limit (DD-HH:MM:SS)
#SBATCH --output=log.%N.%j              # STDOUT output file
#SBATCH --error=err.%N.%j               # STDERR output file (optional)
#SBATCH --export=ALL                    # Export you current env to the job env


#######################################################################
## RBL4D-Var data assimilation input script function.  It generates   #
## 'rbl4dvar.in' from the 's4dvar.in' template.                       #
#######################################################################

My4DVarScript() {

     DataDir=$1                # Data directory
  SUBSTITUTE=$2                # ROMS Perl subtitution function
   OuterLoop=$3                # current outer loop counter
  Phase4DVAR=$4                # current 4D-Var computation phase
     OBSname=$5                # 4D-Var observations NetCDF file
     Fprefix=$6                # ROMS output files prefix (use roms_app)
     Fsuffix=$7                # ROMS output files suffix
    Inp4DVAR=$8                # 4D-Var standard input

  echo
  if [ "${Phase4DVAR}" = "post_error" ]; then
    echo "   Creating 4D-Var Input Script from Template: ${Inp4DVAR}" \
          "  Phase = ${Phase4DVAR}"
  else
    echo "   Creating 4D-Var Input Script from Template: ${Inp4DVAR}" \
          "  Outer = ${OuterLoop}  Phase = ${Phase4DVAR}"
  fi
  echo

## Set model, initial conditions, boundary conditions and surface
## forcing error covariance standard deviations files.

 STDnameM=${DataDir}/STD/irene_std_m.nc
 STDnameI=${DataDir}/STD/irene_std_i.nc
 STDnameB=${DataDir}/STD/irene_std_b.nc
 STDnameF=${DataDir}/STD/irene_std_f.nc

## Set model, initial conditions, boundary conditions and surface
## forcing error covariance normalization factors files.

 NRMnameM=${DataDir}/NRM/irene_nrm_40-15k10m.nc
 NRMnameI=${DataDir}/NRM/irene_nrm_40-15k10m.nc
 NRMnameB=${DataDir}/NRM/irene_nrm_b_40-15k10m.nc
 NRMnameF=${DataDir}/NRM/irene_nrm_f_100k.nc

## Modify 4D-Var template input script and specify above files.

 if [ -f $Inp4DVAR ]; then
   /bin/rm ${Inp4DVAR}
 fi

 cp ../s4dvar.in ${Inp4DVAR}

 $SUBSTITUTE $Inp4DVAR MyOuterLoop   ${OuterLoop}
 $SUBSTITUTE $Inp4DVAR MyPhase4DVAR  ${Phase4DVAR}
 $SUBSTITUTE $Inp4DVAR roms_std_m.nc ${STDnameM}
 $SUBSTITUTE $Inp4DVAR roms_std_i.nc ${STDnameI}
 $SUBSTITUTE $Inp4DVAR roms_std_b.nc ${STDnameB}
 $SUBSTITUTE $Inp4DVAR roms_std_f.nc ${STDnameF}
 $SUBSTITUTE $Inp4DVAR roms_nrm_m.nc ${NRMnameM}
 $SUBSTITUTE $Inp4DVAR roms_nrm_i.nc ${NRMnameI}
 $SUBSTITUTE $Inp4DVAR roms_nrm_b.nc ${NRMnameB}
 $SUBSTITUTE $Inp4DVAR roms_nrm_f.nc ${NRMnameF}
 $SUBSTITUTE $Inp4DVAR roms_obs.nc   ${OBSname}
 $SUBSTITUTE $Inp4DVAR roms_hss.nc   ${Fprefix}_hss_${Fsuffix}.nc
 $SUBSTITUTE $Inp4DVAR roms_lcz.nc   ${Fprefix}_lcz_${Fsuffix}.nc
 $SUBSTITUTE $Inp4DVAR roms_lze.nc   ${Fprefix}_lze_${Fsuffix}.nc
 $SUBSTITUTE $Inp4DVAR roms_mod.nc   ${Fprefix}_mod_${Fsuffix}.nc
 $SUBSTITUTE $Inp4DVAR roms_err.nc   ${Fprefix}_err_${Fsuffix}.nc
}

##---------------------------------------------------------------------
## Control switches: What do you want to do?
##---------------------------------------------------------------------

#      DRYRUN=1                # Print configuration but do not execute
       DRYRUN=0                # Run Coupling with 4D-Var

    BULK_FLUX=0                # Use atmospheric model SBL formulation
#   BULK_FLUX=1                # Use ROMS bulk fluxes formulation

        BATCH=0                # No batch system submission
#       BATCH=1                # Use batch system SLURM to submit

      RECYCLE=0                # Keeping all WRF output files, no recycling
#     RECYCLE=1                # Recycle WRF output files, keep last

  ANA_COUPLED=0                # uncoupled analysis phase
# ANA_COUPLED=1                # ESMF/NUOPC coupled analysis phase

    POSTERIOR=0                # DO NOT compute 4D-Var posterior error
#   POSTERIOR=1                # compute 4D-Var posterior error

##---------------------------------------------------------------------
## User tunable parameters.
##---------------------------------------------------------------------

     ROMS_APP="IRENE"                   # ROMS Application CPP

     roms_app=`echo ${ROMS_APP} | tr '[:upper:]' '[:lower:]'` # lowercase

    ROMS_ROOT=${HOME}/ocean/repository/coupling

 echo "ROMS_ROOT = ${ROMS_ROOT}"

      HereDir=${PWD}                    # current directory

      DataDir="../../Data"              # The Data directory

    WRFiniDir="../Data/WRF"             # WRF input Data directory

 if [[ "$OSTYPE" == "darwin"* ]]; then
     DATE_EXE=gdate                     # macOS system GNU date
 else
     DATE_EXE=date                      # Linux system date
 fi

 if [ ${BATCH} -eq 1 ]; then
         SRUN="srun --mpi=pmi2"         # SLURM workload manager
 else
       MPIrun="mpirunI -np"             # Basic MPI workload manager
 fi

   ROMS_EXE_A="romsM_nl"                # ROMS executable A
   ROMS_EXE_B="romsM_da"                # ROMS executable B
 if [ ${ANA_COUPLED} -eq 1 ]; then
   ROMS_EXE_C="romsM_nl"                # ROMS executable C, coupled analysis
 else
   ROMS_EXE_C="romsM_da"                # ROMS executable C, uncopled analysis
 fi

   START_DATE="2011-08-27-06"           # coupled 4dvar starting date

 FRST_INI_DAY="2011-08-27-06"           # restart initialization date

 LAST_INI_DAY="${START_DATE}"           # last cycle initialization date

 ROMS_TIMEREF="2006-01-01-00"           # ROMS time reference date

     INTERVAL=1.75                      # 4D-Var interval window (days)

     NnestWRF=1                         # WRF number of nested grids
       nPETsX=4                         # WRF/ROMS number PETs in the X-direction
       nPETsY=8                         # WRF/ROMS number PETs in the Y-direction
   nPETsXdata=3                         # DATA number PETs in the X-direction
   nPETsYdata=4                         # DATA number PETs in the Y-direction

     MyNouter=1                         # ROMS number of 4D-Var outer loops

     MyNinner=16                        # ROMS number of 4D-Var inner loops

       MyNHIS=180                       # ROMS NLM trajectory is saved every 6 hours
    MyNDEFHIS=0                         # no multi-file NLM trajectory

       MyNQCK=60                        # ROMS NLM trajectory is saved hourly

       MyNTLM=180                       # ROMS TLM trajectory is saved every 6 hours

#      MyNADJ=180                       # weak constraint, ROMS ADM trajectory daily
       MyNADJ=2520                      # strong contraint, ROMS ADM saved at end

      MyNRREC=0                         # ROMS restart Record

      restart=0                         # restart cycle (0:no, 1:yes)
#     restart=1                         # restart cycle (0:no, 1:yes)

       WRFpre="namelist.input"          # WRF namelist prefix
       WRFtmp="${WRFpre}.tmp"           # WRF namelist template

   ROMS_NLpre="roms_nl_irene"           # ROMS NLM stdinp prefix
   ROMS_NLtmp="${ROMS_NLpre}.tmp"       # ROMS NLM stdinp template

   ROMS_DApre="roms_da_irene"           # ROMS ADM/TLM stdinp prefix
   ROMS_DAtmp="${ROMS_DApre}.tmp"       # ROMS ADM/TLM stdinp template

 if [ ${restart} -eq 0 ]; then
      ROMSini="irene_roms_ini_20110827_06.nc"  # ROMS IC
   ROMSiniDir=${DataDir}/ROMS                  # ROMS IC directory
       WRFini="irene_wrf_inp_d01_20110827.nc"  # WRF IC
    WRFiniDir=${DataDir}/WRF                   # WRF IC directory
 else
      ROMSini="irene_roms_dai_20110827.nc"     # restart ROMS IC
   ROMSiniDir=../Run02/2017.12.22              # restart ROMS IC directory
 fi

     Inp4DVAR="rbl4dvar.in"                 # ROMS 4D-Var input script

 if [ ${BULK_FLUX} -eq 1 ]; then
      ESMFpre="coupling_esmf_bulk_flux"     # ROMS BULK_FLUXES case
 else
      ESMFpre="coupling_esmf_atm_sbl"       # WRF SBL case
 fi
      ESMFtmp="${ESMFpre}.tmp"              # ESMF stdinp template

 if [ ${BATCH} -eq 1 ]; then
        etime=00:00:00                      # elapsed time
        ptime=${etime}                      # previous time
 else
        stime=`${DATE_EXE} -u +"%s"`        # start time (sec) since epoch
        ptime=$stime                        # previous time
 fi

#######################################################################
## Main body of script starts here. It is very unlikely that the USER
## needs to modify it.
#######################################################################

   SUBSTITUTE=${ROMS_ROOT}/ROMS/Bin/substitute   # Perl substitution
   separator1=`perl -e "print ':' x 100;"`       # title sparator
   separator2=`perl -e "print '-' x 100;"`       # run sparator

        nPETs=$(( $nPETsX * $nPETsY ))

echo
echo "${separator1}"
echo " Coupled DATA-WRF-ROMS with Split RBL4D-Var Data Assimilation:" \
       " ${ROMS_APP}"
echo "${separator1}"
echo
echo "                    ROMS Root: ${ROMS_ROOT}"
echo "            ROMS Executable A: ${ROMS_EXE_A}  (background)"
echo "            ROMS Executable B: ${ROMS_EXE_B}  (increment, post_error)"
echo "            ROMS Executable C: ${ROMS_EXE_C}  (analysis)"
echo "   ESMF/NUOPC Coupling System: DATA-WRF-ROMS"
if [ ${BULK_FLUX} -eq 1 ]; then
  echo "   Using ROMS Bulk Fluxes Parameterization"
else
  echo "   Using WRF SBL Fluxes"
fi
if [ ${RECYCLE} -eq 0 ]; then
  echo "   Keeping all WRF NetCDF files (no recycling)"
else
  echo "   Recycling WRF NetCDF file (keeping last)"
fi
echo

##---------------------------------------------------------------------
## Compute date number for reference date, and first/last
## initialization dates.
##---------------------------------------------------------------------

         S_DN=`${ROMS_ROOT}/ROMS/Bin/dates datenum ${START_DATE}`
         F_DN=`${ROMS_ROOT}/ROMS/Bin/dates datenum ${FRST_INI_DAY}`
         L_DN=`${ROMS_ROOT}/ROMS/Bin/dates datenum ${LAST_INI_DAY}`
       REF_DN=`${ROMS_ROOT}/ROMS/Bin/dates datenum ${ROMS_TIMEREF}`

echo "     Coupled 4D-Var Starting Date: ${START_DATE}  datenum = ${S_DN}"
echo " First Coupling/4D-Var Cycle Date: ${FRST_INI_DAY}  datenum = ${F_DN}"
echo " Last  Coupling/4D-Var Cycle Date: ${LAST_INI_DAY}  datenum = ${L_DN}"
echo "              ROMS Reference Date: ${ROMS_TIMEREF}  datenum = ${REF_DN}"
echo "     Coupling/4D-Var Cycle Window: ${INTERVAL} days"
echo "          Number of parallel PETs: ${nPETs}  (${nPETsX}x${nPETsY})"
echo "       Current Starting Directory: ${HereDir}"
echo "             ROMS Application CPP: ${ROMS_APP}"
echo "          Descriptor in filenames: ${roms_app}"
echo

##=====================================================================
## Loop over all 4D-Var Cycles: FRST_INI_DAY to LAST_INI_DAY
##=====================================================================

if [ ${restart} -eq 0 ]; then
  Cycle=0                               # coupled 4D-Var cycle counter
else
  EDAYS=`${ROMS_ROOT}/ROMS/Bin/dates daysdiff ${START_DATE} ${FRST_INI_DAY}`

  let "Cycle=${EDAYS} / ${INTERVAL}"    # restart cycle counter
fi

SDAY=${F_DN}                            # initialize starting day

while [ "$(bc <<< "$SDAY <= $L_DN")" == "1" ]; do

## Set coupling parameters.

          Cycle=$(( $Cycle + 1 ))              # advance cycle by one
         DSTART=$(bc <<< "$SDAY - $REF_DN")    # ROMS DSTART parameter
           EDAY=$(bc <<< "$SDAY + $INTERVAL")  # end day for 4D-Var cycle

          RDATE=`${ROMS_ROOT}/ROMS/Bin/dates numdate ${REF_DN}`
          SDATE=`${ROMS_ROOT}/ROMS/Bin/dates numdate ${SDAY}`
          EDATE=`${ROMS_ROOT}/ROMS/Bin/dates numdate ${EDAY}`
            DOY=`${ROMS_ROOT}/ROMS/Bin/dates yday ${SDATE}`
           yday=`printf %03d $DOY`

  ReferenceTime=`${DATE_EXE} -d "${RDATE}" '+%Y %m %d %H %M %S'`
      StartTime=`${DATE_EXE} -d "${SDATE}" '+%Y %m %d %H %M %S'`
       StopTime=`${DATE_EXE} -d "${EDATE}" '+%Y %m %d %H %M %S'`
    RestartTime="${StartTime}"
        Fprefix="${roms_app}"
        Fsuffix=`${DATE_EXE} -d "${SDATE}" '+%Y%m%d'`
         RunDir=`${DATE_EXE} -d "${SDATE}" '+%Y.%m.%d'`

       ROMS_INI="${ROMSini}"
        WRF_INI="${WRFini}"

  echo "${separator2}"
  echo
  echo "       Coupling/4D-Var Cycle Date: ${SDATE}  DayOfYear = ${yday}" \
                                           " Cycle = ${Cycle}"
  echo "               Data sub-directory: ${DataDir}"
  echo "                Run sub-directory: ${RunDir}"
  echo "     4D-Var number of outer loops: ${MyNouter}"
  echo "     4D-Var number of inner loops: ${MyNinner}"
  echo "      ROMS NLM trajectory writing: ${MyNHIS} NHIS timesteps"
  echo "      ROMS NLM quicksave  writing: ${MyNQCK} NQCK timesteps"
  echo "      ROMS ADM trajectory writing: ${MyNADJ} NADJ timesteps"
  echo "                      ROMS DSTART: ${DSTART}d0"
  echo "            ROMS I/O Files Prefix: ${Fprefix}"
  echo "            ROMS I/O Files Suffix: ${Fsuffix}"
  echo "               ROMS ReferenceTime: ${ReferenceTime}"
  echo "        Coupling/4D-Var StartTime: ${StartTime}"
  echo "      Coupling/4D-Var RestartTime: ${RestartTime}"
  echo "         Coupling/4D-Var StopTime: ${StopTime}"
  echo "           WRF Initial Conditions: ${WRFiniDir}/${WRF_INI}"
  echo "          ROMS Initial Conditions: ${ROMSiniDir}/${ROMS_INI}"

##---------------------------------------------------------------------
## Create run sub-directory based on cycle date (YYYY.MM.DD) and create
## ROMS standard input script from template.
##---------------------------------------------------------------------

      WRFinp=`echo ${WRFpre}.${Fsuffix}`
  ROMS_NLinp=`echo ${ROMS_NLpre}_${Fsuffix}'.in'`
  ROMS_DAinp=`echo ${ROMS_DApre}_${Fsuffix}'.in'`

  echo "              WRF namelist Script: ${WRFinp}"
  echo "    NL ROMS Standard Input Script: ${ROMS_NLinp}"
  echo "    DA ROMS Standard Input Script: ${ROMS_DAinp}"
  echo "         ROMS 4D-Var Input Script: ${Inp4DVAR}"
  echo

  if [ ${DRYRUN} -eq 1 ]; then                # if dry-run, remove run
    if [ -d ${RunDir} ]; then                 # sub-directory if exist
      /bin/rm -rf ${RunDir}
    fi
  fi

  if [ ! -d ./${RunDir} ]; then
    mkdir ${RunDir}
    echo "Cycle ${Cycle}, Creating run sub-directory: ${RunDir}"
    echo "  Creating WRF data links in sub-directory: ${RunDir}"
    echo
    find . -maxdepth 1 -type l -exec /bin/cp -PRfv {} ${RunDir} \;
    echo
  fi

  echo "Changing to directory: ${HereDir}/${RunDir}"
  echo

  cd ${RunDir}

  echo "                Creating WRF namelist Script: ${WRFinp}"

  if [ -e ${WRFinp} ]; then
    /bin/rm ${WRFinp}
  fi
  cp -f ../${WRFtmp} ${WRFinp}

  str=()                                      # WRF startin simulation time
  i=0                                         # integer vector
  for element in ${StartTime// / }; do        # (YYYY MM DD hh mm ss)
    str[$i]=${element}
    ((i=$i+1))
  done

  end=()                                      # WRF end simulation time
  i=0                                         # integer vector 
  for element in ${StopTime// / }; do         # (YYYY MM DD hh mm ss)
    end[$i]=${element}
    ((i=$i+1))
  done

  rhh=$(bc <<< "${INTERVAL} * 24")            # WRF running time (hours)
  run_hours=${rhh%.*}                         # convert to interger

  Wprefix="${DataDir}/WRF/${Fprefix}_wrf"     # WRF input file prefix

  $SUBSTITUTE ${WRFinp} RDD         "0"
  $SUBSTITUTE ${WRFinp} Rhh         "${run_hours}"
  $SUBSTITUTE ${WRFinp} Rmm         "0"
  $SUBSTITUTE ${WRFinp} Rss         "0"
  $SUBSTITUTE ${WRFinp} SYYYY       "${str[0]}"
  $SUBSTITUTE ${WRFinp} SMM         "${str[1]}"
  $SUBSTITUTE ${WRFinp} SDD         "${str[2]}"
  $SUBSTITUTE ${WRFinp} Shh         "${str[3]}"
  $SUBSTITUTE ${WRFinp} Smm         "${str[4]}"
  $SUBSTITUTE ${WRFinp} Sss         "${str[5]}"
  $SUBSTITUTE ${WRFinp} EYYYY       "${end[0]}"
  $SUBSTITUTE ${WRFinp} EMM         "${end[1]}"
  $SUBSTITUTE ${WRFinp} EDD         "${end[2]}"
  $SUBSTITUTE ${WRFinp} Ehh         "${end[3]}"
  $SUBSTITUTE ${WRFinp} Emm         "${end[4]}"
  $SUBSTITUTE ${WRFinp} Ess         "${end[5]}"
  $SUBSTITUTE ${WRFinp} MyMaxDom    "${NnestWRF}"
  $SUBSTITUTE ${WRFinp} MyInpName   "${Wprefix}_inp_d<domain>_${Fsuffix}.nc"
  $SUBSTITUTE ${WRFinp} MyBryName   "${Wprefix}_bdy_d<domain>_${Fsuffix}.nc"
  $SUBSTITUTE ${WRFinp} MySSTname   "${Wprefix}_sst_d<domain>_${Fsuffix}.nc"
  $SUBSTITUTE ${WRFinp} MyHisName   "${Fprefix}_wrf_his_d<domain>_${Fsuffix}.nc"
  $SUBSTITUTE ${WRFinp} MyRstName   "${Fprefix}_wrf_rst_d<domain>_${Fsuffix}.nc"
  $SUBSTITUTE ${WRFinp} MyAvgName   "${Fprefix}_wrf_avg_d<domain>_${Fsuffix}.nc"
  $SUBSTITUTE ${WRFinp} MyIOfields  "${DataDir}/WRF/iofields_list.txt"

  echo "      Creating NL ROMS Standart Input Script: ${ROMS_NLinp}"

  if [ -f ${ROMS_NLinp} ]; then
    /bin/rm ${ROMS_NLinp}
  fi
  cp -f ../${ROMS_NLtmp} ${ROMS_NLinp}

  $SUBSTITUTE ${ROMS_NLinp} MyNtileI  ${nPETsX}
  $SUBSTITUTE ${ROMS_NLinp} MyNtileJ  ${nPETsY}
  $SUBSTITUTE ${ROMS_NLinp} MyNouter  ${MyNouter}
  $SUBSTITUTE ${ROMS_NLinp} MyNinner  ${MyNinner}
  $SUBSTITUTE ${ROMS_NLinp} MyNHIS    ${MyNHIS}
  $SUBSTITUTE ${ROMS_NLinp} MyNDEFHIS ${MyNDEFHIS}
  $SUBSTITUTE ${ROMS_NLinp} MyNQCK    ${MyNQCK}
  $SUBSTITUTE ${ROMS_NLinp} MyNTLM    ${MyNTLM}
  $SUBSTITUTE ${ROMS_NLinp} MyNADJ    ${MyNADJ}
  $SUBSTITUTE ${ROMS_NLinp} MyNRREC   ${MyNRREC}
  $SUBSTITUTE ${ROMS_NLinp} MyDSTART  "${DSTART}d0"
  $SUBSTITUTE ${ROMS_NLinp} MyFprefix "${Fprefix}"
  $SUBSTITUTE ${ROMS_NLinp} MyFsuffix "${Fsuffix}"
  $SUBSTITUTE ${ROMS_NLinp} MyININAME "${ROMS_INI}"
  $SUBSTITUTE ${ROMS_NLinp} MyAPARNAM "${Inp4DVAR}"

  echo "      Creating DA ROMS Standart Input Script: ${ROMS_DAinp}"

  if [ -f ${ROMS_DAinp} ]; then
    /bin/rm ${ROMS_DAinp}
  fi
  cp -f ../${ROMS_DAtmp} ${ROMS_DAinp}

  $SUBSTITUTE ${ROMS_DAinp} MyNtileI  ${nPETsX}
  $SUBSTITUTE ${ROMS_DAinp} MyNtileJ  ${nPETsY}
  $SUBSTITUTE ${ROMS_DAinp} MyNouter  ${MyNouter}
  $SUBSTITUTE ${ROMS_DAinp} MyNinner  ${MyNinner}
  $SUBSTITUTE ${ROMS_DAinp} MyNHIS    ${MyNHIS}
  $SUBSTITUTE ${ROMS_DAinp} MyNDEFHIS ${MyNDEFHIS}
  $SUBSTITUTE ${ROMS_DAinp} MyNQCK    ${MyNQCK}
  $SUBSTITUTE ${ROMS_DAinp} MyNTLM    ${MyNTLM}
  $SUBSTITUTE ${ROMS_DAinp} MyNADJ    ${MyNADJ}
  $SUBSTITUTE ${ROMS_DAinp} MyDSTART  "${DSTART}d0"
  $SUBSTITUTE ${ROMS_DAinp} MyFprefix "${Fprefix}"
  $SUBSTITUTE ${ROMS_DAinp} MyFsuffix "${Fsuffix}"
  $SUBSTITUTE ${ROMS_DAinp} MyININAME "${ROMS_INI}"
  $SUBSTITUTE ${ROMS_DAinp} MyAPARNAM "${Inp4DVAR}"

  ESMFinp=`echo ${ESMFpre}_${Fsuffix}'.in'`

  echo "                        ESMF Coupling Script: ${ESMFinp}"

  if [ -e ${ESMFinp} ]; then
    /bin/rm ${ESMFinp}
  fi
  cp -f ../${ESMFtmp} ${ESMFinp}

  $SUBSTITUTE ${ESMFinp} MyROMSscript    "${ROMS_NLinp}"
  $SUBSTITUTE ${ESMFinp} MyWRFscript     "${WRFinp}"
  $SUBSTITUTE ${ESMFinp} MyItileD        ${nPETsXdata}
  $SUBSTITUTE ${ESMFinp} MyJtileD        ${nPETsYdata}
  $SUBSTITUTE ${ESMFinp} MyPETsROMS      ${nPETs}
  $SUBSTITUTE ${ESMFinp} MyPETsATM       ${nPETs}
  $SUBSTITUTE ${ESMFinp} MyReferenceTime "${ReferenceTime}"
  $SUBSTITUTE ${ESMFinp} MyStartTime     "${StartTime}"
  $SUBSTITUTE ${ESMFinp} MyRestartTime   "${RestartTime}"
  $SUBSTITUTE ${ESMFinp} MyStopTime      "${StopTime}"

  echo

##---------------------------------------------------------------------
## Run 4D-Var for the current time window
##---------------------------------------------------------------------

  OuterLoop=0                        # initialize outer loop counter
  Phase4DVAR="background"            # initialize 4D-Var phase

## Set observations NetCDF filename.

  OBSname="${Fprefix}_obs_${Fsuffix}.nc"

## Copy ROMS nonlinear model initial conditions file.

  echo "   Copying NLM IC file ${ROMSiniDir}/${ROMS_INI}  as  ${ROMS_INI}"

  cp ${ROMSiniDir}/${ROMS_INI} ${ROMS_INI}
  chmod u+w ${ROMS_INI}                          # change protection

## Get a clean copy of the observation file.  This is really important
## since this file will be modified.

  echo "   Copying OBS file ${DataDir}/${OBSname}  as  ${OBSname}"

  cp ${DataDir}/OBS/${OBSname} .
  chmod u+w ${OBSname}                           # change protection

## Set WRF files links.

  ln -sf ${WRFinp} namelist.input

## Set ROMS executable file links.

  if [ "$ROMS_EXE_A" = "$ROMS_EXE_B" ]; then
    ln -sf "../${ROMS_EXE_A}" .
  else
    ln -sf "../${ROMS_EXE_A}" .
    ln -sf "../${ROMS_EXE_B}" .
  fi

  if [ ${BATCH} -eq 1 ]; then
    EXECUTE_A="${SRUN} ${ROMS_EXE_A} ${ESMFinp}"
    EXECUTE_B="${SRUN} ${ROMS_EXE_B} ${ROMS_DAinp}"
    if [ ${ANA_COUPLED} -eq 1 ]; then
      EXECUTE_C="${SRUN} ${ROMS_EXE_C} ${ESMFinp}"
    else
      EXECUTE_C="${SRUN} ${ROMS_EXE_C} ${ROMS_NLinp}"
    fi
  else
    EXECUTE_A="${MPIrun} ${nPETs} ${ROMS_EXE_A} ${ESMFinp}"
    EXECUTE_B="${MPIrun} ${nPETs} ${ROMS_EXE_B} ${ROMS_DAinp}"
    if [ ${ANA_COUPLED} -eq 1 ]; then
      EXECUTE_C="${MPIrun} ${nPETs} ${ROMS_EXE_C} ${ESMFinp}"
    else
      EXECUTE_C="${MPIrun} ${nPETs} ${ROMS_EXE_C} ${ROMS_NLinp}"
    fi
  fi

## Run 4D-Var 'background' phase ......................................

  echo
  echo "Running 4D-Var System:  Cycle = ${Cycle}" \
                             "  Outer = ${OuterLoop}" \
                             "  Phase = ${Phase4DVAR}"

## Create ROMS 4D-Var input script 'rbl4dvar.in' from template.

  My4DVarScript ${DataDir} ${SUBSTITUTE} ${OuterLoop} ${Phase4DVAR} \
                ${OBSname} ${Fprefix} ${Fsuffix} ${Inp4DVAR}

  echo "   ${EXECUTE_A}"

  if [ ${DRYRUN} -eq 0 ]; then

    if [ ${BATCH} -eq 1 ]; then
      ${SRUN} ${ROMS_EXE_A} ${ESMFinp} > log.wrf 2>&1
    else
      ${MPIrun} ${nPETs} ${ROMS_EXE_A} ${ESMFinp} > log.wrf 2>&1
    fi

    if [ $? -ne 0 ] ; then
      echo
      echo "Error while running 4D-Var System:  Cycle = ${Cycle}" \
                                             "  Outer = ${OuterLoop}" \
                                             "  Phase = ${Phase4DVAR}"
      echo "Check ${RunDir}/log.roms for details ..."
      exit 1
    fi
  fi

## Rename log files. If requested, rename WRF history NetCDF files to
## keep it. Otherwise, it will be recycled and lost.

  if [ ${DRYRUN} -eq 0 ]; then
                                   # Keeping WRF history NetCDF files
    if [ ${RECYCLE} -eq 0 ]; then
      for hisfile in ${Fprefix}_wrf_his_d*; do
        hisbase=`basename $hisfile .nc`
        mv -fv ${hisfile} ${hisbase}_outer${OuterLoop}.nc
      done
    fi

    mv log.wrf log${OuterLoop}.wrf
    mv log.coupler log${OuterLoop}.coupler
    mv log.esmf log${OuterLoop}.esmf
  fi

## Start 4D-Var outer loops :::::::::::::::::::::::::::::::::::::::::::

  while [ $OuterLoop -lt $MyNouter ]; do

    OuterLoop=$(( $OuterLoop + 1 ))

## Run 4D-Var 'increment' phase .......................................

    Phase4DVAR="increment"

    echo
    echo "Running 4D-Var System:  Cycle = ${Cycle}" \
                               "  Outer = ${OuterLoop}" \
                               "  Phase = ${Phase4DVAR}"

    My4DVarScript ${DataDir} ${SUBSTITUTE} ${OuterLoop} ${Phase4DVAR} \
                  ${OBSname} ${Fprefix} ${Fsuffix} ${Inp4DVAR}

    echo "   ${EXECUTE_B}"

    if [ ${DRYRUN} -eq 0 ]; then

      if [ ${BATCH} -eq 1 ]; then
        ${SRUN} ${ROMS_EXE_B} ${ROMS_DAinp} > err
      else
        ${MPIrun} ${nPETs} ${ROMS_EXE_B} ${ROMS_DAinp} > err
      fi

      if [ $? -ne 0 ] ; then
        echo
        echo "Error while running 4D-Var System:  Cycle = ${Cycle}" \
                                               "  Outer = ${OuterLoop}" \
			                       "  Phase = ${Phase4DVAR}"
        echo "Check ${RunDir}/log.roms for details ..."
        exit 1
      fi
    fi

## Run 4D-Var 'analysis' phase ........................................

    Phase4DVAR="analysis"

    echo
    echo "Running 4D-Var System:  Cycle = ${Cycle}" \
                               "  Outer = ${OuterLoop}" \
			       "  Phase = ${Phase4DVAR}"

    My4DVarScript ${DataDir} ${SUBSTITUTE} ${OuterLoop} ${Phase4DVAR} \
                  ${OBSname} ${Fprefix} ${Fsuffix} ${Inp4DVAR}

    echo "   ${EXECUTE_C}"

    if [ ${DRYRUN} -eq 0 ]; then

      mv log.roms log$(( $OuterLoop - 1 )).roms    # rename current log.roms
      touch log.roms

      if [ ${BATCH} -eq 1 ]; then
        if [ ${ANA_COUPLED} -eq 1 ]; then
          ${SRUN} ${ROMS_EXE_A} ${ESMFinp} >> log.wrf 2>&1
        else
          ${SRUN} ${ROMS_EXE_C} ${ROMS_NLinp} >> err
        fi
      else
        if [ ${ANA_COUPLED} -eq 1 ]; then
          ${MPIrun} ${nPETs} ${ROMS_EXE_A} ${ESMFinp} >> log.wrf 2>&1
        else
          ${MPIrun} ${nPETs} ${ROMS_EXE_C} ${ROMS_NLinp} >> err
        fi
      fi

      if [ $? -ne 0 ] ; then
        echo
        echo "Error while running 4D-Var System:  Cycle = ${Cycle}" \
                                               "  Outer = ${OuterLoop}" \
			                       "  Phase = ${Phase4DVAR}"
        echo "Check ${RunDir}/log.roms for details ..."
        exit 1
      fi
    fi

## Rename log files. If requested, rename WRF history NetCDF file to keep
## it. Otherwise, its name will be recycle in the coupled 4D-Var algorithm.

    if [ ${DRYRUN} -eq 0 ]; then
      if [ ${ANA_COUPLED} -eq 1 ]; then

#       if [ ${RECYCLE} -eq 0 ]; then            # Keeping all NetCDf files
#         mv ${WRF_INI} wrf_${CDTG}_outer${OuterLoop}.nc
#       fi

        mv log.wrf log${OuterLoop}.wrf
        mv log.coupler log${OuterLoop}.coupler
        mv log.esmf log${OuterLoop}.esmf
      fi
    fi

## End of outer loops :::::::::::::::::::::::::::::::::::::::::::::::::

  done

  if [ ${DRYRUN} -eq 0 ]; then
    mv log.roms log${OuterLoop}.roms          # rename current log.roms
  fi

## Compute 4D-Var analysis posterior error covariance .................
##
## If POSTERIOR_ERROR_I or and POSTERIOR_ERROR_F are activated in
## ROMS Executable B.

  if [ ${POSTERIOR} -eq 1 ]; then

    Phase4DVAR="post_error"

    echo
    echo "Running 4D-Var System:  Cycle = ${Cycle}" \
                               "  Phase = ${Phase4DVAR}"

    My4DVarScript ${DataDir} ${SUBSTITUTE} ${OuterLoop} ${Phase4DVAR} \
                  ${OBSname} ${Fprefix} ${Fsuffix} ${Inp4DVAR}

    echo "   ${EXECUTE_B}"

    if [ ${DRYRUN} -eq 0 ]; then

      touch log.roms

      if [ ${BATCH} -eq 1 ]; then
        ${SRUN} ${ROMS_EXE_B} ${ROMS_DAinp} > err
      else
        ${MPIrun} ${nPETs} ${ROMS_EXE_B} ${ROMS_DAinp} > err
      fi

      if [ $? -ne 0 ] ; then
        echo
        echo "Error while running 4D-Var System:  Cycle = ${Cycle}" \
			                       "  Phase = ${Phase4DVAR}"
        echo "Check ${RunDir}/log.roms for details ..."
        exit 1
      fi
    fi
  fi

##---------------------------------------------------------------------
## Advance to the next Coupling/4D-Var cycle, if any.
##---------------------------------------------------------------------

  echo

  if [ ${BATCH} -eq 1 ]; then
    etime=`sacct -n -X -j $SLURM_JOBID --format=Elapsed | sed 's/-/ days /'`
    ptime_sec=$(date -u -d "$ptime" +"%s")
    etime_sec=$(date -u -d "$etime" +"%s")
    time_diff=`date -u -d "0 ${etime_sec} sec - ${ptime_sec} sec" +"%H:%M:%S"`
    ptime=$etime
  else
    now=`${DATE_EXE} -u +"%s"`
    time_diff=`${DATE_EXE} -u -d "0 ${now} sec - ${ptime} sec" +"%H:%M:%S"`
    ptime=$now
  fi

  echo "Finished Coupled 4D-Var Cycle ${Cycle},  Elapsed time = $time_diff"

  find ./ -type l -exec /bin/rm -f {} \;          # remove all WRF data file
                                                  # links
  echo
  echo "Changing to directory: ${HereDir}"

  cd ../                                          # go back to start directory

  SDAY=$(bc <<< "${SDAY} + ${INTERVAL}")

  ROMSini="${Fprefix}_roms_dai_${Fsuffix}.nc"     # new ROMS IC (DAI file)
  ROMSiniDir="../${RunDir}"                       # new ROMS IC directory

  echo

## End of Coupling/4D-Var cycle.

done

## Done with computations.

if [ ${BATCH} -eq 1 ]; then
  total_time=`sacct -n -X -j $SLURM_JOBID --format=Elapsed`
else
  days=$(( (${ptime} - ${stime}) / 86400 ))
  hms=`${DATE_EXE} -u -d "0 ${ptime} sec - ${stime} sec" +"%H:%M:%S"`

  if (( ${days} == 0 )); then
    total_time=$hms
  else
    total_time="${days}-${hms}"
  fi
fi

echo "Finished computations, Total time = $total_time"

exit 0
