import sys
RSA_PATH='../pc_sw/golden/'
sys.path.append(RSA_PATH)
from nicotb import *
from nicotb.protocol import Avalon
from nicotb.utils import RandProb
import numpy as np

def ToArr(name, nbyte):
	with open(RSA_PATH+name, "rb") as f:
		ret = list(f.read(nbyte))
		assert len(ret) == nbyte
		return ret

def finish():
	for i in range(1000):
		yield ck_ev
	print("Test passed")
	FinishSim()

class Rs232Sim(object):
	def __init__(self, txdat, rxdat):
		self.tx = 1
		self.rx = 1
		self.txdat = txdat
		self.rxdat = rxdat
		self.txn = 0
		self.rxn = 0

	def Rfunc(self, a):
		assert a == 8 or a == 0, f"Address {a} is not a good read address"
		if a == 8:
			if RandProb(1, 3) and self.rxn < len(self.rxdat):
				self.rx = 1
			if RandProb(1, 3):
				self.tx = 1
			return self.rx << 7 | self.tx << 6
		else:
			assert self.rx == 1, "RX not ready"
			self.rx = 0
			ret = self.rxdat[self.rxn]
			self.rxn += 1
			return ret

	def Wfunc(self, a, d):
		assert a == 4, f"Address {a} is not a good write address"
		assert self.tx == 1, "TX not ready"
		assert self.txn < len(self.txdat) and d == self.txdat[self.txn], f"{self.txn}-th data mismatch, got {d}"
		self.tx = 0
		self.txn += 1
		if self.txn == len(self.txdat):
			Fork(finish())

def main():
	yield rst_out_ev
	tx = ToArr("dec1.txt", 5*31)
	rx = ToArr("key.bin", 64) + ToArr("enc1.bin", 5*32)
	sim = Rs232Sim(tx, rx)
	slave = Avalon.SlaveLite(
		(("dut", "avm_write"),),
		(("dut", "avm_read"),),
		(("dut", "avm_waitrequest"),),
		(("dut", "avm_readdatavalid"),),
		(("dut", "avm_address"),),
		(("dut", "avm_writedata"),),
		(("dut", "avm_readdata"),),
		sim.Wfunc, sim.Rfunc, ck_ev
	)

rst_out_ev, ck_ev = CreateEvents(["rst_out", "ck_ev"])
RegisterCoroutines([
	main(),
])
