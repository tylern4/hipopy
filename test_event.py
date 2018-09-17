#!/usr/bin/env python
from __future__ import print_function

import sys
import time

import numpy as np

from hipopy import Events, hipo_reader

file_name = sys.argv[1]
reader = hipo_reader(file_name)
data = Events(reader)
start = time.time()
i = 0
for event in data:
    i += 1
    for part in event.particles:
        pass


end = time.time()
print((end - start), "Sec")
print(((end - start) / i), "time/event")
print((i / (end - start)), "Hz")
