# Playfield IP Specification

## 1. Overview

The `playfield` IP implements the Tetris field state machine that manages:

- active piece placement and motion acceptance,
- collision checking against settled blocks,
- display readout with active-piece overlay,
- lock/merge of the active piece into the settled playfield,
- row-clear detection and score accumulation,
- simulation-only backdoor access for directed verification.

At a high level, the IP keeps two representations of the game field:

1. **Settled playfield**: the persistent block map stored across `rowBlocksNum` rows.
2. **Flow region**: a 4-row window that carries the currently active tetromino before it is locked.

The collision path compares the active 4-row window in `checker.region` against the underlying playfield rows. When the active piece is locked, the IP merges the flow region into the settled playfield, clears any completed rows, and updates the score.

## 2. Schematic

The block-level schematic was cropped from `playfield.png` and is included below.

<img src="./playfield_schematic_crop.png" alt="Playfield IP schematic" width="900" />

## 3. Source and implementation

- Source: `design/IPS/playfield/src/playfield.scala`
- Main class: `IPS.playfield.playfield`
- Configuration case class: `IPS.playfield.PlayfieldConfig`

## 4. Configuration

### 4.1 Elaboration parameters

```text
playfield(
  config: PlayfieldConfig,
  enableCollisonReadout: Boolean = false
)(implicit buildConfig: BuildConfig)
```

### 4.2 `PlayfieldConfig`

| Field | Type | Description |
| --- | --- | --- |
| `rowBlocksNum` | `Int` | Number of stored playfield rows. |
| `colBlocksNum` | `Int` | Number of playable columns per row. |
| `rowBitsWidth` | `Int` | Address width for row indexing. |
| `colBitsWidth` | `Int` | Column index width used by related logic. |
| `placeOffset` | `Int` | Reserved configuration field, default `3`. Not directly consumed in the current implementation. |
| `scoreBitsWidth` | `Int` | Width of the accumulated score output. |

## 5. Functional architecture

The implementation is partitioned into the following internal areas.

### 5.1 `piece_buffer`

- Stores the 4 rotation images for the currently requested tetromino.
- Loads piece bitmaps from `TetrominoesConfig.binaryTypeOffsetTable`.
- Centers a new piece horizontally using a fixed offset of `colBlocksNum / 2` inside an extended 4-row x (`colBlocksNum + 4`) staging area.
- Detects left/right wall overflow using two extra bits on each side.
- Tracks the current rotation in `rot_cur` and a restore point in `rot_backup`.

### 5.2 `checker`

- Holds a 4-row candidate region used for collision checking.
- Tracks the candidate top row in `row`.
- Supports restore, left shift, right shift, and row restore.
- Detects boundary overflow before collision checking:
  - `overflowIfLeft`
  - `overflowIfRight`
  - `overflowIfDown`

### 5.3 `playfield`

- Stores the settled field as `rowBlocksNum` rows of `Bits(colBlocksNum bits)`.
- Provides synchronous row readout and row writeback.
- Returns all ones on out-of-range row access; this acts as a synthetic bottom wall during collision operations.
- Clears the field on `game_restart`.
- Detects full rows and accumulates the score by the number of cleared rows.

### 5.4 `flow`

- Stores the visible active tetromino as 4 rows plus a base row index.
- Is copied from the `checker` region after a successful place or movement operation.
- Is OR-merged with the settled playfield during display readout.

### 5.5 `collision_checker`

- Computes row-wise collision by ANDing candidate rows from the playfield and checker DMA paths.
- Reports a pulse on `io.status`:
  - `payload = true`: collision detected,
  - `payload = false`: no collision.

### 5.6 `locker`

- Temporary 4-row RAM used during lock/merge.
- Receives the OR-merged value of settled playfield rows and flow rows.
- Plays back the merged rows into the settled playfield.

### 5.7 DMA helpers

The design uses internal `UniDma` helpers to sequence short fixed-length transfers for:

- whole-playfield readout,
- 4-row collision checking,
- 4-row merge into the locker,
- 4-row writeback from locker to playfield.

