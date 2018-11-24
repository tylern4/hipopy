/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

#include "clas12/clas12event.h"

namespace clas12 {

  void clas12event::init(hipo::reader& r) {
    clas12header.init(banks[0].c_str(), r);
    clas12particle.init(banks[1].c_str(), r);
    clas12calorimeter.init(banks[2].c_str(), r);
    clas12tof.init(banks[3].c_str(), r);
  }

  double clas12event::getStartTime() { return clas12header.getStartTime(); }

  double clas12event::getTime(int detector, int pindex) {
    switch (detector) {
    case 121:
      return clas12tof.getTime(clas12::FTOF, 1, pindex);
      break;
    case 122:
      return clas12tof.getTime(clas12::FTOF, 2, pindex);
      break;
    case 7:
      return clas12calorimeter.getTime(clas12::EC, 1, pindex);
      break;
    default:
      std::cerr << "detector: " << detector << "does not have bank Time." << std::endl;
    }
    return std::nan("-99");
  }

  double clas12event::getEnergy(int detector, int pindex) {
    double energy = 0.0;
    switch (detector) {
    case 12:
      energy += clas12tof.getEnergy(clas12::FTOF, 1, pindex);
      energy += clas12tof.getEnergy(clas12::FTOF, 2, pindex);
      return energy;
    case 121:
      return clas12tof.getEnergy(clas12::FTOF, 1, pindex);
    case 122:
      return clas12tof.getEnergy(clas12::FTOF, 2, pindex);
    case 7:
      energy += clas12calorimeter.getEnergy(clas12::EC, 1, pindex);
      energy += clas12calorimeter.getEnergy(clas12::EC, 4, pindex);
      energy += clas12calorimeter.getEnergy(clas12::EC, 7, pindex);
      return energy;
    case 71:
      return clas12calorimeter.getEnergy(clas12::EC, 1, pindex);
    case 72:
      return clas12calorimeter.getEnergy(clas12::EC, 4, pindex);
    case 73:
      return clas12calorimeter.getEnergy(clas12::EC, 7, pindex);
    default:
      std::cerr << "detector: " << detector << "does not have bank Energy" << std::endl;
      break;
    }
    return std::nan("-99");
  }

  double clas12event::getBeta(int detector, int pindex) {
    double stt  = clas12header.getStartTime();
    double time = getTime(detector, pindex);
    double path = getPath(detector, pindex);
    return path / (time - stt) / 29.9792458;
  }

  double clas12event::getPath(int detector, int pindex) {
    switch (detector) {
    case 121:
      return clas12tof.getPath(clas12::FTOF, 1, pindex);
      break;
    case 122:
      return clas12tof.getPath(clas12::FTOF, 2, pindex);
      break;
    case 7:
      return clas12calorimeter.getPath(clas12::EC, 1, pindex);
      break;
    default:
      std::cerr << "detector: " << detector << "does not have bank Path" << std::endl;
    }
    return std::nan("-99");
  }

  vector3 clas12event::getHitPosition(int detector, int pindex) {
    detectorHit hit;
    vector3     vec;
    switch (detector) {
    case 121:
      clas12tof.getDetectorHit(clas12::FTOF, 1, pindex, hit);
      vec.setXYZ(hit.x, hit.y, hit.z);
      return vec;
    case 122:
      clas12tof.getDetectorHit(clas12::FTOF, 2, pindex, hit);
      vec.setXYZ(hit.x, hit.y, hit.z);
      return vec;
    case 7:
      clas12calorimeter.getDetectorHit(clas12::EC, 1, pindex, hit);
      vec.setXYZ(hit.x, hit.y, hit.z);
      return vec;
    default:
      std::cerr << "detector: " << detector << "does not have bank Postion (x,y,z)" << std::endl;
      return vec;
    }
  }
} // namespace clas12
