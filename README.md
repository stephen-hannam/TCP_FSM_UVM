## Self-study UVM

UVM and Systemverilog self-study goal-oriented project. The chosen goal will be the design and implementation of a TCP connection controller, centering on a Finite State Machine (FSM) representing the core functionality for establishing and terminating connections in TCP.

### Approach

Use fizzim to construct the various FSMs for phases of TCP connections, and then verify them using UVM (during the course of which synth'able and non-synth'able Systemverilog constructs will also be covered).

UVM will be expedited by Easier-UVM from [Doulos](https://www.doulos.com/knowhow/sysverilog/uvm/) and initially via Getting Started videos found in a playlist maintained by John Aynsley [here](https://www.youtube.com/watch?v=qLr8ayWM_Ww&list=PLBIILfL2t1lnvzw7vF0arlvu36Wj4--D7&index=2&spfreload=10).

### Setup

Download uvm-1.2 ('Class Library Code') from [here](https://accellera.org/downloads/standards/uvm) and follow install instructions given [here](https://www.chipverify.com/uvm/uvm-installation).

If the second link is dead, just untar the download somewhere convenient, and create an environment variable in your terminal pointing to it; eg, called `$UVM_HOME`.

Having brought in a local copy of the BCL (Base Class Library) code, use a compiler directive (typically `-incdir $UVM_HOME`) in your synth tools config or command line call, and ensure correct use of include and import statements in your projects source code.

### NB: ModelSim

If using UVM with ModelSim there are some small adjustments needed in the code, see [here for exposition](https://eda-playground.readthedocs.io/en/latest/modelsim-uvm.html).

### External Resources

Various images in the repo were pulled from online.

Very details slides describing the core workings of TCP can be found [here](https://www.slideshare.net/PeterREgli/tcp-6027334).
