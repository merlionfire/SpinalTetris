`timescale 1ns / 100ps

module testbench () ;
  
  // clocks and resets 
  logic   clk ; 
  logic   ps2_host_clk, ps2_device_clk  ; 
  logic   rst ; 
 
  // PS/2 bus signals 
  wire  ps2_clk, ps2_data ;  

  // uart interface signals 
  logic  uart_tx_full, uart_tx_almost_full,  uart_wr_en,  uart_rx_empty,  uart_rd_en,  uart_rddata_valid; 
  logic  [7:0] uart_wr_data,  uart_rd_data;

  // PS/2 device interface singals  
  logic   ps2_device_soft_rst ; 

  // test vars
  int i, error_num = 0  ;
  int num_uart_wr = 0 ; 
  logic   [7:0]  disp_byte ; 
  logic   [4:0]  delay_cycle ; 
  string  disp_str, disp_char ; 

  `include  "ps2_pkg.vh" 

  parameter TEST_NUM = 5000 ; 

   ps2_host_top  ps2_host_top_inst (
      .clk               ( clk               ), //i
      .rst               ( rst               ), //i
      .ps2_clk           ( ps2_clk           ), //i
      .ps2_data          ( ps2_data          ), //i
      .uart_tx_full      ( uart_tx_full      ), //i
      .uart_tx_almost_full      ( uart_tx_almost_full      ), //i
      .uart_wr_data      ( uart_wr_data      ), //o
      .uart_wr_en        ( uart_wr_en        ), //o
      .uart_rx_empty     ( uart_rx_empty     ), //i
      .uart_rd_en        ( uart_rd_en        ), //o
      .uart_rd_data      ( uart_rd_data      ), //i
      .uart_rddata_valid ( uart_rddata_valid )  //i
   );

  ps2_device_top #(
  ) ps2_device_top_inst  (       
      .clk           ( ps2_device_clk ),
      .rst           ( ps2_device_soft_rst ),
      .ps2_clk       ( ps2_clk      ), 
      .ps2_data      ( ps2_data     )
  );

  pullup( ps2_data ) ;
  pullup( ps2_clk  ) ; 

  assign  ps2_host_clk = clk ; 
  assign  ps2_device_clk = clk ; 

  always #10ns clk = ~ clk ; 
  
  initial begin 
     clk = 1'b0 ; rst = 1'b1 ; ps2_device_soft_rst = 1'b1 ;  uart_rx_empty = 1'b1 ; uart_tx_almost_full = 1'b0 ; uart_tx_full = 1'b0 ;  uart_rddata_valid = 1'b0  ; 
     delay_cycle = 'h0 ;  num_uart_wr = 0;  

     //reset dut 
     repeat (8) @(posedge clk ) ; 
     #5 rst = 1'b0; ps2_device_soft_rst = 1'b0 ;  
     repeat (20) @(posedge clk ) ; 
      
     /*
     for ( int i=0 ; i< NUM_TESTS ; i++ ) begin 
         send_cmd = $random(); 
     end
     */

     //write_ps2( 8'hcc ) ; 
     //write_ps2( PS2_CMD_GET_DEVICE_ID );
     write_ps2( PS2_CMD_RESET_CMD );
     write_ps2( PS2_CMD_SET_STREAM_MODE );
     // Send fake command. Uart_rd_en being HIGH means ACK for last command has been received,  
     uart_rx_empty = 1'b0 ; 
     wait ( uart_rd_en == 1'b1 ) ; 
     $display("@%t find uart_rd_en", $time ) ; 
     repeat( 1000000 ) @( posedge clk ) ; 
     
     write_ps2( PS2_CMD_SET_REMOTE_MODE );
     // Send fake command. Uart_rd_en being HIGH means ACK for last command has been received,  
     uart_rx_empty = 1'b0 ; 
     wait ( uart_rd_en == 1'b1 ) ; 
     $display("@%t find uart_rd_en", $time ) ; 
     repeat( 1000000 ) @( posedge clk ) ; 

     write_ps2( PS2_CMD_SET_SAMPLE_RATE );
     write_ps2( PS2_CMD_ENABLE_DATA_REP );
     write_ps2( PS2_CMD_DISAB_DATA_REP );
     write_ps2( PS2_CMD_SET_DEFAULT );
     write_ps2( PS2_CMD_GET_DEVICE_ID );
     write_ps2( PS2_CMD_STATUS_REQ );
     
     uart_rx_empty = 1'b0 ; 
     wait ( uart_rd_en == 1'b1 ) ; 
     $display("@%t find uart_rd_en", $time ) ; 
     repeat( 100 ) @( posedge clk ) ; 
     $finish ; 

  end


  //issue a byte 
  task write_ps2 ( input [7:0] send_cmd );

     uart_rx_empty = 1'b0 ;   // Notify ps2_host_monior that uart has data for you 
     wait( uart_rd_en == 1'b1 ); 
     @( posedge clk ) #2 uart_rx_empty = 1'b1 ; uart_rddata_valid = 1'b1; uart_rd_data = send_cmd ; $display("send command: 0x%02h", uart_rd_data ) ;   
     @( posedge clk ) #2 uart_rddata_valid = 1'b0 ; 
     repeat( 10) @ ( posedge clk ) ; 
  endtask : write_ps2  


  // Simulate PC displays data from uart in the terminal 
  always @( posedge clk ) begin 
      if ( uart_wr_en == 1'b1 ) begin
           disp_byte <= uart_wr_data ; 
           num_uart_wr++ ;
           uart_tx_full <= 1'b0;  
           uart_tx_almost_full <= 1'b0;  
           if ( num_uart_wr >= 16 ) begin 
              uart_tx_full <= 1'b1;  
           end else if ( num_uart_wr == 15 ) begin 
              uart_tx_almost_full <= 1'b1;  
           end
           
           #1 $sformat(disp_char,"%c",disp_byte ) ; 
           `ifdef   VERBOSE  
              $display( "@%t:disp_byte =0x%02h", $time, disp_byte ) ;  
           `endif   
           disp_str = { disp_str, disp_char } ;
           if ( disp_byte == 8'h0a ) begin    // CR is the last char of comments 
              $display("@%t:display: %s", $time, disp_str ) ;
              disp_str = "" ;  
           end   
      end         
  end


  always @( posedge clk ) begin 
      if ( uart_tx_full == 1'b1 ) begin 
         if ( delay_cycle >= 10 ) begin 
            num_uart_wr-- ; 
            delay_cycle <= 0 ; 
            if ( num_uart_wr <= 15 ) begin 
              uart_tx_full <= 1'b0;  
            end  
         end else begin 
            delay_cycle <= delay_cycle + 1 ; 
         end
      end   
  end 
  /*-----------------------------------------------------------------*/
  /*-------------------- PS/2 Mouse model controller ----------------*/ 
  /*-----------------------------------------------------------------*/
   



  /*-----------------------------------------------------------------*/
  /*-------------------- FSDB dumper  -------------------------------*/ 
  /*-----------------------------------------------------------------*/

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
  end

endmodule  
