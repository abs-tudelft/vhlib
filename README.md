vhlib: a vendor-agnostic VHDL IP library
========================================

[![Build Status](https://dev.azure.com/abs-tudelft/vhlib/_apis/build/status/abs-tudelft.vhlib?branchName=master)](https://dev.azure.com/abs-tudelft/vhlib/_build/latest?definitionId=2&branchName=master)
[![codecov](https://codecov.io/gh/abs-tudelft/vhlib/branch/master/graph/badge.svg)](https://codecov.io/gh/abs-tudelft/vhlib)

`vhlib` is a library of generic, pure-VHDL components that implement common
functionality such as streams in an open source, vendor-agnostic way. It
started as part of [Fletcher](https://github.com/abs-tudelft/fletcher), but
considering how generic it is we decided to pull it apart.

Much more functionality should be added to `vhlib` over time as needed by the
ABS group or otherwise. Right now, we have the following:

 - A library of stream primitives. Think slices, FIFOs, resizers, and so on.
   `vhlib` streams are intended to be highly generic and lightweight, moreso
   than AXI-stream; therefore they are not *entirely* compatible, but they map
   almost one-to-one for simple streams.

 - A VHDL-2008 simulation framework that allows you to easily define unit tests
   in a single process each, in an entity separate from your unit-under-test
   and mockup interfaces. These mockups (called models) can be controlled
   through simple function calls in your test cases, without you needing to
   worry about handshakes, timing, or routing signals all over the place. This
   works together with [`vhdeps`](https://github.com/abs-tudelft/vhdeps), which
   can be used to run the test cases that come with `vhlib` easily; just run
   `vhdeps ghdl` or `vhdeps vsim | vsim` depending on which tool you have to
   run the test suite.

 - There are some utility libraries, but these are still relatively unstable.
   The most interesting one is a model for huge 64-bit-address memories that
   allocates on-the-fly, and has routines to import/export SREC files.

We want to have the following at some point:

 - A memory-mapped communication model based on our stream primitives, similar
   to AXI4 (but, like the streams, more lightweight).

 - A register file generator using the above and/or AXI4-lite. Development has
   sort of started [here](https://github.com/jvanstraten/vhdmmio).

 - Plug-and-play interfaces to and from AXI4.

We have no need for peripherals at this point since the ABS group is focusing
on datacenter-based FPGAs, where the interfacing to the outside world is
usually handled by a shell provided by the vendor. However, some simple things
may be added over time as needed.

The goal is for all synthesizable components to be compatible with both VHDL-93
and VHDL-2008, or at least have files for both versions if this is not possible
due to the need for shared variables (as are usually needed for inferring true
dual-port RAMs). The simulation framework is limited to VHDL-2008.

Documentation is currently purely scattered throughout the code. The goal is to
add some more proper documentation in the near future.
