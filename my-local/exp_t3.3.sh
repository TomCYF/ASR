#! /bin/bash

[ -f ./path.sh ] && . ./path.sh


# extract features
for dir in train test; do
    steps/make_mfcc.sh data/$dir\_words exp/make_mfcc/$dir mfcc
    # compute cmvn
    steps/compute_cmvn_stats.sh data/$dir\_words exp/compute_cmvn_stats/$dir cmvn
done

start_time=$(date +%s)
# train monophone
steps/train_sat.sh 4500 15000 data/train_words data/lang_wsj exp/word/mono_ali exp/word/tri1
# create graph
utils/mkgraph.sh data/lang_wsj_test_bg exp/word/tri1 exp/word/tri1/graph
# decoding
steps/decode_fmllr.sh --nj 4 exp/word/tri1/graph data/test_words exp/word/tri1/decode_test
# generate the results
echo 'Exp: num_gauss = 15000 num_cluster = 4500' $num_gauss >> result.t3.3
local/score_words.sh data/test_words exp/word/tri1/graph exp/word/tri1/decode_test

end_time=$(date +%s)
more exp/word/tri1/decode_test/scoring_kaldi/best_wer >> result.t3.3
echo 'time ' $(($end_time - $start_time)) >> result.t3.3

