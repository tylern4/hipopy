# distutils: language = c++
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool
from libc.math cimport sqrt
import numpy as np

import json

get_id = {'PROTON': 2212, 'NEUTRON': 2112, 'PIP': 211, 'PIM': -211,
          'PI0': 111, 'KP': 321, 'KM': -321, 'PHOTON': 22, 'ELECTRON': 11}

part_mass = {11: 0.000511, 211: 0.13957, -211: 0.13957, 2212: 0.93827,
          2112: 0.939565, 321: 0.493667, -321: 0.493667, 22: 0}


cdef extern from "hipo/node.h" namespace "hipo":
    cdef cppclass node[T]:
      node() except +
      node(int, int) except +
      T getValue(int)
      void   reset()
      void   show()
      int    getLength()
      char  *getAddress()
      int    getBytesLength()
      void   setLength(int)
      void   setAddress(char *)

cdef extern from "hipo/reader.h" namespace "hipo":
    cdef cppclass reader:
      reader() except +
      reader(bool) except +
      vector[string] getDictionary()
      void open(char*)
      int getRecordCount()
      bool next()
      bool  isOpen()
      void  showInfo()
      node *getBranch[T](char*,char*)


cpdef char* str_to_char(str name):
  """Convert python string to char*"""
  cdef bytes name_bytes = name.encode()
  cdef char* c_name = name_bytes
  return c_name


