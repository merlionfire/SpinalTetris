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
