// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : string_draw_engine
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module string_draw_engine (
  input  wire          draw_openning_start,
  input  wire          game_start,
  input  wire          clear_playfield,
  input  wire          draw_done,
  output reg           screen_is_ready,
  output wire          draw_char_start,
  output wire [6:0]    draw_char_word,
  output wire [2:0]    draw_char_scale,
  output wire [3:0]    draw_char_color,
  output wire          draw_block_start,
  output wire [8:0]    draw_x_orig,
  output wire [7:0]    draw_y_orig,
  output wire [7:0]    draw_block_width,
  output wire [7:0]    draw_block_height,
  output wire [3:0]    draw_block_color,
  output wire [3:0]    draw_block_pat_color,
  output wire [1:0]    draw_block_fill_pattern,
  input  wire          clk,
  input  wire          reset
);
  localparam IDLE = 4'd0;
  localparam START_DRAW_OPEN = 4'd1;
  localparam WAIT_DRAW_OPEN_DONE = 4'd2;
  localparam WAIT_GAME_START = 4'd3;
  localparam START_DRAW_STRING = 4'd4;
  localparam WAIT_DRAW_STRING_DONE = 4'd5;
  localparam WAIT_DRAW_SCORE = 4'd6;
  localparam PRE_DRAW_WALL = 4'd7;
  localparam START_DRAW_WALL = 4'd8;
  localparam WAIT_DRAW_WALL_DONE = 4'd9;
  localparam DRAW_SCORE = 4'd10;

  wire       [6:0]    rom_spinal_port0;
  wire       [42:0]   wall_wall_rom_spinal_port0;
  wire       [3:0]    temp_cnt_valueNext;
  wire       [0:0]    temp_cnt_valueNext_1;
  wire       [1:0]    temp_wall_cnt_valueNext;
  wire       [0:0]    temp_wall_cnt_valueNext_1;
  wire                temp_when;
  wire                temp_when_1;
  reg                 cnt_willIncrement;
  reg                 cnt_willClear;
  reg        [3:0]    cnt_valueNext;
  reg        [3:0]    cnt_value;
  wire                cnt_willOverflowIfInc;
  wire                cnt_willOverflow;
  wire       [8:0]    wall_x;
  wire       [7:0]    wall_y;
  reg                 wall_cnt_willIncrement;
  wire                wall_cnt_willClear;
  reg        [1:0]    wall_cnt_valueNext;
  reg        [1:0]    wall_cnt_value;
  wire                wall_cnt_willOverflowIfInc;
  wire                wall_cnt_willOverflow;
  wire       [42:0]   wall_blockInfo;
  reg        [8:0]    x;
  reg        [7:0]    y;
  reg        [2:0]    scale;
  reg        [3:0]    color;
  reg                 start_char_draw;
  reg                 start_block_draw;
  reg                 logoHasRm;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  wire       [3:0]    fsm_debug;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_START_DRAW_OPEN;
  wire                fsm_onExit_WAIT_DRAW_OPEN_DONE;
  wire                fsm_onExit_WAIT_GAME_START;
  wire                fsm_onExit_START_DRAW_STRING;
  wire                fsm_onExit_WAIT_DRAW_STRING_DONE;
  wire                fsm_onExit_WAIT_DRAW_SCORE;
  wire                fsm_onExit_PRE_DRAW_WALL;
  wire                fsm_onExit_START_DRAW_WALL;
  wire                fsm_onExit_WAIT_DRAW_WALL_DONE;
  wire                fsm_onExit_DRAW_SCORE;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_START_DRAW_OPEN;
  wire                fsm_onEntry_WAIT_DRAW_OPEN_DONE;
  wire                fsm_onEntry_WAIT_GAME_START;
  wire                fsm_onEntry_START_DRAW_STRING;
  wire                fsm_onEntry_WAIT_DRAW_STRING_DONE;
  wire                fsm_onEntry_WAIT_DRAW_SCORE;
  wire                fsm_onEntry_PRE_DRAW_WALL;
  wire                fsm_onEntry_START_DRAW_WALL;
  wire                fsm_onEntry_WAIT_DRAW_WALL_DONE;
  wire                fsm_onEntry_DRAW_SCORE;
  `ifndef SYNTHESIS
  reg [167:0] fsm_stateReg_string;
  reg [167:0] fsm_stateNext_string;
  `endif

  reg [6:0] rom [0:10];
  reg [42:0] wall_wall_rom [0:3];

  assign temp_when = (cnt_value == 4'b0101);
  assign temp_when_1 = (cnt_value == 4'b1010);
  assign temp_cnt_valueNext_1 = cnt_willIncrement;
  assign temp_cnt_valueNext = {3'd0, temp_cnt_valueNext_1};
  assign temp_wall_cnt_valueNext_1 = wall_cnt_willIncrement;
  assign temp_wall_cnt_valueNext = {1'd0, temp_wall_cnt_valueNext_1};
  initial begin
    $readmemb("string_draw_engine.v_toplevel_rom.bin",rom);
  end
  assign rom_spinal_port0 = rom[cnt_value];
  initial begin
    $readmemb("string_draw_engine.v_toplevel_wall_wall_rom.bin",wall_wall_rom);
  end
  assign wall_wall_rom_spinal_port0 = wall_wall_rom[wall_cnt_value];
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE                 ";
      START_DRAW_OPEN : fsm_stateReg_string = "START_DRAW_OPEN      ";
      WAIT_DRAW_OPEN_DONE : fsm_stateReg_string = "WAIT_DRAW_OPEN_DONE  ";
      WAIT_GAME_START : fsm_stateReg_string = "WAIT_GAME_START      ";
      START_DRAW_STRING : fsm_stateReg_string = "START_DRAW_STRING    ";
      WAIT_DRAW_STRING_DONE : fsm_stateReg_string = "WAIT_DRAW_STRING_DONE";
      WAIT_DRAW_SCORE : fsm_stateReg_string = "WAIT_DRAW_SCORE      ";
      PRE_DRAW_WALL : fsm_stateReg_string = "PRE_DRAW_WALL        ";
      START_DRAW_WALL : fsm_stateReg_string = "START_DRAW_WALL      ";
      WAIT_DRAW_WALL_DONE : fsm_stateReg_string = "WAIT_DRAW_WALL_DONE  ";
      DRAW_SCORE : fsm_stateReg_string = "DRAW_SCORE           ";
      default : fsm_stateReg_string = "?????????????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE                 ";
      START_DRAW_OPEN : fsm_stateNext_string = "START_DRAW_OPEN      ";
      WAIT_DRAW_OPEN_DONE : fsm_stateNext_string = "WAIT_DRAW_OPEN_DONE  ";
      WAIT_GAME_START : fsm_stateNext_string = "WAIT_GAME_START      ";
      START_DRAW_STRING : fsm_stateNext_string = "START_DRAW_STRING    ";
      WAIT_DRAW_STRING_DONE : fsm_stateNext_string = "WAIT_DRAW_STRING_DONE";
      WAIT_DRAW_SCORE : fsm_stateNext_string = "WAIT_DRAW_SCORE      ";
      PRE_DRAW_WALL : fsm_stateNext_string = "PRE_DRAW_WALL        ";
      START_DRAW_WALL : fsm_stateNext_string = "START_DRAW_WALL      ";
      WAIT_DRAW_WALL_DONE : fsm_stateNext_string = "WAIT_DRAW_WALL_DONE  ";
      DRAW_SCORE : fsm_stateNext_string = "DRAW_SCORE           ";
      default : fsm_stateNext_string = "?????????????????????";
    endcase
  end
  `endif

  always @(*) begin
    cnt_willIncrement = 1'b0;
    cnt_willClear = 1'b0;
    wall_cnt_willIncrement = 1'b0;
    fsm_wantStart = 1'b0;
    start_char_draw = 1'b0;
    start_block_draw = 1'b0;
    screen_is_ready = 1'b0;
    cnt_willIncrement = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      START_DRAW_OPEN : begin
        start_char_draw = 1'b1;
        fsm_stateNext = WAIT_DRAW_OPEN_DONE;
      end
      WAIT_DRAW_OPEN_DONE : begin
        if(draw_done) begin
          cnt_willIncrement = 1'b1;
          if(temp_when) begin
            fsm_stateNext = WAIT_GAME_START;
          end else begin
            fsm_stateNext = START_DRAW_OPEN;
          end
        end
      end
      WAIT_GAME_START : begin
        if(logoHasRm) begin
          fsm_stateNext = START_DRAW_STRING;
        end else begin
          if(game_start) begin
            cnt_willClear = 1'b1;
            fsm_stateNext = START_DRAW_OPEN;
          end
        end
      end
      START_DRAW_STRING : begin
        start_char_draw = 1'b1;
        fsm_stateNext = WAIT_DRAW_STRING_DONE;
      end
      WAIT_DRAW_STRING_DONE : begin
        if(draw_done) begin
          cnt_willIncrement = 1'b1;
          if(temp_when_1) begin
            fsm_stateNext = WAIT_DRAW_SCORE;
          end else begin
            fsm_stateNext = START_DRAW_STRING;
          end
        end
      end
      WAIT_DRAW_SCORE : begin
        fsm_stateNext = PRE_DRAW_WALL;
      end
      PRE_DRAW_WALL : begin
        fsm_stateNext = START_DRAW_WALL;
      end
      START_DRAW_WALL : begin
        start_block_draw = 1'b1;
        fsm_stateNext = WAIT_DRAW_WALL_DONE;
      end
      WAIT_DRAW_WALL_DONE : begin
        if(draw_done) begin
          wall_cnt_willIncrement = 1'b1;
          if(wall_cnt_willOverflow) begin
            fsm_stateNext = DRAW_SCORE;
          end else begin
            fsm_stateNext = PRE_DRAW_WALL;
          end
        end
      end
      DRAW_SCORE : begin
        screen_is_ready = 1'b1;
      end
      default : begin
        if(draw_openning_start) begin
          fsm_stateNext = START_DRAW_OPEN;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign cnt_willOverflowIfInc = (cnt_value == 4'b1010);
  assign cnt_willOverflow = (cnt_willOverflowIfInc && cnt_willIncrement);
  always @(*) begin
    if(cnt_willOverflow) begin
      cnt_valueNext = 4'b0000;
    end else begin
      cnt_valueNext = (cnt_value + temp_cnt_valueNext);
    end
    if(cnt_willClear) begin
      cnt_valueNext = 4'b0000;
    end
  end

  assign draw_char_word = rom_spinal_port0;
  assign wall_cnt_willClear = 1'b0;
  assign wall_cnt_willOverflowIfInc = (wall_cnt_value == 2'b11);
  assign wall_cnt_willOverflow = (wall_cnt_willOverflowIfInc && wall_cnt_willIncrement);
  always @(*) begin
    wall_cnt_valueNext = (wall_cnt_value + temp_wall_cnt_valueNext);
    if(wall_cnt_willClear) begin
      wall_cnt_valueNext = 2'b00;
    end
  end

  assign wall_blockInfo = wall_wall_rom_spinal_port0;
  assign wall_x = wall_blockInfo[8 : 0];
  assign wall_y = wall_blockInfo[16 : 9];
  assign draw_block_width = wall_blockInfo[24 : 17];
  assign draw_block_height = wall_blockInfo[32 : 25];
  assign draw_block_color = wall_blockInfo[36 : 33];
  assign draw_block_pat_color = wall_blockInfo[40 : 37];
  assign draw_block_fill_pattern = wall_blockInfo[42 : 41];
  assign draw_x_orig = x;
  assign draw_y_orig = y;
  assign draw_char_scale = scale;
  assign draw_char_color = color;
  assign draw_char_start = start_char_draw;
  assign draw_block_start = start_block_draw;
  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_START_DRAW_OPEN = ((fsm_stateNext != START_DRAW_OPEN) && (fsm_stateReg == START_DRAW_OPEN));
  assign fsm_onExit_WAIT_DRAW_OPEN_DONE = ((fsm_stateNext != WAIT_DRAW_OPEN_DONE) && (fsm_stateReg == WAIT_DRAW_OPEN_DONE));
  assign fsm_onExit_WAIT_GAME_START = ((fsm_stateNext != WAIT_GAME_START) && (fsm_stateReg == WAIT_GAME_START));
  assign fsm_onExit_START_DRAW_STRING = ((fsm_stateNext != START_DRAW_STRING) && (fsm_stateReg == START_DRAW_STRING));
  assign fsm_onExit_WAIT_DRAW_STRING_DONE = ((fsm_stateNext != WAIT_DRAW_STRING_DONE) && (fsm_stateReg == WAIT_DRAW_STRING_DONE));
  assign fsm_onExit_WAIT_DRAW_SCORE = ((fsm_stateNext != WAIT_DRAW_SCORE) && (fsm_stateReg == WAIT_DRAW_SCORE));
  assign fsm_onExit_PRE_DRAW_WALL = ((fsm_stateNext != PRE_DRAW_WALL) && (fsm_stateReg == PRE_DRAW_WALL));
  assign fsm_onExit_START_DRAW_WALL = ((fsm_stateNext != START_DRAW_WALL) && (fsm_stateReg == START_DRAW_WALL));
  assign fsm_onExit_WAIT_DRAW_WALL_DONE = ((fsm_stateNext != WAIT_DRAW_WALL_DONE) && (fsm_stateReg == WAIT_DRAW_WALL_DONE));
  assign fsm_onExit_DRAW_SCORE = ((fsm_stateNext != DRAW_SCORE) && (fsm_stateReg == DRAW_SCORE));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_START_DRAW_OPEN = ((fsm_stateNext == START_DRAW_OPEN) && (fsm_stateReg != START_DRAW_OPEN));
  assign fsm_onEntry_WAIT_DRAW_OPEN_DONE = ((fsm_stateNext == WAIT_DRAW_OPEN_DONE) && (fsm_stateReg != WAIT_DRAW_OPEN_DONE));
  assign fsm_onEntry_WAIT_GAME_START = ((fsm_stateNext == WAIT_GAME_START) && (fsm_stateReg != WAIT_GAME_START));
  assign fsm_onEntry_START_DRAW_STRING = ((fsm_stateNext == START_DRAW_STRING) && (fsm_stateReg != START_DRAW_STRING));
  assign fsm_onEntry_WAIT_DRAW_STRING_DONE = ((fsm_stateNext == WAIT_DRAW_STRING_DONE) && (fsm_stateReg != WAIT_DRAW_STRING_DONE));
  assign fsm_onEntry_WAIT_DRAW_SCORE = ((fsm_stateNext == WAIT_DRAW_SCORE) && (fsm_stateReg != WAIT_DRAW_SCORE));
  assign fsm_onEntry_PRE_DRAW_WALL = ((fsm_stateNext == PRE_DRAW_WALL) && (fsm_stateReg != PRE_DRAW_WALL));
  assign fsm_onEntry_START_DRAW_WALL = ((fsm_stateNext == START_DRAW_WALL) && (fsm_stateReg != START_DRAW_WALL));
  assign fsm_onEntry_WAIT_DRAW_WALL_DONE = ((fsm_stateNext == WAIT_DRAW_WALL_DONE) && (fsm_stateReg != WAIT_DRAW_WALL_DONE));
  assign fsm_onEntry_DRAW_SCORE = ((fsm_stateNext == DRAW_SCORE) && (fsm_stateReg != DRAW_SCORE));
  assign fsm_debug = fsm_stateReg;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      cnt_value <= 4'b0000;
      wall_cnt_value <= 2'b00;
      logoHasRm <= 1'b0;
      fsm_stateReg <= IDLE;
    end else begin
      cnt_value <= cnt_valueNext;
      wall_cnt_value <= wall_cnt_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        START_DRAW_OPEN : begin
        end
        WAIT_DRAW_OPEN_DONE : begin
        end
        WAIT_GAME_START : begin
          if(logoHasRm) begin
            logoHasRm <= 1'b0;
          end else begin
            if(game_start) begin
              logoHasRm <= 1'b1;
            end
          end
        end
        START_DRAW_STRING : begin
        end
        WAIT_DRAW_STRING_DONE : begin
        end
        WAIT_DRAW_SCORE : begin
        end
        PRE_DRAW_WALL : begin
        end
        START_DRAW_WALL : begin
        end
        WAIT_DRAW_WALL_DONE : begin
        end
        DRAW_SCORE : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    case(fsm_stateReg)
      START_DRAW_OPEN : begin
      end
      WAIT_DRAW_OPEN_DONE : begin
        if(draw_done) begin
          if(!temp_when) begin
            x <= (x + 9'h02e);
          end
        end
      end
      WAIT_GAME_START : begin
        if(logoHasRm) begin
          x <= 9'h0ec;
          y <= 8'h17;
          scale <= 3'b000;
          color <= 4'b0110;
        end else begin
          if(game_start) begin
            x <= 9'h01c;
            y <= 8'h42;
            scale <= 3'b010;
            color <= 4'b0010;
          end
        end
      end
      START_DRAW_STRING : begin
      end
      WAIT_DRAW_STRING_DONE : begin
        if(draw_done) begin
          if(!temp_when_1) begin
            x <= (x + 9'h00c);
          end
        end
      end
      WAIT_DRAW_SCORE : begin
      end
      PRE_DRAW_WALL : begin
        x <= wall_x;
        y <= wall_y;
      end
      START_DRAW_WALL : begin
      end
      WAIT_DRAW_WALL_DONE : begin
      end
      DRAW_SCORE : begin
        x <= 9'h0;
        y <= 8'h0;
      end
      default : begin
        if(draw_openning_start) begin
          x <= 9'h01c;
          y <= 8'h42;
          scale <= 3'b010;
          color <= 4'b0110;
        end
      end
    endcase
  end


endmodule
