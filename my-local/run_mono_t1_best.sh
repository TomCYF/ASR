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
steps/train_mono.sh --nj 4 --totgauss 9700 data/train_words data/lang_wsj exp/mono
# create graph
utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/mono exp/mono/graph
# decoding
steps/decode.sh --nj 4 exp/mono/graph data/test_words exp/mono/decode_test
# generate the results
echo 'Exp: num_gauss = ' $num_gauss >> result_best.t1
local/score_words.sh data/test_words exp/mono/graph \
	exp/mono/decode_test
end_time=$(date +%s)
more exp/mono/decode_test/scoring_kaldi/best_wer >> result_best.t1
echo 'time ' $(($end_time - $start_time)) >> result_best.t1



