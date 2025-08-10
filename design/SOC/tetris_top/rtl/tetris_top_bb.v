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

   assign   ps2_clk     = ps2_clk_out ? 1'bz :  1'b0 ;  
   assign   ps2_clk_in  = ps2_clk ; 

   assign   ps2_data     = ps2_data_out_en ? ps2_data_out  :  1'bz ;  
   assign   ps2_data_in  = ps2_data; 

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
endmodule    

module ps2_host_tx (
   input        clk,
   input        rst,
   input        ps2_clk_in,
   input        ps2_data_in,
   input        ps2_wr_stb,
   input [7:0]  ps2_wr_data, 
   output reg   ps2_clk_out,
   output reg   ps2_data_out_en,
   output reg   ps2_data_out,
   output reg   ps2_tx_done,
   output reg   ps2_tx_ready   
);

// synthesis attribute keep of ps2_wr_stb is "true" 
// synthesis attribute keep of ps2_wr_data is "true" 
// synthesis attribute keep of state_r is "true" 
// synthesis attribute keep of state_nxt is "true" 
// synthesis attribute keep of ps2_clk_in is "true" 
// synthesis attribute keep of ps2_data_in is "true" 
// synthesis attribute keep of ps2_clk_out is "true" 
// synthesis attribute keep of ps2_data_out_en is "true" 
// synthesis attribute keep of ps2_data_out is "true" 
// synthesis attribute keep of cntr_zero is "true" 
// synthesis attribute keep of load_dout is "true" 
// synthesis attribute keep of dec_cntr is "true" 
// synthesis attribute keep of ps2_go is "true" 
// synthesis attribute keep of delay_cntr is "true" 
// synthesis attribute keep of load_cntr is "true" 

localparam IDLE  = 0 ,
          RESET   = 1 ,
          START = 2 ,
          DATA  = 3 ,
          STOP  = 4 ,
          ACK   = 5 ,
          WAIT  = 6 ;  



parameter  NUM_OF_BITS_FOR_100US   =  13 ; 


reg   ps2_clk_in_1d;
wire  ps2_clk_negedge, parity;
reg   [2:0]  state_r = IDLE; 
reg   [2:0]  state_nxt ; 
reg   [ NUM_OF_BITS_FOR_100US-1 : 0 ] delay_cntr ;   
reg   cntr_zero, load_cntr, dec_cntr ; 
reg   [8:0]  data_out ; 
reg   [3:0]  data_cnt = 4'h8 , data_cnt_nxt ; 
reg   load_dout, shift_dout, tran_err_no_ack ;  

always @( posedge clk ) begin
   ps2_clk_in_1d <= ps2_clk_in ; 
end

assign ps2_clk_negedge = ( ~ps2_clk_in )& ps2_clk_in_1d ;  

assign ps2_go = ps2_wr_stb ; 

// Counter for generating delay 
always @( posedge clk ) begin 
   if ( rst ) begin 
      delay_cntr  <= 0 ; 
      cntr_zero   <= 1'b0 ; 
   end else begin    
      if (  delay_cntr == 1  ) begin 
         cntr_zero <= 1'b1 ; 
      end else begin 
         cntr_zero <= 1'b0 ; 
      end

      case ( { load_cntr, dec_cntr } ) // synthesis parallel_case  
         2'b10 :  delay_cntr <= { NUM_OF_BITS_FOR_100US {1'b1} } ; 
         2'b01 :  delay_cntr <= delay_cntr - 1'b1 ; 
      endcase 
   end
end

// Odd parity biy
assign   parity   =  ~ ( ^ ps2_wr_data ) ; 

always @( posedge clk ) begin 
   if ( rst ) begin 
      data_out <= 0 ; 
   end else begin    
      case ( { load_dout, shift_dout} )  //synthesis parallel_case 
         2'b10 : data_out <= { parity, ps2_wr_data }; 
         2'b01 : data_out <= { 1'b1, data_out[8:1] } ;             
      endcase 
   end    
end

always @( posedge clk) begin
   if ( rst ) begin 
      state_r    <= IDLE ; 
      data_cnt   <= 4'h8    ;
   end else begin 
      state_r  <= state_nxt ; 
      data_cnt <= data_cnt_nxt ;  
   end   
end


