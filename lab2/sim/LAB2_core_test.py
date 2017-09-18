import sys
RSA_PATH='../pc_sw/golden/'
sys.path.append(RSA_PATH)
from nicotb import *
from nicotb.utils import Scoreboard, Stacker
from nicotb.protocol import TwoWire
import numpy as np

def To2d(name, pad):
	n = 31 if pad else 32
	n_tst = 5
	nbyte = n_tst*n
	with open(RSA_PATH+name, "rb") as f:
		ret = np.array(list(f.read(nbyte)), dtype=np.uint32)
		if pad:
			ret = np.reshape(ret, (n_tst, n))
			z = np.zeros((n_tst, 32), dtype=np.uint32)
			z[:,1:] = ret
			ret = z
		else:
			ret = np.reshape(ret, (n_tst, n))
		ret = np.reshape(ret, (n_tst, 8, 4))
		ret = np.bitwise_or.reduce(ret << (8*np.arange(3, -1, -1)), axis=2, dtype=np.uint32)
		return np.fliplr(ret)

def main():
	yield rst_out_ev
	master = TwoWire.Master(src_val, src_rdy, src_bus, ck_ev)
	i_data = master.values
	slave = TwoWire.Slave(dst_val, dst_rdy, dst_bus, ck_ev, callbacks=[st.Get])
	val_n = np.array([
		0x029CF831, 0x940D774C,
		0xCDEE4035, 0xE85388EC,
		0x79F7DD12, 0x0A222A4C,
		0xEA485F3B, 0xCA3586E7,
	], dtype=np.uint32)
	val_d = np.array([
		0xBCF46BD9, 0xBEC8802F,
		0xC37BB937, 0x1829BEAF,
		0x3326CF1A, 0x39B15FD1,
		0x47201698, 0xB6ACE0B1,
	], dtype=np.uint32)
	dec = To2d("dec1.txt", True)
	enc = To2d("enc1.bin", False)
	assert enc.shape == dec.shape
	for i in range(enc.shape[0]):
		np.copyto(i_data[0], enc[i])
		np.copyto(i_data[1], val_d)
		np.copyto(i_data[2], val_n)
		test.Expect((dec[i:i+1],))
		yield from master.Send(i_data)

	for i in range(30):
		yield ck_ev
	FinishSim()

rst_out_ev, ck_ev = CreateEvents(["rst_out", "ck_ev"])
scb = Scoreboard()
test = scb.GetTest("test")
st = Stacker(1, [test.Get])
src_val, src_rdy, dst_val, dst_rdy = CreateBuses([
	(("dut", "src_val"),),
	(("dut", "src_rdy"),),
	(("dut", "result_val"),),
	(("dut", "result_rdy"),),
])
src_bus, dst_bus = CreateBuses([
	(
		("","a",(8,),np.uint32),
		("","e",(8,),np.uint32),
		("","n",(8,),np.uint32),
	),
	(("","o",(8,),np.uint32),),
])
RegisterCoroutines([
	main(),
])
