// Generator : SpinalHDL v1.15.0    git head : 05a01af3d3345aa0afcaad8e0186dde13a359db2
// Component : logic_top
// Git hash  : 3d467bff18f916b687d55ae2a8e3528df145783c

`timescale 1ns/1ps

module logic_top (
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  input  wire          drop,
  output wire          row_val_valid,
  output wire [9:0]    row_val_payload,
  output wire          score_val_valid,
  output wire [9:0]    score_val_payload,
  input  wire          draw_field_done,
  input  wire          screen_is_ready,
  input  wire          vga_sof,
  output wire          ctrl_allowed,
  output wire          softReset,
  output wire          game_restart,
  output wire          debug_controller_debug_place_new,
  output wire          debug_controller_controller_in_lockdown,
  output wire          debug_controller_controller_in_end,
  output wire          debug_controller_controller_in_place,
  output wire          debug_new_piece_valid,
  input  wire          clk,
  input  wire          reset
);
  localparam TYPE_1_I = 3'd0;
  localparam TYPE_1_J = 3'd1;
  localparam TYPE_1_L = 3'd2;
  localparam TYPE_1_O = 3'd3;
  localparam TYPE_1_S = 3'd4;
  localparam TYPE_1_T = 3'd5;
  localparam TYPE_1_Z = 3'd6;

  wire                playfield_inst_piece_in_valid;
  wire                piece_gen_inst_io_shape_valid;
  wire       [2:0]    piece_gen_inst_io_shape_payload;
  wire                playfield_inst_status_valid;
  wire                playfield_inst_status_payload;
  wire                playfield_inst_row_val_valid;
  wire       [9:0]    playfield_inst_row_val_payload;
  wire                playfield_inst_score_val_valid;
  wire       [9:0]    playfield_inst_score_val_payload;
  wire                playfield_inst_motion_is_allowed;
  wire                playfield_inst_fsm_is_idle;
  wire                controller_inst_game_restart;
  wire                controller_inst_softReset;
  wire                controller_inst_gen_piece_en;
  wire                controller_inst_move_out_left;
  wire                controller_inst_move_out_right;
  wire                controller_inst_move_out_rotate;
  wire                controller_inst_move_out_down;
  wire                controller_inst_lock;
  wire                controller_inst_debug_debug_place_new;
  wire                controller_inst_debug_controller_in_lockdown;
  wire                controller_inst_debug_controller_in_end;
  wire                controller_inst_debug_controller_in_place;
  reg                 status_stage_valid;
  reg                 status_stage_payload;
  wire       [3:0]    temp_piece_in_valid;
  wire       [2:0]    temp_piece_in_payload;
  `ifndef SYNTHESIS
  reg [7:0] temp_piece_in_payload_string;
  `endif


  seven_bag_rng piece_gen_inst (
    .io_enable        (controller_inst_gen_piece_en        ), //i
    .io_shape_valid   (piece_gen_inst_io_shape_valid       ), //o
    .io_shape_payload (piece_gen_inst_io_shape_payload[2:0]), //o
    .clk              (clk                                 ), //i
    .reset            (reset                               )  //i
  );
  playfield playfield_inst (
    .piece_in_valid    (playfield_inst_piece_in_valid        ), //i
    .piece_in_payload  (temp_piece_in_payload[2:0]           ), //i
    .status_valid      (playfield_inst_status_valid          ), //o
    .status_payload    (playfield_inst_status_payload        ), //o
    .move_in_left      (controller_inst_move_out_left        ), //i
    .move_in_right     (controller_inst_move_out_right       ), //i
    .move_in_rotate    (controller_inst_move_out_rotate      ), //i
    .move_in_down      (controller_inst_move_out_down        ), //i
    .lock              (controller_inst_lock                 ), //i
    .game_restart      (controller_inst_game_restart         ), //i
    .row_val_valid     (playfield_inst_row_val_valid         ), //o
    .row_val_payload   (playfield_inst_row_val_payload[9:0]  ), //o
    .score_val_valid   (playfield_inst_score_val_valid       ), //o
    .score_val_payload (playfield_inst_score_val_payload[9:0]), //o
    .motion_is_allowed (playfield_inst_motion_is_allowed     ), //o
    .fsm_is_idle       (playfield_inst_fsm_is_idle           ), //o
    .clk               (clk                                  ), //i
    .reset             (reset                                )  //i
  );
  controller controller_inst (
    .game_start                   (game_start                                  ), //i
    .move_left                    (move_left                                   ), //i
    .move_right                   (move_right                                  ), //i
    .move_down                    (move_down                                   ), //i
    .rotate                       (rotate                                      ), //i
    .drop                         (drop                                        ), //i
    .screen_is_ready              (screen_is_ready                             ), //i
    .playfield_in_idle            (playfield_inst_fsm_is_idle                  ), //i
    .playfield_allow_action       (playfield_inst_motion_is_allowed            ), //i
    .game_restart                 (controller_inst_game_restart                ), //o
    .softReset                    (controller_inst_softReset                   ), //o
    .gen_piece_en                 (controller_inst_gen_piece_en                ), //o
    .collision_status_valid       (status_stage_valid                          ), //i
    .collision_status_payload     (status_stage_payload                        ), //i
    .move_out_left                (controller_inst_move_out_left               ), //o
    .move_out_right               (controller_inst_move_out_right              ), //o
    .move_out_rotate              (controller_inst_move_out_rotate             ), //o
    .move_out_down                (controller_inst_move_out_down               ), //o
    .lock                         (controller_inst_lock                        ), //o
    .debug_debug_place_new        (controller_inst_debug_debug_place_new       ), //o
    .debug_controller_in_lockdown (controller_inst_debug_controller_in_lockdown), //o
    .debug_controller_in_end      (controller_inst_debug_controller_in_end     ), //o
    .debug_controller_in_place    (controller_inst_debug_controller_in_place   ), //o
    .clk                          (clk                                         ), //i
    .reset                        (reset                                       )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(temp_piece_in_payload)
      TYPE_1_I : temp_piece_in_payload_string = "I";
      TYPE_1_J : temp_piece_in_payload_string = "J";
      TYPE_1_L : temp_piece_in_payload_string = "L";
      TYPE_1_O : temp_piece_in_payload_string = "O";
      TYPE_1_S : temp_piece_in_payload_string = "S";
      TYPE_1_T : temp_piece_in_payload_string = "T";
      TYPE_1_Z : temp_piece_in_payload_string = "Z";
      default : temp_piece_in_payload_string = "?";
    endcase
  end
  `endif

  assign temp_piece_in_valid = {piece_gen_inst_io_shape_payload,piece_gen_inst_io_shape_valid};
  assign playfield_inst_piece_in_valid = temp_piece_in_valid[0];
  assign temp_piece_in_payload = temp_piece_in_valid[3 : 1];
  assign softReset = controller_inst_softReset;
  assign game_restart = controller_inst_game_restart;
  assign debug_controller_debug_place_new = controller_inst_debug_debug_place_new;
  assign debug_controller_controller_in_lockdown = controller_inst_debug_controller_in_lockdown;
  assign debug_controller_controller_in_end = controller_inst_debug_controller_in_end;
  assign debug_controller_controller_in_place = controller_inst_debug_controller_in_place;
  assign debug_new_piece_valid = controller_inst_gen_piece_en;
  assign row_val_valid = playfield_inst_row_val_valid;
  assign row_val_payload = playfield_inst_row_val_payload;
  assign score_val_valid = playfield_inst_score_val_valid;
  assign score_val_payload = playfield_inst_score_val_payload;
  assign ctrl_allowed = playfield_inst_motion_is_allowed;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      status_stage_valid <= 1'b0;
    end else begin
      status_stage_valid <= playfield_inst_status_valid;
    end
  end

  always @(posedge clk) begin
    status_stage_payload <= playfield_inst_status_payload;
  end


endmodule

