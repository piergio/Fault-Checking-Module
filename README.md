# Fault-Checking-Module
Development of a Fault Checking Module in VHDL that is able to check whether a fault has occurred or not. It compares the result computed by the actual system with the expected one.
The main components are:
1. Control Unit: performs an FSM and sends control signals to the Datapath Unit
2. Datapath Unit: contains the two computing peripherals whose results are compared
3. ROM: contains data to be provided to the Datapath Unit 
4. RAM: contains the wrong results

The given implementation uses two Multiplier Modules that are Xilinx Core Units.
