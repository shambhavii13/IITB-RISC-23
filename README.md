# IITB-RISC-23 #
### This is our EE-309 course project under our beloved professor Virendra Singh where we implement state-of-the-art pipelined architecture. 

IITB-RISC-23 is a 16-bit very simple computer based on the Little Computer Architecture. It is a 6-staged pipelined processor (Instruction Fetch, Instruction Decode, Register Read, Execute, Memory Access, and Write Back). It has 8 general purpose registers (R0 to R7). Register R0 is always stores Program Counter. All addresses are byte addresses and instructions. Always it fetches two bytes for instruction and data. This architecture uses Condition Code Register which has two flags Carry flag (C) and Zero flag (Z).

The architecture is optimized for performance, i.e., it has Hazard Mitigation Techniques, Forwarding Mechanism implemented that bring down the Cycles Per Instruction to 1.  The architecture allows predicated instruction execution, multiple load and store execution. There are three machine-code instruction formats (R, I, and J type) and a total of 14 instructions.

_Regards_ </br>
_[Shambhavi](https://github.com/shambhavii13), [Scaria](https://github.com/ScariaK), [Swadhin](https://github.com/Swadine), [Deep](https://github.com/deepboliya)_
