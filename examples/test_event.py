#!/usr/bin/env python
from __future__ import print_function

import collections
import sys
import time

import matplotlib.pyplot as plt
import numpy as np

from hipopy3 import Event, LorentzVector, Particle, hipo3_reader
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
    mp = mass / momentum
    beta = 1.0 / np.sqrt(1.0 + (mp * mp))
    return vertex - vertex_time(sc_t, sc_r, beta)


file_name = sys.argv[1]
reader = hipo3_reader(file_name)
data = Event(reader)

tot_events = 0

pvsb_pos = TH2F(
    "momentum_vs_beta_pos", "P vs #beta Pos Particles", 500, 0, 4, 500, 0, 1.2
)
pvsb_neg = TH2F(
    "momentum_vs_beta_neg", "P vs #beta Neg Particles", 500, 0, 4, 500, 0, 1.2
)
pvsb_neutral = TH2F(
    "momentum_vs_beta_neutral", "P vs #beta Neu Particles", 500, 0, 4, 500, 0, 1.2
)
hfile = TFile("simple.root", "RECREATE", "Demo ROOT file with histograms")

start = time.time()
for event in data:
    tot_events += 1
    if len(event) == 0 or event.particle[0].pid != 11:
        continue
    for part in event.particle[1:]:
        if part.charge == 0:
            pvsb_neutral.Fill(part.P, part.beta)
        elif part.charge == 1:
            pvsb_pos.Fill(part.P, part.beta)
        elif part.charge == -1:
            pvsb_neg.Fill(part.P, part.beta)

end = time.time()
print((end - start), "Sec")
print("{:,} Hz".format((tot_events / (end - start))))
hfile.cd()
pvsb_pos.SetOption("colz")
pvsb_pos.Write()
pvsb_neg.SetOption("colz")
pvsb_neg.Write()
pvsb_neutral.SetOption("colz")
pvsb_neutral.Write()
