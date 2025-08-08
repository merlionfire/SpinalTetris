
`include "ps2_define.vh" 

module ps2_host_top (
   // Clock and reset    
   input        clk,
   input        rst,
   // PS/2 interface 
   inout        ps2_clk,
   inout        ps2_data,
   // uart port iterface 
   input        uart_tx_full,  
   input        uart_tx_almost_full,  
   output [7:0] uart_wr_data,  
   output       uart_wr_en,
   input        uart_rx_empty,  
   output       uart_rd_en,
   input  [7:0] uart_rd_data,
   input        uart_rddata_valid
);


wire  ps2_tx_ready,  ps2_rddata_valid,  ps2_wr_stb,  cmd_rd_en; 
wire host_data_xfr,  device_data_xfr,  comment_data_xfr,  data_xfr_int,  data_is_byte_1,  data_is_byte_2,  data_is_byte_3, ps2_wr_req,  char_idx_end,  host_data_start,  device_data_start ; 
      
wire uart_is_ready, ps2_tx_done, ps2_rx_ready; 

wire [7:0] ps2_rd_data;
wire [7:0] ps2_wr_data;
wire [  `MAX_SEL_NUM-1 :0] comment_sel;

// synthesis attribute keep of uart_is_ready is "true" 
// synthesis attribute keep of data_xfr_int is "true" 
// synthesis attribute keep of uart_wr_data is "true" 
// synthesis attribute keep of uart_wr_en is "true" 
// synthesis attribute keep of host_data_xfr is "true" 
// synthesis attribute keep of device_data_xfr is "true" 
// synthesis attribute keep of comment_data_xfr is "true" 

ps2_host_cm  ps2_host_cm_inst (
   .clk               ( clk               ), //i
   .rst               ( rst               ), //i
   .ps2_tx_ready      ( ps2_tx_ready      ), //i
   .ps2_rddata_valid  ( ps2_rddata_valid  ), //i
   .ps2_rd_data       ( ps2_rd_data       ), //i
   .ps2_wr_stb        ( ps2_wr_stb        ), //i
   .ps2_wr_data       ( ps2_wr_data       ), //i
   .cmd_rd_en         ( cmd_rd_en         ), //o
   .host_data_xfr     ( host_data_xfr     ), //o
   .device_data_xfr   ( device_data_xfr   ), //o
   .comment_data_xfr  ( comment_data_xfr  ), //o
   .data_xfr_int      ( data_xfr_int      ), //o
   .comment_sel       ( comment_sel       ), //o
   .data_is_byte_1    ( data_is_byte_1    ), //o
   .data_is_byte_2    ( data_is_byte_2    ), //o
   .data_is_byte_3    ( data_is_byte_3    ), //o
   .ps2_wr_req        ( ps2_wr_req        ), //i
   .char_idx_end      ( char_idx_end      ), //i
   .host_data_start   ( host_data_start   ), //i
   .device_data_start ( device_data_start ), //i
   .uart_is_ready     ( uart_is_ready     )  //i
);

ps2_host_monitor  ps2_host_monitor_inst (
   .clk               ( clk               ), //i
   .rst               ( rst               ), //i
   .ps2_wr_stb        ( ps2_wr_stb        ), //o
   .ps2_wr_data       ( ps2_wr_data       ), //o
   .ps2_rddata_valid  ( ps2_rddata_valid  ), //i
   .ps2_rd_data       ( ps2_rd_data       ), //i
   .uart_tx_full      ( uart_tx_full      ), //i
   .uart_tx_almost_full      ( uart_tx_almost_full      ), //i
   .uart_wr_en        ( uart_wr_en        ), //o
   .uart_wr_data      ( uart_wr_data      ), //o
   .uart_rx_empty     ( uart_rx_empty     ), //i
   .uart_rd_en        ( uart_rd_en        ), //o
   .uart_rddata_valid ( uart_rddata_valid ), //i
   .uart_rd_data      ( uart_rd_data      ), //i
   .cmd_rd_en         ( cmd_rd_en         ), //i
   .host_data_xfr     ( host_data_xfr     ), //i
   .device_data_xfr   ( device_data_xfr   ), //i
   .comment_data_xfr  ( comment_data_xfr  ), //i
   .data_xfr_int      ( data_xfr_int      ), //i
   .comment_sel       ( comment_sel       ), //i
   .data_is_byte_1    ( data_is_byte_1    ), //i
   .data_is_byte_2    ( data_is_byte_2    ), //i
   .data_is_byte_3    ( data_is_byte_3    ), //i
   .ps2_wr_req        ( ps2_wr_req        ), //o
   .char_idx_end      ( char_idx_end      ), //o
   .host_data_start   ( host_data_start   ), //o
   .device_data_start ( device_data_start ), //o
   .uart_is_ready     ( uart_is_ready     )  //o
);

ps2_host_rxtx  ps2_host_rxtx_inst (
   .clk               ( clk               ), //i
   .rst               ( rst               ), //i
   .ps2_clk           ( ps2_clk           ), //i
   .ps2_data          ( ps2_data          ), //i
   .ps2_wr_stb        ( ps2_wr_stb        ), //i
   .ps2_wr_data       ( ps2_wr_data       ), //i
   .ps2_tx_done       ( ps2_tx_done       ), //o
   .ps2_tx_ready      ( ps2_tx_ready      ), //o
   .ps2_rddata_valid  ( ps2_rddata_valid  ), //o
   .ps2_rd_data       ( ps2_rd_data       ), //o
   .ps2_rx_ready      ( ps2_rx_ready      )  //o
);


endmodule 
