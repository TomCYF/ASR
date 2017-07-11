#! /bin/bash

[ -f ./path.sh ] && . ./path.sh

num_gauss=9700

for dir in train test; do
	steps/make_mfcc.sh data/$dir\_words exp/make_mfcc/$dir mfcc
	# compute cmvn
	steps/compute_cmvn_stats.sh data/$dir\_words exp/cmvn/$dir cmvn
done

start_time=$(date +%s)
my-local/train_mono_delta.sh --nj 4 --totgauss $num_gauss data/train_words data/lang_wsj exp/mono
# create graph
utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/mono exp/mono/graph
# decoding
my-local/decode_delta.sh --nj 4 exp/mono/graph data/test_words exp/mono/decode_test
# generate the results

end_time=$(date +%s)
local/score_words.sh data/test_words exp/mono/graph \
	exp/mono/decode_test
more exp/mono/decode_test/scoring_kaldi/best_wer >> result.t3
echo 'time ' $(($end_time - $start_time)) >> result.t3
# experiments results
