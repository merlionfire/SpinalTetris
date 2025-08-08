`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Crazy Joe's Garage Shop
// Engineer:        Crazy Joe
// 
// Create Date:     22 August 2008 
// Design Name:     De-bounce
// Module Name:     Debounce 
// Project Name:    Avnet FPGA Intro Speedway
// Target Devices:  Spartan-3A DSP
// Tool versions:   ISE/XST 10.1.02
// Description:     This design analyzes an input for NDELAY number of cycles
//                  for stability, thus de-bouncing the input.
//
// Dependencies:    
//
// Revision:        08/22/08 - File created (bhf)
//
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module glitch_free  (
   input      Clk, 
   input      DataNoisy,
   output reg DataClean = 1'b0 
   );

      parameter NDELAY = 4'd10;
      parameter NBITS =  4 ;
      reg data_i = 1'b0 ;
      reg [NBITS-1:0] count;



   // Compare DataNoisy to a registered version of itself
   // Must be the same for NDELAY consecutive cycles before
   // DataClean is assigned
   always @(posedge Clk)
     if (DataNoisy != data_i) 
        begin 
            data_i     <= DataNoisy; 
            count      <= 0; 
        end
     else if (count == NDELAY)
        DataClean      <= data_i;
     else 
        count          <= count+1;

endmodule

