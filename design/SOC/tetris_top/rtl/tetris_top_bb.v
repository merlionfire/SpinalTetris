module ascii_font16x8 #(
  parameter addressWidth = 11,
  parameter wordWidth =8 )(
   input  wire         clk,
   input  wire [addressWidth-1:0]   font_bitmap_addr,
   output wire [wordWidth-1:0]      font_bitmap_byte
);

// Simulation model
/*
   reg [7:0]   bitmap_reg [ 0 : 2047 ] ;
   reg         font_bitmap_byte_r ;

   assign   font_bitmap_byte =  font_bitmap_byte_r ;
   initial begin
      $readmemh("../rtl/ascii_font16x8.mem", bitmap_reg, 0, 2047 ) ;
   end

   always @( posedge clk ) begin
      font_bitmap_byte_r <= bitmap_reg[ font_bitmap_addr] ;
   end
*/
   // 128 ascii chars' 16X8 font bitmap
   RAMB16_S9 #(
    .INIT    ( 9'h000 ),
    .INIT_00 ( 256'h00_00_00_00_7e_81_81_99_bd_81_81_a5_81_7e_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00 ),
    .INIT_01 ( 256'h00_00_00_00_10_38_7c_fe_fe_fe_fe_6c_00_00_00_00_00_00_00_00_7e_ff_ff_e7_c3_ff_ff_db_ff_7e_00_00 ),
    .INIT_02 ( 256'h00_00_00_00_3c_18_18_e7_e7_e7_3c_3c_18_00_00_00_00_00_00_00_00_10_38_7c_fe_7c_38_10_00_00_00_00 ),
    .INIT_03 ( 256'h00_00_00_00_00_00_18_3c_3c_18_00_00_00_00_00_00_00_00_00_00_3c_18_18_7e_ff_ff_7e_3c_18_00_00_00 ),
    .INIT_04 ( 256'h00_00_00_00_00_3c_66_42_42_66_3c_00_00_00_00_00_ff_ff_ff_ff_ff_ff_e7_c3_c3_e7_ff_ff_ff_ff_ff_ff ),
    .INIT_05 ( 256'h00_00_00_00_78_cc_cc_cc_cc_78_32_1a_0e_1e_00_00_ff_ff_ff_ff_ff_c3_99_bd_bd_99_c3_ff_ff_ff_ff_ff ),
    .INIT_06 ( 256'h00_00_00_00_e0_f0_70_30_30_30_30_3f_33_3f_00_00_00_00_00_00_18_18_7e_18_3c_66_66_66_66_3c_00_00 ),
    .INIT_07 ( 256'h00_00_00_00_18_18_db_3c_e7_3c_db_18_18_00_00_00_00_00_00_c0_e6_e7_67_63_63_63_63_7f_63_7f_00_00 ),
    .INIT_08 ( 256'h00_00_00_00_02_06_0e_1e_3e_fe_3e_1e_0e_06_02_00_00_00_00_00_80_c0_e0_f0_f8_fe_f8_f0_e0_c0_80_00 ),
    .INIT_09 ( 256'h00_00_00_00_66_66_00_66_66_66_66_66_66_66_00_00_00_00_00_00_00_18_3c_7e_18_18_18_7e_3c_18_00_00 ),
    .INIT_0A ( 256'h00_00_00_7c_c6_0c_38_6c_c6_c6_6c_38_60_c6_7c_00_00_00_00_00_1b_1b_1b_1b_1b_7b_db_db_db_7f_00_00 ),
    .INIT_0B ( 256'h00_00_00_00_7e_18_3c_7e_18_18_18_7e_3c_18_00_00_00_00_00_00_fe_fe_fe_fe_00_00_00_00_00_00_00_00 ),
    .INIT_0C ( 256'h00_00_00_00_18_3c_7e_18_18_18_18_18_18_18_00_00_00_00_00_00_18_18_18_18_18_18_18_7e_3c_18_00_00 ),
    .INIT_0D ( 256'h00_00_00_00_00_00_30_60_fe_60_30_00_00_00_00_00_00_00_00_00_00_00_18_0c_fe_0c_18_00_00_00_00_00 ),
    .INIT_0E ( 256'h00_00_00_00_00_00_28_6c_fe_6c_28_00_00_00_00_00_00_00_00_00_00_00_fe_c0_c0_c0_00_00_00_00_00_00 ),
    .INIT_0F ( 256'h00_00_00_00_00_10_38_38_7c_7c_fe_fe_00_00_00_00_00_00_00_00_00_fe_fe_7c_7c_38_38_10_00_00_00_00 ),
    .INIT_10 ( 256'h00_00_00_00_18_18_00_18_18_18_3c_3c_3c_18_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00 ),
    .INIT_11 ( 256'h00_00_00_00_6c_6c_fe_6c_6c_6c_fe_6c_6c_00_00_00_00_00_00_00_00_00_00_00_00_00_00_24_66_66_66_00 ),
    .INIT_12 ( 256'h00_00_00_00_86_c6_60_30_18_0c_c6_c2_00_00_00_00_00_00_18_18_7c_c6_86_06_06_7c_c0_c2_c6_7c_18_18 ),
    .INIT_13 ( 256'h00_00_00_00_00_00_00_00_00_00_00_60_30_30_30_00_00_00_00_00_76_cc_cc_cc_dc_76_38_6c_6c_38_00_00 ),
    .INIT_14 ( 256'h00_00_00_00_30_18_0c_0c_0c_0c_0c_0c_18_30_00_00_00_00_00_00_0c_18_30_30_30_30_30_30_18_0c_00_00 ),
    .INIT_15 ( 256'h00_00_00_00_00_00_18_18_7e_18_18_00_00_00_00_00_00_00_00_00_00_00_66_3c_ff_3c_66_00_00_00_00_00 ),
    .INIT_16 ( 256'h00_00_00_00_00_00_00_00_fe_00_00_00_00_00_00_00_00_00_00_30_18_18_18_00_00_00_00_00_00_00_00_00 ),
    .INIT_17 ( 256'h00_00_00_00_80_c0_60_30_18_0c_06_02_00_00_00_00_00_00_00_00_18_18_00_00_00_00_00_00_00_00_00_00 ),
    .INIT_18 ( 256'h00_00_00_00_7e_18_18_18_18_18_18_78_38_18_00_00_00_00_00_00_38_6c_c6_c6_d6_d6_c6_c6_6c_38_00_00 ),
    .INIT_19 ( 256'h00_00_00_00_7c_c6_06_06_06_3c_06_06_c6_7c_00_00_00_00_00_00_fe_c6_c0_60_30_18_0c_06_c6_7c_00_00 ),
    .INIT_1A ( 256'h00_00_00_00_7c_c6_06_06_06_fc_c0_c0_c0_fe_00_00_00_00_00_00_1e_0c_0c_0c_fe_cc_6c_3c_1c_0c_00_00 ),
    .INIT_1B ( 256'h00_00_00_00_30_30_30_30_18_0c_06_06_c6_fe_00_00_00_00_00_00_7c_c6_c6_c6_c6_fc_c0_c0_60_38_00_00 ),
    .INIT_1C ( 256'h00_00_00_00_78_0c_06_06_06_7e_c6_c6_c6_7c_00_00_00_00_00_00_7c_c6_c6_c6_c6_7c_c6_c6_c6_7c_00_00 ),
    .INIT_1D ( 256'h00_00_00_00_30_18_18_00_00_00_18_18_00_00_00_00_00_00_00_00_00_18_18_00_00_00_18_18_00_00_00_00 ),
    .INIT_1E ( 256'h00_00_00_00_00_00_00_7e_00_00_7e_00_00_00_00_00_00_00_00_00_06_0c_18_30_60_30_18_0c_06_00_00_00 ),
    .INIT_1F ( 256'h00_00_00_00_18_18_00_18_18_18_0c_c6_c6_7c_00_00_00_00_00_00_60_30_18_0c_06_0c_18_30_60_00_00_00 ),
    .INIT_20 ( 256'h00_00_00_00_c6_c6_c6_c6_fe_c6_c6_6c_38_10_00_00_00_00_00_00_7c_c0_dc_de_de_de_c6_c6_7c_00_00_00 ),
    .INIT_21 ( 256'h00_00_00_00_3c_66_c2_c0_c0_c0_c0_c2_66_3c_00_00_00_00_00_00_fc_66_66_66_66_7c_66_66_66_fc_00_00 ),
    .INIT_22 ( 256'h00_00_00_00_fe_66_62_60_68_78_68_62_66_fe_00_00_00_00_00_00_f8_6c_66_66_66_66_66_66_6c_f8_00_00 ),
    .INIT_23 ( 256'h00_00_00_00_3a_66_c6_c6_de_c0_c0_c2_66_3c_00_00_00_00_00_00_f0_60_60_60_68_78_68_62_66_fe_00_00 ),
    .INIT_24 ( 256'h00_00_00_00_3c_18_18_18_18_18_18_18_18_3c_00_00_00_00_00_00_c6_c6_c6_c6_c6_fe_c6_c6_c6_c6_00_00 ),
    .INIT_25 ( 256'h00_00_00_00_e6_66_66_6c_78_78_6c_66_66_e6_00_00_00_00_00_00_78_cc_cc_cc_0c_0c_0c_0c_0c_1e_00_00 ),
    .INIT_26 ( 256'h00_00_00_00_c6_c6_c6_c6_c6_d6_fe_fe_ee_c6_00_00_00_00_00_00_fe_66_62_60_60_60_60_60_60_f0_00_00 ),
    .INIT_27 ( 256'h00_00_00_00_7c_c6_c6_c6_c6_c6_c6_c6_c6_7c_00_00_00_00_00_00_c6_c6_c6_c6_ce_de_fe_f6_e6_c6_00_00 ),
    .INIT_28 ( 256'h00_00_0e_0c_7c_de_d6_c6_c6_c6_c6_c6_c6_7c_00_00_00_00_00_00_f0_60_60_60_60_7c_66_66_66_fc_00_00 ),
    .INIT_29 ( 256'h00_00_00_00_7c_c6_c6_06_0c_38_60_c6_c6_7c_00_00_00_00_00_00_e6_66_66_66_6c_7c_66_66_66_fc_00_00 ),
    .INIT_2A ( 256'h00_00_00_00_7c_c6_c6_c6_c6_c6_c6_c6_c6_c6_00_00_00_00_00_00_3c_18_18_18_18_18_18_5a_7e_7e_00_00 ),
    .INIT_2B ( 256'h00_00_00_00_6c_ee_fe_d6_d6_d6_c6_c6_c6_c6_00_00_00_00_00_00_10_38_6c_c6_c6_c6_c6_c6_c6_c6_00_00 ),
    .INIT_2C ( 256'h00_00_00_00_3c_18_18_18_18_3c_66_66_66_66_00_00_00_00_00_00_c6_c6_6c_7c_38_38_7c_6c_c6_c6_00_00 ),
    .INIT_2D ( 256'h00_00_00_00_3c_30_30_30_30_30_30_30_30_3c_00_00_00_00_00_00_fe_c6_c2_60_30_18_0c_86_c6_fe_00_00 ),
    .INIT_2E ( 256'h00_00_00_00_3c_0c_0c_0c_0c_0c_0c_0c_0c_3c_00_00_00_00_00_00_02_06_0e_1c_38_70_e0_c0_80_00_00_00 ),
    .INIT_2F ( 256'h00_00_ff_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_c6_6c_38_10 ),
    .INIT_30 ( 256'h00_00_00_00_76_cc_cc_cc_7c_0c_78_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_18_30_30 ),
    .INIT_31 ( 256'h00_00_00_00_7c_c6_c0_c0_c0_c6_7c_00_00_00_00_00_00_00_00_00_7c_66_66_66_66_6c_78_60_60_e0_00_00 ),
    .INIT_32 ( 256'h00_00_00_00_7c_c6_c0_c0_fe_c6_7c_00_00_00_00_00_00_00_00_00_76_cc_cc_cc_cc_6c_3c_0c_0c_1c_00_00 ),
    .INIT_33 ( 256'h00_78_cc_0c_7c_cc_cc_cc_cc_cc_76_00_00_00_00_00_00_00_00_00_f0_60_60_60_60_f0_60_64_6c_38_00_00 ),
    .INIT_34 ( 256'h00_00_00_00_3c_18_18_18_18_18_38_00_18_18_00_00_00_00_00_00_e6_66_66_66_66_76_6c_60_60_e0_00_00 ),
    .INIT_35 ( 256'h00_00_00_00_e6_66_6c_78_78_6c_66_60_60_e0_00_00_00_3c_66_66_06_06_06_06_06_06_0e_00_06_06_00_00 ),
    .INIT_36 ( 256'h00_00_00_00_c6_d6_d6_d6_d6_fe_ec_00_00_00_00_00_00_00_00_00_3c_18_18_18_18_18_18_18_18_38_00_00 ),
    .INIT_37 ( 256'h00_00_00_00_7c_c6_c6_c6_c6_c6_7c_00_00_00_00_00_00_00_00_00_66_66_66_66_66_66_dc_00_00_00_00_00 ),
    .INIT_38 ( 256'h00_1e_0c_0c_7c_cc_cc_cc_cc_cc_76_00_00_00_00_00_00_f0_60_60_7c_66_66_66_66_66_dc_00_00_00_00_00 ),
    .INIT_39 ( 256'h00_00_00_00_7c_c6_0c_38_60_c6_7c_00_00_00_00_00_00_00_00_00_f0_60_60_60_66_76_dc_00_00_00_00_00 ),
    .INIT_3A ( 256'h00_00_00_00_76_cc_cc_cc_cc_cc_cc_00_00_00_00_00_00_00_00_00_1c_36_30_30_30_30_fc_30_30_10_00_00 ),
    .INIT_3B ( 256'h00_00_00_00_6c_fe_d6_d6_d6_c6_c6_00_00_00_00_00_00_00_00_00_18_3c_66_66_66_66_66_00_00_00_00_00 ),
    .INIT_3C ( 256'h00_f8_0c_06_7e_c6_c6_c6_c6_c6_c6_00_00_00_00_00_00_00_00_00_c6_6c_38_38_38_6c_c6_00_00_00_00_00 ),
    .INIT_3D ( 256'h00_00_00_00_0e_18_18_18_18_70_18_18_18_0e_00_00_00_00_00_00_fe_c6_60_30_18_cc_fe_00_00_00_00_00 ),
    .INIT_3E ( 256'h00_00_00_00_70_18_18_18_18_0e_18_18_18_70_00_00_00_00_00_00_18_18_18_18_18_00_18_18_18_18_00_00 ),
    .INIT_3F ( 256'h00_00_00_00_00_fe_c6_c6_c6_6c_38_10_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_dc_76_00_00 ),
    // unused parity
    .INITP_00( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07( 256'h0000000000000000000000000000000000000000000000000000000000000000 )
   ) font16X8_inst (
    .DO     ( font_bitmap_byte ),
    .DOP    (                  ),
    .ADDR   ( font_bitmap_addr ),
    .CLK    ( clk              ),
    .DI     ( 8'h00            ),
    .DIP    ( 1'b0             ),
    .EN     ( 1'b1             ),
    .WE     ( 1'b0             ),
    .SSR    ( 1'b0             )
 );


endmodule
module ps2_host_rxtx  (
   // Clock and reset    
   input        clk,
   input        rst,
   // PS/2 interface 
   inout        ps2_clk,
   inout        ps2_data,
   // Processor interface for sending data 
   input        ps2_wr_stb,
   input [7:0]  ps2_wr_data, 
   output       ps2_tx_done,
   output       ps2_tx_ready,
   // Processor interface for receiving data 
   output       ps2_rddata_valid,
   output [7:0] ps2_rd_data, 
   output       ps2_rx_ready   
);   


   wire  ps2_clk_out, ps2_clk_in, ps2_clk_in_clean; 
   wire  ps2_data_out_en,  ps2_data_out, ps2_data_in, ps2_data_in_clean; 
   wire  ps2_rx_en;

   assign   ps2_clk     = ps2_clk_out ? 1'bz :  1'b0 ;  
   assign   ps2_clk_in  = ps2_clk ; 

   assign   ps2_data     = ps2_data_out_en ? ps2_data_out  :  1'bz ;  
   assign   ps2_data_in  = ps2_data; 

   assign   ps2_rx_en    = ps2_tx_ready; 
`ifdef SIM
   assign ps2_clk_in_clean = ps2_clk_in ; 
   assign ps2_data_in_clean = ps2_data_in ; 
`else
   io_filter  #(.PIN_NUM (2 ) ) io_filter_inst (
         .clk     (  clk   ),
         .pin_in  ( { ps2_clk_in,      ps2_data_in} ),
         .pin_out ( { ps2_clk_in_clean,ps2_data_in_clean } ) 
   );
`endif

/*
`ifdef 0
   assign       ps2_tx_done = 1'b0;
   assign       ps2_tx_ready = 1'b0 ;
   assign       ps2_rddata_valid = 1'b0 ;
   assign       ps2_rd_data = 8'h00;
   assign       wireps2_rx_ready  = 1'b0 ;
`else
*/


//   ps2_host_tx #(.NUM_OF_BITS_FOR_100US (9 ) )  ps2_host_tx_inst (
   ps2_host_tx #(.NUM_OF_BITS_FOR_100US ( 13 ) )  ps2_host_tx_inst (
      .clk          ( clk           ),
      .rst          ( rst           ),
      .ps2_clk_in   ( ps2_clk_in_clean    ),
      .ps2_data_in  ( ps2_data_in_clean   ),
      .ps2_wr_stb   ( ps2_wr_stb    ),
      .ps2_wr_data  ( ps2_wr_data   ), 
      .ps2_clk_out  ( ps2_clk_out   ),
      .ps2_data_out_en ( ps2_data_out_en ),
      .ps2_data_out ( ps2_data_out   ),
      .ps2_tx_done  ( ps2_tx_done   ), 
      .ps2_tx_ready ( ps2_tx_ready  )    
   );
   
   ps2_host_rx ps2_host_rx_inst (
      .clk          ( clk           ),
      .rst          ( rst           ),
      .ps2_clk_in   ( ps2_clk_in_clean    ),
      .ps2_data_in  ( ps2_data_in_clean   ),
      .ps2_rx_en    ( ps2_rx_en     ),
      .ps2_rddata_valid ( ps2_rddata_valid ),
      .ps2_rd_data  ( ps2_rd_data   ), 
      .ps2_rx_ready ( ps2_rx_ready  )    
   );

//`endif
endmodule    

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
wire  ps2_go ;

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
         default : delay_cntr <= 'bx ;
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
         default :   data_out <= 'bx ;
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
