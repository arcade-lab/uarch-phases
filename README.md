# uarch-phases

A hardware design that supports the collection of processor signal profiles. The signals collected included the program counter, instruction type, processor stalls, bus activity, register file activity, and various other signals along the instruction pipeline. The signals are packed into 32-bits and stored in SRAMS (4MB). When the SRAMS were filled up during runtime, an interrupt is generated and an interrupt handler reads and stores the samples to main memory. 

## Directory organization:

```

src/
 |_ lib/
    |_ tracing/
doc/
 |_ images/
 |_ paper/
    |_ figs/

```


