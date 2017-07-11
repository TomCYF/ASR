#! /bin/bash

[ -f ./path.sh ] && . ./path.sh


# extract features
for dir in train test; do
    steps/make_mfcc.sh data/$dir\_words exp/make_mfcc/$dir mfcc
    # compute cmvn
    steps/compute_cmvn_stats.sh data/$dir\_words exp/compute_cmvn_stats/$dir cmvn
done

# the experiments set for variable of the number of gaussians range from 500 to 20000
for ((num_gauss=9700;num_gauss<=9800;num_gauss=num_gauss+20)); do
	start_time=$(date +%s)
	# train monophone
	steps/train_mono.sh --nj 4 --totgauss $num_gauss data/train_words data/lang_wsj exp/mono
	# create graph
	utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/mono exp/mono/graph
	# decoding
	steps/decode.sh --nj 4 exp/mono/graph data/test_words exp/mono/decode_test
	# generate the results
	echo 'Exp: num_gauss = ' $num_gauss >> result_9200.t1
	local/score_words.sh data/test_words exp/mono/graph \
		exp/mono/decode_test
	end_time=$(date +%s)
	more exp/mono/decode_test/scoring_kaldi/best_wer >> result_9200.t1
	echo 'time ' $(($end_time - $start_time)) >> result_9200.t1
done

# experiments results

