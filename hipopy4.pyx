# cython: profile=True
# distutils: language = c++
# cython: boundscheck=False

cimport cython

from libcpp.string cimport string
from libcpp cimport bool
#from libcpp.map cimport map
#from libcpp.utility cimport pair
#from libcpp.vector cimport vector
#from cython.view cimport array as cvarray
#from libc.stdlib cimport free
#import numpy as np

cdef extern from "hipo4/dictionary.h" namespace "hipo":
    cdef cppclass schema:
      schema() except +
      string json()

cdef extern from "hipo4/dictionary.h" namespace "hipo":
    cdef cppclass dictionary:
      dictionary() except +
      schema getSchema(string)

cdef extern from "hipo4/bank.h" namespace "hipo":
    cdef cppclass bank:
      bank() except +
      bank(schema) except +
      int    getRows()
      int    getInt(string, int)
      int    getShort(string, int)
      int    getByte(string, int)
      float  getFloat(string, int)
      double getDouble(string, int)
      long   getLong(string, int)

cdef extern from "hipo4/event.h" namespace "hipo":
    cdef cppclass event:
      event() except +
      void getStructure(bank)


cdef extern from "hipo4/reader.h" namespace "hipo":
    cdef cppclass reader:
      reader() except +
      reader(char*) except +
      reader(string) except +
      void read(event)
      dictionary* dictionary()
      void readDictionary(dictionary)
      void open(string)
      bool hasNext()
      bool next()



cdef class node:
  cdef dictionary*c_dict
  cdef schema*c_schema
  cdef bank*c_bank
  def __init__(self, name):
      self.name = name
      self.c_dict = new dictionary()
      self.c_bank = new bank(self.c_dict.getSchema(self.name))
  def getInt(self, name, i):
    return self.c_bank.getInt(name, i)
  def getShort(self, name, i):
    return self.c_bank.getShort(name, i)
  def getByte(self, name, i):
    return self.c_bank.getByte(name, i)
  def getFloat(self, name, i):
    return self.c_brank.getFloat(name, i)
  def getDouble(self, name, i):
    return self.c_brank.getDouble(name, i)
  def getLong(self, name, i):
    return self.c_brank.getLong(name, i)

cdef char* str_to_char(str name):
  """Convert python string to char*"""
  cdef bytes name_bytes = name.encode()
  cdef char* c_name = name_bytes
  return c_name

