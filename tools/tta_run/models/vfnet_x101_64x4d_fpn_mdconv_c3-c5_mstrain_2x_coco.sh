#!/usr/bin/env bash
set -e
export CUDA_VISIBLE_DEVICES=0
export PYTHONPATH="$(dirname $0)/..":$PYTHONPATH

if [[ ! -e ./cache ]]; then
    mkdir ./cache
fi

if [ -z "$1" ]; then
    echo "No videos path specified"
    exit 0
fi

if [ -z "$2" ]; then
    echo "No output path specified"
    exit 0
fi

model_name="vfnet_x101_64x4d_fpn_mdconv_c3-c5_mstrain_2x_coco"
CFG="configs/ccdet/coco/vfnet_x101_64x4d_fpn_mdconv_c3-c5_mstrain_2x_coco.py"
CKPT="https://download.openmmlab.com/mmdetection/v2.0/vfnet/vfnet_x101_64x4d_fpn_mdconv_c3-c5_mstrain_2x_coco/vfnet_x101_64x4d_fpn_mdconv_c3-c5_mstrain_2x_coco_20201027pth-b5f6da5e.pth"

TEMP_OUT_CFG="$2/${model_name}_cfg.py"
python tools/create_tta_cfg_det.py --cfg $CFG --out $TEMP_OUT_CFG

# DET_CACHE="cache/full_video_pkl/${model_name}"
OUT_DIR="$2/${model_name}"

VIDEO_DIR=$1
for VIDEO in $VIDEO_DIR/*mp4; do
    python tools/infer_det_video.py --cfg $TEMP_OUT_CFG --ckpt $CKPT \
        --det-thr 0.15 --video $VIDEO --out-dir $OUT_DIR \
        --save-pred --coco-filter
done