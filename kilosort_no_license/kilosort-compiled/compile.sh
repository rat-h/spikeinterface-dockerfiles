#!/bin/bash
set -e

if [ $# == 0 ]; then
    echo "Usage: $0 param1 param2"
    echo "* param1: KiloSort path"
    echo "* param2: spikeinterface path"
    exit
fi

if [ $# -ne 2 ]; then
    echo "spikeinterface and kilosort path must be given"
    exit 1
fi

KS_COMPILED_NAME="ks_compiled"
KS_PATH=${1%/}
SI_PATH=${2%/}
WORK_DIR=$(pwd)
SOURCE_DIR=$( dirname -- "$0"; )
TMP_DIR=$SOURCE_DIR/tmp

echo "kilosort path: $KS_PATH"
echo "spike-interface path: $SI_PATH"

echo "Compiling CUDA files"
cd $KS_PATH/CUDA
matlab -batch "mexGPUall"

echo "Creating tmp folder: $TMP_DIR"
cd $WORK_DIR
mkdir -p $TMP_DIR

echo "Compiling kilosort_master..."
cd $TMP_DIR
matlab -batch "mcc -m $SI_PATH/spikeinterface/sorters/kilosort/kilosort_master.m -a $SI_PATH/spikeinterface/sorters/utils -a $KS_PATH -o ${KS_COMPILED_NAME}"

echo "Creating base docker image..."
matlab -batch "compiler.package.docker('${KS_COMPILED_NAME}', 'requiredMCRProducts.txt', 'ImageName', 'ks-matlab-base')"

cd $WORK_DIR
rm -r $TMP_DIR
