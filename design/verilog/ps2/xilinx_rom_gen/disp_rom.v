parameter INVALID_CMD = 0 ;
parameter RESET_CMD = 1 ;
parameter SET_REMOTE_MODE = 2 ;
parameter GET_DEVICE_ID = 3 ;
parameter SET_SAMPLE_RATE = 4 ;
parameter ENABLE_DATA_REP = 5 ;
parameter DISAB_DATA_REP = 6 ;
parameter SET_DEFAULT = 7 ;
parameter STATUS_REQ = 8 ;
parameter SET_STREAM_MODE = 9 ;
parameter ACK = 10 ;
parameter INVALID_ACK = 11 ;
parameter DEVICE_ID = 12 ;
parameter TEST_PASS = 13 ;
parameter BYTE_1 = 14 ;
parameter BYTE_2 = 15 ;
parameter BYTE_3 = 16 ;

parameter MAX_SEL_NUM = 17 ;

always @( comment_sel or comment_data_temp[0]or comment_data_temp[1]or comment_data_temp[2]or comment_data_temp[3]or comment_data_temp[4]or comment_data_temp[5]or comment_data_temp[6]or comment_data_temp[7]or comment_data_temp[8]or comment_data_temp[9]or comment_data_temp[10]or comment_data_temp[11]or comment_data_temp[12]or comment_data_temp[13]or comment_data_temp[14]or comment_data_temp[15]or comment_data_temp[16]) begin
    comment_data_out = 8'h00;
    for ( i = 0 ; i < MAX_SEL_NUM ; i = i + 1 ) begin
       case ( 1'b1 )
          comment_sel[i] : begin
             comment_data_out = comment_data_temp[i] | comment_data_out;
          end
          default : comment_data_out = comment_data_out; 
       endcase
    end
end
// ROM for "X:-xx "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ BYTE_2 ] = 8'h58 ;//X
       1 : comment_data_temp[ BYTE_2 ] = 8'h3a ;//:
       2 : comment_data_temp[ BYTE_2 ] = 8'h2d ;//-
       3 : comment_data_temp[ BYTE_2 ] = 8'h78 ;//x
       4 : comment_data_temp[ BYTE_2 ] = 8'h78 ;//x
      default : comment_data_temp[ BYTE_2 ] = 8'h0a; //CR
   endcase
end

// ROM for "y:-yy "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ BYTE_3 ] = 8'h79 ;//y
       1 : comment_data_temp[ BYTE_3 ] = 8'h3a ;//:
       2 : comment_data_temp[ BYTE_3 ] = 8'h2d ;//-
       3 : comment_data_temp[ BYTE_3 ] = 8'h79 ;//y
       4 : comment_data_temp[ BYTE_3 ] = 8'h79 ;//y
      default : comment_data_temp[ BYTE_3 ] = 8'h0a; //CR
   endcase
end

// ROM for "Invalid ACK "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ INVALID_ACK ] = 8'h49 ;//I
       1 : comment_data_temp[ INVALID_ACK ] = 8'h6e ;//n
       2 : comment_data_temp[ INVALID_ACK ] = 8'h76 ;//v
       3 : comment_data_temp[ INVALID_ACK ] = 8'h61 ;//a
       4 : comment_data_temp[ INVALID_ACK ] = 8'h6c ;//l
       5 : comment_data_temp[ INVALID_ACK ] = 8'h69 ;//i
       6 : comment_data_temp[ INVALID_ACK ] = 8'h64 ;//d
       7 : comment_data_temp[ INVALID_ACK ] = 8'h20 ;// 
       8 : comment_data_temp[ INVALID_ACK ] = 8'h41 ;//A
       9 : comment_data_temp[ INVALID_ACK ] = 8'h43 ;//C
      10 : comment_data_temp[ INVALID_ACK ] = 8'h4b ;//K
      default : comment_data_temp[ INVALID_ACK ] = 8'h0a; //CR
   endcase
end

// ROM for "Self-test passed "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ TEST_PASS ] = 8'h53 ;//S
       1 : comment_data_temp[ TEST_PASS ] = 8'h65 ;//e
       2 : comment_data_temp[ TEST_PASS ] = 8'h6c ;//l
       3 : comment_data_temp[ TEST_PASS ] = 8'h66 ;//f
       4 : comment_data_temp[ TEST_PASS ] = 8'h2d ;//-
       5 : comment_data_temp[ TEST_PASS ] = 8'h74 ;//t
       6 : comment_data_temp[ TEST_PASS ] = 8'h65 ;//e
       7 : comment_data_temp[ TEST_PASS ] = 8'h73 ;//s
       8 : comment_data_temp[ TEST_PASS ] = 8'h74 ;//t
       9 : comment_data_temp[ TEST_PASS ] = 8'h20 ;// 
      10 : comment_data_temp[ TEST_PASS ] = 8'h70 ;//p
      11 : comment_data_temp[ TEST_PASS ] = 8'h61 ;//a
      12 : comment_data_temp[ TEST_PASS ] = 8'h73 ;//s
      13 : comment_data_temp[ TEST_PASS ] = 8'h73 ;//s
      14 : comment_data_temp[ TEST_PASS ] = 8'h65 ;//e
      15 : comment_data_temp[ TEST_PASS ] = 8'h64 ;//d
      default : comment_data_temp[ TEST_PASS ] = 8'h0a; //CR
   endcase
end

// ROM for "Set Remote Mode "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h53 ;//S
       1 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h65 ;//e
       2 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h74 ;//t
       3 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h20 ;// 
       4 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h52 ;//R
       5 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h65 ;//e
       6 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h6d ;//m
       7 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h6f ;//o
       8 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h74 ;//t
       9 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h65 ;//e
      10 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h20 ;// 
      11 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h4d ;//M
      12 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h6f ;//o
      13 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h64 ;//d
      14 : comment_data_temp[ SET_REMOTE_MODE ] = 8'h65 ;//e
      default : comment_data_temp[ SET_REMOTE_MODE ] = 8'h0a; //CR
   endcase
end

// ROM for "Set Stream Mode "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ SET_STREAM_MODE ] = 8'h53 ;//S
       1 : comment_data_temp[ SET_STREAM_MODE ] = 8'h65 ;//e
       2 : comment_data_temp[ SET_STREAM_MODE ] = 8'h74 ;//t
       3 : comment_data_temp[ SET_STREAM_MODE ] = 8'h20 ;// 
       4 : comment_data_temp[ SET_STREAM_MODE ] = 8'h53 ;//S
       5 : comment_data_temp[ SET_STREAM_MODE ] = 8'h74 ;//t
       6 : comment_data_temp[ SET_STREAM_MODE ] = 8'h72 ;//r
       7 : comment_data_temp[ SET_STREAM_MODE ] = 8'h65 ;//e
       8 : comment_data_temp[ SET_STREAM_MODE ] = 8'h61 ;//a
       9 : comment_data_temp[ SET_STREAM_MODE ] = 8'h6d ;//m
      10 : comment_data_temp[ SET_STREAM_MODE ] = 8'h20 ;// 
      11 : comment_data_temp[ SET_STREAM_MODE ] = 8'h4d ;//M
      12 : comment_data_temp[ SET_STREAM_MODE ] = 8'h6f ;//o
      13 : comment_data_temp[ SET_STREAM_MODE ] = 8'h64 ;//d
      14 : comment_data_temp[ SET_STREAM_MODE ] = 8'h65 ;//e
      default : comment_data_temp[ SET_STREAM_MODE ] = 8'h0a; //CR
   endcase
end

// ROM for "Invlaid command "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ INVALID_CMD ] = 8'h49 ;//I
       1 : comment_data_temp[ INVALID_CMD ] = 8'h6e ;//n
       2 : comment_data_temp[ INVALID_CMD ] = 8'h76 ;//v
       3 : comment_data_temp[ INVALID_CMD ] = 8'h6c ;//l
       4 : comment_data_temp[ INVALID_CMD ] = 8'h61 ;//a
       5 : comment_data_temp[ INVALID_CMD ] = 8'h69 ;//i
       6 : comment_data_temp[ INVALID_CMD ] = 8'h64 ;//d
       7 : comment_data_temp[ INVALID_CMD ] = 8'h20 ;// 
       8 : comment_data_temp[ INVALID_CMD ] = 8'h63 ;//c
       9 : comment_data_temp[ INVALID_CMD ] = 8'h6f ;//o
      10 : comment_data_temp[ INVALID_CMD ] = 8'h6d ;//m
      11 : comment_data_temp[ INVALID_CMD ] = 8'h6d ;//m
      12 : comment_data_temp[ INVALID_CMD ] = 8'h61 ;//a
      13 : comment_data_temp[ INVALID_CMD ] = 8'h6e ;//n
      14 : comment_data_temp[ INVALID_CMD ] = 8'h64 ;//d
      default : comment_data_temp[ INVALID_CMD ] = 8'h0a; //CR
   endcase
end

// ROM for "Status Request "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ STATUS_REQ ] = 8'h53 ;//S
       1 : comment_data_temp[ STATUS_REQ ] = 8'h74 ;//t
       2 : comment_data_temp[ STATUS_REQ ] = 8'h61 ;//a
       3 : comment_data_temp[ STATUS_REQ ] = 8'h74 ;//t
       4 : comment_data_temp[ STATUS_REQ ] = 8'h75 ;//u
       5 : comment_data_temp[ STATUS_REQ ] = 8'h73 ;//s
       6 : comment_data_temp[ STATUS_REQ ] = 8'h20 ;// 
       7 : comment_data_temp[ STATUS_REQ ] = 8'h52 ;//R
       8 : comment_data_temp[ STATUS_REQ ] = 8'h65 ;//e
       9 : comment_data_temp[ STATUS_REQ ] = 8'h71 ;//q
      10 : comment_data_temp[ STATUS_REQ ] = 8'h75 ;//u
      11 : comment_data_temp[ STATUS_REQ ] = 8'h65 ;//e
      12 : comment_data_temp[ STATUS_REQ ] = 8'h73 ;//s
      13 : comment_data_temp[ STATUS_REQ ] = 8'h74 ;//t
      default : comment_data_temp[ STATUS_REQ ] = 8'h0a; //CR
   endcase
end

// ROM for "Set Sample Rate "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h53 ;//S
       1 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h65 ;//e
       2 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h74 ;//t
       3 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h20 ;// 
       4 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h53 ;//S
       5 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h61 ;//a
       6 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h6d ;//m
       7 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h70 ;//p
       8 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h6c ;//l
       9 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h65 ;//e
      10 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h20 ;// 
      11 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h52 ;//R
      12 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h61 ;//a
      13 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h74 ;//t
      14 : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h65 ;//e
      default : comment_data_temp[ SET_SAMPLE_RATE ] = 8'h0a; //CR
   endcase
end

// ROM for "M-0,R-0,L-0 "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ BYTE_1 ] = 8'h4d ;//M
       1 : comment_data_temp[ BYTE_1 ] = 8'h2d ;//-
       2 : comment_data_temp[ BYTE_1 ] = 8'h30 ;//0
       3 : comment_data_temp[ BYTE_1 ] = 8'h2c ;//,
       4 : comment_data_temp[ BYTE_1 ] = 8'h52 ;//R
       5 : comment_data_temp[ BYTE_1 ] = 8'h2d ;//-
       6 : comment_data_temp[ BYTE_1 ] = 8'h30 ;//0
       7 : comment_data_temp[ BYTE_1 ] = 8'h2c ;//,
       8 : comment_data_temp[ BYTE_1 ] = 8'h4c ;//L
       9 : comment_data_temp[ BYTE_1 ] = 8'h2d ;//-
      10 : comment_data_temp[ BYTE_1 ] = 8'h30 ;//0
      default : comment_data_temp[ BYTE_1 ] = 8'h0a; //CR
   endcase
end

// ROM for "Enable Data Reporting "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h45 ;//E
       1 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h6e ;//n
       2 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h61 ;//a
       3 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h62 ;//b
       4 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h6c ;//l
       5 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h65 ;//e
       6 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h20 ;// 
       7 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h44 ;//D
       8 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h61 ;//a
       9 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h74 ;//t
      10 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h61 ;//a
      11 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h20 ;// 
      12 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h52 ;//R
      13 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h65 ;//e
      14 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h70 ;//p
      15 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h6f ;//o
      16 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h72 ;//r
      17 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h74 ;//t
      18 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h69 ;//i
      19 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h6e ;//n
      20 : comment_data_temp[ ENABLE_DATA_REP ] = 8'h67 ;//g
      default : comment_data_temp[ ENABLE_DATA_REP ] = 8'h0a; //CR
   endcase
end

// ROM for "Set Defaults "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ SET_DEFAULT ] = 8'h53 ;//S
       1 : comment_data_temp[ SET_DEFAULT ] = 8'h65 ;//e
       2 : comment_data_temp[ SET_DEFAULT ] = 8'h74 ;//t
       3 : comment_data_temp[ SET_DEFAULT ] = 8'h20 ;// 
       4 : comment_data_temp[ SET_DEFAULT ] = 8'h44 ;//D
       5 : comment_data_temp[ SET_DEFAULT ] = 8'h65 ;//e
       6 : comment_data_temp[ SET_DEFAULT ] = 8'h66 ;//f
       7 : comment_data_temp[ SET_DEFAULT ] = 8'h61 ;//a
       8 : comment_data_temp[ SET_DEFAULT ] = 8'h75 ;//u
       9 : comment_data_temp[ SET_DEFAULT ] = 8'h6c ;//l
      10 : comment_data_temp[ SET_DEFAULT ] = 8'h74 ;//t
      11 : comment_data_temp[ SET_DEFAULT ] = 8'h73 ;//s
      default : comment_data_temp[ SET_DEFAULT ] = 8'h0a; //CR
   endcase
end

// ROM for "Devce ID "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ DEVICE_ID ] = 8'h44 ;//D
       1 : comment_data_temp[ DEVICE_ID ] = 8'h65 ;//e
       2 : comment_data_temp[ DEVICE_ID ] = 8'h76 ;//v
       3 : comment_data_temp[ DEVICE_ID ] = 8'h63 ;//c
       4 : comment_data_temp[ DEVICE_ID ] = 8'h65 ;//e
       5 : comment_data_temp[ DEVICE_ID ] = 8'h20 ;// 
       6 : comment_data_temp[ DEVICE_ID ] = 8'h49 ;//I
       7 : comment_data_temp[ DEVICE_ID ] = 8'h44 ;//D
      default : comment_data_temp[ DEVICE_ID ] = 8'h0a; //CR
   endcase
end

// ROM for "Acknowledgment "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ ACK ] = 8'h41 ;//A
       1 : comment_data_temp[ ACK ] = 8'h63 ;//c
       2 : comment_data_temp[ ACK ] = 8'h6b ;//k
       3 : comment_data_temp[ ACK ] = 8'h6e ;//n
       4 : comment_data_temp[ ACK ] = 8'h6f ;//o
       5 : comment_data_temp[ ACK ] = 8'h77 ;//w
       6 : comment_data_temp[ ACK ] = 8'h6c ;//l
       7 : comment_data_temp[ ACK ] = 8'h65 ;//e
       8 : comment_data_temp[ ACK ] = 8'h64 ;//d
       9 : comment_data_temp[ ACK ] = 8'h67 ;//g
      10 : comment_data_temp[ ACK ] = 8'h6d ;//m
      11 : comment_data_temp[ ACK ] = 8'h65 ;//e
      12 : comment_data_temp[ ACK ] = 8'h6e ;//n
      13 : comment_data_temp[ ACK ] = 8'h74 ;//t
      default : comment_data_temp[ ACK ] = 8'h0a; //CR
   endcase
end

// ROM for "Get Deivce ID "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ GET_DEVICE_ID ] = 8'h47 ;//G
       1 : comment_data_temp[ GET_DEVICE_ID ] = 8'h65 ;//e
       2 : comment_data_temp[ GET_DEVICE_ID ] = 8'h74 ;//t
       3 : comment_data_temp[ GET_DEVICE_ID ] = 8'h20 ;// 
       4 : comment_data_temp[ GET_DEVICE_ID ] = 8'h44 ;//D
       5 : comment_data_temp[ GET_DEVICE_ID ] = 8'h65 ;//e
       6 : comment_data_temp[ GET_DEVICE_ID ] = 8'h69 ;//i
       7 : comment_data_temp[ GET_DEVICE_ID ] = 8'h76 ;//v
       8 : comment_data_temp[ GET_DEVICE_ID ] = 8'h63 ;//c
       9 : comment_data_temp[ GET_DEVICE_ID ] = 8'h65 ;//e
      10 : comment_data_temp[ GET_DEVICE_ID ] = 8'h20 ;// 
      11 : comment_data_temp[ GET_DEVICE_ID ] = 8'h49 ;//I
      12 : comment_data_temp[ GET_DEVICE_ID ] = 8'h44 ;//D
      default : comment_data_temp[ GET_DEVICE_ID ] = 8'h0a; //CR
   endcase
end

// ROM for "Disable Data Reporting "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ DISAB_DATA_REP ] = 8'h44 ;//D
       1 : comment_data_temp[ DISAB_DATA_REP ] = 8'h69 ;//i
       2 : comment_data_temp[ DISAB_DATA_REP ] = 8'h73 ;//s
       3 : comment_data_temp[ DISAB_DATA_REP ] = 8'h61 ;//a
       4 : comment_data_temp[ DISAB_DATA_REP ] = 8'h62 ;//b
       5 : comment_data_temp[ DISAB_DATA_REP ] = 8'h6c ;//l
       6 : comment_data_temp[ DISAB_DATA_REP ] = 8'h65 ;//e
       7 : comment_data_temp[ DISAB_DATA_REP ] = 8'h20 ;// 
       8 : comment_data_temp[ DISAB_DATA_REP ] = 8'h44 ;//D
       9 : comment_data_temp[ DISAB_DATA_REP ] = 8'h61 ;//a
      10 : comment_data_temp[ DISAB_DATA_REP ] = 8'h74 ;//t
      11 : comment_data_temp[ DISAB_DATA_REP ] = 8'h61 ;//a
      12 : comment_data_temp[ DISAB_DATA_REP ] = 8'h20 ;// 
      13 : comment_data_temp[ DISAB_DATA_REP ] = 8'h52 ;//R
      14 : comment_data_temp[ DISAB_DATA_REP ] = 8'h65 ;//e
      15 : comment_data_temp[ DISAB_DATA_REP ] = 8'h70 ;//p
      16 : comment_data_temp[ DISAB_DATA_REP ] = 8'h6f ;//o
      17 : comment_data_temp[ DISAB_DATA_REP ] = 8'h72 ;//r
      18 : comment_data_temp[ DISAB_DATA_REP ] = 8'h74 ;//t
      19 : comment_data_temp[ DISAB_DATA_REP ] = 8'h69 ;//i
      20 : comment_data_temp[ DISAB_DATA_REP ] = 8'h6e ;//n
      21 : comment_data_temp[ DISAB_DATA_REP ] = 8'h67 ;//g
      default : comment_data_temp[ DISAB_DATA_REP ] = 8'h0a; //CR
   endcase
end

// ROM for "Reset command "
always @(*) begin
   case ( char_idx ) 
       0 : comment_data_temp[ RESET_CMD ] = 8'h52 ;//R
       1 : comment_data_temp[ RESET_CMD ] = 8'h65 ;//e
       2 : comment_data_temp[ RESET_CMD ] = 8'h73 ;//s
       3 : comment_data_temp[ RESET_CMD ] = 8'h65 ;//e
       4 : comment_data_temp[ RESET_CMD ] = 8'h74 ;//t
       5 : comment_data_temp[ RESET_CMD ] = 8'h20 ;// 
       6 : comment_data_temp[ RESET_CMD ] = 8'h63 ;//c
       7 : comment_data_temp[ RESET_CMD ] = 8'h6f ;//o
       8 : comment_data_temp[ RESET_CMD ] = 8'h6d ;//m
       9 : comment_data_temp[ RESET_CMD ] = 8'h6d ;//m
      10 : comment_data_temp[ RESET_CMD ] = 8'h61 ;//a
      11 : comment_data_temp[ RESET_CMD ] = 8'h6e ;//n
      12 : comment_data_temp[ RESET_CMD ] = 8'h64 ;//d
      default : comment_data_temp[ RESET_CMD ] = 8'h0a; //CR
   endcase
end