### 5.8 Main FSM

The `main_fsm` sequences the complete life cycle:

- `IDLE`
- `READOUT`
- `LOAD_TO_CHECKER`
- `COLLISION_CHECK`
- `REPORT_COLLISION`
- `END_OF_COLLISION`
- `PASS`
- `WAIT_CONTROL`
- `ROTATION`
- `PRE_CHECK`
- `LOCKER_WRITE_0`
- `LOCKER_WRITE_1`
- `WAIT_LOCKER_WRITE_DONE`
- `LOCKER_READ`
- `WAIT_LOCKER_READ_DONE`
- `CLEAR_REGION`
- `CHECK_ROW_FULL`
- `ROW_REMOVE`
- `ROW_REMOVE_DONE`

## 6. External interface

### 6.1 Front-door ports

| Port | Dir | Type | Description |
| --- | --- | --- | --- |
| `piece_in` | in | `Flow(TYPE())` | New tetromino type request. Rotation starts from the internal reset rotation (`0`). |
| `status` | out | `Flow(Bool())` | Collision result pulse. `true` means collision, `false` means pass. |
| `move_in.left` | in | `Bool` | Request one-cell move to the left. |
| `move_in.right` | in | `Bool` | Request one-cell move to the right. |
| `move_in.rotate` | in | `Bool` | Request rotation to the next internal rotation image. |
| `move_in.down` | in | `Bool` | Request one-row downward move. |
| `lock` | in | `Bool` | Lock the active flow region into the settled playfield. |
| `game_restart` | in | `Bool` | Clears the playfield and resets the accumulated score. |
| `row_val` | out | `Flow(Bits(colBlocksNum bits))` | Sequential row readout for display or observation. Includes flow-region overlay when applicable. |
| `score_val` | out | `Flow(UInt(scoreBitsWidth bits))` | Score update pulse after row-clear processing, and also after restart edge handling. |
| `motion_is_allowed` | out | `Bool` | High when the FSM is waiting for front-door control input. |
| `fsm_is_idle` | out | `Bool` | High when the FSM is in `IDLE`. |

### 6.2 Simulation-only ports

These ports are present only when the elaboration profile includes `Simulation`.

| Port | Dir | Type | Description |
| --- | --- | --- | --- |
| `playfield_backdoor` | in | `Flow(Playfield_Row_Data)` | Direct write access to one settled playfield row. |
| `flow_backdoor` | in | `flow_region_Data` | Direct write access to the 4-row flow region and its base row. |
| `checker_backdoor` | in | `flow_region_Data` | Direct write access to the 4-row checker region and its base row. |
| `start_collision_check` | in | `Bool` | Manual trigger for the collision-check sequence. |
| `fsm_reset` | in | `Bool` | Manual FSM reset from `WAIT_CONTROL` back to `IDLE`. |
| `fsm_contrl` | in | `Bool` | Manual transition from `IDLE` to `WAIT_CONTROL`. |
| `read` | in | `Bool` | Manual request for the `READOUT` state in simulation. |

## 7. Behavioral specification

### 7.1 Piece load and initial placement

1. `piece_in.valid` is sampled in `IDLE`.
2. The tetromino type selects one of seven shape tables (`I`, `J`, `L`, `O`, `S`, `T`, `Z`).
3. Rotation images are preloaded into `piece_buffer`.
4. The default placement path loads the current rotation into `checker.region` and starts collision checking.

A failed collision check during the initial place sequence reports `status.payload = true` and returns to `IDLE`, which effectively acts as the game-over condition for a newly spawned piece.

### 7.2 Motion handling

Motion commands are accepted in `WAIT_CONTROL`.

Command evaluation order is:

1. `left`
2. `right`
3. `down`
4. `rotate`
5. `lock`

If multiple controls are asserted in the same cycle, the earlier condition in that order wins.

Boundary checks are performed before launching memory-based collision checking:

- left movement uses `overflowIfLeft`,
- right movement uses `overflowIfRight`,
- down movement uses `overflowIfDown`,
- rotation uses the staged rotated image overflow flag.

