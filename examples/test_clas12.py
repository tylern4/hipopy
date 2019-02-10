#!/usr/bin/env python
from __future__ import print_function
from __future__ import division

import numpy as np
import time
import sys

from clas12 import clas12Event

from ROOT import TH2D, TFile

file_name = sys.argv[1]

event = clas12Event(file_name)

total = 0
start_time = time.time()

sampling_fraction_hist = TH2D(
    "sampling_fraction_hist", "sampling_fraction_hist", 500, 0, 10, 500, 0, 1
)

for evnt in event:
    total += 1
    if total % 10000 == 0:
        print(str(total / (time.time() - start_time)), "hz")
    if len(evnt) == 0:
        continue
    if evnt.charge(0) == -1:
        mom = np.sqrt(
            np.square(evnt.px(0)) + np.square(evnt.py(0)) + np.square(evnt.pz(0))
        )
        sf = event.ec_tot_energy(0) / mom
        sampling_fraction_hist.Fill(mom, sf)

print("\n\n")
print(str(time.time() - start_time), "sec")
print(str(total / (time.time() - start_time)), "hz")

hfile = TFile("sf.root", "RECREATE", "Demo ROOT file with sampling fraction histogram")
sampling_fraction_hist.Write()
hfile.Write()
