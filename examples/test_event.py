#!/usr/bin/env python
from __future__ import print_function

import collections
import sys
import time

import matplotlib.pyplot as plt
import numpy as np

from hipopy import Event, LorentzVector, Particle, hipo_reader
from ROOT import TLorentzVector


def vertex_time(sc_time, sc_pathlength, relatavistic_beta):
    c_special_units = 29.9792458
    return sc_time - sc_pathlength / (relatavistic_beta * c_special_units)


def deltat(momentum, sc_t, sc_r, vertex, guess_mass):
    if momentum == 0:
        return np.nan
    beta = 1.0 / np.sqrt(1.0 + (guess_mass / momentum) * (guess_mass / momentum))
    dt = vertex - vertex_time(sc_t, sc_r, beta)
    return dt


fig = plt.figure(figsize=(16, 9))

file_name = sys.argv[1]
reader = hipo_reader(file_name)
data = Event(reader)

i = 0

dt_pip = []
mom = []

start = time.time()
for event in data:
    i += 1
    etot = event.ec[0][3]
    sc_t = event.tof[0][0]
    sc_r = event.tof[0][1]
    if (sc_t != sc_t) or (sc_r != sc_r):
        continue

    vertex = vertex_time(sc_t, sc_r, 1.0)
    for part, x in zip(event.particles, range(len(event.particles))):
        sc_t = event.tof[x][0]
        sc_r = event.tof[x][1]
        if (sc_t != sc_t) or (sc_r != sc_r) or part.P == 0:
            continue

        dt_pip.append(deltat(part.P, sc_t, sc_r, vertex, 0.13957018))
        mom.append(part.P)

end = time.time()
print((end - start), "Sec")
print(((end - start) / i), "time/event")
print((i / (end - start)), "Hz")

fig, axs = plt.subplots()
axs.hist2d(mom, dt_pip, bins=500, range=((0.0, 2.2), (-10.0, 10.0)))

fig.savefig("dt_pip.pdf")
