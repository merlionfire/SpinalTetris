//==============================================================================
// PS/2 Keyboard Driver Module (VIP)
// Purpose: Generate PS/2 protocol compliant signals for keyboard simulation
// Pure Verilog/SystemVerilog module - no classes needed
//==============================================================================

module ps2_key_driver(
  input  logic clk,
  input  logic reset,
  inout  wire  ps2_clk,
  inout  wire  ps2_data
);
  
  // Internal control signals
  logic ps2_clk_drive;
  logic ps2_data_drive;
  logic ps2_clk_out;
  logic ps2_data_out;
  
  // Tri-state control
  assign ps2_clk  = ps2_clk_drive  ? ps2_clk_out  : 1'bz;
  assign ps2_data = ps2_data_drive ? ps2_data_out : 1'bz;
  
  // Timing parameters (scaled for simulation)
  // Real PS/2: 10-16.7 kHz (60-100us period)
  // For simulation: Use faster timing
  parameter int PS2_CLK_HALF_PERIOD = 5000;  // 5us half period = 100kHz (faster for sim)
  
  //============================================================================
  // Task to send a single bit on PS/2 bus
  //============================================================================
/* 
 task automatic send_bit(input logic bit_val);
    begin
      // Set data line
      ps2_data_out = bit_val;
      ps2_data_drive = 1;
      
      // Clock low phase
      ps2_clk_out = 0;
      ps2_clk_drive = 1;
      #(PS2_CLK_HALF_PERIOD * 1ns);
      
      // Clock high phase  
      ps2_clk_out = 1;
      #(PS2_CLK_HALF_PERIOD * 1ns);
      
      // Release clock (let it be pulled up)
      ps2_clk_drive = 0;
    end
  endtask
 */ 

  //============================================================================
  // Task to send a single bit on PS/2 bus
  //============================================================================
  task automatic send_bit(input logic bit_val);
    begin

      // Set data line
      ps2_data_out = bit_val;
      ps2_data_drive = 1;

      #( (PS2_CLK_HALF_PERIOD)  * 1ns);
      
      ps2_clk_out = 0;
      ps2_clk_drive = 1;
      #( ( PS2_CLK_HALF_PERIOD )  * 1ns);
      // Release clock (let it be pulled up)
      ps2_clk_drive = 0;
    end
  endtask

  //============================================================================
  // Task to send a complete byte with PS/2 framing
  //============================================================================
  task automatic send_byte(input logic [7:0] data);
    logic parity;
    begin
      // Calculate odd parity
      parity = ~^data;
      
      $display("[%0t] PS/2 Driver: Sending byte 0x%02h", $time, data);
      
      // Start bit (0)
      send_bit(1'b0);
      
      // Data bits (LSB first)
      for (int i = 0; i < 8; i++) begin
        send_bit(data[i]);
      end
      
      // Parity bit
      send_bit(parity);
      
      // Stop bit (1)
      send_bit(1'b1);
      
      // Release bus and idle period
      ps2_clk_drive = 0;
      ps2_data_drive = 0;
      #(PS2_CLK_HALF_PERIOD * 4 * 1ns);  // Idle time between bytes
    end
  endtask
  
  //============================================================================
  // Task to send make code (key press)
  //============================================================================
  task automatic send_key_make(input logic [7:0] scan_code);
    begin
      $display("[%0t] PS/2 Driver: Key MAKE - 0x%02h", $time, scan_code);
      send_byte(scan_code);
    end
  endtask
  
  //============================================================================
  // Task to send break code (key release)
  //============================================================================
  task automatic send_key_break(input logic [7:0] scan_code);
    begin
      $display("[%0t] PS/2 Driver: Key BREAK - 0xF0, 0x%02h", $time, scan_code);
      send_byte(8'hF0);  // Break code prefix
      send_byte(scan_code);
    end
  endtask
  
  //============================================================================
  // Task to send raw byte (for testing invalid codes)
  //============================================================================
  task automatic send_raw_byte(input logic [7:0] data);
    begin
      $display("[%0t] PS/2 Driver: Raw byte - 0x%02h", $time, data);
      send_byte(data);
    end
  endtask
  
  //============================================================================
  // Initialize signals
  //============================================================================
  initial begin
    ps2_clk_drive = 0;
    ps2_data_drive = 0;
    ps2_clk_out = 1;
    ps2_data_out = 1;
  end
  
endmodule
