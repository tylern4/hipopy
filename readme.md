[![Travis Build Status](https://travis-ci.org/tylern4/hipopy.svg?branch=master)](https://travis-ci.org/tylern4/hipopy)
[![pipeline status](https://gitlab.com/tylern4/hipopy/badges/master/pipeline.svg)](https://gitlab.com/tylern4/hipopy/commits/master)


## Build
```shell
git clone https://github.com/tylern4/hipopy.git
cd hipopy
mkdir build
cd build
cmake ..
make -j$(nproc)
make install
```

## Basic Example
```python
#!/usr/bin/env python
from __future__ import print_function
from hipopy import hipo_reader
import sys

file_name = sys.argv[1]
reader = hipo_reader(unicode(file_name, "utf-8"))

rec_part_pid = reader.getIntNode(u"REC::Particle", u"pid")
rec_part_px = reader.getFloatNode(u"REC::Particle", u"px")
rec_part_py = reader.getFloatNode(u"REC::Particle", u"py")
rec_part_pz = reader.getFloatNode(u"REC::Particle", u"pz")

num = 0
while(reader.next()):
    num += 1
    print("Event:")
    for i in range(0, rec_part_pid.getLength()):
        print("pid\t" + str(rec_part_pid[i]))
        print("px\t" + str(rec_part_px[i]))
        print("py\t" + str(rec_part_py[i]))
        print("pz\t" + str(rec_part_pz[i]))
    print()
```

## Benchmark
```python
import time
start = time.time()

import hipopy;
reader = hipopy.hipo_reader(u"/tmp/4070_8.hipo");
i = 0
while(reader.next()):
    i += 1

end = time.time()

print(i,(end-start))
```

```shell
(1429931, 12.387712001800537)
```


## Docker
```shell
docker run -v /local/path/to/data:/tmp --rm -it tylern4/hipopy
```

## Singularity on the Farm
```shell
module load singularity
setenv SINGULARITY_CACHEDIR /volatile/clas12/tylern/sing_cache
singularity exec docker://tylern4/hipopy ipython
```
