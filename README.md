# class-based-testbench-for-D_flipflop-verification

SystemVerilog Testbench for D Flip-Flop
Overview
This repository contains a SystemVerilog testbench for verifying a D Flip-Flop (D FF). The D FF captures the input data on the clock edge, with a reset to initialize outputs. The testbench uses a class-based structure for modularity and reusability.
Design Under Test (DUT)
The DUT is a D Flip-Flop with:

Inputs:
clk: Clock signal
D: Data input
reset: Synchronous reset (active high)


Outputs:
Q: Data output
Qb: Inverted data output


Behavior:
On a positive clock edge, if reset is high, Q is set to 0 and Qb to 1.
If reset is low, Q takes the value of D, and Qb is the inverse of D.
Initial state: Q = 0, Qb = 1.



Testbench Structure
The testbench is organized into classes for clarity:
1. D Flip-Flop Item

Represents a transaction with D, reset, Q, and Qb.
Uses constrained randomization for D (50% 0/1) and reset (10% 1, 90% 0).
Includes a print method for logging.

2. Interface

Connects the testbench to the DUT with all signals.

3. Generator

Generates 10 random transactions with D and reset.
Sends transactions to the driver and scoreboard via mailboxes.

4. Driver

Drives D and reset to the DUT based on transactions.
Synchronizes with the clock and signals completion.

5. Monitor

Samples DUT inputs (D, reset) and outputs (Q, Qb) each clock cycle.
Sends sampled data to the scoreboard.

6. Scoreboard

Compares DUT outputs against expected behavior:
For reset = 1: Checks Q = 0, Qb = 1.
For reset = 0: Checks Q = D, Qb = ~D.


Logs pass/fail for each transaction.

7. Environment

Connects generator, driver, monitor, and scoreboard.
Manages mailboxes and events.

8. Test

Initializes the environment and starts the test.

9. Testbench Module

Top-level module with DUT, interface, and test.
Generates a 10ns period clock and dumps waveforms.

Files

dff.sv: The D Flip-Flop design.
dff_tb.sv: Testbench with all classes and connections.
README.md: This file.

Requirements

SystemVerilog simulator (e.g., VCS, QuestaSim, Incisive).


Compile and Simulate (example with VCS):
vcs -sverilog -timescale=1ns/1ns dff.sv dff_tb.sv
./simv


View Waveforms:

Waveforms are saved in wave.shm. Use your simulator’s viewer to analyze signals.



Output

Transaction logs with time, component, and signal values.
Pass/fail messages for each test case based on reset and data conditions.

Features

Modular design for easy maintenance.
Randomized testing of reset and data inputs.
Clear pass/fail reporting.
Waveform support for debugging.

Potential Improvements

Add functional coverage to measure test completeness.
Extend to test specific edge cases (e.g., consecutive resets).
Adopt UVM for standardization.

License
GNU License. See the LICENSE file for details.
Contributing
Contributions are welcome. Submit a pull request or open an issue for suggestions or bugs.
Contact
For questions, email gowdashashank414@gmail.com or open an issue.
