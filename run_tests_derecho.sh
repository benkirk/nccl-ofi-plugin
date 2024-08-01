#!/bin/bash
#PBS -A SCSG0001
#PBS -q main
#PBS -l select=2:ncpus=64:mpiprocs=4:ngpus=4
#PBS -l walltime=0:30:00
#PBS -j oe

# build plugin & tests if necessary
[ -f install/lib/libnccl.so ] || { echo " Building nccl-ofi-plugin..."; ./build_derecho.sh > build_derecho.log; }

source env_nccl_derecho.sh || exit 1

#export NCCL_DEBUG=WARN
export NCCL_DEBUG=INFO
unset CUDA_VISIBLE_DEVICES

echo && echo && echo
env
echo && echo && echo

echo "nvidia-smi:"
nvidia-smi



echo && echo && echo
ldd nccl-tests/build/all_reduce_perf || exit 1
echo && echo && echo



echo "========== RUNNING NCCL TESTS =========="
mpi_args="--cpu-bind numa"
exe_args="-b 512K -e 8G -f 4"
for exe in nccl-tests/build/{all*_perf,sendrecv_perf}; do

    testname=$(basename ${exe})
    logfile=${testname}.log.${PBS_JOBID}

    echo && echo && echo

    echo "# --> Intra-node (2GPUs)" | tee -a ${logfile}
    cmd="mpiexec ${mpi_args} -n 2 -ppn 2 ${exe} ${exe_args}"
    echo "# --> ${cmd}" | tee -a ${logfile}
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# --> Inter-node (2GPUs)" | tee -a ${logfile}
    cmd="mpiexec ${mpi_args} -n 2 -ppn 1 ${exe} ${exe_args}"
    echo "# --> ${cmd}" | tee -a ${logfile}
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# --> Intra-node (4GPUs)" | tee -a ${logfile}
    cmd="mpiexec ${mpi_args} -n 4 -ppn 4 ${exe} ${exe_args}"
    echo "# --> ${cmd}" | tee -a ${logfile}
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# --> Inter-node (4GPUs)" | tee -a ${logfile}
    cmd="mpiexec ${mpi_args} -n 4 -ppn 2 ${exe} ${exe_args}"
    echo "# --> ${cmd}" | tee -a ${logfile}
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# --> Inter-node (8 GPUs)" | tee -a ${logfile}
    cmd="mpiexec ${mpi_args} -n 8 -ppn 4 ${exe} ${exe_args}"
    echo "# --> ${cmd}" | tee -a ${logfile}
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"
    echo && echo && echo

done
