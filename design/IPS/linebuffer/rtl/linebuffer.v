// Generator : SpinalHDL v1.12.2    git head : f25edbcee624ef41548345cfb91c42060e33313f
// Component : linebuffer
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module linebuffer (
  input  wire          wr_in_valid,
  input  wire [3:0]    wr_in_payload,
  input  wire          rd_start,
  output wire          rd_out_valid,
  output wire [3:0]    rd_out_payload,
  input  wire          wr_clk,
  input  wire          wr_reset,
  input  wire          rd_clk,
  input  wire          rd_reset
);

  reg        [3:0]    ram_spinal_port1;
  reg        [4:0]    wr_addr;
  reg        [4:0]    rd_addr;
  reg                 rd_enable;
  reg                 rd_scale_cnt_willIncrement;
  reg                 rd_scale_cnt_willClear;
  wire                rd_scale_cnt_willOverflowIfInc;
  wire                rd_scale_cnt_willOverflow;
  wire                rd_valid;
  wire                rd_inc_enable;
  wire                rd_data_valid;
  wire       [3:0]    rd_data_payload;
  wire       [3:0]    rd_rd_data;
  reg                 rd_valid_regNext;
  reg [3:0] ram [0:31];

  always @(posedge wr_clk) begin
    if(wr_in_valid) begin
      ram[wr_addr] <= wr_in_payload;
    end
  end

  always @(posedge rd_clk) begin
    if(rd_valid) begin
      ram_spinal_port1 <= ram[rd_addr];
    end
  end

  always @(*) begin
    rd_scale_cnt_willIncrement = 1'b0;
    if(rd_enable) begin
      rd_scale_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    rd_scale_cnt_willClear = 1'b0;
    if(rd_start) begin
      rd_scale_cnt_willClear = 1'b1;
    end
  end

  assign rd_scale_cnt_willOverflowIfInc = 1'b1;
  assign rd_scale_cnt_willOverflow = (rd_scale_cnt_willOverflowIfInc && rd_scale_cnt_willIncrement);
  assign rd_valid = (1'b1 && rd_enable);
  assign rd_inc_enable = (rd_scale_cnt_willOverflowIfInc && rd_enable);
  assign rd_rd_data = ram_spinal_port1;
  assign rd_data_valid = rd_valid_regNext;
  assign rd_data_payload = rd_rd_data;
  assign rd_out_valid = rd_data_valid;
  assign rd_out_payload = rd_data_payload;
  always @(posedge wr_clk or posedge wr_reset) begin
    if(wr_reset) begin
      wr_addr <= 5'h0;
    end else begin
      if(wr_in_valid) begin
        if((wr_addr == 5'h1f)) begin
          wr_addr <= 5'h0;
        end else begin
          wr_addr <= (wr_addr + 5'h01);
        end
      end
    end
  end

  always @(posedge rd_clk or posedge rd_reset) begin
    if(rd_reset) begin
      rd_addr <= 5'h0;
      rd_enable <= 1'b0;
      rd_valid_regNext <= 1'b0;
    end else begin
      if(rd_start) begin
        rd_enable <= 1'b1;
      end else begin
        if(((rd_addr == 5'h1f) && rd_scale_cnt_willOverflowIfInc)) begin
          rd_enable <= 1'b0;
        end
      end
      if(rd_start) begin
        rd_addr <= 5'h0;
      end else begin
        if(rd_inc_enable) begin
          rd_addr <= (rd_addr + 5'h01);
        end
      end
      rd_valid_regNext <= rd_valid;
    end
  end


endmodule
