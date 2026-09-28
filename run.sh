#!/bin/bash
set -e

#verilator builds a c++ executable, and invokes compiler to produce the native binary in ../sim/sim_out, running this from obj_dir
verilator --binary --timing --trace -Wall -Wno-fatal -f sim/files.f  --top-module async_fifo_tb -o ../sim/sim_out 

#at run time we put our plusargs in 
./sim/sim_out +write_half_period=5.5 +read_half_period=5.0 +ntb_random_seed=1
./sim/sim_out +write_half_period=2.5 +read_half_period=5.0 +ntb_random_seed=2
./sim/sim_out +write_half_period=5.0 +read_half_period=2.5 +ntb_random_seed=3
./sim/sim_out +write_half_period=7.0 +read_half_period=3.0 +ntb_random_seed=4
./sim/sim_out +write_half_period=5.0 +read_half_period=5.0 +ntb_random_seed=5
