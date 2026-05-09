# Bram2p Specification

## 1. Overview

`Bram2p` is a single-clock, dual-port block RAM wrapper written in SpinalHDL.
It provides:

- one synchronous write port
- one synchronous read port with `Flow`-based output
- memory initialization from an optional hex file
- a hardware-assisted memory clear operation
- simulation / elaboration-time protection against external writes during clear

The generated RTL module name is:

- `Bram2p_<wordWidth>x<depth>`

Example: `Bram2p_8x1024`

---

## 2. Configuration Parameters

The block is configured by `Bram2pConfig`.

| Parameter | Type | Description |
| --- | --- | --- |
| `wordWidth` | `Int` | Width of each memory word in bits. |
| `depth` | `Int` | Number of memory locations. |
| `initFileName` | `String` | Optional hex initialization file path. Empty string disables file-based initialization. |
| `default_value` | `BigInt` | Default fill value used when no init file is provided and during clear. |

### 2.1 Derived Parameter

| Name | Definition | Description |
| --- | --- | --- |
| `addressWidth` | `log2Up(depth)` | Address width required to cover the configured depth. |

### 2.2 Initialization Behavior

Initialization data is produced by `MemInitUtils.loadHexInitFile(...)`.

Behavior:

- If `initFileName` is provided and valid, memory contents are loaded from that file.
- If no initialization file is provided, the memory is filled with `default_value`.
- The initialization vector is sized to `depth`.
- Each word is constrained to `wordWidth` bits by the initialization utility.

---

## 3. Interface

`Bram2p` exposes `Bram2pIo`.

### 3.1 Write Port: `wr`

| Signal | Direction | Type | Description |
| --- | --- | --- | --- |
| `wr.en` | input | `Bool` | Write enable. |
| `wr.addr` | input | `UInt(addressWidth bits)` | Write address. |
| `wr.data` | input | `Bits(wordWidth bits)` | Write data. |

### 3.2 Read Port: `rd`

| Signal | Direction | Type | Description |
| --- | --- | --- | --- |
| `rd.en` | input | `Bool` | Read request enable. |
| `rd.addr` | input | `UInt(addressWidth bits)` | Read address. |
| `rd.data.valid` | output | `Bool` | Read data valid, asserted one cycle after `rd.en`. |
| `rd.data.payload` | output | `Bits(wordWidth bits)` | Read data returned by the synchronous memory read. |

`rd.data` uses a `Flow`, so there is no ready/acknowledge signal.

### 3.3 Clear Control

| Signal | Direction | Type | Description |
| --- | --- | --- | --- |
| `clear_start` | input | `Bool` | Starts a full-memory clear on a rising edge. |
| `clear_done` | output | `Bool` | Pulses when the clear sequence reaches its final address. |

---

## 4. Functional Behavior

### 4.1 Write Operation

A normal write occurs when:

- `clear_busy = False`
- `wr.en = True`

In that case:

- `wr.addr` selects the target location
- `wr.data` is written to memory

### 4.2 Read Operation

The memory read is synchronous.

When `rd.en` is asserted:

- `rd.addr` is sampled by the RAM read port
- `rd.data.valid` is asserted on the next cycle
- `rd.data.payload` returns the corresponding memory word on the next cycle

This implies a one-cycle read latency.

### 4.3 Clear Operation

The clear engine writes `default_value` into every memory location.

#### Clear Sequence

1. A rising edge on `clear_start` sets the internal `clear_busy` flag.
2. While `clear_busy` is high, the write port is internally redirected:
   - write address comes from the internal clear counter
   - write data is forced to `default_value`
   - write enable is forced active
3. The internal counter steps through the full memory range.
4. When the counter reaches its final location, the clear operation completes:
   - `clear_done` is asserted
   - `clear_busy` is cleared

#### Clear Characteristics

- The clear sequence occupies the write port for the full duration of the operation.
- The clear fills all addresses from `0` to `depth - 1`.
- The clear value is always `default_value`.
- `clear_done` is a completion indication, not a level status.

---

## 5. Arbitration and Access Rules

`Bram2p` has one physical write port in the underlying memory.
During clear, that port is reserved for internal clear writes.

### Rule: No External Write During Clear

External writes are not allowed while clear is active.

The design explicitly checks:

- `external_write_during_clear = clear_busy && wr.en`

If this condition occurs, the design raises:

- a SpinalHDL assertion with `FAILURE` severity
- an inline Verilog / SVA assertion in simulation when `SIM` is enabled

### Practical Implication

System-level logic must guarantee:

- `wr.en = False` whenever a clear is in progress

If external write traffic is needed, it must be stalled or arbitrated outside `Bram2p`.

---

## 6. Timing Summary

| Path | Timing |
| --- | --- |
| Write request to memory update | Same cycle as enabled write port behavior of generated RAM |
| Read request to `rd.data.valid` | 1 cycle |
| Read request to `rd.data.payload` | 1 cycle |
| `clear_start` rising edge to first clear write | Begins when `clear_busy` becomes active |
| Clear duration | `depth` write cycles |

Notes:

- Exact write visibility during simultaneous read/write to the same address depends on the generated memory semantics.
- The current implementation is single-clock and does not introduce explicit clock-domain crossing logic.

---

## 7. Internal Structure

The main internal elements are:

- `memory`: `Mem(Bits(wordWidth bits), depth)`
- `clear_busy`: indicates that the memory clear process owns the write port
- `clear_addr`: counter used to sweep memory addresses during clear
- `wr_addr`: mux between external write address and internal clear address
- `wr_data`: mux between external write data and `default_value`
- `wr_en`: combined write enable for normal write or clear write

The memory is annotated with:

- `ram_style = "block"`

This is intended to guide FPGA inference toward block RAM resources.

---

## 8. Reset and Clocking

`Bram2p` operates in the current SpinalHDL clock domain.

Relevant reset behavior:

- `clear_busy` resets to `False`
- `rd.data.valid` resets to `False`

The inline assertion block is mapped to the current clock domain using:

- current clock as `clk`
- current reset as `rst`

No separate read/write clock domains are implemented.

---

## 9. Constraints and Assumptions

The following assumptions apply to correct use:

1. `depth` must be a valid positive memory depth.
2. `wordWidth` must be a valid positive data width.
3. External logic must not request writes while clear is active.
4. Read behavior during clear is allowed by the current implementation, but returned data depends on the addresses being read while the memory contents are being overwritten.
5. If read and write target the same address in overlapping cycles, the observed value depends on the inferred RAM semantics of the target technology.

---

## 10. Verification-Relevant Notes

The implementation contains two protection mechanisms for illegal write-during-clear behavior:

1. Spinal assertion:
   - catches the violation at elaboration / simulation level depending on backend support
2. Inline Verilog SVA block:
   - active under `` `ifdef SIM ``
   - reports an error if `vld` is asserted during a clock edge outside reset

Recommended verification scenarios:

- normal write then readback
- initialization-file content check
- default-value initialization when file is absent
- full-memory clear completion after `depth` cycles
- read during clear
- illegal external write during clear
- boundary addresses `0` and `depth - 1`

---

## 11. Example Use Cases

Typical use cases include:

- tile / frame buffer storage
- lookup tables
- simple single-clock local memory
- small scratchpad memory with deterministic bulk clear

---

## 12. Summary

`Bram2p` is a configurable single-clock dual-port RAM abstraction with:

- synchronous write
- synchronous single-cycle-latency read
- optional hex-file initialization
- built-in sequential clear over the full address space
- explicit protection against external writes during clear

It is suitable when a design needs a simple block RAM with a dedicated clear operation and predictable interface behavior.
