#!/bin/bash

#
# ASR Lab 1
# Data preparation and feature extraction
# 
# University of Edinburgh 2017
#

# Set environment variables
# The first part checks whether the files exist, 
# if they do then the second part is executed.
[ -f ./path.sh ] && . ./path.sh

####################
# DATA PREPARATION #
####################

# Set a variable to point to the TIMIT directory
timit=/group/corporapublic/timit/original

# -> Create the data directories, passing the timit variable
local/timit_create_data.sh $timit

utils/validate_data_dir.sh data/train
utils/validate_data_dir.sh data/test

utils/spk2utt_to_utt2spk.pl < data/train/spk2utt > data/train/utt2spk
utils/spk2utt_to_utt2spk.pl < data/test/spk2utt > data/test/utt2spk

# -> How many utterances are there in TIMIT?
wc -l < data/train/utt2spk

# -> How many speakers are there in TIMIT?
# Write a command that will produce the number below.
# 462 speakers
wc -l < data/train/spk2utt

# Make sure utils/validate_data_dir.sh is fine before continuing.

######################
# FEATURE EXTRACTION #
######################
-l < data/train/utt2spk
# We will now extract features on which to train 
for dir in train test; do
  steps/make_mfcc.sh data/$dir exp/make_mfcc/$dir mfcc
done

# -> Do the same but apply cepstral mean and variance normalisation.
# -> Complete the lines below
# for
# steps/compute_cmvn_stats.sh
# done

for dir in train test; do
  steps/compute_cmvn_stats.sh data/$dir exp/compute_cmvn_stats/$dir cmvn
done

# -> Validate the data directory again

# -> What is the feature dimension? 
# From script file
feat-to-dim scp:data/train/feats.scp -
# From archive file
feat-to-dim ark:mfcc/raw_mfcc_train.1.ark -

# -> Let's look at the features. 
copy-feats scp:data/train/feats.scp ark,t:- | head

# -> Look at the features for only utterance fdfb0_sx58.
# -> Complete the line below.
# copy-feats 

# -> Using the same trick, how many frames does fdfb0_sx58 have?
# feat-to-len

# -> What does the following line do?
head -10 data/train/feats.scp | tail -1 | copy-feats scp:- ark,t:- | head

# -> Create 43 dimensional filterbank+pitch features on copies of the data directories.
# YOUR CODE HERE
