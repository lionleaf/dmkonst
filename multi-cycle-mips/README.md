Multi-Cycle CPU
===============

A simple multi-cycle CPU was implemented on a Spartan-6 FPGA. 
It implements a subset of the MIPS instruction set. 
The core focus has been performance through keeping the hardware as simple as possible. 
By writing VHDL with hardware in mind at every step a simple and understandable RTL was achieved. 
After some additional optimization a max clock frequency of 85MHz was reached. 
With instructions taking 2 to 3 cycles this results in a performance which is significantly faster than 
the earlier implementations.

[Direct link to the report.](https://github.com/lionleaf/dmkonst/blob/master/multi-cycle-mips-report.pdf?raw=true)
