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
