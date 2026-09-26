# VeriMesh

<p align="center"><img src="docs/architecture.svg" width="96%" /></p>

<p align="center">
  <img src="https://img.shields.io/badge/SystemVerilog-RTL-2544D8?style=for-the-badge" />
  <img src="https://img.shields.io/badge/UVM-2020--3.2-6E4BE4?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Verilator-5.052-37D9A5?style=for-the-badge" />
  <img src="https://img.shields.io/badge/SVA-assertions-E86FA4?style=for-the-badge" />
</p>

**Reusable UVM verification environment for a configurable ready/valid packet switch.**

VeriMesh pairs a synthesizable 4×4 packet-switch DUT with a real class-based UVM environment and an open-source regression path.

## Verification architecture

```text
random / hotspot sequences
          │
          ▼
      sequencer
          │
          ▼
        driver
          │
          ▼
  ready/valid DUT  ◄──── SVA protocol assertions
       │     │
       │     └──────── output monitor ───────┐
       │                                     ▼
       └──── accepted-input monitor ───► scoreboard
                    │                   expected queues
                    │
                    └──────────────► functional coverage
```

## What is actually checked

### Stimulus
- randomized source port
- randomized destination port
- randomized 32-bit payload
- randomized downstream stall duration
- directed hotspot traffic to force arbitration pressure

### Scoreboard
Every accepted input transaction is cloned into a **per-destination expected queue**. Every output handshake pops and compares the corresponding expected payload. Unexpected packets, payload mismatches, and packets still queued at end-of-test are errors.

This is end-to-end checking, not packet counting.

### Monitors
VeriMesh has separate monitors for:
- input transactions that were actually accepted by the DUT
- output transactions that actually completed under `out_ready`

### Functional coverage
Coverage samples accepted traffic and includes:
- source ports
- destination ports
- source × destination route cross
- payload-class bins

### Assertions
SVA checks that `out_valid` remains asserted while an output is backpressured.

## DUT

The DUT is a synthesizable 4×4 ready/valid switch. Each input supplies a destination and 32-bit payload. For each output, the lowest-index valid requester wins. Backpressure propagates to the winning source through `in_ready`.

## Run the UVM regression

Open-source Verilator path:

```bash
git clone https://github.com/verilator/uvm.git /tmp/uvm

docker run --rm --entrypoint /bin/bash \
  -v "$PWD:/work" \
  -v "/tmp/uvm:/uvm:ro" \
  -w /work \
  verilator/verilator:latest \
  -lc 'make verilator-uvm TEST=switch_base_test UVM_HOME=/uvm/src'
```

Commercial-simulator targets remain available:

```bash
make questa TEST=switch_base_test
make vcs TEST=switch_hotspot_test
make xrun TEST=switch_base_test
```

## CI

Every push runs three independent paths:

1. **Verilator RTL lint**
2. **portable Python arbitration reference model**
3. **real UVM regression in Verilator 5.052**, including both:
   - `switch_base_test`
   - `switch_hotspot_test`

The latest regression passes all three jobs.

## Repository map

```text
rtl/packet_switch.sv       synthesizable DUT
rtl/packet_switch_sva.sv   protocol assertions
uvm/switch_pkg.sv          packaged UVM environment
uvm/switch_item.sv         transaction object
uvm/switch_sequence.sv     random + hotspot traffic
uvm/switch_driver.sv       source + backpressure driver
uvm/switch_monitor.sv      dual transaction monitors
uvm/switch_scoreboard.sv   end-to-end expected queues
uvm/switch_coverage.sv     route functional coverage
uvm/switch_env.sv          reusable verification environment
uvm/switch_test.sv         regression tests
model/reference.py         portable arbitration oracle
```

VeriMesh targets standard UVM APIs and keeps the DUT, reference model, assertions, coverage, and scoreboard independently inspectable.
