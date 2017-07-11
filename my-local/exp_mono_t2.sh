#! /bin/bash

[ -f ./path.sh ] && . ./path.sh

# from previous experiments, set the total
# number of gaussian as 1750 could reach the best result.
num_gauss=9700

for feats in mfcc plp fbank; do
    # extract features
    for dir in train test; do
		steps/make_$feats.sh data/$dir\_words exp/make_$feats/$dir $feats
	# compute cmvn
		steps/compute_cmvn_stats.sh data/$dir\_words exp/cmvn/$dir cmvn
    done
    start_time=$(date +%s)
    # train monophone
    steps/train_mono.sh --nj 4 --totgauss $num_gauss \
		data/train_words data/lang_wsj exp/mono
    # create graph
    utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/mono \
		exp/mono/graph

    # decoding
    steps/decode.sh --nj 4 exp/mono/graph data/test_words \
		exp/mono/decode_test
	end_time=$(date +%s)
    # generate the results
	echo 'Features: ' $feats >> result.t2
    local/score_words.sh data/test_words exp/mono/graph \
		exp/mono/decode_test	
	
	more exp/mono/decode_test/scoring_kaldi/best_wer >> result.t2
	echo 'time ' $(($end_time - $start_time)) >> result.t2
done

# experiments results

# Features:  mfcc
# %WER 28.0 | 192 7215 | 75.0 16.9 8.1 3.0 28.0 100.0 | -0.438 | exp/mono/decode_test/score_5/ctm_39phn.filt.sys
# Features:  plp
# %WER 28.6 | 192 7215 | 74.5 18.1 7.5 3.1 28.6 99.5 | -0.709 | exp/mono/decode_test/score_4/ctm_39phn.filt.sys
# Features:  fbank
# %WER 30.9 | 192 7215 | 73.1 19.9 7.0 4.0 30.9 99.5 | -0.627 | exp/mono/decode_test/score_10/ctm_39phn.filt.sys

