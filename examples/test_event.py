#!/usr/bin/env python
from __future__ import print_function

import collections
import sys
import time

import matplotlib.animation as animation
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import style

from hipopy import Event, LorentzVector, Particle, hipo_reader
from ROOT import TLorentzVector


def compare(x, y): return collections.Counter(x) == collections.Counter(y)


style.use('fivethirtyeight')
fig = plt.figure(figsize=(16, 9))

file_name = sys.argv[1]
reader = hipo_reader(file_name)
data = Event(reader)
start = time.time()
i = 0
for event in data:
    i += 1

end = time.time()
print((end - start), "Sec")
print(((end - start) / i), "time/event")
print((i / (end - start)), "Hz")
