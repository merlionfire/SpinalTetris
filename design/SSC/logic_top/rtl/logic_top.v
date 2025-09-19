// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : logic_top
// Git hash  : 57c638189b4e0ddb5195fdfb622c25acf3882cef

`timescale 1ns/1ps

module logic_top (
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  output wire          row_val_valid,
  output wire [9:0]    row_val_payload,
  input  wire          draw_field_done,
  input  wire          screen_is_ready,
  input  wire          vga_sof,
  output wire          ctrl_allowed,
  output reg           softReset,
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
  localparam STANDBY = 4'd0;
  localparam MOVE = 4'd1;
  localparam CHECK = 4'd2;
  localparam ERASE = 4'd3;
  localparam UPDATE = 4'd4;
  localparam START_REFRESH = 4'd5;
  localparam WAIT_FRESH_DONE = 4'd6;
  localparam STATUS = 4'd7;
  localparam FREEZE_CTRL = 4'd8;
  localparam IDLE = 4'd0;
  localparam GAME_START = 4'd1;
  localparam RANDOM_GEN = 4'd2;
  localparam PLACE = 4'd3;
  localparam END_1 = 4'd4;
  localparam FALLING = 4'd5;
  localparam LOCK = 4'd6;
  localparam LOCKDOWN = 4'd7;
  localparam PATTERN = 4'd8;

  reg                 play_field_1_fetch;
  wire                piece_gen_io_shape_valid;
  wire       [2:0]    piece_gen_io_shape_payload;
  wire                picoller_inst_piece_in_ready;
  wire                picoller_inst_collision_out_valid;
  wire                picoller_inst_collision_out_payload;
  wire                picoller_inst_block_pos_valid;
  wire       [3:0]    picoller_inst_block_pos_payload_x;
  wire       [4:0]    picoller_inst_block_pos_payload_y;
  wire                play_field_1_clear_done;
  wire                play_field_1_block_val_valid;
  wire                play_field_1_block_val_payload;
  wire                play_field_1_row_val_valid;
  wire       [9:0]    play_field_1_row_val_payload;
  wire                play_field_1_lines_cleared_valid;
  wire       [4:0]    play_field_1_lines_cleared_payload;
  wire       [4:0]    temp_freeze_ctrl_cnt_valueNext;
  wire       [0:0]    temp_freeze_ctrl_cnt_valueNext_1;
  wire       [24:0]   temp_main_fsm_drop_timeout_counter_valueNext;
  wire       [0:0]    temp_main_fsm_drop_timeout_counter_valueNext_1;
  wire       [24:0]   temp_main_fsm_lock_timeout_counter_valueNext;
  wire       [0:0]    temp_main_fsm_lock_timeout_counter_valueNext_1;
  wire       [7:0]    temp_score_total_score;
  wire                temp_when;
  wire                temp_when_1;
  wire                temp_when_2;
  wire                temp_when_3;
  wire                piece_req_valid;
  wire                piece_req_ready;
  reg        [3:0]    piece_req_payload_orign_x;
  reg        [4:0]    piece_req_payload_orign_y;
  wire       [2:0]    piece_req_payload_type;
  reg        [1:0]    piece_req_payload_rot;
  reg                 update;
  reg                 block_set;
  reg                 clear_start;
  reg                 restart;
  wire                collision_in_valid;
  wire                collision_in_payload;
  reg                 lines_cleared_num_valid;
  reg        [4:0]    lines_cleared_num_payload;
  reg        [4:0]    id_debug;
  reg                 gen_piece_en;
  reg                 block_skip_en;
  wire       [3:0]    start_x;
  wire       [4:0]    start_y;
  reg        [3:0]    pos_x_cur;
  reg        [4:0]    pos_y_cur;
  reg        [1:0]    rot_cur;
  reg        [2:0]    shape_cur;
  reg                 req_valid;
  reg        [3:0]    pos_x_chk;
  reg        [4:0]    pos_y_chk;
  reg        [1:0]    rot_chk;
  reg        [2:0]    shape_chk;
  reg                 move_en;
  reg                 ctrl_en;
  reg                 drop_down;
  reg                 place_en;
  reg                 playfield_fsm_result;
  reg                 playfield_fsm_reset;
  wire                fsm_is_place;
  reg                 freeze_ctrl_cnt_willIncrement;
  reg                 freeze_ctrl_cnt_willClear;
  reg        [4:0]    freeze_ctrl_cnt_valueNext;
  reg        [4:0]    freeze_ctrl_cnt_value;
  wire                freeze_ctrl_cnt_willOverflowIfInc;
  wire                freeze_ctrl_cnt_willOverflow;
  reg        [2:0]    debug_move_type;
  wire                playfield_fsm_wantExit;
  reg                 playfield_fsm_wantStart;
  wire                playfield_fsm_wantKill;
  wire                main_fsm_wantExit;
  reg                 main_fsm_wantStart;
  wire                main_fsm_wantKill;
  reg                 main_fsm_drop_timeout_state;
  reg                 main_fsm_drop_timeout_stateRise;
  wire                main_fsm_drop_timeout_counter_willIncrement;
  reg                 main_fsm_drop_timeout_counter_willClear;
  reg        [24:0]   main_fsm_drop_timeout_counter_valueNext;
  reg        [24:0]   main_fsm_drop_timeout_counter_value;
  wire                main_fsm_drop_timeout_counter_willOverflowIfInc;
  wire                main_fsm_drop_timeout_counter_willOverflow;
  reg                 main_fsm_lock_timeout_state;
  reg                 main_fsm_lock_timeout_stateRise;
  wire                main_fsm_lock_timeout_counter_willIncrement;
  reg                 main_fsm_lock_timeout_counter_willClear;
  reg        [24:0]   main_fsm_lock_timeout_counter_valueNext;
  reg        [24:0]   main_fsm_lock_timeout_counter_value;
  wire                main_fsm_lock_timeout_counter_willOverflowIfInc;
  wire                main_fsm_lock_timeout_counter_willOverflow;
  wire       [3:0]    main_fsm_debug;
  wire       [3:0]    playfield_fsm_debug;
  reg        [7:0]    score_total_score;
  reg        [2:0]    score_score_with_bonus;
  reg        [3:0]    playfield_fsm_stateReg;
  reg        [3:0]    playfield_fsm_stateNext;
  wire                playfield_fsm_onExit_STANDBY;
  wire                playfield_fsm_onExit_MOVE;
  wire                playfield_fsm_onExit_CHECK;
  wire                playfield_fsm_onExit_ERASE;
  wire                playfield_fsm_onExit_UPDATE;
  wire                playfield_fsm_onExit_START_REFRESH;
  wire                playfield_fsm_onExit_WAIT_FRESH_DONE;
  wire                playfield_fsm_onExit_STATUS;
  wire                playfield_fsm_onExit_FREEZE_CTRL;
  wire                playfield_fsm_onEntry_STANDBY;
  wire                playfield_fsm_onEntry_MOVE;
  wire                playfield_fsm_onEntry_CHECK;
  wire                playfield_fsm_onEntry_ERASE;
  wire                playfield_fsm_onEntry_UPDATE;
  wire                playfield_fsm_onEntry_START_REFRESH;
  wire                playfield_fsm_onEntry_WAIT_FRESH_DONE;
  wire                playfield_fsm_onEntry_STATUS;
  wire                playfield_fsm_onEntry_FREEZE_CTRL;
  reg        [3:0]    main_fsm_stateReg;
  reg        [3:0]    main_fsm_stateNext;
  wire                main_fsm_onExit_IDLE;
  wire                main_fsm_onExit_GAME_START;
  wire                main_fsm_onExit_RANDOM_GEN;
  wire       [2:0]    temp_shape_cur;
  wire                main_fsm_onExit_PLACE;
  wire                main_fsm_onExit_END_1;
  wire                main_fsm_onExit_FALLING;
  wire                main_fsm_onExit_LOCK;
  wire                main_fsm_onExit_LOCKDOWN;
  wire                main_fsm_onExit_PATTERN;
  wire                main_fsm_onEntry_IDLE;
  wire                main_fsm_onEntry_GAME_START;
  wire                main_fsm_onEntry_RANDOM_GEN;
  wire                main_fsm_onEntry_PLACE;
  wire                main_fsm_onEntry_END_1;
  wire                main_fsm_onEntry_FALLING;
  wire                main_fsm_onEntry_LOCK;
  wire                main_fsm_onEntry_LOCKDOWN;
  wire                main_fsm_onEntry_PATTERN;
  `ifndef SYNTHESIS
  reg [7:0] piece_req_payload_type_string;
  reg [7:0] shape_cur_string;
  reg [7:0] shape_chk_string;
  reg [119:0] playfield_fsm_stateReg_string;
  reg [119:0] playfield_fsm_stateNext_string;
  reg [79:0] main_fsm_stateReg_string;
  reg [79:0] main_fsm_stateNext_string;
  reg [7:0] temp_shape_cur_string;
  `endif


  assign temp_when = (ctrl_en && move_left);
  assign temp_when_1 = (ctrl_en && move_right);
  assign temp_when_2 = (ctrl_en && rotate);
  assign temp_when_3 = ((ctrl_en && move_down) || drop_down);
  assign temp_freeze_ctrl_cnt_valueNext_1 = freeze_ctrl_cnt_willIncrement;
  assign temp_freeze_ctrl_cnt_valueNext = {4'd0, temp_freeze_ctrl_cnt_valueNext_1};
  assign temp_main_fsm_drop_timeout_counter_valueNext_1 = main_fsm_drop_timeout_counter_willIncrement;
  assign temp_main_fsm_drop_timeout_counter_valueNext = {24'd0, temp_main_fsm_drop_timeout_counter_valueNext_1};
  assign temp_main_fsm_lock_timeout_counter_valueNext_1 = main_fsm_lock_timeout_counter_willIncrement;
  assign temp_main_fsm_lock_timeout_counter_valueNext = {24'd0, temp_main_fsm_lock_timeout_counter_valueNext_1};
  assign temp_score_total_score = {5'd0, score_score_with_bonus};
  seven_bag_rng piece_gen (
    .io_enable        (gen_piece_en                   ), //i
    .io_shape_valid   (piece_gen_io_shape_valid       ), //o
    .io_shape_payload (piece_gen_io_shape_payload[2:0]), //o
    .clk              (clk                            ), //i
    .reset            (reset                          )  //i
  );
  picoller picoller_inst (
    .piece_in_valid           (piece_req_valid                       ), //i
    .piece_in_ready           (picoller_inst_piece_in_ready          ), //o
    .piece_in_payload_orign_x (piece_req_payload_orign_x[3:0]        ), //i
    .piece_in_payload_orign_y (piece_req_payload_orign_y[4:0]        ), //i
    .piece_in_payload_type    (piece_req_payload_type[2:0]           ), //i
    .piece_in_payload_rot     (piece_req_payload_rot[1:0]            ), //i
    .collision_out_valid      (picoller_inst_collision_out_valid     ), //o
    .collision_out_payload    (picoller_inst_collision_out_payload   ), //o
    .update                   (update                                ), //i
    .block_set                (block_set                             ), //i
    .block_skip_en            (block_skip_en                         ), //i
    .block_pos_valid          (picoller_inst_block_pos_valid         ), //o
    .block_pos_payload_x      (picoller_inst_block_pos_payload_x[3:0]), //o
    .block_pos_payload_y      (picoller_inst_block_pos_payload_y[4:0]), //o
    .block_val_valid          (play_field_1_block_val_valid          ), //i
    .block_val_payload        (play_field_1_block_val_payload        ), //i
    .clk                      (clk                                   ), //i
    .reset                    (reset                                 )  //i
  );
  play_field play_field_1 (
    .block_pos_valid       (picoller_inst_block_pos_valid          ), //i
    .block_pos_payload_x   (picoller_inst_block_pos_payload_x[3:0] ), //i
    .block_pos_payload_y   (picoller_inst_block_pos_payload_y[4:0] ), //i
    .update                (update                                 ), //i
    .clear_start           (clear_start                            ), //i
    .block_set             (block_set                              ), //i
    .restart               (restart                                ), //i
    .fetch                 (play_field_1_fetch                     ), //i
    .clear_done            (play_field_1_clear_done                ), //o
    .block_val_valid       (play_field_1_block_val_valid           ), //o
    .block_val_payload     (play_field_1_block_val_payload         ), //o
    .row_val_valid         (play_field_1_row_val_valid             ), //o
    .row_val_payload       (play_field_1_row_val_payload[9:0]      ), //o
    .lines_cleared_valid   (play_field_1_lines_cleared_valid       ), //o
    .lines_cleared_payload (play_field_1_lines_cleared_payload[4:0]), //o
    .clk                   (clk                                    ), //i
    .reset                 (reset                                  )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_req_payload_type)
      I : piece_req_payload_type_string = "I";
      J : piece_req_payload_type_string = "J";
      L : piece_req_payload_type_string = "L";
      O : piece_req_payload_type_string = "O";
      S : piece_req_payload_type_string = "S";
      T : piece_req_payload_type_string = "T";
      Z : piece_req_payload_type_string = "Z";
      default : piece_req_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(shape_cur)
      I : shape_cur_string = "I";
      J : shape_cur_string = "J";
      L : shape_cur_string = "L";
      O : shape_cur_string = "O";
      S : shape_cur_string = "S";
      T : shape_cur_string = "T";
      Z : shape_cur_string = "Z";
      default : shape_cur_string = "?";
    endcase
  end
  always @(*) begin
    case(shape_chk)
      I : shape_chk_string = "I";
      J : shape_chk_string = "J";
      L : shape_chk_string = "L";
      O : shape_chk_string = "O";
      S : shape_chk_string = "S";
      T : shape_chk_string = "T";
      Z : shape_chk_string = "Z";
      default : shape_chk_string = "?";
    endcase
  end
  always @(*) begin
    case(playfield_fsm_stateReg)
      STANDBY : playfield_fsm_stateReg_string = "STANDBY        ";
      MOVE : playfield_fsm_stateReg_string = "MOVE           ";
      CHECK : playfield_fsm_stateReg_string = "CHECK          ";
      ERASE : playfield_fsm_stateReg_string = "ERASE          ";
      UPDATE : playfield_fsm_stateReg_string = "UPDATE         ";
      START_REFRESH : playfield_fsm_stateReg_string = "START_REFRESH  ";
      WAIT_FRESH_DONE : playfield_fsm_stateReg_string = "WAIT_FRESH_DONE";
      STATUS : playfield_fsm_stateReg_string = "STATUS         ";
      FREEZE_CTRL : playfield_fsm_stateReg_string = "FREEZE_CTRL    ";
      default : playfield_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(playfield_fsm_stateNext)
      STANDBY : playfield_fsm_stateNext_string = "STANDBY        ";
      MOVE : playfield_fsm_stateNext_string = "MOVE           ";
      CHECK : playfield_fsm_stateNext_string = "CHECK          ";
      ERASE : playfield_fsm_stateNext_string = "ERASE          ";
      UPDATE : playfield_fsm_stateNext_string = "UPDATE         ";
      START_REFRESH : playfield_fsm_stateNext_string = "START_REFRESH  ";
      WAIT_FRESH_DONE : playfield_fsm_stateNext_string = "WAIT_FRESH_DONE";
      STATUS : playfield_fsm_stateNext_string = "STATUS         ";
      FREEZE_CTRL : playfield_fsm_stateNext_string = "FREEZE_CTRL    ";
      default : playfield_fsm_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateReg)
      IDLE : main_fsm_stateReg_string = "IDLE      ";
      GAME_START : main_fsm_stateReg_string = "GAME_START";
      RANDOM_GEN : main_fsm_stateReg_string = "RANDOM_GEN";
      PLACE : main_fsm_stateReg_string = "PLACE     ";
      END_1 : main_fsm_stateReg_string = "END_1     ";
      FALLING : main_fsm_stateReg_string = "FALLING   ";
      LOCK : main_fsm_stateReg_string = "LOCK      ";
      LOCKDOWN : main_fsm_stateReg_string = "LOCKDOWN  ";
      PATTERN : main_fsm_stateReg_string = "PATTERN   ";
      default : main_fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateNext)
      IDLE : main_fsm_stateNext_string = "IDLE      ";
      GAME_START : main_fsm_stateNext_string = "GAME_START";
      RANDOM_GEN : main_fsm_stateNext_string = "RANDOM_GEN";
      PLACE : main_fsm_stateNext_string = "PLACE     ";
      END_1 : main_fsm_stateNext_string = "END_1     ";
      FALLING : main_fsm_stateNext_string = "FALLING   ";
      LOCK : main_fsm_stateNext_string = "LOCK      ";
      LOCKDOWN : main_fsm_stateNext_string = "LOCKDOWN  ";
      PATTERN : main_fsm_stateNext_string = "PATTERN   ";
      default : main_fsm_stateNext_string = "??????????";
    endcase
  end
  always @(*) begin
    case(temp_shape_cur)
      I : temp_shape_cur_string = "I";
      J : temp_shape_cur_string = "J";
      L : temp_shape_cur_string = "L";
      O : temp_shape_cur_string = "O";
      S : temp_shape_cur_string = "S";
      T : temp_shape_cur_string = "T";
      Z : temp_shape_cur_string = "Z";
      default : temp_shape_cur_string = "?";
    endcase
  end
  `endif

  assign piece_req_ready = picoller_inst_piece_in_ready;
  assign collision_in_valid = picoller_inst_collision_out_valid;
  assign collision_in_payload = picoller_inst_collision_out_payload;
  assign row_val_valid = play_field_1_row_val_valid;
  assign row_val_payload = play_field_1_row_val_payload;
  assign start_x = 4'b0101;
  assign start_y = 5'h0;
  always @(*) begin
    piece_req_payload_orign_x = pos_x_cur;
    piece_req_payload_orign_y = pos_y_cur;
    piece_req_payload_rot = rot_cur;
    playfield_fsm_wantStart = 1'b0;
    play_field_1_fetch = 1'b0;
    playfield_fsm_stateNext = playfield_fsm_stateReg;
    case(playfield_fsm_stateReg)
      MOVE : begin
        if(temp_when) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(temp_when_1) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(temp_when_2) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(temp_when_3) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(place_en) begin
          playfield_fsm_stateNext = CHECK;
        end
      end
      CHECK : begin
        piece_req_payload_orign_x = pos_x_chk;
        piece_req_payload_orign_y = pos_y_chk;
        piece_req_payload_rot = rot_chk;
        if(collision_in_valid) begin
          if(collision_in_payload) begin
            playfield_fsm_stateNext = STATUS;
          end else begin
            if(fsm_is_place) begin
              playfield_fsm_stateNext = UPDATE;
            end else begin
              playfield_fsm_stateNext = ERASE;
            end
          end
        end
      end
      ERASE : begin
        if(collision_in_valid) begin
          playfield_fsm_stateNext = UPDATE;
        end
      end
      UPDATE : begin
        if(collision_in_valid) begin
          playfield_fsm_stateNext = START_REFRESH;
        end
      end
      START_REFRESH : begin
        if(vga_sof) begin
          play_field_1_fetch = 1'b1;
          playfield_fsm_stateNext = WAIT_FRESH_DONE;
        end
      end
      WAIT_FRESH_DONE : begin
        if(draw_field_done) begin
          playfield_fsm_stateNext = STATUS;
        end
      end
      STATUS : begin
        playfield_fsm_stateNext = FREEZE_CTRL;
      end
      FREEZE_CTRL : begin
        if(freeze_ctrl_cnt_willOverflow) begin
          playfield_fsm_stateNext = MOVE;
        end
      end
      default : begin
        if(move_en) begin
          playfield_fsm_stateNext = MOVE;
        end
        playfield_fsm_wantStart = 1'b1;
      end
    endcase
    if(playfield_fsm_wantKill) begin
      playfield_fsm_stateNext = STANDBY;
    end
  end

  assign piece_req_payload_type = shape_cur;
  assign piece_req_valid = req_valid;
  always @(*) begin
    freeze_ctrl_cnt_willIncrement = 1'b0;
    if(vga_sof) begin
      freeze_ctrl_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    freeze_ctrl_cnt_willClear = 1'b0;
    if(playfield_fsm_onEntry_FREEZE_CTRL) begin
      freeze_ctrl_cnt_willClear = 1'b1;
    end
  end

  assign freeze_ctrl_cnt_willOverflowIfInc = (freeze_ctrl_cnt_value == 5'h13);
  assign freeze_ctrl_cnt_willOverflow = (freeze_ctrl_cnt_willOverflowIfInc && freeze_ctrl_cnt_willIncrement);
  always @(*) begin
    if(freeze_ctrl_cnt_willOverflow) begin
      freeze_ctrl_cnt_valueNext = 5'h0;
    end else begin
      freeze_ctrl_cnt_valueNext = (freeze_ctrl_cnt_value + temp_freeze_ctrl_cnt_valueNext);
    end
    if(freeze_ctrl_cnt_willClear) begin
      freeze_ctrl_cnt_valueNext = 5'h0;
    end
  end

  assign playfield_fsm_wantExit = 1'b0;
  assign playfield_fsm_wantKill = 1'b0;
  assign ctrl_allowed = (playfield_fsm_stateReg == MOVE);
  assign main_fsm_wantExit = 1'b0;
  always @(*) begin
    main_fsm_wantStart = 1'b0;
    softReset = 1'b0;
    main_fsm_stateNext = main_fsm_stateReg;
    case(main_fsm_stateReg)
      GAME_START : begin
        if(screen_is_ready) begin
          main_fsm_stateNext = RANDOM_GEN;
        end
      end
      RANDOM_GEN : begin
        if(piece_gen_io_shape_valid) begin
          main_fsm_stateNext = PLACE;
        end
      end
      PLACE : begin
        if((playfield_fsm_stateReg == STATUS)) begin
          if(playfield_fsm_result) begin
            main_fsm_stateNext = FALLING;
          end else begin
            main_fsm_stateNext = END_1;
          end
        end
      end
      END_1 : begin
        softReset = 1'b1;
        main_fsm_stateNext = IDLE;
      end
      FALLING : begin
        if((main_fsm_drop_timeout_state && (playfield_fsm_stateReg == MOVE))) begin
          main_fsm_stateNext = LOCK;
        end
      end
      LOCK : begin
        if((playfield_fsm_stateReg == STATUS)) begin
          if(playfield_fsm_result) begin
            main_fsm_stateNext = FALLING;
          end else begin
            main_fsm_stateNext = LOCKDOWN;
          end
        end
      end
      LOCKDOWN : begin
        if(main_fsm_lock_timeout_state) begin
          main_fsm_stateNext = PATTERN;
        end
      end
      PATTERN : begin
        if(play_field_1_clear_done) begin
          main_fsm_stateNext = RANDOM_GEN;
        end
      end
      default : begin
        if(game_start) begin
          main_fsm_stateNext = GAME_START;
        end
        main_fsm_wantStart = 1'b1;
      end
    endcase
    if(main_fsm_wantKill) begin
      main_fsm_stateNext = IDLE;
    end
  end

  assign main_fsm_wantKill = 1'b0;
  always @(*) begin
    main_fsm_drop_timeout_stateRise = 1'b0;
    main_fsm_drop_timeout_counter_willClear = 1'b0;
    if(main_fsm_drop_timeout_counter_willOverflow) begin
      main_fsm_drop_timeout_stateRise = (! main_fsm_drop_timeout_state);
    end
    if(main_fsm_onEntry_FALLING) begin
      main_fsm_drop_timeout_counter_willClear = 1'b1;
      main_fsm_drop_timeout_stateRise = 1'b0;
    end
  end

  assign main_fsm_drop_timeout_counter_willOverflowIfInc = (main_fsm_drop_timeout_counter_value == 25'h168decf);
  assign main_fsm_drop_timeout_counter_willOverflow = (main_fsm_drop_timeout_counter_willOverflowIfInc && main_fsm_drop_timeout_counter_willIncrement);
  always @(*) begin
    if(main_fsm_drop_timeout_counter_willOverflow) begin
      main_fsm_drop_timeout_counter_valueNext = 25'h0;
    end else begin
      main_fsm_drop_timeout_counter_valueNext = (main_fsm_drop_timeout_counter_value + temp_main_fsm_drop_timeout_counter_valueNext);
    end
    if(main_fsm_drop_timeout_counter_willClear) begin
      main_fsm_drop_timeout_counter_valueNext = 25'h0;
    end
  end

  assign main_fsm_drop_timeout_counter_willIncrement = 1'b1;
  always @(*) begin
    main_fsm_lock_timeout_stateRise = 1'b0;
    main_fsm_lock_timeout_counter_willClear = 1'b0;
    if(main_fsm_lock_timeout_counter_willOverflow) begin
      main_fsm_lock_timeout_stateRise = (! main_fsm_lock_timeout_state);
    end
    if(main_fsm_onEntry_LOCKDOWN) begin
      main_fsm_lock_timeout_counter_willClear = 1'b1;
      main_fsm_lock_timeout_stateRise = 1'b0;
    end
  end

  assign main_fsm_lock_timeout_counter_willOverflowIfInc = (main_fsm_lock_timeout_counter_value == 25'h17d783f);
  assign main_fsm_lock_timeout_counter_willOverflow = (main_fsm_lock_timeout_counter_willOverflowIfInc && main_fsm_lock_timeout_counter_willIncrement);
  always @(*) begin
    if(main_fsm_lock_timeout_counter_willOverflow) begin
      main_fsm_lock_timeout_counter_valueNext = 25'h0;
    end else begin
      main_fsm_lock_timeout_counter_valueNext = (main_fsm_lock_timeout_counter_value + temp_main_fsm_lock_timeout_counter_valueNext);
    end
    if(main_fsm_lock_timeout_counter_willClear) begin
      main_fsm_lock_timeout_counter_valueNext = 25'h0;
    end
  end

  assign main_fsm_lock_timeout_counter_willIncrement = 1'b1;
  assign fsm_is_place = (main_fsm_stateReg == PLACE);
  always @(*) begin
    score_score_with_bonus = 3'b000;
    case(lines_cleared_num_payload)
      5'h01 : begin
        score_score_with_bonus = 3'b001;
      end
      5'h02 : begin
        score_score_with_bonus = 3'b010;
      end
      5'h03 : begin
        score_score_with_bonus = 3'b011;
      end
      5'h04 : begin
        score_score_with_bonus = 3'b100;
      end
      default : begin
      end
    endcase
  end

  assign playfield_fsm_onExit_STANDBY = ((playfield_fsm_stateNext != STANDBY) && (playfield_fsm_stateReg == STANDBY));
  assign playfield_fsm_onExit_MOVE = ((playfield_fsm_stateNext != MOVE) && (playfield_fsm_stateReg == MOVE));
  assign playfield_fsm_onExit_CHECK = ((playfield_fsm_stateNext != CHECK) && (playfield_fsm_stateReg == CHECK));
  assign playfield_fsm_onExit_ERASE = ((playfield_fsm_stateNext != ERASE) && (playfield_fsm_stateReg == ERASE));
  assign playfield_fsm_onExit_UPDATE = ((playfield_fsm_stateNext != UPDATE) && (playfield_fsm_stateReg == UPDATE));
  assign playfield_fsm_onExit_START_REFRESH = ((playfield_fsm_stateNext != START_REFRESH) && (playfield_fsm_stateReg == START_REFRESH));
  assign playfield_fsm_onExit_WAIT_FRESH_DONE = ((playfield_fsm_stateNext != WAIT_FRESH_DONE) && (playfield_fsm_stateReg == WAIT_FRESH_DONE));
  assign playfield_fsm_onExit_STATUS = ((playfield_fsm_stateNext != STATUS) && (playfield_fsm_stateReg == STATUS));
  assign playfield_fsm_onExit_FREEZE_CTRL = ((playfield_fsm_stateNext != FREEZE_CTRL) && (playfield_fsm_stateReg == FREEZE_CTRL));
  assign playfield_fsm_onEntry_STANDBY = ((playfield_fsm_stateNext == STANDBY) && (playfield_fsm_stateReg != STANDBY));
  assign playfield_fsm_onEntry_MOVE = ((playfield_fsm_stateNext == MOVE) && (playfield_fsm_stateReg != MOVE));
  assign playfield_fsm_onEntry_CHECK = ((playfield_fsm_stateNext == CHECK) && (playfield_fsm_stateReg != CHECK));
  assign playfield_fsm_onEntry_ERASE = ((playfield_fsm_stateNext == ERASE) && (playfield_fsm_stateReg != ERASE));
  assign playfield_fsm_onEntry_UPDATE = ((playfield_fsm_stateNext == UPDATE) && (playfield_fsm_stateReg != UPDATE));
  assign playfield_fsm_onEntry_START_REFRESH = ((playfield_fsm_stateNext == START_REFRESH) && (playfield_fsm_stateReg != START_REFRESH));
  assign playfield_fsm_onEntry_WAIT_FRESH_DONE = ((playfield_fsm_stateNext == WAIT_FRESH_DONE) && (playfield_fsm_stateReg != WAIT_FRESH_DONE));
  assign playfield_fsm_onEntry_STATUS = ((playfield_fsm_stateNext == STATUS) && (playfield_fsm_stateReg != STATUS));
  assign playfield_fsm_onEntry_FREEZE_CTRL = ((playfield_fsm_stateNext == FREEZE_CTRL) && (playfield_fsm_stateReg != FREEZE_CTRL));
  assign playfield_fsm_debug = playfield_fsm_stateReg;
  assign main_fsm_onExit_IDLE = ((main_fsm_stateNext != IDLE) && (main_fsm_stateReg == IDLE));
  assign main_fsm_onExit_GAME_START = ((main_fsm_stateNext != GAME_START) && (main_fsm_stateReg == GAME_START));
  assign main_fsm_onExit_RANDOM_GEN = ((main_fsm_stateNext != RANDOM_GEN) && (main_fsm_stateReg == RANDOM_GEN));
  assign temp_shape_cur = piece_gen_io_shape_payload;
  assign main_fsm_onExit_PLACE = ((main_fsm_stateNext != PLACE) && (main_fsm_stateReg == PLACE));
  assign main_fsm_onExit_END_1 = ((main_fsm_stateNext != END_1) && (main_fsm_stateReg == END_1));
  assign main_fsm_onExit_FALLING = ((main_fsm_stateNext != FALLING) && (main_fsm_stateReg == FALLING));
  assign main_fsm_onExit_LOCK = ((main_fsm_stateNext != LOCK) && (main_fsm_stateReg == LOCK));
  assign main_fsm_onExit_LOCKDOWN = ((main_fsm_stateNext != LOCKDOWN) && (main_fsm_stateReg == LOCKDOWN));
  assign main_fsm_onExit_PATTERN = ((main_fsm_stateNext != PATTERN) && (main_fsm_stateReg == PATTERN));
  assign main_fsm_onEntry_IDLE = ((main_fsm_stateNext == IDLE) && (main_fsm_stateReg != IDLE));
  assign main_fsm_onEntry_GAME_START = ((main_fsm_stateNext == GAME_START) && (main_fsm_stateReg != GAME_START));
  assign main_fsm_onEntry_RANDOM_GEN = ((main_fsm_stateNext == RANDOM_GEN) && (main_fsm_stateReg != RANDOM_GEN));
  assign main_fsm_onEntry_PLACE = ((main_fsm_stateNext == PLACE) && (main_fsm_stateReg != PLACE));
  assign main_fsm_onEntry_END_1 = ((main_fsm_stateNext == END_1) && (main_fsm_stateReg != END_1));
  assign main_fsm_onEntry_FALLING = ((main_fsm_stateNext == FALLING) && (main_fsm_stateReg != FALLING));
  assign main_fsm_onEntry_LOCK = ((main_fsm_stateNext == LOCK) && (main_fsm_stateReg != LOCK));
  assign main_fsm_onEntry_LOCKDOWN = ((main_fsm_stateNext == LOCKDOWN) && (main_fsm_stateReg != LOCKDOWN));
  assign main_fsm_onEntry_PATTERN = ((main_fsm_stateNext == PATTERN) && (main_fsm_stateReg != PATTERN));
  assign main_fsm_debug = main_fsm_stateReg;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      update <= 1'b0;
      block_set <= 1'b0;
      clear_start <= 1'b0;
      restart <= 1'b0;
      lines_cleared_num_valid <= 1'b0;
      id_debug <= 5'h0;
      gen_piece_en <= 1'b0;
      block_skip_en <= 1'b0;
      pos_x_cur <= 4'b0000;
      pos_y_cur <= 5'h0;
      rot_cur <= 2'b00;
      req_valid <= 1'b0;
      pos_x_chk <= 4'b0000;
      pos_y_chk <= 5'h0;
      rot_chk <= 2'b00;
      move_en <= 1'b0;
      ctrl_en <= 1'b0;
      drop_down <= 1'b0;
      place_en <= 1'b0;
      playfield_fsm_result <= 1'b0;
      playfield_fsm_reset <= 1'b0;
      freeze_ctrl_cnt_value <= 5'h0;
      debug_move_type <= 3'b000;
      main_fsm_drop_timeout_state <= 1'b0;
      main_fsm_drop_timeout_counter_value <= 25'h0;
      main_fsm_lock_timeout_state <= 1'b0;
      main_fsm_lock_timeout_counter_value <= 25'h0;
      score_total_score <= 8'h0;
      playfield_fsm_stateReg <= STANDBY;
      main_fsm_stateReg <= IDLE;
    end else begin
      lines_cleared_num_valid <= play_field_1_lines_cleared_valid;
      req_valid <= 1'b0;
      update <= 1'b0;
      block_set <= 1'b1;
      freeze_ctrl_cnt_value <= freeze_ctrl_cnt_valueNext;
      gen_piece_en <= 1'b0;
      drop_down <= 1'b0;
      move_en <= 1'b0;
      place_en <= 1'b0;
      restart <= 1'b0;
      playfield_fsm_reset <= 1'b0;
      clear_start <= 1'b0;
      main_fsm_drop_timeout_counter_value <= main_fsm_drop_timeout_counter_valueNext;
      if(main_fsm_drop_timeout_counter_willOverflow) begin
        main_fsm_drop_timeout_state <= 1'b1;
      end
      main_fsm_lock_timeout_counter_value <= main_fsm_lock_timeout_counter_valueNext;
      if(main_fsm_lock_timeout_counter_willOverflow) begin
        main_fsm_lock_timeout_state <= 1'b1;
      end
      if((main_fsm_stateReg == GAME_START)) begin
        score_total_score <= 8'h0;
      end
      if(lines_cleared_num_valid) begin
        score_total_score <= (score_total_score + temp_score_total_score);
      end
      playfield_fsm_stateReg <= playfield_fsm_stateNext;
      case(playfield_fsm_stateReg)
        MOVE : begin
          block_set <= 1'b0;
          pos_x_chk <= pos_x_cur;
          pos_y_chk <= pos_y_cur;
          rot_chk <= rot_cur;
          if(temp_when) begin
            pos_x_chk <= (pos_x_cur - 4'b0001);
          end
          if(temp_when_1) begin
            pos_x_chk <= (pos_x_cur + 4'b0001);
            debug_move_type <= 3'b010;
          end
          if(temp_when_2) begin
            rot_chk <= (rot_cur + 2'b01);
            debug_move_type <= 3'b011;
          end
          if(temp_when_3) begin
            pos_y_chk <= (pos_y_cur + 5'h01);
          end
          if(ctrl_en) begin
            if(move_left) begin
              debug_move_type <= 3'b001;
            end else begin
              if(move_right) begin
                debug_move_type <= 3'b010;
              end else begin
                if(move_down) begin
                  debug_move_type <= 3'b011;
                end else begin
                  if(rotate) begin
                    debug_move_type <= 3'b100;
                  end
                end
              end
            end
          end else begin
            if(drop_down) begin
              debug_move_type <= 3'b101;
            end else begin
              if(place_en) begin
                debug_move_type <= 3'b110;
              end
            end
          end
        end
        CHECK : begin
          block_skip_en <= (! fsm_is_place);
        end
        ERASE : begin
          update <= 1'b1;
          block_set <= 1'b0;
        end
        UPDATE : begin
          update <= 1'b1;
          if(collision_in_valid) begin
            playfield_fsm_result <= 1'b1;
          end
        end
        START_REFRESH : begin
          block_set <= 1'b0;
        end
        WAIT_FRESH_DONE : begin
        end
        STATUS : begin
          block_set <= 1'b0;
        end
        FREEZE_CTRL : begin
        end
        default : begin
        end
      endcase
      if(playfield_fsm_onExit_MOVE) begin
        playfield_fsm_result <= 1'b0;
      end
      if(playfield_fsm_onExit_CHECK) begin
        block_skip_en <= 1'b0;
      end
      if(playfield_fsm_onExit_ERASE) begin
        pos_x_cur <= pos_x_chk;
        pos_y_cur <= pos_y_chk;
        rot_cur <= rot_chk;
      end
      if(playfield_fsm_onEntry_CHECK) begin
        req_valid <= 1'b1;
      end
      if(playfield_fsm_onEntry_ERASE) begin
        req_valid <= 1'b1;
      end
      if(playfield_fsm_onEntry_UPDATE) begin
        req_valid <= 1'b1;
      end
      main_fsm_stateReg <= main_fsm_stateNext;
      case(main_fsm_stateReg)
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
        LOCK : begin
        end
        LOCKDOWN : begin
        end
        PATTERN : begin
        end
        default : begin
          restart <= 1'b1;
        end
      endcase
      if(main_fsm_onExit_RANDOM_GEN) begin
        pos_x_cur <= start_x;
        pos_y_cur <= start_y;
        rot_cur <= 2'b00;
      end
      if(main_fsm_onEntry_RANDOM_GEN) begin
        move_en <= 1'b1;
        gen_piece_en <= 1'b1;
      end
      if(main_fsm_onEntry_PLACE) begin
        place_en <= 1'b1;
        id_debug <= (id_debug + 5'h01);
      end
      if(main_fsm_onEntry_FALLING) begin
        main_fsm_drop_timeout_state <= 1'b0;
        ctrl_en <= 1'b1;
      end
      if(main_fsm_onEntry_LOCK) begin
        ctrl_en <= 1'b0;
        drop_down <= 1'b1;
      end
      if(main_fsm_onEntry_LOCKDOWN) begin
        main_fsm_lock_timeout_state <= 1'b0;
      end
      if(main_fsm_onEntry_PATTERN) begin
        playfield_fsm_reset <= 1'b1;
        clear_start <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    lines_cleared_num_payload <= play_field_1_lines_cleared_payload;
    case(playfield_fsm_stateReg)
      MOVE : begin
        shape_chk <= shape_cur;
      end
      CHECK : begin
      end
      ERASE : begin
      end
      UPDATE : begin
      end
      START_REFRESH : begin
      end
      WAIT_FRESH_DONE : begin
      end
      STATUS : begin
      end
      FREEZE_CTRL : begin
      end
      default : begin
      end
    endcase
    if(main_fsm_onExit_RANDOM_GEN) begin
      shape_cur <= temp_shape_cur;
    end
  end


endmodule

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

module picoller (
  input  wire          piece_in_valid,
  output wire          piece_in_ready,
  input  wire [3:0]    piece_in_payload_orign_x,
  input  wire [4:0]    piece_in_payload_orign_y,
  input  wire [2:0]    piece_in_payload_type,
  input  wire [1:0]    piece_in_payload_rot,
  output wire          collision_out_valid,
  output wire          collision_out_payload,
  input  wire          update,
  input  wire          block_set,
  input  wire          block_skip_en,
  output wire          block_pos_valid,
  output wire [3:0]    block_pos_payload_x,
  output wire [4:0]    block_pos_payload_y,
  input  wire          block_val_valid,
  input  wire          block_val_payload,
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

  wire                collision_checker_1_block_wr_en;
  wire                piece_checker_1_piece_in_ready;
  wire                piece_checker_1_blocks_out_valid;
  wire       [3:0]    piece_checker_1_blocks_out_payload_x;
  wire       [4:0]    piece_checker_1_blocks_out_payload_y;
  wire                piece_checker_1_collision_out_valid;
  wire                piece_checker_1_collision_out_payload;
  wire                collision_checker_1_block_pos_valid;
  wire       [3:0]    collision_checker_1_block_pos_payload_x;
  wire       [4:0]    collision_checker_1_block_pos_payload_y;
  wire                collision_checker_1_hit_status_valid;
  wire                collision_checker_1_hit_status_payload_is_occupied;
  wire                collision_checker_1_hit_status_payload_is_wall;
  wire                piece_checker_1_blocks_out_toFlow_valid;
  wire       [3:0]    piece_checker_1_blocks_out_toFlow_payload_x;
  wire       [4:0]    piece_checker_1_blocks_out_toFlow_payload_y;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_type_string;
  `endif


  piece_checker piece_checker_1 (
    .piece_in_valid                 (piece_in_valid                                    ), //i
    .piece_in_ready                 (piece_checker_1_piece_in_ready                    ), //o
    .piece_in_payload_orign_x       (piece_in_payload_orign_x[3:0]                     ), //i
    .piece_in_payload_orign_y       (piece_in_payload_orign_y[4:0]                     ), //i
    .piece_in_payload_type          (piece_in_payload_type[2:0]                        ), //i
    .piece_in_payload_rot           (piece_in_payload_rot[1:0]                         ), //i
    .blocks_out_valid               (piece_checker_1_blocks_out_valid                  ), //o
    .blocks_out_ready               (1'b1                                              ), //i
    .blocks_out_payload_x           (piece_checker_1_blocks_out_payload_x[3:0]         ), //o
    .blocks_out_payload_y           (piece_checker_1_blocks_out_payload_y[4:0]         ), //o
    .hit_status_valid               (collision_checker_1_hit_status_valid              ), //i
    .hit_status_payload_is_occupied (collision_checker_1_hit_status_payload_is_occupied), //i
    .hit_status_payload_is_wall     (collision_checker_1_hit_status_payload_is_wall    ), //i
    .collision_out_valid            (piece_checker_1_collision_out_valid               ), //o
    .collision_out_payload          (piece_checker_1_collision_out_payload             ), //o
    .clk                            (clk                                               ), //i
    .reset                          (reset                                             )  //i
  );
  collision_checker collision_checker_1 (
    .block_in_valid                 (piece_checker_1_blocks_out_toFlow_valid           ), //i
    .block_in_payload_x             (piece_checker_1_blocks_out_toFlow_payload_x[3:0]  ), //i
    .block_in_payload_y             (piece_checker_1_blocks_out_toFlow_payload_y[4:0]  ), //i
    .block_skip_en                  (block_skip_en                                     ), //i
    .block_wr_en                    (collision_checker_1_block_wr_en                   ), //i
    .block_pos_valid                (collision_checker_1_block_pos_valid               ), //o
    .block_pos_payload_x            (collision_checker_1_block_pos_payload_x[3:0]      ), //o
    .block_pos_payload_y            (collision_checker_1_block_pos_payload_y[4:0]      ), //o
    .block_val_valid                (block_val_valid                                   ), //i
    .block_val_payload              (block_val_payload                                 ), //i
    .hit_status_valid               (collision_checker_1_hit_status_valid              ), //o
    .hit_status_payload_is_occupied (collision_checker_1_hit_status_payload_is_occupied), //o
    .hit_status_payload_is_wall     (collision_checker_1_hit_status_payload_is_wall    ), //o
    .clk                            (clk                                               ), //i
    .reset                          (reset                                             )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_in_payload_type)
      I : piece_in_payload_type_string = "I";
      J : piece_in_payload_type_string = "J";
      L : piece_in_payload_type_string = "L";
      O : piece_in_payload_type_string = "O";
      S : piece_in_payload_type_string = "S";
      T : piece_in_payload_type_string = "T";
      Z : piece_in_payload_type_string = "Z";
      default : piece_in_payload_type_string = "?";
    endcase
  end
  `endif

  assign piece_in_ready = piece_checker_1_piece_in_ready;
  assign collision_out_valid = piece_checker_1_collision_out_valid;
  assign collision_out_payload = piece_checker_1_collision_out_payload;
  assign piece_checker_1_blocks_out_toFlow_valid = piece_checker_1_blocks_out_valid;
  assign piece_checker_1_blocks_out_toFlow_payload_x = piece_checker_1_blocks_out_payload_x;
  assign piece_checker_1_blocks_out_toFlow_payload_y = piece_checker_1_blocks_out_payload_y;
  assign collision_checker_1_block_wr_en = (update && block_set);
  assign block_pos_valid = collision_checker_1_block_pos_valid;
  assign block_pos_payload_x = collision_checker_1_block_pos_payload_x;
  assign block_pos_payload_y = collision_checker_1_block_pos_payload_y;

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

module collision_checker (
  input  wire          block_in_valid,
  input  wire [3:0]    block_in_payload_x,
  input  wire [4:0]    block_in_payload_y,
  input  wire          block_skip_en,
  input  wire          block_wr_en,
  output wire          block_pos_valid,
  output wire [3:0]    block_pos_payload_x,
  output wire [4:0]    block_pos_payload_y,
  input  wire          block_val_valid,
  input  wire          block_val_payload,
  output wire          hit_status_valid,
  output wire          hit_status_payload_is_occupied,
  output wire          hit_status_payload_is_wall,
  input  wire          clk,
  input  wire          reset
);

  wire       [3:0]    blocks_prev_reset_x;
  wire       [4:0]    blocks_prev_reset_y;
  wire                temp_1;
  wire       [3:0]    blocks_prev_0_x;
  wire       [4:0]    blocks_prev_0_y;
  wire       [3:0]    blocks_prev_1_x;
  wire       [4:0]    blocks_prev_1_y;
  wire       [3:0]    blocks_prev_2_x;
  wire       [4:0]    blocks_prev_2_y;
  wire       [3:0]    blocks_prev_3_x;
  wire       [4:0]    blocks_prev_3_y;
  reg        [3:0]    temp_blocks_prev_0_x;
  reg        [4:0]    temp_blocks_prev_0_y;
  reg        [3:0]    temp_blocks_prev_1_x;
  reg        [4:0]    temp_blocks_prev_1_y;
  reg        [3:0]    temp_blocks_prev_2_x;
  reg        [4:0]    temp_blocks_prev_2_y;
  reg        [3:0]    temp_blocks_prev_3_x;
  reg        [4:0]    temp_blocks_prev_3_y;
  wire                block_req_valid;
  wire       [3:0]    block_req_payload_x;
  wire       [4:0]    block_req_payload_y;
  wire                block_skip;
  reg        [3:0]    bit_sel;
  reg                 wall_hit;
  reg                 bottom_hit;
  wire                left_wall_hit;
  wire                right_wall_hit;
  wire                wall_hit_pre;
  reg                 valid_1d;
  wire                valid_fall_edge;
  reg                 valid_fall_edge_1d;
  wire                occupied_enable;
  reg                 occupied;

  assign blocks_prev_reset_x = 4'b0000;
  assign blocks_prev_reset_y = 5'h0;
  assign temp_1 = (block_in_valid && block_wr_en);
  assign blocks_prev_0_x = temp_blocks_prev_0_x;
  assign blocks_prev_0_y = temp_blocks_prev_0_y;
  assign blocks_prev_1_x = temp_blocks_prev_1_x;
  assign blocks_prev_1_y = temp_blocks_prev_1_y;
  assign blocks_prev_2_x = temp_blocks_prev_2_x;
  assign blocks_prev_2_y = temp_blocks_prev_2_y;
  assign blocks_prev_3_x = temp_blocks_prev_3_x;
  assign blocks_prev_3_y = temp_blocks_prev_3_y;
  assign block_skip = (((((1'b0 || ((blocks_prev_0_x == block_in_payload_x) && (blocks_prev_0_y == block_in_payload_y))) || ((blocks_prev_1_x == block_in_payload_x) && (blocks_prev_1_y == block_in_payload_y))) || ((blocks_prev_2_x == block_in_payload_x) && (blocks_prev_2_y == block_in_payload_y))) || ((blocks_prev_3_x == block_in_payload_x) && (blocks_prev_3_y == block_in_payload_y))) && block_skip_en);
  assign block_req_payload_x = block_in_payload_x;
  assign block_req_payload_y = block_in_payload_y;
  assign block_req_valid = ((! block_skip) && block_in_valid);
  assign block_pos_valid = block_req_valid;
  assign block_pos_payload_x = block_req_payload_x;
  assign block_pos_payload_y = block_req_payload_y;
  assign left_wall_hit = (! (|bit_sel));
  assign right_wall_hit = (4'b1011 <= bit_sel);
  assign wall_hit_pre = (((bottom_hit || left_wall_hit) || right_wall_hit) || wall_hit);
  assign valid_fall_edge = ((! block_in_valid) && valid_1d);
  assign occupied_enable = (block_val_valid && (! occupied));
  assign hit_status_valid = valid_fall_edge_1d;
  assign hit_status_payload_is_wall = wall_hit;
  assign hit_status_payload_is_occupied = (occupied && (! wall_hit));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      temp_blocks_prev_0_x <= blocks_prev_reset_x;
      temp_blocks_prev_0_y <= blocks_prev_reset_y;
      temp_blocks_prev_1_x <= blocks_prev_reset_x;
      temp_blocks_prev_1_y <= blocks_prev_reset_y;
      temp_blocks_prev_2_x <= blocks_prev_reset_x;
      temp_blocks_prev_2_y <= blocks_prev_reset_y;
      temp_blocks_prev_3_x <= blocks_prev_reset_x;
      temp_blocks_prev_3_y <= blocks_prev_reset_y;
      bit_sel <= 4'b0000;
      wall_hit <= 1'b0;
      bottom_hit <= 1'b0;
      valid_1d <= 1'b0;
      valid_fall_edge_1d <= 1'b0;
      occupied <= 1'b0;
    end else begin
      if(temp_1) begin
        temp_blocks_prev_0_x <= block_in_payload_x;
        temp_blocks_prev_0_y <= block_in_payload_y;
      end
      if(temp_1) begin
        temp_blocks_prev_1_x <= temp_blocks_prev_0_x;
        temp_blocks_prev_1_y <= temp_blocks_prev_0_y;
      end
      if(temp_1) begin
        temp_blocks_prev_2_x <= temp_blocks_prev_1_x;
        temp_blocks_prev_2_y <= temp_blocks_prev_1_y;
      end
      if(temp_1) begin
        temp_blocks_prev_3_x <= temp_blocks_prev_2_x;
        temp_blocks_prev_3_y <= temp_blocks_prev_2_y;
      end
      bit_sel <= block_req_payload_x;
      bottom_hit <= (5'h16 <= block_req_payload_y);
      valid_1d <= block_in_valid;
      valid_fall_edge_1d <= valid_fall_edge;
      if(valid_fall_edge_1d) begin
        wall_hit <= 1'b0;
      end
      if(valid_1d) begin
        wall_hit <= wall_hit_pre;
      end
      if(occupied_enable) begin
        occupied <= block_val_payload;
      end
      if(valid_fall_edge_1d) begin
        occupied <= 1'b0;
      end
    end
  end


endmodule

module piece_checker (
  input  wire          piece_in_valid,
  output reg           piece_in_ready,
  input  wire [3:0]    piece_in_payload_orign_x,
  input  wire [4:0]    piece_in_payload_orign_y,
  input  wire [2:0]    piece_in_payload_type,
  input  wire [1:0]    piece_in_payload_rot,
  output wire          blocks_out_valid,
  input  wire          blocks_out_ready,
  output wire [3:0]    blocks_out_payload_x,
  output wire [4:0]    blocks_out_payload_y,
  input  wire          hit_status_valid,
  input  wire          hit_status_payload_is_occupied,
  input  wire          hit_status_payload_is_wall,
  output wire          collision_out_valid,
  output wire          collision_out_payload,
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

  wire       [1:0]    temp_temp_blk_offset_payload_x_1;
  wire       [0:0]    temp_temp_blk_offset_payload_x_1_1;
  reg        [3:0]    temp_temp_blk_offset_payload_x_4;
  wire       [3:0]    temp_test_blk_pos_x;
  wire       [4:0]    temp_test_blk_pos_y;
  reg        [1:0]    blks_offset_0_x;
  reg        [1:0]    blks_offset_0_y;
  reg        [1:0]    blks_offset_1_x;
  reg        [1:0]    blks_offset_1_y;
  reg        [1:0]    blks_offset_2_x;
  reg        [1:0]    blks_offset_2_y;
  reg        [1:0]    blks_offset_3_x;
  reg        [1:0]    blks_offset_3_y;
  wire                piece_valid;
  reg                 piece_ready;
  wire       [3:0]    piece_payload_orign_x;
  wire       [4:0]    piece_payload_orign_y;
  wire       [2:0]    piece_payload_type;
  wire       [1:0]    piece_payload_rot;
  reg                 piece_in_rValid;
  wire                piece_in_fire;
  reg        [3:0]    piece_in_rData_orign_x;
  reg        [4:0]    piece_in_rData_orign_y;
  reg        [2:0]    piece_in_rData_type;
  reg        [1:0]    piece_in_rData_rot;
  wire                blk_offset_valid;
  wire                blk_offset_ready;
  wire       [1:0]    blk_offset_payload_x;
  wire       [1:0]    blk_offset_payload_y;
  wire                piece_stage_valid;
  wire                piece_stage_ready;
  wire       [3:0]    piece_stage_payload_orign_x;
  wire       [4:0]    piece_stage_payload_orign_y;
  wire       [2:0]    piece_stage_payload_type;
  wire       [1:0]    piece_stage_payload_rot;
  reg                 piece_rValid;
  reg        [3:0]    piece_rData_orign_x;
  reg        [4:0]    piece_rData_orign_y;
  reg        [2:0]    piece_rData_type;
  reg        [1:0]    piece_rData_rot;
  wire                piece_offset_valid;
  wire                piece_offset_ready;
  wire       [1:0]    piece_offset_payload_0_x;
  wire       [1:0]    piece_offset_payload_0_y;
  wire       [1:0]    piece_offset_payload_1_x;
  wire       [1:0]    piece_offset_payload_1_y;
  wire       [1:0]    piece_offset_payload_2_x;
  wire       [1:0]    piece_offset_payload_2_y;
  wire       [1:0]    piece_offset_payload_3_x;
  wire       [1:0]    piece_offset_payload_3_y;
  wire                blk_offset_fire;
  reg                 temp_blk_offset_payload_x;
  reg        [1:0]    temp_blk_offset_payload_x_1;
  reg        [1:0]    temp_blk_offset_payload_x_2;
  wire                temp_piece_offset_ready;
  wire       [15:0]   temp_blk_offset_payload_x_3;
  wire       [3:0]    temp_blk_offset_payload_x_4;
  wire       [3:0]    test_blk_pos_x;
  wire       [4:0]    test_blk_pos_y;
  wire                blk_offset_translated_valid;
  reg                 blk_offset_translated_ready;
  wire       [3:0]    blk_offset_translated_payload_x;
  wire       [4:0]    blk_offset_translated_payload_y;
  wire                blk_offset_translated_m2sPipe_valid;
  wire                blk_offset_translated_m2sPipe_ready;
  wire       [3:0]    blk_offset_translated_m2sPipe_payload_x;
  wire       [4:0]    blk_offset_translated_m2sPipe_payload_y;
  reg                 blk_offset_translated_rValid;
  reg        [3:0]    blk_offset_translated_rData_x;
  reg        [4:0]    blk_offset_translated_rData_y;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_type_string;
  reg [7:0] piece_payload_type_string;
  reg [7:0] piece_in_rData_type_string;
  reg [7:0] piece_stage_payload_type_string;
  reg [7:0] piece_rData_type_string;
  `endif


  assign temp_temp_blk_offset_payload_x_1_1 = temp_blk_offset_payload_x;
  assign temp_temp_blk_offset_payload_x_1 = {1'd0, temp_temp_blk_offset_payload_x_1_1};
  assign temp_test_blk_pos_x = {2'd0, blk_offset_payload_x};
  assign temp_test_blk_pos_y = {3'd0, blk_offset_payload_y};
  always @(*) begin
    case(temp_blk_offset_payload_x_2)
      2'b00 : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[3 : 0];
      2'b01 : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[7 : 4];
      2'b10 : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[11 : 8];
      default : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[15 : 12];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_in_payload_type)
      I : piece_in_payload_type_string = "I";
      J : piece_in_payload_type_string = "J";
      L : piece_in_payload_type_string = "L";
      O : piece_in_payload_type_string = "O";
      S : piece_in_payload_type_string = "S";
      T : piece_in_payload_type_string = "T";
      Z : piece_in_payload_type_string = "Z";
      default : piece_in_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_payload_type)
      I : piece_payload_type_string = "I";
      J : piece_payload_type_string = "J";
      L : piece_payload_type_string = "L";
      O : piece_payload_type_string = "O";
      S : piece_payload_type_string = "S";
      T : piece_payload_type_string = "T";
      Z : piece_payload_type_string = "Z";
      default : piece_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_in_rData_type)
      I : piece_in_rData_type_string = "I";
      J : piece_in_rData_type_string = "J";
      L : piece_in_rData_type_string = "L";
      O : piece_in_rData_type_string = "O";
      S : piece_in_rData_type_string = "S";
      T : piece_in_rData_type_string = "T";
      Z : piece_in_rData_type_string = "Z";
      default : piece_in_rData_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_stage_payload_type)
      I : piece_stage_payload_type_string = "I";
      J : piece_stage_payload_type_string = "J";
      L : piece_stage_payload_type_string = "L";
      O : piece_stage_payload_type_string = "O";
      S : piece_stage_payload_type_string = "S";
      T : piece_stage_payload_type_string = "T";
      Z : piece_stage_payload_type_string = "Z";
      default : piece_stage_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_rData_type)
      I : piece_rData_type_string = "I";
      J : piece_rData_type_string = "J";
      L : piece_rData_type_string = "L";
      O : piece_rData_type_string = "O";
      S : piece_rData_type_string = "S";
      T : piece_rData_type_string = "T";
      Z : piece_rData_type_string = "Z";
      default : piece_rData_type_string = "?";
    endcase
  end
  `endif

  assign piece_in_fire = (piece_in_valid && piece_in_ready);
  always @(*) begin
    piece_in_ready = piece_ready;
    if((! piece_valid)) begin
      piece_in_ready = 1'b1;
    end
  end

  assign piece_valid = piece_in_rValid;
  assign piece_payload_orign_x = piece_in_rData_orign_x;
  assign piece_payload_orign_y = piece_in_rData_orign_y;
  assign piece_payload_type = piece_in_rData_type;
  assign piece_payload_rot = piece_in_rData_rot;
  always @(*) begin
    piece_ready = piece_stage_ready;
    if((! piece_stage_valid)) begin
      piece_ready = 1'b1;
    end
  end

  assign piece_stage_valid = piece_rValid;
  assign piece_stage_payload_orign_x = piece_rData_orign_x;
  assign piece_stage_payload_orign_y = piece_rData_orign_y;
  assign piece_stage_payload_type = piece_rData_type;
  assign piece_stage_payload_rot = piece_rData_rot;
  assign piece_offset_valid = piece_stage_valid;
  assign piece_stage_ready = piece_offset_ready;
  assign piece_offset_payload_0_x = blks_offset_0_x;
  assign piece_offset_payload_0_y = blks_offset_0_y;
  assign piece_offset_payload_1_x = blks_offset_1_x;
  assign piece_offset_payload_1_y = blks_offset_1_y;
  assign piece_offset_payload_2_x = blks_offset_2_x;
  assign piece_offset_payload_2_y = blks_offset_2_y;
  assign piece_offset_payload_3_x = blks_offset_3_x;
  assign piece_offset_payload_3_y = blks_offset_3_y;
  assign blk_offset_fire = (blk_offset_valid && blk_offset_ready);
  always @(*) begin
    temp_blk_offset_payload_x = 1'b0;
    if(blk_offset_fire) begin
      temp_blk_offset_payload_x = 1'b1;
    end
  end

  assign temp_piece_offset_ready = (temp_blk_offset_payload_x_2 == 2'b11);
  always @(*) begin
    temp_blk_offset_payload_x_1 = (temp_blk_offset_payload_x_2 + temp_temp_blk_offset_payload_x_1);
    if(1'b0) begin
      temp_blk_offset_payload_x_1 = 2'b00;
    end
  end

  assign blk_offset_valid = piece_offset_valid;
  assign temp_blk_offset_payload_x_3 = {{piece_offset_payload_3_y,piece_offset_payload_3_x},{{piece_offset_payload_2_y,piece_offset_payload_2_x},{{piece_offset_payload_1_y,piece_offset_payload_1_x},{piece_offset_payload_0_y,piece_offset_payload_0_x}}}};
  assign temp_blk_offset_payload_x_4 = temp_temp_blk_offset_payload_x_4;
  assign blk_offset_payload_x = temp_blk_offset_payload_x_4[1 : 0];
  assign blk_offset_payload_y = temp_blk_offset_payload_x_4[3 : 2];
  assign piece_offset_ready = (blk_offset_ready && temp_piece_offset_ready);
  assign test_blk_pos_x = (piece_payload_orign_x + temp_test_blk_pos_x);
  assign test_blk_pos_y = (piece_payload_orign_y + temp_test_blk_pos_y);
  assign blk_offset_translated_valid = blk_offset_valid;
  assign blk_offset_ready = blk_offset_translated_ready;
  assign blk_offset_translated_payload_x = test_blk_pos_x;
  assign blk_offset_translated_payload_y = test_blk_pos_y;
  always @(*) begin
    blk_offset_translated_ready = blk_offset_translated_m2sPipe_ready;
    if((! blk_offset_translated_m2sPipe_valid)) begin
      blk_offset_translated_ready = 1'b1;
    end
  end

  assign blk_offset_translated_m2sPipe_valid = blk_offset_translated_rValid;
  assign blk_offset_translated_m2sPipe_payload_x = blk_offset_translated_rData_x;
  assign blk_offset_translated_m2sPipe_payload_y = blk_offset_translated_rData_y;
  assign blocks_out_valid = blk_offset_translated_m2sPipe_valid;
  assign blk_offset_translated_m2sPipe_ready = blocks_out_ready;
  assign blocks_out_payload_x = blk_offset_translated_m2sPipe_payload_x;
  assign blocks_out_payload_y = blk_offset_translated_m2sPipe_payload_y;
  assign collision_out_valid = hit_status_valid;
  assign collision_out_payload = (hit_status_payload_is_occupied || hit_status_payload_is_wall);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      blks_offset_0_x <= 2'b00;
      blks_offset_0_y <= 2'b00;
      blks_offset_1_x <= 2'b00;
      blks_offset_1_y <= 2'b00;
      blks_offset_2_x <= 2'b00;
      blks_offset_2_y <= 2'b00;
      blks_offset_3_x <= 2'b00;
      blks_offset_3_y <= 2'b00;
      piece_in_rValid <= 1'b0;
      piece_rValid <= 1'b0;
      temp_blk_offset_payload_x_2 <= 2'b00;
      blk_offset_translated_rValid <= 1'b0;
    end else begin
      if(piece_in_ready) begin
        piece_in_rValid <= piece_in_valid;
      end
      case(piece_payload_type)
        I : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b11;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b11;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b11;
              blks_offset_3_y <= 2'b10;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b11;
            end
          endcase
        end
        S : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b00;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b10;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        L : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b00;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b00;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        O : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
          endcase
        end
        J : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        Z : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        default : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
      endcase
      if(piece_ready) begin
        piece_rValid <= piece_valid;
      end
      temp_blk_offset_payload_x_2 <= temp_blk_offset_payload_x_1;
      if(blk_offset_translated_ready) begin
        blk_offset_translated_rValid <= blk_offset_translated_valid;
      end
    end
  end

  always @(posedge clk) begin
    if(piece_in_fire) begin
      piece_in_rData_orign_x <= piece_in_payload_orign_x;
      piece_in_rData_orign_y <= piece_in_payload_orign_y;
      piece_in_rData_type <= piece_in_payload_type;
      piece_in_rData_rot <= piece_in_payload_rot;
    end
    if(piece_ready) begin
      piece_rData_orign_x <= piece_payload_orign_x;
      piece_rData_orign_y <= piece_payload_orign_y;
      piece_rData_type <= piece_payload_type;
      piece_rData_rot <= piece_payload_rot;
    end
    if(blk_offset_translated_ready) begin
      blk_offset_translated_rData_x <= blk_offset_translated_payload_x;
      blk_offset_translated_rData_y <= blk_offset_translated_payload_y;
    end
  end


endmodule
