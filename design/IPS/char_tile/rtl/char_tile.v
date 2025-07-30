// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : char_tile
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module char_tile (
  input  wire [9:0]    x,
  input  wire [8:0]    y,
  input  wire          sol,
  input  wire [9:0]    sx_orig,
  input  wire [8:0]    sy_orig,
  input  wire          color_en,
  output wire          color_valid,
  output wire [3:0]    color_payload_r,
  output wire [3:0]    color_payload_g,
  output wire [3:0]    color_payload_b,
  input  wire          clk,
  input  wire          reset
);
  localparam IDLE = 3'd0;
  localparam LINE_START = 3'd1;
  localparam WAIT_POS = 3'd2;
  localparam FETCG_PIXEL = 3'd3;
  localparam LINE_END = 3'd4;

  wire       [7:0]    ascii_font16X8_inst_font_bitmap_byte;
  wire       [9:0]    temp_y_diff;
  wire       [9:0]    temp_y_diff_1;
  wire       [6:0]    temp_x_cnt_valueNext;
  wire       [0:0]    temp_x_cnt_valueNext_1;
  wire       [7:0]    temp_when;
  wire       [13:0]   temp_rom_addr_block_1;
  wire       [13:0]   temp_rom_addr_block_2;
  wire       [4:0]    temp_rom_addr_block_3;
  wire       [13:0]   temp_rom_addr_block_4;
  wire       [3:0]    temp_rom_addr_block_5;
  wire       [10:0]   temp_rom_addr;
  wire       [8:0]    temp_rom_addr_1;
  wire       [3:0]    temp_rom_addr_2;
  wire       [9:0]    y_diff;
  wire       [8:0]    y_diff_scale;
  wire                y_valid;
  reg        [9:0]    sx_early_r;
  wire                sop;
  reg        [10:0]   rom_addr_block;
  reg        [10:0]   rom_addr;
  reg                 draw_running;
  reg                 scale_cnt_willIncrement;
  reg                 scale_cnt_willClear;
  reg        [0:0]    scale_cnt_valueNext;
  reg        [0:0]    scale_cnt_value;
  wire                scale_cnt_willOverflowIfInc;
  wire                scale_cnt_willOverflow;
  reg                 x_cnt_willIncrement;
  reg                 x_cnt_willClear;
  reg        [6:0]    x_cnt_valueNext;
  reg        [6:0]    x_cnt_value;
  wire                x_cnt_willOverflowIfInc;
  wire                x_cnt_willOverflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    temp_x_pixel_offset;
  reg        [2:0]    x_pixel_offset;
  reg        [3:0]    color_r;
  reg        [3:0]    color_g;
  reg        [3:0]    color_b;
  reg                 draw_running_delay_1;
  reg                 draw_running_delay_2;
  reg                 draw_running_delay_3;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire       [8:0]    temp_rom_addr_block;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_LINE_START;
  wire                fsm_onExit_WAIT_POS;
  wire                fsm_onExit_FETCG_PIXEL;
  wire                fsm_onExit_LINE_END;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_LINE_START;
  wire                fsm_onEntry_WAIT_POS;
  wire                fsm_onEntry_FETCG_PIXEL;
  wire                fsm_onEntry_LINE_END;
  `ifndef SYNTHESIS
  reg [87:0] fsm_stateReg_string;
  reg [87:0] fsm_stateNext_string;
  `endif


  assign temp_y_diff = {1'b0,y};
  assign temp_y_diff_1 = {1'b0,sy_orig};
  assign temp_x_cnt_valueNext_1 = x_cnt_willIncrement;
  assign temp_x_cnt_valueNext = {6'd0, temp_x_cnt_valueNext_1};
  assign temp_when = {ascii_font16X8_inst_font_bitmap_byte[0],{ascii_font16X8_inst_font_bitmap_byte[1],{ascii_font16X8_inst_font_bitmap_byte[2],{ascii_font16X8_inst_font_bitmap_byte[3],{ascii_font16X8_inst_font_bitmap_byte[4],{ascii_font16X8_inst_font_bitmap_byte[5],{ascii_font16X8_inst_font_bitmap_byte[6],ascii_font16X8_inst_font_bitmap_byte[7]}}}}}}};
  assign temp_rom_addr_block_1 = (temp_rom_addr_block_2 + temp_rom_addr_block_4);
  assign temp_rom_addr_block_2 = (temp_rom_addr_block_3 * 9'h100);
  assign temp_rom_addr_block_3 = (temp_rom_addr_block >>> 3'd4);
  assign temp_rom_addr_block_5 = temp_rom_addr_block[3 : 0];
  assign temp_rom_addr_block_4 = {10'd0, temp_rom_addr_block_5};
  assign temp_rom_addr_1 = (temp_rom_addr_2 * 5'h10);
  assign temp_rom_addr = {2'd0, temp_rom_addr_1};
  assign temp_rom_addr_2 = (x_cnt_value >>> 2'd3);
  ascii_font16x8 #(
    .wordWidth    (8 ),
    .addressWidth (11)
  ) ascii_font16X8_inst (
    .clk              (clk                                      ), //i
    .font_bitmap_addr (rom_addr[10:0]                           ), //i
    .font_bitmap_byte (ascii_font16X8_inst_font_bitmap_byte[7:0])  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE       ";
      LINE_START : fsm_stateReg_string = "LINE_START ";
      WAIT_POS : fsm_stateReg_string = "WAIT_POS   ";
      FETCG_PIXEL : fsm_stateReg_string = "FETCG_PIXEL";
      LINE_END : fsm_stateReg_string = "LINE_END   ";
      default : fsm_stateReg_string = "???????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE       ";
      LINE_START : fsm_stateNext_string = "LINE_START ";
      WAIT_POS : fsm_stateNext_string = "WAIT_POS   ";
      FETCG_PIXEL : fsm_stateNext_string = "FETCG_PIXEL";
      LINE_END : fsm_stateNext_string = "LINE_END   ";
      default : fsm_stateNext_string = "???????????";
    endcase
  end
  `endif

  assign y_diff = ($signed(temp_y_diff) - $signed(temp_y_diff_1));
  assign y_diff_scale = (y_diff >>> 1'd1);
  assign y_valid = ((! y_diff[9]) && ($signed(y_diff_scale) < $signed(9'h080)));
  assign sop = (x == sx_early_r);
  always @(*) begin
    scale_cnt_willIncrement = 1'b0;
    if(draw_running) begin
      scale_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    scale_cnt_willClear = 1'b0;
    x_cnt_willClear = 1'b0;
    fsm_wantStart = 1'b0;
    draw_running = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      LINE_START : begin
        if(y_valid) begin
          fsm_stateNext = WAIT_POS;
        end else begin
          fsm_stateNext = IDLE;
        end
      end
      WAIT_POS : begin
        if(sop) begin
          x_cnt_willClear = 1'b1;
          scale_cnt_willClear = 1'b1;
          fsm_stateNext = FETCG_PIXEL;
        end
      end
      FETCG_PIXEL : begin
        draw_running = 1'b1;
        if((x_cnt_willOverflowIfInc && scale_cnt_willOverflowIfInc)) begin
          fsm_stateNext = LINE_END;
        end
      end
      LINE_END : begin
        fsm_stateNext = IDLE;
      end
      default : begin
        if(sol) begin
          fsm_stateNext = LINE_START;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign scale_cnt_willOverflowIfInc = (scale_cnt_value == 1'b1);
  assign scale_cnt_willOverflow = (scale_cnt_willOverflowIfInc && scale_cnt_willIncrement);
  always @(*) begin
    scale_cnt_valueNext = (scale_cnt_value + scale_cnt_willIncrement);
    if(scale_cnt_willClear) begin
      scale_cnt_valueNext = 1'b0;
    end
  end

  always @(*) begin
    x_cnt_willIncrement = 1'b0;
    if(scale_cnt_willOverflowIfInc) begin
      x_cnt_willIncrement = 1'b1;
    end
  end

  assign x_cnt_willOverflowIfInc = (x_cnt_value == 7'h7f);
  assign x_cnt_willOverflow = (x_cnt_willOverflowIfInc && x_cnt_willIncrement);
  always @(*) begin
    x_cnt_valueNext = (x_cnt_value + temp_x_cnt_valueNext);
    if(x_cnt_willClear) begin
      x_cnt_valueNext = 7'h0;
    end
  end

  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  assign color_payload_r = color_r;
  assign color_payload_g = color_g;
  assign color_payload_b = color_b;
  assign color_valid = draw_running_delay_3;
  assign temp_rom_addr_block = y_diff_scale;
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_LINE_START = ((fsm_stateNext != LINE_START) && (fsm_stateReg == LINE_START));
  assign fsm_onExit_WAIT_POS = ((fsm_stateNext != WAIT_POS) && (fsm_stateReg == WAIT_POS));
  assign fsm_onExit_FETCG_PIXEL = ((fsm_stateNext != FETCG_PIXEL) && (fsm_stateReg == FETCG_PIXEL));
  assign fsm_onExit_LINE_END = ((fsm_stateNext != LINE_END) && (fsm_stateReg == LINE_END));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_LINE_START = ((fsm_stateNext == LINE_START) && (fsm_stateReg != LINE_START));
  assign fsm_onEntry_WAIT_POS = ((fsm_stateNext == WAIT_POS) && (fsm_stateReg != WAIT_POS));
  assign fsm_onEntry_FETCG_PIXEL = ((fsm_stateNext == FETCG_PIXEL) && (fsm_stateReg != FETCG_PIXEL));
  assign fsm_onEntry_LINE_END = ((fsm_stateNext == LINE_END) && (fsm_stateReg != LINE_END));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_early_r <= 10'h0;
      rom_addr_block <= 11'h0;
      rom_addr <= 11'h0;
      scale_cnt_value <= 1'b0;
      x_cnt_value <= 7'h0;
      fsm_stateReg <= IDLE;
    end else begin
      scale_cnt_value <= scale_cnt_valueNext;
      x_cnt_value <= x_cnt_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        LINE_START : begin
          if(y_valid) begin
            sx_early_r <= (sx_orig - 10'h001);
          end
        end
        WAIT_POS : begin
          rom_addr_block <= temp_rom_addr_block_1[10:0];
        end
        FETCG_PIXEL : begin
          rom_addr <= (rom_addr_block + temp_rom_addr);
        end
        LINE_END : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    temp_x_pixel_offset <= x_cnt_value[2 : 0];
    x_pixel_offset <= temp_x_pixel_offset;
    if(temp_when[x_pixel_offset]) begin
      color_b <= 4'b1100;
      color_g <= 4'b1100;
      color_r <= 4'b1100;
    end else begin
      color_b <= 4'b1010;
      color_g <= 4'b1100;
      color_r <= 4'b0000;
    end
    draw_running_delay_1 <= draw_running;
    draw_running_delay_2 <= draw_running_delay_1;
    draw_running_delay_3 <= draw_running_delay_2;
  end


endmodule
