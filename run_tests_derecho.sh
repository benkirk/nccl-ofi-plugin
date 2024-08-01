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
args="-b 512K -e 8G -f 4"
for exe in nccl-tests/build/{all*_perf,sendrecv_perf}; do

    testname=$(basename ${exe})
    logfile=${testname}.log.${PBS_JOBID}

    echo && echo && echo

    echo "# Intra-node (2GPUs)"
    cmd="mpiexec -n 2 -ppn 2 ${exe} ${args}"
    echo "# ${cmd}"
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# Inter-node (2GPUs)"
    cmd="mpiexec -n 2 -ppn 1 ${exe} ${args}"
    echo "# ${cmd}"
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# Intra-node (4GPUs)"
    cmd="mpiexec -n 4 -ppn 4 ${exe} ${args}"
    echo "# ${cmd}"
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# Inter-node (4GPUs)"
    cmd="mpiexec -n 4 -ppn 2 ${exe} ${args}"
    echo "# ${cmd}"
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"

    echo "# Inter-node (8 GPUs)"
    cmd="mpiexec -n 8 -ppn 4 ${exe} ${args}"
    echo "# ${cmd}"
    echo "# --> BEGIN execution (${exe})"
    eval ${cmd} | tee -a ${logfile}
    echo "# --> END execution (${exe})"
    echo && echo && echo


done

# mpiexec -n 8 -ppn 4 nccl-tests/build/all_reduce_perf -b 8 -e 4G -f 2
# mpiexec -n 8 -ppn 4 nccl-tests/build/alltoall_perf -b 8 -e 4G -f 2
