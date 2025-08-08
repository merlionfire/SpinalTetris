`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:33:02 06/20/2012 
// Design Name: 
// Module Name:    synchronizer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module synch_level(
    input      clk,
    input      sig_in,
    output reg sig_sync
    );

   reg sig_sync_pre ; 

   always @( posedge clk ) begin
      sig_sync_pre <= sig_in ; 
      sig_sync     <= sig_sync_pre ;  		
   end
endmodule