A boundary failure is reported as a collision pulse without updating the flow region.

### 7.3 Collision checking

For each candidate operation, the IP compares 4 rows of the settled playfield beginning at `checker.row` against the 4-row checker region.

Collision rule:

```text
collision = OR over rows( playfield_row & checker_row )
```

Result reporting:

- `status.valid = 1, status.payload = 1`: operation collides,
- `status.valid = 1, status.payload = 0`: operation passes.

If the operation passes, the flow region is updated from the checker region.

### 7.4 Display readout

During `READOUT`, the IP streams `rowBlocksNum` rows on `row_val`.

- Base data comes from the settled playfield.
- When the streamed address overlaps the 4-row `flow.row` window, the corresponding flow rows are OR-merged into the outgoing data.

This allows a display path to render the active tetromino without modifying the settled playfield until `lock` is asserted.

### 7.5 Lock and merge

When `lock` is asserted in `WAIT_CONTROL`:

1. The corresponding 4 playfield rows are read.
2. The 4 flow rows are read.
3. Each pair is OR-merged.
4. The merged rows are buffered in `locker.region`.
5. The merged rows are written back into the settled playfield.
6. The flow/checker staging state is cleared.
7. Row-clear detection and score update run.

### 7.6 Row clear and scoring

The playfield computes a per-row `andR` to detect full rows.

- Full rows are removed one at a time by shifting lower-index rows downward.
- The top row is cleared after each remove operation.
- The count of completed rows is accumulated into `total_score`.

`score_val.valid` pulses after the score update latency, and `score_val.payload` carries the updated accumulated score.

### 7.7 Restart behavior

When `game_restart` is asserted:

- all settled playfield rows are cleared,
- `total_score` is reset to zero.

The internal flow/checker piece state is not synchronously cleared directly by `game_restart`; it is cleared by the normal lock/clear path or by simulation control sequences. Integrators should therefore restart the overall gameplay sequence from an idle state.

## 8. Data representation

### 8.1 Row storage

- Each playfield row is `Bits(colBlocksNum bits)`.
- Bit value `1` means occupied.
- Bit value `0` means empty.

### 8.2 Tetromino encoding

The tetromino type enum is defined by `config.TYPE` with members:

- `I`
- `J`
- `L`
- `O`
- `S`
- `T`
- `Z`

Each tetromino has 4 precomputed rotation images, each represented as 4 row bitmaps.

## 9. Timing and handshake notes

- `piece_in`, `status`, `row_val`, and `score_val` use `Flow`, so they carry `valid` without a `ready` backpressure signal.
- `piece_in` is internally piped through `m2sPipe(holdPayload = true)`, which captures the payload with one-cycle staging.
- Movement commands are level-sampled by the FSM; pulse them for one cycle unless a longer hold is intentionally desired.
- `row_val` is a streamed readout, not a random-access response port.

## 10. Verification hooks

The existing simulation environment exercises the IP in the following categories:

- readout correctness,
- collision detection,
- initial placement,
- movement sequences,
- lock/merge behavior,
- single-row to four-row clearing use cases.

Relevant verification sources:

- `design/IPS/playfield/test/PlayfieldTest.scala`
- `design/IPS/playfield/test/PlayfieldBackdoorAPI.scala`

## 11. Design limitations and integration notes

- The module accepts only tetromino type on `piece_in`; there is no external rotation index input.
- Rotation advances cyclically through the preloaded images.
- There is no front-door random row access to the settled field; only streamed readout is exposed.
- The implementation uses simulation-only backdoor ports that must not be relied on in synthesis builds.
- `enableCollisonReadout` changes the post-collision behavior by returning to `READOUT` instead of directly waiting for control.

## 12. Summary

The `playfield` IP is the stateful Tetris field controller for the project. It separates active-piece staging from settled block storage, performs 4-row collision checks, overlays the active piece during display readout, commits the piece on lock, and handles row clearing plus score accumulation.

