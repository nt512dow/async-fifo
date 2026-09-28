# Asynchronous FIFO with Synchronous Gray Pointers

Some key notes:
- Based on Clifford Cummings' [paper](https://scholar.google.com/citations?view_op=view_citation&hl=en&user=j53P4MQAAAAJ&citation_for_view=j53P4MQAAAAJ:3fE2CSJIrl8C) 
- Involves clock domain crossing, where read and write clocks have different frequencies
- Uses gray code for pointers and a 2-flop synchronizer to ensure that the transmitted pointer value is either the current value (which may happen due to metastability) or the updated value
- Pessimistic pointers which are updated immediately upon empty/full but synchronized pointers may reflect old values
- Pointers are n+1 bits wide to distinguish full from empty
- Full is computed in the read domain, empty in the write domain


### Build Instructions:  
Requirements: Verilator 5.052, a C++ compiler, bash
```bash
chmod +x ./run.sh
./run.sh
```
This compiles once and runs the same binary with different clock periods and seeds which are configurable in the run.sh file.  
Waveform is written to async_fifo.vcd (open with surfer or GTKWave).


### Test Methodology:
- Individual modules were tested for basic functionality
- async_fifo_tb and run.sh involve different clock periods (coprime, multiples) and run till (1000 * DEPTH) write attempts are done
- At each write and read clock posedge, there is a 70% chance we attempt a read and write respectively, done to simulate randomness
- A queue was used to check validity of values
- A counter was used to check validity of reads and writes


### Architecture:
FIFO architecture followed the paper's design but I connected all resets.
![fifo](fifo.png)

Gray Code Counter architecture
![gray_code_counter](gray_code_counter.png)

Both pictures are taken from Clifford Cummings' [paper].(https://scholar.google.com/citations?view_op=view_citation&hl=en&user=j53P4MQAAAAJ&citation_for_view=j53P4MQAAAAJ:3fE2CSJIrl8C)


### Debugging Issues:
While testing async_fifo, I noticed the values of read_data did not match up with the values at the front of the queue. Initially, I had thought that it was an issue of timing with the #1 delay on the read clock when checking.  
After fixing that, I realised read_data was only sometimes giving me old values, only on read attempts that happen on two consecutive clock edges.  
It turned out in dual_port_ram, I had implemented read_data with sequential logic. It worked fine when I implemented read_data with combinational logic.


### Future Work:
- almost_full and almost_empty flags
- sequential read_data