// Generator : SpinalHDL v1.12.2    git head : f25edbcee624ef41548345cfb91c42060e33313f
// Component : color_palettes
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module color_palettes (
  input  wire [3:0]    io_addr,
  input  wire          io_rd_en,
  output wire          io_color_valid,
  output wire [11:0]   io_color_payload,
  input  wire          clk,
  input  wire          reset
);

  reg        [11:0]   rom_spinal_port0;
  reg                 io_rd_en_regNext;
  reg [11:0] rom [0:15];

  initial begin
    rom[0] = 12'b100000100101;
    rom[1] = 12'b101100010101;
    rom[2] = 12'b111100000101;
    rom[3] = 12'b111101010010;
    rom[4] = 12'b111110100000;
    rom[5] = 12'b111111000001;
    rom[6] = 12'b111111110010;
    rom[7] = 12'b011111100010;
    rom[8] = 12'b000011100011;
    rom[9] = 12'b000010110100;
    rom[10] = 12'b000010000101;
    rom[11] = 12'b000110011010;
    rom[12] = 12'b001110111111;
    rom[13] = 12'b010110011100;
    rom[14] = 12'b100001111010;
    rom[15] = 12'b100001000111;
  end
  always @(posedge clk) begin
    if(io_rd_en) begin
      rom_spinal_port0 <= rom[io_addr];
    end
  end

  assign io_color_payload = rom_spinal_port0;
  assign io_color_valid = io_rd_en_regNext;
  always @(posedge clk) begin
    io_rd_en_regNext <= io_rd_en;
  end


endmodule
