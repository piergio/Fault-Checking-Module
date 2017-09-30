# Fault-Checking-Module
Development of a Fault-Checking SoC module in VHDL using XilinX ISE, that is able to check whether a fault has occurred or not, at power-up. It compares the result computed by the actual system for which the SoC has been built with the expected right one. The main components are:

Control Unit: performs an FSM and sends control signals to the Datapath Unit
Datapath Unit: contains the two computing peripherals whose results are compared
ROM: contains data to be provided to the Datapath Unit
RAM: contains the wrong results

The given implementation uses two Multiplier Modules that are Xilinx IP Units.
