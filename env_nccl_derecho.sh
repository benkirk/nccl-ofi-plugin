# Source this script in your shifter container
# to pull in NCCL with the OFI plugin
module reset >/dev/null 2>&1
module load nvhpc/24.3 cuda/12.2.1 >/dev/null 2>&1
module list

export MPICH_OFI_NIC_POLICY=GPU

unset CUDA_VISIBLE_DEVICES

export NCCL_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/install"
export LD_LIBRARY_PATH=$NCCL_HOME/lib:$NCCL_HOME/plugin/lib:$NCCL_HOME/plugin/deps/lib:$LD_LIBRARY_PATH

export FI_CXI_DISABLE_HOST_REGISTER=1
export NCCL_CROSS_NIC=1
export NCCL_SOCKET_IFNAME=hsn
export NCCL_NET_GDR_LEVEL=PHB
export NCCL_NET="AWS Libfabric"
