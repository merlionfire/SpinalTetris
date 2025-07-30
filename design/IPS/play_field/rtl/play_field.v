// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : play_field
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module play_field (
  input  wire          block_pos_valid,
  input  wire [3:0]    block_pos_payload_x,
  input  wire [4:0]    block_pos_payload_y,
  input  wire          update,
  input  wire          clear_start,
  input  wire          block_set,
  input  wire          restart,
  input  wire          fetch,
  output reg           clear_done,
  output wire          block_val_valid,
  output wire          block_val_payload,
  output wire          row_val_valid,
  output wire [9:0]    row_val_payload,
  output reg           lines_cleared_valid,
  output reg  [4:0]    lines_cleared_payload,
  input  wire          clk,
  input  wire          reset
);
  localparam IDLE = 3'd0;
  localparam ENABLE_ROWS = 3'd1;
  localparam ROWS_FULL_READY = 3'd2;
  localparam LOCK = 3'd3;
  localparam CHECK = 3'd4;
  localparam CLEAR = 3'd5;
  localparam SHIFT = 3'd6;

  wire                row_0_io_row;
  wire                shift_ctrl_0_io_full_locked;
  wire                row_1_io_row;
  wire                shift_ctrl_1_1_io_full_locked;
  wire                row_2_io_row;
  wire                shift_ctrl_2_1_io_full_locked;
  wire                row_3_io_row;
  wire                shift_ctrl_3_1_io_full_locked;
  wire                row_4_io_row;
  wire                shift_ctrl_4_1_io_full_locked;
  wire                row_5_io_row;
  wire                shift_ctrl_5_1_io_full_locked;
  wire                row_6_io_row;
  wire                shift_ctrl_6_1_io_full_locked;
  wire                row_7_io_row;
  wire                shift_ctrl_7_1_io_full_locked;
  wire                row_8_io_row;
  wire                shift_ctrl_8_1_io_full_locked;
  wire                row_9_io_row;
  wire                shift_ctrl_9_1_io_full_locked;
  wire                row_10_io_row;
  wire                shift_ctrl_10_1_io_full_locked;
  wire                row_11_io_row;
  wire                shift_ctrl_11_1_io_full_locked;
  wire                row_12_io_row;
  wire                shift_ctrl_12_1_io_full_locked;
  wire                row_13_io_row;
  wire                shift_ctrl_13_1_io_full_locked;
  wire                row_14_io_row;
  wire                shift_ctrl_14_1_io_full_locked;
  wire                row_15_io_row;
  wire                shift_ctrl_15_1_io_full_locked;
  wire                row_16_io_row;
  wire                shift_ctrl_16_1_io_full_locked;
  wire                row_17_io_row;
  wire                shift_ctrl_17_1_io_full_locked;
  wire                row_18_io_row;
  wire                shift_ctrl_18_1_io_full_locked;
  wire                row_19_io_row;
  wire                shift_ctrl_19_1_io_full_locked;
  wire                row_20_io_row;
  wire                shift_ctrl_20_1_io_full_locked;
  wire                row_21_io_row;
  wire                shift_ctrl_21_1_io_full_locked;
  wire       [9:0]    row_0_io_blocks_out;
  wire                row_0_io_full;
  wire                shift_ctrl_0_io_full_out;
  wire                shift_ctrl_0_io_holes_out;
  wire                shift_ctrl_0_io_shift_en;
  wire                shift_ctrl_0_io_clear_en;
  wire       [9:0]    row_1_io_blocks_out;
  wire                row_1_io_full;
  wire                shift_ctrl_1_1_io_full_out;
  wire                shift_ctrl_1_1_io_holes_out;
  wire                shift_ctrl_1_1_io_shift_en;
  wire                shift_ctrl_1_1_io_clear_en;
  wire       [9:0]    row_2_io_blocks_out;
  wire                row_2_io_full;
  wire                shift_ctrl_2_1_io_full_out;
  wire                shift_ctrl_2_1_io_holes_out;
  wire                shift_ctrl_2_1_io_shift_en;
  wire                shift_ctrl_2_1_io_clear_en;
  wire       [9:0]    row_3_io_blocks_out;
  wire                row_3_io_full;
  wire                shift_ctrl_3_1_io_full_out;
  wire                shift_ctrl_3_1_io_holes_out;
  wire                shift_ctrl_3_1_io_shift_en;
  wire                shift_ctrl_3_1_io_clear_en;
  wire       [9:0]    row_4_io_blocks_out;
  wire                row_4_io_full;
  wire                shift_ctrl_4_1_io_full_out;
  wire                shift_ctrl_4_1_io_holes_out;
  wire                shift_ctrl_4_1_io_shift_en;
  wire                shift_ctrl_4_1_io_clear_en;
  wire       [9:0]    row_5_io_blocks_out;
  wire                row_5_io_full;
  wire                shift_ctrl_5_1_io_full_out;
  wire                shift_ctrl_5_1_io_holes_out;
  wire                shift_ctrl_5_1_io_shift_en;
  wire                shift_ctrl_5_1_io_clear_en;
  wire       [9:0]    row_6_io_blocks_out;
  wire                row_6_io_full;
  wire                shift_ctrl_6_1_io_full_out;
  wire                shift_ctrl_6_1_io_holes_out;
  wire                shift_ctrl_6_1_io_shift_en;
  wire                shift_ctrl_6_1_io_clear_en;
  wire       [9:0]    row_7_io_blocks_out;
  wire                row_7_io_full;
  wire                shift_ctrl_7_1_io_full_out;
  wire                shift_ctrl_7_1_io_holes_out;
  wire                shift_ctrl_7_1_io_shift_en;
  wire                shift_ctrl_7_1_io_clear_en;
  wire       [9:0]    row_8_io_blocks_out;
  wire                row_8_io_full;
  wire                shift_ctrl_8_1_io_full_out;
  wire                shift_ctrl_8_1_io_holes_out;
  wire                shift_ctrl_8_1_io_shift_en;
  wire                shift_ctrl_8_1_io_clear_en;
  wire       [9:0]    row_9_io_blocks_out;
  wire                row_9_io_full;
  wire                shift_ctrl_9_1_io_full_out;
  wire                shift_ctrl_9_1_io_holes_out;
  wire                shift_ctrl_9_1_io_shift_en;
  wire                shift_ctrl_9_1_io_clear_en;
  wire       [9:0]    row_10_io_blocks_out;
  wire                row_10_io_full;
  wire                shift_ctrl_10_1_io_full_out;
  wire                shift_ctrl_10_1_io_holes_out;
  wire                shift_ctrl_10_1_io_shift_en;
  wire                shift_ctrl_10_1_io_clear_en;
  wire       [9:0]    row_11_io_blocks_out;
  wire                row_11_io_full;
  wire                shift_ctrl_11_1_io_full_out;
  wire                shift_ctrl_11_1_io_holes_out;
  wire                shift_ctrl_11_1_io_shift_en;
  wire                shift_ctrl_11_1_io_clear_en;
  wire       [9:0]    row_12_io_blocks_out;
  wire                row_12_io_full;
  wire                shift_ctrl_12_1_io_full_out;
  wire                shift_ctrl_12_1_io_holes_out;
  wire                shift_ctrl_12_1_io_shift_en;
  wire                shift_ctrl_12_1_io_clear_en;
  wire       [9:0]    row_13_io_blocks_out;
  wire                row_13_io_full;
  wire                shift_ctrl_13_1_io_full_out;
  wire                shift_ctrl_13_1_io_holes_out;
  wire                shift_ctrl_13_1_io_shift_en;
  wire                shift_ctrl_13_1_io_clear_en;
  wire       [9:0]    row_14_io_blocks_out;
  wire                row_14_io_full;
  wire                shift_ctrl_14_1_io_full_out;
  wire                shift_ctrl_14_1_io_holes_out;
  wire                shift_ctrl_14_1_io_shift_en;
  wire                shift_ctrl_14_1_io_clear_en;
  wire       [9:0]    row_15_io_blocks_out;
  wire                row_15_io_full;
  wire                shift_ctrl_15_1_io_full_out;
  wire                shift_ctrl_15_1_io_holes_out;
  wire                shift_ctrl_15_1_io_shift_en;
  wire                shift_ctrl_15_1_io_clear_en;
  wire       [9:0]    row_16_io_blocks_out;
  wire                row_16_io_full;
  wire                shift_ctrl_16_1_io_full_out;
  wire                shift_ctrl_16_1_io_holes_out;
  wire                shift_ctrl_16_1_io_shift_en;
  wire                shift_ctrl_16_1_io_clear_en;
  wire       [9:0]    row_17_io_blocks_out;
  wire                row_17_io_full;
  wire                shift_ctrl_17_1_io_full_out;
  wire                shift_ctrl_17_1_io_holes_out;
  wire                shift_ctrl_17_1_io_shift_en;
  wire                shift_ctrl_17_1_io_clear_en;
  wire       [9:0]    row_18_io_blocks_out;
  wire                row_18_io_full;
  wire                shift_ctrl_18_1_io_full_out;
  wire                shift_ctrl_18_1_io_holes_out;
  wire                shift_ctrl_18_1_io_shift_en;
  wire                shift_ctrl_18_1_io_clear_en;
  wire       [9:0]    row_19_io_blocks_out;
  wire                row_19_io_full;
  wire                shift_ctrl_19_1_io_full_out;
  wire                shift_ctrl_19_1_io_holes_out;
  wire                shift_ctrl_19_1_io_shift_en;
  wire                shift_ctrl_19_1_io_clear_en;
  wire       [9:0]    row_20_io_blocks_out;
  wire                row_20_io_full;
  wire                shift_ctrl_20_1_io_full_out;
  wire                shift_ctrl_20_1_io_holes_out;
  wire                shift_ctrl_20_1_io_shift_en;
  wire                shift_ctrl_20_1_io_clear_en;
  wire       [9:0]    row_21_io_blocks_out;
  wire                row_21_io_full;
  wire                shift_ctrl_21_1_io_full_out;
  wire                shift_ctrl_21_1_io_holes_out;
  wire                shift_ctrl_21_1_io_shift_en;
  wire                shift_ctrl_21_1_io_clear_en;
  wire       [4:0]    temp_lines_cleared_payload_8;
  wire       [4:0]    temp_lines_cleared_payload_9;
  reg        [4:0]    temp_lines_cleared_payload_10;
  wire       [2:0]    temp_lines_cleared_payload_11;
  reg        [4:0]    temp_lines_cleared_payload_12;
  wire       [2:0]    temp_lines_cleared_payload_13;
  wire       [4:0]    temp_lines_cleared_payload_14;
  reg        [4:0]    temp_lines_cleared_payload_15;
  wire       [2:0]    temp_lines_cleared_payload_16;
  reg        [4:0]    temp_lines_cleared_payload_17;
  wire       [2:0]    temp_lines_cleared_payload_18;
  wire       [4:0]    temp_lines_cleared_payload_19;
  wire       [4:0]    temp_lines_cleared_payload_20;
  reg        [4:0]    temp_lines_cleared_payload_21;
  wire       [2:0]    temp_lines_cleared_payload_22;
  reg        [4:0]    temp_lines_cleared_payload_23;
  wire       [2:0]    temp_lines_cleared_payload_24;
  wire       [4:0]    temp_lines_cleared_payload_25;
  reg        [4:0]    temp_lines_cleared_payload_26;
  wire       [2:0]    temp_lines_cleared_payload_27;
  reg        [4:0]    temp_lines_cleared_payload_28;
  wire       [2:0]    temp_lines_cleared_payload_29;
  wire       [0:0]    temp_lines_cleared_payload_30;
  wire       [9:0]    temp_row_status;
  reg                 enable_rows;
  reg                 lock;
  reg                 clear;
  reg                 shift;
  wire                shift_done;
  reg        [21:0]   rows_full;
  wire       [4:0]    temp_lines_cleared_payload;
  wire       [4:0]    temp_lines_cleared_payload_1;
  wire       [4:0]    temp_lines_cleared_payload_2;
  wire       [4:0]    temp_lines_cleared_payload_3;
  wire       [4:0]    temp_lines_cleared_payload_4;
  wire       [4:0]    temp_lines_cleared_payload_5;
  wire       [4:0]    temp_lines_cleared_payload_6;
  wire       [4:0]    temp_lines_cleared_payload_7;
  wire       [9:0]    rowsblocks_0;
  wire       [9:0]    rowsblocks_1;
  wire       [9:0]    rowsblocks_2;
  wire       [9:0]    rowsblocks_3;
  wire       [9:0]    rowsblocks_4;
  wire       [9:0]    rowsblocks_5;
  wire       [9:0]    rowsblocks_6;
  wire       [9:0]    rowsblocks_7;
  wire       [9:0]    rowsblocks_8;
  wire       [9:0]    rowsblocks_9;
  wire       [9:0]    rowsblocks_10;
  wire       [9:0]    rowsblocks_11;
  wire       [9:0]    rowsblocks_12;
  wire       [9:0]    rowsblocks_13;
  wire       [9:0]    rowsblocks_14;
  wire       [9:0]    rowsblocks_15;
  wire       [9:0]    rowsblocks_16;
  wire       [9:0]    rowsblocks_17;
  wire       [9:0]    rowsblocks_18;
  wire       [9:0]    rowsblocks_19;
  wire       [9:0]    rowsblocks_20;
  wire       [9:0]    rowsblocks_21;
  reg        [9:0]    cols_select;
  reg        [21:0]   rows_select;
  reg                 fetch_runing;
  wire                clear_fsm_wantExit;
  reg                 clear_fsm_wantStart;
  wire                clear_fsm_wantKill;
  reg                 update_en;
  reg                 temp_shift_done;
  reg                 block_pos_valid_regNext;
  wire       [9:0]    row_status;
  reg                 fetch_runing_regNext;
  reg        [9:0]    row_status_regNext;
  reg        [2:0]    clear_fsm_stateReg;
  reg        [2:0]    clear_fsm_stateNext;
  wire                clear_fsm_onExit_IDLE;
  wire                clear_fsm_onExit_ENABLE_ROWS;
  wire                clear_fsm_onExit_ROWS_FULL_READY;
  wire                clear_fsm_onExit_LOCK;
  wire                clear_fsm_onExit_CHECK;
  wire                clear_fsm_onExit_CLEAR;
  wire                clear_fsm_onExit_SHIFT;
  wire                clear_fsm_onEntry_IDLE;
  wire                clear_fsm_onEntry_ENABLE_ROWS;
  wire                clear_fsm_onEntry_ROWS_FULL_READY;
  wire                clear_fsm_onEntry_LOCK;
  wire                clear_fsm_onEntry_CHECK;
  wire                clear_fsm_onEntry_CLEAR;
  wire                clear_fsm_onEntry_SHIFT;
  `ifndef SYNTHESIS
  reg [119:0] clear_fsm_stateReg_string;
  reg [119:0] clear_fsm_stateNext_string;
  `endif


  assign temp_lines_cleared_payload_8 = (temp_lines_cleared_payload_9 + temp_lines_cleared_payload_14);
  assign temp_lines_cleared_payload_9 = (temp_lines_cleared_payload_10 + temp_lines_cleared_payload_12);
  assign temp_lines_cleared_payload_14 = (temp_lines_cleared_payload_15 + temp_lines_cleared_payload_17);
  assign temp_lines_cleared_payload_19 = (temp_lines_cleared_payload_20 + temp_lines_cleared_payload_25);
  assign temp_lines_cleared_payload_20 = (temp_lines_cleared_payload_21 + temp_lines_cleared_payload_23);
  assign temp_lines_cleared_payload_25 = (temp_lines_cleared_payload_26 + temp_lines_cleared_payload_28);
  assign temp_lines_cleared_payload_30 = rows_full[21];
  assign temp_lines_cleared_payload_29 = {2'd0, temp_lines_cleared_payload_30};
  assign temp_lines_cleared_payload_11 = {rows_full[2],{rows_full[1],rows_full[0]}};
  assign temp_lines_cleared_payload_13 = {rows_full[5],{rows_full[4],rows_full[3]}};
  assign temp_lines_cleared_payload_16 = {rows_full[8],{rows_full[7],rows_full[6]}};
  assign temp_lines_cleared_payload_18 = {rows_full[11],{rows_full[10],rows_full[9]}};
  assign temp_lines_cleared_payload_22 = {rows_full[14],{rows_full[13],rows_full[12]}};
  assign temp_lines_cleared_payload_24 = {rows_full[17],{rows_full[16],rows_full[15]}};
  assign temp_lines_cleared_payload_27 = {rows_full[20],{rows_full[19],rows_full[18]}};
  assign temp_row_status = ((((((10'h0 | rowsblocks_0) | rowsblocks_1) | rowsblocks_2) | rowsblocks_3) | rowsblocks_4) | rowsblocks_5);
  row_blocks row_0 (
    .io_row        (row_0_io_row            ), //i
    .io_cols       (cols_select[9:0]        ), //i
    .io_block_pos  (10'h0                   ), //i
    .io_shift      (shift_ctrl_0_io_shift_en), //i
    .io_update     (update_en               ), //i
    .io_block_set  (block_set               ), //i
    .io_clear      (shift_ctrl_0_io_clear_en), //i
    .io_blocks_out (row_0_io_blocks_out[9:0]), //o
    .io_full       (row_0_io_full           ), //o
    .clk           (clk                     ), //i
    .reset         (reset                   )  //i
  );
  shift_ctrl shift_ctrl_0 (
    .io_full_in     (1'b0                       ), //i
    .io_full_out    (shift_ctrl_0_io_full_out   ), //o
    .io_full_locked (shift_ctrl_0_io_full_locked), //i
    .io_lock        (lock                       ), //i
    .io_restart     (restart                    ), //i
    .io_shift       (shift                      ), //i
    .io_clear       (clear                      ), //i
    .io_holes_in    (shift_ctrl_1_1_io_holes_out), //i
    .io_holes_out   (shift_ctrl_0_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_0_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_0_io_clear_en   ), //o
    .clk            (clk                        ), //i
    .reset          (reset                      )  //i
  );
  row_blocks row_1 (
    .io_row        (row_1_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_0[9:0]         ), //i
    .io_shift      (shift_ctrl_1_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_1_1_io_clear_en), //i
    .io_blocks_out (row_1_io_blocks_out[9:0]  ), //o
    .io_full       (row_1_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_1_1 (
    .io_full_in     (shift_ctrl_0_io_full_out     ), //i
    .io_full_out    (shift_ctrl_1_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_1_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_2_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_1_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_1_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_1_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_2 (
    .io_row        (row_2_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_1[9:0]         ), //i
    .io_shift      (shift_ctrl_2_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_2_1_io_clear_en), //i
    .io_blocks_out (row_2_io_blocks_out[9:0]  ), //o
    .io_full       (row_2_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_2_1 (
    .io_full_in     (shift_ctrl_1_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_2_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_2_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_3_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_2_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_2_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_2_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_3 (
    .io_row        (row_3_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_2[9:0]         ), //i
    .io_shift      (shift_ctrl_3_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_3_1_io_clear_en), //i
    .io_blocks_out (row_3_io_blocks_out[9:0]  ), //o
    .io_full       (row_3_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_3_1 (
    .io_full_in     (shift_ctrl_2_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_3_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_3_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_4_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_3_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_3_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_3_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_4 (
    .io_row        (row_4_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_3[9:0]         ), //i
    .io_shift      (shift_ctrl_4_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_4_1_io_clear_en), //i
    .io_blocks_out (row_4_io_blocks_out[9:0]  ), //o
    .io_full       (row_4_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_4_1 (
    .io_full_in     (shift_ctrl_3_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_4_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_4_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_5_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_4_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_4_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_4_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_5 (
    .io_row        (row_5_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_4[9:0]         ), //i
    .io_shift      (shift_ctrl_5_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_5_1_io_clear_en), //i
    .io_blocks_out (row_5_io_blocks_out[9:0]  ), //o
    .io_full       (row_5_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_5_1 (
    .io_full_in     (shift_ctrl_4_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_5_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_5_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_6_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_5_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_5_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_5_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_6 (
    .io_row        (row_6_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_5[9:0]         ), //i
    .io_shift      (shift_ctrl_6_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_6_1_io_clear_en), //i
    .io_blocks_out (row_6_io_blocks_out[9:0]  ), //o
    .io_full       (row_6_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_6_1 (
    .io_full_in     (shift_ctrl_5_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_6_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_6_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_7_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_6_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_6_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_6_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_7 (
    .io_row        (row_7_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_6[9:0]         ), //i
    .io_shift      (shift_ctrl_7_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_7_1_io_clear_en), //i
    .io_blocks_out (row_7_io_blocks_out[9:0]  ), //o
    .io_full       (row_7_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_7_1 (
    .io_full_in     (shift_ctrl_6_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_7_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_7_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_8_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_7_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_7_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_7_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_8 (
    .io_row        (row_8_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_7[9:0]         ), //i
    .io_shift      (shift_ctrl_8_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_8_1_io_clear_en), //i
    .io_blocks_out (row_8_io_blocks_out[9:0]  ), //o
    .io_full       (row_8_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_8_1 (
    .io_full_in     (shift_ctrl_7_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_8_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_8_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_9_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_8_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_8_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_8_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_9 (
    .io_row        (row_9_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_8[9:0]         ), //i
    .io_shift      (shift_ctrl_9_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_9_1_io_clear_en), //i
    .io_blocks_out (row_9_io_blocks_out[9:0]  ), //o
    .io_full       (row_9_io_full             ), //o
    .clk           (clk                       ), //i
    .reset         (reset                     )  //i
  );
  shift_ctrl shift_ctrl_9_1 (
    .io_full_in     (shift_ctrl_8_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_9_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_9_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_10_1_io_holes_out ), //i
    .io_holes_out   (shift_ctrl_9_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_9_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_9_1_io_clear_en   ), //o
    .clk            (clk                          ), //i
    .reset          (reset                        )  //i
  );
  row_blocks row_10 (
    .io_row        (row_10_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_9[9:0]          ), //i
    .io_shift      (shift_ctrl_10_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_10_1_io_clear_en), //i
    .io_blocks_out (row_10_io_blocks_out[9:0]  ), //o
    .io_full       (row_10_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_10_1 (
    .io_full_in     (shift_ctrl_9_1_io_full_out    ), //i
    .io_full_out    (shift_ctrl_10_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_10_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_11_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_10_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_10_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_10_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_11 (
    .io_row        (row_11_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_10[9:0]         ), //i
    .io_shift      (shift_ctrl_11_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_11_1_io_clear_en), //i
    .io_blocks_out (row_11_io_blocks_out[9:0]  ), //o
    .io_full       (row_11_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_11_1 (
    .io_full_in     (shift_ctrl_10_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_11_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_11_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_12_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_11_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_11_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_11_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_12 (
    .io_row        (row_12_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_11[9:0]         ), //i
    .io_shift      (shift_ctrl_12_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_12_1_io_clear_en), //i
    .io_blocks_out (row_12_io_blocks_out[9:0]  ), //o
    .io_full       (row_12_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_12_1 (
    .io_full_in     (shift_ctrl_11_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_12_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_12_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_13_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_12_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_12_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_12_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_13 (
    .io_row        (row_13_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_12[9:0]         ), //i
    .io_shift      (shift_ctrl_13_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_13_1_io_clear_en), //i
    .io_blocks_out (row_13_io_blocks_out[9:0]  ), //o
    .io_full       (row_13_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_13_1 (
    .io_full_in     (shift_ctrl_12_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_13_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_13_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_14_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_13_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_13_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_13_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_14 (
    .io_row        (row_14_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_13[9:0]         ), //i
    .io_shift      (shift_ctrl_14_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_14_1_io_clear_en), //i
    .io_blocks_out (row_14_io_blocks_out[9:0]  ), //o
    .io_full       (row_14_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_14_1 (
    .io_full_in     (shift_ctrl_13_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_14_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_14_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_15_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_14_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_14_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_14_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_15 (
    .io_row        (row_15_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_14[9:0]         ), //i
    .io_shift      (shift_ctrl_15_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_15_1_io_clear_en), //i
    .io_blocks_out (row_15_io_blocks_out[9:0]  ), //o
    .io_full       (row_15_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_15_1 (
    .io_full_in     (shift_ctrl_14_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_15_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_15_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_16_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_15_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_15_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_15_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_16 (
    .io_row        (row_16_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_15[9:0]         ), //i
    .io_shift      (shift_ctrl_16_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_16_1_io_clear_en), //i
    .io_blocks_out (row_16_io_blocks_out[9:0]  ), //o
    .io_full       (row_16_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_16_1 (
    .io_full_in     (shift_ctrl_15_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_16_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_16_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_17_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_16_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_16_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_16_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_17 (
    .io_row        (row_17_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_16[9:0]         ), //i
    .io_shift      (shift_ctrl_17_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_17_1_io_clear_en), //i
    .io_blocks_out (row_17_io_blocks_out[9:0]  ), //o
    .io_full       (row_17_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_17_1 (
    .io_full_in     (shift_ctrl_16_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_17_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_17_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_18_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_17_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_17_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_17_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_18 (
    .io_row        (row_18_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_17[9:0]         ), //i
    .io_shift      (shift_ctrl_18_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_18_1_io_clear_en), //i
    .io_blocks_out (row_18_io_blocks_out[9:0]  ), //o
    .io_full       (row_18_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_18_1 (
    .io_full_in     (shift_ctrl_17_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_18_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_18_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_19_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_18_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_18_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_18_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_19 (
    .io_row        (row_19_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_18[9:0]         ), //i
    .io_shift      (shift_ctrl_19_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_19_1_io_clear_en), //i
    .io_blocks_out (row_19_io_blocks_out[9:0]  ), //o
    .io_full       (row_19_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_19_1 (
    .io_full_in     (shift_ctrl_18_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_19_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_19_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_20_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_19_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_19_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_19_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_20 (
    .io_row        (row_20_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_19[9:0]         ), //i
    .io_shift      (shift_ctrl_20_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_20_1_io_clear_en), //i
    .io_blocks_out (row_20_io_blocks_out[9:0]  ), //o
    .io_full       (row_20_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_20_1 (
    .io_full_in     (shift_ctrl_19_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_20_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_20_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_21_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_20_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_20_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_20_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  row_blocks row_21 (
    .io_row        (row_21_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_20[9:0]         ), //i
    .io_shift      (shift_ctrl_21_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_21_1_io_clear_en), //i
    .io_blocks_out (row_21_io_blocks_out[9:0]  ), //o
    .io_full       (row_21_io_full             ), //o
    .clk           (clk                        ), //i
    .reset         (reset                      )  //i
  );
  shift_ctrl shift_ctrl_21_1 (
    .io_full_in     (shift_ctrl_20_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_21_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_21_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (1'b0                          ), //i
    .io_holes_out   (shift_ctrl_21_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_21_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_21_1_io_clear_en   ), //o
    .clk            (clk                           ), //i
    .reset          (reset                         )  //i
  );
  always @(*) begin
    case(temp_lines_cleared_payload_11)
      3'b000 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_13)
      3'b000 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_16)
      3'b000 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_18)
      3'b000 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_22)
      3'b000 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_24)
      3'b000 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_27)
      3'b000 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_29)
      3'b000 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_7;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(clear_fsm_stateReg)
      IDLE : clear_fsm_stateReg_string = "IDLE           ";
      ENABLE_ROWS : clear_fsm_stateReg_string = "ENABLE_ROWS    ";
      ROWS_FULL_READY : clear_fsm_stateReg_string = "ROWS_FULL_READY";
      LOCK : clear_fsm_stateReg_string = "LOCK           ";
      CHECK : clear_fsm_stateReg_string = "CHECK          ";
      CLEAR : clear_fsm_stateReg_string = "CLEAR          ";
      SHIFT : clear_fsm_stateReg_string = "SHIFT          ";
      default : clear_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(clear_fsm_stateNext)
      IDLE : clear_fsm_stateNext_string = "IDLE           ";
      ENABLE_ROWS : clear_fsm_stateNext_string = "ENABLE_ROWS    ";
      ROWS_FULL_READY : clear_fsm_stateNext_string = "ROWS_FULL_READY";
      LOCK : clear_fsm_stateNext_string = "LOCK           ";
      CHECK : clear_fsm_stateNext_string = "CHECK          ";
      CLEAR : clear_fsm_stateNext_string = "CLEAR          ";
      SHIFT : clear_fsm_stateNext_string = "SHIFT          ";
      default : clear_fsm_stateNext_string = "???????????????";
    endcase
  end
  `endif

  assign temp_lines_cleared_payload = 5'h0;
  assign temp_lines_cleared_payload_1 = 5'h01;
  assign temp_lines_cleared_payload_2 = 5'h01;
  assign temp_lines_cleared_payload_3 = 5'h02;
  assign temp_lines_cleared_payload_4 = 5'h01;
  assign temp_lines_cleared_payload_5 = 5'h02;
  assign temp_lines_cleared_payload_6 = 5'h02;
  assign temp_lines_cleared_payload_7 = 5'h03;
  assign clear_fsm_wantExit = 1'b0;
  always @(*) begin
    clear_fsm_wantStart = 1'b0;
    enable_rows = 1'b0;
    lock = 1'b0;
    clear = 1'b0;
    shift = 1'b0;
    clear_done = 1'b0;
    clear_fsm_stateNext = clear_fsm_stateReg;
    case(clear_fsm_stateReg)
      ENABLE_ROWS : begin
        enable_rows = 1'b1;
        clear_fsm_stateNext = ROWS_FULL_READY;
      end
      ROWS_FULL_READY : begin
        clear_fsm_stateNext = LOCK;
      end
      LOCK : begin
        lock = 1'b1;
        clear_fsm_stateNext = CHECK;
      end
      CHECK : begin
        if(shift_ctrl_0_io_holes_out) begin
          clear_fsm_stateNext = CLEAR;
        end else begin
          clear_done = 1'b1;
          clear_fsm_stateNext = IDLE;
        end
      end
      CLEAR : begin
        clear = 1'b1;
        clear_fsm_stateNext = SHIFT;
      end
      SHIFT : begin
        shift = 1'b1;
        if(shift_done) begin
          clear_fsm_stateNext = ENABLE_ROWS;
        end
      end
      default : begin
        if(clear_start) begin
          clear_fsm_stateNext = ENABLE_ROWS;
        end
        clear_fsm_wantStart = 1'b1;
      end
    endcase
    if(clear_fsm_wantKill) begin
      clear_fsm_stateNext = IDLE;
    end
  end

  assign clear_fsm_wantKill = 1'b0;
  assign shift_ctrl_0_io_full_locked = rows_full[0];
  assign row_0_io_row = rows_select[0];
  assign rowsblocks_0 = row_0_io_blocks_out;
  assign shift_ctrl_1_1_io_full_locked = rows_full[1];
  assign row_1_io_row = rows_select[1];
  assign rowsblocks_1 = row_1_io_blocks_out;
  assign shift_ctrl_2_1_io_full_locked = rows_full[2];
  assign row_2_io_row = rows_select[2];
  assign rowsblocks_2 = row_2_io_blocks_out;
  assign shift_ctrl_3_1_io_full_locked = rows_full[3];
  assign row_3_io_row = rows_select[3];
  assign rowsblocks_3 = row_3_io_blocks_out;
  assign shift_ctrl_4_1_io_full_locked = rows_full[4];
  assign row_4_io_row = rows_select[4];
  assign rowsblocks_4 = row_4_io_blocks_out;
  assign shift_ctrl_5_1_io_full_locked = rows_full[5];
  assign row_5_io_row = rows_select[5];
  assign rowsblocks_5 = row_5_io_blocks_out;
  assign shift_ctrl_6_1_io_full_locked = rows_full[6];
  assign row_6_io_row = rows_select[6];
  assign rowsblocks_6 = row_6_io_blocks_out;
  assign shift_ctrl_7_1_io_full_locked = rows_full[7];
  assign row_7_io_row = rows_select[7];
  assign rowsblocks_7 = row_7_io_blocks_out;
  assign shift_ctrl_8_1_io_full_locked = rows_full[8];
  assign row_8_io_row = rows_select[8];
  assign rowsblocks_8 = row_8_io_blocks_out;
  assign shift_ctrl_9_1_io_full_locked = rows_full[9];
  assign row_9_io_row = rows_select[9];
  assign rowsblocks_9 = row_9_io_blocks_out;
  assign shift_ctrl_10_1_io_full_locked = rows_full[10];
  assign row_10_io_row = rows_select[10];
  assign rowsblocks_10 = row_10_io_blocks_out;
  assign shift_ctrl_11_1_io_full_locked = rows_full[11];
  assign row_11_io_row = rows_select[11];
  assign rowsblocks_11 = row_11_io_blocks_out;
  assign shift_ctrl_12_1_io_full_locked = rows_full[12];
  assign row_12_io_row = rows_select[12];
  assign rowsblocks_12 = row_12_io_blocks_out;
  assign shift_ctrl_13_1_io_full_locked = rows_full[13];
  assign row_13_io_row = rows_select[13];
  assign rowsblocks_13 = row_13_io_blocks_out;
  assign shift_ctrl_14_1_io_full_locked = rows_full[14];
  assign row_14_io_row = rows_select[14];
  assign rowsblocks_14 = row_14_io_blocks_out;
  assign shift_ctrl_15_1_io_full_locked = rows_full[15];
  assign row_15_io_row = rows_select[15];
  assign rowsblocks_15 = row_15_io_blocks_out;
  assign shift_ctrl_16_1_io_full_locked = rows_full[16];
  assign row_16_io_row = rows_select[16];
  assign rowsblocks_16 = row_16_io_blocks_out;
  assign shift_ctrl_17_1_io_full_locked = rows_full[17];
  assign row_17_io_row = rows_select[17];
  assign rowsblocks_17 = row_17_io_blocks_out;
  assign shift_ctrl_18_1_io_full_locked = rows_full[18];
  assign row_18_io_row = rows_select[18];
  assign rowsblocks_18 = row_18_io_blocks_out;
  assign shift_ctrl_19_1_io_full_locked = rows_full[19];
  assign row_19_io_row = rows_select[19];
  assign rowsblocks_19 = row_19_io_blocks_out;
  assign shift_ctrl_20_1_io_full_locked = rows_full[20];
  assign row_20_io_row = rows_select[20];
  assign rowsblocks_20 = row_20_io_blocks_out;
  assign shift_ctrl_21_1_io_full_locked = rows_full[21];
  assign row_21_io_row = rows_select[21];
  assign rowsblocks_21 = row_21_io_blocks_out;
  assign shift_done = temp_shift_done;
  assign block_val_valid = block_pos_valid_regNext;
  assign row_status = ((((((((((((((((temp_row_status | rowsblocks_6) | rowsblocks_7) | rowsblocks_8) | rowsblocks_9) | rowsblocks_10) | rowsblocks_11) | rowsblocks_12) | rowsblocks_13) | rowsblocks_14) | rowsblocks_15) | rowsblocks_16) | rowsblocks_17) | rowsblocks_18) | rowsblocks_19) | rowsblocks_20) | rowsblocks_21);
  assign block_val_payload = (|(row_status & cols_select));
  assign row_val_valid = fetch_runing_regNext;
  assign row_val_payload = row_status_regNext;
  assign clear_fsm_onExit_IDLE = ((clear_fsm_stateNext != IDLE) && (clear_fsm_stateReg == IDLE));
  assign clear_fsm_onExit_ENABLE_ROWS = ((clear_fsm_stateNext != ENABLE_ROWS) && (clear_fsm_stateReg == ENABLE_ROWS));
  assign clear_fsm_onExit_ROWS_FULL_READY = ((clear_fsm_stateNext != ROWS_FULL_READY) && (clear_fsm_stateReg == ROWS_FULL_READY));
  assign clear_fsm_onExit_LOCK = ((clear_fsm_stateNext != LOCK) && (clear_fsm_stateReg == LOCK));
  assign clear_fsm_onExit_CHECK = ((clear_fsm_stateNext != CHECK) && (clear_fsm_stateReg == CHECK));
  assign clear_fsm_onExit_CLEAR = ((clear_fsm_stateNext != CLEAR) && (clear_fsm_stateReg == CLEAR));
  assign clear_fsm_onExit_SHIFT = ((clear_fsm_stateNext != SHIFT) && (clear_fsm_stateReg == SHIFT));
  assign clear_fsm_onEntry_IDLE = ((clear_fsm_stateNext == IDLE) && (clear_fsm_stateReg != IDLE));
  assign clear_fsm_onEntry_ENABLE_ROWS = ((clear_fsm_stateNext == ENABLE_ROWS) && (clear_fsm_stateReg != ENABLE_ROWS));
  assign clear_fsm_onEntry_ROWS_FULL_READY = ((clear_fsm_stateNext == ROWS_FULL_READY) && (clear_fsm_stateReg != ROWS_FULL_READY));
  assign clear_fsm_onEntry_LOCK = ((clear_fsm_stateNext == LOCK) && (clear_fsm_stateReg != LOCK));
  assign clear_fsm_onEntry_CHECK = ((clear_fsm_stateNext == CHECK) && (clear_fsm_stateReg != CHECK));
  assign clear_fsm_onEntry_CLEAR = ((clear_fsm_stateNext == CLEAR) && (clear_fsm_stateReg != CLEAR));
  assign clear_fsm_onEntry_SHIFT = ((clear_fsm_stateNext == SHIFT) && (clear_fsm_stateReg != SHIFT));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      rows_full <= 22'h0;
      lines_cleared_valid <= 1'b0;
      cols_select <= 10'h0;
      rows_select <= 22'h0;
      fetch_runing <= 1'b0;
      temp_shift_done <= 1'b0;
      block_pos_valid_regNext <= 1'b0;
      fetch_runing_regNext <= 1'b0;
      clear_fsm_stateReg <= IDLE;
    end else begin
      if(block_pos_valid) begin
        case(block_pos_payload_x)
          4'b0001 : begin
            cols_select <= 10'h001;
          end
          4'b0010 : begin
            cols_select <= 10'h002;
          end
          4'b0011 : begin
            cols_select <= 10'h004;
          end
          4'b0100 : begin
            cols_select <= 10'h008;
          end
          4'b0101 : begin
            cols_select <= 10'h010;
          end
          4'b0110 : begin
            cols_select <= 10'h020;
          end
          4'b0111 : begin
            cols_select <= 10'h040;
          end
          4'b1000 : begin
            cols_select <= 10'h080;
          end
          4'b1001 : begin
            cols_select <= 10'h100;
          end
          4'b1010 : begin
            cols_select <= 10'h200;
          end
          default : begin
            cols_select <= 10'bxxxxxxxxxx;
          end
        endcase
      end
      if(enable_rows) begin
        rows_select <= 22'h3fffff;
      end
      if(block_pos_valid) begin
        case(block_pos_payload_y)
          5'h0 : begin
            rows_select <= 22'h000001;
          end
          5'h01 : begin
            rows_select <= 22'h000002;
          end
          5'h02 : begin
            rows_select <= 22'h000004;
          end
          5'h03 : begin
            rows_select <= 22'h000008;
          end
          5'h04 : begin
            rows_select <= 22'h000010;
          end
          5'h05 : begin
            rows_select <= 22'h000020;
          end
          5'h06 : begin
            rows_select <= 22'h000040;
          end
          5'h07 : begin
            rows_select <= 22'h000080;
          end
          5'h08 : begin
            rows_select <= 22'h000100;
          end
          5'h09 : begin
            rows_select <= 22'h000200;
          end
          5'h0a : begin
            rows_select <= 22'h000400;
          end
          5'h0b : begin
            rows_select <= 22'h000800;
          end
          5'h0c : begin
            rows_select <= 22'h001000;
          end
          5'h0d : begin
            rows_select <= 22'h002000;
          end
          5'h0e : begin
            rows_select <= 22'h004000;
          end
          5'h0f : begin
            rows_select <= 22'h008000;
          end
          5'h10 : begin
            rows_select <= 22'h010000;
          end
          5'h11 : begin
            rows_select <= 22'h020000;
          end
          5'h12 : begin
            rows_select <= 22'h040000;
          end
          5'h13 : begin
            rows_select <= 22'h080000;
          end
          5'h14 : begin
            rows_select <= 22'h100000;
          end
          5'h15 : begin
            rows_select <= 22'h200000;
          end
          default : begin
            rows_select <= 22'bxxxxxxxxxxxxxxxxxxxxxx;
          end
        endcase
      end
      if(fetch) begin
        fetch_runing <= 1'b1;
        rows_select <= 22'h0;
        rows_select[0] <= 1'b1;
      end else begin
        if(rows_select[21]) begin
          fetch_runing <= 1'b0;
        end
      end
      if(fetch_runing) begin
        rows_select <= (rows_select <<< 1);
      end
      lines_cleared_valid <= 1'b0;
      rows_full[0] <= row_0_io_full;
      rows_full[1] <= row_1_io_full;
      rows_full[2] <= row_2_io_full;
      rows_full[3] <= row_3_io_full;
      rows_full[4] <= row_4_io_full;
      rows_full[5] <= row_5_io_full;
      rows_full[6] <= row_6_io_full;
      rows_full[7] <= row_7_io_full;
      rows_full[8] <= row_8_io_full;
      rows_full[9] <= row_9_io_full;
      rows_full[10] <= row_10_io_full;
      rows_full[11] <= row_11_io_full;
      rows_full[12] <= row_12_io_full;
      rows_full[13] <= row_13_io_full;
      rows_full[14] <= row_14_io_full;
      rows_full[15] <= row_15_io_full;
      rows_full[16] <= row_16_io_full;
      rows_full[17] <= row_17_io_full;
      rows_full[18] <= row_18_io_full;
      rows_full[19] <= row_19_io_full;
      rows_full[20] <= row_20_io_full;
      rows_full[21] <= row_21_io_full;
      temp_shift_done <= (! shift_ctrl_0_io_holes_out);
      block_pos_valid_regNext <= block_pos_valid;
      fetch_runing_regNext <= fetch_runing;
      clear_fsm_stateReg <= clear_fsm_stateNext;
      if(clear_fsm_onExit_CHECK) begin
        if((! clear_done)) begin
          lines_cleared_valid <= 1'b1;
        end
      end
    end
  end

  always @(posedge clk) begin
    lines_cleared_payload <= (temp_lines_cleared_payload_8 + temp_lines_cleared_payload_19);
    update_en <= (block_pos_valid && update);
    row_status_regNext <= row_status;
  end


endmodule

//shift_ctrl_21 replaced by shift_ctrl

//row_blocks_21 replaced by row_blocks

//shift_ctrl_20 replaced by shift_ctrl

//row_blocks_20 replaced by row_blocks

//shift_ctrl_19 replaced by shift_ctrl

//row_blocks_19 replaced by row_blocks

//shift_ctrl_18 replaced by shift_ctrl

//row_blocks_18 replaced by row_blocks

//shift_ctrl_17 replaced by shift_ctrl

//row_blocks_17 replaced by row_blocks

//shift_ctrl_16 replaced by shift_ctrl

//row_blocks_16 replaced by row_blocks

//shift_ctrl_15 replaced by shift_ctrl

//row_blocks_15 replaced by row_blocks

//shift_ctrl_14 replaced by shift_ctrl

//row_blocks_14 replaced by row_blocks

//shift_ctrl_13 replaced by shift_ctrl

//row_blocks_13 replaced by row_blocks

//shift_ctrl_12 replaced by shift_ctrl

//row_blocks_12 replaced by row_blocks

//shift_ctrl_11 replaced by shift_ctrl

//row_blocks_11 replaced by row_blocks

//shift_ctrl_10 replaced by shift_ctrl

//row_blocks_10 replaced by row_blocks

//shift_ctrl_9 replaced by shift_ctrl

//row_blocks_9 replaced by row_blocks

//shift_ctrl_8 replaced by shift_ctrl

//row_blocks_8 replaced by row_blocks

//shift_ctrl_7 replaced by shift_ctrl

//row_blocks_7 replaced by row_blocks

//shift_ctrl_6 replaced by shift_ctrl

//row_blocks_6 replaced by row_blocks

//shift_ctrl_5 replaced by shift_ctrl

//row_blocks_5 replaced by row_blocks

//shift_ctrl_4 replaced by shift_ctrl

//row_blocks_4 replaced by row_blocks

//shift_ctrl_3 replaced by shift_ctrl

//row_blocks_3 replaced by row_blocks

//shift_ctrl_2 replaced by shift_ctrl

//row_blocks_2 replaced by row_blocks

//shift_ctrl_1 replaced by shift_ctrl

//row_blocks_1 replaced by row_blocks

module shift_ctrl (
  input  wire          io_full_in,
  output wire          io_full_out,
  input  wire          io_full_locked,
  input  wire          io_lock,
  input  wire          io_restart,
  input  wire          io_shift,
  input  wire          io_clear,
  input  wire          io_holes_in,
  output wire          io_holes_out,
  output wire          io_shift_en,
  output wire          io_clear_en,
  input  wire          clk,
  input  wire          reset
);

  reg                 full_wire;
  reg                 full_reg;

  always @(*) begin
    if(io_lock) begin
      full_wire = io_full_locked;
    end else begin
      if(io_shift_en) begin
        full_wire = io_full_in;
      end else begin
        full_wire = full_reg;
      end
    end
  end

  assign io_full_out = full_reg;
  assign io_holes_out = (io_holes_in || full_reg);
  assign io_shift_en = (io_holes_out && io_shift);
  assign io_clear_en = (io_restart || (io_clear && full_reg));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      full_reg <= 1'b0;
    end else begin
      full_reg <= full_wire;
    end
  end


endmodule

module row_blocks (
  input  wire          io_row,
  input  wire [9:0]    io_cols,
  input  wire [9:0]    io_block_pos,
  input  wire          io_shift,
  input  wire          io_update,
  input  wire          io_block_set,
  input  wire          io_clear,
  output reg  [9:0]    io_blocks_out,
  output wire          io_full,
  input  wire          clk,
  input  wire          reset
);

  wire                row_update;
  wire                temp_1;
  reg                 temp_io_blocks_out;
  wire                temp_2;
  reg                 temp_io_blocks_out_1;
  wire                temp_3;
  reg                 temp_io_blocks_out_2;
  wire                temp_4;
  reg                 temp_io_blocks_out_3;
  wire                temp_5;
  reg                 temp_io_blocks_out_4;
  wire                temp_6;
  reg                 temp_io_blocks_out_5;
  wire                temp_7;
  reg                 temp_io_blocks_out_6;
  wire                temp_8;
  reg                 temp_io_blocks_out_7;
  wire                temp_9;
  reg                 temp_io_blocks_out_8;
  wire                temp_10;
  reg                 temp_io_blocks_out_9;

  assign io_full = (&io_blocks_out);
  assign row_update = (io_update && io_row);
  assign temp_1 = (row_update && io_cols[0]);
  always @(*) begin
    io_blocks_out[0] = (io_row && temp_io_blocks_out);
    io_blocks_out[1] = (io_row && temp_io_blocks_out_1);
    io_blocks_out[2] = (io_row && temp_io_blocks_out_2);
    io_blocks_out[3] = (io_row && temp_io_blocks_out_3);
    io_blocks_out[4] = (io_row && temp_io_blocks_out_4);
    io_blocks_out[5] = (io_row && temp_io_blocks_out_5);
    io_blocks_out[6] = (io_row && temp_io_blocks_out_6);
    io_blocks_out[7] = (io_row && temp_io_blocks_out_7);
    io_blocks_out[8] = (io_row && temp_io_blocks_out_8);
    io_blocks_out[9] = (io_row && temp_io_blocks_out_9);
  end

  assign temp_2 = (row_update && io_cols[1]);
  assign temp_3 = (row_update && io_cols[2]);
  assign temp_4 = (row_update && io_cols[3]);
  assign temp_5 = (row_update && io_cols[4]);
  assign temp_6 = (row_update && io_cols[5]);
  assign temp_7 = (row_update && io_cols[6]);
  assign temp_8 = (row_update && io_cols[7]);
  assign temp_9 = (row_update && io_cols[8]);
  assign temp_10 = (row_update && io_cols[9]);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      temp_io_blocks_out <= 1'b0;
      temp_io_blocks_out_1 <= 1'b0;
      temp_io_blocks_out_2 <= 1'b0;
      temp_io_blocks_out_3 <= 1'b0;
      temp_io_blocks_out_4 <= 1'b0;
      temp_io_blocks_out_5 <= 1'b0;
      temp_io_blocks_out_6 <= 1'b0;
      temp_io_blocks_out_7 <= 1'b0;
      temp_io_blocks_out_8 <= 1'b0;
      temp_io_blocks_out_9 <= 1'b0;
    end else begin
      if(io_shift) begin
        temp_io_blocks_out <= io_block_pos[0];
      end
      if((temp_1 && io_block_set)) begin
        temp_io_blocks_out <= 1'b1;
      end
      if((io_clear || (temp_1 && (! io_block_set)))) begin
        temp_io_blocks_out <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_1 <= io_block_pos[1];
      end
      if((temp_2 && io_block_set)) begin
        temp_io_blocks_out_1 <= 1'b1;
      end
      if((io_clear || (temp_2 && (! io_block_set)))) begin
        temp_io_blocks_out_1 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_2 <= io_block_pos[2];
      end
      if((temp_3 && io_block_set)) begin
        temp_io_blocks_out_2 <= 1'b1;
      end
      if((io_clear || (temp_3 && (! io_block_set)))) begin
        temp_io_blocks_out_2 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_3 <= io_block_pos[3];
      end
      if((temp_4 && io_block_set)) begin
        temp_io_blocks_out_3 <= 1'b1;
      end
      if((io_clear || (temp_4 && (! io_block_set)))) begin
        temp_io_blocks_out_3 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_4 <= io_block_pos[4];
      end
      if((temp_5 && io_block_set)) begin
        temp_io_blocks_out_4 <= 1'b1;
      end
      if((io_clear || (temp_5 && (! io_block_set)))) begin
        temp_io_blocks_out_4 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_5 <= io_block_pos[5];
      end
      if((temp_6 && io_block_set)) begin
        temp_io_blocks_out_5 <= 1'b1;
      end
      if((io_clear || (temp_6 && (! io_block_set)))) begin
        temp_io_blocks_out_5 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_6 <= io_block_pos[6];
      end
      if((temp_7 && io_block_set)) begin
        temp_io_blocks_out_6 <= 1'b1;
      end
      if((io_clear || (temp_7 && (! io_block_set)))) begin
        temp_io_blocks_out_6 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_7 <= io_block_pos[7];
      end
      if((temp_8 && io_block_set)) begin
        temp_io_blocks_out_7 <= 1'b1;
      end
      if((io_clear || (temp_8 && (! io_block_set)))) begin
        temp_io_blocks_out_7 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_8 <= io_block_pos[8];
      end
      if((temp_9 && io_block_set)) begin
        temp_io_blocks_out_8 <= 1'b1;
      end
      if((io_clear || (temp_9 && (! io_block_set)))) begin
        temp_io_blocks_out_8 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_9 <= io_block_pos[9];
      end
      if((temp_10 && io_block_set)) begin
        temp_io_blocks_out_9 <= 1'b1;
      end
      if((io_clear || (temp_10 && (! io_block_set)))) begin
        temp_io_blocks_out_9 <= 1'b0;
      end
    end
  end


endmodule
