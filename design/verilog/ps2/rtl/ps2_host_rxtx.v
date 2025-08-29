module ps2_host_rxtx  (
   // Clock and reset    
   input        clk,
   input        rst,
   // PS/2 interface 
   inout        ps2_clk,
   inout        ps2_data,
   // Processor interface for sending data 
   input        ps2_wr_stb,
   input [7:0]  ps2_wr_data, 
   output       ps2_tx_done,
   output       ps2_tx_ready,
   // Processor interface for receiving data 
   output       ps2_rddata_valid,
   output [7:0] ps2_rd_data, 
   output       ps2_rx_ready   
);   


   wire  ps2_clk_out, ps2_clk_in, ps2_clk_in_clean; 
   wire  ps2_data_out_en,  ps2_data_out, ps2_data_in, ps2_data_in_clean; 
   wire  ps2_rx_en;

   //assign   ps2_clk     = ps2_clk_out ? 1'bz :  1'b0 ;  
   assign   ps2_clk_in  = ps2_clk ; 

   //assign   ps2_data     = ps2_data_out_en ? ps2_data_out  :  1'bz ;  
   assign   ps2_data_in   = ps2_data; 

   assign   ps2_rx_en    = ps2_tx_ready; 
`ifdef SIM
   assign ps2_clk_in_clean = ps2_clk_in ; 
   assign ps2_data_in_clean = ps2_data_in ; 
`else
   io_filter  #(.PIN_NUM (2 ) ) io_filter_inst (
         .clk     (  clk   ),
         .pin_in  ( { ps2_clk_in,      ps2_data_in} ),
         .pin_out ( { ps2_clk_in_clean,ps2_data_in_clean } ) 
   );
`endif

/*
`ifdef 0
   assign       ps2_tx_done = 1'b0;
   assign       ps2_tx_ready = 1'b0 ;
   assign       ps2_rddata_valid = 1'b0 ;
   assign       ps2_rd_data = 8'h00;
   assign       wireps2_rx_ready  = 1'b0 ;
`else
*/


//   ps2_host_tx #(.NUM_OF_BITS_FOR_100US (9 ) )  ps2_host_tx_inst (
   ps2_host_tx #(.NUM_OF_BITS_FOR_100US ( 13 ) )  ps2_host_tx_inst (
      .clk          ( clk           ),
      .rst          ( rst           ),
      .ps2_clk_in   ( ps2_clk_in_clean    ),
      .ps2_data_in  ( ps2_data_in_clean   ),
      .ps2_wr_stb   ( ps2_wr_stb    ),
      .ps2_wr_data  ( ps2_wr_data   ), 
      .ps2_clk_out  ( ps2_clk_out   ),
      .ps2_data_out_en ( ps2_data_out_en ),
      .ps2_data_out ( ps2_data_out   ),
      .ps2_tx_done  ( ps2_tx_done   ), 
      .ps2_tx_ready ( ps2_tx_ready  )    
   );
   
   ps2_host_rx ps2_host_rx_inst (
      .clk          ( clk           ),
      .rst          ( rst           ),
      .ps2_clk_in   ( ps2_clk_in_clean    ),
      .ps2_data_in  ( ps2_data_in_clean   ),
      .ps2_rx_en    ( ps2_rx_en     ),
      .ps2_rddata_valid ( ps2_rddata_valid ),
      .ps2_rd_data  ( ps2_rd_data   ), 
      .ps2_rx_ready ( ps2_rx_ready  )    
   );

//`endif
endmodule    

