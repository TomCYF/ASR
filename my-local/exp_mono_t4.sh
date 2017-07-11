#! /bin/bash

[ -f ./path.sh ] && . ./path.sh

num_gauss=9700

for dir in train test; do
    steps/make_mfcc.sh data/$dir\_words exp/make_mfcc/$dir mfcc
    
    steps/compute_cmvn_stats.sh data/$dir\_words exp/compute_cmvn_stats/$dir cmvn
done

start_time=$(date +%s)
my-local/train_mono_cmvn.sh --nj 4 --totgauss $num_gauss --cmvn-opts "--norm-vars=true" data/train_words data/lang_wsj exp/mono

utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/mono exp/mono/graph

steps/decode.sh --nj 4 exp/mono/graph data/test_words exp/mono/decode_test

end_time=$(date +%s)
local/score_words.sh data/test_words exp/mono/graph \
	exp/mono/decode_test
more exp/mono/decode_test/scoring_kaldi/best_wer >> result.t4

echo 'time ' $(($end_time - $start_time)) >> result.t4
