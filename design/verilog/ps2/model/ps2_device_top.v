module ps2_device_top  #(
   parameter NUM_OF_BITS_FOR_100US = 13,   
   parameter INIT_CNTR_FOR_100US   = 13'h1f00, 
   // 10KHz < ps2_clk < 16.7 ( 60us < T < 100us ) 
   // 30us < T/2 < 50us 
   // if clk is 20ns, 1500 < cnt < 2500. 
   //  cnt [10:0]  and CNT_min = 1024*2 = 2048
   parameter  NUM_OF_BITS_CLK_HALF_CNT = 11     
) 
( 
   input        clk,
   input        rst,
   // PS/2 bus interface 
   inout        ps2_clk,
   inout        ps2_data
);

`include "ps2_pkg.vh" 

  // rx signals 
  logic [7:0] ps2_receive_data; 
  logic       ps2_rx_done;
  logic       ps2_rx_busy;
  // tx signals 
  logic [7:0] ps2_wr_data;
  logic       ps2_wr_stb; 
  logic       ps2_tx_done;
  logic       ps2_tx_ready; 

  logic [7:0] device_id = 8'h89 ;   
  logic [3:0] state_r, state_nxt, follow_state, follow_state_nxt ;  
  logic [7:0] byte_1 = { 1'b0, 1'b0,   1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1} ; 
  logic [7:0] byte_2 = 8'h12 ; 
  logic [7:0] byte_3 = 8'h82 ; 
  logic [7:0] cmd_latch ;  
  logic       stream_mode_en = 1'b0 ;
  logic       mouse_is_move  = 1'b0 ;  


  // State machine state 
  localparam
     IDLE                  =  4'h1,
     SEND_ACK              =  4'h2,
     WAIT_ACK_OUT          =  4'h3,
     SEND_SELF_TEST_PASS   =  4'h4,
     SEND_DEVICE_ID        =  4'h5, 
     SEND_BYTE_1           =  4'h6,      
     SEND_BYTE_2           =  4'h7,      
     SEND_BYTE_3           =  4'h8,      
     WAIT_DATA_OUT         =  4'h9;


  ps2_device_rx #(
    .NUM_OF_BITS_FOR_100US ( NUM_OF_BITS_FOR_100US  ) ,   
    .INIT_CNTR_FOR_100US   ( INIT_CNTR_FOR_100US    ) , 
    .NUM_OF_BITS_CLK_HALF_CNT ( NUM_OF_BITS_CLK_HALF_CNT  )  // one ps2 clock is 16 working clock cycles  
  ) ps2_device_rx_inst  (       
      .clk           ( clk       ),
      .rst           ( rst       ),
      .ps2_clk       ( ps2_clk   ), 
      .ps2_data      ( ps2_data  ),
      .ps2_receive_data             ( ps2_receive_data ), 
      .ps2_rx_done   ( ps2_rx_done ),
      .ps2_rx_busy   ( ps2_rx_busy )
  );


  ps2_device_tx #( 
    .NUM_OF_BITS_CLK_HALF_CNT ( NUM_OF_BITS_CLK_HALF_CNT  ) 
  ) ps2_device_tx_inst   (
      .clk           ( clk       ),
      .rst           ( rst       ),
      .ps2_clk       ( ps2_clk   ), 
      .ps2_data      ( ps2_data  ),
      .ps2_wr_data   ( ps2_wr_data ),
      .ps2_wr_stb    ( ps2_wr_stb ), 
      .ps2_tx_done   ( ps2_tx_done ),
      .ps2_tx_ready  ( ps2_tx_ready ) 
  );    



  always @( posedge clk ) begin 
     if ( rst == 1'b1 ) begin
        cmd_latch <= 8'h00 ;  
        state_r   <= IDLE ;  
        follow_state <= IDLE ;  
     end else begin 
        if ( ps2_rx_done == 1'b1 ) begin   
            cmd_latch <= ps2_receive_data; 
        end 
        state_r <= state_nxt ; 
        follow_state <= follow_state_nxt ;
     end 

  end 

 
  always @( posedge clk ) begin 
     if ( rst == 1'b1 ) begin
          stream_mode_en <= 1'b0;
     end else begin 
         if ( cmd_latch == PS2_CMD_SET_REMOTE_MODE ) begin
            stream_mode_en <= 1'b0 ;
         end else if ( cmd_latch == PS2_CMD_SET_STREAM_MODE ) begin
            stream_mode_en <= 1'b1 ;
         end   
     end 
  end


  always begin 
     repeat( 50 ) @( posedge clk ) ;
     mouse_is_move = 1'b1; 
     @( posedge clk ) ;
     mouse_is_move =  1'b0;
  end   

  always_comb begin
     ps2_wr_stb         =  1'b0;
     ps2_wr_data        =  8'h00;
     follow_state_nxt   =  follow_state ; 
     state_nxt          =  state_r ;
     if ( ps2_rx_done == 1'b1 ) begin  // Host cmd has high priority  
        state_nxt   =  SEND_ACK ; 
     end else begin          
        case ( state_r ) 
           IDLE : begin 
              if ( ( stream_mode_en == 1'b1 ) && (  mouse_is_move  == 1'b1 ) ) begin 
                 state_nxt   = SEND_BYTE_1 ; 
              end 
           end 
           // PS/2 mouse reply ACK when receivng command from host
           SEND_ACK : begin 
              ps2_wr_stb   = 1'b1 ; 
              ps2_wr_data  = PS2_RD_ACK ;  
              state_nxt    = WAIT_ACK_OUT ; 
           end 
           WAIT_ACK_OUT : begin 
              if ( ps2_tx_done == 1'b1 ) begin   
                  case ( cmd_latch ) 
                     PS2_CMD_RESET_CMD       : state_nxt = SEND_SELF_TEST_PASS ;                           
                     PS2_CMD_GET_DEVICE_ID   : state_nxt = SEND_DEVICE_ID;
                     default:                  state_nxt = IDLE ;   
                  endcase    
              end
           end 
           SEND_SELF_TEST_PASS : begin 
              ps2_wr_stb   = 1'b1 ; 
              ps2_wr_data  = PS2_RD_PASS ;  
              follow_state_nxt   = SEND_DEVICE_ID ; 
              state_nxt    = WAIT_DATA_OUT ;  
           end
           SEND_DEVICE_ID : begin
              ps2_wr_stb   = 1'b1 ; 
              ps2_wr_data  = device_id  ;  
              follow_state_nxt   =  IDLE ; 
              state_nxt    = WAIT_DATA_OUT ;  
           end
           SEND_BYTE_1  : begin 
              ps2_wr_stb   = 1'b1 ; 
              ps2_wr_data  = byte_1  ;  
              follow_state_nxt   =  SEND_BYTE_2 ; 
              state_nxt    = WAIT_DATA_OUT ;  
           end 
           SEND_BYTE_2  : begin 
              ps2_wr_stb   = 1'b1 ; 
              ps2_wr_data  = byte_2  ;  
              follow_state_nxt   =  SEND_BYTE_3 ; 
              state_nxt    = WAIT_DATA_OUT ;  
           end 
           SEND_BYTE_3  : begin 
              ps2_wr_stb   = 1'b1 ; 
              ps2_wr_data  = byte_3  ;  
              follow_state_nxt   =  IDLE; 
              state_nxt    = WAIT_DATA_OUT ;  
           end 
           WAIT_DATA_OUT : begin 
              if ( ps2_tx_done == 1'b1 ) begin 
                state_nxt =  follow_state ; 
              end
           end   
           default : begin
              state_nxt =  IDLE ;  
           end 
        endcase 
     end   
  end 
endmodule   
