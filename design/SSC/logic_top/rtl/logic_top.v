// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : logic_top
// Git hash  : 2ec2bc472caa8ebc02a6bc14d322ce01ad62ad20

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
  input  wire          draw_field_done,
  input  wire          screen_is_ready,
  input  wire          vga_sof,
  output wire          ctrl_allowed,
  output wire          softReset,
  output wire          game_restart,
  input  wire          clk,
  input  wire          reset
);
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;

  wire                playfield_inst_piece_in_valid;
  wire                piece_gen_inst_io_shape_valid;
  wire       [2:0]    piece_gen_inst_io_shape_payload;
  wire                playfield_inst_status_valid;
  wire                playfield_inst_status_payload;
  wire                playfield_inst_row_val_valid;
  wire       [9:0]    playfield_inst_row_val_payload;
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
  wire                controller_inst_read;
  wire       [9:0]    temp_temp_motion_voted_2;
  wire       [9:0]    temp_temp_motion_voted_2_1;
  wire       [4:0]    temp_temp_motion_voted_2_2;
  reg        [4:0]    motion_request;
  wire       [4:0]    priority_1;
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
  reg                 status_stage_valid;
  reg                 status_stage_payload;
  wire       [3:0]    temp_piece_in_valid;
  wire       [2:0]    temp_piece_in_payload;
  `ifndef SYNTHESIS
  reg [7:0] temp_piece_in_payload_string;
  `endif


  assign temp_temp_motion_voted_2 = (temp_motion_voted_1 - temp_temp_motion_voted_2_1);
  assign temp_temp_motion_voted_2_2 = priority_1;
  assign temp_temp_motion_voted_2_1 = {5'd0, temp_temp_motion_voted_2_2};
  seven_bag_rng piece_gen_inst (
    .io_enable        (controller_inst_gen_piece_en        ), //i
    .io_shape_valid   (piece_gen_inst_io_shape_valid       ), //o
    .io_shape_payload (piece_gen_inst_io_shape_payload[2:0]), //o
    .clk              (clk                                 ), //i
    .reset            (reset                               )  //i
  );
  playfield playfield_inst (
    .piece_in_valid    (playfield_inst_piece_in_valid      ), //i
    .piece_in_payload  (temp_piece_in_payload[2:0]         ), //i
    .status_valid      (playfield_inst_status_valid        ), //o
    .status_payload    (playfield_inst_status_payload      ), //o
    .move_in_left      (controller_inst_move_out_left      ), //i
    .move_in_right     (controller_inst_move_out_right     ), //i
    .move_in_rotate    (controller_inst_move_out_rotate    ), //i
    .move_in_down      (controller_inst_move_out_down      ), //i
    .lock              (controller_inst_lock               ), //i
    .game_restart      (controller_inst_game_restart       ), //i
    .row_val_valid     (playfield_inst_row_val_valid       ), //o
    .row_val_payload   (playfield_inst_row_val_payload[9:0]), //o
    .motion_is_allowed (playfield_inst_motion_is_allowed   ), //o
    .fsm_is_idle       (playfield_inst_fsm_is_idle         ), //o
    .clk               (clk                                ), //i
    .reset             (reset                              )  //i
  );
  controller controller_inst (
    .game_start               (game_start                      ), //i
    .move_left                (move_left_1                     ), //i
    .move_right               (move_right_1                    ), //i
    .move_down                (move_down_1                     ), //i
    .rotate                   (rotate_1                        ), //i
    .drop                     (drop_1                          ), //i
    .screen_is_ready          (screen_is_ready                 ), //i
    .playfiedl_in_idle        (playfield_inst_fsm_is_idle      ), //i
    .playfiedl_allow_action   (playfield_inst_motion_is_allowed), //i
    .game_restart             (controller_inst_game_restart    ), //o
    .softReset                (controller_inst_softReset       ), //o
    .gen_piece_en             (controller_inst_gen_piece_en    ), //o
    .collision_status_valid   (status_stage_valid              ), //i
    .collision_status_payload (status_stage_payload            ), //i
    .move_out_left            (controller_inst_move_out_left   ), //o
    .move_out_right           (controller_inst_move_out_right  ), //o
    .move_out_rotate          (controller_inst_move_out_rotate ), //o
    .move_out_down            (controller_inst_move_out_down   ), //o
    .lock                     (controller_inst_lock            ), //o
    .read                     (controller_inst_read            ), //o
    .clk                      (clk                             ), //i
    .reset                    (reset                           )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(temp_piece_in_payload)
      I : temp_piece_in_payload_string = "I";
      J : temp_piece_in_payload_string = "J";
      L : temp_piece_in_payload_string = "L";
      O : temp_piece_in_payload_string = "O";
      S : temp_piece_in_payload_string = "S";
      T : temp_piece_in_payload_string = "T";
      Z : temp_piece_in_payload_string = "Z";
      default : temp_piece_in_payload_string = "?";
    endcase
  end
  `endif

  assign priority_1 = 5'h0;
  assign temp_motion_voted = motion_request;
  assign temp_motion_voted_1 = {temp_motion_voted,temp_motion_voted};
  assign temp_motion_voted_2 = (temp_motion_voted_1 & (~ temp_temp_motion_voted_2));
  assign motion_voted = (temp_motion_voted_2[9 : 5] | temp_motion_voted_2[4 : 0]);
  assign drop_1 = motion_voted[0];
  assign move_down_1 = motion_voted[1];
  assign move_left_1 = motion_voted[2];
  assign move_right_1 = motion_voted[3];
  assign rotate_1 = motion_voted[4];
  assign temp_piece_in_valid = {piece_gen_inst_io_shape_payload,piece_gen_inst_io_shape_valid};
  assign playfield_inst_piece_in_valid = temp_piece_in_valid[0];
  assign temp_piece_in_payload = temp_piece_in_valid[3 : 1];
  assign softReset = controller_inst_softReset;
  assign game_restart = controller_inst_game_restart;
  assign row_val_valid = playfield_inst_row_val_valid;
  assign row_val_payload = playfield_inst_row_val_payload;
  assign ctrl_allowed = playfield_inst_motion_is_allowed;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      motion_request <= 5'h0;
      drop_regNext <= 1'b0;
      move_down_regNext <= 1'b0;
      move_left_regNext <= 1'b0;
      move_right_regNext <= 1'b0;
      rotate_regNext <= 1'b0;
      status_stage_valid <= 1'b0;
    end else begin
      drop_regNext <= drop;
      motion_request[0] <= (drop && (! drop_regNext));
      move_down_regNext <= move_down;
      motion_request[1] <= (move_down && (! move_down_regNext));
      move_left_regNext <= move_left;
      motion_request[2] <= (move_left && (! move_left_regNext));
      move_right_regNext <= move_right;
      motion_request[3] <= (move_right && (! move_right_regNext));
      rotate_regNext <= rotate;
      motion_request[4] <= (rotate && (! rotate_regNext));
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
  input  wire          playfiedl_in_idle,
  input  wire          playfiedl_allow_action,
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
  output wire          read,
  input  wire          clk,
  input  wire          reset
);
  localparam IDLE = 4'd0;
  localparam GAME_START = 4'd1;
  localparam RANDOM_GEN = 4'd2;
  localparam PLACE = 4'd3;
  localparam END_1 = 4'd4;
  localparam FALLING = 4'd5;
  localparam DOWN = 4'd6;
  localparam DROP = 4'd7;
  localparam MOVE = 4'd8;
  localparam LOCK = 4'd9;
  localparam LOCKDOWN = 4'd10;
  localparam CLEAN = 4'd11;

  wire       [24:0]   temp_drop_timeout_counter_valueNext;
  wire       [0:0]    temp_drop_timeout_counter_valueNext_1;
  wire       [24:0]   temp_lock_timeout_counter_valueNext;
  wire       [0:0]    temp_lock_timeout_counter_valueNext_1;
  wire                temp_when;
  reg                 drop_timeout_state;
  reg                 drop_timeout_stateRise;
  wire                drop_timeout_counter_willIncrement;
  reg                 drop_timeout_counter_willClear;
  reg        [24:0]   drop_timeout_counter_valueNext;
  reg        [24:0]   drop_timeout_counter_value;
  wire                drop_timeout_counter_willOverflowIfInc;
  wire                drop_timeout_counter_willOverflow;
  reg                 lock_timeout_state;
  reg                 lock_timeout_stateRise;
  wire                lock_timeout_counter_willIncrement;
  reg                 lock_timeout_counter_willClear;
  reg        [24:0]   lock_timeout_counter_valueNext;
  reg        [24:0]   lock_timeout_counter_value;
  wire                lock_timeout_counter_willOverflowIfInc;
  wire                lock_timeout_counter_willOverflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_GAME_START;
  wire                fsm_onExit_RANDOM_GEN;
  wire                fsm_onExit_PLACE;
  wire                fsm_onExit_END_1;
  wire                fsm_onExit_FALLING;
  wire                fsm_onExit_DOWN;
  wire                fsm_onExit_DROP;
  wire                fsm_onExit_MOVE;
  wire                fsm_onExit_LOCK;
  wire                fsm_onExit_LOCKDOWN;
  wire                fsm_onExit_CLEAN;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_GAME_START;
  wire                fsm_onEntry_RANDOM_GEN;
  wire                fsm_onEntry_PLACE;
  wire                fsm_onEntry_END_1;
  wire                fsm_onEntry_FALLING;
  wire                fsm_onEntry_DOWN;
  wire                fsm_onEntry_DROP;
  wire                fsm_onEntry_MOVE;
  wire                fsm_onEntry_LOCK;
  wire                fsm_onEntry_LOCKDOWN;
  wire                fsm_onEntry_CLEAN;
  `ifndef SYNTHESIS
  reg [79:0] fsm_stateReg_string;
  reg [79:0] fsm_stateNext_string;
  `endif


  assign temp_when = (! collision_status_payload);
  assign temp_drop_timeout_counter_valueNext_1 = drop_timeout_counter_willIncrement;
  assign temp_drop_timeout_counter_valueNext = {24'd0, temp_drop_timeout_counter_valueNext_1};
  assign temp_lock_timeout_counter_valueNext_1 = lock_timeout_counter_willIncrement;
  assign temp_lock_timeout_counter_valueNext = {24'd0, temp_lock_timeout_counter_valueNext_1};
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE      ";
      GAME_START : fsm_stateReg_string = "GAME_START";
      RANDOM_GEN : fsm_stateReg_string = "RANDOM_GEN";
      PLACE : fsm_stateReg_string = "PLACE     ";
      END_1 : fsm_stateReg_string = "END_1     ";
      FALLING : fsm_stateReg_string = "FALLING   ";
      DOWN : fsm_stateReg_string = "DOWN      ";
      DROP : fsm_stateReg_string = "DROP      ";
      MOVE : fsm_stateReg_string = "MOVE      ";
      LOCK : fsm_stateReg_string = "LOCK      ";
      LOCKDOWN : fsm_stateReg_string = "LOCKDOWN  ";
      CLEAN : fsm_stateReg_string = "CLEAN     ";
      default : fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE      ";
      GAME_START : fsm_stateNext_string = "GAME_START";
      RANDOM_GEN : fsm_stateNext_string = "RANDOM_GEN";
      PLACE : fsm_stateNext_string = "PLACE     ";
      END_1 : fsm_stateNext_string = "END_1     ";
      FALLING : fsm_stateNext_string = "FALLING   ";
      DOWN : fsm_stateNext_string = "DOWN      ";
      DROP : fsm_stateNext_string = "DROP      ";
      MOVE : fsm_stateNext_string = "MOVE      ";
      LOCK : fsm_stateNext_string = "LOCK      ";
      LOCKDOWN : fsm_stateNext_string = "LOCKDOWN  ";
      CLEAN : fsm_stateNext_string = "CLEAN     ";
      default : fsm_stateNext_string = "??????????";
    endcase
  end
  `endif

  always @(*) begin
    drop_timeout_stateRise = 1'b0;
    drop_timeout_counter_willClear = 1'b0;
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_stateRise = (! drop_timeout_state);
    end
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
      GAME_START : begin
        if(screen_is_ready) begin
          fsm_stateNext = RANDOM_GEN;
        end
      end
      RANDOM_GEN : begin
        gen_piece_en = 1'b1;
        fsm_stateNext = PLACE;
      end
      PLACE : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = END_1;
          end else begin
            fsm_stateNext = FALLING;
          end
        end
      end
      END_1 : begin
        if(game_start) begin
          softReset = 1'b1;
          game_restart = 1'b1;
          fsm_stateNext = IDLE;
        end
      end
      FALLING : begin
        if((move_down && playfiedl_allow_action)) begin
          fsm_stateNext = DOWN;
        end
        if((drop && playfiedl_allow_action)) begin
          fsm_stateNext = DROP;
        end
        if((move_left && playfiedl_allow_action)) begin
          move_out_left = 1'b1;
          fsm_stateNext = MOVE;
        end
        if((move_right && playfiedl_allow_action)) begin
          move_out_right = 1'b1;
          fsm_stateNext = MOVE;
        end
        if((rotate && playfiedl_allow_action)) begin
          move_out_rotate = 1'b1;
          fsm_stateNext = MOVE;
        end
        if(drop_timeout_state) begin
          fsm_stateNext = LOCK;
        end
      end
      DOWN : begin
        if(collision_status_valid) begin
          if(temp_when) begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
          end
          fsm_stateNext = FALLING;
        end
      end
      DROP : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = LOCKDOWN;
          end else begin
            fsm_stateNext = DROP;
          end
        end
      end
      MOVE : begin
        if(collision_status_valid) begin
          fsm_stateNext = FALLING;
        end
      end
      LOCK : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = LOCKDOWN;
          end else begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
            fsm_stateNext = FALLING;
          end
        end
      end
      LOCKDOWN : begin
        if(lock_timeout_state) begin
          lock = 1'b1;
          fsm_stateNext = CLEAN;
        end
      end
      CLEAN : begin
        if(playfiedl_in_idle) begin
          fsm_stateNext = RANDOM_GEN;
        end
      end
      default : begin
        if(game_start) begin
          fsm_stateNext = GAME_START;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_onExit_PLACE) begin
      drop_timeout_counter_willClear = 1'b1;
      drop_timeout_stateRise = 1'b0;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign drop_timeout_counter_willOverflowIfInc = (drop_timeout_counter_value == 25'h168decf);
  assign drop_timeout_counter_willOverflow = (drop_timeout_counter_willOverflowIfInc && drop_timeout_counter_willIncrement);
  always @(*) begin
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_counter_valueNext = 25'h0;
    end else begin
      drop_timeout_counter_valueNext = (drop_timeout_counter_value + temp_drop_timeout_counter_valueNext);
    end
    if(drop_timeout_counter_willClear) begin
      drop_timeout_counter_valueNext = 25'h0;
    end
  end

  assign drop_timeout_counter_willIncrement = 1'b1;
  always @(*) begin
    lock_timeout_stateRise = 1'b0;
    lock_timeout_counter_willClear = 1'b0;
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_stateRise = (! lock_timeout_state);
    end
    if(fsm_onEntry_LOCKDOWN) begin
      lock_timeout_counter_willClear = 1'b1;
      lock_timeout_stateRise = 1'b0;
    end
  end

  assign lock_timeout_counter_willOverflowIfInc = (lock_timeout_counter_value == 25'h17d783f);
  assign lock_timeout_counter_willOverflow = (lock_timeout_counter_willOverflowIfInc && lock_timeout_counter_willIncrement);
  always @(*) begin
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_counter_valueNext = 25'h0;
    end else begin
      lock_timeout_counter_valueNext = (lock_timeout_counter_value + temp_lock_timeout_counter_valueNext);
    end
    if(lock_timeout_counter_willClear) begin
      lock_timeout_counter_valueNext = 25'h0;
    end
  end

  assign lock_timeout_counter_willIncrement = 1'b1;
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

  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_GAME_START = ((fsm_stateNext != GAME_START) && (fsm_stateReg == GAME_START));
  assign fsm_onExit_RANDOM_GEN = ((fsm_stateNext != RANDOM_GEN) && (fsm_stateReg == RANDOM_GEN));
  assign fsm_onExit_PLACE = ((fsm_stateNext != PLACE) && (fsm_stateReg == PLACE));
  assign fsm_onExit_END_1 = ((fsm_stateNext != END_1) && (fsm_stateReg == END_1));
  assign fsm_onExit_FALLING = ((fsm_stateNext != FALLING) && (fsm_stateReg == FALLING));
  assign fsm_onExit_DOWN = ((fsm_stateNext != DOWN) && (fsm_stateReg == DOWN));
  assign fsm_onExit_DROP = ((fsm_stateNext != DROP) && (fsm_stateReg == DROP));
  assign fsm_onExit_MOVE = ((fsm_stateNext != MOVE) && (fsm_stateReg == MOVE));
  assign fsm_onExit_LOCK = ((fsm_stateNext != LOCK) && (fsm_stateReg == LOCK));
  assign fsm_onExit_LOCKDOWN = ((fsm_stateNext != LOCKDOWN) && (fsm_stateReg == LOCKDOWN));
  assign fsm_onExit_CLEAN = ((fsm_stateNext != CLEAN) && (fsm_stateReg == CLEAN));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_GAME_START = ((fsm_stateNext == GAME_START) && (fsm_stateReg != GAME_START));
  assign fsm_onEntry_RANDOM_GEN = ((fsm_stateNext == RANDOM_GEN) && (fsm_stateReg != RANDOM_GEN));
  assign fsm_onEntry_PLACE = ((fsm_stateNext == PLACE) && (fsm_stateReg != PLACE));
  assign fsm_onEntry_END_1 = ((fsm_stateNext == END_1) && (fsm_stateReg != END_1));
  assign fsm_onEntry_FALLING = ((fsm_stateNext == FALLING) && (fsm_stateReg != FALLING));
  assign fsm_onEntry_DOWN = ((fsm_stateNext == DOWN) && (fsm_stateReg != DOWN));
  assign fsm_onEntry_DROP = ((fsm_stateNext == DROP) && (fsm_stateReg != DROP));
  assign fsm_onEntry_MOVE = ((fsm_stateNext == MOVE) && (fsm_stateReg != MOVE));
  assign fsm_onEntry_LOCK = ((fsm_stateNext == LOCK) && (fsm_stateReg != LOCK));
  assign fsm_onEntry_LOCKDOWN = ((fsm_stateNext == LOCKDOWN) && (fsm_stateReg != LOCKDOWN));
  assign fsm_onEntry_CLEAN = ((fsm_stateNext == CLEAN) && (fsm_stateReg != CLEAN));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      drop_timeout_state <= 1'b0;
      drop_timeout_counter_value <= 25'h0;
      lock_timeout_state <= 1'b0;
      lock_timeout_counter_value <= 25'h0;
      fsm_stateReg <= IDLE;
    end else begin
      drop_timeout_counter_value <= drop_timeout_counter_valueNext;
      if(drop_timeout_counter_willOverflow) begin
        drop_timeout_state <= 1'b1;
      end
      lock_timeout_counter_value <= lock_timeout_counter_valueNext;
      if(lock_timeout_counter_willOverflow) begin
        lock_timeout_state <= 1'b1;
      end
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        GAME_START : begin
        end
        RANDOM_GEN : begin
        end
        PLACE : begin
        end
        END_1 : begin
        end
        FALLING : begin
        end
        DOWN : begin
          if(collision_status_valid) begin
            if(temp_when) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        DROP : begin
        end
        MOVE : begin
        end
        LOCK : begin
          if(collision_status_valid) begin
            if(!collision_status_payload) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        LOCKDOWN : begin
        end
        CLEAN : begin
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
  output wire          motion_is_allowed,
  output wire          fsm_is_idle,
  input  wire          clk,
  input  wire          reset
);
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;
  localparam NO = 3'd0;
  localparam LEFT = 3'd1;
  localparam RIGHT = 3'd2;
  localparam DOWN = 3'd3;
  localparam ROTATE = 3'd4;
  localparam PLACE = 3'd5;
  localparam IDLE = 5'd0;
  localparam READOUT = 5'd1;
  localparam LOAD_TO_CHECKER = 5'd2;
  localparam COLLISION_CHECK = 5'd3;
  localparam REPORT_COLLISION = 5'd4;
  localparam END_OF_COLLISION = 5'd5;
  localparam PASS = 5'd6;
  localparam WAIT_CONTROL = 5'd7;
  localparam ROTATION = 5'd8;
  localparam PRE_CHECK = 5'd9;
  localparam LOCKER_WRITE_0 = 5'd10;
  localparam LOCKER_WRITE_1 = 5'd11;
  localparam WAIT_LOCKER_WRITE_DONE = 5'd12;
  localparam LOCKER_READ = 5'd13;
  localparam WAIT_LOCKER_READ_DONE = 5'd14;
  localparam CLEAR_REGION = 5'd15;
  localparam CHECK_ROW_FULL = 5'd16;
  localparam ROW_REMOVE = 5'd17;
  localparam ROW_REMOVE_DONE = 5'd18;

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
  wire                main_fsm_onExit_IDLE;
  wire                main_fsm_onExit_READOUT;
  wire                main_fsm_onExit_LOAD_TO_CHECKER;
  wire                main_fsm_onExit_COLLISION_CHECK;
  wire                main_fsm_onExit_REPORT_COLLISION;
  wire                main_fsm_onExit_END_OF_COLLISION;
  wire                main_fsm_onExit_PASS;
  wire                main_fsm_onExit_WAIT_CONTROL;
  wire                main_fsm_onExit_ROTATION;
  wire                main_fsm_onExit_PRE_CHECK;
  wire                main_fsm_onExit_LOCKER_WRITE_0;
  wire                main_fsm_onExit_LOCKER_WRITE_1;
  wire                main_fsm_onExit_WAIT_LOCKER_WRITE_DONE;
  wire                main_fsm_onExit_LOCKER_READ;
  wire                main_fsm_onExit_WAIT_LOCKER_READ_DONE;
  wire                main_fsm_onExit_CLEAR_REGION;
  wire                main_fsm_onExit_CHECK_ROW_FULL;
  wire                main_fsm_onExit_ROW_REMOVE;
  wire                main_fsm_onExit_ROW_REMOVE_DONE;
  wire                main_fsm_onEntry_IDLE;
  wire                main_fsm_onEntry_READOUT;
  wire                main_fsm_onEntry_LOAD_TO_CHECKER;
  wire                main_fsm_onEntry_COLLISION_CHECK;
  wire                main_fsm_onEntry_REPORT_COLLISION;
  wire                main_fsm_onEntry_END_OF_COLLISION;
  wire                main_fsm_onEntry_PASS;
  wire                main_fsm_onEntry_WAIT_CONTROL;
  wire                main_fsm_onEntry_ROTATION;
  wire                main_fsm_onEntry_PRE_CHECK;
  wire                main_fsm_onEntry_LOCKER_WRITE_0;
  wire                main_fsm_onEntry_LOCKER_WRITE_1;
  wire                main_fsm_onEntry_WAIT_LOCKER_WRITE_DONE;
  wire                main_fsm_onEntry_LOCKER_READ;
  wire                main_fsm_onEntry_WAIT_LOCKER_READ_DONE;
  wire                main_fsm_onEntry_CLEAR_REGION;
  wire                main_fsm_onEntry_CHECK_ROW_FULL;
  wire                main_fsm_onEntry_ROW_REMOVE;
  wire                main_fsm_onEntry_ROW_REMOVE_DONE;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_string;
  reg [7:0] piece_payload_string;
  reg [47:0] action_1_string;
  reg [175:0] main_fsm_stateReg_string;
  reg [175:0] main_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [9:0] locker_region [0:3];

  assign temp_when = (action_1 == PLACE);
  assign temp_when_1 = (action_1 == DOWN);
  assign temp_when_2 = (action_1 == ROTATE);
  assign temp_playfield_count_8 = (temp_playfield_count_9 + temp_playfield_count_14);
  assign temp_playfield_count_9 = (temp_playfield_count_10 + temp_playfield_count_12);
  assign temp_playfield_count_14 = (temp_playfield_count_15 + temp_playfield_count_17);
  assign temp_playfield_count_19 = (temp_playfield_count_20 + temp_playfield_count_25);
  assign temp_playfield_count_20 = (temp_playfield_count_21 + temp_playfield_count_23);
  assign temp_playfield_count_25 = (temp_playfield_count_26 + temp_playfield_count_28);
  assign temp_playfield_count_30 = playfield_ones[21];
  assign temp_playfield_count_29 = {2'd0, temp_playfield_count_30};
  assign temp_playfield_lowestOne = (playfield_ones - 22'h000001);
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
      I : piece_in_payload_string = "I";
      J : piece_in_payload_string = "J";
      L : piece_in_payload_string = "L";
      O : piece_in_payload_string = "O";
      S : piece_in_payload_string = "S";
      T : piece_in_payload_string = "T";
      Z : piece_in_payload_string = "Z";
      default : piece_in_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_payload)
      I : piece_payload_string = "I";
      J : piece_payload_string = "J";
      L : piece_payload_string = "L";
      O : piece_payload_string = "O";
      S : piece_payload_string = "S";
      T : piece_payload_string = "T";
      Z : piece_payload_string = "Z";
      default : piece_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(action_1)
      NO : action_1_string = "NO    ";
      LEFT : action_1_string = "LEFT  ";
      RIGHT : action_1_string = "RIGHT ";
      DOWN : action_1_string = "DOWN  ";
      ROTATE : action_1_string = "ROTATE";
      PLACE : action_1_string = "PLACE ";
      default : action_1_string = "??????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateReg)
      IDLE : main_fsm_stateReg_string = "IDLE                  ";
      READOUT : main_fsm_stateReg_string = "READOUT               ";
      LOAD_TO_CHECKER : main_fsm_stateReg_string = "LOAD_TO_CHECKER       ";
      COLLISION_CHECK : main_fsm_stateReg_string = "COLLISION_CHECK       ";
      REPORT_COLLISION : main_fsm_stateReg_string = "REPORT_COLLISION      ";
      END_OF_COLLISION : main_fsm_stateReg_string = "END_OF_COLLISION      ";
      PASS : main_fsm_stateReg_string = "PASS                  ";
      WAIT_CONTROL : main_fsm_stateReg_string = "WAIT_CONTROL          ";
      ROTATION : main_fsm_stateReg_string = "ROTATION              ";
      PRE_CHECK : main_fsm_stateReg_string = "PRE_CHECK             ";
      LOCKER_WRITE_0 : main_fsm_stateReg_string = "LOCKER_WRITE_0        ";
      LOCKER_WRITE_1 : main_fsm_stateReg_string = "LOCKER_WRITE_1        ";
      WAIT_LOCKER_WRITE_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_WRITE_DONE";
      LOCKER_READ : main_fsm_stateReg_string = "LOCKER_READ           ";
      WAIT_LOCKER_READ_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_READ_DONE ";
      CLEAR_REGION : main_fsm_stateReg_string = "CLEAR_REGION          ";
      CHECK_ROW_FULL : main_fsm_stateReg_string = "CHECK_ROW_FULL        ";
      ROW_REMOVE : main_fsm_stateReg_string = "ROW_REMOVE            ";
      ROW_REMOVE_DONE : main_fsm_stateReg_string = "ROW_REMOVE_DONE       ";
      default : main_fsm_stateReg_string = "??????????????????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateNext)
      IDLE : main_fsm_stateNext_string = "IDLE                  ";
      READOUT : main_fsm_stateNext_string = "READOUT               ";
      LOAD_TO_CHECKER : main_fsm_stateNext_string = "LOAD_TO_CHECKER       ";
      COLLISION_CHECK : main_fsm_stateNext_string = "COLLISION_CHECK       ";
      REPORT_COLLISION : main_fsm_stateNext_string = "REPORT_COLLISION      ";
      END_OF_COLLISION : main_fsm_stateNext_string = "END_OF_COLLISION      ";
      PASS : main_fsm_stateNext_string = "PASS                  ";
      WAIT_CONTROL : main_fsm_stateNext_string = "WAIT_CONTROL          ";
      ROTATION : main_fsm_stateNext_string = "ROTATION              ";
      PRE_CHECK : main_fsm_stateNext_string = "PRE_CHECK             ";
      LOCKER_WRITE_0 : main_fsm_stateNext_string = "LOCKER_WRITE_0        ";
      LOCKER_WRITE_1 : main_fsm_stateNext_string = "LOCKER_WRITE_1        ";
      WAIT_LOCKER_WRITE_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_WRITE_DONE";
      LOCKER_READ : main_fsm_stateNext_string = "LOCKER_READ           ";
      WAIT_LOCKER_READ_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_READ_DONE ";
      CLEAR_REGION : main_fsm_stateNext_string = "CLEAR_REGION          ";
      CHECK_ROW_FULL : main_fsm_stateNext_string = "CHECK_ROW_FULL        ";
      ROW_REMOVE : main_fsm_stateNext_string = "ROW_REMOVE            ";
      ROW_REMOVE_DONE : main_fsm_stateNext_string = "ROW_REMOVE_DONE       ";
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
      READOUT : begin
        output_en = 1'b1;
        if((playfield_addr_access_port_payload == flow_row)) begin
          dma_flow_dma_start = 1'b1;
        end
        if(row_out_done) begin
          if(main_fsm_will_goto_idle) begin
            main_fsm_stateNext = IDLE;
          end else begin
            main_fsm_stateNext = WAIT_CONTROL;
          end
        end
      end
      LOAD_TO_CHECKER : begin
        load_piece = 1'b1;
        main_fsm_stateNext = COLLISION_CHECK;
      end
      COLLISION_CHECK : begin
        if(collision_checker_is_collision_valid) begin
          if(collision_checker_is_collision_payload) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = PASS;
          end
        end
      end
      REPORT_COLLISION : begin
        status_valid = 1'b1;
        status_payload = 1'b1;
        if(temp_when) begin
          main_fsm_stateNext = IDLE;
        end else begin
          main_fsm_stateNext = END_OF_COLLISION;
        end
      end
      END_OF_COLLISION : begin
        if((((action_1 == LEFT) || (action_1 == RIGHT)) || (action_1 == ROTATE))) begin
          load_piece = 1'b1;
        end
        main_fsm_stateNext = WAIT_CONTROL;
      end
      PASS : begin
        if((action_1 == PLACE)) begin
          flow_update = 1'b1;
        end
        if((action_1 == LEFT)) begin
          flow_update = 1'b1;
          piece_buffer_left_shift_all = 1'b1;
        end
        if((action_1 == RIGHT)) begin
          flow_update = 1'b1;
          piece_buffer_right_shift_all = 1'b1;
        end
        if(temp_when_1) begin
          flow_update = 1'b1;
        end
        if(temp_when_2) begin
          flow_update = 1'b1;
        end
        main_fsm_stateNext = READOUT;
      end
      WAIT_CONTROL : begin
        if(move_in_left) begin
          if(checker_overflowIfLeft) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            checker_left_shift = 1'b1;
            main_fsm_stateNext = PRE_CHECK;
          end
        end
        if(move_in_right) begin
          if(checker_overflowIfRight) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            checker_right_shift = 1'b1;
            main_fsm_stateNext = PRE_CHECK;
          end
        end
        if(move_in_down) begin
          if(checker_overflowIfDown) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = PRE_CHECK;
          end
        end
        if(move_in_rotate) begin
          main_fsm_stateNext = ROTATION;
        end
        if(lock) begin
          main_fsm_stateNext = LOCKER_WRITE_0;
        end
      end
      ROTATION : begin
        if(temp_when_3) begin
          main_fsm_stateNext = REPORT_COLLISION;
        end else begin
          load_piece = 1'b1;
          main_fsm_stateNext = PRE_CHECK;
        end
      end
      PRE_CHECK : begin
        main_fsm_stateNext = COLLISION_CHECK;
      end
      LOCKER_WRITE_0 : begin
        dma_flow_dma_start = 1'b1;
        main_fsm_stateNext = LOCKER_WRITE_1;
      end
      LOCKER_WRITE_1 : begin
        dma_locker_dma_start = 1'b1;
        main_fsm_stateNext = WAIT_LOCKER_WRITE_DONE;
      end
      WAIT_LOCKER_WRITE_DONE : begin
        if(row_out_done) begin
          main_fsm_stateNext = LOCKER_READ;
        end
      end
      LOCKER_READ : begin
        dma_playfield_dma_start = 1'b1;
        main_fsm_stateNext = WAIT_LOCKER_READ_DONE;
      end
      WAIT_LOCKER_READ_DONE : begin
        playfield_freeze = 1'b1;
        if(locker_readou_is_done) begin
          main_fsm_stateNext = CLEAR_REGION;
        end
      end
      CLEAR_REGION : begin
        main_fsm_stateNext = CHECK_ROW_FULL;
      end
      CHECK_ROW_FULL : begin
        if(playfield_isRowFull) begin
          main_fsm_stateNext = ROW_REMOVE;
        end else begin
          main_fsm_stateNext = READOUT;
        end
      end
      ROW_REMOVE : begin
        playfield_clear = 1'b1;
        main_fsm_stateNext = ROW_REMOVE_DONE;
      end
      ROW_REMOVE_DONE : begin
        main_fsm_stateNext = CHECK_ROW_FULL;
      end
      default : begin
        if(piece_valid) begin
          main_fsm_stateNext = LOAD_TO_CHECKER;
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
      main_fsm_stateNext = IDLE;
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
  assign motion_is_allowed = (main_fsm_stateReg == WAIT_CONTROL);
  assign fsm_is_idle = (main_fsm_stateReg == IDLE);
  assign temp_flow_region_0 = 40'h0;
  assign main_fsm_onExit_IDLE = ((main_fsm_stateNext != IDLE) && (main_fsm_stateReg == IDLE));
  assign main_fsm_onExit_READOUT = ((main_fsm_stateNext != READOUT) && (main_fsm_stateReg == READOUT));
  assign main_fsm_onExit_LOAD_TO_CHECKER = ((main_fsm_stateNext != LOAD_TO_CHECKER) && (main_fsm_stateReg == LOAD_TO_CHECKER));
  assign main_fsm_onExit_COLLISION_CHECK = ((main_fsm_stateNext != COLLISION_CHECK) && (main_fsm_stateReg == COLLISION_CHECK));
  assign main_fsm_onExit_REPORT_COLLISION = ((main_fsm_stateNext != REPORT_COLLISION) && (main_fsm_stateReg == REPORT_COLLISION));
  assign main_fsm_onExit_END_OF_COLLISION = ((main_fsm_stateNext != END_OF_COLLISION) && (main_fsm_stateReg == END_OF_COLLISION));
  assign main_fsm_onExit_PASS = ((main_fsm_stateNext != PASS) && (main_fsm_stateReg == PASS));
  assign main_fsm_onExit_WAIT_CONTROL = ((main_fsm_stateNext != WAIT_CONTROL) && (main_fsm_stateReg == WAIT_CONTROL));
  assign main_fsm_onExit_ROTATION = ((main_fsm_stateNext != ROTATION) && (main_fsm_stateReg == ROTATION));
  assign main_fsm_onExit_PRE_CHECK = ((main_fsm_stateNext != PRE_CHECK) && (main_fsm_stateReg == PRE_CHECK));
  assign main_fsm_onExit_LOCKER_WRITE_0 = ((main_fsm_stateNext != LOCKER_WRITE_0) && (main_fsm_stateReg == LOCKER_WRITE_0));
  assign main_fsm_onExit_LOCKER_WRITE_1 = ((main_fsm_stateNext != LOCKER_WRITE_1) && (main_fsm_stateReg == LOCKER_WRITE_1));
  assign main_fsm_onExit_WAIT_LOCKER_WRITE_DONE = ((main_fsm_stateNext != WAIT_LOCKER_WRITE_DONE) && (main_fsm_stateReg == WAIT_LOCKER_WRITE_DONE));
  assign main_fsm_onExit_LOCKER_READ = ((main_fsm_stateNext != LOCKER_READ) && (main_fsm_stateReg == LOCKER_READ));
  assign main_fsm_onExit_WAIT_LOCKER_READ_DONE = ((main_fsm_stateNext != WAIT_LOCKER_READ_DONE) && (main_fsm_stateReg == WAIT_LOCKER_READ_DONE));
  assign main_fsm_onExit_CLEAR_REGION = ((main_fsm_stateNext != CLEAR_REGION) && (main_fsm_stateReg == CLEAR_REGION));
  assign main_fsm_onExit_CHECK_ROW_FULL = ((main_fsm_stateNext != CHECK_ROW_FULL) && (main_fsm_stateReg == CHECK_ROW_FULL));
  assign main_fsm_onExit_ROW_REMOVE = ((main_fsm_stateNext != ROW_REMOVE) && (main_fsm_stateReg == ROW_REMOVE));
  assign main_fsm_onExit_ROW_REMOVE_DONE = ((main_fsm_stateNext != ROW_REMOVE_DONE) && (main_fsm_stateReg == ROW_REMOVE_DONE));
  assign main_fsm_onEntry_IDLE = ((main_fsm_stateNext == IDLE) && (main_fsm_stateReg != IDLE));
  assign main_fsm_onEntry_READOUT = ((main_fsm_stateNext == READOUT) && (main_fsm_stateReg != READOUT));
  assign main_fsm_onEntry_LOAD_TO_CHECKER = ((main_fsm_stateNext == LOAD_TO_CHECKER) && (main_fsm_stateReg != LOAD_TO_CHECKER));
  assign main_fsm_onEntry_COLLISION_CHECK = ((main_fsm_stateNext == COLLISION_CHECK) && (main_fsm_stateReg != COLLISION_CHECK));
  assign main_fsm_onEntry_REPORT_COLLISION = ((main_fsm_stateNext == REPORT_COLLISION) && (main_fsm_stateReg != REPORT_COLLISION));
  assign main_fsm_onEntry_END_OF_COLLISION = ((main_fsm_stateNext == END_OF_COLLISION) && (main_fsm_stateReg != END_OF_COLLISION));
  assign main_fsm_onEntry_PASS = ((main_fsm_stateNext == PASS) && (main_fsm_stateReg != PASS));
  assign main_fsm_onEntry_WAIT_CONTROL = ((main_fsm_stateNext == WAIT_CONTROL) && (main_fsm_stateReg != WAIT_CONTROL));
  assign main_fsm_onEntry_ROTATION = ((main_fsm_stateNext == ROTATION) && (main_fsm_stateReg != ROTATION));
  assign main_fsm_onEntry_PRE_CHECK = ((main_fsm_stateNext == PRE_CHECK) && (main_fsm_stateReg != PRE_CHECK));
  assign main_fsm_onEntry_LOCKER_WRITE_0 = ((main_fsm_stateNext == LOCKER_WRITE_0) && (main_fsm_stateReg != LOCKER_WRITE_0));
  assign main_fsm_onEntry_LOCKER_WRITE_1 = ((main_fsm_stateNext == LOCKER_WRITE_1) && (main_fsm_stateReg != LOCKER_WRITE_1));
  assign main_fsm_onEntry_WAIT_LOCKER_WRITE_DONE = ((main_fsm_stateNext == WAIT_LOCKER_WRITE_DONE) && (main_fsm_stateReg != WAIT_LOCKER_WRITE_DONE));
  assign main_fsm_onEntry_LOCKER_READ = ((main_fsm_stateNext == LOCKER_READ) && (main_fsm_stateReg != LOCKER_READ));
  assign main_fsm_onEntry_WAIT_LOCKER_READ_DONE = ((main_fsm_stateNext == WAIT_LOCKER_READ_DONE) && (main_fsm_stateReg != WAIT_LOCKER_READ_DONE));
  assign main_fsm_onEntry_CLEAR_REGION = ((main_fsm_stateNext == CLEAR_REGION) && (main_fsm_stateReg != CLEAR_REGION));
  assign main_fsm_onEntry_CHECK_ROW_FULL = ((main_fsm_stateNext == CHECK_ROW_FULL) && (main_fsm_stateReg != CHECK_ROW_FULL));
  assign main_fsm_onEntry_ROW_REMOVE = ((main_fsm_stateNext == ROW_REMOVE) && (main_fsm_stateReg != ROW_REMOVE));
  assign main_fsm_onEntry_ROW_REMOVE_DONE = ((main_fsm_stateNext == ROW_REMOVE_DONE) && (main_fsm_stateReg != ROW_REMOVE_DONE));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      piece_valid <= 1'b0;
      action_1 <= NO;
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
      main_fsm_stateReg <= IDLE;
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
        READOUT : begin
        end
        LOAD_TO_CHECKER : begin
        end
        COLLISION_CHECK : begin
        end
        REPORT_COLLISION : begin
          if(!temp_when) begin
            if((action_1 == ROTATE)) begin
              piece_buffer_rot_cur <= piece_buffer_rot_backup;
            end
          end
        end
        END_OF_COLLISION : begin
          action_1 <= NO;
        end
        PASS : begin
          if(temp_when_1) begin
            checker_row_backup <= checker_row;
          end
          if(temp_when_2) begin
            piece_buffer_rot_backup <= piece_buffer_rot_cur;
          end
        end
        WAIT_CONTROL : begin
          if(move_in_left) begin
            if(!checker_overflowIfLeft) begin
              action_1 <= LEFT;
            end
          end
          if(move_in_right) begin
            if(!checker_overflowIfRight) begin
              action_1 <= RIGHT;
            end
          end
          if(move_in_down) begin
            if(!checker_overflowIfDown) begin
              checker_row <= (checker_row + 5'h01);
              action_1 <= DOWN;
            end
          end
          if(move_in_rotate) begin
            piece_buffer_rot_cur <= (piece_buffer_rot_cur + 2'b01);
          end
        end
        ROTATION : begin
          if(!temp_when_3) begin
            action_1 <= ROTATE;
          end
        end
        PRE_CHECK : begin
        end
        LOCKER_WRITE_0 : begin
        end
        LOCKER_WRITE_1 : begin
          dma_locker_dma_channel_0_enable <= 1'b1;
        end
        WAIT_LOCKER_WRITE_DONE : begin
        end
        LOCKER_READ : begin
          dma_playfield_dma_channel_2_enable <= 1'b1;
          dma_playfield_dma_base_addr <= flow_row;
          dma_playfield_dma_word_count <= 5'h03;
        end
        WAIT_LOCKER_READ_DONE : begin
        end
        CLEAR_REGION : begin
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
        CHECK_ROW_FULL : begin
          if(!playfield_isRowFull) begin
            main_fsm_will_goto_idle <= 1'b1;
          end
        end
        ROW_REMOVE : begin
        end
        ROW_REMOVE_DONE : begin
        end
        default : begin
          dma_flow_dma_channel_0_enable <= 1'b1;
          dma_checker_dma_channel_0_enable <= 1'b1;
          main_fsm_will_goto_idle <= 1'b0;
          if(piece_valid) begin
            action_1 <= PLACE;
          end
        end
      endcase
      if(main_fsm_onExit_READOUT) begin
        dma_playfield_dma_channel_1_enable <= 1'b0;
      end
      if(main_fsm_onExit_COLLISION_CHECK) begin
        dma_playfield_dma_channel_0_enable <= 1'b0;
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
        I : begin
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
        J : begin
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
        L : begin
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
        O : begin
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
        S : begin
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
        T : begin
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
  localparam IDLE = 3'd0;
  localparam CHECK = 3'd1;
  localparam OUTPUT_1 = 3'd2;
  localparam DONE = 3'd3;
  localparam SHIFT = 3'd4;
  localparam ELEMENT = 3'd5;

  wire                temp_when;
  reg        [5:0]    lfsr;
  reg        [2:0]    generatedNumbers_0;
  reg        [2:0]    generatedNumbers_1;
  reg        [2:0]    generatedNumbers_2;
  reg        [2:0]    generatedNumbers_3;
  reg        [2:0]    generatedNumbers_4;
  reg        [2:0]    generatedNumbers_5;
  reg        [2:0]    generatedNumbers_6;
  reg        [2:0]    count;
  reg                 existed;
  reg                 shift;
  wire       [2:0]    nextNumber;
  reg                 invalid;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire       [7:0]    temp_1;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_CHECK;
  wire                fsm_onExit_OUTPUT_1;
  wire                fsm_onExit_DONE;
  wire                fsm_onExit_SHIFT;
  wire                fsm_onExit_ELEMENT;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_CHECK;
  wire                fsm_onEntry_OUTPUT_1;
  wire                fsm_onEntry_DONE;
  wire                fsm_onEntry_SHIFT;
  wire                fsm_onEntry_ELEMENT;
  `ifndef SYNTHESIS
  reg [63:0] fsm_stateReg_string;
  reg [63:0] fsm_stateNext_string;
  `endif


  assign temp_when = (count == 3'b111);
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE    ";
      CHECK : fsm_stateReg_string = "CHECK   ";
      OUTPUT_1 : fsm_stateReg_string = "OUTPUT_1";
      DONE : fsm_stateReg_string = "DONE    ";
      SHIFT : fsm_stateReg_string = "SHIFT   ";
      ELEMENT : fsm_stateReg_string = "ELEMENT ";
      default : fsm_stateReg_string = "????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE    ";
      CHECK : fsm_stateNext_string = "CHECK   ";
      OUTPUT_1 : fsm_stateNext_string = "OUTPUT_1";
      DONE : fsm_stateNext_string = "DONE    ";
      SHIFT : fsm_stateNext_string = "SHIFT   ";
      ELEMENT : fsm_stateNext_string = "ELEMENT ";
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
      CHECK : begin
        if((existed || invalid)) begin
          fsm_stateNext = SHIFT;
        end else begin
          fsm_stateNext = OUTPUT_1;
        end
      end
      OUTPUT_1 : begin
        io_shape_valid = 1'b1;
        shift = 1'b1;
        fsm_stateNext = DONE;
      end
      DONE : begin
        fsm_stateNext = IDLE;
      end
      SHIFT : begin
        shift = 1'b1;
        fsm_stateNext = ELEMENT;
      end
      ELEMENT : begin
        fsm_stateNext = CHECK;
      end
      default : begin
        if(io_enable) begin
          fsm_stateNext = CHECK;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign fsm_wantKill = 1'b0;
  assign temp_1 = ({7'd0,1'b1} <<< count);
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_CHECK = ((fsm_stateNext != CHECK) && (fsm_stateReg == CHECK));
  assign fsm_onExit_OUTPUT_1 = ((fsm_stateNext != OUTPUT_1) && (fsm_stateReg == OUTPUT_1));
  assign fsm_onExit_DONE = ((fsm_stateNext != DONE) && (fsm_stateReg == DONE));
  assign fsm_onExit_SHIFT = ((fsm_stateNext != SHIFT) && (fsm_stateReg == SHIFT));
  assign fsm_onExit_ELEMENT = ((fsm_stateNext != ELEMENT) && (fsm_stateReg == ELEMENT));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_CHECK = ((fsm_stateNext == CHECK) && (fsm_stateReg != CHECK));
  assign fsm_onEntry_OUTPUT_1 = ((fsm_stateNext == OUTPUT_1) && (fsm_stateReg != OUTPUT_1));
  assign fsm_onEntry_DONE = ((fsm_stateNext == DONE) && (fsm_stateReg != DONE));
  assign fsm_onEntry_SHIFT = ((fsm_stateNext == SHIFT) && (fsm_stateReg != SHIFT));
  assign fsm_onEntry_ELEMENT = ((fsm_stateNext == ELEMENT) && (fsm_stateReg != ELEMENT));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lfsr <= 6'h2d;
      count <= 3'b000;
      fsm_stateReg <= IDLE;
    end else begin
      if(shift) begin
        lfsr <= {lfsr[4 : 0],(lfsr[5] ^ lfsr[3])};
      end
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        CHECK : begin
        end
        OUTPUT_1 : begin
          count <= (count + 3'b001);
        end
        DONE : begin
          if(temp_when) begin
            count <= 3'b000;
          end
        end
        SHIFT : begin
        end
        ELEMENT : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    invalid <= (nextNumber == 3'b111);
    existed <= 1'b0;
    if(((3'b000 < count) && (nextNumber == generatedNumbers_0))) begin
      existed <= 1'b1;
    end
    if(((3'b001 < count) && (nextNumber == generatedNumbers_1))) begin
      existed <= 1'b1;
    end
    if(((3'b010 < count) && (nextNumber == generatedNumbers_2))) begin
      existed <= 1'b1;
    end
    if(((3'b011 < count) && (nextNumber == generatedNumbers_3))) begin
      existed <= 1'b1;
    end
    if(((3'b100 < count) && (nextNumber == generatedNumbers_4))) begin
      existed <= 1'b1;
    end
    if(((3'b101 < count) && (nextNumber == generatedNumbers_5))) begin
      existed <= 1'b1;
    end
    if(((3'b110 < count) && (nextNumber == generatedNumbers_6))) begin
      existed <= 1'b1;
    end
    case(fsm_stateReg)
      CHECK : begin
      end
      OUTPUT_1 : begin
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
      end
      DONE : begin
        if(temp_when) begin
          generatedNumbers_0 <= 3'b000;
          generatedNumbers_1 <= 3'b000;
          generatedNumbers_2 <= 3'b000;
          generatedNumbers_3 <= 3'b000;
          generatedNumbers_4 <= 3'b000;
          generatedNumbers_5 <= 3'b000;
          generatedNumbers_6 <= 3'b000;
        end
      end
      SHIFT : begin
      end
      ELEMENT : begin
      end
      default : begin
      end
    endcase
  end


endmodule
