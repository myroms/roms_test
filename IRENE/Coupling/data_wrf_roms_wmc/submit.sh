#!/bin/bash

##  SLURM batch script to submit jobs to amarel:
##
##  Use 'sbatch submit.bash' to queue the job
##  Use 'squeue -p PARTITION'         to check your group jobs (including JOBID)
##  Use 'scancel JOBID'               to cancel a job

#SBATCH --exclusive                  # don't run on nodes with other jobs running
#SBATCH --partition=???              # Partition (job queue)
#SBATCH --requeue                    # Return job to the queue if preempted
#SBATCH --job-name=WRF-ROMS-IRENE    # Assign an short name to your job
#SBATCH --nodes=1                    # Number of nodes you require (each has 32 PETs)
#SBATCH --ntasks=32                  # Total number of tasks you'll launch
#SBATCH --ntasks-per-node=32         # Number of tasks you'll launch on each node
#SBATCH --cpus-per-task=1            # Cores per task (>1 if multithread tasks)
#SBATCH --mem=177000                 # Real memory (RAM) required (MB)
#SBATCH --time=00-04:00:00           # Total run time limit (DD-HH:MM:SS)
#SBATCH --output=log.%j              # STDOUT output file
#SBATCH --error=err.%j               # STDERR output file (optional)
#SBATCH --export=ALL                 # Export you current env to the job env

##---------------------------------------------------------------------
## Control switches: What do you want to do?
##---------------------------------------------------------------------

        BATCH=0                # No batch system submission
#       BATCH=1                # Use batch system SLURM to submit

    BULK_FLUX=0                # Use atmospheric model SBL formulation
#   BULK_FLUX=1                # Use ROMS bulk fluxes formulation

     ROMS_EXE="romsM"          # ROMS executable


if [ ${BATCH} -eq 1 ]; then
         SRUN="srun --mpi=pmi2"         # SLURM workload manager
else
        nPETs=32                        # number of processes
       MPIrun="mpirun -np"              # Basic MPI workload manager
fi


if [ ${BULK_FLUX} -eq 1 ]; then
      ESMFpre="coupling_esmf_bulk_flux.in"   # ROMS BULK_FLUXES case
else
      ESMFpre="coupling_esmf_atm_sbl.in"     # WRF SBL case
fi

## If using 'gfortran', uncomment the following environmental variable:

# export GFORTRAN_CONVERT_UNIT='big_endian'

##---------------------------------------------------------------------
## Run coupled system
##---------------------------------------------------------------------

if [ ${BATCH} -eq 1 ]; then
   ${SRUN} ${ROMS_EXE} ${ESMFinp} > log.wrf 2>&1
else
   ${MPIrun} ${nPETs} ${ROMS_EXE} ${ESMFinp} > log.wrf 2>&1
fi

exit 0