always @(*) begin 
   state_nxt      =  state_r;
   ps2_clk_out    =  1'b1;
   ps2_data_out_en =  1'b0;
   ps2_data_out   =  1'b1;
   load_dout      =  1'b0;
   shift_dout     =  1'b0;
   load_cntr      =  1'b0;
   dec_cntr       =  1'b0;
   data_cnt_nxt   =  data_cnt ; 
   ps2_tx_done    =  1'b0;
   tran_err_no_ack   =  1'b0; 
   ps2_tx_ready   = 1'b0 ; 
   case ( state_r  ) 
      IDLE : begin 
         ps2_tx_ready = 1'b1 ; 
         if ( ps2_go ) begin 
            state_nxt   =  RESET;        
            load_dout   =  1'b1; 
            load_cntr   =  1'b1;
         end   
      end 
      RESET : begin
         ps2_clk_out = 1'b0 ; 
         dec_cntr    = 1'b1 ; 
         if ( cntr_zero ) 
            state_nxt   =  START ; 
      end
      START: begin 
         ps2_data_out_en   =  1'b1;
         ps2_data_out      =  1'b0;
         if ( ps2_clk_negedge )  begin
            state_nxt      =  DATA;
            data_cnt_nxt   =  4'h8 ; 
               end   
      end
      DATA : begin
         ps2_data_out_en   =  1'b1;
         ps2_data_out      =  data_out[0] ; 
         if ( ps2_clk_negedge ) begin 
            shift_dout     =  1'b1 ;  
            if ( data_cnt  == 0 ) 
               state_nxt   =  STOP; 
            else  
               data_cnt_nxt   =  data_cnt - 1'b1 ;
         end   
      end  
      STOP : begin
         state_nxt  =  ACK ; 
      end   
      ACK  : begin         
         if ( ps2_clk_negedge ) begin 
            state_nxt   =  WAIT ; 
            ps2_tx_done     =  1'b1 ; 
            if ( ps2_data_in == 1'b1 ) begin
               tran_err_no_ack = 1'b1 ; 
            end   
         end
      end     
      WAIT:  begin
         if ( ps2_clk_in && ps2_data_in ) begin 
            state_nxt   =  IDLE ;   
         end   
      end
      default :  state_nxt = IDLE ; 
   endcase 
end 

endmodule 
module ps2_host_rx (
   // clock and reset    
   input        clk,
   input        rst,
   // PS/2 interface 
   input        ps2_clk_in,
   input        ps2_data_in,
   // Processor interface 
   input        ps2_rx_en,
   output reg   ps2_rddata_valid,
   output [7:0] ps2_rd_data, 
   output reg   ps2_rx_ready   
);

localparam IDLE = 2'b00, 
           DATA = 2'b01,
           CHECK = 2'b10,
           DONE = 2'b11;


reg   ps2_clk_in_1d,  shift_bits_in ;
reg   [9:0] data_in ; 
reg   [3:0] shift_bits_cnt, shift_bits_cnt_nxt;
reg   [12:0]  ps2_clk_cnt ; 
reg   ps2_rd_data_err, ps2_rd_data_err_nxt, ps2_rx_done,  ps2_rx_done_nxt,  ps2_rddata_valid_nxt; 
reg   [1:0] state_r = IDLE , state_nxt;  

wire  ps2_clk_nep; 
wire  ps2_rd_data_par, ps2_rd_bit_stop ;  
wire  ps2_clk_in_expire ; 

// synthesis attribute keep of state_r is "true" 
// synthesis attribute keep of ps2_clk_nep is "true" 
// synthesis attribute keep of state_r is "true" 
// synthesis attribute keep of state_nxt is "true" 



always @( posedge clk ) begin
   ps2_clk_in_1d <= ps2_clk_in ; 
end

assign   ps2_clk_nep  = ( ~ps2_clk_in ) & ps2_clk_in_1d ;  

assign   ps2_rd_data     = data_in[7:0] ; 
assign   ps2_rd_data_par = data_in[8] ; 
assign   ps2_rd_bit_stop = data_in[9] ;  

//******************************************************** 
// Time-out counter.
//    catch the exception that clock from device losts.
//    It prevents FSM from staying in "DATA".
//    Hopefully it will handle cases of surprise mosue 
//    removal during transmission, and cases of mosue 
//    resets.
// *******************************************************   


assign ps2_clk_in_expire = (ps2_clk_cnt == 13'h0001 ); 
always @( posedge clk ) begin 
   if ( rst ) begin 
      ps2_clk_cnt <= 13'h000 ; 
   end else if ( ( (state_nxt == DATA ) && (state_r == IDLE) ) | shift_bits_in ) begin 
      ps2_clk_cnt   <=  13'h1fff; 
   end else if ( ps2_clk_cnt > 13'h001  ) begin  
      ps2_clk_cnt   <=  ps2_clk_cnt - 1'b1  ; 
   end     
end     


always @ ( posedge clk ) begin 
   if ( rst ) begin 
      data_in  <= 10'h00 ;    
   end else begin 
      if ( shift_bits_in ) begin 
         data_in <= { ps2_data_in, data_in[9:1] } ; 
      end   
   end 
end 

always @( posedge clk ) begin 
   if ( rst ) begin 
      state_r           <=   IDLE; 
      shift_bits_cnt    <=   'b0;       
      ps2_rd_data_err   <=   1'b0;     
      ps2_rx_done       <=   1'b0; 
      ps2_rddata_valid  <=   1'b0; 
   end else begin 
      state_r           <=   state_nxt; 
      shift_bits_cnt    <=   shift_bits_cnt_nxt;       
      ps2_rd_data_err   <=   ps2_rd_data_err_nxt;     
      ps2_rx_done       <=   ps2_rx_done_nxt; 
      ps2_rddata_valid  <=   ps2_rddata_valid_nxt; 
   end
end 

always @(*) begin
   state_nxt            =  state_r ; 
   shift_bits_cnt_nxt   =  shift_bits_cnt ;       
   ps2_rd_data_err_nxt  =  ps2_rd_data_err;     
   ps2_rx_done_nxt      =  1'b0; 
   ps2_rddata_valid_nxt =  1'b0; 
   shift_bits_in        =  1'b0;
   ps2_rx_ready         =  1'b0 ;   
   case ( state_r ) 
      IDLE : begin 
         ps2_rx_ready  = 1'b1 ;   
         if ( ( ps2_rx_en == 1'b1 ) && ( ps2_clk_nep == 1'b1 ) ) begin 
            if ( ~ ps2_data_in ) begin 
               state_nxt   =  DATA ;  
               shift_bits_cnt_nxt   =  9 ;  
               ps2_rd_data_err_nxt  = 1'b0;  
            end else begin 
               ps2_rd_data_err_nxt  = 1'b1;  
            end
         end
      end   
      DATA : begin
         if ( ps2_clk_in_expire ) begin 
             state_nxt   = IDLE ; 
         end else if ( ps2_clk_nep ) begin 
            shift_bits_in  =  1'b1 ; 
            if ( shift_bits_cnt == 4'h0 ) begin 
               state_nxt   =  CHECK ; 
            end else begin    
               shift_bits_cnt_nxt   =  shift_bits_cnt - 1'b1 ; 
            end
         end 
      end   
      CHECK : begin 
         ps2_rx_done_nxt       = 1'b1 ; 
         if (  ( ^{ ps2_rd_data, ps2_rd_data_par}  )  & ps2_rd_bit_stop ) begin 
             state_nxt   =  DONE ; 
             ps2_rddata_valid_nxt  =  1'b1 ; 
         end else begin      
             state_nxt   =  IDLE ; 
             ps2_rd_data_err_nxt  =  1'b1 ;          
         end 
      end 
      DONE: begin 
         state_nxt   =  IDLE ; 
      end   
   endcase  
end 


endmodule

module io_filter #( parameter PIN_NUM = 3 ) 
(
   input   clk , 
   input   [ PIN_NUM-1 : 0 ]   pin_in    , 
   output  [ PIN_NUM-1 : 0 ]   pin_out    
) ; 


   wire [ PIN_NUM-1 : 0 ] pin_in_sync ; 

   genvar i ; 
   generate 
      for ( i = 0 ; i < PIN_NUM ; i = i+1 ) begin : io_sync_db   
         synchro #(.INITIALIZE("LOGIC0")) io_sync_inst (
				.clk    (  clk            ),
            .async  (  pin_in[i]      ),
				.sync   (  pin_in_sync[i] )
			);
	
		   glitch_free  glitch_free_inst (
            .Clk       ( clk ), 
            .DataNoisy ( pin_in_sync[i]  ),
            .DataClean ( pin_out[i]    ) 
         );
      end 
   endgenerate 

endmodule 
//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2006 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor:        Xilinx
// \   \   \/    Version:       1.0.0
//  \   \        Filename:      synchro.v
//  /   /        Date Created:  December 25, 2006
// /___/   /\    Last Modified: December 25, 2006
// \   \  /  \
//  \___\/\___\
//
// Devices:   Spartan-3 Generation FPGA
// Purpose:   Signal synchronizer, meant for async inputs
// Contact:   crabill@xilinx.com
// Reference: None
//
// Revision History:
//   Rev 1.0.0 - (crabill) First created December 25, 2006.
//
//////////////////////////////////////////////////////////////////////////////
//
// LIMITED WARRANTY AND DISCLAIMER. These designs are provided to you "as is".
// Xilinx and its licensors make and you receive no warranties or conditions,
// express, implied, statutory or otherwise, and Xilinx specifically disclaims
// any implied warranties of merchantability, non-infringement, or fitness for
// a particular purpose. Xilinx does not warrant that the functions contained
// in these designs will meet your requirements, or that the operation of
// these designs will be uninterrupted or error free, or that defects in the
// designs will be corrected. Furthermore, Xilinx does not warrant or make any
// representations regarding use or the results of the use of the designs in
// terms of correctness, accuracy, reliability, or otherwise.
//
// LIMITATION OF LIABILITY. In no event will Xilinx or its licensors be liable
// for any loss of data, lost profits, cost or procurement of substitute goods
// or services, or for any special, incidental, consequential, or indirect
// damages arising from the use or operation of the designs or accompanying
// documentation, however caused and on any theory of liability. This
// limitation will apply even if Xilinx has been advised of the possibility
// of such damage. This limitation shall apply not-withstanding the failure
// of the essential purpose of any limited remedies herein.
//
//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2006 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module synchro
  #(
  parameter          INITIALIZE = "LOGIC0"
  )

  (
  input  wire        async,
  input  wire        clk,
  output wire        sync
  );

  //******************************************************************//
  // Synchronizer.                                                    //
  //******************************************************************//

  wire        temp;

  generate
    if (INITIALIZE == "LOGIC1")
    begin : use_fdp
      (* ASYNC_REG = "TRUE" *) (* RLOC = "X0Y0"  *) FDP fda (.Q(temp),.D(async),.C(clk),.PRE(1'b0));
      (* ASYNC_REG = "TRUE" *) (* RLOC = "X0Y0"  *) FDP fdb (.Q(sync),.D(temp),.C(clk),.PRE(1'b0));
    end
    else
    begin : use_fdc
      (* ASYNC_REG = "TRUE" *) (* RLOC = "X0Y0"  *) FDC fda (.Q(temp),.D(async),.C(clk),.CLR(1'b0));
      (* ASYNC_REG = "TRUE" *) (* RLOC = "X0Y0"  *) FDC fdb (.Q(sync),.D(temp),.C(clk),.CLR(1'b0));
    end
  endgenerate

  // synthesis attribute ASYNC_REG of fda is "TRUE";
  // synthesis attribute ASYNC_REG of fdb is "TRUE";
  // synthesis attribute HU_SET of fda is "SYNC";
  // synthesis attribute HU_SET of fdb is "SYNC";
  // synthesis attribute RLOC of fda is "X0Y0";
  // synthesis attribute RLOC of fdb is "X0Y0";

  //******************************************************************//
  //                                                                  //
  //******************************************************************//

endmodule

module sync_pulse (
   input  wire    src_clk,   
   input  wire    async_in,
   input  wire    des_clk,
   output wire    sync_out
);


   wire  async, toggle, temp, temp_sync ; 

   assign async   =  toggle ^ async_in ; 

   FDC fda (.Q(toggle),.D(async),.C(src_clk),.CLR(1'b0));
    
   synchro  synchro_inst (
      .async   ( toggle ),
      .clk     ( des_clk ),
      .sync    ( temp )  
   ) ; 

   FDC fdb (.Q(temp_sync),.D(temp),.C(des_clk),.CLR(1'b0));

   assign sync_out   =  temp_sync ^ temp ; 
   

endmodule    
