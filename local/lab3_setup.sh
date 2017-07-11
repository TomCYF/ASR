#!/bin/bash

# Setup new data and lang directories for
# word recognition on TIMIT with WSJ LM
# JF 2017

# copy data dirs and replace text (phones->words)
echo "Copying word-level data directories ..."
for dir in train test dev; do
  echo "...creating data/${dir}_words"
  cp -r data/${dir} data/${dir}_words || exit 1
  [ -d data/${dir}_words/split* ] && rm -r data/${dir}_words/split*
  cp /afs/inf.ed.ac.uk/group/teaching/asr/tools/labs/data/local/word/${dir}/text data/${dir}_words/ || exit 1
done

# copy new language model directories (wsj lang + wsj test bigram)
echo "Copying word-level language models into data/lang_wsj{,_test_bg}"
cp -r /afs/inf.ed.ac.uk/group/teaching/asr/tools/labs/data/{lang_wsj,lang_wsj_test_bg} data/ || exit 1

# copy monophone word experiment directories
echo "Copying corresponding monophone models into exp/word/mono{,_ali}"
mkdir -p exp/word || exit 1
cp -r /afs/inf.ed.ac.uk/group/teaching/asr/tools/labs/exp/word/mono{,_ali} exp/word/ || exit 1

echo "Lab 3 preparation succeeded."
