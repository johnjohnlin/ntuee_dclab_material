# File Structure

* src/DE2\_115
	* All files related to the FPGA
* include/
	* Verilog files which only contain include lines
* sim/ and lint/
	* Working directories

# Simulation

Simulate the core file(s)

    cd sim/
    LD_PRELOAD=/usr/local/lib/libpython3.6m.so make -f ../../Makefile Top

I am not quite sure why LD_PRELOAD is necessary for loading PyQt correctly, and this script is only for our workstation.
