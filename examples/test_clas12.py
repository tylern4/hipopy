#!/usr/bin/env python
from __future__ import print_function
from __future__ import division

import numpy as np
import time
import sys

from clas12 import clas12Event, LorentzVector

from ROOT import TH2D, TH1D, TFile

SECTORS = 7
BEAM_E = 10.9
MASS_ELEC = 0.000511


def Q2_calc(_e_mu, _e_mu_prime):
    """Retruns Q^2 value: -q^mu^2 = -(e^mu - e^mu')^2 = Q^2."""
    _q_mu = _e_mu - _e_mu_prime
    return -_q_mu.Mag2


def W_calc(_e_mu, _e_mu_prime):
    """Returns W: Gotten from s channel [(gamma - P)^2 == s == w^2], Sqrt[M_p^2 - Q^2 + 2 M_p gamma]."""
    _q_mu = _e_mu - _e_mu_prime
    _p_target = LorentzVector(0.0, 0.0, 0.0, mass=0.93827)
    return (_p_target + _q_mu).Mag


file_name = sys.argv[1]

event = clas12Event(file_name.encode("utf8"))

total = 0
start_time = time.time()

sampling_fraction_hist = TH2D(
    "sampling_fraction_hist", "sampling_fraction_hist", 500, 0, 10, 500, 0, 1
)
w_vs_q2 = TH2D("w_vs_q2", "w_vs_q2", 500, 0, 5, 500, 0, 5)
w = TH1D("w", "w", 500, 0, 5)

e_mu = LorentzVector(0.0, 0.0, BEAM_E, energy=BEAM_E)

for evnt in event:
    total += 1
    if total % 10000 == 0:
        print(str(total / (time.time() - start_time)), "hz")
    if len(evnt) == 0:
        continue
    if total > 50000:
        break
    if evnt.charge(0) == -1:
        mom = np.sqrt(
            np.square(evnt.px(0)) + np.square(evnt.py(0)) + np.square(evnt.pz(0))
        )
        sf = event.ec_tot_energy(0) / mom
        sampling_fraction_hist.Fill(mom, sf)
        e_mu_prime = LorentzVector(evnt.px(0), evnt.py(0), evnt.pz(0), mass=MASS_ELEC)
        w.Fill(W_calc(e_mu, e_mu_prime))
        w_vs_q2.Fill(W_calc(e_mu, e_mu_prime), Q2_calc(e_mu, e_mu_prime))

print("\n")
print(str(time.time() - start_time), "sec")
print(str(total / (time.time() - start_time)), "hz")

hfile = TFile("sf.root", "RECREATE", "Demo ROOT file with sampling fraction histogram")
sampling_fraction_hist.Write()
w_vs_q2.Write()
w.Write()
hfile.Write()
