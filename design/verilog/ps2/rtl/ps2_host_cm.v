`include "ps2_define.vh" 

module ps2_host_cm
(
   // Clock and reset    
   input        clk,
   input        rst,
   // PS/2 rxtx interface 
   input        ps2_tx_ready,   
   input        ps2_rddata_valid,
   input [7:0]  ps2_rd_data, 
   input        ps2_wr_stb,
   input [7:0]  ps2_wr_data,
   // ps2_host_monitor interface 
   output reg   cmd_rd_en,
   output reg   host_data_xfr,
   output reg   device_data_xfr,
   output reg   comment_data_xfr,
   output       data_xfr_int,  
   output reg   [ `MAX_SEL_NUM - 1 : 0  ]  comment_sel, 
   output reg   data_is_byte_1,
   output reg   data_is_byte_2,
   output reg   data_is_byte_3,
   input        ps2_wr_req,
   input        char_idx_end,
   input        host_data_start,
   input        device_data_start,
   input        uart_is_ready
);   

`include "ps2_pkg.vh" 


localparam IDLE         =  3'b000, 
           WAIT_CMD_ACK =  3'b001,
           INIT_STATUS  =  3'b010,
           RD_DEVICE_ID =  3'b011,
           RD_BYTE_2    =  3'b100,
           RD_BYTE_3    =  3'b101;

reg [2:0]   state_r, follow_state_r ; 
reg [7:0]   pre_cmd ; 
reg data_is_ack, data_is_wrong_ack, data_is_device_id, data_is_init_status ; 
wire  cmd_is_done ; 
wire comment_xfr_end  ; 
reg  uart_is_ready_1d ; 
wire uart_is_ready_change;  


assign  comment_xfr_end  = ( comment_data_xfr  & char_idx_end ) | rst  ; 


//synthesis attribute USELOWSKEWLINES of comment_xfr_end is "TRUE" ; 

always @( posedge clk ) begin 
   if ( rst ) begin 
      cmd_rd_en  <= 1'b0 ; 
   end else begin
  // fetch nre cmd from Uart if 
  //  1. Uart FIFO is not empty 
  //  2. PS2 controller is ready to send a new  cmd
  //  3. Previous sent is done. 
      if ( (  ps2_wr_req == 1'b1 ) && ( ps2_tx_ready == 1'b1 ) && ( cmd_is_done == 1'b1 ) && 
              ( ( host_data_xfr | device_data_xfr | comment_data_xfr ) == 1'b0 )  ) begin 
         cmd_rd_en  <=  1'b1 ; 
      end else begin 
         cmd_rd_en  <= 1'b0 ; 
      end
   end   
end



always @( posedge clk ) begin : gen_comment_sel 
   integer i ; 
   if ( comment_xfr_end  ) begin 
      for ( i = 0 ; i < `MAX_SEL_NUM ; i = i + 1 )   begin  
        comment_sel[i] <= 1'b0 ; 
      end    
   end else begin 

      if ( ps2_wr_stb == 1'b1 ) begin  
         case ( ps2_wr_data ) 
           PS2_CMD_RESET_CMD        : comment_sel[ RESET_CMD ]       <=  1'b1  ; //Reset command
           PS2_CMD_SET_REMOTE_MODE  : comment_sel[ SET_REMOTE_MODE ] <=  1'b1  ; //Set Remote Mode 
           PS2_CMD_GET_DEVICE_ID    : comment_sel[ GET_DEVICE_ID ]   <=  1'b1  ; //Get Deivce ID 
           PS2_CMD_SET_SAMPLE_RATE  : comment_sel[ SET_SAMPLE_RATE ] <=  1'b1  ; //Set Sample Rate  
           PS2_CMD_ENABLE_DATA_REP  : comment_sel[ ENABLE_DATA_REP ] <=  1'b1  ; //Enable Data Reporting
           PS2_CMD_DISAB_DATA_REP   : comment_sel[ DISAB_DATA_REP  ] <=  1'b1  ; //Disable Data Reporting
           PS2_CMD_SET_DEFAULT      : comment_sel[ SET_DEFAULT ]     <=  1'b1  ; //Set Defaults
           PS2_CMD_STATUS_REQ       : comment_sel[ STATUS_REQ ]      <=  1'b1  ; //Status Request
           PS2_CMD_SET_STREAM_MODE  : comment_sel[ SET_STREAM_MODE ] <=  1'b1  ; //Set Stream Mode 
           default :                  comment_sel[ INVALID_CMD ]     <=  1'b1  ; //Invlaid command 
         endcase   
      end else begin 
         if ( data_is_ack == 1'b1 )       comment_sel[ ACK ] <= 1'b1 ; // Acknowledgment 
         if ( data_is_wrong_ack == 1'b1 ) comment_sel[ INVALID_ACK ] <= 1'b1 ; // Invalid ACK  
         if ( data_is_device_id == 1'b1 ) comment_sel[ DEVICE_ID ] <= 1'b1;   // Devce ID 
         if ( data_is_init_status == 1'b1 ) comment_sel[ TEST_PASS] <= 1'b1 ; // self-test passed 
         if ( data_is_byte_1 == 1'b1 )    comment_sel[ BYTE_1 ] <= 1'b1 ; //  
         if ( data_is_byte_2 == 1'b1 )    comment_sel[ BYTE_2 ] <= 1'b1 ; //  
         if ( data_is_byte_3 == 1'b1 )    comment_sel[ BYTE_3 ] <= 1'b1 ; //  
      end 
   end
end   
/*

always @( posedge clk ) begin 
   if ( rst == 1'b1 ) begin 
      state_r  <= IDLE ; 
      cmd_is_done <= 1'b1 ; 
      data_is_ack <= 1'b0 ; 
      data_is_wrong_ack <= 1'b0 ;  
      data_is_device_id  <= 1'b0  ; 
      data_is_byte_1 <= 1'b0 ;  
      data_is_byte_2 <= 1'b0 ;  
      data_is_byte_3 <= 1'b0 ;  
   end else begin 
      cmd_is_done <= 1'b1 ; 
      data_is_ack <= 1'b0 ; 
      data_is_wrong_ack <= 1'b0 ;  
      data_is_device_id  <= 1'b0  ; 
      data_is_byte_1 <= 1'b0 ;  
      data_is_byte_2 <= 1'b0 ;  
      data_is_byte_3 <= 1'b0 ;  
      case ( state_r ) 
         IDLE : begin 
            if ( ps2_wr_stb == 1'b1 ) begin 
               cmd_is_done <= 1'b0 ; 
               state_r   <=  WAIT_CMD_ACK ; 
            end
         end 
         WAIT_CMD_ACK : begin 
            cmd_is_done <= 1'b0 ; 
            if ( ps2_rddata_valid == 1'b1 ) begin 
              state_r   <= ACK_DONE ;  
              if ( ps2_rd_data == PS2_RD_ACK ) begin 
                  data_is_ack <= 1'b1 ; 
              end else begin     
                  data_is_wrong_ack <= 1'b1 ; 
              end    
            end 
         end   
         ACK_DONE : begin 
            if ( ps2_wr_stb == 1'b1 ) begin 
               cmd_is_done <= 1'b0 ; 
               state_r   <= WAIT_CMD_ACK ; 
            end else begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  case ( pre_cmd ) 
                     PS2_CMD_GET_DEVICE_ID : begin 
                        data_is_device_id  <= 1'b1 ; 
                        state_r <=  RD_DEVICE_ID   ;                
                     end    
                     PS2_CMD_RESET_CMD : begin 
                        data_is_init_status <= 1'b1 ; 
                        state_r <=  INIT_STATUS ;  
                     end
                     default: begin 
                        data_is_byte_1 <= 1'b1;
                        state_r   <=  RD_BYTE_1 ;     
                     end    
                  endcase 
               end    
            end  
         end   
         INIT_STATUS : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_device_id  <= 1'b1 ;
               state_r   <=  RD_DEVICE_ID ; 
            end    
         end 
         RD_DEVICE_ID : begin 
            state_r   <=  ACK_DONE  ; 
         end
         RD_BYTE_1 : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_byte_2 <= 1'b1; 
               state_r  <=  RD_BYTE_2  ; 
            end    
         end
         RD_BYTE_2 : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_byte_3 <= 1'b1; 
               state_r   <= RD_BYTE_3  ; 
            end    
         end
         RD_BYTE_3 : state_r   <=  ACK_DONE  ; 
         default :   state_r   <=  ACK_DONE ; 
            
      endcase    
   end
end 
*/

assign cmd_is_done = ( state_r == IDLE ) ? 1'b1 : 1'b0  ; 

always @( posedge clk ) begin 
   if ( rst == 1'b1 ) begin 
      state_r  <= IDLE ; 
      data_is_ack <= 1'b0 ; 
      data_is_wrong_ack <= 1'b0 ;  
      data_is_device_id  <= 1'b0  ; 
      data_is_init_status <= 1'b0 ; 
      data_is_byte_1 <= 1'b0 ;  
      data_is_byte_2 <= 1'b0 ;  
      data_is_byte_3 <= 1'b0 ;  
   end else begin 
      data_is_ack <= 1'b0 ; 
      data_is_wrong_ack <= 1'b0 ;  
      data_is_init_status <= 1'b0 ; 
      data_is_device_id  <= 1'b0  ; 
      data_is_byte_1 <= 1'b0 ;  
      data_is_byte_2 <= 1'b0 ;  
      data_is_byte_3 <= 1'b0 ;  

      case ( state_r ) 
         IDLE : begin 
            if ( ps2_wr_stb == 1'b1 ) begin 
               pre_cmd   <= ps2_wr_data ; 
               state_r   <=  WAIT_CMD_ACK ; 
            end else if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_byte_1 <= 1'b1; 
               state_r  <=  RD_BYTE_2  ; 
            end      
         end 
         WAIT_CMD_ACK : begin 
            case ( pre_cmd ) 
               PS2_CMD_GET_DEVICE_ID : begin 
                  follow_state_r <=  RD_DEVICE_ID   ;                
               end    
               PS2_CMD_RESET_CMD : begin 
                  follow_state_r <=  INIT_STATUS ;  
               end
               default: begin 
                  follow_state_r   <=  IDLE ;     
               end    
            endcase 

            if ( ps2_rddata_valid == 1'b1 ) begin 
              state_r   <= follow_state_r ;  
              if ( ps2_rd_data == PS2_RD_ACK ) begin 
                  data_is_ack <= 1'b1 ; 
              end else begin     
                  data_is_wrong_ack <= 1'b1 ; 
              end    
            end 
         end
         INIT_STATUS : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_init_status <= 1'b1 ; 
               state_r   <=  RD_DEVICE_ID ; 
            end    
         end 
         RD_DEVICE_ID : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_device_id  <= 1'b1 ;
               state_r   <=  IDLE  ; 
            end   
         end
         RD_BYTE_2 : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_byte_2 <= 1'b1; 
               state_r   <= RD_BYTE_3  ; 
            end    
         end
         RD_BYTE_3 : begin 
            if ( ps2_rddata_valid == 1'b1 ) begin 
               data_is_byte_3 <= 1'b1; 
               state_r   <= IDLE  ; 
            end    
         end
         default :  state_r   <=  IDLE ; 
               
      endcase    
   end   
end


assign   data_xfr_int  = uart_is_ready & ( host_data_xfr | device_data_xfr |  
                            ( comment_data_xfr & ( uart_is_ready_change | ~ char_idx_end ) )  )  ; 

always @( posedge clk ) begin 
   uart_is_ready_1d    <=  uart_is_ready ; 
end 

assign  uart_is_ready_change = ( uart_is_ready != uart_is_ready_1d ) ; 


always @( posedge clk ) begin 
   if ( rst == 1'b1 ) begin 
      host_data_xfr      <= 1'b0 ; 
      device_data_xfr    <= 1'b0 ; 
      comment_data_xfr   <= 1'b0 ; 
   end else begin 
      if (  char_idx_end == 1'b1 ) begin 
          host_data_xfr      <= 1'b0 ; 
          device_data_xfr    <= 1'b0 ; 
          comment_data_xfr   <= ~comment_data_xfr   ; 
      end else begin  
          if ( host_data_start == 1'b1 ) begin
             host_data_xfr  <= 1'b1 ; 
          end   
          
          if ( device_data_start == 1'b1 ) begin 
             device_data_xfr <= 1'b1 ;
          end
      end
   end
end



`ifdef SVA 

   // ONLY 1 or NOT in xx_data_xfr is HIGH 
   assert property ( @(posedge clk ) 
      $onehot0( { host_data_xfr, device_data_xfr, comment_data_xfr } ) 
   );   

   // ONLY 1 or not select singal within comment_sel is HIGH 
   assert property ( @(posedge clk ) 
      $onehot0( comment_sel ) 
   ) ;    

   assert property ( @( posedge clk ) 
      ( $rose(ps2_wr_stb) ) |-> ##1 $onehot( comment_sel ) 
   );   
   
   assert property ( @( posedge clk ) 
      ( $rose (ps2_rddata_valid)  ) |-> ##2 $onehot( comment_sel ) 
   );   
   
   // when host sent out data :
   // 1. data_xfr_int must be HIGH during the follwing
   //    10 NON-CONTINOUS clocks( because uart may be full at some clock
   //    cycles ) to send  10 bytes to uart for display 
   // 2. then comment_dat_start is high for initiating displaying comments
   assert property ( @(posedge clk ) 
      ( $rose( ps2_rddata_valid ) || $rose( ps2_wr_stb ) ) |-> ##[1:5] ( data_xfr_int[->10] ) ## [1:30] comment_data_xfr    
   );    
/*
   assert property ( @( posedge clk ) 
      $rose(ps2_wr_stb) |=> ( $past( state_r == IDLE ||  state_r == ACK_DONE ) )  && ( state_r == WAIT_CMD_ACK )    
   );
*/
`endif

endmodule 