cdef class Event:
  cdef:
    reader*c_hiporeader
    dictionary*c_dict
    event*c_event
    bank*c_ForwardTagger
    bank*c_VertDoca
    bank*c_Track
    bank*c_Cherenkov
    bank*c_Event
    bank*c_Particle
    bank*c_Scintillator
    bank*c_Calorimeter
    bank*c_CovMat
  def __cinit__(Event self, string filename):
    self.c_hiporeader = new reader(filename)
    self.c_dict = self.c_hiporeader.dictionary()
    self.c_event = new event()
    self.c_ForwardTagger = new bank(self.c_dict.getSchema("REC::ForwardTagger".encode('utf8')))
    self.c_VertDoca = new bank(self.c_dict.getSchema("REC::VertDoca".encode('utf8')))
    self.c_Track = new bank(self.c_dict.getSchema("REC::Track".encode('utf8')))
    self.c_Cherenkov = new bank(self.c_dict.getSchema("REC::Cherenkov".encode('utf8')))
    self.c_Event = new bank(self.c_dict.getSchema("REC::Event".encode('utf8')))
    self.c_Particle = new bank(self.c_dict.getSchema("REC::Particle".encode('utf8')))
    self.c_Scintillator = new bank(self.c_dict.getSchema("REC::Scintillator".encode('utf8')))
    self.c_Calorimeter = new bank(self.c_dict.getSchema("REC::Calorimeter".encode('utf8')))
    self.c_CovMat = new bank(self.c_dict.getSchema("REC::CovMat".encode('utf8')))

  def __len__(Event self):
    return self._pid.getLength()
  def __iter__(Event self):
      return self
  def __str__(Event self):
    out = ""
    out += self.c_dict.getSchema("REC::ForwardTagger".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::VertDoca".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Track".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Cherenkov".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Event".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Particle".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Scintillator".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Calorimeter".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::CovMat".encode('utf8')).json()
    return out
  def __next__(Event self):
    if self.c_hiporeader.next():
      self.c_hiporeader.read(self.c_event[0])
      self.c_event.getStructure(self.c_Particle[0])
      self.c_event.getStructure(self.c_ForwardTagger[0])
      self.c_event.getStructure(self.c_VertDoca[0])
      self.c_event.getStructure(self.c_Track[0])
      self.c_event.getStructure(self.c_Cherenkov[0])
      self.c_event.getStructure(self.c_Event[0])
      self.c_event.getStructure(self.c_Scintillator[0])
      self.c_event.getStructure(self.c_Calorimeter[0])
      self.c_event.getStructure(self.c_CovMat[0])
      return self
    else:
      raise StopIteration
  def __len__(Event self):
    return self.c_Particle.getRows()
  def pid(Event self, int i):
    return self.c_Particle.getFloat("pid".encode('utf8') ,i)
  def px(Event self, int i):
    return self.c_Particle.getFloat("px".encode('utf8') ,i)
  def py(Event self, int i):
    return self.c_Particle.getFloat("py".encode('utf8') ,i)
  def pz(Event self, int i):
    return self.c_Particle.getFloat("pz".encode('utf8') ,i)
  def vx(Event self, int i):
    return self.c_Particle.getFloat("vx".encode('utf8') ,i)
  def vy(Event self, int i):
    return self.c_Particle.getFloat("vy".encode('utf8') ,i)
  def vz(Event self, int i):
    return self.c_Particle.getFloat("vz".encode('utf8') ,i)
  def charge(Event self, int i):
    return self.c_Particle.getByte("charge".encode('utf8'), i)
  def beta(Event self, int i):
    return self.c_Particle.getFloat("beta".encode('utf8'), i)
  def chi2pid(Event self, int i):
    return self.c_Particle.getFloat("chi2pid".encode('utf8'), i)
  def status(Event self, int i):
    return self.c_Particle.getShort("status".encode('utf8'), i)

  def event_len(Event self):
    return self.c_Event.getRows()
  def NRUN(Event self):
    return self.c_Event.getInt("NRUN".encode('utf8'),0)
  def NEVENT(Event self):
    return self.c_Event.getInt("NEVENT".encode('utf8'),0)
  def EVNTime(Event self):
    return self.c_Event.getFloat("EVNTime".encode('utf8'),0)
  def TYPE(Event self):
    return self.c_Event.getByte("TYPE".encode('utf8'),0)
  def EvCAT(Event self):
    return self.c_Event.getShort("EvCAT".encode('utf8'),0)
  def NPGP(Event self):
    return self.c_Event.getShort("NPGP".encode('utf8'),0)
  def TRG(Event self):
    return self.c_Event.getLong("TRG".encode('utf8'),0)
  def BCG(Event self):
    return self.c_Event.getFloat("BCG".encode('utf8'),0)
  def LT(Event self):
    return self.c_Event.getDouble("LT".encode('utf8'),0)
  def STTime(Event self):
    return self.c_Event.getFloat("STTime".encode('utf8'),0)
  def RFTime(Event self):
    return self.c_Event.getFloat("RFTime".encode('utf8'),0)
  def Helic(Event self):
    return self.c_Event.getByte("Helic".encode('utf8'),0)
  def PTIME(Event self):
    return self.c_Event.getFloat("PTIME".encode('utf8'),0)

  def ft_len(Event self):
    return self.c_ForwardTagger.getRows()
  def ft_pindex(Event self, int i):
    return self.c_ForwardTagger.getShort("pindex".encode('utf8'), i)
  def ft_detector(Event self, int i):
    return self.c_ForwardTagger.getByte("detector".encode('utf8'), i)
  def ft_energy(Event self, int i):
    return self.c_ForwardTagger.getFloat("energy".encode('utf8'), i)
  def ft_time(Event self, int i):
    return self.c_ForwardTagger.getFloat("time".encode('utf8'), i)
  def ft_path(Event self, int i):
    return self.c_ForwardTagger.getFloat("path".encode('utf8'), i)
  def ft_chi2(Event self, int i):
    return self.c_ForwardTagger.getFloat("chi2".encode('utf8'), i)
  def ft_x(Event self, int i):
    return self.c_ForwardTagger.getFloat("x".encode('utf8'), i)
  def ft_y(Event self, int i):
    return self.c_ForwardTagger.getFloat("y".encode('utf8'), i)
  def ft_z(Event self, int i):
    return self.c_ForwardTagger.getFloat("z".encode('utf8'), i)
  def ft_dx(Event self, int i):
    return self.c_ForwardTagger.getFloat("dx".encode('utf8'), i)
  def ft_dy(Event self, int i):
    return self.c_ForwardTagger.getFloat("dy".encode('utf8'), i)
  def ft_radius(Event self, int i):
    return self.c_ForwardTagger.getFloat("radius".encode('utf8'), i)
  def ft_size(Event self, int i):
    return self.c_ForwardTagger.getShort("size".encode('utf8'), i)
  def ft_status(Event self, int i):
    return self.c_ForwardTagger.getShort("status".encode('utf8'), i)

  def vd_len(Event self):
    return self.c_VertDoca.getRows()
  def vd_index1(Event self, int i):
    return self.c_VertDoca.getShort("index1".encode('utf8'),i)
  def vd_index2(Event self, int i):
    return self.c_VertDoca.getShort("index2".encode('utf8'),i)
  def vd_x(Event self, int i):
    return self.c_VertDoca.getFloat("x".encode('utf8'),i)
  def vd_y(Event self, int i):
    return self.c_VertDoca.getFloat("y".encode('utf8'),i)
  def vd_z(Event self, int i):
    return self.c_VertDoca.getFloat("z".encode('utf8'),i)
  def vd_x1(Event self, int i):
    return self.c_VertDoca.getFloat("x1".encode('utf8'),i)
  def vd_y1(Event self, int i):
    return self.c_VertDoca.getFloat("y1".encode('utf8'),i)
  def vd_z1(Event self, int i):
    return self.c_VertDoca.getFloat("z1".encode('utf8'),i)
  def vd_cx1(Event self, int i):
    return self.c_VertDoca.getFloat("cx1".encode('utf8'),i)
  def vd_cy1(Event self, int i):
    return self.c_VertDoca.getFloat("cy1".encode('utf8'),i)
  def vd_cz1(Event self, int i):
    return self.c_VertDoca.getFloat("cz1".encode('utf8'),i)
  def vd_x2(Event self, int i):
    return self.c_VertDoca.getFloat("x2".encode('utf8'),i)
  def vd_y2(Event self, int i):
    return self.c_VertDoca.getFloat("y2".encode('utf8'),i)
  def vd_z2(Event self, int i):
    return self.c_VertDoca.getFloat("z2".encode('utf8'),i)
  def vd_cx2(Event self, int i):
    return self.c_VertDoca.getFloat("cx2".encode('utf8'),i)
  def vd_cy2(Event self, int i):
    return self.c_VertDoca.getFloat("cy2".encode('utf8'),i)
  def vd_cz2(Event self, int i):
    return self.c_VertDoca.getFloat("cz2".encode('utf8'),i)
  def vd_r(Event self, int i):
    return self.c_VertDoca.getFloat("r".encode('utf8'),i)

  def trk_len(Event self):
      return self.c_Track.getRows()
  def trk_index(Event self, int i):
    return self.c_Track.getShort("index".encode('utf8'),i)
  def trk_pindex(Event self, int i):
    return self.c_Track.getShort("pindex".encode('utf8'),i)
  def trk_detector(Event self, int i):
    return self.c_Track.getByte("detector".encode('utf8'),i)
  def trk_sector(Event self, int i):
    return self.c_Track.getByte("sector".encode('utf8'),i)
  def trk_status(Event self, int i):
    return self.c_Track.getShort("status".encode('utf8'),i)
  def trk_q(Event self, int i):
    return self.c_Track.getByte("q".encode('utf8'),i)
  def trk_chi2(Event self, int i):
    return self.c_Track.getFloat("chi2".encode('utf8'),i)
  def trk_NDF(Event self, int i):
    return self.c_Track.getShort("NDF".encode('utf8'),i)
  def trk_px_nomm(Event self, int i):
    return self.c_Track.getFloat("px_nomm".encode('utf8'),i)
  def trk_py_nomm(Event self, int i):
    return self.c_Track.getFloat("py_nomm".encode('utf8'),i)
  def trk_pz_nomm(Event self, int i):
    return self.c_Track.getFloat("pz_nomm".encode('utf8'),i)
  def trk_vx_nomm(Event self, int i):
    return self.c_Track.getFloat("vx_nomm".encode('utf8'),i)
  def trk_vy_nomm(Event self, int i):
    return self.c_Track.getFloat("vy_nomm".encode('utf8'),i)
  def trk_vz_nomm(Event self, int i):
    return self.c_Track.getFloat("vz_nomm".encode('utf8'),i)
  def trk_chi2_nomm(Event self, int i):
    return self.c_Track.getFloat("chi2_nomm".encode('utf8'),i)
  def trk_NDF_nomm(Event self, int i):
    return self.c_Track.getShort("NDF_nomm".encode('utf8'),i)

  def chern_len(Event self):
      return self.c_Cherenkov.getRows()
  def chern_index(Event self, int i):
    return self.c_Cherenkov.getShort("index".encode('utf8'),i)
  def chern_pindex(Event self, int i):
    return self.c_Cherenkov.getShort("pindex".encode('utf8'),i)
  def chern_detector(Event self, int i):
    return self.c_Cherenkov.getByte("detector".encode('utf8'),i)
  def chern_sector(Event self, int i):
    return self.c_Cherenkov.getByte("sector".encode('utf8'),i)
  def chern_nphe(Event self, int i):
    return self.c_Cherenkov.getFloat("nphe".encode('utf8'),i)
  def chern_time(Event self, int i):
    return self.c_Cherenkov.getFloat("time".encode('utf8'),i)
  def chern_path(Event self, int i):
    return self.c_Cherenkov.getFloat("path".encode('utf8'),i)
  def chern_chi2(Event self, int i):
    return self.c_Cherenkov.getFloat("chi2".encode('utf8'),i)
  def chern_x(Event self, int i):
    return self.c_Cherenkov.getFloat("x".encode('utf8'),i)
  def chern_y(Event self, int i):
    return self.c_Cherenkov.getFloat("y".encode('utf8'),i)
  def chern_z(Event self, int i):
    return self.c_Cherenkov.getFloat("z".encode('utf8'),i)
  def chern_theta(Event self, int i):
    return self.c_Cherenkov.getFloat("theta".encode('utf8'),i)
  def chern_phi(Event self, int i):
    return self.c_Cherenkov.getFloat("phi".encode('utf8'),i)
  def chern_dtheta(Event self, int i):
    return self.c_Cherenkov.getFloat("dtheta".encode('utf8'),i)
  def chern_dphi(Event self, int i):
    return self.c_Cherenkov.getFloat("dphi".encode('utf8'),i)
  def chern_status(Event self, int i):
    return self.c_Cherenkov.getShort("status".encode('utf8'),i)

  def sc_len(Event self):
    return self.c_Scintillator.getRows()
  def sc_index(Event self, int i):
    return self.c_Scintillator.getShort("index".encode('utf8'),i)
  def sc_pindex(Event self, int i):
    return self.c_Scintillator.getShort("pindex".encode('utf8'),i)
  def sc_detector(Event self, int i):
    return self.c_Scintillator.getByte("detector".encode('utf8'),i)
  def sc_sector(Event self, int i):
    return self.c_Scintillator.getByte("sector".encode('utf8'),i)
  def sc_layer(Event self, int i):
    return self.c_Scintillator.getByte("layer".encode('utf8'),i)
  def sc_component(Event self, int i):
    return self.c_Scintillator.getShort("component".encode('utf8'),i)
  def sc_energy(Event self, int i):
    return self.c_Scintillator.getFloat("energy".encode('utf8'),i)
  def sc_time(Event self, int i):
    return self.c_Scintillator.getFloat("time".encode('utf8'),i)
  def sc_path(Event self, int i):
    return self.c_Scintillator.getFloat("path".encode('utf8'),i)
  def sc_chi2(Event self, int i):
    return self.c_Scintillator.getFloat("chi2".encode('utf8'),i)
  def sc_x(Event self, int i):
    return self.c_Scintillator.getFloat("x".encode('utf8'),i)
  def sc_y(Event self, int i):
    return self.c_Scintillator.getFloat("y".encode('utf8'),i)
  def sc_z(Event self, int i):
    return self.c_Scintillator.getFloat("z".encode('utf8'),i)
  def sc_hx(Event self, int i):
    return self.c_Scintillator.getFloat("hx".encode('utf8'),i)
  def sc_hy(Event self, int i):
    return self.c_Scintillator.getFloat("hy".encode('utf8'),i)
  def sc_hz(Event self, int i):
    return self.c_Scintillator.getFloat("hz".encode('utf8'),i)
  def sc_status(Event self, int i):
    return self.c_Scintillator.getShort("status".encode('utf8'),i)

  def cal_len(Event self):
    return self.c_Calorimeter.getRows()
  def cal_in(Event self, int i):
    return self.c_Calorimeter.getShort("index".encode('utf8'),i)
  def cal_pi(Event self, int i):
    return self.c_Calorimeter.getShort("pindex".encode('utf8'),i)
  def cal_de(Event self, int i):
    return self.c_Calorimeter.getByte("detector".encode('utf8'),i)
  def cal_se(Event self, int i):
    return self.c_Calorimeter.getByte("sector".encode('utf8'),i)
  def cal_la(Event self, int i):
    return self.c_Calorimeter.getByte("layer".encode('utf8'),i)
  def cal_en(Event self, int i):
    return self.c_Calorimeter.getFloat("energy".encode('utf8'),i)
  def cal_ti(Event self, int i):
    return self.c_Calorimeter.getFloat("time".encode('utf8'),i)
  def cal_pa(Event self, int i):
    return self.c_Calorimeter.getFloat("path".encode('utf8'),i)
  def cal_ch(Event self, int i):
    return self.c_Calorimeter.getFloat("chi2".encode('utf8'),i)
  def cal_x(Event self, int i):
    return self.c_Calorimeter.getFloat("x".encode('utf8'),i)
  def cal_y(Event self, int i):
    return self.c_Calorimeter.getFloat("y".encode('utf8'),i)
  def cal_z(Event self, int i):
    return self.c_Calorimeter.getFloat("z".encode('utf8'),i)
  def cal_hx(Event self, int i):
    return self.c_Calorimeter.getFloat("hx".encode('utf8'),i)
  def cal_hy(Event self, int i):
    return self.c_Calorimeter.getFloat("hy".encode('utf8'),i)
  def cal_hz(Event self, int i):
    return self.c_Calorimeter.getFloat("hz".encode('utf8'),i)
  def cal_lu(Event self, int i):
    return self.c_Calorimeter.getFloat("lu".encode('utf8'),i)
  def cal_lv(Event self, int i):
    return self.c_Calorimeter.getFloat("lv".encode('utf8'),i)
  def cal_lw(Event self, int i):
    return self.c_Calorimeter.getFloat("lw".encode('utf8'),i)
  def cal_du(Event self, int i):
    return self.c_Calorimeter.getFloat("du".encode('utf8'),i)
  def cal_dv(Event self, int i):
    return self.c_Calorimeter.getFloat("dv".encode('utf8'),i)
  def cal_dw(Event self, int i):
    return self.c_Calorimeter.getFloat("dw".encode('utf8'),i)
  def cal_m2(Event self, int i):
    return self.c_Calorimeter.getFloat("m2u".encode('utf8'),i)
  def cal_m2(Event self, int i):
    return self.c_Calorimeter.getFloat("m2v".encode('utf8'),i)
  def cal_m2(Event self, int i):
    return self.c_Calorimeter.getFloat("m2w".encode('utf8'),i)
  def cal_m3(Event self, int i):
    return self.c_Calorimeter.getFloat("m3u".encode('utf8'),i)
  def cal_m3(Event self, int i):
    return self.c_Calorimeter.getFloat("m3v".encode('utf8'),i)
  def cal_m3(Event self, int i):
    return self.c_Calorimeter.getFloat("m3w".encode('utf8'),i)
  def cal_st(Event self, int i):
    return self.c_Calorimeter.getShort("status".encode('utf8'),i)
