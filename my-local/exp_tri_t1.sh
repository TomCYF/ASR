#! /bin/bash

[ -f ./path.sh ] && . ./path.sh

#local/lab3_setup.sh

for ((num_cluster=1000;num_cluster<=5000;num_cluster=num_cluster+500)); do	
	for ((per_gauss=1;per_gauss<=64;per_gauss=per_gauss*2)); do
		num_gauss=$(($num_cluster * $per_gauss))
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
		echo 'Exp: num_gauss = ' $num_gauss 'num_cluster = ' $num_cluster>> result.tri1
	    	more exp/word/tri1/decode_test/scoring_kaldi/best_wer
		more exp/word/tri1/decode_test/scoring_kaldi/best_wer >> result.tri1
		echo 'time ' $(($end_time - $start_time)) >> result.tri1
	done
done
