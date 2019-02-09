#!/usr/bin/env python
from __future__ import print_function
from __future__ import division

import sys

import numpy as np
import time

from hipopy4 import Event

file_name = sys.argv[1]

event = Event(file_name)

total = 0
start_time = time.time()

print(event)

for evnt in event:
    total += 1
    if len(evnt) == 0:
        continue
    for part in range(len(evnt)):
        momentum = np.sqrt(
            np.square(evnt.px(part))
            + np.square(evnt.py(part))
            + np.square(evnt.pz(part))
        )
    if total % 100000 == 0:
        print(str(total / (time.time() - start_time)), "hz")


print(str(time.time() - start_time), "sec")
print(str(total / (time.time() - start_time)), "hz")
