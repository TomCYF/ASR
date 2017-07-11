#! /bin/python

import sys
import os

if str(sys.argv[2])=='train':
	f = open('data/train_f/'+str(sys.argv[1]), 'w')
	m = open('data/train_m/'+str(sys.argv[1]), 'w')
else:
	f = open('data/test_f/'+str(sys.argv[1]), 'w')
	m = open('data/test_m/'+str(sys.argv[1]), 'w')
for line in sys.stdin:
	words = line.strip()
	if line.startswith('f'):
		print >> f, words
	else: print >> m, words
		 
