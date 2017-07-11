#! /bin/bash

[ -f ./path.sh ] && . ./path.sh

# split data by gender
m_train_dir='data/train_f'
f_train_dir='data/train_m'
m_test_dir='data/test_f'
f_test_dir='data/test_m'
if [ ! -d $m_train_dir ]; then 
	mkdir $m_train_dir 
	cp data/train_words/glm $m_train_dir
fi
if [ ! -d $f_train_dir ]; then 
	mkdir $f_train_dir 
	cp data/train_words/glm $f_train_dir
fi
if [ ! -d $m_test_dir ]; then 
	mkdir $m_test_dir 
	cp data/test_words/glm $m_test_dir
fi
if [ ! -d $f_test_dir ]; then 
	mkdir $f_test_dir 
	cp data/test_words/glm $f_test_dir
fi
for f in cmvn.scp spk2utt utt2spk wav.scp stm text; do
	touch $m_train_dir/$f
	touch $f_train_dir/$f
	cat data/train_words/$f | my-local/split_data_gender.py $f train
	
	touch $m_test_dir/$f
	touch $f_test_dir/$f
	cat data/test_words/$f | my-local/split_data_gender.py $f test
done


for gender in f m; do
	for dir in train test; do
    		steps/make_mfcc.sh data/$dir\_$gender exp/make_mfcc/$dir mfcc
    		steps/compute_cmvn_stats.sh data/$dir\_$gender exp/cmvn/$dir cmvn
	done	
	start_time=$(date +%s)
	steps/train_mono.sh --nj 4 --totgauss 9500 data/train_$gender data/lang_wsj exp/mono
	
	steps/train_deltas.sh 4500 15000 data/train_$gender \
		data/lang_wsj exp/mono exp/word/tri1

	utils/mkgraph.sh data/lang_wsj_test_bg \
		exp/word/tri1 exp/word/tri1/graph

	steps/decode.sh --nj 4 exp/word/tri1/graph \
 		data/test_$gender exp/word/tri1/decode_test


	# utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/mono exp/mono/graph

	# steps/decode.sh --nj 4 exp/mono/graph data/test_$gender exp/mono/decode_test

	# local/score_words.sh data/test_words exp/mono/graph exp/mono/decode_test
	
	local/score_words.sh data/test_$gender exp/word/tri1/graph \
		exp/word/tri1/decode_test

	end_time=$(date +%s)
	echo 'Exp: num_gauss = ' 9500 >> result.t3.1
	echo 'time ' $(($end_time - $start_time)) >> result.t3.1
	more exp/word/tri1/decode_test/scoring_kaldi/best_wer
	more exp/word/tri1/decode_test/scoring_kaldi/best_wer >> result.t3.1
done









                

