#!/usr/bin/env python
from __future__ import print_function

import sys

import numpy as np

from hipopy import hipo_reader

file_name = sys.argv[1]
reader = hipo_reader(file_name)

rec_part_pid = reader.getIntNode("REC::Particle", "pid")
raw_scaler_helicity = reader.getInt8Node("RAW::scaler", "helicity")


num = 0
while(reader.next() and num < 2):
    raw_scaler_helicity.show()
