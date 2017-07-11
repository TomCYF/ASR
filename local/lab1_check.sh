#!/bin/bash

# Check for dirs and some files from lab1

for dir in train test; do
    utils/validate_data_dir.sh data/$dir || exit 1;
done

[ ! -d "mfcc" ] && echo "Missing mfcc feature dir!" && exit 1;

files="mfcc/raw_mfcc_train.1.ark \
	   data/train/cmvn.scp data/test/cmvn.scp"

for f in $files; do
	[ ! -f $f ] && echo "Missing $f!" && exit 1;
done
	
echo "Everything looks ok." && exit 0;
