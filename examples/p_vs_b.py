#!/usr/bin/env python
from __future__ import print_function

import sys

import matplotlib.pyplot as plt
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC

from hipopy3 import LorentzVector, hipo3_reader

px_py_pz_beta = []
true_pid = []
for f in sys.argv[1:]:
    print("Loading {}".format(f))
    reader = hipo3_reader(f)
    pid = reader.getIntNode(u"REC::Particle", u"pid")
    px = reader.getFloatNode(u"REC::Particle", u"px")
    py = reader.getFloatNode(u"REC::Particle", u"py")
    pz = reader.getFloatNode(u"REC::Particle", u"pz")
    vx = reader.getFloatNode(u"REC::Particle", u"vx")
    vy = reader.getFloatNode(u"REC::Particle", u"vy")
    vz = reader.getFloatNode(u"REC::Particle", u"vz")
    charge = reader.getInt8Node(u"REC::Particle", u"charge")
    beta = reader.getFloatNode(u"REC::Particle", u"beta")

    mc_pid = reader.getIntNode(u"MC::Particle", u"pid")
    mc_px = reader.getFloatNode(u"MC::Particle", u"px")
    mc_py = reader.getFloatNode(u"MC::Particle", u"py")
    mc_pz = reader.getFloatNode(u"MC::Particle", u"pz")
    mc_vx = reader.getFloatNode(u"MC::Particle", u"vx")
    mc_vy = reader.getFloatNode(u"MC::Particle", u"vy")
    mc_vz = reader.getFloatNode(u"MC::Particle", u"vz")

    num = 0
    while reader.next():
        if len(pid) != len(mc_pid):
            continue
        num += 1
        for i in range(len(pid)):
            p = np.sqrt(px[i]**2 + py[i]**2 + pz[i]**2)
            if beta[i] >= 0.2 and beta[i] < 1.0 and p < 2.5:
                p = np.sqrt(px[i]**2 + py[i]**2 + pz[i]**2)
                px_py_pz_beta.append([px[i], py[i], pz[i], beta[i], charge[i]])
                true_pid.append(mc_pid[i])

px_py_pz_beta = np.array(px_py_pz_beta)
true_pid = np.array(true_pid)

X_train, X_test, y_train, y_test = train_test_split(px_py_pz_beta, true_pid, test_size=0.5)

clf_pid = SVC(kernel='rbf', gamma='auto')
clf_pid.fit(X_train, y_train)

score = clf_pid.score(X_test, y_test)
print("\t{0:.2f} %".format(100 * score))

p = []
b = []
pid_bank = []
pid_mc = []
pid_svm = []
for f in sys.argv[1:]:
    print("Loading {}".format(f))
    reader = hipo_reader(f)
    pid = reader.getIntNode(u"REC::Particle", u"pid")
    px = reader.getFloatNode(u"REC::Particle", u"px")
    py = reader.getFloatNode(u"REC::Particle", u"py")
    pz = reader.getFloatNode(u"REC::Particle", u"pz")
    vx = reader.getFloatNode(u"REC::Particle", u"vx")
    vy = reader.getFloatNode(u"REC::Particle", u"vy")
    vz = reader.getFloatNode(u"REC::Particle", u"vz")
    charge = reader.getInt8Node(u"REC::Particle", u"charge")
    beta = reader.getFloatNode(u"REC::Particle", u"beta")
    mc_pid = reader.getIntNode(u"MC::Particle", u"pid")

    while reader.next() and num < 10000:
        num += 1
        for i in range(1, len(pid)):
            if np.isnan([px[i], py[i], pz[i], beta[i], charge[i]]).any():
                continue

            p.append(np.sqrt(px[i] * px[i] + py[i] * py[i] * pz[i] * pz[i]))
            b.append(beta[i])
            pid_bank.append(pid[i])
            pid_mc.append(mc_pid[i])
            svm_pid = clf_pid.predict([[px[i], py[i], pz[i], beta[i], charge[i]]])[0]
            pid_svm.append(svm_pid)

p = np.array(p)
b = np.array(b)
pid_bank = np.array(pid_bank)
pid_svm = np.array(pid_svm)
pid_mc = np.array(pid_mc)
cut = (b < 1.1) == (b > 0.0)
p = p[cut]
pid_bank = pid_bank[cut]
pid_svm = pid_svm[cut]
pid_mc = pid_mc[cut]
b = b[cut]
color = pid_bank == pid_mc
plt.scatter(p[color], b[color], c='g', s=0.2)
plt.scatter(p[~color], b[~color], c='r', s=0.2)
plt.savefig("pvsb.pdf")
