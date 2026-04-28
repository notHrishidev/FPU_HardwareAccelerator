# FPU Hardware Accelerator

A custom 16-bit Floating-Point Unit (FPU) implemented in Verilog, designed for ASIC synthesis. The FPU performs floating-point **multiplication** using a hierarchical Vedic multiplier for the mantissa and a Square-Root Carry Select Adder (SQRT-CSLA) for the exponent, all orchestrated by a 4-state Finite State Machine (FSM).

---

## Table of Contents

1. [Floating-Point Format](#floating-point-format)
2. [Architecture](#architecture)
   - [Top-Level FPU FSM](#top-level-fpu-fsm)
   - [Vedic 8×8 Multiplier](#vedic-88-multiplier)
   - [SQRT Carry Select Adder (SQRT-CSLA)](#sqrt-carry-select-adder-sqrt-csla)
   - [Module Hierarchy](#module-hierarchy)
3. [Port Description](#port-description)
4. [Features](#features)
5. [Limitations](#limitations)
6. [Testbench Instantiation](#testbench-instantiation)
   - [File Includes](#file-includes)
   - [Single-Shot Example](#single-shot-example)
   - [Burst Mode Example](#burst-mode-example)
7. [Synthesis Configuration](#synthesis-configuration)
8. [Directory Structure](#directory-structure)

---

## Floating-Point Format

The FPU uses a **custom 16-bit floating-point format** — it is **not** IEEE 754 compliant.

| Bit(s) | Field    | Width |
|--------|----------|-------|
| 15     | Sign     | 1 bit |
| 14 – 7 | Exponent | 8 bits |
| 6 – 0  | Mantissa | 7 bits (implicit leading 1 assumed) |

The leading `1` of the mantissa is implicit (hidden bit), so the effective mantissa precision is 8 bits. The exponent field is unsigned and biased encoding is expected to be handled by the user; the hardware performs raw binary addition of the two exponent fields.

---

## Architecture

### Top-Level FPU FSM

The FPU is controlled by a synchronous 4-state Moore FSM clocked on the rising edge of `clk`.

```
        reset
          │
          ▼
     ┌─────────┐
     │  Idle   │◄─────────────────┐
     └────┬────┘                  │ (burst == 0)
          │                       │
          ▼                       │
     ┌─────────┐            ┌─────┴────┐
     │  Calc   │            │  ResOut  │
     └────┬────┘            └─────▲────┘
          │                       │
          ▼                       │
     ┌─────────┐                  │
     │ FPUAdj  │──────────────────┘
     └─────────┘       (burst == 1 → back to Calc)
```

| State   | Action |
|---------|--------|
| **Idle**   | Clears internal registers; asserts `ready = 1` |
| **Calc**   | Latches inputs; restores implicit leading `1` on mantissas (`{1'b1, A[6:0]}`); separates exponents; deasserts `ready` |
| **FPUAdj** | Performs post-multiplication normalization: if bit 15 of the 16-bit mantissa product is set, shifts mantissa right by 1 and increments the exponent sum by 1 |
| **ResOut** | Assembles the output `P`; asserts `ready = 1`; loops back to `Calc` when `burst` is active |

**Computation per state:**

- **Mantissa**: `{1'b1, A[6:0]} × {1'b1, B[6:0]}` via the Vedic_8x8 multiplier (produces a 16-bit product; upper 7–8 bits become the output mantissa after normalization).
- **Exponent**: `A[14:7] + B[14:7]` via SQRT_CSLA (+ optional `1` for normalization adjustment).
- **Sign**: `A[15] XOR B[15]`.

**Latency**: 4 clock cycles per multiplication (one cycle per FSM state).

---

### Vedic 8×8 Multiplier

The mantissa multiplier is built using the **Urdhva Tiryagbhyam** (Vedic mathematics) algorithm, implemented as a recursive hierarchy of smaller multipliers and Carry Select Adders.

```
Vedic_8x8 (8×8 → 16-bit)
├── 4× Vedic_4x4 (4×4 → 8-bit)
│     └── 4× Vedic_2x2 (2×2 → 4-bit, combinational AND/XOR)
├── 2× b8CSLA (8-bit Carry Select Adder)
└── 1× b4CSLA (4-bit Carry Select Adder)

Vedic_4x4 (4×4 → 8-bit)
├── 4× Vedic_2x2
├── 2× b4CSLA
└── 1× b4CSLA
```

The Carry Select Adders (CSLA) pre-compute results for both possible carry-in values and use a multiplexer to select the correct result when the carry propagates, eliminating carry-ripple delay across the adder stages.

- **b8CSLA**: 8-bit CSLA built from four 2-bit Ripple Carry Adder (b2RCA) groups.
- **b4CSLA**: 4-bit CSLA built from two b2RCA groups.
- **b2RCA**: 2-bit Ripple Carry Adder (base adder primitive, fully combinational).

---

### SQRT Carry Select Adder (SQRT-CSLA)

The exponent adder uses a **Square-Root CSLA** with group sizes following the √N pattern (groups of 1, 3, and 4 bits for an 8-bit total), which balances area and speed better than a uniform-group CSLA.

```
SQRT_CSLA (8-bit + 8-bit → 8-bit sum, ovf)
├── Group 1 (bits [0:0],   1-bit): bNRCA with Cin=0
├── Group 2 (bits [3:1],   3-bit): bNRCA with Cin=0 and Cin=1
└── Group 3 (bits [7:4],   4-bit): bNRCA with Cin=0 and Cin=1
```

- **bNRCA** – Parameterized N-bit Ripple Carry Adder built from a generate-loop of Full Adders (`FA`).
- **FA** – Standard 1-bit Full Adder (sum = A⊕B⊕Cin, carry = majority).
- **Overflow** – Detected via signed overflow formula: `ovf = ~(A[7] ^ B[7]) & (A[7] ^ S[7])` (same-sign inputs, different-sign result).

---

### Module Hierarchy

```
FPU
├── Vedic_8x8
│   ├── Vedic_4x4 (×4)
│   │   ├── Vedic_2x2 (×4)
│   │   └── b4CSLA (×3)
│   │       └── b2RCA (×2 per b4CSLA)
│   ├── b8CSLA (×2)
│   │   └── b2RCA (×4 per b8CSLA)
│   └── b4CSLA (×1)
└── SQRT_CSLA
    └── bNRCA (×5 instances, different N)
        └── FA (×N per bNRCA)
```

---

## Port Description

| Port     | Direction | Width  | Description |
|----------|-----------|--------|-------------|
| `A`      | Input     | 16-bit | First floating-point operand |
| `B`      | Input     | 16-bit | Second floating-point operand |
| `clk`    | Input     | 1-bit  | Clock (rising-edge triggered) |
| `reset`  | Input     | 1-bit  | Synchronous active-high reset |
| `enable` | Input     | 1-bit  | When high, the FSM advances each clock cycle |
| `burst`  | Input     | 1-bit  | When high at `ResOut`, the FSM loops back to `Calc` immediately (back-to-back multiplications) |
| `P`      | Output    | 16-bit | Floating-point product result |
| `ovf`    | Output    | 1-bit  | Sticky overflow flag (set when exponent addition overflows; cleared only by `reset`) |
| `ready`  | Output    | 1-bit  | High when the FPU is idle or has just produced a result |

---

## Features

- **Custom 16-bit floating-point multiplication** (1 sign + 8 exponent + 7 mantissa bits).
- **Implicit leading-1 mantissa** — the hardware restores the hidden bit before multiplying.
- **One-bit post-multiplication normalization** — detects whether the mantissa product overflows 7 bits and adjusts the result and exponent accordingly.
- **Burst mode** — continuous back-to-back multiplications without returning to Idle, reducing FSM overhead.
- **Sticky overflow flag** — `ovf` latches once the exponent adder overflows and remains set until `reset`, giving the user a persistent indication of any overflow event.
- **Hierarchical Vedic multiplier** — fully combinational, area- and speed-efficient 8×8 multiplication.
- **SQRT-CSLA exponent adder** — reduced carry-propagation delay compared to a ripple-carry adder.
- **Synchronous reset** — all registers and outputs return to a known state on the next rising edge after `reset` is asserted.
- **OpenLane ASIC flow ready** — `config.tcl` targets a 100 MHz clock (10 ns period) with a 40% core utilization floor-plan.

---

## Limitations

1. **Not IEEE 754 compliant.** The format (1-8-7) differs from half-precision (1-5-10) and single-precision (1-8-23). No bias adjustment is applied to the exponent.
2. **Multiplication only.** Addition, subtraction, and division are not supported.
3. **No special-value handling.** NaN, ±Infinity, and denormal (subnormal) numbers are not detected or handled.
4. **Single-bit normalization only.** The normalization step only handles a 1-bit shift in the mantissa product. Results that require larger shifts (e.g., if both mantissas are zero) are not handled correctly.
5. **Exponent bias not applied.** The hardware adds raw exponent bits; the caller is responsible for applying and removing any exponent bias.
6. **Exponent overflow wraps silently** (except for the sticky `ovf` flag). There is no saturation or clamping.
7. **Simplified CSLA carry-in.** The lowest group of the SQRT_CSLA and the `b4CSLA`/`b8CSLA` adders always assume `Cin = 0`. This is correct for the FPU's internal use but limits direct reuse in general-purpose adder contexts.
8. **4-cycle latency** per multiplication; no pipelining within a single multiply operation (new inputs are accepted only after `ready` is asserted again).
9. **`enable` must be held high** throughout a computation. Deasserting `enable` mid-computation stalls the FSM in the current state.

---

## Testbench Instantiation

### File Includes

Before instantiating the FPU in a simulation testbench, include all source files in dependency order. Adjust the path prefix to match your project root:

```verilog
// Vedic Multiplier hierarchy
`include "src/VedicMultiplier/b2RCA.v"
`include "src/VedicMultiplier/b4CSLA.v"
`include "src/VedicMultiplier/b8CSLA.v"
`include "src/VedicMultiplier/Vedic_2x2.v"
`include "src/VedicMultiplier/Vedic_4x4.v"
`include "src/VedicMultiplier/Vedic_8x8.v"

// SQRT Carry Select Adder hierarchy
`include "src/SQRT_CSLA/FA.v"
`include "src/SQRT_CSLA/bNRCA.v"
`include "src/SQRT_CSLA/SQRT_CSLA.v"

// Top-level FPU
`include "src/FPU/FPU.v"
```

### Single-Shot Example

Computes `A × B`, waits for `ready`, then reads `P`.

```verilog
module tb_FPU_example;

    // ── DUT signals ──────────────────────────────────────────
    reg         clk, reset, enable, burst;
    reg  [15:0] A, B;
    wire [15:0] P;
    wire        ovf, ready;

    // ── DUT instantiation ────────────────────────────────────
    FPU dut (
        .A      (A),
        .B      (B),
        .clk    (clk),
        .reset  (reset),
        .burst  (burst),
        .enable (enable),
        .P      (P),
        .ovf    (ovf),
        .ready  (ready)
    );

    // ── 100 MHz clock ────────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period

    // ── Stimulus ─────────────────────────────────────────────
    initial begin
        // Assert synchronous reset
        reset  = 1;
        enable = 1;
        burst  = 0;
        A      = 16'b0_00000101_0000000;  // example operand A
        B      = 16'b0_00000110_0000000;  // example operand B

        @(posedge clk); #1;  // hold reset for one full cycle
        reset = 0;

        // Apply operands on the next rising edge
        @(posedge clk);

        // Wait for the FPU to finish (ready goes low then high)
        @(negedge ready);   // FPU started computing
        @(posedge ready);   // result is available

        $display("A = %b | B = %b | P = %b | ovf = %b", A, B, P, ovf);

        $finish;
    end

endmodule
```

### Burst Mode Example

Performs several back-to-back multiplications without returning to Idle between operations.

```verilog
initial begin
    reset  = 1;
    enable = 1;
    burst  = 1;   // keep going after each result
    A      = 16'b0_00000101_0000000;
    B      = 16'b0_00000110_0000000;

    @(posedge clk); #1;
    reset = 0;

    @(posedge clk);

    repeat (3) begin
        @(posedge ready);   // wait for each result
        $display("P = %b | ovf = %b", P, ovf);

        // Update operands for the next burst iteration
        A = A + 1;
        B = B + 1;
    end

    // Deassert burst to let the FSM return to Idle after the last result
    burst = 0;
    @(posedge ready);
    $display("Final P = %b | ovf = %b", P, ovf);

    $finish;
end
```

### Signal Timing Reference

```
         ___     ___     ___     ___     ___
clk  ___|   |___|   |___|   |___|   |___|   |___

       Idle    Calc   FPUAdj  ResOut   Idle
              ← A,B valid ─────────────────►
                                      ← P valid
ready  ──────╮                       ╭──────────
             ╰───────────────────────╯
```

> **Note:** `enable` must remain high during all four FSM states for the computation to proceed. Deasserting `enable` at any point holds the FSM in its current state.

---

## Synthesis Configuration

The included `config.tcl` targets the OpenLane ASIC flow:

| Parameter          | Value        | Description |
|--------------------|--------------|-------------|
| `DESIGN_NAME`      | `FPU`        | Top-level module |
| `CLOCK_PORT`       | `clk`        | Clock net name |
| `CLOCK_PERIOD`     | 10 ns        | 100 MHz target |
| `FP_SIZING`        | relative     | Floorplan sizing mode |
| `FP_CORE_UTIL`     | 40%          | Core area utilization |
| `PL_TARGET_DENSITY`| 0.45         | Placement density |
| `SYNTH_STRATEGY`   | `DELAY 0`    | Optimize for delay |
| `SYNTH_MAX_FANOUT` | 10           | Maximum fanout per net |
| `FP_PDN_VPITCH`    | 180 µm       | Vertical power grid pitch |
| `FP_PDN_HPITCH`    | 180 µm       | Horizontal power grid pitch |

---

## Directory Structure

```
FPU_HardwareAccelerator/
├── config.tcl                  # OpenLane synthesis configuration
├── src/
│   ├── headers.v               # `include path reference (commented templates)
│   ├── FPU/
│   │   └── FPU.v               # Top-level FPU FSM
│   ├── VedicMultiplier/
│   │   ├── Vedic_2x2.v         # 2×2 Vedic multiplier (combinational)
│   │   ├── Vedic_4x4.v         # 4×4 Vedic multiplier
│   │   ├── Vedic_8x8.v         # 8×8 Vedic multiplier (used by FPU)
│   │   ├── b2RCA.v             # 2-bit Ripple Carry Adder
│   │   ├── b4CSLA.v            # 4-bit Carry Select Adder
│   │   └── b8CSLA.v            # 8-bit Carry Select Adder
│   └── SQRT_CSLA/
│       ├── FA.v                # 1-bit Full Adder
│       ├── bNRCA.v             # Parameterized N-bit Ripple Carry Adder
│       └── SQRT_CSLA.v         # 8-bit Square-Root Carry Select Adder
└── TB/
    ├── FPU/
    │   └── tb_FPU.v            # FPU top-level testbench
    ├── VedicMultiplier/
    │   ├── tb_Vedic_2x2.v
    │   ├── tb_Vedic_4x4.v
    │   ├── tb_Vedic_8x8.v
    │   ├── tb_b2RCA.v
    │   ├── tb_b4CSLA.v
    │   └── tb_b8CSLA.v
    └── SQRT_CSLA/
        ├── tb_SQRT_CSLA.v
        └── tb_bNRCA.v
```
