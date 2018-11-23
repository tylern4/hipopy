#!/usr/bin/env python
from __future__ import print_function

import collections
import sys
import time

import matplotlib.pyplot as plt
import numpy as np

from hipopy import Event, LorentzVector, Particle, hipo_reader
from ROOT import TH1F, TH2F, TCanvas, TFile, TLorentzVector

MASS_P = 0.93827203
MASS_N = 0.93956556
MASS_E = 0.000511
MASS_PIP = 0.13957018
MASS_PIM = 0.13957018
MASS_PI0 = 0.1349766
c_special_units = 29.9792458


def vertex_time(sc_time, sc_pathlength, relatavistic_beta):
    return sc_time - (sc_pathlength / (relatavistic_beta * c_special_units))


def deltat(momentum, sc_t, sc_r, vertex, mass):
    if momentum == 0:
        return np.nan
    mp = (mass / momentum)
    beta = 1.0 / np.sqrt(1.0 + (mp * mp))
    return vertex - vertex_time(sc_t, sc_r, beta)


file_name = sys.argv[1]
reader = hipo_reader(file_name)
data = Event(reader)

tot_events = 0

dt_pip = TH2F('dt_pip', '#DeltaT #pi^{+}', 500, 0, 4, 500, -10, 10)
sampling_fraction = TH2F('sampling_fraction', 'Sampling Fraction', 500, 0, 10, 500, 0, 0.5)
dt_p = TH2F('dt_p', '#DeltaT P^{+}', 500, 0, 4, 500, -10, 10)
hfile = TFile('simple.root', 'RECREATE', 'Demo ROOT file with histograms')

start = time.time()
for event in data:
    tot_events += 1
    if len(event) == 0:
        continue
    if event.particle[0].pid != 11:
        continue
    sampling_fraction.Fill(event.particle[0].P, event.ec[3][0] / event.particle[0].P)
    sc_t = event.tof[0][0]
    sc_r = event.tof[0][1]
    if (sc_t != sc_t) or (sc_r != sc_r):
        continue

    vertex = vertex_time(sc_t, sc_r, 1.0)
    for x in range(1, len(event.particle)):
        try:
            sc_t = event.tof[x][0]
            sc_r = event.tof[x][1]
            if event.particle[x].P == 0 or event.particle[x].charge != 1:
                continue
            dt_pip.Fill(event.particle[x].P, deltat(event.particle[x].P, sc_t, sc_r, vertex, MASS_PIP))
            dt_p.Fill(event.particle[x].P, deltat(event.particle[x].P, sc_t, sc_r, vertex, MASS_P))
        except IndexError:
            pass

end = time.time()
print((end - start), "Sec")
print("{:,} Hz".format((tot_events / (end - start))))
hfile.cd()
sampling_fraction.Write()
dt_pip.Write()
dt_p.Write()
hfile.Write()

#fig, axs = plt.subplots()
#axs.hist2d(mom, dt_pip, bins=500, range=((0.0, 2.2), (-10.0, 10.0)))

# fig.savefig("dt_pip.pdf")
