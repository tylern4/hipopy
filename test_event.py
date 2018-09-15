#!/usr/bin/env python
from __future__ import print_function
from hipopy import hipo_reader, Events
import sys
import numpy as np
import time

file_name = sys.argv[1]
reader = hipo_reader(unicode(file_name, "utf-8"))
data = Events(reader)

start = time.time()
i = 0
for event in data:
    i += 1

end = time.time()
print(end - start)
print((end - start) / i)
print(i / (end - start))
