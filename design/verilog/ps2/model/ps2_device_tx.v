module ps2_device_tx #( 
   // 10KHz < ps2_clk < 16.7 ( 60us < T < 100us ) 
   // 30us < T/2 < 50us 
   // if clk is 20ns, 1500 < cnt < 2500. 
   //  cnt [10:0]  and CNT_min = 1024*2 = 2048
  parameter  NUM_OF_BITS_CLK_HALF_CNT = 11    
) (       
   input        clk,
   input        rst,
   inout        ps2_clk,
   inout        ps2_data,
   input [7:0]  ps2_wr_data,
   input        ps2_wr_stb, 
   output reg   ps2_tx_done,
   output reg   ps2_tx_ready 
);  

parameter CLK_HALF_CYCLES_INIT      =  { NUM_OF_BITS_CLK_HALF_CNT { 1'b1 } } ;  
parameter CLK_QUARTER_CYCLES_INIT   = CLK_HALF_CYCLES_INIT  / 2 ; 
localparam  IDLE                 =  2'b00,
            CLK_QUARTER_HIGH_A   =  2'b01, 
            CLK_HALF_LOW         =  2'b10,
            CLK_QUARTER_HIGH_B   =  2'b11;   

reg ps2_data_out_en, ps2_clk_out, load_shift_bits, load_clk_quarter_cnt, load_clk_half_cnt, dec_clk_cnt, shift_bits, clk_time ; 

reg   [10:0]   data_out;
reg   [3:0]    shift_bits_cnt ; 
reg   [ NUM_OF_BITS_CLK_HALF_CNT-1 : 0] clk_cnt ; 
reg   [1:0]    state_r, state_nxt; 
wire  ps2_data_in, ps2_clk_in, ps2_data_parity ;  

assign   ps2_clk     = ps2_clk_out ?  1'bz :  1'b0 ;  
assign   ps2_clk_in  = ps2_clk ; 

assign   ps2_data     = ps2_data_out_en  ? data_out[0] : 1'bz  ;  
assign   ps2_data_in  = ps2_data; 

assign   ps2_data_parity = ~ ( ^ps2_wr_data ) ;  

always @( posedge clk ) begin 
   if ( rst ) begin 
      shift_bits_cnt <= 4'd0;  
      data_out       <= 11'h00 ; 
   end else begin 
      if ( load_shift_bits ) begin 
         shift_bits_cnt <= 4'd10;  
         data_out <= { {1'b1},  ps2_data_parity , ps2_wr_data, {1'b0} } ; 
      end else if ( shift_bits ) begin 
         shift_bits_cnt <= shift_bits_cnt - 1'b1 ;  
         data_out <= { 1'b1, data_out[10:1] } ; 
      end    
   end 
end 

always @( posedge clk ) begin 
   if ( rst ) begin 
      clk_cnt  <= 0 ; 
      clk_time <= 1'b0; 
   end else begin 
      if ( load_clk_quarter_cnt ) begin 
         clk_cnt  <= CLK_QUARTER_CYCLES_INIT ; 
      end 
      if ( load_clk_half_cnt ) begin 
         clk_cnt  <= CLK_HALF_CYCLES_INIT ; 
      end 
      if ( dec_clk_cnt ) begin 
         clk_cnt  <= clk_cnt - 1'b1;
      end 

      if ( clk_cnt == 'd1  ) begin 
         clk_time <= 1'b1; 
      end else begin 
         clk_time <= 1'b0;
      end 
   end 
end 

always @( posedge clk ) begin 
   if ( rst ) begin
      state_r <= IDLE ; 
   end else begin 
      state_r <=  state_nxt   ; 
   end 


end 

always @(*) begin 
   ps2_data_out_en    =  1'b0;
   ps2_clk_out        =  1'b1; 
   ps2_tx_ready = 1'b0; 
   ps2_tx_done  = 1'b0;
   load_shift_bits  = 1'b0; 
   load_clk_quarter_cnt = 1'b0;
   load_clk_half_cnt = 1'b0;
   dec_clk_cnt =  1'b0;            
   shift_bits  =  1'b0; 
   state_nxt   = state_r ; 
   case ( state_r ) 
      IDLE : begin 
         if ( ps2_clk_in & ps2_data_in ) begin 
            ps2_tx_ready = 1'b1 ; 
         end   
         if ( ps2_wr_stb  & ps2_clk_in & ps2_data_in ) begin 
            load_shift_bits  = 1'b1; 
            load_clk_quarter_cnt = 1'b1;
            state_nxt   =  CLK_QUARTER_HIGH_A ; 
         end   
      end 
      CLK_QUARTER_HIGH_A : begin 
         dec_clk_cnt =  1'b1;            
         ps2_data_out_en   =  1'b1 ; 
         if ( clk_time ) begin 
           load_clk_half_cnt = 1'b1;
           state_nxt =  CLK_HALF_LOW ; 
         end  
      end
      CLK_HALF_LOW : begin 
         ps2_clk_out =  1'b0 ; 
         dec_clk_cnt =  1'b1;            
         ps2_data_out_en   =  1'b1;
         if ( clk_time ) begin 
           load_clk_quarter_cnt = 1'b1;
           state_nxt =  CLK_QUARTER_HIGH_B; 
         end  
      end
      CLK_QUARTER_HIGH_B : begin 
         dec_clk_cnt =  1'b1;            
         ps2_data_out_en   =  1'b1;
         if ( clk_time ) begin 
            if ( shift_bits_cnt == 0 ) begin 
               ps2_tx_done =  1'b1 ; 
               state_nxt   =  IDLE ; 
            end else begin   
              load_clk_quarter_cnt = 1'b1;
              shift_bits   =  1'b1; 
              state_nxt =  CLK_QUARTER_HIGH_A; 
            end   
         end  
      end
   endcase 
end 

endmodule 
