#! /bin/bash

[ -f ./path.sh ] && . ./path.sh

#local/lab3_setup.sh
$num_cluster=4500
num_gauss=15000
start_time=$(date +%s)
steps/train_deltas.sh $num_cluster $num_gauss data/train_words \
	data/lang_wsj exp/word/mono_ali exp/word/tri1

utils/mkgraph.sh data/lang_wsj_test_bg \
	exp/word/tri1 exp/word/tri1/graph

steps/decode.sh --nj 4 exp/word/tri1/graph \
 	data/test_words exp/word/tri1/decode_test

local/score_words.sh data/test_words exp/word/tri1/graph \
	exp/word/tri1/decode_test
end_time=$(date +%s)
echo 'Exp: num_gauss = ' $num_gauss 'num_cluster = ' $num_cluster>> result_best.tri1
more exp/word/tri1/decode_test/scoring_kaldi/best_wer
more exp/word/tri1/decode_test/scoring_kaldi/best_wer >> result_best.tri1
echo 'time ' $(($end_time - $start_time)) >> result_best.tri1

