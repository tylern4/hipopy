# distutils: language = c++
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool
import numpy as np
from libc.math cimport sqrt, log, atan2

get_id = {'PROTON': 2212, 'NEUTRON': 2112, 'PIP': 211, 'PIM': -211,
          'PI0': 111, 'KP': 321, 'KM': -321, 'PHOTON': 22, 'ELECTRON': 11}

part_mass = {11: 0.000511, 211: 0.13957, -211: 0.13957, 2212: 0.93827,
          2112: 0.939565, 321: 0.493667, -321: 0.493667, 22: 0}

import json


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

cdef class int_node:
  cdef node[int]*c_node

  def __cinit__(self):
    self.c_node = new node[int]()

  def __getitem__(self, int x):
    return self.c_node.getValue(x)

  def __len__(self):
    return self.c_node.getLength()

  def show(self):
    self.c_node.show()

  cdef setup(self, node[int]* node):
    self.c_node = node

  cpdef int getValue(self, int x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()


cdef class char_node:
  cdef node[char]*c_node

  def __cinit__(self):
    self.c_node = new node[char]()

  def __getitem__(self, int x):
    return self.c_node.getValue(x)

  def __len__(self):
    return self.c_node.getLength()

  def show(self):
    self.c_node.show()

  cdef setup(self, node[char]* node):
    self.c_node = node

  cpdef char getValue(self, int x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()


cdef class float_node:
  cdef node[float]*c_node
  def __cinit__(self):
    self.c_node = new node[float]()

  def __getitem__(self, int x):
    return self.c_node.getValue(x)

  def __len__(self):
    return self.c_node.getLength()

  def show(self):
    self.c_node.show()

  cdef setup(self, node[float]* node):
    self.c_node = node

  cpdef float getValue(self, int x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()

cdef class short_node:
  cdef node[short]*c_node
  def __cinit__(self):
    self.c_node = new node[short]()

  def __getitem__(self, int x):
    return self.c_node.getValue(x)

  def __len__(self):
    return self.c_node.getLength()

  def show(self):
    self.c_node.show()

  cdef setup(self, node[short]* node):
    self.c_node = node

  cpdef short getValue(self, int x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()

cdef class long_node:
  cdef node[long]*c_node
  def __cinit__(self):
    self.c_node = new node[long]()

  def __getitem__(self, int x):
    return self.c_node.getValue(x)

  def __len__(self):
    return self.c_node.getLength()

  def show(self):
    self.c_node.show()

  cdef setup(self, node[long]* node):
    self.c_node = node

  cpdef long getValue(self, int x):
    return self.c_node.getValue(x)

  cpdef int getLength(self):
    return self.c_node.getLength()

cdef class hipo_reader:
  """Hipo_reader based on hipo::reader class"""
  # Define hipo::reader class
  cdef reader*c_reader
  def __cinit__(self, filename):
    """Initialize hipo_reader with a file"""
    self.c_reader = new reader()
    self.open(filename)

  def __str__(self):
    return self.jsonString()

  def __repr__(self):
    return self.jsonString()

  cdef void open(self, filename):
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
  cpdef int_node getIntNode(self, group, item):
    """Create a hipo::node<int> which is accesible to python"""
    cdef node[int]*c_node
    c_node = self.c_reader.getBranch[int](group, item)
    py_node = int_node()
    py_node.setup(c_node)
    return py_node
  cpdef long_node getLongNode(self, group, item):
    """Create a hipo::node<long> which is accesible to python"""
    cdef node[long]*c_node
    c_node = self.c_reader.getBranch[long](group, item)
    py_node = long_node()
    py_node.setup(c_node)
    return py_node
  cpdef char_node getInt8Node(self, group, item):
    """Create a hipo::node<int8_t> which is accesible to python"""
    cdef node[char]*c_node
    c_node = self.c_reader.getBranch[char](group, item)
    py_node = char_node()
    py_node.setup(c_node)
    return py_node
  cpdef getFloatNode(self, group, item):
    """Create a hipo::node<float> which is accesible to python"""
    cdef node[float]*c_node
    c_node = self.c_reader.getBranch[float](group, item)
    py_node = float_node()
    py_node.setup(c_node)
    return py_node
  cpdef short_node getInt16Node(self, group, item):
    """Create a hipo::node<int16_t> which is accesible to python"""
    cdef node[short]*c_node
    c_node = self.c_reader.getBranch[short](group, item)
    py_node = short_node()
    py_node.setup(c_node)
    return py_node

cdef class LorentzVector:
  cdef public double px, py, pz, mass, P2, P, energy
  def __cinit__(LorentzVector self, double px, double py, double pz, double mass):
    self.px = px
    self.py = py
    self.pz = pz
    self.mass = mass
    self.P2 = (px**2 + py**2 + pz**2)
    self.P = sqrt(self.P2)
    self.energy = sqrt(self.P2 + self.mass**2)
  def __add__(LorentzVector self, LorentzVector other):
    return LorentzVector(self.px + other.px, self.py + other.py,
                          self.pz + other.pz, self.energy + other.energy)
  def __str__(self):
    return "Px {0: 0.2f} | Py {1: 0.2f} | Pz {2: 0.2f} | E {3: 0.2f}".format(self.px,self.py ,self.pz, self.energy)
  def __repr__(self):
    return self.__str__()
  @property
  def Mag2(LorentzVector self):
    return self.energy**2 - self.P2
  @property
  def M2(LorentzVector self):
    return self.Mag2
  @property
  def Mag(LorentzVector self):
    if self.Mag2 < 0.0:
      return -sqrt(-self.Mag2)
    else:
      return sqrt(self.Mag2)
  @property
  def M(LorentzVector self):
    return self.Mag

cdef class ThreeVector:
  cdef public double vx, vy, vz, L2, L
  def __cinit__(ThreeVector self, double vx, double vy, double vz):
    self.vx = vx
    self.vy = vy
    self.vz = vz
    self.L2 = (vx**2 + vy**2 + vz**2)
    self.L = sqrt(self.L2)
  def __add__(ThreeVector self, ThreeVector other):
    return ThreeVector(self.vx + other.vx, self.vy + other.vy, self.vz + other.vz)


cdef class Particle:
  cdef public int pid, charge
  cdef public double mass, vx, vy, vz, beta
  cdef public LorentzVector FourVector
  cdef public ThreeVector Vertex
  def __cinit__(Particle self, double px, double py, double pz, int pid, double vx, double vy, double vz, int charge, double beta):
    self.pid = pid
    self.charge = charge
    self.Vertex = ThreeVector(vx, vy, vz)
    self.beta = beta
    self.mass = part_mass.get(self.pid, 0)
    self.FourVector = LorentzVector(px, py, pz, self.mass)
  def __add__(Particle self, Particle other):
    return self.FourVector + other.FourVector
  def __str__(Particle self):
    return "pid {:5d} | ".format(self.pid) + self.FourVector.__str__()
  def __repr__(Particle self):
    return self.__str__()
  @property
  def Mag2(Particle self):
    return self.FourVector.Mag2
  @property
  def M2(Particle self):
    return self.FourVector.Mag2
  @property
  def Mag(Particle self):
    return self.FourVector.Mag
  @property
  def M(Particle self):
    return self.FourVector.Mag

cdef class Event:
  cdef hipo_reader hiporeader
  cdef int_node _run, _pid
  cdef char_node _charge
  cdef float_node _px,_py,_pz,_vx,_vy,_vz,_beta
  cdef int run
  cdef public list particles
  def __cinit__(Event self, hipo_reader reader):
    self.hiporeader = reader
    self._run = self.hiporeader.getIntNode("RUN::config","run")
    self._pid = self.hiporeader.getIntNode("REC::Particle", "pid")
    self._px = self.hiporeader.getFloatNode("REC::Particle", "px")
    self._py = self.hiporeader.getFloatNode("REC::Particle", "py")
    self._pz = self.hiporeader.getFloatNode("REC::Particle", "pz")
    self._vx = self.hiporeader.getFloatNode("REC::Particle", "vx")
    self._vy = self.hiporeader.getFloatNode("REC::Particle", "vy")
    self._vz = self.hiporeader.getFloatNode("REC::Particle", "vz")
    self._charge = self.hiporeader.getInt8Node("REC::Particle", "charge")
    self._beta = self.hiporeader.getFloatNode("REC::Particle", "beta")
  def __len__(Event self):
    return self._pid.getLength()
  def __iter__(Event self):
      return self
  def next(Event self):
    if self.hiporeader.next():
      self.loadParts()
      return self
    else:
      raise StopIteration
  def __next__(Event self):
    if self.hiporeader.next():
      self.loadParts()
      return self
    else:
      raise StopIteration
  def loadParts(Event self):
    if self._run.getLength() > 0:
      self.run = self._run[0]
    cdef int l = len(self)
    cdef int i = 0
    self.particles = [None] * l
    for i in range(0, l):
      self.particles[i] = Particle(self._px[i], self._py[i], self._pz[i], self._pid[i],
                          self._vx[i], self._vy[i], self._vz[i], self._charge[i], self._beta[i])
