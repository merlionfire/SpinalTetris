`define  RST   1'b0 

module pcb  ( 
    input   CLK_50M,
    input   BTN_SOUTH , 
    input   RS232_DCE_RXD,
    output  RS232_DCE_TXD, 
    inout   PS2_CLK1,
    inout   PS2_DATA1
);

  `include  "ps2_pkg.vh" 
   
   wire  dcm_locked;         // DCM output: lock signal, used as reset to other circuitry
   (* keep = "yes" *) wire  clk_50mhz_i, analyzer_clk ;        // 50 MHz clock, post-IBUFG
   (* keep = "yes" *) wire  clk_100mhz ;    
   wire  dcm_clk_50mhz,  ps2_host_clk, uart_clk ;       // DCM output: 50 MHz, Phase 0   
   wire  uart_rx, uart_tx ; 
   wire  btn_south_io, btn_south_io_filter, btn_south_io_filter_pulse; 

   wire  uart_tx_full, uart_tx_almost_full,  uart_wr_en,  uart_rx_empty,  uart_rd_en,  uart_rddata_valid; 
   wire  [7:0] uart_wr_data,  uart_rd_data;

// synthesis attribute keep of uart_wr_en is "true" 
// synthesis attribute keep of uart_wr_data is "true"
// synthesis attribute keep of uart_rddata_valid is "true" 
// synthesis attribute keep of uart_rd_en is "true"
// synthesis attribute keep of uart_rd_data is "true"
// synthesis attribute keep of uart_rx_empty is "true"
// synthesis attribute keep of uart_rx is "true"
// synthesis attribute keep of uart_tx is "true"


   // Module instatiatation 
   analyzer_clock analyzer_clock_inst  (
         .U1_CLKIN_IN   (  CLK_50M            ), 
         .U1_RST_IN     (  1'b0               ), 
         .U1_CLKIN_IBUFG_OUT( clk_50mhz_i     ), 
         .U1_CLK2X_OUT  (  clk_100mhz         ), 
         .U2_CLKDV_OUT  (  dcm_clk_50mhz      ), 
         .U2_CLK0_OUT   (  analyzer_clk       ), 
         .U2_LOCKED_OUT (  dcm_locked         )
    );

   btn_filter  #(.PIN_NUM (1 ) ) top_btn_filter_inst (
     .clk     (  ps2_host_clk   ),
     .pin_in  ( { btn_south_io} ),
     .pin_out ( { btn_south_io_filter } ) 
   );


  (* keep_hierarchy ="yes" *)  ps2_host_top  ps2_host_top_inst (
      .clk               ( ps2_host_clk      ), //i
      .rst               ( ps2_host_rst      ), //i
      .ps2_clk           ( PS2_CLK1          ), //i
      .ps2_data          ( PS2_DATA1         ), //i
      .uart_tx_full      ( uart_tx_full      ), //i
      .uart_tx_almost_full      ( uart_tx_almost_full      ), //i
      .uart_wr_data      ( uart_wr_data      ), //o
      .uart_wr_en        ( uart_wr_en        ), //o
      .uart_rx_empty     ( uart_rx_empty     ), //i
      .uart_rd_en        ( uart_rd_en        ), //o
      .uart_rd_data      ( uart_rd_data      ), //i
      .uart_rddata_valid ( uart_rddata_valid )  //i
   );


  (* keep_hierarchy ="yes" *)  uart  uart_inst (
      .clk           ( uart_clk          ),
      .rst           ( uart_rst          ),
      .rx            ( uart_rx           ),
      .tx            ( uart_tx           ),
      .tx_full       ( uart_tx_full      ),
      .tx_almost_full  ( uart_tx_almost_full      ),
      .wr_data       ( uart_wr_data      ), 
      .wr_en         ( uart_wr_en        ),
      .rx_empty      ( uart_rx_empty     ),
      .rd_en         ( uart_rd_en        ), 
      .rd_data       ( uart_rd_data      ),
      .rd_data_valid ( uart_rddata_valid )
   );

   // IO connection 
   assign   uart_rx =  RS232_DCE_RXD ;
   assign   RS232_DCE_TXD  = uart_tx ;
   assign   btn_south_io = BTN_SOUTH  ;  
   // Clock and reset 
   assign   uart_clk      =  dcm_clk_50mhz ; 
   assign   ps2_host_clk  =  dcm_clk_50mhz ; 
   assign   uart_rst  =  btn_south_io_filter ;  
   assign   ps2_host_rst  =  btn_south_io_filter ;  
endmodule 