module controller (
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  input  wire          drop,
  input  wire          screen_is_ready,
  input  wire          playfield_in_idle,
  input  wire          playfield_allow_action,
  output reg           game_restart,
  output reg           softReset,
  output reg           gen_piece_en,
  input  wire          collision_status_valid,
  input  wire          collision_status_payload,
  output reg           move_out_left,
  output reg           move_out_right,
  output reg           move_out_rotate,
  output reg           move_out_down,
  output reg           lock,
  (* keep *) output wire          debug_debug_place_new,
  output wire          debug_controller_in_lockdown,
  output wire          debug_controller_in_end,
  output wire          debug_controller_in_place,
  input  wire          clk,
  input  wire          reset
);
  localparam fsm_1_IDLE = 4'd0;
  localparam fsm_1_GAME_START = 4'd1;
  localparam fsm_1_RANDOM_GEN = 4'd2;
  localparam fsm_1_PLACE = 4'd3;
  localparam fsm_1_END_1 = 4'd4;
  localparam fsm_1_FALLING = 4'd5;
  localparam fsm_1_DOWN = 4'd6;
  localparam fsm_1_DROP = 4'd7;
  localparam fsm_1_WAIT_ALLOW_ACTION = 4'd8;
  localparam fsm_1_MOVE = 4'd9;
  localparam fsm_1_LOCK = 4'd10;
  localparam fsm_1_LOCKDOWN = 4'd11;
  localparam fsm_1_CLEAN = 4'd12;
  localparam fsm_1_WAIT_TIME = 4'd13;

  wire       [13:0]   temp_drop_timeout_counter_valueNext;
  wire       [0:0]    temp_drop_timeout_counter_valueNext_1;
  wire       [6:0]    temp_lock_timeout_counter_valueNext;
  wire       [0:0]    temp_lock_timeout_counter_valueNext_1;
  wire       [2:0]    temp_9;
  reg        [2:0]    temp_10;
  wire       [2:0]    temp_11;
  reg        [2:0]    temp_12;
  wire       [2:0]    temp_13;
  wire       [1:0]    temp_14;
  wire       [9:0]    temp_temp_motion_voted_2;
  wire       [9:0]    temp_temp_motion_voted_2_1;
  wire       [4:0]    temp_temp_motion_voted_2_2;
  wire                temp_when;
  reg                 drop_timeout_state;
  reg                 drop_timeout_stateRise;
  wire                drop_timeout_counter_willIncrement;
  wire                drop_timeout_counter_willDecrement;
  reg                 drop_timeout_counter_willClear;
  wire                drop_timeout_counter_willLoad;
  reg        [13:0]   drop_timeout_counter_valueNext;
  reg        [13:0]   drop_timeout_counter_value;
  wire                drop_timeout_counter_willOverflowIfInc;
  wire                drop_timeout_counter_willUnderflowIfDec;
  wire                drop_timeout_counter_willOverflow;
  wire                drop_timeout_counter_willUnderflow;
  reg                 lock_timeout_state;
  reg                 lock_timeout_stateRise;
  wire                lock_timeout_counter_willIncrement;
  wire                lock_timeout_counter_willDecrement;
  reg                 lock_timeout_counter_willClear;
  wire                lock_timeout_counter_willLoad;
  reg        [6:0]    lock_timeout_counter_valueNext;
  reg        [6:0]    lock_timeout_counter_value;
  wire                lock_timeout_counter_willOverflowIfInc;
  wire                lock_timeout_counter_willUnderflowIfDec;
  wire                lock_timeout_counter_willOverflow;
  wire                lock_timeout_counter_willUnderflow;
  reg        [4:0]    motion_request;
  reg                 clear_motion_request;
  wire       [4:0]    priority_1;
  wire       [2:0]    temp_1;
  wire       [2:0]    temp_2;
  wire       [2:0]    temp_3;
  wire       [2:0]    temp_4;
  wire       [2:0]    temp_5;
  wire       [2:0]    temp_6;
  wire       [2:0]    temp_7;
  wire       [2:0]    temp_8;
  wire                drop_1;
  wire                move_down_1;
  wire                move_left_1;
  wire                move_right_1;
  wire                rotate_1;
  reg                 drop_regNext;
  reg                 move_down_regNext;
  reg                 move_left_regNext;
  reg                 move_right_regNext;
  reg                 rotate_regNext;
  wire       [4:0]    temp_motion_voted;
  wire       [9:0]    temp_motion_voted_1;
  wire       [9:0]    temp_motion_voted_2;
  wire       [4:0]    motion_voted;
  reg                 debug_place_new_cnt_willIncrement;
  wire                debug_place_new_cnt_willDecrement;
  wire                debug_place_new_cnt_willClear;
  wire                debug_place_new_cnt_willLoad;
  reg        [0:0]    debug_place_new_cnt_valueNext;
  reg        [0:0]    debug_place_new_cnt_value;
  wire                debug_place_new_cnt_willOverflowIfInc;
  wire                debug_place_new_cnt_willUnderflowIfDec;
  wire                debug_place_new_cnt_willOverflow;
  wire                debug_place_new_cnt_willUnderflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                fsm_onExit_PLACE;
  wire                fsm_onExit_FALLING;
  wire                fsm_onEntry_DOWN;
  wire                fsm_onEntry_DROP;
  wire                fsm_onEntry_LOCK;
  wire                fsm_onEntry_LOCKDOWN;
  `ifndef SYNTHESIS
  reg [135:0] fsm_stateReg_string;
  reg [135:0] fsm_stateNext_string;
  `endif


  assign temp_when = (! collision_status_payload);
  assign temp_drop_timeout_counter_valueNext_1 = drop_timeout_counter_willIncrement;
  assign temp_drop_timeout_counter_valueNext = {13'd0, temp_drop_timeout_counter_valueNext_1};
  assign temp_lock_timeout_counter_valueNext_1 = lock_timeout_counter_willIncrement;
  assign temp_lock_timeout_counter_valueNext = {6'd0, temp_lock_timeout_counter_valueNext_1};
  assign temp_9 = (temp_10 + temp_12);
  assign temp_14 = {priority_1[4],priority_1[3]};
  assign temp_13 = {1'd0, temp_14};
  assign temp_temp_motion_voted_2 = (temp_motion_voted_1 - temp_temp_motion_voted_2_1);
  assign temp_temp_motion_voted_2_2 = priority_1;
  assign temp_temp_motion_voted_2_1 = {5'd0, temp_temp_motion_voted_2_2};
  assign temp_11 = {priority_1[2],{priority_1[1],priority_1[0]}};
  always @(*) begin
    case(temp_11)
      3'b000 : temp_10 = temp_1;
      3'b001 : temp_10 = temp_2;
      3'b010 : temp_10 = temp_3;
      3'b011 : temp_10 = temp_4;
      3'b100 : temp_10 = temp_5;
      3'b101 : temp_10 = temp_6;
      3'b110 : temp_10 = temp_7;
      default : temp_10 = temp_8;
    endcase
  end

  always @(*) begin
    case(temp_13)
      3'b000 : temp_12 = temp_1;
      3'b001 : temp_12 = temp_2;
      3'b010 : temp_12 = temp_3;
      3'b011 : temp_12 = temp_4;
      3'b100 : temp_12 = temp_5;
      3'b101 : temp_12 = temp_6;
      3'b110 : temp_12 = temp_7;
      default : temp_12 = temp_8;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_1_IDLE : fsm_stateReg_string = "IDLE             ";
      fsm_1_GAME_START : fsm_stateReg_string = "GAME_START       ";
      fsm_1_RANDOM_GEN : fsm_stateReg_string = "RANDOM_GEN       ";
      fsm_1_PLACE : fsm_stateReg_string = "PLACE            ";
      fsm_1_END_1 : fsm_stateReg_string = "END_1            ";
      fsm_1_FALLING : fsm_stateReg_string = "FALLING          ";
      fsm_1_DOWN : fsm_stateReg_string = "DOWN             ";
      fsm_1_DROP : fsm_stateReg_string = "DROP             ";
      fsm_1_WAIT_ALLOW_ACTION : fsm_stateReg_string = "WAIT_ALLOW_ACTION";
      fsm_1_MOVE : fsm_stateReg_string = "MOVE             ";
      fsm_1_LOCK : fsm_stateReg_string = "LOCK             ";
      fsm_1_LOCKDOWN : fsm_stateReg_string = "LOCKDOWN         ";
      fsm_1_CLEAN : fsm_stateReg_string = "CLEAN            ";
      fsm_1_WAIT_TIME : fsm_stateReg_string = "WAIT_TIME        ";
      default : fsm_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_1_IDLE : fsm_stateNext_string = "IDLE             ";
      fsm_1_GAME_START : fsm_stateNext_string = "GAME_START       ";
      fsm_1_RANDOM_GEN : fsm_stateNext_string = "RANDOM_GEN       ";
      fsm_1_PLACE : fsm_stateNext_string = "PLACE            ";
      fsm_1_END_1 : fsm_stateNext_string = "END_1            ";
      fsm_1_FALLING : fsm_stateNext_string = "FALLING          ";
      fsm_1_DOWN : fsm_stateNext_string = "DOWN             ";
      fsm_1_DROP : fsm_stateNext_string = "DROP             ";
      fsm_1_WAIT_ALLOW_ACTION : fsm_stateNext_string = "WAIT_ALLOW_ACTION";
      fsm_1_MOVE : fsm_stateNext_string = "MOVE             ";
      fsm_1_LOCK : fsm_stateNext_string = "LOCK             ";
      fsm_1_LOCKDOWN : fsm_stateNext_string = "LOCKDOWN         ";
      fsm_1_CLEAN : fsm_stateNext_string = "CLEAN            ";
      fsm_1_WAIT_TIME : fsm_stateNext_string = "WAIT_TIME        ";
      default : fsm_stateNext_string = "?????????????????";
    endcase
  end
  `endif

  always @(*) begin
    drop_timeout_stateRise = 1'b0;
    drop_timeout_counter_willClear = 1'b0;
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_stateRise = (! drop_timeout_state);
    end
    lock_timeout_stateRise = 1'b0;
    lock_timeout_counter_willClear = 1'b0;
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_stateRise = (! lock_timeout_state);
    end
    debug_place_new_cnt_willIncrement = 1'b0;
    fsm_wantStart = 1'b0;
    gen_piece_en = 1'b0;
    move_out_left = 1'b0;
    move_out_right = 1'b0;
    move_out_rotate = 1'b0;
    softReset = 1'b0;
    game_restart = 1'b0;
    lock = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_1_GAME_START : begin
        if(screen_is_ready) begin
          fsm_stateNext = fsm_1_RANDOM_GEN;
        end
      end
      fsm_1_RANDOM_GEN : begin
        gen_piece_en = 1'b1;
        fsm_stateNext = fsm_1_PLACE;
      end
      fsm_1_PLACE : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = fsm_1_END_1;
          end else begin
            fsm_stateNext = fsm_1_FALLING;
          end
        end
      end
      fsm_1_END_1 : begin
        if(game_start) begin
          softReset = 1'b1;
          game_restart = 1'b1;
          fsm_stateNext = fsm_1_GAME_START;
        end
      end
      fsm_1_FALLING : begin
        if((move_down_1 && playfield_allow_action)) begin
          fsm_stateNext = fsm_1_DOWN;
        end
        if((drop_1 && playfield_allow_action)) begin
          fsm_stateNext = fsm_1_DROP;
        end
        if((move_left_1 && playfield_allow_action)) begin
          move_out_left = 1'b1;
          fsm_stateNext = fsm_1_MOVE;
        end
        if((move_right_1 && playfield_allow_action)) begin
          move_out_right = 1'b1;
          fsm_stateNext = fsm_1_MOVE;
        end
        if((rotate_1 && playfield_allow_action)) begin
          move_out_rotate = 1'b1;
          fsm_stateNext = fsm_1_MOVE;
        end
        if(drop_timeout_state) begin
          fsm_stateNext = fsm_1_LOCK;
        end
      end
      fsm_1_DOWN : begin
        if(collision_status_valid) begin
          if(temp_when) begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
          end
          fsm_stateNext = fsm_1_FALLING;
        end
      end
      fsm_1_DROP : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = fsm_1_LOCKDOWN;
          end else begin
            fsm_stateNext = fsm_1_WAIT_ALLOW_ACTION;
          end
        end
      end
      fsm_1_WAIT_ALLOW_ACTION : begin
        if(playfield_allow_action) begin
          fsm_stateNext = fsm_1_DROP;
        end
      end
      fsm_1_MOVE : begin
        if(collision_status_valid) begin
          fsm_stateNext = fsm_1_FALLING;
        end
      end
      fsm_1_LOCK : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = fsm_1_LOCKDOWN;
          end else begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
            fsm_stateNext = fsm_1_FALLING;
          end
        end
      end
      fsm_1_LOCKDOWN : begin
        if(lock_timeout_state) begin
          lock = 1'b1;
          fsm_stateNext = fsm_1_CLEAN;
        end
      end
      fsm_1_CLEAN : begin
        if(playfield_in_idle) begin
          lock_timeout_counter_willClear = 1'b1;
          lock_timeout_stateRise = 1'b0;
          fsm_stateNext = fsm_1_WAIT_TIME;
        end
      end
      fsm_1_WAIT_TIME : begin
        if(lock_timeout_state) begin
          fsm_stateNext = fsm_1_RANDOM_GEN;
        end
      end
      default : begin
        if(game_start) begin
          fsm_stateNext = fsm_1_GAME_START;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_onExit_PLACE) begin
      drop_timeout_counter_willClear = 1'b1;
      drop_timeout_stateRise = 1'b0;
      debug_place_new_cnt_willIncrement = 1'b1;
    end
    if(fsm_onEntry_LOCKDOWN) begin
      lock_timeout_counter_willClear = 1'b1;
      lock_timeout_stateRise = 1'b0;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_1_IDLE;
    end
  end

  assign drop_timeout_counter_willDecrement = 1'b0;
  assign drop_timeout_counter_willLoad = 1'b0;
  assign drop_timeout_counter_willOverflowIfInc = (drop_timeout_counter_value == 14'h270f);
  assign drop_timeout_counter_willUnderflowIfDec = (drop_timeout_counter_value == 14'h0);
  assign drop_timeout_counter_willOverflow = (drop_timeout_counter_willOverflowIfInc && drop_timeout_counter_willIncrement);
  always @(*) begin
    drop_timeout_counter_valueNext = (drop_timeout_counter_value + temp_drop_timeout_counter_valueNext);
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_counter_valueNext = 14'h0;
    end
    if(drop_timeout_counter_willClear) begin
      drop_timeout_counter_valueNext = 14'h0;
    end
  end

  assign drop_timeout_counter_willUnderflow = (drop_timeout_counter_willUnderflowIfDec && drop_timeout_counter_willDecrement);
  assign drop_timeout_counter_willIncrement = 1'b1;
  assign lock_timeout_counter_willDecrement = 1'b0;
  assign lock_timeout_counter_willLoad = 1'b0;
  assign lock_timeout_counter_willOverflowIfInc = (lock_timeout_counter_value == 7'h63);
  assign lock_timeout_counter_willUnderflowIfDec = (lock_timeout_counter_value == 7'h0);
  assign lock_timeout_counter_willOverflow = (lock_timeout_counter_willOverflowIfInc && lock_timeout_counter_willIncrement);
  always @(*) begin
    lock_timeout_counter_valueNext = (lock_timeout_counter_value + temp_lock_timeout_counter_valueNext);
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_counter_valueNext = 7'h0;
    end
    if(lock_timeout_counter_willClear) begin
      lock_timeout_counter_valueNext = 7'h0;
    end
  end

  assign lock_timeout_counter_willUnderflow = (lock_timeout_counter_willUnderflowIfDec && lock_timeout_counter_willDecrement);
  assign lock_timeout_counter_willIncrement = 1'b1;
  assign priority_1 = 5'h01;
  assign temp_1 = 3'b000;
  assign temp_2 = 3'b001;
  assign temp_3 = 3'b001;
  assign temp_4 = 3'b010;
  assign temp_5 = 3'b001;
  assign temp_6 = 3'b010;
  assign temp_7 = 3'b010;
  assign temp_8 = 3'b011;
  assign temp_motion_voted = motion_request;
  assign temp_motion_voted_1 = {temp_motion_voted,temp_motion_voted};
  assign temp_motion_voted_2 = (temp_motion_voted_1 & (~ temp_temp_motion_voted_2));
  assign motion_voted = (temp_motion_voted_2[9 : 5] | temp_motion_voted_2[4 : 0]);
  assign drop_1 = motion_voted[0];
  assign move_down_1 = motion_voted[1];
  assign move_left_1 = motion_voted[2];
  assign move_right_1 = motion_voted[3];
  assign rotate_1 = motion_voted[4];
  assign debug_place_new_cnt_willDecrement = 1'b0;
  assign debug_place_new_cnt_willClear = 1'b0;
  assign debug_place_new_cnt_willLoad = 1'b0;
  assign debug_place_new_cnt_willOverflowIfInc = (debug_place_new_cnt_value == 1'b1);
  assign debug_place_new_cnt_willUnderflowIfDec = (debug_place_new_cnt_value == 1'b0);
  assign debug_place_new_cnt_willOverflow = (debug_place_new_cnt_willOverflowIfInc && debug_place_new_cnt_willIncrement);
  always @(*) begin
    debug_place_new_cnt_valueNext = (debug_place_new_cnt_value + debug_place_new_cnt_willIncrement);
    if(debug_place_new_cnt_willClear) begin
      debug_place_new_cnt_valueNext = 1'b0;
    end
  end

  assign debug_place_new_cnt_willUnderflow = (debug_place_new_cnt_willUnderflowIfDec && debug_place_new_cnt_willDecrement);
  assign debug_debug_place_new = debug_place_new_cnt_willOverflow;
  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  always @(*) begin
    move_out_down = 1'b0;
    if(fsm_onEntry_DOWN) begin
      move_out_down = 1'b1;
    end
    if(fsm_onEntry_DROP) begin
      move_out_down = 1'b1;
    end
    if(fsm_onEntry_LOCK) begin
      move_out_down = 1'b1;
    end
  end

  always @(*) begin
    clear_motion_request = 1'b0;
    if(fsm_onExit_FALLING) begin
      clear_motion_request = 1'b1;
    end
  end

  assign debug_controller_in_lockdown = (fsm_stateReg == fsm_1_LOCKDOWN);
  assign debug_controller_in_end = (fsm_stateReg == fsm_1_END_1);
  assign debug_controller_in_place = (fsm_stateReg == fsm_1_PLACE);
  assign fsm_onExit_PLACE = ((fsm_stateNext != fsm_1_PLACE) && (fsm_stateReg == fsm_1_PLACE));
  assign fsm_onExit_FALLING = ((fsm_stateNext != fsm_1_FALLING) && (fsm_stateReg == fsm_1_FALLING));
  assign fsm_onEntry_DOWN = ((fsm_stateNext == fsm_1_DOWN) && (fsm_stateReg != fsm_1_DOWN));
  assign fsm_onEntry_DROP = ((fsm_stateNext == fsm_1_DROP) && (fsm_stateReg != fsm_1_DROP));
  assign fsm_onEntry_LOCK = ((fsm_stateNext == fsm_1_LOCK) && (fsm_stateReg != fsm_1_LOCK));
  assign fsm_onEntry_LOCKDOWN = ((fsm_stateNext == fsm_1_LOCKDOWN) && (fsm_stateReg != fsm_1_LOCKDOWN));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      drop_timeout_state <= 1'b0;
      drop_timeout_counter_value <= 14'h0;
      lock_timeout_state <= 1'b0;
      lock_timeout_counter_value <= 7'h0;
      motion_request <= 5'h0;
      drop_regNext <= 1'b0;
      move_down_regNext <= 1'b0;
      move_left_regNext <= 1'b0;
      move_right_regNext <= 1'b0;
      rotate_regNext <= 1'b0;
      debug_place_new_cnt_value <= 1'b0;
      fsm_stateReg <= fsm_1_IDLE;
    end else begin
      drop_timeout_counter_value <= drop_timeout_counter_valueNext;
      if(drop_timeout_counter_willOverflow) begin
        drop_timeout_state <= 1'b1;
      end
      lock_timeout_counter_value <= lock_timeout_counter_valueNext;
      if(lock_timeout_counter_willOverflow) begin
        lock_timeout_state <= 1'b1;
      end
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((temp_9 == 3'b001)); // controller.scala:L126
        `else
          if(!(temp_9 == 3'b001)) begin
            $display("FAILURE priority must be one-hot"); // controller.scala:L126
            $finish;
          end
        `endif
      `endif
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[0] <= 1'b0;
      end else begin
        if((drop && (! drop_regNext))) begin
          motion_request[0] <= 1'b1;
        end
      end
      drop_regNext <= drop;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[1] <= 1'b0;
      end else begin
        if((move_down && (! move_down_regNext))) begin
          motion_request[1] <= 1'b1;
        end
      end
      move_down_regNext <= move_down;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[2] <= 1'b0;
      end else begin
        if((move_left && (! move_left_regNext))) begin
          motion_request[2] <= 1'b1;
        end
      end
      move_left_regNext <= move_left;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[3] <= 1'b0;
      end else begin
        if((move_right && (! move_right_regNext))) begin
          motion_request[3] <= 1'b1;
        end
      end
      move_right_regNext <= move_right;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[4] <= 1'b0;
      end else begin
        if((rotate && (! rotate_regNext))) begin
          motion_request[4] <= 1'b1;
        end
      end
      rotate_regNext <= rotate;
      debug_place_new_cnt_value <= debug_place_new_cnt_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_1_GAME_START : begin
        end
        fsm_1_RANDOM_GEN : begin
        end
        fsm_1_PLACE : begin
        end
        fsm_1_END_1 : begin
        end
        fsm_1_FALLING : begin
        end
        fsm_1_DOWN : begin
          if(collision_status_valid) begin
            if(temp_when) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        fsm_1_DROP : begin
        end
        fsm_1_WAIT_ALLOW_ACTION : begin
        end
        fsm_1_MOVE : begin
        end
        fsm_1_LOCK : begin
          if(collision_status_valid) begin
            if(!collision_status_payload) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        fsm_1_LOCKDOWN : begin
        end
        fsm_1_CLEAN : begin
          if(playfield_in_idle) begin
            lock_timeout_state <= 1'b0;
          end
        end
        fsm_1_WAIT_TIME : begin
        end
        default : begin
        end
      endcase
      if(fsm_onExit_PLACE) begin
        drop_timeout_state <= 1'b0;
      end
      if(fsm_onEntry_LOCKDOWN) begin
        lock_timeout_state <= 1'b0;
      end
    end
  end


endmodule

module playfield (
  input  wire          piece_in_valid,
  input  wire [2:0]    piece_in_payload,
  output reg           status_valid,
  output reg           status_payload,
  input  wire          move_in_left,
  input  wire          move_in_right,
  input  wire          move_in_rotate,
  input  wire          move_in_down,
  input  wire          lock,
  input  wire          game_restart,
  output wire          row_val_valid,
  output reg  [9:0]    row_val_payload,
  output wire          score_val_valid,
  output wire [9:0]    score_val_payload,
  output wire          motion_is_allowed,
  output wire          fsm_is_idle,
  input  wire          clk,
  input  wire          reset
);
  localparam TYPE_1_I = 3'd0;
  localparam TYPE_1_J = 3'd1;
  localparam TYPE_1_L = 3'd2;
  localparam TYPE_1_O = 3'd3;
  localparam TYPE_1_S = 3'd4;
  localparam TYPE_1_T = 3'd5;
  localparam TYPE_1_Z = 3'd6;
  localparam ACTION_NO = 3'd0;
  localparam ACTION_LEFT = 3'd1;
  localparam ACTION_RIGHT = 3'd2;
  localparam ACTION_DOWN = 3'd3;
  localparam ACTION_ROTATE = 3'd4;
  localparam ACTION_PLACE = 3'd5;
  localparam main_fsm_IDLE = 5'd0;
  localparam main_fsm_READOUT = 5'd1;
  localparam main_fsm_LOAD_TO_CHECKER = 5'd2;
  localparam main_fsm_COLLISION_CHECK = 5'd3;
  localparam main_fsm_REPORT_COLLISION = 5'd4;
  localparam main_fsm_END_OF_COLLISION = 5'd5;
  localparam main_fsm_PASS = 5'd6;
  localparam main_fsm_WAIT_CONTROL = 5'd7;
  localparam main_fsm_ROTATION = 5'd8;
  localparam main_fsm_PRE_CHECK = 5'd9;
  localparam main_fsm_LOCKER_WRITE_0 = 5'd10;
  localparam main_fsm_LOCKER_WRITE_1 = 5'd11;
  localparam main_fsm_WAIT_LOCKER_WRITE_DONE = 5'd12;
  localparam main_fsm_LOCKER_READ = 5'd13;
  localparam main_fsm_WAIT_LOCKER_READ_DONE = 5'd14;
  localparam main_fsm_CLEAR_REGION = 5'd15;
  localparam main_fsm_CHECK_ROW_FULL = 5'd16;
  localparam main_fsm_ROW_REMOVE = 5'd17;
  localparam main_fsm_ROW_REMOVE_DONE = 5'd18;

  reg        [9:0]    locker_region_spinal_port1;
  wire       [1:0]    temp_piece_buffer_pieces_0_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_0_overflow_1;
  wire       [1:0]    temp_piece_buffer_pieces_1_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_1_overflow_1;
  wire       [1:0]    temp_piece_buffer_pieces_2_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_2_overflow_1;
  wire       [1:0]    temp_piece_buffer_pieces_3_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_3_overflow_1;
  reg        [9:0]    temp_checker_readout;
  wire       [4:0]    temp_playfield_count_8;
  wire       [4:0]    temp_playfield_count_9;
  reg        [4:0]    temp_playfield_count_10;
  wire       [2:0]    temp_playfield_count_11;
  reg        [4:0]    temp_playfield_count_12;
  wire       [2:0]    temp_playfield_count_13;
  wire       [4:0]    temp_playfield_count_14;
  reg        [4:0]    temp_playfield_count_15;
  wire       [2:0]    temp_playfield_count_16;
  reg        [4:0]    temp_playfield_count_17;
  wire       [2:0]    temp_playfield_count_18;
  wire       [4:0]    temp_playfield_count_19;
  wire       [4:0]    temp_playfield_count_20;
  reg        [4:0]    temp_playfield_count_21;
  wire       [2:0]    temp_playfield_count_22;
  reg        [4:0]    temp_playfield_count_23;
  wire       [2:0]    temp_playfield_count_24;
  wire       [4:0]    temp_playfield_count_25;
  reg        [4:0]    temp_playfield_count_26;
  wire       [2:0]    temp_playfield_count_27;
  reg        [4:0]    temp_playfield_count_28;
  wire       [2:0]    temp_playfield_count_29;
  wire       [0:0]    temp_playfield_count_30;
  wire       [21:0]   temp_playfield_lowestOne;
  wire       [9:0]    temp_playfield_total_score;
  reg        [9:0]    temp_flow_readout;
  wire                temp_locker_region_port;
  reg        [9:0]    temp_checker_region_0;
  reg        [9:0]    temp_checker_region_1;
  reg        [9:0]    temp_checker_region_2;
  reg        [9:0]    temp_checker_region_3;
  wire                temp_when;
  wire                temp_when_1;
  wire                temp_when_2;
  reg                 temp_when_3;
  reg                 piece_valid;
  reg        [2:0]    piece_payload;
  reg                 load_piece;
  reg        [2:0]    action_1;
  reg        [1:0]    piece_buffer_rot_cur;
  reg        [1:0]    piece_buffer_rot_backup;
  reg                 piece_buffer_left_shift_all;
  reg                 piece_buffer_right_shift_all;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_0_region_0;
  wire       [9:0]    piece_buffer_pieces_0_region_1;
  wire       [9:0]    piece_buffer_pieces_0_region_2;
  wire       [9:0]    piece_buffer_pieces_0_region_3;
  wire                piece_buffer_pieces_0_left_overflow;
  wire                piece_buffer_pieces_0_right_overflow;
  wire                piece_buffer_pieces_0_overflow;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_1_region_0;
  wire       [9:0]    piece_buffer_pieces_1_region_1;
  wire       [9:0]    piece_buffer_pieces_1_region_2;
  wire       [9:0]    piece_buffer_pieces_1_region_3;
  wire                piece_buffer_pieces_1_left_overflow;
  wire                piece_buffer_pieces_1_right_overflow;
  wire                piece_buffer_pieces_1_overflow;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_2_region_0;
  wire       [9:0]    piece_buffer_pieces_2_region_1;
  wire       [9:0]    piece_buffer_pieces_2_region_2;
  wire       [9:0]    piece_buffer_pieces_2_region_3;
  wire                piece_buffer_pieces_2_left_overflow;
  wire                piece_buffer_pieces_2_right_overflow;
  wire                piece_buffer_pieces_2_overflow;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_3_region_0;
  wire       [9:0]    piece_buffer_pieces_3_region_1;
  wire       [9:0]    piece_buffer_pieces_3_region_2;
  wire       [9:0]    piece_buffer_pieces_3_region_3;
  wire                piece_buffer_pieces_3_left_overflow;
  wire                piece_buffer_pieces_3_right_overflow;
  wire                piece_buffer_pieces_3_overflow;
  reg        [4:0]    checker_row;
  reg        [4:0]    checker_row_backup;
  wire                checker_read_req;
  wire                checker_addr_access_port_valid;
  wire       [1:0]    checker_addr_access_port_payload;
  reg        [9:0]    checker_region_0;
  reg        [9:0]    checker_region_1;
  reg        [9:0]    checker_region_2;
  reg        [9:0]    checker_region_3;
  reg        [9:0]    checker_readout;
  wire                checker_restore;
  reg                 checker_right_shift;
  reg                 checker_left_shift;
  wire                checker_overflowIfLeft;
  wire                checker_overflowIfRight;
  wire                checker_overflowIfDown;
  wire                playfield_reset;
  reg                 playfield_freeze;
  reg                 playfield_clear;
  reg                 playfield_update_score;
  wire       [4:0]    playfield_access_row_base;
  wire                playfield_read_req_port_valid;
  wire       [4:0]    playfield_read_req_port_payload;
  wire                playfield_write_req_port_valid;
  wire       [4:0]    playfield_write_req_port_payload;
  wire                playfield_addr_access_port_valid;
  wire       [4:0]    playfield_addr_access_port_payload;
  reg        [9:0]    playfield_readout;
  wire                playfield_write_in_port_valid;
  wire       [9:0]    playfield_write_in_port_payload;
  reg        [9:0]    playfield_region_0;
  reg        [9:0]    playfield_region_1;
  reg        [9:0]    playfield_region_2;
  reg        [9:0]    playfield_region_3;
  reg        [9:0]    playfield_region_4;
  reg        [9:0]    playfield_region_5;
  reg        [9:0]    playfield_region_6;
  reg        [9:0]    playfield_region_7;
  reg        [9:0]    playfield_region_8;
  reg        [9:0]    playfield_region_9;
  reg        [9:0]    playfield_region_10;
  reg        [9:0]    playfield_region_11;
  reg        [9:0]    playfield_region_12;
  reg        [9:0]    playfield_region_13;
  reg        [9:0]    playfield_region_14;
  reg        [9:0]    playfield_region_15;
  reg        [9:0]    playfield_region_16;
  reg        [9:0]    playfield_region_17;
  reg        [9:0]    playfield_region_18;
  reg        [9:0]    playfield_region_19;
  reg        [9:0]    playfield_region_20;
  reg        [9:0]    playfield_region_21;
  reg        [21:0]   playfield_row_sel;
  wire                playfield_address_beyond_limit;
  wire       [219:0]  temp_playfield_region_0;
  reg        [21:0]   playfield_ones;
  wire       [4:0]    temp_playfield_count;
  wire       [4:0]    temp_playfield_count_1;
  wire       [4:0]    temp_playfield_count_2;
  wire       [4:0]    temp_playfield_count_3;
  wire       [4:0]    temp_playfield_count_4;
  wire       [4:0]    temp_playfield_count_5;
  wire       [4:0]    temp_playfield_count_6;
  wire       [4:0]    temp_playfield_count_7;
  reg        [4:0]    playfield_count;
  wire                playfield_isRowFull;
  wire       [21:0]   playfield_lowestOne;
  wire       [21:0]   playfield_rows_to_clear;
  reg        [9:0]    playfield_total_score;
  reg                 playfield_update_score_delay_1;
  reg                 playfield_lock_score;
  reg                 playfield_lock_score_1d;
  reg                 game_restart_regNext;
  reg        [4:0]    flow_row;
  wire                flow_read_req;
  wire                flow_addr_access_port_valid;
  wire       [1:0]    flow_addr_access_port_payload;
  reg        [9:0]    flow_region_0;
  reg        [9:0]    flow_region_1;
  reg        [9:0]    flow_region_2;
  reg        [9:0]    flow_region_3;
  reg        [9:0]    flow_readout;
  reg                 flow_update;
  reg        [3:0]    flow_row_occuppied;
  reg                 collision_checker_start;
  reg                 collision_checker_collision_bits_valid;
  reg                 collision_checker_collision_bits_payload;
  wire                collision_checker_src_0_valid;
  wire       [9:0]    collision_checker_src_0_payload;
  wire                collision_checker_src_1_valid;
  wire       [9:0]    collision_checker_src_1_payload;
  reg                 collision_checker_check_status;
  wire                collision_checker_is_collision_valid;
  wire                collision_checker_is_collision_payload;
  reg                 collision_checker_collision_bits_valid_regNext;
  reg                 output_en;
  wire                playfield_dataout_valid;
  wire       [9:0]    playfield_dataout_payload;
  wire                src_0_valid;
  wire       [9:0]    src_0_payload;
  wire                src_1_valid;
  wire       [9:0]    src_1_payload;
  wire                src_2_valid;
  wire       [9:0]    src_2_payload;
  reg                 playfield_dataout_stage_valid;
  reg        [9:0]    playfield_dataout_stage_payload;
  wire       [9:0]    row_merged;
  reg                 src_0_valid_regNext;
  wire                row_out_done;
  wire                locker_addr_access_port_valid;
  wire       [1:0]    locker_addr_access_port_payload;
  wire                locker_data_in_port_valid;
  wire       [9:0]    locker_data_in_port_payload;
  wire       [9:0]    locker_readout;
  reg                 locker_addr_access_port_valid_regNext;
  wire                locker_readou_is_done;
  reg        [4:0]    dma_playfield_dma_base_addr;
  reg        [4:0]    dma_playfield_dma_word_count;
  reg                 dma_playfield_dma_start;
  reg        [4:0]    dma_playfield_dma_req_counter;
  wire                dma_playfield_dma_counter_is_last;
  reg                 dma_playfield_dma_start_regNext;
  wire                dma_playfield_dma_trig;
  reg                 dma_playfield_dma_req_valid;
  reg                 dma_playfield_dma_req_valid_regNext;
  reg        [4:0]    dma_playfield_dma_addr;
  wire       [9:0]    dma_playfield_dma_source_0;
  wire       [9:0]    dma_playfield_dma_source_1;
  wire                dma_playfield_dma_sink_0_valid;
  wire       [9:0]    dma_playfield_dma_sink_0_payload;
  wire                dma_playfield_dma_sink_1_valid;
  wire       [9:0]    dma_playfield_dma_sink_1_payload;
  wire                dma_playfield_dma_sink_2_valid;
  wire       [9:0]    dma_playfield_dma_sink_2_payload;
  reg                 dma_playfield_dma_req_valid_1d;
  wire                dma_playfield_dma_channel_0_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_payload;
  reg                 dma_playfield_dma_channel_0_enable;
  wire                dma_playfield_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_data_in_payload;
  wire                dma_playfield_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_data_out_payload;
  wire                dma_playfield_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_data_inter_payload;
  wire                dma_playfield_dma_channel_1_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_payload;
  reg                 dma_playfield_dma_channel_1_enable;
  wire                dma_playfield_dma_channel_1_data_in_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_data_in_payload;
  wire                dma_playfield_dma_channel_1_data_out_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_data_out_payload;
  wire                dma_playfield_dma_channel_1_data_inter_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_data_inter_payload;
  wire                dma_playfield_dma_channel_2_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_payload;
  reg                 dma_playfield_dma_channel_2_enable;
  wire                dma_playfield_dma_channel_2_data_in_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_data_in_payload;
  wire                dma_playfield_dma_channel_2_data_out_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_data_out_payload;
  wire                dma_playfield_dma_channel_2_data_inter_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_data_inter_payload;
  wire       [1:0]    dma_checker_dma_base_addr;
  wire       [1:0]    dma_checker_dma_word_count;
  reg                 dma_checker_dma_start;
  reg        [1:0]    dma_checker_dma_req_counter;
  wire                dma_checker_dma_counter_is_last;
  reg                 dma_checker_dma_start_regNext;
  wire                dma_checker_dma_trig;
  reg                 dma_checker_dma_req_valid;
  reg                 dma_checker_dma_req_valid_regNext;
  reg        [1:0]    dma_checker_dma_addr;
  wire       [9:0]    dma_checker_dma_source_0;
  wire                dma_checker_dma_sink_0_valid;
  wire       [9:0]    dma_checker_dma_sink_0_payload;
  reg                 dma_checker_dma_req_valid_1d;
  wire                dma_checker_dma_channel_0_valid;
  wire       [9:0]    dma_checker_dma_channel_0_payload;
  reg                 dma_checker_dma_channel_0_enable;
  wire                dma_checker_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_checker_dma_channel_0_data_in_payload;
  wire                dma_checker_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_checker_dma_channel_0_data_out_payload;
  wire                dma_checker_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_checker_dma_channel_0_data_inter_payload;
  wire       [1:0]    dma_flow_dma_base_addr;
  wire       [1:0]    dma_flow_dma_word_count;
  reg                 dma_flow_dma_start;
  reg        [1:0]    dma_flow_dma_req_counter;
  wire                dma_flow_dma_counter_is_last;
  reg                 dma_flow_dma_start_regNext;
  wire                dma_flow_dma_trig;
  reg                 dma_flow_dma_req_valid;
  reg                 dma_flow_dma_req_valid_regNext;
  reg        [1:0]    dma_flow_dma_addr;
  wire       [9:0]    dma_flow_dma_source_0;
  wire                dma_flow_dma_sink_0_valid;
  wire       [9:0]    dma_flow_dma_sink_0_payload;
  reg                 dma_flow_dma_req_valid_1d;
  wire                dma_flow_dma_channel_0_valid;
  wire       [9:0]    dma_flow_dma_channel_0_payload;
  reg                 dma_flow_dma_channel_0_enable;
  wire                dma_flow_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_flow_dma_channel_0_data_in_payload;
  wire                dma_flow_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_flow_dma_channel_0_data_out_payload;
  wire                dma_flow_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_flow_dma_channel_0_data_inter_payload;
  wire       [1:0]    dma_locker_dma_base_addr;
  wire       [1:0]    dma_locker_dma_word_count;
  reg                 dma_locker_dma_start;
  reg        [1:0]    dma_locker_dma_req_counter;
  wire                dma_locker_dma_counter_is_last;
  reg                 dma_locker_dma_start_regNext;
  wire                dma_locker_dma_trig;
  reg                 dma_locker_dma_req_valid;
  reg                 dma_locker_dma_req_valid_regNext;
  reg        [1:0]    dma_locker_dma_addr;
  wire       [9:0]    dma_locker_dma_source_0;
  wire       [9:0]    dma_locker_dma_source_1;
  wire                dma_locker_dma_sink_0_valid;
  wire       [9:0]    dma_locker_dma_sink_0_payload;
  wire                dma_locker_dma_sink_1_valid;
  wire       [9:0]    dma_locker_dma_sink_1_payload;
  reg                 dma_locker_dma_req_valid_1d;
  wire                dma_locker_dma_channel_0_valid;
  wire       [9:0]    dma_locker_dma_channel_0_payload;
  reg                 dma_locker_dma_channel_0_enable;
  wire                dma_locker_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_locker_dma_channel_0_data_in_payload;
  wire                dma_locker_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_locker_dma_channel_0_data_out_payload;
  wire                dma_locker_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_locker_dma_channel_0_data_inter_payload;
  wire                dma_locker_dma_channel_1_valid;
  wire       [9:0]    dma_locker_dma_channel_1_payload;
  reg                 dma_locker_dma_channel_1_enable;
  wire                dma_locker_dma_channel_1_data_in_valid;
  wire       [9:0]    dma_locker_dma_channel_1_data_in_payload;
  wire                dma_locker_dma_channel_1_data_out_valid;
  wire       [9:0]    dma_locker_dma_channel_1_data_out_payload;
  wire                dma_locker_dma_channel_1_data_inter_valid;
  wire       [9:0]    dma_locker_dma_channel_1_data_inter_payload;
  wire                main_fsm_wantExit;
  reg                 main_fsm_wantStart;
  wire                main_fsm_wantKill;
  reg                 main_fsm_will_goto_idle;
  reg        [4:0]    main_fsm_stateReg;
  reg        [4:0]    main_fsm_stateNext;
  wire       [39:0]   temp_flow_region_0;
  wire                main_fsm_onExit_READOUT;
  wire                main_fsm_onExit_COLLISION_CHECK;
  wire                main_fsm_onExit_PASS;
  wire                main_fsm_onExit_WAIT_LOCKER_WRITE_DONE;
  wire                main_fsm_onExit_WAIT_LOCKER_READ_DONE;
  wire                main_fsm_onEntry_READOUT;
  wire                main_fsm_onEntry_COLLISION_CHECK;
  wire                main_fsm_onEntry_PASS;
  wire                main_fsm_onEntry_LOCKER_WRITE_0;
  wire                main_fsm_onEntry_LOCKER_READ;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_string;
  reg [7:0] piece_payload_string;
  reg [47:0] action_1_string;
  reg [175:0] main_fsm_stateReg_string;
  reg [175:0] main_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [9:0] locker_region [0:3];

  assign temp_when = (action_1 == ACTION_PLACE);
  assign temp_when_1 = (action_1 == ACTION_DOWN);
  assign temp_when_2 = (action_1 == ACTION_ROTATE);
  assign temp_playfield_count_8 = (temp_playfield_count_9 + temp_playfield_count_14);
  assign temp_playfield_count_9 = (temp_playfield_count_10 + temp_playfield_count_12);
  assign temp_playfield_count_14 = (temp_playfield_count_15 + temp_playfield_count_17);
  assign temp_playfield_count_19 = (temp_playfield_count_20 + temp_playfield_count_25);
  assign temp_playfield_count_20 = (temp_playfield_count_21 + temp_playfield_count_23);
  assign temp_playfield_count_25 = (temp_playfield_count_26 + temp_playfield_count_28);
  assign temp_playfield_count_30 = playfield_ones[21];
  assign temp_playfield_count_29 = {2'd0, temp_playfield_count_30};
  assign temp_playfield_lowestOne = (playfield_ones - 22'h000001);
  assign temp_playfield_total_score = {5'd0, playfield_count};
  assign temp_locker_region_port = (locker_addr_access_port_valid && locker_data_in_port_valid);
  assign temp_playfield_count_11 = {playfield_ones[2],{playfield_ones[1],playfield_ones[0]}};
  assign temp_playfield_count_13 = {playfield_ones[5],{playfield_ones[4],playfield_ones[3]}};
  assign temp_playfield_count_16 = {playfield_ones[8],{playfield_ones[7],playfield_ones[6]}};
  assign temp_playfield_count_18 = {playfield_ones[11],{playfield_ones[10],playfield_ones[9]}};
  assign temp_playfield_count_22 = {playfield_ones[14],{playfield_ones[13],playfield_ones[12]}};
  assign temp_playfield_count_24 = {playfield_ones[17],{playfield_ones[16],playfield_ones[15]}};
  assign temp_playfield_count_27 = {playfield_ones[20],{playfield_ones[19],playfield_ones[18]}};
  assign temp_piece_buffer_pieces_0_overflow = piece_buffer_pieces_0_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_0_overflow_1 = piece_buffer_pieces_0_region_extra_0[1 : 0];
  assign temp_piece_buffer_pieces_1_overflow = piece_buffer_pieces_1_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_1_overflow_1 = piece_buffer_pieces_1_region_extra_0[1 : 0];
  assign temp_piece_buffer_pieces_2_overflow = piece_buffer_pieces_2_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_2_overflow_1 = piece_buffer_pieces_2_region_extra_0[1 : 0];
  assign temp_piece_buffer_pieces_3_overflow = piece_buffer_pieces_3_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_3_overflow_1 = piece_buffer_pieces_3_region_extra_0[1 : 0];
  always @(posedge clk) begin
    if(temp_locker_region_port) begin
      locker_region[locker_addr_access_port_payload] <= locker_data_in_port_payload;
    end
  end

  always @(posedge clk) begin
    if(locker_addr_access_port_valid) begin
      locker_region_spinal_port1 <= locker_region[locker_addr_access_port_payload];
    end
  end

  always @(*) begin
    case(checker_addr_access_port_payload)
      2'b00 : temp_checker_readout = checker_region_0;
      2'b01 : temp_checker_readout = checker_region_1;
      2'b10 : temp_checker_readout = checker_region_2;
      default : temp_checker_readout = checker_region_3;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_11)
      3'b000 : temp_playfield_count_10 = temp_playfield_count;
      3'b001 : temp_playfield_count_10 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_10 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_10 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_10 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_10 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_10 = temp_playfield_count_6;
      default : temp_playfield_count_10 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_13)
      3'b000 : temp_playfield_count_12 = temp_playfield_count;
      3'b001 : temp_playfield_count_12 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_12 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_12 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_12 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_12 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_12 = temp_playfield_count_6;
      default : temp_playfield_count_12 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_16)
      3'b000 : temp_playfield_count_15 = temp_playfield_count;
      3'b001 : temp_playfield_count_15 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_15 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_15 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_15 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_15 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_15 = temp_playfield_count_6;
      default : temp_playfield_count_15 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_18)
      3'b000 : temp_playfield_count_17 = temp_playfield_count;
      3'b001 : temp_playfield_count_17 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_17 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_17 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_17 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_17 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_17 = temp_playfield_count_6;
      default : temp_playfield_count_17 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_22)
      3'b000 : temp_playfield_count_21 = temp_playfield_count;
      3'b001 : temp_playfield_count_21 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_21 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_21 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_21 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_21 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_21 = temp_playfield_count_6;
      default : temp_playfield_count_21 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_24)
      3'b000 : temp_playfield_count_23 = temp_playfield_count;
      3'b001 : temp_playfield_count_23 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_23 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_23 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_23 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_23 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_23 = temp_playfield_count_6;
      default : temp_playfield_count_23 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_27)
      3'b000 : temp_playfield_count_26 = temp_playfield_count;
      3'b001 : temp_playfield_count_26 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_26 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_26 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_26 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_26 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_26 = temp_playfield_count_6;
      default : temp_playfield_count_26 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_29)
      3'b000 : temp_playfield_count_28 = temp_playfield_count;
      3'b001 : temp_playfield_count_28 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_28 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_28 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_28 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_28 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_28 = temp_playfield_count_6;
      default : temp_playfield_count_28 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(flow_addr_access_port_payload)
      2'b00 : temp_flow_readout = flow_region_0;
      2'b01 : temp_flow_readout = flow_region_1;
      2'b10 : temp_flow_readout = flow_region_2;
      default : temp_flow_readout = flow_region_3;
    endcase
  end

  always @(*) begin
    case(piece_buffer_rot_cur)
      2'b00 : begin
        temp_checker_region_0 = piece_buffer_pieces_0_region_0;
        temp_checker_region_1 = piece_buffer_pieces_0_region_1;
        temp_checker_region_2 = piece_buffer_pieces_0_region_2;
        temp_checker_region_3 = piece_buffer_pieces_0_region_3;
        temp_when_3 = piece_buffer_pieces_0_overflow;
      end
      2'b01 : begin
        temp_checker_region_0 = piece_buffer_pieces_1_region_0;
        temp_checker_region_1 = piece_buffer_pieces_1_region_1;
        temp_checker_region_2 = piece_buffer_pieces_1_region_2;
        temp_checker_region_3 = piece_buffer_pieces_1_region_3;
        temp_when_3 = piece_buffer_pieces_1_overflow;
      end
      2'b10 : begin
        temp_checker_region_0 = piece_buffer_pieces_2_region_0;
        temp_checker_region_1 = piece_buffer_pieces_2_region_1;
        temp_checker_region_2 = piece_buffer_pieces_2_region_2;
        temp_checker_region_3 = piece_buffer_pieces_2_region_3;
        temp_when_3 = piece_buffer_pieces_2_overflow;
      end
      default : begin
        temp_checker_region_0 = piece_buffer_pieces_3_region_0;
        temp_checker_region_1 = piece_buffer_pieces_3_region_1;
        temp_checker_region_2 = piece_buffer_pieces_3_region_2;
        temp_checker_region_3 = piece_buffer_pieces_3_region_3;
        temp_when_3 = piece_buffer_pieces_3_overflow;
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_in_payload)
      TYPE_1_I : piece_in_payload_string = "I";
      TYPE_1_J : piece_in_payload_string = "J";
      TYPE_1_L : piece_in_payload_string = "L";
      TYPE_1_O : piece_in_payload_string = "O";
      TYPE_1_S : piece_in_payload_string = "S";
      TYPE_1_T : piece_in_payload_string = "T";
      TYPE_1_Z : piece_in_payload_string = "Z";
      default : piece_in_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_payload)
      TYPE_1_I : piece_payload_string = "I";
      TYPE_1_J : piece_payload_string = "J";
      TYPE_1_L : piece_payload_string = "L";
      TYPE_1_O : piece_payload_string = "O";
      TYPE_1_S : piece_payload_string = "S";
      TYPE_1_T : piece_payload_string = "T";
      TYPE_1_Z : piece_payload_string = "Z";
      default : piece_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(action_1)
      ACTION_NO : action_1_string = "NO    ";
      ACTION_LEFT : action_1_string = "LEFT  ";
      ACTION_RIGHT : action_1_string = "RIGHT ";
      ACTION_DOWN : action_1_string = "DOWN  ";
      ACTION_ROTATE : action_1_string = "ROTATE";
      ACTION_PLACE : action_1_string = "PLACE ";
      default : action_1_string = "??????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateReg)
      main_fsm_IDLE : main_fsm_stateReg_string = "IDLE                  ";
      main_fsm_READOUT : main_fsm_stateReg_string = "READOUT               ";
      main_fsm_LOAD_TO_CHECKER : main_fsm_stateReg_string = "LOAD_TO_CHECKER       ";
      main_fsm_COLLISION_CHECK : main_fsm_stateReg_string = "COLLISION_CHECK       ";
      main_fsm_REPORT_COLLISION : main_fsm_stateReg_string = "REPORT_COLLISION      ";
      main_fsm_END_OF_COLLISION : main_fsm_stateReg_string = "END_OF_COLLISION      ";
      main_fsm_PASS : main_fsm_stateReg_string = "PASS                  ";
      main_fsm_WAIT_CONTROL : main_fsm_stateReg_string = "WAIT_CONTROL          ";
      main_fsm_ROTATION : main_fsm_stateReg_string = "ROTATION              ";
      main_fsm_PRE_CHECK : main_fsm_stateReg_string = "PRE_CHECK             ";
      main_fsm_LOCKER_WRITE_0 : main_fsm_stateReg_string = "LOCKER_WRITE_0        ";
      main_fsm_LOCKER_WRITE_1 : main_fsm_stateReg_string = "LOCKER_WRITE_1        ";
      main_fsm_WAIT_LOCKER_WRITE_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_WRITE_DONE";
      main_fsm_LOCKER_READ : main_fsm_stateReg_string = "LOCKER_READ           ";
      main_fsm_WAIT_LOCKER_READ_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_READ_DONE ";
      main_fsm_CLEAR_REGION : main_fsm_stateReg_string = "CLEAR_REGION          ";
      main_fsm_CHECK_ROW_FULL : main_fsm_stateReg_string = "CHECK_ROW_FULL        ";
      main_fsm_ROW_REMOVE : main_fsm_stateReg_string = "ROW_REMOVE            ";
      main_fsm_ROW_REMOVE_DONE : main_fsm_stateReg_string = "ROW_REMOVE_DONE       ";
      default : main_fsm_stateReg_string = "??????????????????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateNext)
      main_fsm_IDLE : main_fsm_stateNext_string = "IDLE                  ";
      main_fsm_READOUT : main_fsm_stateNext_string = "READOUT               ";
      main_fsm_LOAD_TO_CHECKER : main_fsm_stateNext_string = "LOAD_TO_CHECKER       ";
      main_fsm_COLLISION_CHECK : main_fsm_stateNext_string = "COLLISION_CHECK       ";
      main_fsm_REPORT_COLLISION : main_fsm_stateNext_string = "REPORT_COLLISION      ";
      main_fsm_END_OF_COLLISION : main_fsm_stateNext_string = "END_OF_COLLISION      ";
      main_fsm_PASS : main_fsm_stateNext_string = "PASS                  ";
      main_fsm_WAIT_CONTROL : main_fsm_stateNext_string = "WAIT_CONTROL          ";
      main_fsm_ROTATION : main_fsm_stateNext_string = "ROTATION              ";
      main_fsm_PRE_CHECK : main_fsm_stateNext_string = "PRE_CHECK             ";
      main_fsm_LOCKER_WRITE_0 : main_fsm_stateNext_string = "LOCKER_WRITE_0        ";
      main_fsm_LOCKER_WRITE_1 : main_fsm_stateNext_string = "LOCKER_WRITE_1        ";
      main_fsm_WAIT_LOCKER_WRITE_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_WRITE_DONE";
      main_fsm_LOCKER_READ : main_fsm_stateNext_string = "LOCKER_READ           ";
      main_fsm_WAIT_LOCKER_READ_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_READ_DONE ";
      main_fsm_CLEAR_REGION : main_fsm_stateNext_string = "CLEAR_REGION          ";
      main_fsm_CHECK_ROW_FULL : main_fsm_stateNext_string = "CHECK_ROW_FULL        ";
      main_fsm_ROW_REMOVE : main_fsm_stateNext_string = "ROW_REMOVE            ";
      main_fsm_ROW_REMOVE_DONE : main_fsm_stateNext_string = "ROW_REMOVE_DONE       ";
      default : main_fsm_stateNext_string = "??????????????????????";
    endcase
  end
  `endif

  always @(*) begin
    load_piece = 1'b0;
    piece_buffer_left_shift_all = 1'b0;
    piece_buffer_right_shift_all = 1'b0;
    checker_right_shift = 1'b0;
    checker_left_shift = 1'b0;
    playfield_freeze = 1'b0;
    playfield_clear = 1'b0;
    playfield_update_score = 1'b0;
    flow_update = 1'b0;
    collision_checker_start = 1'b0;
    output_en = 1'b0;
    dma_playfield_dma_start = 1'b0;
    dma_checker_dma_start = 1'b0;
    dma_flow_dma_start = 1'b0;
    dma_locker_dma_start = 1'b0;
    main_fsm_wantStart = 1'b0;
    status_valid = 1'b0;
    status_payload = 1'b0;
    main_fsm_stateNext = main_fsm_stateReg;
    case(main_fsm_stateReg)
      main_fsm_READOUT : begin
        output_en = 1'b1;
        if((playfield_addr_access_port_payload == flow_row)) begin
          dma_flow_dma_start = 1'b1;
        end
        if(row_out_done) begin
          if(main_fsm_will_goto_idle) begin
            main_fsm_stateNext = main_fsm_IDLE;
          end else begin
            main_fsm_stateNext = main_fsm_WAIT_CONTROL;
          end
        end
      end
      main_fsm_LOAD_TO_CHECKER : begin
        load_piece = 1'b1;
        main_fsm_stateNext = main_fsm_COLLISION_CHECK;
      end
      main_fsm_COLLISION_CHECK : begin
        if(collision_checker_is_collision_valid) begin
          if(collision_checker_is_collision_payload) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = main_fsm_PASS;
          end
        end
      end
      main_fsm_REPORT_COLLISION : begin
        status_valid = 1'b1;
        status_payload = 1'b1;
        if(temp_when) begin
          main_fsm_stateNext = main_fsm_IDLE;
        end else begin
          main_fsm_stateNext = main_fsm_END_OF_COLLISION;
        end
      end
      main_fsm_END_OF_COLLISION : begin
        if((((action_1 == ACTION_LEFT) || (action_1 == ACTION_RIGHT)) || (action_1 == ACTION_ROTATE))) begin
          load_piece = 1'b1;
        end
        main_fsm_stateNext = main_fsm_READOUT;
      end
      main_fsm_PASS : begin
        if((action_1 == ACTION_PLACE)) begin
          flow_update = 1'b1;
        end
        if((action_1 == ACTION_LEFT)) begin
          flow_update = 1'b1;
          piece_buffer_left_shift_all = 1'b1;
        end
        if((action_1 == ACTION_RIGHT)) begin
          flow_update = 1'b1;
          piece_buffer_right_shift_all = 1'b1;
        end
        if(temp_when_1) begin
          flow_update = 1'b1;
        end
        if(temp_when_2) begin
          flow_update = 1'b1;
        end
        main_fsm_stateNext = main_fsm_READOUT;
      end
      main_fsm_WAIT_CONTROL : begin
        if(move_in_left) begin
          if(checker_overflowIfLeft) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            checker_left_shift = 1'b1;
            main_fsm_stateNext = main_fsm_PRE_CHECK;
          end
        end
        if(move_in_right) begin
          if(checker_overflowIfRight) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            checker_right_shift = 1'b1;
            main_fsm_stateNext = main_fsm_PRE_CHECK;
          end
        end
        if(move_in_down) begin
          if(checker_overflowIfDown) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = main_fsm_PRE_CHECK;
          end
        end
        if(move_in_rotate) begin
          main_fsm_stateNext = main_fsm_ROTATION;
        end
        if(lock) begin
          main_fsm_stateNext = main_fsm_LOCKER_WRITE_0;
        end
      end
      main_fsm_ROTATION : begin
        if(temp_when_3) begin
          main_fsm_stateNext = main_fsm_REPORT_COLLISION;
        end else begin
          load_piece = 1'b1;
          main_fsm_stateNext = main_fsm_PRE_CHECK;
        end
      end
      main_fsm_PRE_CHECK : begin
        main_fsm_stateNext = main_fsm_COLLISION_CHECK;
      end
      main_fsm_LOCKER_WRITE_0 : begin
        dma_flow_dma_start = 1'b1;
        main_fsm_stateNext = main_fsm_LOCKER_WRITE_1;
      end
      main_fsm_LOCKER_WRITE_1 : begin
        dma_locker_dma_start = 1'b1;
        main_fsm_stateNext = main_fsm_WAIT_LOCKER_WRITE_DONE;
      end
      main_fsm_WAIT_LOCKER_WRITE_DONE : begin
        if(row_out_done) begin
          main_fsm_stateNext = main_fsm_LOCKER_READ;
        end
      end
      main_fsm_LOCKER_READ : begin
        dma_playfield_dma_start = 1'b1;
        main_fsm_stateNext = main_fsm_WAIT_LOCKER_READ_DONE;
      end
      main_fsm_WAIT_LOCKER_READ_DONE : begin
        playfield_freeze = 1'b1;
        if(locker_readou_is_done) begin
          main_fsm_stateNext = main_fsm_CLEAR_REGION;
        end
      end
      main_fsm_CLEAR_REGION : begin
        playfield_update_score = 1'b1;
        main_fsm_stateNext = main_fsm_CHECK_ROW_FULL;
      end
      main_fsm_CHECK_ROW_FULL : begin
        if(playfield_isRowFull) begin
          main_fsm_stateNext = main_fsm_ROW_REMOVE;
        end else begin
          main_fsm_stateNext = main_fsm_READOUT;
        end
      end
      main_fsm_ROW_REMOVE : begin
        playfield_clear = 1'b1;
        main_fsm_stateNext = main_fsm_ROW_REMOVE_DONE;
      end
      main_fsm_ROW_REMOVE_DONE : begin
        main_fsm_stateNext = main_fsm_CHECK_ROW_FULL;
      end
      default : begin
        if(piece_valid) begin
          main_fsm_stateNext = main_fsm_LOAD_TO_CHECKER;
        end
        main_fsm_wantStart = 1'b1;
      end
    endcase
    if(main_fsm_onExit_READOUT) begin
      dma_playfield_dma_start = 1'b0;
      dma_flow_dma_start = 1'b0;
    end
    if(main_fsm_onExit_COLLISION_CHECK) begin
      dma_playfield_dma_start = 1'b0;
      dma_checker_dma_start = 1'b0;
    end
    if(main_fsm_onExit_WAIT_LOCKER_WRITE_DONE) begin
      dma_playfield_dma_start = 1'b0;
      dma_flow_dma_start = 1'b0;
      dma_locker_dma_start = 1'b0;
    end
    if(main_fsm_onExit_WAIT_LOCKER_READ_DONE) begin
      dma_locker_dma_start = 1'b0;
      dma_playfield_dma_start = 1'b0;
    end
    if(main_fsm_onEntry_READOUT) begin
      dma_playfield_dma_start = 1'b1;
    end
    if(main_fsm_onEntry_COLLISION_CHECK) begin
      collision_checker_start = 1'b1;
      dma_playfield_dma_start = 1'b1;
      dma_checker_dma_start = 1'b1;
    end
    if(main_fsm_onEntry_PASS) begin
      status_valid = 1'b1;
      status_payload = 1'b0;
    end
    if(main_fsm_onEntry_LOCKER_WRITE_0) begin
      dma_playfield_dma_start = 1'b1;
    end
    if(main_fsm_onEntry_LOCKER_READ) begin
      dma_locker_dma_start = 1'b1;
      playfield_freeze = 1'b1;
    end
    if(main_fsm_wantKill) begin
      main_fsm_stateNext = main_fsm_IDLE;
    end
  end

  assign piece_buffer_pieces_0_left_overflow = 1'b0;
  assign piece_buffer_pieces_0_right_overflow = 1'b0;
  assign piece_buffer_pieces_0_overflow = (((((piece_buffer_pieces_0_left_overflow || (|temp_piece_buffer_pieces_0_overflow)) || (|piece_buffer_pieces_0_region_extra_1[13 : 12])) || (|piece_buffer_pieces_0_region_extra_2[13 : 12])) || (|piece_buffer_pieces_0_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_0_right_overflow || (|temp_piece_buffer_pieces_0_overflow_1)) || (|piece_buffer_pieces_0_region_extra_1[1 : 0])) || (|piece_buffer_pieces_0_region_extra_2[1 : 0])) || (|piece_buffer_pieces_0_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_1_left_overflow = 1'b0;
  assign piece_buffer_pieces_1_right_overflow = 1'b0;
  assign piece_buffer_pieces_1_overflow = (((((piece_buffer_pieces_1_left_overflow || (|temp_piece_buffer_pieces_1_overflow)) || (|piece_buffer_pieces_1_region_extra_1[13 : 12])) || (|piece_buffer_pieces_1_region_extra_2[13 : 12])) || (|piece_buffer_pieces_1_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_1_right_overflow || (|temp_piece_buffer_pieces_1_overflow_1)) || (|piece_buffer_pieces_1_region_extra_1[1 : 0])) || (|piece_buffer_pieces_1_region_extra_2[1 : 0])) || (|piece_buffer_pieces_1_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_2_left_overflow = 1'b0;
  assign piece_buffer_pieces_2_right_overflow = 1'b0;
  assign piece_buffer_pieces_2_overflow = (((((piece_buffer_pieces_2_left_overflow || (|temp_piece_buffer_pieces_2_overflow)) || (|piece_buffer_pieces_2_region_extra_1[13 : 12])) || (|piece_buffer_pieces_2_region_extra_2[13 : 12])) || (|piece_buffer_pieces_2_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_2_right_overflow || (|temp_piece_buffer_pieces_2_overflow_1)) || (|piece_buffer_pieces_2_region_extra_1[1 : 0])) || (|piece_buffer_pieces_2_region_extra_2[1 : 0])) || (|piece_buffer_pieces_2_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_3_left_overflow = 1'b0;
  assign piece_buffer_pieces_3_right_overflow = 1'b0;
  assign piece_buffer_pieces_3_overflow = (((((piece_buffer_pieces_3_left_overflow || (|temp_piece_buffer_pieces_3_overflow)) || (|piece_buffer_pieces_3_region_extra_1[13 : 12])) || (|piece_buffer_pieces_3_region_extra_2[13 : 12])) || (|piece_buffer_pieces_3_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_3_right_overflow || (|temp_piece_buffer_pieces_3_overflow_1)) || (|piece_buffer_pieces_3_region_extra_1[1 : 0])) || (|piece_buffer_pieces_3_region_extra_2[1 : 0])) || (|piece_buffer_pieces_3_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_0_region_0 = piece_buffer_pieces_0_region_extra_0[11 : 2];
  assign piece_buffer_pieces_0_region_1 = piece_buffer_pieces_0_region_extra_1[11 : 2];
  assign piece_buffer_pieces_0_region_2 = piece_buffer_pieces_0_region_extra_2[11 : 2];
  assign piece_buffer_pieces_0_region_3 = piece_buffer_pieces_0_region_extra_3[11 : 2];
  assign piece_buffer_pieces_1_region_0 = piece_buffer_pieces_1_region_extra_0[11 : 2];
  assign piece_buffer_pieces_1_region_1 = piece_buffer_pieces_1_region_extra_1[11 : 2];
  assign piece_buffer_pieces_1_region_2 = piece_buffer_pieces_1_region_extra_2[11 : 2];
  assign piece_buffer_pieces_1_region_3 = piece_buffer_pieces_1_region_extra_3[11 : 2];
  assign piece_buffer_pieces_2_region_0 = piece_buffer_pieces_2_region_extra_0[11 : 2];
  assign piece_buffer_pieces_2_region_1 = piece_buffer_pieces_2_region_extra_1[11 : 2];
  assign piece_buffer_pieces_2_region_2 = piece_buffer_pieces_2_region_extra_2[11 : 2];
  assign piece_buffer_pieces_2_region_3 = piece_buffer_pieces_2_region_extra_3[11 : 2];
  assign piece_buffer_pieces_3_region_0 = piece_buffer_pieces_3_region_extra_0[11 : 2];
  assign piece_buffer_pieces_3_region_1 = piece_buffer_pieces_3_region_extra_1[11 : 2];
  assign piece_buffer_pieces_3_region_2 = piece_buffer_pieces_3_region_extra_2[11 : 2];
  assign piece_buffer_pieces_3_region_3 = piece_buffer_pieces_3_region_extra_3[11 : 2];
  assign checker_read_req = 1'b0;
  assign checker_restore = 1'b0;
  assign checker_overflowIfLeft = (((checker_region_0[9] || checker_region_1[9]) || checker_region_2[9]) || checker_region_3[9]);
  assign checker_overflowIfRight = (((checker_region_0[0] || checker_region_1[0]) || checker_region_2[0]) || checker_region_3[0]);
  assign checker_overflowIfDown = ((((checker_row == 5'h15) || ((checker_row == 5'h14) && (|checker_region_1))) || ((checker_row == 5'h13) && (|checker_region_2))) || ((checker_row == 5'h12) && (|checker_region_3)));
  assign playfield_reset = 1'b0;
  assign playfield_access_row_base = 5'h0;
  assign playfield_read_req_port_valid = 1'b0;
  assign playfield_read_req_port_payload = 5'h0;
  assign playfield_write_req_port_valid = 1'b0;
  assign playfield_write_req_port_payload = 5'h0;
  always @(*) begin
    playfield_row_sel = 22'h0;
    case(playfield_addr_access_port_payload)
      5'h0 : begin
        playfield_row_sel[0] = 1'b1;
      end
      5'h01 : begin
        playfield_row_sel[1] = 1'b1;
      end
      5'h02 : begin
        playfield_row_sel[2] = 1'b1;
      end
      5'h03 : begin
        playfield_row_sel[3] = 1'b1;
      end
      5'h04 : begin
        playfield_row_sel[4] = 1'b1;
      end
      5'h05 : begin
        playfield_row_sel[5] = 1'b1;
      end
      5'h06 : begin
        playfield_row_sel[6] = 1'b1;
      end
      5'h07 : begin
        playfield_row_sel[7] = 1'b1;
      end
      5'h08 : begin
        playfield_row_sel[8] = 1'b1;
      end
      5'h09 : begin
        playfield_row_sel[9] = 1'b1;
      end
      5'h0a : begin
        playfield_row_sel[10] = 1'b1;
      end
      5'h0b : begin
        playfield_row_sel[11] = 1'b1;
      end
      5'h0c : begin
        playfield_row_sel[12] = 1'b1;
      end
      5'h0d : begin
        playfield_row_sel[13] = 1'b1;
      end
      5'h0e : begin
        playfield_row_sel[14] = 1'b1;
      end
      5'h0f : begin
        playfield_row_sel[15] = 1'b1;
      end
      5'h10 : begin
        playfield_row_sel[16] = 1'b1;
      end
      5'h11 : begin
        playfield_row_sel[17] = 1'b1;
      end
      5'h12 : begin
        playfield_row_sel[18] = 1'b1;
      end
      5'h13 : begin
        playfield_row_sel[19] = 1'b1;
      end
      5'h14 : begin
        playfield_row_sel[20] = 1'b1;
      end
      5'h15 : begin
        playfield_row_sel[21] = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign playfield_address_beyond_limit = (5'h15 < playfield_addr_access_port_payload);
  assign temp_playfield_region_0 = 220'h0;
  assign temp_playfield_count = 5'h0;
  assign temp_playfield_count_1 = 5'h01;
  assign temp_playfield_count_2 = 5'h01;
  assign temp_playfield_count_3 = 5'h02;
  assign temp_playfield_count_4 = 5'h01;
  assign temp_playfield_count_5 = 5'h02;
  assign temp_playfield_count_6 = 5'h02;
  assign temp_playfield_count_7 = 5'h03;
  assign playfield_isRowFull = (|playfield_ones);
  assign playfield_lowestOne = (playfield_ones & (~ temp_playfield_lowestOne));
  assign playfield_rows_to_clear = (playfield_lowestOne - 22'h000001);
  assign score_val_valid = (playfield_lock_score_1d || ((! game_restart) && game_restart_regNext));
  assign score_val_payload = playfield_total_score;
  assign flow_read_req = 1'b0;
  always @(*) begin
    flow_row_occuppied[0] = (|flow_region_0);
    flow_row_occuppied[1] = (|flow_region_1);
    flow_row_occuppied[2] = (|flow_region_2);
    flow_row_occuppied[3] = (|flow_region_3);
  end

  assign collision_checker_is_collision_valid = ((! collision_checker_collision_bits_valid) && collision_checker_collision_bits_valid_regNext);
  assign collision_checker_is_collision_payload = collision_checker_check_status;
  assign src_0_valid = playfield_dataout_stage_valid;
  assign src_0_payload = playfield_dataout_stage_payload;
  assign row_val_valid = (src_0_valid && output_en);
  always @(*) begin
    row_val_payload = src_0_payload;
    if((src_0_valid && src_1_valid)) begin
      row_val_payload = row_merged;
    end
  end

  assign row_merged = (src_0_payload | src_1_payload);
  assign row_out_done = ((! src_0_valid) && src_0_valid_regNext);
  assign locker_readout = locker_region_spinal_port1;
  assign locker_readou_is_done = ((! locker_addr_access_port_valid) && locker_addr_access_port_valid_regNext);
  assign dma_playfield_dma_counter_is_last = (dma_playfield_dma_req_counter == dma_playfield_dma_word_count);
  assign dma_playfield_dma_trig = (dma_playfield_dma_start && (! dma_playfield_dma_start_regNext));
  assign playfield_addr_access_port_valid = dma_playfield_dma_req_valid;
  assign playfield_addr_access_port_payload = (dma_playfield_dma_req_counter + dma_playfield_dma_base_addr);
  assign dma_playfield_dma_channel_0_data_in_valid = dma_playfield_dma_channel_0_valid;
  assign dma_playfield_dma_channel_0_data_in_payload = dma_playfield_dma_channel_0_payload;
  assign dma_playfield_dma_channel_0_data_inter_valid = (dma_playfield_dma_channel_0_data_in_valid && dma_playfield_dma_channel_0_enable);
  assign dma_playfield_dma_channel_0_data_inter_payload = dma_playfield_dma_channel_0_data_in_payload;
  assign dma_playfield_dma_channel_0_data_out_valid = dma_playfield_dma_channel_0_data_inter_valid;
  assign dma_playfield_dma_channel_0_data_out_payload = dma_playfield_dma_channel_0_data_inter_payload;
  assign dma_playfield_dma_channel_1_data_in_valid = dma_playfield_dma_channel_1_valid;
  assign dma_playfield_dma_channel_1_data_in_payload = dma_playfield_dma_channel_1_payload;
  assign dma_playfield_dma_channel_1_data_inter_valid = (dma_playfield_dma_channel_1_data_in_valid && dma_playfield_dma_channel_1_enable);
  assign dma_playfield_dma_channel_1_data_inter_payload = dma_playfield_dma_channel_1_data_in_payload;
  assign dma_playfield_dma_channel_1_data_out_valid = dma_playfield_dma_channel_1_data_inter_valid;
  assign dma_playfield_dma_channel_1_data_out_payload = dma_playfield_dma_channel_1_data_inter_payload;
  assign dma_playfield_dma_channel_2_data_in_valid = dma_playfield_dma_channel_2_valid;
  assign dma_playfield_dma_channel_2_data_in_payload = dma_playfield_dma_channel_2_payload;
  assign dma_playfield_dma_channel_2_data_inter_valid = (dma_playfield_dma_channel_2_data_in_valid && dma_playfield_dma_channel_2_enable);
  assign dma_playfield_dma_channel_2_data_inter_payload = dma_playfield_dma_channel_2_data_in_payload;
  assign dma_playfield_dma_channel_2_data_out_valid = dma_playfield_dma_channel_2_data_inter_valid;
  assign dma_playfield_dma_channel_2_data_out_payload = dma_playfield_dma_channel_2_data_inter_payload;
  assign dma_playfield_dma_channel_0_valid = dma_playfield_dma_req_valid_1d;
  assign dma_playfield_dma_channel_0_payload = dma_playfield_dma_source_0;
  assign dma_playfield_dma_sink_0_valid = dma_playfield_dma_channel_0_data_out_valid;
  assign dma_playfield_dma_sink_0_payload = dma_playfield_dma_channel_0_data_out_payload;
  assign dma_playfield_dma_channel_1_valid = dma_playfield_dma_req_valid_1d;
  assign dma_playfield_dma_channel_1_payload = dma_playfield_dma_source_0;
  assign dma_playfield_dma_sink_1_valid = dma_playfield_dma_channel_1_data_out_valid;
  assign dma_playfield_dma_sink_1_payload = dma_playfield_dma_channel_1_data_out_payload;
  assign dma_playfield_dma_channel_2_valid = dma_playfield_dma_req_valid;
  assign dma_playfield_dma_channel_2_payload = dma_playfield_dma_source_1;
  assign dma_playfield_dma_sink_2_valid = dma_playfield_dma_channel_2_data_out_valid;
  assign dma_playfield_dma_sink_2_payload = dma_playfield_dma_channel_2_data_out_payload;
  assign dma_playfield_dma_source_0 = playfield_readout;
  assign dma_playfield_dma_source_1 = src_2_payload;
  assign collision_checker_src_0_valid = dma_playfield_dma_sink_0_valid;
  assign collision_checker_src_0_payload = dma_playfield_dma_sink_0_payload;
  assign playfield_dataout_valid = dma_playfield_dma_sink_1_valid;
  assign playfield_dataout_payload = dma_playfield_dma_sink_1_payload;
  assign playfield_write_in_port_valid = dma_playfield_dma_sink_2_valid;
  assign playfield_write_in_port_payload = dma_playfield_dma_sink_2_payload;
  assign dma_checker_dma_base_addr = 2'b00;
  assign dma_checker_dma_word_count = 2'b11;
  assign dma_checker_dma_counter_is_last = (dma_checker_dma_req_counter == dma_checker_dma_word_count);
  assign dma_checker_dma_trig = (dma_checker_dma_start && (! dma_checker_dma_start_regNext));
  assign checker_addr_access_port_valid = dma_checker_dma_req_valid;
  assign checker_addr_access_port_payload = (dma_checker_dma_req_counter + dma_checker_dma_base_addr);
  assign dma_checker_dma_channel_0_data_in_valid = dma_checker_dma_channel_0_valid;
  assign dma_checker_dma_channel_0_data_in_payload = dma_checker_dma_channel_0_payload;
  assign dma_checker_dma_channel_0_data_inter_valid = (dma_checker_dma_channel_0_data_in_valid && dma_checker_dma_channel_0_enable);
  assign dma_checker_dma_channel_0_data_inter_payload = dma_checker_dma_channel_0_data_in_payload;
  assign dma_checker_dma_channel_0_data_out_valid = dma_checker_dma_channel_0_data_inter_valid;
  assign dma_checker_dma_channel_0_data_out_payload = dma_checker_dma_channel_0_data_inter_payload;
  assign dma_checker_dma_channel_0_valid = dma_checker_dma_req_valid_1d;
  assign dma_checker_dma_channel_0_payload = dma_checker_dma_source_0;
  assign dma_checker_dma_sink_0_valid = dma_checker_dma_channel_0_data_out_valid;
  assign dma_checker_dma_sink_0_payload = dma_checker_dma_channel_0_data_out_payload;
  assign dma_checker_dma_source_0 = checker_readout;
  assign collision_checker_src_1_valid = dma_checker_dma_sink_0_valid;
  assign collision_checker_src_1_payload = dma_checker_dma_sink_0_payload;
  assign dma_flow_dma_base_addr = 2'b00;
  assign dma_flow_dma_word_count = 2'b11;
  assign dma_flow_dma_counter_is_last = (dma_flow_dma_req_counter == dma_flow_dma_word_count);
  assign dma_flow_dma_trig = (dma_flow_dma_start && (! dma_flow_dma_start_regNext));
  assign flow_addr_access_port_valid = dma_flow_dma_req_valid;
  assign flow_addr_access_port_payload = (dma_flow_dma_req_counter + dma_flow_dma_base_addr);
  assign dma_flow_dma_channel_0_data_in_valid = dma_flow_dma_channel_0_valid;
  assign dma_flow_dma_channel_0_data_in_payload = dma_flow_dma_channel_0_payload;
  assign dma_flow_dma_channel_0_data_inter_valid = (dma_flow_dma_channel_0_data_in_valid && dma_flow_dma_channel_0_enable);
  assign dma_flow_dma_channel_0_data_inter_payload = dma_flow_dma_channel_0_data_in_payload;
  assign dma_flow_dma_channel_0_data_out_valid = dma_flow_dma_channel_0_data_inter_valid;
  assign dma_flow_dma_channel_0_data_out_payload = dma_flow_dma_channel_0_data_inter_payload;
  assign dma_flow_dma_channel_0_valid = dma_flow_dma_req_valid_1d;
  assign dma_flow_dma_channel_0_payload = dma_flow_dma_source_0;
  assign dma_flow_dma_sink_0_valid = dma_flow_dma_channel_0_data_out_valid;
  assign dma_flow_dma_sink_0_payload = dma_flow_dma_channel_0_data_out_payload;
  assign dma_flow_dma_source_0 = flow_readout;
  assign src_1_valid = dma_flow_dma_sink_0_valid;
  assign src_1_payload = dma_flow_dma_sink_0_payload;
  assign dma_locker_dma_base_addr = 2'b00;
  assign dma_locker_dma_word_count = 2'b11;
  assign dma_locker_dma_counter_is_last = (dma_locker_dma_req_counter == dma_locker_dma_word_count);
  assign dma_locker_dma_trig = (dma_locker_dma_start && (! dma_locker_dma_start_regNext));
  assign locker_addr_access_port_valid = dma_locker_dma_req_valid;
  assign locker_addr_access_port_payload = (dma_locker_dma_req_counter + dma_locker_dma_base_addr);
  assign dma_locker_dma_channel_0_data_in_valid = dma_locker_dma_channel_0_valid;
  assign dma_locker_dma_channel_0_data_in_payload = dma_locker_dma_channel_0_payload;
  assign dma_locker_dma_channel_0_data_inter_valid = (dma_locker_dma_channel_0_data_in_valid && dma_locker_dma_channel_0_enable);
  assign dma_locker_dma_channel_0_data_inter_payload = dma_locker_dma_channel_0_data_in_payload;
  assign dma_locker_dma_channel_0_data_out_valid = dma_locker_dma_channel_0_data_inter_valid;
  assign dma_locker_dma_channel_0_data_out_payload = dma_locker_dma_channel_0_data_inter_payload;
  assign dma_locker_dma_channel_1_data_in_valid = dma_locker_dma_channel_1_valid;
  assign dma_locker_dma_channel_1_data_in_payload = dma_locker_dma_channel_1_payload;
  assign dma_locker_dma_channel_1_data_inter_valid = (dma_locker_dma_channel_1_data_in_valid && dma_locker_dma_channel_1_enable);
  assign dma_locker_dma_channel_1_data_inter_payload = dma_locker_dma_channel_1_data_in_payload;
  assign dma_locker_dma_channel_1_data_out_valid = dma_locker_dma_channel_1_data_inter_valid;
  assign dma_locker_dma_channel_1_data_out_payload = dma_locker_dma_channel_1_data_inter_payload;
  assign dma_locker_dma_channel_0_valid = dma_locker_dma_req_valid;
  assign dma_locker_dma_channel_0_payload = dma_locker_dma_source_0;
  assign dma_locker_dma_sink_0_valid = dma_locker_dma_channel_0_data_out_valid;
  assign dma_locker_dma_sink_0_payload = dma_locker_dma_channel_0_data_out_payload;
  assign dma_locker_dma_channel_1_valid = dma_locker_dma_req_valid_1d;
  assign dma_locker_dma_channel_1_payload = dma_locker_dma_source_1;
  assign dma_locker_dma_sink_1_valid = dma_locker_dma_channel_1_data_out_valid;
  assign dma_locker_dma_sink_1_payload = dma_locker_dma_channel_1_data_out_payload;
  assign dma_locker_dma_source_0 = row_merged;
  assign dma_locker_dma_source_1 = locker_readout;
  assign locker_data_in_port_valid = dma_locker_dma_sink_0_valid;
  assign locker_data_in_port_payload = dma_locker_dma_sink_0_payload;
  assign src_2_valid = dma_locker_dma_sink_1_valid;
  assign src_2_payload = dma_locker_dma_sink_1_payload;
  assign main_fsm_wantExit = 1'b0;
  assign main_fsm_wantKill = 1'b0;
  assign motion_is_allowed = (main_fsm_stateReg == main_fsm_WAIT_CONTROL);
  assign fsm_is_idle = (main_fsm_stateReg == main_fsm_IDLE);
  assign temp_flow_region_0 = 40'h0;
  assign main_fsm_onExit_READOUT = ((main_fsm_stateNext != main_fsm_READOUT) && (main_fsm_stateReg == main_fsm_READOUT));
  assign main_fsm_onExit_COLLISION_CHECK = ((main_fsm_stateNext != main_fsm_COLLISION_CHECK) && (main_fsm_stateReg == main_fsm_COLLISION_CHECK));
  assign main_fsm_onExit_PASS = ((main_fsm_stateNext != main_fsm_PASS) && (main_fsm_stateReg == main_fsm_PASS));
  assign main_fsm_onExit_WAIT_LOCKER_WRITE_DONE = ((main_fsm_stateNext != main_fsm_WAIT_LOCKER_WRITE_DONE) && (main_fsm_stateReg == main_fsm_WAIT_LOCKER_WRITE_DONE));
  assign main_fsm_onExit_WAIT_LOCKER_READ_DONE = ((main_fsm_stateNext != main_fsm_WAIT_LOCKER_READ_DONE) && (main_fsm_stateReg == main_fsm_WAIT_LOCKER_READ_DONE));
  assign main_fsm_onEntry_READOUT = ((main_fsm_stateNext == main_fsm_READOUT) && (main_fsm_stateReg != main_fsm_READOUT));
  assign main_fsm_onEntry_COLLISION_CHECK = ((main_fsm_stateNext == main_fsm_COLLISION_CHECK) && (main_fsm_stateReg != main_fsm_COLLISION_CHECK));
  assign main_fsm_onEntry_PASS = ((main_fsm_stateNext == main_fsm_PASS) && (main_fsm_stateReg != main_fsm_PASS));
  assign main_fsm_onEntry_LOCKER_WRITE_0 = ((main_fsm_stateNext == main_fsm_LOCKER_WRITE_0) && (main_fsm_stateReg != main_fsm_LOCKER_WRITE_0));
  assign main_fsm_onEntry_LOCKER_READ = ((main_fsm_stateNext == main_fsm_LOCKER_READ) && (main_fsm_stateReg != main_fsm_LOCKER_READ));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      piece_valid <= 1'b0;
      action_1 <= ACTION_NO;
      piece_buffer_rot_cur <= 2'b00;
      piece_buffer_rot_backup <= 2'b00;
      checker_row <= 5'h0;
      checker_row_backup <= 5'h0;
      playfield_region_0 <= 10'h0;
      playfield_region_1 <= 10'h0;
      playfield_region_2 <= 10'h0;
      playfield_region_3 <= 10'h0;
      playfield_region_4 <= 10'h0;
      playfield_region_5 <= 10'h0;
      playfield_region_6 <= 10'h0;
      playfield_region_7 <= 10'h0;
      playfield_region_8 <= 10'h0;
      playfield_region_9 <= 10'h0;
      playfield_region_10 <= 10'h0;
      playfield_region_11 <= 10'h0;
      playfield_region_12 <= 10'h0;
      playfield_region_13 <= 10'h0;
      playfield_region_14 <= 10'h0;
      playfield_region_15 <= 10'h0;
      playfield_region_16 <= 10'h0;
      playfield_region_17 <= 10'h0;
      playfield_region_18 <= 10'h0;
      playfield_region_19 <= 10'h0;
      playfield_region_20 <= 10'h0;
      playfield_region_21 <= 10'h0;
      playfield_ones <= 22'h0;
      playfield_count <= 5'h0;
      playfield_total_score <= 10'h0;
      playfield_update_score_delay_1 <= 1'b0;
      playfield_lock_score <= 1'b0;
      playfield_lock_score_1d <= 1'b0;
      flow_row <= 5'h0;
      flow_region_0 <= 10'h0;
      flow_region_1 <= 10'h0;
      flow_region_2 <= 10'h0;
      flow_region_3 <= 10'h0;
      collision_checker_collision_bits_valid <= 1'b0;
      collision_checker_check_status <= 1'b0;
      collision_checker_collision_bits_valid_regNext <= 1'b0;
      playfield_dataout_stage_valid <= 1'b0;
      src_0_valid_regNext <= 1'b0;
      locker_addr_access_port_valid_regNext <= 1'b0;
      dma_playfield_dma_base_addr <= 5'h0;
      dma_playfield_dma_word_count <= 5'h03;
      dma_playfield_dma_req_counter <= 5'h0;
      dma_playfield_dma_start_regNext <= 1'b0;
      dma_playfield_dma_req_valid <= 1'b0;
      dma_playfield_dma_req_valid_regNext <= 1'b0;
      dma_playfield_dma_req_valid_1d <= 1'b0;
      dma_playfield_dma_channel_0_enable <= 1'b0;
      dma_playfield_dma_channel_1_enable <= 1'b0;
      dma_playfield_dma_channel_2_enable <= 1'b0;
      dma_checker_dma_req_counter <= 2'b00;
      dma_checker_dma_start_regNext <= 1'b0;
      dma_checker_dma_req_valid <= 1'b0;
      dma_checker_dma_req_valid_regNext <= 1'b0;
      dma_checker_dma_req_valid_1d <= 1'b0;
      dma_checker_dma_channel_0_enable <= 1'b0;
      dma_flow_dma_req_counter <= 2'b00;
      dma_flow_dma_start_regNext <= 1'b0;
      dma_flow_dma_req_valid <= 1'b0;
      dma_flow_dma_req_valid_regNext <= 1'b0;
      dma_flow_dma_req_valid_1d <= 1'b0;
      dma_flow_dma_channel_0_enable <= 1'b0;
      dma_locker_dma_req_counter <= 2'b00;
      dma_locker_dma_start_regNext <= 1'b0;
      dma_locker_dma_req_valid <= 1'b0;
      dma_locker_dma_req_valid_regNext <= 1'b0;
      dma_locker_dma_req_valid_1d <= 1'b0;
      dma_locker_dma_channel_0_enable <= 1'b0;
      dma_locker_dma_channel_1_enable <= 1'b0;
      main_fsm_will_goto_idle <= 1'b0;
      main_fsm_stateReg <= main_fsm_IDLE;
    end else begin
      piece_valid <= piece_in_valid;
      if(!playfield_address_beyond_limit) begin
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[0]) begin
            playfield_region_0 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[1]) begin
            playfield_region_1 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[2]) begin
            playfield_region_2 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[3]) begin
            playfield_region_3 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[4]) begin
            playfield_region_4 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[5]) begin
            playfield_region_5 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[6]) begin
            playfield_region_6 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[7]) begin
            playfield_region_7 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[8]) begin
            playfield_region_8 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[9]) begin
            playfield_region_9 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[10]) begin
            playfield_region_10 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[11]) begin
            playfield_region_11 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[12]) begin
            playfield_region_12 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[13]) begin
            playfield_region_13 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[14]) begin
            playfield_region_14 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[15]) begin
            playfield_region_15 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[16]) begin
            playfield_region_16 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[17]) begin
            playfield_region_17 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[18]) begin
            playfield_region_18 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[19]) begin
            playfield_region_19 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[20]) begin
            playfield_region_20 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[21]) begin
            playfield_region_21 <= playfield_write_in_port_payload;
          end
        end
      end
      if(game_restart) begin
        playfield_region_0 <= temp_playfield_region_0[9 : 0];
        playfield_region_1 <= temp_playfield_region_0[19 : 10];
        playfield_region_2 <= temp_playfield_region_0[29 : 20];
        playfield_region_3 <= temp_playfield_region_0[39 : 30];
        playfield_region_4 <= temp_playfield_region_0[49 : 40];
        playfield_region_5 <= temp_playfield_region_0[59 : 50];
        playfield_region_6 <= temp_playfield_region_0[69 : 60];
        playfield_region_7 <= temp_playfield_region_0[79 : 70];
        playfield_region_8 <= temp_playfield_region_0[89 : 80];
        playfield_region_9 <= temp_playfield_region_0[99 : 90];
        playfield_region_10 <= temp_playfield_region_0[109 : 100];
        playfield_region_11 <= temp_playfield_region_0[119 : 110];
        playfield_region_12 <= temp_playfield_region_0[129 : 120];
        playfield_region_13 <= temp_playfield_region_0[139 : 130];
        playfield_region_14 <= temp_playfield_region_0[149 : 140];
        playfield_region_15 <= temp_playfield_region_0[159 : 150];
        playfield_region_16 <= temp_playfield_region_0[169 : 160];
        playfield_region_17 <= temp_playfield_region_0[179 : 170];
        playfield_region_18 <= temp_playfield_region_0[189 : 180];
        playfield_region_19 <= temp_playfield_region_0[199 : 190];
        playfield_region_20 <= temp_playfield_region_0[209 : 200];
        playfield_region_21 <= temp_playfield_region_0[219 : 210];
      end
      playfield_ones[0] <= (&playfield_region_0);
      playfield_ones[1] <= (&playfield_region_1);
      playfield_ones[2] <= (&playfield_region_2);
      playfield_ones[3] <= (&playfield_region_3);
      playfield_ones[4] <= (&playfield_region_4);
      playfield_ones[5] <= (&playfield_region_5);
      playfield_ones[6] <= (&playfield_region_6);
      playfield_ones[7] <= (&playfield_region_7);
      playfield_ones[8] <= (&playfield_region_8);
      playfield_ones[9] <= (&playfield_region_9);
      playfield_ones[10] <= (&playfield_region_10);
      playfield_ones[11] <= (&playfield_region_11);
      playfield_ones[12] <= (&playfield_region_12);
      playfield_ones[13] <= (&playfield_region_13);
      playfield_ones[14] <= (&playfield_region_14);
      playfield_ones[15] <= (&playfield_region_15);
      playfield_ones[16] <= (&playfield_region_16);
      playfield_ones[17] <= (&playfield_region_17);
      playfield_ones[18] <= (&playfield_region_18);
      playfield_ones[19] <= (&playfield_region_19);
      playfield_ones[20] <= (&playfield_region_20);
      playfield_ones[21] <= (&playfield_region_21);
      playfield_count <= (temp_playfield_count_8 + temp_playfield_count_19);
      if((playfield_clear && playfield_rows_to_clear[0])) begin
        playfield_region_1 <= playfield_region_0;
      end
      if((playfield_clear && playfield_rows_to_clear[1])) begin
        playfield_region_2 <= playfield_region_1;
      end
      if((playfield_clear && playfield_rows_to_clear[2])) begin
        playfield_region_3 <= playfield_region_2;
      end
      if((playfield_clear && playfield_rows_to_clear[3])) begin
        playfield_region_4 <= playfield_region_3;
      end
      if((playfield_clear && playfield_rows_to_clear[4])) begin
        playfield_region_5 <= playfield_region_4;
      end
      if((playfield_clear && playfield_rows_to_clear[5])) begin
        playfield_region_6 <= playfield_region_5;
      end
      if((playfield_clear && playfield_rows_to_clear[6])) begin
        playfield_region_7 <= playfield_region_6;
      end
      if((playfield_clear && playfield_rows_to_clear[7])) begin
        playfield_region_8 <= playfield_region_7;
      end
      if((playfield_clear && playfield_rows_to_clear[8])) begin
        playfield_region_9 <= playfield_region_8;
      end
      if((playfield_clear && playfield_rows_to_clear[9])) begin
        playfield_region_10 <= playfield_region_9;
      end
      if((playfield_clear && playfield_rows_to_clear[10])) begin
        playfield_region_11 <= playfield_region_10;
      end
      if((playfield_clear && playfield_rows_to_clear[11])) begin
        playfield_region_12 <= playfield_region_11;
      end
      if((playfield_clear && playfield_rows_to_clear[12])) begin
        playfield_region_13 <= playfield_region_12;
      end
      if((playfield_clear && playfield_rows_to_clear[13])) begin
        playfield_region_14 <= playfield_region_13;
      end
      if((playfield_clear && playfield_rows_to_clear[14])) begin
        playfield_region_15 <= playfield_region_14;
      end
      if((playfield_clear && playfield_rows_to_clear[15])) begin
        playfield_region_16 <= playfield_region_15;
      end
      if((playfield_clear && playfield_rows_to_clear[16])) begin
        playfield_region_17 <= playfield_region_16;
      end
      if((playfield_clear && playfield_rows_to_clear[17])) begin
        playfield_region_18 <= playfield_region_17;
      end
      if((playfield_clear && playfield_rows_to_clear[18])) begin
        playfield_region_19 <= playfield_region_18;
      end
      if((playfield_clear && playfield_rows_to_clear[19])) begin
        playfield_region_20 <= playfield_region_19;
      end
      if((playfield_clear && playfield_rows_to_clear[20])) begin
        playfield_region_21 <= playfield_region_20;
      end
      if(playfield_clear) begin
        playfield_region_0 <= 10'h0;
      end
      playfield_update_score_delay_1 <= playfield_update_score;
      playfield_lock_score <= playfield_update_score_delay_1;
      playfield_lock_score_1d <= playfield_lock_score;
      if(game_restart) begin
        playfield_total_score <= 10'h0;
      end else begin
        if(playfield_lock_score) begin
          playfield_total_score <= (playfield_total_score + temp_playfield_total_score);
        end
      end
      if(flow_update) begin
        flow_region_0 <= checker_region_0;
        flow_region_1 <= checker_region_1;
        flow_region_2 <= checker_region_2;
        flow_region_3 <= checker_region_3;
        flow_row <= checker_row;
      end
      collision_checker_collision_bits_valid <= collision_checker_src_0_valid;
      if((collision_checker_collision_bits_valid && collision_checker_collision_bits_payload)) begin
        collision_checker_check_status <= 1'b1;
      end
      if(collision_checker_start) begin
        collision_checker_check_status <= 1'b0;
      end
      collision_checker_collision_bits_valid_regNext <= collision_checker_collision_bits_valid;
      playfield_dataout_stage_valid <= playfield_dataout_valid;
      src_0_valid_regNext <= src_0_valid;
      locker_addr_access_port_valid_regNext <= locker_addr_access_port_valid;
      dma_playfield_dma_start_regNext <= dma_playfield_dma_start;
      if(dma_playfield_dma_counter_is_last) begin
        dma_playfield_dma_req_valid <= 1'b0;
      end
      if(dma_playfield_dma_trig) begin
        dma_playfield_dma_req_valid <= 1'b1;
      end
      if(dma_playfield_dma_req_valid) begin
        dma_playfield_dma_req_counter <= (dma_playfield_dma_req_counter + 5'h01);
      end else begin
        if(((! dma_playfield_dma_req_valid) && dma_playfield_dma_req_valid_regNext)) begin
          dma_playfield_dma_req_counter <= 5'h0;
        end
      end
      dma_playfield_dma_req_valid_regNext <= dma_playfield_dma_req_valid;
      dma_playfield_dma_req_valid_1d <= dma_playfield_dma_req_valid;
      dma_checker_dma_start_regNext <= dma_checker_dma_start;
      if(dma_checker_dma_counter_is_last) begin
        dma_checker_dma_req_valid <= 1'b0;
      end
      if(dma_checker_dma_trig) begin
        dma_checker_dma_req_valid <= 1'b1;
      end
      if(dma_checker_dma_req_valid) begin
        dma_checker_dma_req_counter <= (dma_checker_dma_req_counter + 2'b01);
      end else begin
        if(((! dma_checker_dma_req_valid) && dma_checker_dma_req_valid_regNext)) begin
          dma_checker_dma_req_counter <= 2'b00;
        end
      end
      dma_checker_dma_req_valid_regNext <= dma_checker_dma_req_valid;
      dma_checker_dma_req_valid_1d <= dma_checker_dma_req_valid;
      dma_flow_dma_start_regNext <= dma_flow_dma_start;
      if(dma_flow_dma_counter_is_last) begin
        dma_flow_dma_req_valid <= 1'b0;
      end
      if(dma_flow_dma_trig) begin
        dma_flow_dma_req_valid <= 1'b1;
      end
      if(dma_flow_dma_req_valid) begin
        dma_flow_dma_req_counter <= (dma_flow_dma_req_counter + 2'b01);
      end else begin
        if(((! dma_flow_dma_req_valid) && dma_flow_dma_req_valid_regNext)) begin
          dma_flow_dma_req_counter <= 2'b00;
        end
      end
      dma_flow_dma_req_valid_regNext <= dma_flow_dma_req_valid;
      dma_flow_dma_req_valid_1d <= dma_flow_dma_req_valid;
      dma_locker_dma_start_regNext <= dma_locker_dma_start;
      if(dma_locker_dma_counter_is_last) begin
        dma_locker_dma_req_valid <= 1'b0;
      end
      if(dma_locker_dma_trig) begin
        dma_locker_dma_req_valid <= 1'b1;
      end
      if(dma_locker_dma_req_valid) begin
        dma_locker_dma_req_counter <= (dma_locker_dma_req_counter + 2'b01);
      end else begin
        if(((! dma_locker_dma_req_valid) && dma_locker_dma_req_valid_regNext)) begin
          dma_locker_dma_req_counter <= 2'b00;
        end
      end
      dma_locker_dma_req_valid_regNext <= dma_locker_dma_req_valid;
      dma_locker_dma_req_valid_1d <= dma_locker_dma_req_valid;
      main_fsm_stateReg <= main_fsm_stateNext;
      case(main_fsm_stateReg)
        main_fsm_READOUT : begin
        end
        main_fsm_LOAD_TO_CHECKER : begin
        end
        main_fsm_COLLISION_CHECK : begin
        end
        main_fsm_REPORT_COLLISION : begin
          if(!temp_when) begin
            if((action_1 == ACTION_ROTATE)) begin
              piece_buffer_rot_cur <= piece_buffer_rot_backup;
            end
          end
        end
        main_fsm_END_OF_COLLISION : begin
          action_1 <= ACTION_NO;
        end
        main_fsm_PASS : begin
          if(temp_when_1) begin
            checker_row_backup <= checker_row;
          end
          if(temp_when_2) begin
            piece_buffer_rot_backup <= piece_buffer_rot_cur;
          end
        end
        main_fsm_WAIT_CONTROL : begin
          if(move_in_left) begin
            if(!checker_overflowIfLeft) begin
              action_1 <= ACTION_LEFT;
            end
          end
          if(move_in_right) begin
            if(!checker_overflowIfRight) begin
              action_1 <= ACTION_RIGHT;
            end
          end
          if(move_in_down) begin
            if(!checker_overflowIfDown) begin
              checker_row <= (checker_row + 5'h01);
              action_1 <= ACTION_DOWN;
            end
          end
          if(move_in_rotate) begin
            piece_buffer_rot_cur <= (piece_buffer_rot_cur + 2'b01);
          end
        end
        main_fsm_ROTATION : begin
          if(!temp_when_3) begin
            action_1 <= ACTION_ROTATE;
          end
        end
        main_fsm_PRE_CHECK : begin
        end
        main_fsm_LOCKER_WRITE_0 : begin
        end
        main_fsm_LOCKER_WRITE_1 : begin
          dma_locker_dma_channel_0_enable <= 1'b1;
        end
        main_fsm_WAIT_LOCKER_WRITE_DONE : begin
        end
        main_fsm_LOCKER_READ : begin
          dma_playfield_dma_channel_2_enable <= 1'b1;
          dma_playfield_dma_base_addr <= flow_row;
          dma_playfield_dma_word_count <= 5'h03;
        end
        main_fsm_WAIT_LOCKER_READ_DONE : begin
        end
        main_fsm_CLEAR_REGION : begin
          piece_buffer_rot_cur <= 2'b00;
          piece_buffer_rot_backup <= 2'b00;
          flow_region_0 <= temp_flow_region_0[9 : 0];
          flow_region_1 <= temp_flow_region_0[19 : 10];
          flow_region_2 <= temp_flow_region_0[29 : 20];
          flow_region_3 <= temp_flow_region_0[39 : 30];
          flow_row <= 5'h0;
          checker_row <= 5'h0;
          checker_row_backup <= 5'h0;
        end
        main_fsm_CHECK_ROW_FULL : begin
          if(!playfield_isRowFull) begin
            main_fsm_will_goto_idle <= 1'b1;
          end
        end
        main_fsm_ROW_REMOVE : begin
        end
        main_fsm_ROW_REMOVE_DONE : begin
        end
        default : begin
          dma_flow_dma_channel_0_enable <= 1'b1;
          dma_checker_dma_channel_0_enable <= 1'b1;
          main_fsm_will_goto_idle <= 1'b0;
          if(piece_valid) begin
            action_1 <= ACTION_PLACE;
          end
        end
      endcase
      if(main_fsm_onExit_READOUT) begin
        dma_playfield_dma_channel_1_enable <= 1'b0;
      end
      if(main_fsm_onExit_COLLISION_CHECK) begin
        dma_playfield_dma_channel_0_enable <= 1'b0;
      end
      if(main_fsm_onExit_PASS) begin
        action_1 <= ACTION_NO;
      end
      if(main_fsm_onExit_WAIT_LOCKER_WRITE_DONE) begin
        dma_playfield_dma_channel_1_enable <= 1'b0;
        dma_locker_dma_channel_0_enable <= 1'b0;
      end
      if(main_fsm_onExit_WAIT_LOCKER_READ_DONE) begin
        dma_locker_dma_channel_1_enable <= 1'b0;
        dma_playfield_dma_channel_2_enable <= 1'b0;
      end
      if(main_fsm_onEntry_READOUT) begin
        dma_playfield_dma_channel_1_enable <= 1'b1;
        dma_playfield_dma_base_addr <= 5'h0;
        dma_playfield_dma_word_count <= 5'h15;
      end
      if(main_fsm_onEntry_COLLISION_CHECK) begin
        dma_playfield_dma_channel_0_enable <= 1'b1;
        dma_playfield_dma_base_addr <= checker_row;
        dma_playfield_dma_word_count <= 5'h03;
      end
      if(main_fsm_onEntry_LOCKER_WRITE_0) begin
        dma_playfield_dma_channel_1_enable <= 1'b1;
        dma_playfield_dma_base_addr <= flow_row;
        dma_playfield_dma_word_count <= 5'h03;
      end
      if(main_fsm_onEntry_LOCKER_READ) begin
        dma_locker_dma_channel_1_enable <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if(piece_in_valid) begin
      piece_payload <= piece_in_payload;
    end
    if(piece_valid) begin
      case(piece_payload)
        TYPE_1_I : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01e0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_1 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0040;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h01e0;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0080;
        end
        TYPE_1_J : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0100;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0040;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_L : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0040;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_2 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0100;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_O : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_3_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_S : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0180;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0100;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_T : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        default : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0180;
          piece_buffer_pieces_0_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_2_region_extra_2 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0100;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
      endcase
    end
    if(piece_buffer_left_shift_all) begin
      piece_buffer_pieces_0_region_extra_0 <= (piece_buffer_pieces_0_region_extra_0 <<< 1);
      piece_buffer_pieces_0_region_extra_1 <= (piece_buffer_pieces_0_region_extra_1 <<< 1);
      piece_buffer_pieces_0_region_extra_2 <= (piece_buffer_pieces_0_region_extra_2 <<< 1);
      piece_buffer_pieces_0_region_extra_3 <= (piece_buffer_pieces_0_region_extra_3 <<< 1);
      piece_buffer_pieces_1_region_extra_0 <= (piece_buffer_pieces_1_region_extra_0 <<< 1);
      piece_buffer_pieces_1_region_extra_1 <= (piece_buffer_pieces_1_region_extra_1 <<< 1);
      piece_buffer_pieces_1_region_extra_2 <= (piece_buffer_pieces_1_region_extra_2 <<< 1);
      piece_buffer_pieces_1_region_extra_3 <= (piece_buffer_pieces_1_region_extra_3 <<< 1);
      piece_buffer_pieces_2_region_extra_0 <= (piece_buffer_pieces_2_region_extra_0 <<< 1);
      piece_buffer_pieces_2_region_extra_1 <= (piece_buffer_pieces_2_region_extra_1 <<< 1);
      piece_buffer_pieces_2_region_extra_2 <= (piece_buffer_pieces_2_region_extra_2 <<< 1);
      piece_buffer_pieces_2_region_extra_3 <= (piece_buffer_pieces_2_region_extra_3 <<< 1);
      piece_buffer_pieces_3_region_extra_0 <= (piece_buffer_pieces_3_region_extra_0 <<< 1);
      piece_buffer_pieces_3_region_extra_1 <= (piece_buffer_pieces_3_region_extra_1 <<< 1);
      piece_buffer_pieces_3_region_extra_2 <= (piece_buffer_pieces_3_region_extra_2 <<< 1);
      piece_buffer_pieces_3_region_extra_3 <= (piece_buffer_pieces_3_region_extra_3 <<< 1);
    end
    if(piece_buffer_right_shift_all) begin
      piece_buffer_pieces_0_region_extra_0 <= (piece_buffer_pieces_0_region_extra_0 >>> 1);
      piece_buffer_pieces_0_region_extra_1 <= (piece_buffer_pieces_0_region_extra_1 >>> 1);
      piece_buffer_pieces_0_region_extra_2 <= (piece_buffer_pieces_0_region_extra_2 >>> 1);
      piece_buffer_pieces_0_region_extra_3 <= (piece_buffer_pieces_0_region_extra_3 >>> 1);
      piece_buffer_pieces_1_region_extra_0 <= (piece_buffer_pieces_1_region_extra_0 >>> 1);
      piece_buffer_pieces_1_region_extra_1 <= (piece_buffer_pieces_1_region_extra_1 >>> 1);
      piece_buffer_pieces_1_region_extra_2 <= (piece_buffer_pieces_1_region_extra_2 >>> 1);
      piece_buffer_pieces_1_region_extra_3 <= (piece_buffer_pieces_1_region_extra_3 >>> 1);
      piece_buffer_pieces_2_region_extra_0 <= (piece_buffer_pieces_2_region_extra_0 >>> 1);
      piece_buffer_pieces_2_region_extra_1 <= (piece_buffer_pieces_2_region_extra_1 >>> 1);
      piece_buffer_pieces_2_region_extra_2 <= (piece_buffer_pieces_2_region_extra_2 >>> 1);
      piece_buffer_pieces_2_region_extra_3 <= (piece_buffer_pieces_2_region_extra_3 >>> 1);
      piece_buffer_pieces_3_region_extra_0 <= (piece_buffer_pieces_3_region_extra_0 >>> 1);
      piece_buffer_pieces_3_region_extra_1 <= (piece_buffer_pieces_3_region_extra_1 >>> 1);
      piece_buffer_pieces_3_region_extra_2 <= (piece_buffer_pieces_3_region_extra_2 >>> 1);
      piece_buffer_pieces_3_region_extra_3 <= (piece_buffer_pieces_3_region_extra_3 >>> 1);
    end
    checker_readout <= temp_checker_readout;
    if(playfield_address_beyond_limit) begin
      playfield_readout <= 10'h3ff;
    end else begin
      if(playfield_row_sel[0]) begin
        playfield_readout <= playfield_region_0;
      end
      if(playfield_row_sel[1]) begin
        playfield_readout <= playfield_region_1;
      end
      if(playfield_row_sel[2]) begin
        playfield_readout <= playfield_region_2;
      end
      if(playfield_row_sel[3]) begin
        playfield_readout <= playfield_region_3;
      end
      if(playfield_row_sel[4]) begin
        playfield_readout <= playfield_region_4;
      end
      if(playfield_row_sel[5]) begin
        playfield_readout <= playfield_region_5;
      end
      if(playfield_row_sel[6]) begin
        playfield_readout <= playfield_region_6;
      end
      if(playfield_row_sel[7]) begin
        playfield_readout <= playfield_region_7;
      end
      if(playfield_row_sel[8]) begin
        playfield_readout <= playfield_region_8;
      end
      if(playfield_row_sel[9]) begin
        playfield_readout <= playfield_region_9;
      end
      if(playfield_row_sel[10]) begin
        playfield_readout <= playfield_region_10;
      end
      if(playfield_row_sel[11]) begin
        playfield_readout <= playfield_region_11;
      end
      if(playfield_row_sel[12]) begin
        playfield_readout <= playfield_region_12;
      end
      if(playfield_row_sel[13]) begin
        playfield_readout <= playfield_region_13;
      end
      if(playfield_row_sel[14]) begin
        playfield_readout <= playfield_region_14;
      end
      if(playfield_row_sel[15]) begin
        playfield_readout <= playfield_region_15;
      end
      if(playfield_row_sel[16]) begin
        playfield_readout <= playfield_region_16;
      end
      if(playfield_row_sel[17]) begin
        playfield_readout <= playfield_region_17;
      end
      if(playfield_row_sel[18]) begin
        playfield_readout <= playfield_region_18;
      end
      if(playfield_row_sel[19]) begin
        playfield_readout <= playfield_region_19;
      end
      if(playfield_row_sel[20]) begin
        playfield_readout <= playfield_region_20;
      end
      if(playfield_row_sel[21]) begin
        playfield_readout <= playfield_region_21;
      end
    end
    game_restart_regNext <= game_restart;
    flow_readout <= temp_flow_readout;
    collision_checker_collision_bits_payload <= (|(collision_checker_src_0_payload & collision_checker_src_1_payload));
    playfield_dataout_stage_payload <= playfield_dataout_payload;
    if(load_piece) begin
      checker_region_0 <= temp_checker_region_0;
    end
    if(checker_right_shift) begin
      checker_region_0 <= (checker_region_0 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_0 <= (checker_region_0 <<< 1);
    end
    if(checker_restore) begin
      checker_region_0 <= flow_region_0;
    end
    if(load_piece) begin
      checker_region_1 <= temp_checker_region_1;
    end
    if(checker_right_shift) begin
      checker_region_1 <= (checker_region_1 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_1 <= (checker_region_1 <<< 1);
    end
    if(checker_restore) begin
      checker_region_1 <= flow_region_1;
    end
    if(load_piece) begin
      checker_region_2 <= temp_checker_region_2;
    end
    if(checker_right_shift) begin
      checker_region_2 <= (checker_region_2 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_2 <= (checker_region_2 <<< 1);
    end
    if(checker_restore) begin
      checker_region_2 <= flow_region_2;
    end
    if(load_piece) begin
      checker_region_3 <= temp_checker_region_3;
    end
    if(checker_right_shift) begin
      checker_region_3 <= (checker_region_3 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_3 <= (checker_region_3 <<< 1);
    end
    if(checker_restore) begin
      checker_region_3 <= flow_region_3;
    end
  end


endmodule

module seven_bag_rng (
  input  wire          io_enable,
  output reg           io_shape_valid,
  output wire [2:0]    io_shape_payload,
  input  wire          clk,
  input  wire          reset
);
  localparam fsm_IDLE = 3'd0;
  localparam fsm_CHECK = 3'd1;
  localparam fsm_OUTPUT_1 = 3'd2;
  localparam fsm_DONE = 3'd3;
  localparam fsm_SHIFT = 3'd4;
  localparam fsm_ELEMENT = 3'd5;

  reg        [5:0]    lfsr;
  reg        [2:0]    generatedNumbers_0;
  reg        [2:0]    generatedNumbers_1;
  reg        [2:0]    generatedNumbers_2;
  reg        [2:0]    generatedNumbers_3;
  reg        [2:0]    generatedNumbers_4;
  reg        [2:0]    generatedNumbers_5;
  reg        [2:0]    generatedNumbers_6;
  reg        [2:0]    generatedNumbers_7;
  reg        [2:0]    count;
  reg                 existedOrInvalid;
  reg                 shift;
  wire       [2:0]    nextNumber;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire       [7:0]    temp_1;
  `ifndef SYNTHESIS
  reg [63:0] fsm_stateReg_string;
  reg [63:0] fsm_stateNext_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_IDLE : fsm_stateReg_string = "IDLE    ";
      fsm_CHECK : fsm_stateReg_string = "CHECK   ";
      fsm_OUTPUT_1 : fsm_stateReg_string = "OUTPUT_1";
      fsm_DONE : fsm_stateReg_string = "DONE    ";
      fsm_SHIFT : fsm_stateReg_string = "SHIFT   ";
      fsm_ELEMENT : fsm_stateReg_string = "ELEMENT ";
      default : fsm_stateReg_string = "????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_IDLE : fsm_stateNext_string = "IDLE    ";
      fsm_CHECK : fsm_stateNext_string = "CHECK   ";
      fsm_OUTPUT_1 : fsm_stateNext_string = "OUTPUT_1";
      fsm_DONE : fsm_stateNext_string = "DONE    ";
      fsm_SHIFT : fsm_stateNext_string = "SHIFT   ";
      fsm_ELEMENT : fsm_stateNext_string = "ELEMENT ";
      default : fsm_stateNext_string = "????????";
    endcase
  end
  `endif

  assign nextNumber = lfsr[2 : 0];
  assign io_shape_payload = nextNumber;
  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    shift = 1'b0;
    io_shape_valid = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_CHECK : begin
        if(existedOrInvalid) begin
          fsm_stateNext = fsm_SHIFT;
        end else begin
          fsm_stateNext = fsm_OUTPUT_1;
        end
      end
      fsm_OUTPUT_1 : begin
        io_shape_valid = 1'b1;
        shift = 1'b1;
        fsm_stateNext = fsm_DONE;
      end
      fsm_DONE : begin
        fsm_stateNext = fsm_IDLE;
      end
      fsm_SHIFT : begin
        shift = 1'b1;
        fsm_stateNext = fsm_ELEMENT;
      end
      fsm_ELEMENT : begin
        fsm_stateNext = fsm_CHECK;
      end
      default : begin
        if(io_enable) begin
          fsm_stateNext = fsm_CHECK;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_IDLE;
    end
  end

  assign fsm_wantKill = 1'b0;
  assign temp_1 = ({7'd0,1'b1} <<< count);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lfsr <= 6'h2d;
      generatedNumbers_0 <= 3'b111;
      generatedNumbers_1 <= 3'b111;
      generatedNumbers_2 <= 3'b111;
      generatedNumbers_3 <= 3'b111;
      generatedNumbers_4 <= 3'b111;
      generatedNumbers_5 <= 3'b111;
      generatedNumbers_6 <= 3'b111;
      generatedNumbers_7 <= 3'b111;
      count <= 3'b000;
      fsm_stateReg <= fsm_IDLE;
    end else begin
      if(shift) begin
        lfsr <= {lfsr[4 : 0],(lfsr[5] ^ lfsr[3])};
      end
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! (io_shape_valid && (io_shape_payload == 3'b111)))); // seven_bag_rng.scala:L41
        `else
          if(!(! (io_shape_valid && (io_shape_payload == 3'b111)))) begin
            $display("FAILURE seven_bag_rng: valid shape must never be 7"); // seven_bag_rng.scala:L41
            $finish;
          end
        `endif
      `endif
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_CHECK : begin
        end
        fsm_OUTPUT_1 : begin
          if(temp_1[0]) begin
            generatedNumbers_0 <= nextNumber;
          end
          if(temp_1[1]) begin
            generatedNumbers_1 <= nextNumber;
          end
          if(temp_1[2]) begin
            generatedNumbers_2 <= nextNumber;
          end
          if(temp_1[3]) begin
            generatedNumbers_3 <= nextNumber;
          end
          if(temp_1[4]) begin
            generatedNumbers_4 <= nextNumber;
          end
          if(temp_1[5]) begin
            generatedNumbers_5 <= nextNumber;
          end
          if(temp_1[6]) begin
            generatedNumbers_6 <= nextNumber;
          end
          if(temp_1[7]) begin
            generatedNumbers_7 <= nextNumber;
          end
          count <= (count + 3'b001);
        end
        fsm_DONE : begin
          if((count == 3'b111)) begin
            count <= 3'b000;
            generatedNumbers_0 <= 3'b111;
            generatedNumbers_1 <= 3'b111;
            generatedNumbers_2 <= 3'b111;
            generatedNumbers_3 <= 3'b111;
            generatedNumbers_4 <= 3'b111;
            generatedNumbers_5 <= 3'b111;
            generatedNumbers_6 <= 3'b111;
          end
        end
        fsm_SHIFT : begin
        end
        fsm_ELEMENT : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    existedOrInvalid <= 1'b0;
    if((nextNumber == generatedNumbers_0)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_1)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_2)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_3)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_4)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_5)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_6)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_7)) begin
      existedOrInvalid <= 1'b1;
    end
  end


endmodule
