// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : bram_2p
// Git hash  : 6bd8048e4e65ce59c2f7aaa8c8dec9b7933132bd

`timescale 1ns/1ps

module bram_2p (
  input  wire          wr_en,
  input  wire [14:0]   wr_addr,
  input  wire [3:0]    wr_data,
  input  wire          rd_en,
  input  wire [14:0]   rd_addr,
  output wire [3:0]    rd_data,
  input  wire          clear,
  input  wire          clk,
  input  wire          reset
);

  reg        [3:0]    memory_spinal_port1;
  wire       [14:0]   temp_full_addr_valueNext;
  wire       [0:0]    temp_full_addr_valueNext_1;
  reg                 addr_inc;
  reg                 full_addr_willIncrement;
  wire                full_addr_willClear;
  reg        [14:0]   full_addr_valueNext;
  reg        [14:0]   full_addr_value;
  wire                full_addr_willOverflowIfInc;
  wire                full_addr_willOverflow;
  wire       [14:0]   wr_addr_1;
  wire       [3:0]    wr_data_1;
  wire                wr_en_1;
  (* ram_style = "block" *) reg [3:0] memory [0:19199];

  assign temp_full_addr_valueNext_1 = full_addr_willIncrement;
  assign temp_full_addr_valueNext = {14'd0, temp_full_addr_valueNext_1};
  initial begin
    $readmemb("bram_2p.v_toplevel_memory.bin",memory);
  end
  always @(posedge clk) begin
    if(wr_en_1) begin
      memory[wr_addr_1] <= wr_data_1;
    end
  end

  always @(posedge clk) begin
    if(rd_en) begin
      memory_spinal_port1 <= memory[rd_addr];
    end
  end

  always @(*) begin
    full_addr_willIncrement = 1'b0;
    if(addr_inc) begin
      full_addr_willIncrement = 1'b1;
    end
  end

  assign full_addr_willClear = 1'b0;
  assign full_addr_willOverflowIfInc = (full_addr_value == 15'h4aff);
  assign full_addr_willOverflow = (full_addr_willOverflowIfInc && full_addr_willIncrement);
  always @(*) begin
    if(full_addr_willOverflow) begin
      full_addr_valueNext = 15'h0;
    end else begin
      full_addr_valueNext = (full_addr_value + temp_full_addr_valueNext);
    end
    if(full_addr_willClear) begin
      full_addr_valueNext = 15'h0;
    end
  end

  assign wr_addr_1 = (addr_inc ? full_addr_value : wr_addr);
  assign wr_data_1 = (addr_inc ? 4'b1111 : wr_data);
  assign wr_en_1 = (addr_inc || wr_en);
  assign rd_data = memory_spinal_port1;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      addr_inc <= 1'b0;
      full_addr_value <= 15'h0;
    end else begin
      if(clear) begin
        addr_inc <= 1'b1;
      end
      full_addr_value <= full_addr_valueNext;
      if(full_addr_willOverflow) begin
        addr_inc <= 1'b0;
      end
    end
  end


endmodule
