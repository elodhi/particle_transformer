#!/bin/bash

set -x

source env.sh

echo "args: $@"

# set the dataset dir via `DATADIR_QuarkGluon`
#DATADIR=${DATADIR_QuarkGluon_h5}
DATADIR='/data/elodhi'
[[ -z $DATADIR ]] && DATADIR='./datasets/QuarkGluon_h5'

# set a comment via `COMMENT`
suffix=${COMMENT}

# PN, PFN, PCNN, ParT
model=$1
extraopts=""
if [[ "$model" == "ParT" ]]; then
    modelopts="networks/example_ParticleTransformer-modified.py --use-amp --optimizer-option weight_decay 0.01"
    lr="1e-3"
elif [[ "$model" == "ParT-FineTune" ]]; then
    modelopts="networks/example_ParticleTransformer_finetune.py --use-amp --optimizer-option weight_decay 0.01"
    lr="1e-4"
    extraopts="--optimizer-option lr_mult (\"fc.*\",50) --lr-scheduler none"
elif [[ "$model" == "PN" ]]; then
    modelopts="networks/example_ParticleNet.py"
    lr="1e-2"
elif [[ "$model" == "PN-FineTune" ]]; then
    modelopts="networks/example_ParticleNet_finetune.py"
    lr="1e-3"
    extraopts="--optimizer-option lr_mult (\"fc_out.*\",50) --lr-scheduler none"
elif [[ "$model" == "PFN" ]]; then
    modelopts="networks/example_PFN.py"
    lr="2e-2"
    extraopts="--batch-size 4096"
elif [[ "$model" == "PCNN" ]]; then
    modelopts="networks/example_PCNN.py"
    lr="2e-2"
    extraopts="--batch-size 4096"
else
    echo "Invalid model $model!"
    exit 1
fi

# "kin", "kinpid", "kinpidplus"
FEATURE_TYPE=$2
[[ -z ${FEATURE_TYPE} ]] && FEATURE_TYPE="kinpid"

if [[ "${FEATURE_TYPE}" == "kin" ]]; then
    pretrain_type="kin"
elif [[ "${FEATURE_TYPE}" =~ ^(kinpid|kinpidplus)$ ]]; then
    pretrain_type="kinpid"
else
    echo "Invalid feature type ${FEATURE_TYPE}!"
    exit 1
fi

if [[ "$model" == "ParT-FineTune" ]]; then
    modelopts+=" --load-model-weights models/ParT_${pretrain_type}.pt"
fi
if [[ "$model" == "PN-FineTune" ]]; then
    modelopts+=" --load-model-weights models/ParticleNet_${pretrain_type}.pt"
fi

weaver \
    --data-train "/data/elodhi/topotowers/user.gwmyers.364703.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237078._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364704.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237076._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364705.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237071._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364706.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237072._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364707.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237079._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364708.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237075._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364709.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237073._000001.output.h5" "/data/elodhi/topotowers/user.gwmyers.364710.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237083._000001.output.h5" \
    --data-test "/data/elodhi/topotowers/user.gwmyers.364703.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237078._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364704.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237076._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364705.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237071._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364706.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237072._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364707.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237079._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364708.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237075._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364709.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237073._000002.output.h5" "/data/elodhi/topotowers/user.gwmyers.364710.e7142_s3681_r13145_p5489.tdd.jetm2_flow.24_2_31.24-02-08_qg_v1_output.h5/user.gwmyers.37237083._000002.output.h5" \
    --data-fraction 0.08 \
    --data-config data/QuarkGluon/qg_${FEATURE_TYPE}_towers.yaml --network-config $modelopts \
    --model-prefix training/QuarkGluon_h5/${model}/{auto}${suffix}/net \
    --train-val-split 0.8 \
    --batch-size 300 --num-epochs 5 --gpus 1 \
    --start-lr $lr --optimizer ranger --log logs/QuarkGluon_h5_towers_${model}_{auto}${suffix}.log --predict-output pred.root \
    --tensorboard QuarkGluon_h5_${FEATURE_TYPE}_${model}${suffix} \
    ${extraopts} "${@:3}"

# Used when you would like to load the whole dataset into memory, instead of loading it via iterations:
    #--in-memory --fetch-step 1 --steps-per-epoch 10557 
