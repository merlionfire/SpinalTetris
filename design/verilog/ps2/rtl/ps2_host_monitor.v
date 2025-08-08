`include "ps2_define.vh" 

module ps2_host_monitor
(
   // clock and reset  
   input    clk,
   input    rst,
   // PS/2 rxtx interface 
   output       ps2_wr_stb,
   output [7:0] ps2_wr_data,
   input        ps2_rddata_valid,
   input  [7:0] ps2_rd_data,
   // UART interface 
   input        uart_tx_full,
   input        uart_tx_almost_full,
   output reg   uart_wr_en,
   output [7:0] uart_wr_data,
   input        uart_rx_empty,  
   output       uart_rd_en, 
   input        uart_rddata_valid,
   input  [7:0] uart_rd_data,
   // cm interface 
   input        cmd_rd_en,
   input        host_data_xfr,
   input        device_data_xfr,
   input        comment_data_xfr,
   input        data_xfr_int,  
   input [ `MAX_SEL_NUM - 1 : 0  ]  comment_sel, 
   input        data_is_byte_1,
   input        data_is_byte_2,
   input        data_is_byte_3,
   output       ps2_wr_req,
   output       char_idx_end,
   output       host_data_start,
   output       device_data_start,
   output       uart_is_ready
);

`include "ps2_pkg.vh" 

localparam HOST_DEVICE_DISP_CHARS_NUM  =  4'd11 ; 

reg  [7:0]  host_data_out, device_data_out ; 
wire [7:0]  comment_data_out ; 
reg  [7:0]  data_latch, mouse_mov, data_in;  
reg  [7:0]  ascii_code, byte_h_ascii, byte_l_ascii;  
reg         y_ov, x_ov, x_sig, y_sig, m_btn, r_btn, l_btn ;   
reg         data_start, byte_high_en, byte_low_en ; 
reg         host_data_xfr_1d, device_data_xfr_1d; 
wire [3:0]  hex_in;
reg  [4:0]  char_idx, char_idx_nxt, char_idx_clone  ;  
reg         comment_data_xfr_1d; 
wire        comment_data_start;  
wire        char_idx_eq_max_nxt, comment_data_eq_cr ; 
reg         char_idx_eq_max ; 

//synthesis attribute equivalent_register_removal of char_idx_clone is "false" 
//synthesis attribute equivalent_register_removal of char_idx is "false" 
 
// rom storing comments 
disp_rom  disp_rom_inst (   
   .clk               ( clk         ),
   .rst               ( rst         ),
   .comment_sel       ( comment_sel ), 
   .char_idx          ( char_idx    ), 
   .byte_l_ascii      ( byte_l_ascii),
   .byte_h_ascii      ( byte_h_ascii),
   .x_sig             ( x_sig       ),
   .y_sig             ( y_sig       ),
   .m_btn             ( m_btn       ),
   .r_btn             ( r_btn       ),
   .l_btn             ( l_btn       ),
   .comment_data_out  ( comment_data_out )     
); 



/*------- data path: uart <==> monitor <==> ps2_rxtx -----------*/ 
// datapath : uart -> DP -> PS2 rxtx  
assign  ps2_wr_req = ~ uart_rx_empty ; 
assign  uart_rd_en  =  cmd_rd_en; 
assign  ps2_wr_stb  =  uart_rddata_valid; 
assign  ps2_wr_data =  uart_rd_data;  
assign  uart_is_ready = ~ ( uart_tx_full | uart_tx_almost_full ) ; 

// datapath : uart <- DP <- PS2 rxtx  
//assign   uart_wr_en    = data_xfr_int & ( ~ comment_data_start ) ; 

always @( posedge clk ) begin 
    host_data_xfr_1d      <= host_data_xfr; 
    device_data_xfr_1d    <= device_data_xfr; 
end 
/*
assign   uart_wr_data  = ( host_data_xfr_1d   == 1'b1 ) ?   host_data_out   : 
                         ( device_data_xfr_1d == 1'b1 ) ?   device_data_out : comment_data_out ; 
*/

assign   uart_wr_data  = {8{host_data_xfr_1d}}    &  host_data_out |  
                        {8{device_data_xfr_1d}}  &  device_data_out |
                        {8{comment_data_xfr_1d}} &  comment_data_out ; 
                     
always @( posedge clk  ) begin  
      uart_wr_en    <= data_xfr_int  ; 
end
   
/*------- display data into/from ps2 controller with comments through uart interface ----------*/  
// dipslay Host  :<cmd>
always @( posedge clk  ) begin  
   if ( rst == 1'b1 ) begin 
      host_data_out  <= 8'h00 ; 
   end else begin    
      case ( char_idx_clone[3:0] ) // synthesis parallel_case  
           4'h0  :  host_data_out  <= 8'h48;   // H
           4'h1  :  host_data_out  <= 8'h6F;   // o
           4'h2  :  host_data_out  <= 8'h73;   // s
           4'h3  :  host_data_out  <= 8'h74;   // t
           4'h4  :  host_data_out  <= 8'h20;   // space 
           4'h5  :  host_data_out  <= 8'h20;   // space 
           4'h6  :  host_data_out  <= 8'h3a;   // : 
           4'h7  :  host_data_out  <= byte_h_ascii ;   //  
           4'h8  :  host_data_out  <= byte_l_ascii ;   //  
           4'h9  :  host_data_out  <= 8'h20;   // space
           4'ha  :  host_data_out  <= 8'h20;   // space 
           default  :  host_data_out  <= 8'hxx;    
       endcase
   end
end 

// dipsplay Device: 
always @( posedge clk  ) begin  
   if ( rst == 1'b1 ) begin 
      device_data_out  <= 8'h00 ; 
   end else begin    
      case ( char_idx_clone[3:0] ) // synthesis parallel_case   
           4'h0  :  device_data_out  <= 8'h44;   // D
           4'h1  :  device_data_out  <= 8'h65;   // e
           4'h2  :  device_data_out  <= 8'h76;   // v
           4'h3  :  device_data_out  <= 8'h69;   // i
           4'h4  :  device_data_out  <= 8'h63;   // c 
           4'h5  :  device_data_out  <= 8'h65;   // e  
           4'h6  :  device_data_out  <= 8'h3a;   // :  
           4'h7  :  device_data_out  <= byte_h_ascii ;   // 
           4'h8  :  device_data_out  <= byte_l_ascii ;   // 
           4'h9  :  device_data_out  <= 8'h20;   // space
           4'ha  :  device_data_out  <= 8'h20;   // space 
           default  :  device_data_out  <= 8'hxx;    
       endcase
    end
end
// pointer to the char of string for display
 
always @( posedge clk ) begin  
   if ( rst == 1'b1 ) begin 
      char_idx <= 'b0 ; 
      char_idx_clone  <= 'b0; 
      char_idx_eq_max <= 1'b0 ; 
   end else begin   
      char_idx        <= char_idx_nxt ; 
      char_idx_clone  <= char_idx_nxt ; 
      char_idx_eq_max <= char_idx_eq_max_nxt ; 
   end
end

always @(*) begin 
   if ( char_idx_end == 1'b1 ) begin 
       char_idx_nxt = 'b0 ;
   end else if ( data_xfr_int == 1'b1 ) begin 
       char_idx_nxt = char_idx_clone + 1'b1 ; 
   end else begin 
       char_idx_nxt = char_idx_clone ; 
   end
end 

assign  char_idx_eq_max_nxt = ( char_idx_nxt == ( HOST_DEVICE_DISP_CHARS_NUM - 1 ) ) ; 
assign  comment_data_eq_cr  = ( uart_wr_data == 8'h0a ) ; 

assign  host_data_start   =  uart_rddata_valid; 
assign  device_data_start =  ps2_rddata_valid ; 


assign  char_idx_end = ( ( host_data_xfr | device_data_xfr ) & char_idx_eq_max & uart_is_ready ) | 
                       ( comment_data_xfr & comment_data_eq_cr & ( uart_is_ready | uart_wr_en ) ) ;   


always @( posedge clk ) begin 
  if ( rst == 1'b1 ) begin 
     comment_data_xfr_1d <= 1'b0 ; 
  end else begin 
     comment_data_xfr_1d <= comment_data_xfr ; 
  end 
end  



assign comment_data_start = comment_data_xfr & ( ~comment_data_xfr_1d ) ;   

// convert 8-bits hex to 2 ascii.
// Data are sampled on interface to PS2 controller.  
always @( posedge clk ) begin 
    if ( rst == 1'b1 ) begin 
        data_latch  <=  8'h00 ; 
    end else begin 
        if ( ps2_wr_stb == 1'b1 ) begin 
            data_latch <=  ps2_wr_data ; 
        end else if  ( ps2_rddata_valid == 1'b1 ) begin 
            data_latch <=  ps2_rd_data ; 
        end    
    end
end    

always @( posedge clk ) begin 
    if ( rst == 1'b1 ) begin 
        y_ov    <=  1'b0 ; 
        x_ov    <=  1'b0 ;
        x_sig   <=  1'b0 ;
        y_sig   <=  1'b0 ; 
        m_btn   <=  1'b0 ;  
        r_btn   <=  1'b0 ;  
        l_btn   <=  1'b0 ;  
        mouse_mov   <=  8'h00 ; 
    end else if ( data_is_byte_1 == 1'b1 ) begin 
        { y_ov, x_ov, y_sig, x_sig, m_btn, r_btn, l_btn } <= { data_latch[7:4], data_latch[2:0] } ; 
    end else if ( data_is_byte_2 == 1'b1 || data_is_byte_3 == 1'b1  ) begin 
        mouse_mov <= ( data_is_byte_2 ? x_sig : y_sig ) ? ( ~ data_latch + 1'b1 ) : data_latch ;     
    end 
end 


always @( * ) begin 
    if ( comment_data_xfr & ( comment_sel[ BYTE_2 ] | comment_sel[ BYTE_3] ) ) begin   
        data_in = mouse_mov  ;
    end else begin 
        data_in = data_latch ;
    end   
end 


always @( posedge clk ) begin 
    if ( rst == 1'b1 ) begin 
        data_start   <= 1'b0  ;   
        byte_high_en <= 1'b0  ;      
        byte_low_en  <= 1'b0  ;    
    end else begin 
         
        data_start   <= ( host_data_start | device_data_start | comment_data_start )  ;      
        byte_high_en <= data_start ;  
        byte_low_en  <= byte_high_en ;    
    end 
end 


assign hex_in = ( byte_high_en == 1'b1 ) ? data_in[7:4] : 
                ( byte_low_en  == 1'b1 ) ? data_in[3:0] : 4'hx ;   


// byte to ascii 
always @(*) begin 
   case ( hex_in )  
      4'h0: ascii_code  =  8'h30;
      4'h1: ascii_code  =  8'h31;
      4'h2: ascii_code  =  8'h32;
      4'h3: ascii_code  =  8'h33;
      4'h4: ascii_code  =  8'h34;
      4'h5: ascii_code  =  8'h35;
      4'h6: ascii_code  =  8'h36;
      4'h7: ascii_code  =  8'h37;
      4'h8: ascii_code  =  8'h38;
      4'h9: ascii_code  =  8'h39;
      4'hA: ascii_code  =  8'h41;
      4'hB: ascii_code  =  8'h42;
      4'hC: ascii_code  =  8'h43;
      4'hD: ascii_code  =  8'h44;
      4'hE: ascii_code  =  8'h45;
      4'hF: ascii_code  =  8'h46;
      default :  ascii_code  =  8'h5x; //X
   endcase 
end 

always @( posedge clk ) begin 
    if ( rst == 1'b1 ) begin 
        byte_h_ascii <= 8'h00 ;   
        byte_l_ascii <= 8'h00 ; 
    end else begin 
        if ( byte_high_en == 1'b1 ) begin 
            byte_h_ascii <= ascii_code ;   
        end else if ( byte_low_en == 1'b1 ) begin 
            byte_l_ascii <= ascii_code ; 
        end      
    end    
end 

`ifdef SVA 

   assert property ( @( posedge clk ) 
        ( $rose( ps2_wr_stb ) || $rose( ps2_rddata_valid) ) |-> ##[1:3] $rose(byte_high_en) ##1  $rose(byte_low_en) && $fell(byte_high_en) ##1 $fell(byte_low_en)  
   ) ;       

   
   // Once ps2 host controller sends /recieves data, must send uart display
   // content within the limited clock cycles. 
   assert property ( @( posedge clk ) 
        ( $rose( ps2_wr_stb ) || $rose( ps2_rddata_valid) )  |-> ##[1:30] $rose(uart_wr_en )  
   ) ;

`endif



endmodule 
