#!/usr/bin/env python
from __future__ import print_function

import sys
import time
from collections import defaultdict

import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

from hipopy import LorentzVector, hipo_reader

SECTORS = 7
BEAM_E = 2.2
MASS_ELEC = 0.000511


def GetSector(pindex, sector):
    sec = defaultdict(list)
    for i in xrange(len(pindex)):
        sec[pindex[i]].append(sector[i])
    try:
        return sec[0][0]
    except:
        return 0


def gaus(x, a, x0, sigma):
    return a * np.exp(-(x - x0)**2 / (2 * sigma**2))


def Q2_calc(_e_mu, _e_mu_prime):
    """Retruns Q^2 value: q^mu^2 = (e^mu - e^mu')^2 = -Q^2."""
    _q_mu = (_e_mu - _e_mu_prime)
    return -_q_mu.Mag2


def W_calc(_e_mu, _e_mu_prime):
    """Returns W: Gotten from s channel [(gamma - P)^2 == s == w^2], Sqrt[M_p^2 - Q^2 + 2 M_p gamma]."""
    _q_mu = (_e_mu - _e_mu_prime)
    _p_target = LorentzVector(0.0, 0.0, 0.0, mass=0.93827)
    return (_p_target + _q_mu).Mag


def process(filenames):
    events = 0
    num = 0
    e_mu = LorentzVector(0.0, 0.0, BEAM_E, energy=BEAM_E)
    for f in filenames:
        reader = hipo_reader(f)
        while reader.next():
            events += 1

    print("Processing {} Events".format(events))
    W = np.ones(shape=(SECTORS, events * 2)) * np.nan
    Q2 = np.ones(shape=(SECTORS, events * 2)) * np.nan

    for f in filenames:
        reader = hipo_reader(f)
        pid = reader.getIntNode(u"REC::Particle", u"pid")
        px = reader.getFloatNode(u"REC::Particle", u"px")
        py = reader.getFloatNode(u"REC::Particle", u"py")
        pz = reader.getFloatNode(u"REC::Particle", u"pz")
        vx = reader.getFloatNode(u"REC::Particle", u"vx")
        vy = reader.getFloatNode(u"REC::Particle", u"vy")
        vz = reader.getFloatNode(u"REC::Particle", u"vz")
        charge = reader.getInt8Node(u"REC::Particle", u"charge")
        beta = reader.getFloatNode(u"REC::Particle", u"beta")

        track_pindex = reader.getInt16Node(u"REC::Track", u"pindex")
        track_sector = reader.getInt8Node(u"REC::Track", u"sector")

        cal_pindex = reader.getInt16Node(u"REC::Calorimeter", u"pindex")
        cal_sector = reader.getInt8Node(u"REC::Calorimeter", u"sector")

        while reader.next():
            if len(pid) == 0:
                continue
            num += 1
            sec = GetSector(cal_pindex, cal_sector)
            e_mu_prime = LorentzVector(px[0], py[0], pz[0], mass=MASS_ELEC)
            W[sec][num] = W_calc(e_mu, e_mu_prime)
            Q2[sec][num] = Q2_calc(e_mu, e_mu_prime)

    return events, W, Q2


start = time.time()
events, W, Q2 = process(sys.argv[1:])

fig_WQ2, axs_WQ2 = plt.subplots(2, 6, sharey='row', figsize=(16, 10))
for s in range(1, SECTORS):
    i = s - 1
    W_s = W[s]
    Q2_s = Q2[s]
    W_s = W_s[~np.isnan(W_s)]
    Q2_s = Q2_s[~np.isnan(Q2_s)]
    y, bins, _ = axs_WQ2[0, i].hist(W_s, bins=100, range=(0.8, 1.1), color='darkblue',
                                    histtype='step', fill=True, density=True)
    x = (bins[:-1] + bins[1:]) / 2
    popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0], maxfev=8000)
    axs_WQ2[0, i].plot(x, gaus(x, *popt), "red",
                       label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
    axs_WQ2[0, i].legend()

    axs_WQ2[1, i].hist2d(W_s, Q2_s, bins=100, range=((0.8, 1.1), (0, 1.0)))
    axs_WQ2[0, i].set_title("Sector {0:d} W vs $Q^2$".format(s))


fig_WQ22, axs_WQ22 = plt.subplots(2, 2, sharey='row', figsize=(16, 10))
W_s = W[0]
Q2_s = Q2[0]
W_s = W_s[~np.isnan(W_s)]
Q2_s = Q2_s[~np.isnan(Q2_s)]
y, bins, _ = axs_WQ22[0, 0].hist(W_s, bins=100, range=(0.8, 1.1), color='darkblue',
                                 histtype='step', fill=True, density=True)
x = (bins[:-1] + bins[1:]) / 2
popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0])
axs_WQ22[0, 0].plot(x, gaus(x, *popt), "red",
                    label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
axs_WQ22[0, 0].legend()

axs_WQ22[1, 0].hist2d(W_s, Q2_s, bins=100, range=((0.8, 1.1), (0, 1.0)))
axs_WQ22[0, 0].set_title("No Sector W vs $Q^2$".format(s))
##########################
W_s = W[:]
Q2_s = Q2[:]
W_s = W_s[~np.isnan(W_s)]
Q2_s = Q2_s[~np.isnan(Q2_s)]
y, bins, _ = axs_WQ22[0, 1].hist(W_s, bins=100, range=(0.8, 1.1), color='darkblue',
                                 histtype='step', fill=True, density=True)
x = (bins[:-1] + bins[1:]) / 2
popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0])
axs_WQ22[0, 1].plot(x, gaus(x, *popt), "red",
                    label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
axs_WQ22[0, 1].legend()

axs_WQ22[1, 1].hist2d(W_s, Q2_s, bins=100, range=((0.8, 1.1), (0, 1.0)))
axs_WQ22[0, 1].set_title("All Sectors W vs $Q^2$".format(s))

fig_WQ2.savefig("WvsQ2_bySector.pdf")
fig_WQ22.savefig("WvsQ2.pdf")


end = time.time()
print((end - start), "Sec")
print(((end - start) / events), "time/event")
print((events / (end - start)), "Hz")
