/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * File:   clas12event.h
 * Author: gavalian
 *
 * Created on April 27, 2017, 10:01 AM
 */

#ifndef CLAS12_EVENT_H
#define CLAS12_EVENT_H

#include "detector.h"
#include "header.h"
#include "particle.h"
#include "vectors.h"
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <stdint.h>
#include <stdlib.h>
#include <string>
#include <vector>

namespace clas12 {

  static const double FTOF = 12;
  static const double HTCC = 15;
  static const double EC   = 7;

  static const double FTOF1A = 121;
  static const double FTOF1B = 122;
  static const double PCAL   = 71;
  static const double ECIN   = 72;
  static const double ECOUT  = 73;

  class clas12event {

  private:
    /*static const char *vinit[] = {
        "REC::Event","REC::Particle","REC::Calorimeter",
        "REC::Scintillator" };
  */
    std::vector<std::string> banks = {"REC::Event", "REC::Particle", "REC::Calorimeter",
                                      "REC::Scintillator"};

    clas12::header   clas12header;
    clas12::particle clas12particle;
    clas12::detector clas12calorimeter;
    clas12::detector clas12tof;
    clas12::detector clas12cherenkov;

  public:
    clas12event() {}

    clas12event(hipo::reader& r) { init(r); }

    ~clas12event() {}

    void init(hipo::reader& r);

    double  getStartTime();
    int     getPid(int index);
    float   getPx(int index);
    float   getPy(int index);
    float   getPz(int index);
    double  getTime(int detector, int pindex);
    double  getEnergy(int detector, int pindex);
    double  getPath(int detector, int pindex);
    double  getBeta(int detector, int pindex);
    vector3 getHitPosition(int detector, int pindex);

    clas12::particle& particles() { return clas12particle; }
    clas12::header&   header() { return clas12header; }
  }; // namespace clas12

} // namespace clas12

#endif /* UTILS_H */
