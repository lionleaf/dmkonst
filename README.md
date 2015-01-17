TDT4255 Computer Construction
==========

University project as part of TDT4255 at the Norwegian University of Science and Technology.

Written by Aleksander Wasaznik, Geir Kulia and Andreas Løve Selvik.

Note: During this semester both Aleksander and Andreas was also part of the ambitious course "Computer Design Project" where we built a computer from the ground up with a custom GPU. Those repositories can be found here: https://github.com/dmpro2014

The exercise was split in four parts:

0. Tutorial
-----------
The result of following a tutorial step by step to introduce VHDL and the toolchain, which was a good thing, as most of us had never touch a hardware definition language.

1. A simple stack machine   (stack-machine)
-----------
An simple introduction to VHDL and the toolchain where we had to build a simple stack-machine that can calculate
mathematical expressions with +, -, * and / written in reverse polish notation.
Here we had to design the RTL ourselves.

2. A multicycle MIPS processor (multi-cycle-mips)
-----------
Given a subset of the MIPS instruction set and the requirement that it had to be a a multi-cycle implementation (no pipelining) we designed and implemented this processor. It was inspired by the processor detailed in Computer Organization and Design [Patterson and Hennessy]. 
The resulting implementation was succesfully tested on a Spartan-6 FPGA.
We spent a lot of effort on optimizing the design and VHDL to get the highest possible performance, and we had among the fastest processors.

This exercise counted 25% of our grade.

[Direct link to the report.](https://github.com/lionleaf/dmkonst/blob/master/multi-cycle-mips-report.pdf?raw=true)

3. A pipelined MIPS processor with optimizations (pipeline-mips)
----------
We pipelined the processor from the last exercise. And then introduced optimizations, such as forwarding, hazard detection and branch handling to deal with the pipeline hazards.
This processor was also successfully tested on a Spartan-6 FPGA.
We spent quite some time playing with the VHDL language to try to implement the pipeline registers as clean as possible, which can be seen in various branches of this repository.

This exercise also accounted for 25% of our grade.

[Direct link to the report.](https://github.com/lionleaf/dmkonst/blob/master/pipeline-mips-report.pdf?raw=true)
