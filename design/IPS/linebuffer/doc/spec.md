# LineBuffer Specification

## 1. Module Purpose
`LineBuffer` stores one line of input pixels in RAM and streams them out in the read clock domain.

The read path supports horizontal scaling by repeating each fetched pixel for multiple `rdClock` cycles.

## 2. Implementation Reference
Source: `design/IPS/linebuffer/src/LineBuffer.scala`

This specification follows current signal naming as implemented:
- `io.wr_in`
- `io.rd_start`
- `io.rd_out`
- `rd.enable`
- `rd.scale_cnt`
- `rd.valid` (internal read-fire signal)

## 3. Interface
### 3.1 Write Side (`wrClock` domain)
- `io.wr_in.valid`: write strobe.
- `io.wr_in.payload`: pixel/sample data.

Behavior:
- On each cycle with `io.wr_in.valid == True`, write `payload` into RAM at current write address.
- Write address increments on each valid write and wraps to `0` after `depth - 1`.

### 3.2 Read Side (`rdClock` domain)
- `io.rd_start`: start pulse for one output line read.
- `io.rd_out.valid`: output stream valid.
- `io.rd_out.payload`: output pixel/sample.

Behavior:
- `io.rd_start` resets read address to `0`, clears `scale_cnt`, and sets `rd.enable := True`.
- While `rd.enable` is `True`, output stream is active.
- Read session stops when read address reaches `depth - 1` and scale counter indicates the last repetition for that address.

## 4. Parameters and Constraints
- `depth`: RAM depth (must be `>= 2`, power of two).
- `rd_scale`: scaling factor (must be `>= 1`, power of two).
- `wrClock`: write clock domain, must be non-null.
- `rdClock`: read clock domain, must be non-null.

## 5. Scale Functionality (Normative)
`rd_scale` defines how many `rdClock` cycles each RAM pixel is presented on `io.rd_out.payload` while `io.rd_out.valid` is asserted.

Definitions (same as implementation intent):
- `rd.valid` (internal) = read-fire strobe to RAM.
- `io.rd_out.valid` = stream-active valid, not "new RAM read" indicator.

Rules:
1. RAM is read once per pixel repetition group (on internal `rd.valid` pulse).
2. The returned RAM word is held on `io.rd_out.payload` and reused for multiple cycles.
3. Each RAM word occupies exactly `rd_scale` active output cycles.
4. Read address increments once per repetition group (after `rd_scale` cycles).

Equivalent relation:
- Output cycles per source pixel = `rd_scale`
- Total active output cycles for one line = `depth * rd_scale`

Example (`rd_scale = 4`):
- Address 0 pixel is emitted for 4 consecutive valid cycles.
- Address advances to 1, then pixel 1 is emitted for 4 cycles.
- Repeats until address `depth - 1` is emitted for 4 cycles, then stream stops.

## 6. Timing Notes
- RAM read is synchronous (`readSync`), so payload update is aligned to read-fire latency.
- `io.rd_out.valid` reflects stream activity window (read session), which intentionally covers repeated-pixel cycles.
- Consumers must interpret `io.rd_out.valid` as "pixel available this cycle"; it does not imply a fresh RAM fetch each cycle.

## 7. Reset/Restart Behavior
- A pulse on `io.rd_start` restarts read from address `0` and clears repetition phase.
- If `io.rd_start` is asserted while reading is active, current logic restarts the line from the beginning.

## 8. Non-Goals
- No backpressure: output uses `Flow` (no `ready`).
- No frame/line boundary metadata besides `io.rd_start` and valid window.

## 9. Verification Checklist
1. `rd_scale = 1`: one output cycle per RAM word.
2. `rd_scale > 1`: each RAM word repeated exactly `rd_scale` valid cycles.
3. Output line length equals `depth * rd_scale` valid cycles.
4. End condition stops after last repeated pixel of address `depth - 1`.
5. Mid-read `rd_start` causes deterministic restart to address `0`.