cdef class int_node:
  cdef node[int]*c_node

  def __cinit__(self):
    self.c_node = new node[int]()

  def __getitem__(self, arg):
    return self.c_node.getValue(arg)

  def __len__(self):
    return self.c_node.getLength()

  def __str__(self):
    self.c_node.show()

  cdef setup(self, node[int]* node):
    self.c_node = node

  cpdef int getValue(self, x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()


cdef class char_node:
  cdef node[char]*c_node

  def __cinit__(self):
    self.c_node = new node[char]()

  def __getitem__(self, arg):
    return self.c_node.getValue(arg)

  def __len__(self):
    return self.c_node.getLength()

  def __str__(self):
    self.c_node.show()

  cdef setup(self, node[char]* node):
    self.c_node = node

  cpdef char getValue(self, x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()


cdef class float_node:
  cdef node[float]*c_node
  def __cinit__(self):
    self.c_node = new node[float]()

  def __getitem__(self, arg):
    return self.c_node.getValue(arg)

  def __len__(self):
    return self.c_node.getLength()

  def __str__(self):
    self.c_node.show()

  cdef setup(self, node[float]* node):
    self.c_node = node

  cpdef float getValue(self, x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()

cdef class short_node:
  cdef node[short]*c_node
  def __cinit__(self):
    self.c_node = new node[short]()

  def __getitem__(self, arg):
    return self.c_node.getValue(arg)

  def __len__(self):
    return self.c_node.getLength()

  def __str__(self):
    self.c_node.show()

  cdef setup(self, node[short]* node):
    self.c_node = node

  cpdef short getValue(self, x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()

cdef class hipo_reader:
  """Hipo_reader based on hipo::reader class"""
  # Define hipo::reader class
  cdef reader*c_reader
  def __cinit__(self, str filename):
    """Initialize hipo_reader with a file"""
    self.c_reader = new reader()
    self.open(filename)

  def __str__(self):
    return self.jsonString()

  def __repr__(self):
    return self.jsonString()

  cpdef void open(self, str filename):
    """Open a new hipo file with the hipo::reader"""
    cdef bytes filename_bytes = filename.encode()
    cdef char* c_filename = filename_bytes
    self.c_reader.open(c_filename)

  def isOpen(self):
    """Check if the file is open"""
    return self.c_reader.isOpen()

  def showInfo(self):
    """Shows the files info from hipo::reader.showInfo()"""
    self.c_reader.showInfo()

  def getRecordCount(self):
    """Return the number of records in the file"""
    return self.c_reader.getRecordCount()

  def next(self):
    """Load the next vaules of the ntuple [Returns true if there is an event]"""
    return self.c_reader.next()

  def __next__(self):
    """Load the next vaules of the ntuple [Returns true if there is an event]"""
    return self.c_reader.next()

  def getDictionary(self):
    """Get dictionary string from hipo file [More useful to use getjson]"""
    return self.c_reader.getDictionary()

  def jsonString(self):
    """Get dictionary as string"""
    hipo_dict = self.c_reader.getDictionary()
    out = []
    out.append("[{\n")
    for dic in hipo_dict:
        dic = str(dic)
        dic = dic.split("{")[1].split("}")
        bank = dic[0].split(",")
        out.append("\t\"bank\" : \""+bank[1]+"\",\n")
        out.append("\t\"group\" : "+ bank[0]+",\n")
        out.append("\t\t\"items\": [\n")
        items = dic[1].split("[")
        ids = []
        for x in items[1:]:
            ids = x.split("]")[0].split(",")
            out.append("\t\t{")
            out.append("\"name\": \"{0}\", \"id\": {1}, \"type\": \"{2}\"".format(ids[1],ids[0],str(ids[2]).lower()))
            out.append("},\n")
        out[-1] = "}\t]\n},\n{\n"

    out[-1] = "}\n]\n}\n]"
    out = ''.join(out)
    return out

  def getJson(self):
    """Get dictionary as a json object"""
    return json.loads(self.jsonString())

  def getIntNode(self, str group, str item):
    """Create a hipo::node<int> which is accesible to python"""
    cdef node[int]*c_node
    c_group = str_to_char(group)
    c_item = str_to_char(item)
    c_node = self.c_reader.getBranch[int](c_group,c_item)
    py_node = int_node()
    py_node.setup(c_node)
    return py_node

  def getByteNode(self, str group, str item):
    """Create a hipo::node<char> which is accesible to python"""
    cdef node[char]*c_node
    c_group = str_to_char(group)
    c_item = str_to_char(item)
    c_node = self.c_reader.getBranch[char](c_group,c_item)
    py_node = char_node()
    py_node.setup(c_node)
    return py_node

  def getFloatNode(self, str group, str item):
    """Create a hipo::node<float> which is accesible to python"""
    cdef node[float]*c_node
    c_group = str_to_char(group)
    c_item = str_to_char(item)
    c_node = self.c_reader.getBranch[float](c_group,c_item)
    py_node = float_node()
    py_node.setup(c_node)
    return py_node

  def getShortNode(self, str group, str item):
    """Create a hipo::node<short> which is accesible to python"""
    cdef node[short]*c_node
    c_group = str_to_char(group)
    c_item = str_to_char(item)
    c_node = self.c_reader.getBranch[short](c_group,c_item)
    py_node = short_node()
    py_node.setup(c_node)
    return py_node

cdef class Particle:
  cdef int pid
  cdef double m
  cdef double px
  cdef double py
  cdef double pz
  cdef double P2
  cdef double P
  cdef double E
  def __cinit__(self, double px, double py, double pz, int pid):
    self.pid = pid
    self.m = part_mass.get(self.pid, 0)
    self.px = px
    self.py = py
    self.pz = pz
    self.P2 = (px**2 + py**2 + pz**2)
    self.P = sqrt(self.P2)
    self.E = sqrt(self.P2 + self.m**2)
  cpdef double mass(self):
    return self.m

class Events:
  def __init__(self, hipo_reader reader):
    self.hiporeader = reader
    self._run = self.hiporeader.getIntNode(u"RUN::config",u"run")
    self._pid = self.hiporeader.getIntNode(u"REC::Particle", u"pid")
    self._px = self.hiporeader.getFloatNode(u"REC::Particle", u"px")
    self._py = self.hiporeader.getFloatNode(u"REC::Particle", u"py")
    self._pz = self.hiporeader.getFloatNode(u"REC::Particle", u"pz")
    self._vx = self.hiporeader.getFloatNode(u"REC::Particle", u"vx")
    self._vy = self.hiporeader.getFloatNode(u"REC::Particle", u"vy")
    self._vz = self.hiporeader.getFloatNode(u"REC::Particle", u"vz")
    self._charge = self.hiporeader.getByteNode(u"REC::Particle", u"charge")
    self._beta = self.hiporeader.getFloatNode(u"REC::Particle", u"beta")
  def __len__(self):
    return self._pid.getLength()
  def __iter__(self):
      return self
  def next(self):
    if self.hiporeader.next():
      self.loadParts()
      return self
    else:
      raise StopIteration
  def loadParts(self):
    if self._run.getLength() > 0:
      self.run = self._run[0]
    cdef l = len(self)
    self.pid = np.zeros(l,dtype=np.int)
    self.px = np.zeros(l,dtype=np.float)
    self.py = np.zeros(l,dtype=np.float)
    self.pz = np.zeros(l,dtype=np.float)
    self.vx = np.zeros(l,dtype=np.float)
    self.vy = np.zeros(l,dtype=np.float)
    self.vz = np.zeros(l,dtype=np.float)
    self.charge = np.zeros(l,dtype=np.int)
    self.beta = np.zeros(l,dtype=np.float)
    self.particles = [None] * l
    cdef int i = 0
    for i in range(0, l):
      self.pid[i] = self._pid[i]
      self.px[i] = self._px[i]
      self.py[i] = self._py[i]
      self.pz[i] = self._pz[i]
      self.vx[i] = self._vx[i]
      self.vy[i] = self._vy[i]
      self.vz[i] = self._vz[i]
      self.charge[i] = self._charge[i]
      self.beta[i] = self._beta[i]
      self.particles[i] = Particle(self.px[i],self.py[i],self.pz[i],self.pid[i])
