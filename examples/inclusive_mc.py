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
    delta_px = np.ones(shape=(SECTORS, events)) * np.nan
    delta_py = np.ones(shape=(SECTORS, events)) * np.nan
    delta_pz = np.ones(shape=(SECTORS, events)) * np.nan
    delta_vx = np.ones(shape=(SECTORS, events)) * np.nan
    delta_vy = np.ones(shape=(SECTORS, events)) * np.nan
    delta_vz = np.ones(shape=(SECTORS, events)) * np.nan

    W = np.ones(shape=(SECTORS, events)) * np.nan
    Q2 = np.ones(shape=(SECTORS, events)) * np.nan

    W_mc = np.ones(shape=(SECTORS, events)) * np.nan
    delta_W = np.ones(shape=(SECTORS, events)) * np.nan
    Q2_mc = np.ones(shape=(SECTORS, events)) * np.nan

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

        mc_pid = reader.getIntNode(u"MC::Particle", u"pid")
        mc_px = reader.getFloatNode(u"MC::Particle", u"px")
        mc_py = reader.getFloatNode(u"MC::Particle", u"py")
        mc_pz = reader.getFloatNode(u"MC::Particle", u"pz")
        mc_vx = reader.getFloatNode(u"MC::Particle", u"vx")
        mc_vy = reader.getFloatNode(u"MC::Particle", u"vy")
        mc_vz = reader.getFloatNode(u"MC::Particle", u"vz")
        mc_vt = reader.getFloatNode(u"MC::Particle", u"vt")

        track_pindex = reader.getInt16Node(u"REC::Track", u"pindex")
        track_sector = reader.getInt8Node(u"REC::Track", u"sector")

        cal_pindex = reader.getInt16Node(u"REC::Calorimeter", u"pindex")
        cal_sector = reader.getInt8Node(u"REC::Calorimeter", u"sector")

        while reader.next():
            if len(pid) == 0:
                continue
            num += 1
            sec = GetSector(cal_pindex, cal_sector)
            delta_px[sec][num] = px[0] - mc_px[0]
            delta_py[sec][num] = py[0] - mc_py[0]
            delta_pz[sec][num] = pz[0] - mc_pz[0]
            e_mu_prime = LorentzVector(px[0], py[0], pz[0], mass=MASS_ELEC)
            mc_e_mu_prime = LorentzVector(mc_px[0], mc_py[0], mc_pz[0], mass=MASS_ELEC)
            W[sec][num] = W_calc(e_mu, e_mu_prime)
            Q2[sec][num] = Q2_calc(e_mu, e_mu_prime)

            W_mc[sec][num] = W_calc(e_mu, mc_e_mu_prime)
            Q2_mc[sec][num] = Q2_calc(e_mu, mc_e_mu_prime)
            delta_W[sec][num] = W_calc(e_mu, e_mu_prime) - W_calc(e_mu, mc_e_mu_prime)

    return events, delta_px, delta_py, delta_pz, W, W_mc, Q2, Q2_mc, delta_W


start = time.time()
events, delta_px, delta_py, delta_pz, W, W_mc, Q2, Q2_mc, delta_W = process(sys.argv[1:])

fig_p, axs_p = plt.subplots(3, SECTORS, sharex=True, sharey='row', figsize=(16, 10))
fig_p.text(0.5, 0.04, '$\Delta$ P', ha='center')
axs_p[0, 0].set_ylabel("$\Delta P_x$")
axs_p[1, 0].set_ylabel("$\Delta P_y$")
axs_p[2, 0].set_ylabel("$\Delta P_z$")

fig_WQ2, axs_WQ2 = plt.subplots(2, SECTORS, sharey='row', figsize=(16, 10))
for s in range(0, SECTORS):
    dpx = delta_px[s]
    dpx = dpx[~np.isnan(dpx)]
    y, bins, _ = axs_p[0, s].hist(dpx, bins=50, range=(-1, 1), color='darkred',
                                  histtype='step', fill=True, density=True)
    axs_p[0, s].set_title("Sector: {0:d}".format(s))

    x = (bins[:-1] + bins[1:]) / 2
    popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0])
    axs_p[0, s].plot(x, gaus(x, *popt), "blue",
                     label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
    axs_p[0, s].legend()

    dpy = delta_py[s]
    dpy = dpy[~np.isnan(dpy)]
    y, bins, _ = axs_p[1, s].hist(dpy, bins=50, range=(-1, 1), color='darkgreen',
                                  histtype='step', fill=True, density=True)
    x = (bins[:-1] + bins[1:]) / 2
    popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0])
    axs_p[1, s].plot(x, gaus(x, *popt), "red",
                     label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
    axs_p[1, s].legend()

    dpz = delta_pz[s]
    dpz = dpz[~np.isnan(dpz)]
    y, bins, _ = axs_p[2, s].hist(dpz, bins=50, range=(-1, 1), color='darkblue',
                                  histtype='step', fill=True, density=True)
    x = (bins[:-1] + bins[1:]) / 2
    popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0])
    axs_p[2, s].plot(x, gaus(x, *popt), "green",
                     label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
    axs_p[2, s].legend()

    W_s = W[s]
    Q2_s = Q2[s]
    W_s = W_s[~np.isnan(W_s)]
    Q2_s = Q2_s[~np.isnan(Q2_s)]
    y, bins, _ = axs_WQ2[0, s].hist(W_s, bins=100, range=(0.8, 1.1), color='darkblue',
                                    histtype='step', fill=True, density=True)
    x = (bins[:-1] + bins[1:]) / 2
    popt, pcov = curve_fit(gaus, x, y, p0=[1.0, 1.0, 1.0])
    axs_WQ2[0, s].plot(x, gaus(x, *popt), "red",
                       label="$\mu$ = {0:.4f}\n$\sigma$ = {1:.4f}".format(popt[1], popt[2]), linewidth=2)
    axs_WQ2[0, s].legend()

    axs_WQ2[1, s].hist2d(W_s, Q2_s, bins=100, range=((0.8, 1.1), (0, 1.0)))
    axs_WQ2[0, s].set_title("Sector {0:d} W vs $Q^2$".format(s))

fig_p.savefig("delta_p.pdf")
fig_WQ2.savefig("WvsQ2.pdf")

end = time.time()
print((end - start), "Sec")
print(((end - start) / events), "time/event")
print((events / (end - start)), "Hz")
