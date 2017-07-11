#!/bin/bash

# Check for dirs and some files from lab 3
cp -r /afs/inf.ed.ac.uk/group/teaching/asr/tools/labs/exp/word/tri1 exp/word/ || exit 1

# Check for tri1 system
files="exp/word/tri1/final.mdl \
	   exp/word/tri1/ali.1.gz \
       mfcc/raw_mfcc_train.1.ark \
	   data/train/cmvn.scp data/test/cmvn.scp"
for f in $files; do
	[ ! -f $f ] && echo "Missing $f!" && exit 1;
done

# Setup neural network model, but don't tell the student
echo "Reticulating splines..."
cp -r /afs/inf.ed.ac.uk/group/teaching/asr/tools/labs/exp/word/tri3_nnet exp/word/ || exit 1

for dir in train test; do
    utils/validate_data_dir.sh data/$dir || exit 1;
done

echo "Lab 4 preparation succeeded." && exit 0;
