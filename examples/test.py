#!/usr/bin/env python
from __future__ import print_function

import sys

import numpy as np

from hipopy import hipo_reader

file_name = sys.argv[1]
reader = hipo_reader(file_name)

_ec_pindex = reader.getInt16Node(u"REC::Calorimeter", u"pindex")
_ec_detector = reader.getInt8Node(u"REC::Calorimeter", u"detector")
_ec_sector = reader.getInt8Node(u"REC::Calorimeter", u"sector")
_ec_layer = reader.getInt8Node(u"REC::Calorimeter", u"layer")
_ec_energy = reader.getFloatNode(u"REC::Calorimeter", u"energy")
_ec_time = reader.getFloatNode(u"REC::Calorimeter", u"time")
_ec_path = reader.getFloatNode(u"REC::Calorimeter", u"path")
_ec_x = reader.getFloatNode(u"REC::Calorimeter", u"x")
_ec_y = reader.getFloatNode(u"REC::Calorimeter", u"y")
_ec_z = reader.getFloatNode(u"REC::Calorimeter", u"z")
_ec_lu = reader.getFloatNode(u"REC::Calorimeter", u"lu")
_ec_lv = reader.getFloatNode(u"REC::Calorimeter", u"lv")
_ec_lw = reader.getFloatNode(u"REC::Calorimeter", u"lw")


num = 0
while(reader.next() and num < 10):
    num += 1
    print("_ec_pindex", end="\t")
    for i in range(0, len(_ec_pindex)):
        print(_ec_pindex[i], end="\t")
    print()
    print("_ec_detector", end="\t")
    for i in range(0, len(_ec_detector)):
        print(_ec_detector[i], end="\t")
    print()
    print("_ec_sector", end="\t")
    for i in range(0, len(_ec_sector)):
        print(_ec_sector[i], end="\t")
    print()
    print("_ec_layer", end="\t")
    for i in range(0, len(_ec_layer)):
        print(_ec_layer[i], end="\t")
    print()
    print("_ec_energy", end="\t")
    for i in range(0, len(_ec_energy)):
        print(_ec_energy[i], end="\t")
    print()
    print("_ec_time", end="\t")
    for i in range(0, len(_ec_time)):
        print(_ec_time[i], end="\t")
    print()
    print("_ec_path", end="\t")
    for i in range(0, len(_ec_path)):
        print(_ec_path[i], end="\t")
    print()
    print("_ec_x", end="\t")
    for i in range(0, len(_ec_x)):
        print(_ec_x[i], end="\t")
    print()
    print("_ec_y", end="\t")
    for i in range(0, len(_ec_y)):
        print(_ec_y[i], end="\t")
    print()
    print("_ec_z", end="\t")
    for i in range(0, len(_ec_z)):
        print(_ec_z[i], end="\t")
    print()
    print("_ec_lu", end="\t")
    for i in range(0, len(_ec_lu)):
        print(_ec_lu[i], end="\t")
    print()
    print("_ec_lv", end="\t")
    for i in range(0, len(_ec_lv)):
        print(_ec_lv[i], end="\t")
    print()
    print("_ec_lw", end="\t")
    for i in range(0, len(_ec_lw)):
        print(_ec_lw[i], end="\t")
    print("\n******************")
