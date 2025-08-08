module ps2_device_rx #(
  parameter NUM_OF_BITS_FOR_100US   =  13,   
  parameter INIT_CNTR_FOR_100US     =  13'h1f00, 
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
   output [7:0] ps2_receive_data, 
   output reg   ps2_rx_done,
   output reg   ps2_rx_busy
);  

   parameter  IDLE   =  0,
              RST    =  1,
              WAIT_CLK_HIGH   =  2,
              START  =  3,
              DATA_A =  4,
              DATA_B =  5,
              STOP_A =  6,
              STOP_B =  7,
              ACK_A  =  8,
              ACK_B  =  9,
              ERROR  =  10;

  
   reg   ps2_clk_out, ps2_data_out_en, ps2_data_out ; 
   reg   [ NUM_OF_BITS_CLK_HALF_CNT-1 : 0 ]  clk_half_cnt  ; 
   reg   [ NUM_OF_BITS_FOR_100US - 1 : 0  ]  delay_cntr_nxt, delay_cntr ; 
   reg   [3:0] shift_bits_cnt, shift_bits_cnt_nxt ; 
   reg   [3:0] state_r, state_nxt ; 
   reg   clk_half_time, load_clk_half_cnt, dec_clk_half_cnt ; 
   reg   [8:0]    byte_in ; 
   reg   ps2_rx_done_nxt, shift_bits_in  ; 

   wire     ps2_clk_in, ps2_data_in ;  
   wire     delay_cntr_zero ;    

   assign   ps2_clk     = ps2_clk_out ? 1'bz :  1'b0 ;  
   assign   ps2_clk_in  = ps2_clk ; 

   assign   ps2_data     = ps2_data_out_en ? ps2_data_out  :  1'bz ;  
   assign   ps2_data_in  = ps2_data; 


   assign   delay_cntr_zero   =  ~ ( | delay_cntr ) ;    
   assign   ps2_receive_data  =   byte_in[7:0] ;

   always @( posedge clk ) begin 
      if ( rst == 1'b1 ) begin 
            clk_half_cnt   <= { NUM_OF_BITS_CLK_HALF_CNT { 1'b0 }} ; 
            clk_half_time  <= 1'b0 ;   
      end else begin 
         if ( clk_half_cnt ==   'd1 )  begin    
            clk_half_time  <= 1'b1 ; 
         end else begin
            clk_half_time  <= 1'b0 ;
         end   

         if ( load_clk_half_cnt ) begin 
            clk_half_cnt   <= { NUM_OF_BITS_CLK_HALF_CNT { 1'b1 } }  ; 
         end

         if  ( dec_clk_half_cnt  ) begin 
            clk_half_cnt   <= clk_half_cnt   - 1'b1 ; 
         end
      end 
   end


   /* Sample data line when clock line is high */
   always @( posedge clk ) begin 
      if ( rst == 1'b1 ) begin 
         byte_in  <= 9'h0 ; 
      end else begin 
         if ( state_r == IDLE ) begin 
            byte_in  <= 9'h0 ; 
         end else begin 
            if ( ( shift_bits_in == 1'b1 ) && ( clk_half_cnt == { 1'b1, { ( NUM_OF_BITS_CLK_HALF_CNT-1 ) { 1'b0 }} } ) )   
            begin 
               byte_in <= { ps2_data_in, byte_in[8:1] }  ;  
            end   
         end   
      end   

   end 

   /* State machine for recieving data */
   always @( posedge clk ) begin 
      if ( rst == 1'b1 ) begin 
         state_r         <=  4'b0000 ;    
         delay_cntr      <=  { NUM_OF_BITS_FOR_100US {1'b0} } ; 
         shift_bits_cnt  <=  4'b0000 ; 
         ps2_rx_done     <=  1'b0; 
      end else begin 
         state_r         <=  state_nxt    ;    
         delay_cntr      <=  delay_cntr_nxt ; 
         shift_bits_cnt  <=  shift_bits_cnt_nxt ; 
         ps2_rx_done     <=  ps2_rx_done_nxt ; 
      end

   end 


   always @(*)  begin 
      ps2_clk_out    =  1'b1 ; 
      ps2_data_out_en  =  1'b0 ; 
      ps2_data_out   =  1'b1 ; 
      ps2_rx_busy    =  1'b1 ; 
      state_nxt      =  state_r ;    
      delay_cntr_nxt =  delay_cntr ; 
      load_clk_half_cnt =  1'b0;
      dec_clk_half_cnt  =  1'b0; 
      shift_bits_cnt_nxt   =  shift_bits_cnt ; 
      shift_bits_in     =  1'b0 ; 
      ps2_rx_done_nxt   =  1'b0 ; 
      case ( state_r ) 
         IDLE : begin 
            ps2_rx_busy =  1'b0 ;    
            if ( ~ ps2_clk_in  & ps2_data_in ) begin 
               state_nxt   =  RST   ;  
               delay_cntr_nxt =  INIT_CNTR_FOR_100US ; 
            end
         end
         RST: begin
            // Decrease delay_cntr untill it is zero and then held, 
            if ( | delay_cntr ) begin 
               delay_cntr_nxt =  delay_cntr - 1'b1 ;    
            end

            // If ps2_clk_in is released by host :
            // 1.  <100us ( delay_cntr_zero = 0), then come back to IDLE.
            // 2.  >100us ( imply ps2_data is NOT pulled down by host ), it is
            // error
            if ( ps2_clk_in ) begin 
               if ( delay_cntr_zero ) begin 
                  state_nxt   = ERROR ; 
               end else begin 
                  state_nxt   = IDLE ; 
               end
            end   
            
            // if host pulldowns data line >  100us, then enter request-hold    
            if ( ~ ps2_data_in ) begin 
               if ( delay_cntr_zero ) begin 
                  state_nxt   =  WAIT_CLK_HIGH ; 
               end else begin 
                  state_nxt   = ERROR ; 
               end
            end   
         end
         WAIT_CLK_HIGH : begin 
            if ( ps2_clk_in ) begin 
               state_nxt   =  START ;
               load_clk_half_cnt = 1'b1 ; 
            end   
         end 
         START : begin 
            if ( clk_half_time ==  1'b1 ) begin   
               state_nxt   =  DATA_A ; 
               load_clk_half_cnt = 1'b1 ; 
               shift_bits_cnt_nxt  = 8 ;   
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end
         end
         DATA_A : begin
            ps2_clk_out   =   1'b0 ;  
            if ( clk_half_time ==  1'b1 ) begin   
               state_nxt   = DATA_B ;  
               load_clk_half_cnt = 1'b1 ; 
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end   
         end      
         DATA_B : begin 
            shift_bits_in   =  1'b1 ; 
            if ( clk_half_time ==  1'b1 ) begin   
               if ( shift_bits_cnt == 4'h0 ) begin 
                  state_nxt   =  STOP_A  ;  
               end else begin 
                  state_nxt   = DATA_A ;  
                  shift_bits_cnt_nxt   =  shift_bits_cnt - 1'b1 ; 
               end
               load_clk_half_cnt = 1'b1 ; 
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end 
         end   
         STOP_A : begin 
            ps2_clk_out   =   1'b0 ;  
            if ( clk_half_time ==  1'b1 ) begin   
               state_nxt   =  STOP_B ;   
               load_clk_half_cnt = 1'b1 ; 
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end   
         end
         STOP_B : begin 
            if ( clk_half_time ==  1'b1 ) begin   
               load_clk_half_cnt = 1'b1 ; 
               if ( ps2_data_in ) begin 
                  state_nxt   =  ACK_A ;   
               end  
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end   
         end
         ACK_A : begin 
            ps2_data_out_en   =  1'b1 ; 
            ps2_data_out      =  1'b0 ; 
            if ( clk_half_time ==  1'b1 ) begin   
               state_nxt   = ACK_B ;  
               load_clk_half_cnt = 1'b1 ; 
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end   
         end 
         ACK_B : begin 
            ps2_clk_out       =  1'b0;
            ps2_data_out_en   =  1'b1 ; 
            ps2_data_out      =  1'b0 ; 
            if ( clk_half_time ==  1'b1 ) begin   
               ps2_rx_done_nxt  = 1'b1 ;  
`ifdef DEBUG                 
               $display("\t@%0dns: Device: recieved data is 0x%02h", $time, byte_in[7:0] ) ; 
`endif               
               if ( ^ byte_in[8:0] ) begin 
                  state_nxt   = IDLE  ;  
               end else begin 
`ifdef DEBUG               
                  $display("\t@%0dns: Device: parity error ", $time ) ; 
`endif               
                  state_nxt   = ERROR  ;  
               end    
            end else begin 
               dec_clk_half_cnt = 1'b1 ; 
            end   
         end 
         ERROR: begin
            $display("\t@%0dns: Device: error occurs", $time ) ; 
            state_nxt   =  IDLE ; 
         end
         default: begin 
            state_nxt   = ERROR ;       
         end         
      endcase
   end
      
endmodule    
