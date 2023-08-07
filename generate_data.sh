#!/bin/bash
echo "------------ start --------"
root_path=/nfs/wsi/es/hannah/datasets/test/seiz_bckg/
proj_path=/home/schreiner/projects/GGN/GGN

k=$1
if [ ! -n "$k" ];then
    k="train"
fi

echo $k
pid=$(ps -ef | grep seizure | grep -v grep | awk '{print $2}')
if [ -n "$pid" ]; then
    echo "running seizure: $pid" 
    kill -9 $pid
    echo "killed!"
fi

if [ $k = "kill" ]; then
    echo "only kill seizure process"
    exit 1
fi

# TUH:
echo "start running tuh eeg_train!"

ulimit -v 4294967296

training_tag=training_default_ggn

python -u $proj_path/eeg_main.py \
--seed=1992 \
--em_train \
--task=generate_data \
--runs=10 \
--batch_size=16 \
--epochs=100 \
--weighted_ce=prop \
--lr=0.00005 \
--dropout=0.6 \
--predict_class_num=9 \
--server_tag=seizure \
--data_path=$root_path/fft/ \
--dataset=TUH \
--adj_file=$proj_path/adjs/raw_adj.npy \
--adj_type=origin \
--feature_len=244 \
--cuda \
--encoder=rnn \
--bidirect \
--encoder_hid_dim=256 \
--cut_encoder_dim=0 \
--decoder=lgg_cnn \
--decoder_hid_dim=512 \
--decoder_out_dim=32 \
--lgg_warmup=5 \
--lgg_tau=0.01 \
--lgg_hid_dim=64 \
--lgg_k=5 \
--lgg \
--gnn_pooling=gate \
--agg_type=gate \
--gnn_hid_dim=32 \
--gnn_out_dim=16 \
--gnn_layer_num=2 \
--max_diffusion_step=2 \
--fig_filename=$proj_path/figs/$training_tag \
--best_model_save_path=$proj_path/best_models/$training_tag.pth \

