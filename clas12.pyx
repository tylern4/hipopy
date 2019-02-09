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
import numpy as np
cimport numpy as np


clas12_detector = {"BMT":  1,
"BST":  2,
"CND":  3,
"CTOF":  4,
"CVT":  5,
"DC":  6,
"ECAL":  7,
"FMT":  8,
"FT":  9,
"FTCAL": 10,
"FTHODO": 11,
"FTOF": 12,
"FTTRK": 13,
"HTCC": 15,
"LTCC": 16,
"RF": 17,
"RICH": 18,
"RTPC": 19,
"HEL": 20,
"BAND": 21}


clas12_layer = {"FTOF_1A": 1,"FTOF_1B": 2,"FTOF_2": 3,"PCAL": 1,"EC_INNER": 4,"EC_OUTER": 7}

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

cdef class clas12Event:
  cdef:
    reader*c_hiporeader
    dictionary*c_dict
    event*c_hipo_event
    bank*c_ForwardTagger
    bank*c_Track
    bank*c_Cherenkov
    bank*c_Particle
    bank*c_Scintillator
    bank*c_Calorimeter
    # EC
    np.ndarray ec_tot_energy
    np.ndarray ec_pcal_energy
    np.ndarray ec_pcal_sec
    np.ndarray ec_pcal_time
    np.ndarray ec_pcal_path
    np.ndarray ec_pcal_x
    np.ndarray ec_pcal_y
    np.ndarray ec_pcal_z
    np.ndarray ec_pcal_lu
    np.ndarray ec_pcal_lv
    np.ndarray ec_pcal_lw
    np.ndarray ec_ecin_energy
    np.ndarray ec_ecin_sec
    np.ndarray ec_ecin_time
    np.ndarray ec_ecin_path
    np.ndarray ec_ecin_x
    np.ndarray ec_ecin_y
    np.ndarray ec_ecin_z
    np.ndarray ec_ecin_lu
    np.ndarray ec_ecin_lv
    np.ndarray ec_ecin_lw
    np.ndarray ec_ecout_energy
    np.ndarray ec_ecout_sec
    np.ndarray ec_ecout_time
    np.ndarray ec_ecout_path
    np.ndarray ec_ecout_x
    np.ndarray ec_ecout_y
    np.ndarray ec_ecout_z
    np.ndarray ec_ecout_lu
    np.ndarray ec_ecout_lv
    np.ndarray ec_ecout_lw

    # SC
    np.ndarray sc_ftof_1a_sec
    np.ndarray sc_ftof_1a_time
    np.ndarray sc_ftof_1a_path
    np.ndarray sc_ftof_1a_energy
    np.ndarray sc_ftof_1a_component
    np.ndarray sc_ftof_1a_x
    np.ndarray sc_ftof_1a_y
    np.ndarray sc_ftof_1a_z
    np.ndarray sc_ftof_1a_hx
    np.ndarray sc_ftof_1a_hy
    np.ndarray sc_ftof_1a_hz
    np.ndarray sc_ftof_1b_sec
    np.ndarray sc_ftof_1b_time
    np.ndarray sc_ftof_1b_path
    np.ndarray sc_ftof_1b_energy
    np.ndarray sc_ftof_1b_component
    np.ndarray sc_ftof_1b_x
    np.ndarray sc_ftof_1b_y
    np.ndarray sc_ftof_1b_z
    np.ndarray sc_ftof_1b_hx
    np.ndarray sc_ftof_1b_hy
    np.ndarray sc_ftof_1b_hz
    np.ndarray sc_ftof_2_sec
    np.ndarray sc_ftof_2_time
    np.ndarray sc_ftof_2_path
    np.ndarray sc_ftof_2_energy
    np.ndarray sc_ftof_2_component
    np.ndarray sc_ftof_2_x
    np.ndarray sc_ftof_2_y
    np.ndarray sc_ftof_2_z
    np.ndarray sc_ftof_2_hx
    np.ndarray sc_ftof_2_hy
    np.ndarray sc_ftof_2_hz
    np.ndarray sc_ctof_time
    np.ndarray sc_ctof_path
    np.ndarray sc_ctof_energy
    np.ndarray sc_ctof_component
    np.ndarray sc_ctof_x
    np.ndarray sc_ctof_y
    np.ndarray sc_ctof_z
    np.ndarray sc_ctof_hx
    np.ndarray sc_ctof_hy
    np.ndarray sc_ctof_hz
    np.ndarray sc_cnd_time
    np.ndarray sc_cnd_path
    np.ndarray sc_cnd_energy
    np.ndarray sc_cnd_component
    np.ndarray sc_cnd_x
    np.ndarray sc_cnd_y
    np.ndarray sc_cnd_z
    np.ndarray sc_cnd_hx
    np.ndarray sc_cnd_hy
    np.ndarray sc_cnd_hz


  def __cinit__(clas12Event self, string filename):
    self.c_hiporeader = new reader(filename)
    self.c_dict = self.c_hiporeader.dictionary()
    self.c_hipo_event = new event()
    self.c_ForwardTagger = new bank(self.c_dict.getSchema("REC::ForwardTagger".encode('utf8')))
    self.c_Track = new bank(self.c_dict.getSchema("REC::Track".encode('utf8')))
    self.c_Cherenkov = new bank(self.c_dict.getSchema("REC::Cherenkov".encode('utf8')))
    self.c_Particle = new bank(self.c_dict.getSchema("REC::Particle".encode('utf8')))
    self.c_Scintillator = new bank(self.c_dict.getSchema("REC::Scintillator".encode('utf8')))
    self.c_Calorimeter = new bank(self.c_dict.getSchema("REC::Calorimeter".encode('utf8')))


  def __iter__(clas12Event self):
      return self
  def __str__(clas12Event self):
    out = "["
    out += self.c_dict.getSchema("REC::ForwardTagger".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::VertDoca".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Track".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Cherenkov".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Particle".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Scintillator".encode('utf8')).json()
    out += self.c_dict.getSchema("REC::Calorimeter".encode('utf8')).json()
    out += "]"
    return out
  def __next__(clas12Event self):
    if self.c_hiporeader.next():
      self.c_hiporeader.read(self.c_hipo_event[0])
      self.c_hipo_event.getStructure(self.c_Particle[0])
      self.c_hipo_event.getStructure(self.c_ForwardTagger[0])
      self.c_hipo_event.getStructure(self.c_Track[0])
      self.c_hipo_event.getStructure(self.c_Cherenkov[0])
      self.c_hipo_event.getStructure(self.c_Scintillator[0])
      self.c_hipo_event.getStructure(self.c_Calorimeter[0])
      self.load_cal()

      return self
    else:
      raise StopIteration

  def __len__(clas12Event self):
    return self.c_Particle.getRows()
  def pid(clas12Event self, int i):
    return self.c_Particle.getInt("pid".encode('utf8') ,i)
  def px(clas12Event self, int i):
    return self.c_Particle.getFloat("px".encode('utf8') ,i)
  def py(clas12Event self, int i):
    return self.c_Particle.getFloat("py".encode('utf8') ,i)
  def pz(clas12Event self, int i):
    return self.c_Particle.getFloat("pz".encode('utf8') ,i)
  def vx(clas12Event self, int i):
    return self.c_Particle.getFloat("vx".encode('utf8') ,i)
  def vy(clas12Event self, int i):
    return self.c_Particle.getFloat("vy".encode('utf8') ,i)
  def vz(clas12Event self, int i):
    return self.c_Particle.getFloat("vz".encode('utf8') ,i)
  def charge(clas12Event self, int i):
    return self.c_Particle.getByte("charge".encode('utf8'), i)
  def beta(clas12Event self, int i):
    return self.c_Particle.getFloat("beta".encode('utf8'), i)
  def chi2pid(clas12Event self, int i):
    return self.c_Particle.getFloat("chi2pid".encode('utf8'), i)
  def status(clas12Event self, int i):
    return self.c_Particle.getShort("status".encode('utf8'), i)

  def ft_len(clas12Event self):
    return self.c_ForwardTagger.getRows()
  def ft_pindex(clas12Event self, int i):
    return self.c_ForwardTagger.getShort("pindex".encode('utf8'), i)
  def ft_detector(clas12Event self, int i):
    return self.c_ForwardTagger.getByte("detector".encode('utf8'), i)
  def ft_energy(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("energy".encode('utf8'), i)
  def ft_time(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("time".encode('utf8'), i)
  def ft_path(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("path".encode('utf8'), i)
  def ft_chi2(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("chi2".encode('utf8'), i)
  def ft_x(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("x".encode('utf8'), i)
  def ft_y(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("y".encode('utf8'), i)
  def ft_z(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("z".encode('utf8'), i)
  def ft_dx(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("dx".encode('utf8'), i)
  def ft_dy(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("dy".encode('utf8'), i)
  def ft_radius(clas12Event self, int i):
    return self.c_ForwardTagger.getFloat("radius".encode('utf8'), i)
  def ft_size(clas12Event self, int i):
    return self.c_ForwardTagger.getShort("size".encode('utf8'), i)
  def ft_status(clas12Event self, int i):
    return self.c_ForwardTagger.getShort("status".encode('utf8'), i)

  def vd_len(clas12Event self):
    return self.c_VertDoca.getRows()
  def vd_index1(clas12Event self, int i):
    return self.c_VertDoca.getShort("index1".encode('utf8'),i)
  def vd_index2(clas12Event self, int i):
    return self.c_VertDoca.getShort("index2".encode('utf8'),i)
  def vd_x(clas12Event self, int i):
    return self.c_VertDoca.getFloat("x".encode('utf8'),i)
  def vd_y(clas12Event self, int i):
    return self.c_VertDoca.getFloat("y".encode('utf8'),i)
  def vd_z(clas12Event self, int i):
    return self.c_VertDoca.getFloat("z".encode('utf8'),i)
  def vd_x1(clas12Event self, int i):
    return self.c_VertDoca.getFloat("x1".encode('utf8'),i)
  def vd_y1(clas12Event self, int i):
    return self.c_VertDoca.getFloat("y1".encode('utf8'),i)
  def vd_z1(clas12Event self, int i):
    return self.c_VertDoca.getFloat("z1".encode('utf8'),i)
  def vd_cx1(clas12Event self, int i):
    return self.c_VertDoca.getFloat("cx1".encode('utf8'),i)
  def vd_cy1(clas12Event self, int i):
    return self.c_VertDoca.getFloat("cy1".encode('utf8'),i)
  def vd_cz1(clas12Event self, int i):
    return self.c_VertDoca.getFloat("cz1".encode('utf8'),i)
  def vd_x2(clas12Event self, int i):
    return self.c_VertDoca.getFloat("x2".encode('utf8'),i)
  def vd_y2(clas12Event self, int i):
    return self.c_VertDoca.getFloat("y2".encode('utf8'),i)
  def vd_z2(clas12Event self, int i):
    return self.c_VertDoca.getFloat("z2".encode('utf8'),i)
  def vd_cx2(clas12Event self, int i):
    return self.c_VertDoca.getFloat("cx2".encode('utf8'),i)
  def vd_cy2(clas12Event self, int i):
    return self.c_VertDoca.getFloat("cy2".encode('utf8'),i)
  def vd_cz2(clas12Event self, int i):
    return self.c_VertDoca.getFloat("cz2".encode('utf8'),i)
  def vd_r(clas12Event self, int i):
    return self.c_VertDoca.getFloat("r".encode('utf8'),i)

  def trk_len(clas12Event self):
      return self.c_Track.getRows()
  def trk_index(clas12Event self, int i):
    return self.c_Track.getShort("index".encode('utf8'),i)
  def trk_pindex(clas12Event self, int i):
    return self.c_Track.getShort("pindex".encode('utf8'),i)
  def trk_detector(clas12Event self, int i):
    return self.c_Track.getByte("detector".encode('utf8'),i)
  def trk_sector(clas12Event self, int i):
    return self.c_Track.getByte("sector".encode('utf8'),i)
  def trk_status(clas12Event self, int i):
    return self.c_Track.getShort("status".encode('utf8'),i)
  def trk_q(clas12Event self, int i):
    return self.c_Track.getByte("q".encode('utf8'),i)
  def trk_chi2(clas12Event self, int i):
    return self.c_Track.getFloat("chi2".encode('utf8'),i)
  def trk_NDF(clas12Event self, int i):
    return self.c_Track.getShort("NDF".encode('utf8'),i)
  def trk_px_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("px_nomm".encode('utf8'),i)
  def trk_py_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("py_nomm".encode('utf8'),i)
  def trk_pz_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("pz_nomm".encode('utf8'),i)
  def trk_vx_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("vx_nomm".encode('utf8'),i)
  def trk_vy_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("vy_nomm".encode('utf8'),i)
  def trk_vz_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("vz_nomm".encode('utf8'),i)
  def trk_chi2_nomm(clas12Event self, int i):
    return self.c_Track.getFloat("chi2_nomm".encode('utf8'),i)
  def trk_NDF_nomm(clas12Event self, int i):
    return self.c_Track.getShort("NDF_nomm".encode('utf8'),i)

  def chern_len(clas12Event self):
      return self.c_Cherenkov.getRows()
  def chern_index(clas12Event self, int i):
    return self.c_Cherenkov.getShort("index".encode('utf8'),i)
  def chern_pindex(clas12Event self, int i):
    return self.c_Cherenkov.getShort("pindex".encode('utf8'),i)
  def chern_detector(clas12Event self, int i):
    return self.c_Cherenkov.getByte("detector".encode('utf8'),i)
  def chern_sector(clas12Event self, int i):
    return self.c_Cherenkov.getByte("sector".encode('utf8'),i)
  def chern_nphe(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("nphe".encode('utf8'),i)
  def chern_time(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("time".encode('utf8'),i)
  def chern_path(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("path".encode('utf8'),i)
  def chern_chi2(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("chi2".encode('utf8'),i)
  def chern_x(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("x".encode('utf8'),i)
  def chern_y(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("y".encode('utf8'),i)
  def chern_z(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("z".encode('utf8'),i)
  def chern_theta(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("theta".encode('utf8'),i)
  def chern_phi(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("phi".encode('utf8'),i)
  def chern_dtheta(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("dtheta".encode('utf8'),i)
  def chern_dphi(clas12Event self, int i):
    return self.c_Cherenkov.getFloat("dphi".encode('utf8'),i)
  def chern_status(clas12Event self, int i):
    return self.c_Cherenkov.getShort("status".encode('utf8'),i)

  def sc_len(clas12Event self):
    return self.c_Scintillator.getRows()

  def load_sc(clas12Event self):
    len_pid = self.c_Particle.getRows()
    len_pindex = self.c_Scintillator.getRows()

    self.sc_ftof_1a_sec = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_time = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_path = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_energy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_component = np.ones(len_pid, dtype=float) * (-1)
    self.sc_ftof_1a_x = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_y = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_z = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_hx = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_hy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1a_hz = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_sec = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_time = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_path = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_energy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_component = np.ones(len_pid, dtype=float) * (-1)
    self.sc_ftof_1b_x = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_y = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_z = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_hx = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_hy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_1b_hz = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_sec = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_time = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_path = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_energy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_component = np.ones(len_pid, dtype=float) * (-1)
    self.sc_ftof_2_x = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_y = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_z = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_hx = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_hy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ftof_2_hz = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_time = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_path = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_energy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_component = np.ones(len_pid, dtype=float) * (-1)
    self.sc_ctof_x = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_y = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_z = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_hx = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_hy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_ctof_hz = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_time = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_path = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_energy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_component = np.ones(len_pid, dtype=float) * (-1)
    self.sc_cnd_x = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_y = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_z = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_hx = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_hy = np.ones(len_pid, dtype=float) * np.nan
    self.sc_cnd_hz = np.ones(len_pid, dtype=float) * np.nan

    for i in range(0,len_pid):
      for k in range(0,len_pindex):
        pindex = self.c_Scintillator.getShort("pindex".encode('utf8'), k)
        detector = self.c_Scintillator.getByte("detector".encode('utf8'), k)
        layer = self.c_Scintillator.getByte("layer".encode('utf8'), k)
        if pindex == i and detector == clas12_detector["FTOF"] and layer == clas12_layer["FTOF_1A"]:
          self.sc_ftof_1a_sec[i] = self.c_Scintillator.getByte("sector".encode('utf8'), k)
          self.sc_ftof_1a_time[i] = self.c_Scintillator.getFloat("time".encode('utf8'), k)
          self.sc_ftof_1a_path[i] = self.c_Scintillator.getFloat("path".encode('utf8'), k)
          self.sc_ftof_1a_energy[i] = self.c_Scintillator.getFloat("energy".encode('utf8'), k)
          self.sc_ftof_1a_component[i] = self.c_Scintillator.getShort("component".encode('utf8'), k)
          self.sc_ftof_1a_x[i] = self.c_Scintillator.getFloat("x".encode('utf8'), k)
          self.sc_ftof_1a_y[i] = self.c_Scintillator.getFloat("y".encode('utf8'), k)
          self.sc_ftof_1a_z[i] = self.c_Scintillator.getFloat("z".encode('utf8'), k)
          self.sc_ftof_1a_hx[i] = self.c_Scintillator.getFloat("hx".encode('utf8'), k)
          self.sc_ftof_1a_hy[i] = self.c_Scintillator.getFloat("hy".encode('utf8'), k)
          self.sc_ftof_1a_hz[i] = self.c_Scintillator.getFloat("hz".encode('utf8'), k)
        elif pindex == i and detector == clas12_detector["FTOF"] and layer == clas12_layer["FTOF_1B"]:
          self.sc_ftof_1b_sec[i] = self.c_Scintillator.getByte("sector".encode('utf8'), k)
          self.sc_ftof_1b_time[i] = self.c_Scintillator.getFloat("time".encode('utf8'), k)
          self.sc_ftof_1b_path[i] = self.c_Scintillator.getFloat("path".encode('utf8'), k)
          self.sc_ftof_1b_energy[i] = self.c_Scintillator.getFloat("energy".encode('utf8'), k)
          self.sc_ftof_1b_component[i] = self.c_Scintillator.getShort("component".encode('utf8'), k)
          self.sc_ftof_1b_x[i] = self.c_Scintillator.getFloat("x".encode('utf8'), k)
          self.sc_ftof_1b_y[i] = self.c_Scintillator.getFloat("y".encode('utf8'), k)
          self.sc_ftof_1b_z[i] = self.c_Scintillator.getFloat("z".encode('utf8'), k)
          self.sc_ftof_1b_hx[i] = self.c_Scintillator.getFloat("hx".encode('utf8'), k)
          self.sc_ftof_1b_hy[i] = self.c_Scintillator.getFloat("hy".encode('utf8'), k)
          self.sc_ftof_1b_hz[i] = self.c_Scintillator.getFloat("hz".encode('utf8'), k)
        elif pindex == i and detector == clas12_detector["FTOF"] and layer == clas12_layer["FTOF_2"]:
          self.sc_ftof_2_sec[i] = self.c_Scintillator.getByte("sector".encode('utf8'), k)
          self.sc_ftof_2_time[i] = self.c_Scintillator.getFloat("time".encode('utf8'), k)
          self.sc_ftof_2_path[i] = self.c_Scintillator.getFloat("path".encode('utf8'), k)
          self.sc_ftof_2_energy[i] = self.c_Scintillator.getFloat("energy".encode('utf8'), k)
          self.sc_ftof_2_component[i] = self.c_Scintillator.getShort("component".encode('utf8'), k)
          self.sc_ftof_2_x[i] = self.c_Scintillator.getFloat("x".encode('utf8'), k)
          self.sc_ftof_2_y[i] = self.c_Scintillator.getFloat("y".encode('utf8'), k)
          self.sc_ftof_2_z[i] = self.c_Scintillator.getFloat("z".encode('utf8'), k)
          self.sc_ftof_2_hx[i] = self.c_Scintillator.getFloat("hx".encode('utf8'), k)
          self.sc_ftof_2_hy[i] = self.c_Scintillator.getFloat("hy".encode('utf8'), k)
          self.sc_ftof_2_hz[i] = self.c_Scintillator.getFloat("hz".encode('utf8'), k)
        elif pindex == i and detector == clas12_detector["CTOF"]:
          self.sc_ctof_time[i] = self.c_Scintillator.getFloat("time".encode('utf8'), k)
          self.sc_ctof_path[i] = self.c_Scintillator.getFloat("path".encode('utf8'), k)
          self.sc_ctof_energy[i] = self.c_Scintillator.getFloat("energy".encode('utf8'), k)
          self.sc_ctof_component[i] = self.c_Scintillator.getShort("component".encode('utf8'), k)
          self.sc_ctof_x[i] = self.c_Scintillator.getFloat("x".encode('utf8'), k)
          self.sc_ctof_y[i] = self.c_Scintillator.getFloat("y".encode('utf8'), k)
          self.sc_ctof_z[i] = self.c_Scintillator.getFloat("z".encode('utf8'), k)
          self.sc_ctof_hx[i] = self.c_Scintillator.getFloat("hx".encode('utf8'), k)
          self.sc_ctof_hy[i] = self.c_Scintillator.getFloat("hy".encode('utf8'), k)
          self.sc_ctof_hz[i] = self.c_Scintillator.getFloat("hz".encode('utf8'), k)
        elif pindex == i and detector == clas12_detector["CND"]:
          self.sc_cnd_time[i] = self.c_Scintillator.getFloat("time".encode('utf8'), k)
          self.sc_cnd_path[i] = self.c_Scintillator.getFloat("path".encode('utf8'), k)
          self.sc_cnd_energy[i] = self.c_Scintillator.getFloat("energy".encode('utf8'), k)
          self.sc_cnd_component[i] = self.c_Scintillator.getShort("component".encode('utf8'), k)
          self.sc_cnd_x[i] = self.c_Scintillator.getFloat("x".encode('utf8'), k)
          self.sc_cnd_y[i] = self.c_Scintillator.getFloat("y".encode('utf8'), k)
          self.sc_cnd_z[i] = self.c_Scintillator.getFloat("z".encode('utf8'), k)
          self.sc_cnd_hx[i] = self.c_Scintillator.getFloat("hx".encode('utf8'), k)
          self.sc_cnd_hy[i] = self.c_Scintillator.getFloat("hy".encode('utf8'), k)
          self.sc_cnd_hz[i] = self.c_Scintillator.getFloat("hz".encode('utf8'), k)

  def len_cal(clas12Event self):
    return self.c_Calorimeter.getRows()
  def cal_tot_energy(clas12Event self, int i):
    if i > self.c_Calorimeter.getRows():
      return np.nan
    return self.ec_tot_energy[i]
  def load_cal(clas12Event self):
    len_pid = self.c_Particle.getRows()
    len_pindex = self.c_Calorimeter.getRows()
    self.ec_tot_energy = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_energy = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_sec = np.ones(len_pid, dtype=int) * (-1)
    self.ec_pcal_time = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_path = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_x = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_y = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_z = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_lu = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_lv = np.ones(len_pid, dtype=float) * np.nan
    self.ec_pcal_lw = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_energy = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_sec = np.ones(len_pid, dtype=int) * (-1)
    self.ec_ecin_time = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_path = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_x = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_y = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_z = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_lu = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_lv = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecin_lw = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_energy = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_sec = np.ones(len_pid, dtype=int) * (-1)
    self.ec_ecout_time = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_path = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_x = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_y = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_z = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_lu = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_lv = np.ones(len_pid, dtype=float) * np.nan
    self.ec_ecout_lw = np.ones(len_pid, dtype=float) * np.nan
    pcal = 0.0
    einner = 0.0
    eouter = 0.0
    etot = 0.0

    for i in range(0,len_pid):
      for k in range(0,len_pindex):
        pindex = self.c_Calorimeter.getShort("pindex".encode('utf8'), k)
        detector = self.c_Calorimeter.getByte("detector".encode('utf8'), k)
        layer = self.c_Calorimeter.getByte("layer".encode('utf8'), k)
        energy = self.c_Calorimeter.getFloat("energy".encode('utf8'), k)

        if pindex == i and detector == clas12_detector["ECAL"]:
          etot += energy;
          if layer == clas12_layer["PCAL"]:
            pcal += energy
            self.ec_pcal_sec[i] = self.c_Calorimeter.getByte("sector".encode('utf8'), k)
            self.ec_pcal_time[i] = self.c_Calorimeter.getFloat("time".encode('utf8'), k)
            self.ec_pcal_path[i] = self.c_Calorimeter.getFloat("path".encode('utf8'), k)
            self.ec_pcal_x[i] = self.c_Calorimeter.getFloat("x".encode('utf8'), k)
            self.ec_pcal_y[i] = self.c_Calorimeter.getFloat("y".encode('utf8'), k)
            self.ec_pcal_z[i] = self.c_Calorimeter.getFloat("z".encode('utf8'), k)
            self.ec_pcal_lu[i] = self.c_Calorimeter.getFloat("lu".encode('utf8'), k)
            self.ec_pcal_lv[i] = self.c_Calorimeter.getFloat("lv".encode('utf8'), k)
            self.ec_pcal_lw[i] = self.c_Calorimeter.getFloat("lw".encode('utf8'), k)
          elif layer == clas12_layer["EC_INNER"]:
            einner += energy
            self.ec_ecin_sec[i] = self.c_Calorimeter.getByte("sector".encode('utf8'), k)
            self.ec_ecin_time[i] = self.c_Calorimeter.getFloat("time".encode('utf8'), k)
            self.ec_ecin_path[i] = self.c_Calorimeter.getFloat("path".encode('utf8'), k)
            self.ec_ecin_x[i] = self.c_Calorimeter.getFloat("x".encode('utf8'), k)
            self.ec_ecin_y[i] = self.c_Calorimeter.getFloat("y".encode('utf8'), k)
            self.ec_ecin_z[i] = self.c_Calorimeter.getFloat("z".encode('utf8'), k)
            self.ec_ecin_lu[i] = self.c_Calorimeter.getFloat("lu".encode('utf8'), k)
            self.ec_ecin_lv[i] = self.c_Calorimeter.getFloat("lv".encode('utf8'), k)
            self.ec_ecin_lw[i] = self.c_Calorimeter.getFloat("lw".encode('utf8'), k)
          elif layer == clas12_layer["EC_OUTER"]:
            eouter += energy
            self.ec_ecout_sec[i] = self.c_Calorimeter.getByte("sector".encode('utf8'), k)
            self.ec_ecout_time[i] = self.c_Calorimeter.getFloat("time".encode('utf8'), k)
            self.ec_ecout_path[i] = self.c_Calorimeter.getFloat("path".encode('utf8'), k)
            self.ec_ecout_x[i] = self.c_Calorimeter.getFloat("x".encode('utf8'), k)
            self.ec_ecout_y[i] = self.c_Calorimeter.getFloat("y".encode('utf8'), k)
            self.ec_ecout_z[i] = self.c_Calorimeter.getFloat("z".encode('utf8'), k)
            self.ec_ecout_lu[i] = self.c_Calorimeter.getFloat("lu".encode('utf8'), k)
            self.ec_ecout_lv[i] = self.c_Calorimeter.getFloat("lv".encode('utf8'), k)
            self.ec_ecout_lw[i] = self.c_Calorimeter.getFloat("lw".encode('utf8'), k)


        self.ec_pcal_energy[i] = pcal if pcal != 0.0 else np.nan
        self.ec_ecin_energy[i] = einner if einner != 0.0 else np.nan
        self.ec_ecout_energy[i] = eouter if eouter != 0.0 else np.nan
        self.ec_tot_energy[i] = etot if etot != 0.0 else np.nan
