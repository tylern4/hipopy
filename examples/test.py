#!/usr/bin/env python
from __future__ import print_function
from __future__ import division

import sys

import numpy as np

from hipopy3 import hipo3_reader as hipo_reader

file_name = sys.argv[1]
reader = hipo_reader(file_name)

pid = reader.getIntNode(u"REC::Particle", u"pid")
px = reader.getFloatNode(u"REC::Particle", u"px")
py = reader.getFloatNode(u"REC::Particle", u"py")
pz = reader.getFloatNode(u"REC::Particle", u"pz")
vx = reader.getFloatNode(u"REC::Particle", u"vx")
vy = reader.getFloatNode(u"REC::Particle", u"vy")
vz = reader.getFloatNode(u"REC::Particle", u"vz")

total = 0
good = 0
while reader.next():
    total += 1
    if len(pid) == 0:
        continue
    good += 1

print(good / total)
