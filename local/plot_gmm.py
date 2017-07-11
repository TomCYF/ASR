import re
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats
import fileinput

# A very hacky parser for acoustic models in Kaldi
# that plots the GMMs corresponding to the first
# 12 cepstral coefficients for a pdf given by
# setting pdf below.
# Reads from std.in.
# E.g. gmm-copy --binary=false 0.mdl - | python local/plot_gmm.py -
#
# Joachim Fainberg, Uni. of Edinburgh, 2017

pdf = 44

def parse_line(line):
  '''
  <WEIGHTS>  [ 0.09707794 0.06996857 0.09917086 ]
  returns list [ 0.09707794 0.06996857 0.09917086 ]
  '''
  return [float(x) for x in re.findall('[0-9]*\.[0-9]*', line)]

parsing = False
means_flag = False
invs_flag = False
means_invvars = []
invvars = []
count = 0
for line in fileinput.input():
    if "<DiagGMM>" in line:
      count += 1
      if count == pdf:
        parsing = True
    if line.startswith("</DiagGMM>") and count == pdf:
      break
    if parsing:
      p = parse_line(line)
      if "<WEIGHTS>" in line:
        weights = p
      elif "<MEANS_INVVARS>" in line:
        means_flag = True
        continue
      elif "<INV_VARS>" in line:
        invs_flag = True
        means_flag = False
        continue
      if means_flag:
        means_invvars.append(p)
      elif invs_flag:
        invvars.append(p)

# plot gmms
comps = []
if not weights: weights = [1.0]
for dim in range(0,12):
    means_invvars_1 = np.array([x[dim] for x in means_invvars])
    invvars_1 = np.array([x[dim] for x in invvars])

    means_1 = means_invvars_1 / invvars_1
    vars_1 = 1.0 / invvars_1

    mix = 0.0
    x = np.arange(-10*max(means_1),10*max(means_1),0.01)
    for w, m, v in zip(weights, means_1, vars_1):
      norm = scipy.stats.norm.pdf(x, m, v)
      mix += w*norm

    comps.append((x, mix))
nrow = 4
ncol = 3
fig, axs = plt.subplots(nrow, ncol) #, sharex=True, sharey=False)
for i, ax in enumerate(fig.axes):
        ax.plot(comps[i][0], comps[i][1])
        ax.set_xticks([], [])
        ax.set_yticks([], [])
        ax.set_xlabel('c{0}'.format(i))
big_ax = fig.add_subplot(111, frameon=False)
big_ax.set_xlabel('x')
big_ax.set_ylabel('magnitude')
big_ax.set_axis_bgcolor('none')
big_ax.tick_params(labelcolor='none', top='off', bottom='off', left='off', right='off') 
plt.tight_layout()
plt.show()
