// Generator : SpinalHDL v1.12.2    git head : f25edbcee624ef41548345cfb91c42060e33313f
// Component : bram_2p
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module bram_2p (
  input  wire          wr_en,
  input  wire [14:0]   wr_addr,
  input  wire [3:0]    wr_data,
  input  wire          rd_en,
  input  wire [14:0]   rd_addr,
  output wire [3:0]    rd_data,
  input  wire          clk,
  input  wire          reset
);

  reg        [3:0]    memory_spinal_port1;
  reg [3:0] memory [0:19199];

  initial begin
    $readmemb("bram_2p.v_toplevel_memory.bin",memory);
  end
  always @(posedge clk) begin
    if(wr_en) begin
      memory[wr_addr] <= wr_data;
    end
  end

  always @(posedge clk) begin
    if(rd_en) begin
      memory_spinal_port1 <= memory[rd_addr];
    end
  end

  assign rd_data = memory_spinal_port1;

endmodule
