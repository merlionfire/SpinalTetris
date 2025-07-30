// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : racing_beam
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module racing_beam (
  input  wire [9:0]    x,
  input  wire [8:0]    y,
  input  wire          sof,
  input  wire          color_en,
  output wire          color_valid,
  output wire [3:0]    color_payload_r,
  output wire [3:0]    color_payload_g,
  output wire [3:0]    color_payload_b,
  input  wire          clk,
  input  wire          reset
);

  wire                temp_when;
  wire                temp_when_1;
  wire       [3:0]    temp_roster_bar_color_r;
  wire       [3:0]    temp_roster_bar_color_r_1;
  wire       [3:0]    temp_roster_bar_color_g;
  wire       [3:0]    temp_roster_bar_color_g_1;
  wire       [3:0]    temp_roster_bar_color_b;
  wire       [3:0]    temp_roster_bar_color_b_1;
  reg                 color_en_regNext;
  wire                eol;
  reg        [3:0]    roster_bar_color_r;
  reg        [3:0]    roster_bar_color_g;
  reg        [3:0]    roster_bar_color_b;
  reg                 roster_bar_inc;
  reg        [3:0]    roster_bar_color_cnt;
  reg        [0:0]    roster_bar_line_cnt;
  reg        [3:0]    hitomezashi_color_r;
  reg        [3:0]    hitomezashi_color_g;
  reg        [3:0]    hitomezashi_color_b;
  wire       [39:0]   hitomezashi_vStart;
  wire       [29:0]   hitomezashi_hStart;
  reg                 hitomezashi_last_h_stitch;
  wire                hitomezashi_v_line;
  wire                hitomezashi_h_line;
  wire                hitomezashi_v_on;
  wire                hitomezashi_h_on;
  wire                hitomezashi_stitch;
  reg                 color_en_regNext_1;

  assign temp_when = (roster_bar_line_cnt == 1'b1);
  assign temp_when_1 = (roster_bar_color_cnt == 4'b1001);
  assign temp_roster_bar_color_r = (roster_bar_color_r + 4'b0001);
  assign temp_roster_bar_color_r_1 = (roster_bar_color_r - 4'b0001);
  assign temp_roster_bar_color_g = (roster_bar_color_g + 4'b0001);
  assign temp_roster_bar_color_g_1 = (roster_bar_color_g - 4'b0001);
  assign temp_roster_bar_color_b = (roster_bar_color_b + 4'b0001);
  assign temp_roster_bar_color_b_1 = (roster_bar_color_b - 4'b0001);
  assign eol = ((! color_en) && color_en_regNext);
  assign hitomezashi_vStart = 40'hb7ab5cb286;
  assign hitomezashi_hStart = 30'h15c2c25d;
  assign hitomezashi_v_line = (x[3 : 0] == 4'b0000);
  assign hitomezashi_h_line = (y[3 : 0] == 4'b0000);
  assign hitomezashi_v_on = (y[4] ^ hitomezashi_vStart[x[9 : 4]]);
  assign hitomezashi_h_on = (x[4] ^ hitomezashi_hStart[y[8 : 4]]);
  assign hitomezashi_stitch = (((hitomezashi_v_line && hitomezashi_v_on) || (hitomezashi_h_line && hitomezashi_h_on)) || hitomezashi_last_h_stitch);
  assign color_payload_r = roster_bar_color_r;
  assign color_payload_g = roster_bar_color_g;
  assign color_payload_b = roster_bar_color_b;
  assign color_valid = color_en_regNext_1;
  always @(posedge clk) begin
    color_en_regNext <= color_en;
    if(sof) begin
      roster_bar_color_b <= 4'b0110;
      roster_bar_color_g <= 4'b0010;
      roster_bar_color_r <= 4'b0001;
    end else begin
      if(eol) begin
        if(temp_when) begin
          if(!temp_when_1) begin
            roster_bar_color_r <= (roster_bar_inc ? temp_roster_bar_color_r : temp_roster_bar_color_r_1);
            roster_bar_color_g <= (roster_bar_inc ? temp_roster_bar_color_g : temp_roster_bar_color_g_1);
            roster_bar_color_b <= (roster_bar_inc ? temp_roster_bar_color_b : temp_roster_bar_color_b_1);
          end
        end
      end
    end
    hitomezashi_color_r <= (hitomezashi_stitch ? 4'b1111 : 4'b0001);
    hitomezashi_color_g <= (hitomezashi_stitch ? 4'b1100 : 4'b0011);
    hitomezashi_color_b <= (hitomezashi_stitch ? 4'b0000 : 4'b0111);
    color_en_regNext_1 <= color_en;
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      roster_bar_inc <= 1'b0;
      roster_bar_color_cnt <= 4'b0000;
      roster_bar_line_cnt <= 1'b0;
      hitomezashi_last_h_stitch <= 1'b0;
    end else begin
      if(sof) begin
        roster_bar_inc <= 1'b1;
      end else begin
        if(eol) begin
          if(temp_when) begin
            roster_bar_line_cnt <= 1'b0;
            if(temp_when_1) begin
              roster_bar_inc <= (! roster_bar_inc);
              roster_bar_color_cnt <= 4'b0000;
            end else begin
              roster_bar_color_cnt <= (roster_bar_color_cnt + 4'b0001);
            end
          end else begin
            roster_bar_line_cnt <= (roster_bar_line_cnt + 1'b1);
          end
        end
      end
      hitomezashi_last_h_stitch <= (hitomezashi_h_line && hitomezashi_h_on);
    end
  end


endmodule
