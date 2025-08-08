`timescale 1ns / 100ps

//`define TEST_HOST_TO_DEVICE_ONLY    
`define TEST_DEVICE_TO_HOST_ONLY   

module testbench () ;
  
  logic  clk ; 
  logic  rst ; 

  int i, error_num = 0  ;
  logic  ps2_host_wr_stb, ps2_host_tx_done, ps2_host_tx_ready, ps2_host_rx_en, ps2_host_rddata_valid, ps2_host_rx_done, ps2_host_rd_data_err, ps2_host_rx_ready   ; 
  logic  ps2_device_wr_stb, ps2_device_tx_done, ps2_device_tx_ready, ps2_device_rx_done ; 
  logic  [7:0]    ps2_host_wr_data, ps2_device_wr_data,  ps2_host_rd_data,  ps2_device_receive_data ; 
  logic  [7:0]    test_data ; 
  wire   ps2_clk, ps2_data ;  


  parameter TEST_NUM = 5000 ; 


  ps2_host_rxtx  ps2_host_rxtx_inst (
      .clk           (  clk         ),
      .rst           (  rst         ),
      .ps2_clk       (  ps2_clk     ),
      .ps2_data      (  ps2_data    ),
      .ps2_wr_stb    (  ps2_host_wr_stb  ),
      .ps2_wr_data   (  ps2_host_wr_data ), 
      .ps2_tx_done   (  ps2_host_tx_done ),
      .ps2_tx_ready  (  ps2_host_tx_ready),    
      .ps2_rx_en     (  ps2_host_rx_en ),
      .ps2_rddata_valid (  ps2_host_rddata_valid ),
      .ps2_rd_data   (  ps2_host_rd_data ), 
      .ps2_rx_done   (  ps2_host_rx_done ),
      .ps2_rd_data_err ( ps2_host_rd_data_err ),
      .ps2_rx_ready  ( ps2_host_rx_ready )   
  );   

  // delay of 100us is changed to 100ns. 
  // It is equal to (2**5)*20ns = 32 X 20ns = 640ns 
  defparam ps2_host_wrapper_inst.ps2_host_tx_inst.NUM_OF_BITS_FOR_100US = 5 ;  
  
  ps2_device_top #(
    .NUM_OF_BITS_FOR_100US (5) ,   
    .INIT_CNTR_FOR_100US   (5'h18) , 
    .NUM_OF_BITS_CLK_HALF_CNT ( 3 )  // one ps2 clock is 16 working clock cycles  
  ) ps2_device_top_inst  (       
      .clk           ( clk          ),
      .rst           ( rst          ),
      .ps2_clk       ( ps2_clk      ), 
      .ps2_data      ( ps2_data     ),
      .ps2_rx_done   ( ps2_device_rx_done  ),
      .ps2_receive_data ( ps2_device_receive_data ), 
      .ps2_wr_stb    ( ps2_device_wr_stb   ), 
      .ps2_wr_data   ( ps2_device_wr_data  ),
      .ps2_tx_done   ( ps2_device_tx_done  ),
      .ps2_tx_ready  ( ps2_device_tx_ready ) 
  );

  pullup( ps2_data ) ;
  pullup( ps2_clk  ) ; 

  always #10ns clk = ~ clk ; 
  


  initial begin 
     clk = 1'b0 ; 
     rst = 1'b1 ; 

     repeat (8) @(posedge clk ) ; 
     #5 rst = 1'b0; 
     repeat (20) @(posedge clk ) ; 

`ifdef  TEST_HOST_TO_DEVICE_ONLY 
     // Host write only test 
     $display("====== Host-to-device test begins ======");   
     for ( i = 1 ; i <= TEST_NUM ; i++ ) begin
         $display("Test %0d :", i )  ;  
         test_data = $random(); 
         ps2_host_tx_test( test_data ) ;
         repeat( 10 ) @ ( posedge clk ) ; 
     end
     
     $display( "Number of tests   : %d", TEST_NUM ) ; 
     $display( "Number of failure : %d", error_num ) ;  
     $display("====== Host-to-device test ends   ======");   
`endif

`ifdef TEST_DEVICE_TO_HOST_ONLY   
     // Host read only test 
     error_num = 0 ; 
     ps2_host_rx_en  =  1'b1 ;  
     $display("======= Device-to-Host test begins ====== ");   
     for ( i = 1 ; i <= TEST_NUM ; i++ ) begin
         $display("Test %0d :", i )  ;  
         test_data = $random(); 
         ps2_host_rx_test( test_data ) ;
         repeat( 10 ) @ ( posedge clk ) ; 
     end
     ps2_host_rx_en  =  1'b0 ;  
     $display( "Number of tests   : %d", TEST_NUM ) ; 
     $display( "Number of failure : %d", error_num ) ;  
     $display("======= Device-to-Host test ends   ====== ");   
`endif

     $finish ; 

  end

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
  end

  task ps2_host_tx_test ( input [7:0] data_test ) ;
      wait ( ps2_host_tx_ready == 1'b1 ) ;  
      @( posedge clk ) ; 
      ps2_host_wr_data    =    data_test; 
      ps2_host_wr_stb     =   1'b1 ; 
      @( posedge clk ) ; 
      ps2_host_wr_stb     =    1'b0 ; 
      $display ("\thost send     : 0x%02h", data_test ) ; 
      wait ( ps2_device_rx_done);  
      $display ("\tdevice Receive: 0x%02h", ps2_device_receive_data ) ; 
      if ( data_test == ps2_device_receive_data  ) begin 
         $display("\tstatus: Pass") ; 
      end else begin    
         error_num++ ; 
         $display("\tstatus: Fail @%0dns", $time) ; 
      end
  endtask : ps2_host_tx_test           

  assert property ( @( posedge clk ) 
        $rose(  ps2_host_wr_stb ) |-> ##[100:500] $rose(ps2_device_rx_done) ) 
  else  begin
        $display("Receiver does NOT respond. Force to stop simulationi !!!") ;  
        $finish() ;          
  end 


  task ps2_host_rx_test ( input [7:0] data_test ) ;
      wait ( ps2_device_tx_ready == 1'b1 ) ;  
      @( posedge clk ) ; 
      ps2_device_wr_data    =    data_test; 
      ps2_device_wr_stb     =    1'b1 ; 
      @( posedge clk ) ; 
      ps2_device_wr_stb     =    1'b0 ; 
      $display ("\tdevice send : 0x%02h", data_test ) ; 
      wait ( ps2_host_rx_done);  
      $display ("\thost receive: 0x%02h", ps2_host_rd_data ) ; 
      if ( data_test == ps2_host_rd_data ) begin 
         $display("\tstatus: Pass") ; 
      end else begin    
         error_num++ ; 
         $display("\tstatus: Fail @%0dns", $time) ; 
      end
  endtask : ps2_host_rx_test           

  assert property ( @( posedge clk ) 
        $rose(  ps2_device_wr_stb ) |-> ##[100:500] $rose(ps2_host_rx_done) ) 
  else  begin
        $display("Receiver does NOT respond. Force to stop simulationi !!!") ;  
        $finish() ;          
  end 

endmodule  

  
