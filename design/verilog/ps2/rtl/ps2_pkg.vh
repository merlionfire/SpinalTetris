
localparam INVALID_CMD = 0 ;
localparam RESET_CMD = 1 ;
localparam SET_REMOTE_MODE = 2 ;
localparam GET_DEVICE_ID = 3 ;
localparam SET_SAMPLE_RATE = 4 ;
localparam ENABLE_DATA_REP = 5 ;
localparam DISAB_DATA_REP = 6 ;
localparam SET_DEFAULT = 7 ;
localparam STATUS_REQ = 8 ;
localparam SET_STREAM_MODE = 9 ;
localparam ACK = 10 ;
localparam INVALID_ACK = 11 ;
localparam DEVICE_ID = 12 ;
localparam TEST_PASS = 13 ;
localparam BYTE_1 = 14 ;
localparam BYTE_2 = 15 ;
localparam BYTE_3 = 16 ;


localparam  PS2_CMD_RESET_CMD       = 8'hFF,
            PS2_CMD_SET_REMOTE_MODE = 8'hF0,
            PS2_CMD_GET_DEVICE_ID   = 8'hF2,
            PS2_CMD_SET_SAMPLE_RATE = 8'hF3,
            PS2_CMD_ENABLE_DATA_REP = 8'hF4,
            PS2_CMD_DISAB_DATA_REP  = 8'hF5, 
            PS2_CMD_SET_DEFAULT     = 8'hF6,
            PS2_CMD_STATUS_REQ      = 8'hF9,
            PS2_CMD_SET_STREAM_MODE = 8'hEA,
            PS2_RD_ACK  =   8'hFA , 
            PS2_RD_PASS =   8'hAA ; 
