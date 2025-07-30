// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : sprite
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module sprite (
  input  wire [9:0]    x,
  input  wire [8:0]    y,
  input  wire          sol,
  input  wire [9:0]    sx_orig,
  input  wire [8:0]    sy_orig,
  output wire          pix_valid,
  output wire [3:0]    pix_payload,
  input  wire          clk,
  input  wire          reset
);
  localparam IDLE = 3'd0;
  localparam LINE_START = 3'd1;
  localparam WAIT_POS = 3'd2;
  localparam LINE_DRAW = 3'd3;
  localparam LINE_END = 3'd4;

  reg        [3:0]    rom_spinal_port0;
  wire       [9:0]    temp_y_diff;
  wire       [9:0]    temp_y_diff_1;
  wire       [1:0]    temp_scale_cnt_valueNext;
  wire       [0:0]    temp_scale_cnt_valueNext_1;
  wire       [4:0]    temp_x_cnt_valueNext;
  wire       [0:0]    temp_x_cnt_valueNext_1;
  wire                temp_rom_port;
  wire                temp_pix_payload;
  wire       [10:0]   temp_rom_addr_block;
  wire       [4:0]    temp_rom_addr_block_1;
  wire       [7:0]    temp_rom_addr_block_2;
  wire       [9:0]    temp_rom_addr;
  wire       [9:0]    y_diff;
  wire       [7:0]    y_diff_scale;
  wire                y_valid;
  reg        [9:0]    sx_early_r;
  wire                sop;
  reg        [9:0]    rom_addr_block;
  reg        [9:0]    rom_addr;
  reg                 draw_running;
  reg                 scale_cnt_willIncrement;
  reg                 scale_cnt_willClear;
  reg        [1:0]    scale_cnt_valueNext;
  reg        [1:0]    scale_cnt_value;
  wire                scale_cnt_willOverflowIfInc;
  wire                scale_cnt_willOverflow;
  reg                 x_cnt_willIncrement;
  reg                 x_cnt_willClear;
  reg        [4:0]    x_cnt_valueNext;
  reg        [4:0]    x_cnt_value;
  wire                x_cnt_willOverflowIfInc;
  wire                x_cnt_willOverflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg                 draw_running_delay_1;
  reg                 draw_running_delay_2;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_LINE_START;
  wire                fsm_onExit_WAIT_POS;
  wire                fsm_onExit_LINE_DRAW;
  wire                fsm_onExit_LINE_END;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_LINE_START;
  wire                fsm_onEntry_WAIT_POS;
  wire                fsm_onEntry_LINE_DRAW;
  wire                fsm_onEntry_LINE_END;
  `ifndef SYNTHESIS
  reg [79:0] fsm_stateReg_string;
  reg [79:0] fsm_stateNext_string;
  `endif

  reg [3:0] rom [0:639];

  assign temp_y_diff = {1'b0,y};
  assign temp_y_diff_1 = {1'b0,sy_orig};
  assign temp_scale_cnt_valueNext_1 = scale_cnt_willIncrement;
  assign temp_scale_cnt_valueNext = {1'd0, temp_scale_cnt_valueNext_1};
  assign temp_x_cnt_valueNext_1 = x_cnt_willIncrement;
  assign temp_x_cnt_valueNext = {4'd0, temp_x_cnt_valueNext_1};
  assign temp_rom_addr_block = (temp_rom_addr_block_1 * 6'h20);
  assign temp_rom_addr_block_2 = y_diff_scale;
  assign temp_rom_addr_block_1 = temp_rom_addr_block_2[4:0];
  assign temp_rom_addr = {5'd0, x_cnt_value};
  assign temp_pix_payload = 1'b1;
  initial begin
    rom[0] = 4'b1001;
    rom[1] = 4'b1001;
    rom[2] = 4'b1001;
    rom[3] = 4'b1001;
    rom[4] = 4'b1001;
    rom[5] = 4'b1001;
    rom[6] = 4'b1001;
    rom[7] = 4'b1001;
    rom[8] = 4'b1001;
    rom[9] = 4'b1001;
    rom[10] = 4'b1001;
    rom[11] = 4'b1001;
    rom[12] = 4'b1000;
    rom[13] = 4'b1001;
    rom[14] = 4'b1001;
    rom[15] = 4'b1001;
    rom[16] = 4'b1000;
    rom[17] = 4'b1001;
    rom[18] = 4'b1001;
    rom[19] = 4'b1001;
    rom[20] = 4'b1000;
    rom[21] = 4'b1001;
    rom[22] = 4'b1001;
    rom[23] = 4'b1001;
    rom[24] = 4'b1001;
    rom[25] = 4'b1001;
    rom[26] = 4'b1001;
    rom[27] = 4'b1001;
    rom[28] = 4'b1001;
    rom[29] = 4'b1001;
    rom[30] = 4'b1001;
    rom[31] = 4'b1001;
    rom[32] = 4'b1001;
    rom[33] = 4'b1001;
    rom[34] = 4'b1001;
    rom[35] = 4'b1001;
    rom[36] = 4'b1001;
    rom[37] = 4'b1001;
    rom[38] = 4'b1001;
    rom[39] = 4'b1001;
    rom[40] = 4'b1001;
    rom[41] = 4'b1001;
    rom[42] = 4'b1001;
    rom[43] = 4'b1000;
    rom[44] = 4'b0110;
    rom[45] = 4'b1000;
    rom[46] = 4'b1001;
    rom[47] = 4'b1000;
    rom[48] = 4'b0110;
    rom[49] = 4'b1000;
    rom[50] = 4'b1001;
    rom[51] = 4'b1001;
    rom[52] = 4'b1000;
    rom[53] = 4'b1001;
    rom[54] = 4'b1001;
    rom[55] = 4'b1001;
    rom[56] = 4'b1000;
    rom[57] = 4'b1001;
    rom[58] = 4'b1001;
    rom[59] = 4'b1001;
    rom[60] = 4'b1001;
    rom[61] = 4'b1001;
    rom[62] = 4'b1001;
    rom[63] = 4'b1001;
    rom[64] = 4'b1001;
    rom[65] = 4'b1001;
    rom[66] = 4'b1001;
    rom[67] = 4'b1001;
    rom[68] = 4'b1001;
    rom[69] = 4'b1001;
    rom[70] = 4'b1001;
    rom[71] = 4'b1001;
    rom[72] = 4'b1000;
    rom[73] = 4'b1000;
    rom[74] = 4'b1001;
    rom[75] = 4'b1000;
    rom[76] = 4'b0110;
    rom[77] = 4'b1000;
    rom[78] = 4'b1001;
    rom[79] = 4'b1000;
    rom[80] = 4'b0110;
    rom[81] = 4'b1000;
    rom[82] = 4'b1001;
    rom[83] = 4'b1000;
    rom[84] = 4'b0110;
    rom[85] = 4'b1000;
    rom[86] = 4'b1001;
    rom[87] = 4'b1000;
    rom[88] = 4'b0110;
    rom[89] = 4'b1000;
    rom[90] = 4'b1001;
    rom[91] = 4'b1001;
    rom[92] = 4'b1001;
    rom[93] = 4'b1001;
    rom[94] = 4'b1001;
    rom[95] = 4'b1001;
    rom[96] = 4'b1001;
    rom[97] = 4'b1001;
    rom[98] = 4'b1001;
    rom[99] = 4'b1001;
    rom[100] = 4'b1001;
    rom[101] = 4'b1001;
    rom[102] = 4'b1001;
    rom[103] = 4'b1001;
    rom[104] = 4'b1000;
    rom[105] = 4'b0110;
    rom[106] = 4'b1000;
    rom[107] = 4'b1001;
    rom[108] = 4'b1000;
    rom[109] = 4'b0110;
    rom[110] = 4'b1000;
    rom[111] = 4'b1000;
    rom[112] = 4'b0011;
    rom[113] = 4'b1000;
    rom[114] = 4'b1001;
    rom[115] = 4'b1000;
    rom[116] = 4'b0011;
    rom[117] = 4'b1000;
    rom[118] = 4'b1001;
    rom[119] = 4'b0101;
    rom[120] = 4'b0110;
    rom[121] = 4'b1000;
    rom[122] = 4'b1001;
    rom[123] = 4'b1001;
    rom[124] = 4'b1000;
    rom[125] = 4'b1000;
    rom[126] = 4'b1001;
    rom[127] = 4'b1001;
    rom[128] = 4'b1001;
    rom[129] = 4'b1001;
    rom[130] = 4'b1001;
    rom[131] = 4'b1001;
    rom[132] = 4'b1001;
    rom[133] = 4'b1001;
    rom[134] = 4'b1001;
    rom[135] = 4'b1001;
    rom[136] = 4'b1000;
    rom[137] = 4'b0110;
    rom[138] = 4'b1000;
    rom[139] = 4'b1000;
    rom[140] = 4'b1000;
    rom[141] = 4'b0100;
    rom[142] = 4'b0110;
    rom[143] = 4'b1000;
    rom[144] = 4'b0011;
    rom[145] = 4'b1000;
    rom[146] = 4'b1000;
    rom[147] = 4'b1000;
    rom[148] = 4'b0011;
    rom[149] = 4'b1000;
    rom[150] = 4'b0111;
    rom[151] = 4'b0100;
    rom[152] = 4'b1000;
    rom[153] = 4'b1001;
    rom[154] = 4'b1001;
    rom[155] = 4'b1000;
    rom[156] = 4'b0110;
    rom[157] = 4'b1000;
    rom[158] = 4'b1001;
    rom[159] = 4'b1001;
    rom[160] = 4'b1001;
    rom[161] = 4'b1001;
    rom[162] = 4'b1001;
    rom[163] = 4'b1001;
    rom[164] = 4'b1001;
    rom[165] = 4'b1000;
    rom[166] = 4'b1000;
    rom[167] = 4'b1000;
    rom[168] = 4'b1001;
    rom[169] = 4'b1000;
    rom[170] = 4'b0110;
    rom[171] = 4'b1000;
    rom[172] = 4'b1000;
    rom[173] = 4'b0100;
    rom[174] = 4'b0100;
    rom[175] = 4'b1000;
    rom[176] = 4'b1000;
    rom[177] = 4'b1000;
    rom[178] = 4'b1000;
    rom[179] = 4'b1000;
    rom[180] = 4'b1000;
    rom[181] = 4'b1000;
    rom[182] = 4'b0100;
    rom[183] = 4'b0101;
    rom[184] = 4'b1000;
    rom[185] = 4'b1001;
    rom[186] = 4'b1000;
    rom[187] = 4'b0110;
    rom[188] = 4'b0100;
    rom[189] = 4'b1000;
    rom[190] = 4'b1001;
    rom[191] = 4'b1001;
    rom[192] = 4'b1001;
    rom[193] = 4'b1001;
    rom[194] = 4'b1001;
    rom[195] = 4'b1001;
    rom[196] = 4'b1001;
    rom[197] = 4'b1001;
    rom[198] = 4'b1000;
    rom[199] = 4'b1000;
    rom[200] = 4'b1000;
    rom[201] = 4'b1000;
    rom[202] = 4'b0011;
    rom[203] = 4'b0110;
    rom[204] = 4'b1000;
    rom[205] = 4'b1000;
    rom[206] = 4'b0100;
    rom[207] = 4'b1000;
    rom[208] = 4'b1000;
    rom[209] = 4'b0110;
    rom[210] = 4'b0110;
    rom[211] = 4'b1000;
    rom[212] = 4'b0110;
    rom[213] = 4'b0110;
    rom[214] = 4'b0110;
    rom[215] = 4'b1000;
    rom[216] = 4'b1000;
    rom[217] = 4'b1000;
    rom[218] = 4'b0110;
    rom[219] = 4'b0100;
    rom[220] = 4'b1000;
    rom[221] = 4'b1001;
    rom[222] = 4'b1001;
    rom[223] = 4'b1001;
    rom[224] = 4'b1001;
    rom[225] = 4'b1001;
    rom[226] = 4'b1001;
    rom[227] = 4'b1001;
    rom[228] = 4'b1000;
    rom[229] = 4'b1000;
    rom[230] = 4'b1000;
    rom[231] = 4'b1000;
    rom[232] = 4'b1000;
    rom[233] = 4'b1000;
    rom[234] = 4'b0110;
    rom[235] = 4'b0011;
    rom[236] = 4'b1000;
    rom[237] = 4'b1000;
    rom[238] = 4'b0110;
    rom[239] = 4'b0110;
    rom[240] = 4'b1000;
    rom[241] = 4'b0110;
    rom[242] = 4'b0011;
    rom[243] = 4'b1000;
    rom[244] = 4'b0110;
    rom[245] = 4'b0011;
    rom[246] = 4'b0110;
    rom[247] = 4'b1000;
    rom[248] = 4'b0110;
    rom[249] = 4'b1000;
    rom[250] = 4'b0100;
    rom[251] = 4'b1000;
    rom[252] = 4'b1001;
    rom[253] = 4'b1001;
    rom[254] = 4'b1001;
    rom[255] = 4'b1001;
    rom[256] = 4'b1001;
    rom[257] = 4'b1001;
    rom[258] = 4'b1001;
    rom[259] = 4'b1000;
    rom[260] = 4'b0000;
    rom[261] = 4'b1000;
    rom[262] = 4'b0000;
    rom[263] = 4'b0000;
    rom[264] = 4'b0010;
    rom[265] = 4'b1000;
    rom[266] = 4'b1000;
    rom[267] = 4'b1000;
    rom[268] = 4'b1000;
    rom[269] = 4'b1000;
    rom[270] = 4'b0111;
    rom[271] = 4'b0111;
    rom[272] = 4'b0111;
    rom[273] = 4'b0111;
    rom[274] = 4'b0111;
    rom[275] = 4'b0111;
    rom[276] = 4'b0111;
    rom[277] = 4'b1000;
    rom[278] = 4'b1000;
    rom[279] = 4'b0110;
    rom[280] = 4'b0100;
    rom[281] = 4'b0110;
    rom[282] = 4'b1000;
    rom[283] = 4'b1000;
    rom[284] = 4'b1001;
    rom[285] = 4'b1000;
    rom[286] = 4'b1001;
    rom[287] = 4'b1001;
    rom[288] = 4'b1001;
    rom[289] = 4'b1001;
    rom[290] = 4'b1001;
    rom[291] = 4'b1000;
    rom[292] = 4'b1000;
    rom[293] = 4'b1000;
    rom[294] = 4'b1000;
    rom[295] = 4'b0010;
    rom[296] = 4'b0000;
    rom[297] = 4'b0010;
    rom[298] = 4'b1000;
    rom[299] = 4'b1000;
    rom[300] = 4'b0111;
    rom[301] = 4'b1000;
    rom[302] = 4'b0111;
    rom[303] = 4'b0111;
    rom[304] = 4'b0110;
    rom[305] = 4'b0110;
    rom[306] = 4'b0111;
    rom[307] = 4'b0111;
    rom[308] = 4'b0111;
    rom[309] = 4'b0111;
    rom[310] = 4'b0111;
    rom[311] = 4'b1000;
    rom[312] = 4'b1000;
    rom[313] = 4'b1000;
    rom[314] = 4'b1000;
    rom[315] = 4'b1000;
    rom[316] = 4'b1000;
    rom[317] = 4'b0101;
    rom[318] = 4'b1000;
    rom[319] = 4'b1001;
    rom[320] = 4'b1001;
    rom[321] = 4'b1001;
    rom[322] = 4'b1001;
    rom[323] = 4'b1000;
    rom[324] = 4'b1000;
    rom[325] = 4'b1000;
    rom[326] = 4'b1000;
    rom[327] = 4'b1000;
    rom[328] = 4'b0000;
    rom[329] = 4'b0000;
    rom[330] = 4'b1000;
    rom[331] = 4'b0111;
    rom[332] = 4'b0111;
    rom[333] = 4'b1000;
    rom[334] = 4'b0111;
    rom[335] = 4'b0111;
    rom[336] = 4'b0011;
    rom[337] = 4'b0110;
    rom[338] = 4'b0111;
    rom[339] = 4'b0111;
    rom[340] = 4'b0011;
    rom[341] = 4'b0111;
    rom[342] = 4'b0111;
    rom[343] = 4'b0111;
    rom[344] = 4'b0110;
    rom[345] = 4'b0110;
    rom[346] = 4'b0101;
    rom[347] = 4'b0101;
    rom[348] = 4'b0100;
    rom[349] = 4'b1000;
    rom[350] = 4'b1001;
    rom[351] = 4'b1001;
    rom[352] = 4'b1001;
    rom[353] = 4'b1001;
    rom[354] = 4'b1000;
    rom[355] = 4'b1000;
    rom[356] = 4'b1000;
    rom[357] = 4'b1000;
    rom[358] = 4'b1000;
    rom[359] = 4'b1000;
    rom[360] = 4'b0000;
    rom[361] = 4'b0000;
    rom[362] = 4'b0111;
    rom[363] = 4'b0111;
    rom[364] = 4'b0111;
    rom[365] = 4'b0111;
    rom[366] = 4'b1000;
    rom[367] = 4'b0111;
    rom[368] = 4'b0111;
    rom[369] = 4'b0111;
    rom[370] = 4'b0110;
    rom[371] = 4'b0110;
    rom[372] = 4'b0110;
    rom[373] = 4'b0110;
    rom[374] = 4'b0110;
    rom[375] = 4'b0100;
    rom[376] = 4'b0100;
    rom[377] = 4'b0110;
    rom[378] = 4'b0110;
    rom[379] = 4'b0111;
    rom[380] = 4'b0111;
    rom[381] = 4'b1000;
    rom[382] = 4'b1001;
    rom[383] = 4'b1001;
    rom[384] = 4'b1001;
    rom[385] = 4'b1000;
    rom[386] = 4'b1000;
    rom[387] = 4'b0101;
    rom[388] = 4'b1000;
    rom[389] = 4'b0010;
    rom[390] = 4'b1000;
    rom[391] = 4'b0010;
    rom[392] = 4'b0000;
    rom[393] = 4'b0010;
    rom[394] = 4'b0111;
    rom[395] = 4'b0110;
    rom[396] = 4'b0110;
    rom[397] = 4'b0111;
    rom[398] = 4'b0111;
    rom[399] = 4'b1000;
    rom[400] = 4'b1000;
    rom[401] = 4'b1000;
    rom[402] = 4'b1000;
    rom[403] = 4'b0111;
    rom[404] = 4'b0111;
    rom[405] = 4'b0111;
    rom[406] = 4'b0111;
    rom[407] = 4'b0111;
    rom[408] = 4'b0111;
    rom[409] = 4'b0111;
    rom[410] = 4'b0111;
    rom[411] = 4'b0111;
    rom[412] = 4'b0111;
    rom[413] = 4'b1000;
    rom[414] = 4'b1001;
    rom[415] = 4'b1001;
    rom[416] = 4'b1000;
    rom[417] = 4'b0001;
    rom[418] = 4'b1000;
    rom[419] = 4'b1000;
    rom[420] = 4'b0111;
    rom[421] = 4'b1000;
    rom[422] = 4'b0000;
    rom[423] = 4'b0000;
    rom[424] = 4'b0010;
    rom[425] = 4'b1000;
    rom[426] = 4'b0111;
    rom[427] = 4'b0101;
    rom[428] = 4'b0101;
    rom[429] = 4'b0101;
    rom[430] = 4'b0110;
    rom[431] = 4'b0110;
    rom[432] = 4'b0111;
    rom[433] = 4'b0111;
    rom[434] = 4'b0111;
    rom[435] = 4'b1000;
    rom[436] = 4'b1000;
    rom[437] = 4'b1000;
    rom[438] = 4'b1000;
    rom[439] = 4'b0111;
    rom[440] = 4'b0111;
    rom[441] = 4'b0110;
    rom[442] = 4'b0110;
    rom[443] = 4'b0110;
    rom[444] = 4'b0110;
    rom[445] = 4'b1000;
    rom[446] = 4'b1001;
    rom[447] = 4'b1001;
    rom[448] = 4'b1000;
    rom[449] = 4'b1000;
    rom[450] = 4'b1000;
    rom[451] = 4'b1000;
    rom[452] = 4'b0100;
    rom[453] = 4'b0111;
    rom[454] = 4'b1000;
    rom[455] = 4'b1000;
    rom[456] = 4'b1000;
    rom[457] = 4'b0111;
    rom[458] = 4'b0111;
    rom[459] = 4'b0101;
    rom[460] = 4'b0101;
    rom[461] = 4'b0101;
    rom[462] = 4'b0100;
    rom[463] = 4'b0100;
    rom[464] = 4'b0100;
    rom[465] = 4'b0100;
    rom[466] = 4'b0101;
    rom[467] = 4'b0101;
    rom[468] = 4'b0101;
    rom[469] = 4'b0110;
    rom[470] = 4'b0111;
    rom[471] = 4'b1000;
    rom[472] = 4'b1000;
    rom[473] = 4'b0110;
    rom[474] = 4'b0110;
    rom[475] = 4'b0110;
    rom[476] = 4'b0111;
    rom[477] = 4'b1000;
    rom[478] = 4'b1001;
    rom[479] = 4'b1001;
    rom[480] = 4'b1000;
    rom[481] = 4'b0101;
    rom[482] = 4'b0100;
    rom[483] = 4'b0100;
    rom[484] = 4'b0100;
    rom[485] = 4'b0100;
    rom[486] = 4'b0100;
    rom[487] = 4'b0101;
    rom[488] = 4'b0101;
    rom[489] = 4'b0101;
    rom[490] = 4'b0110;
    rom[491] = 4'b0101;
    rom[492] = 4'b0101;
    rom[493] = 4'b0101;
    rom[494] = 4'b0100;
    rom[495] = 4'b0100;
    rom[496] = 4'b0100;
    rom[497] = 4'b0100;
    rom[498] = 4'b0100;
    rom[499] = 4'b0101;
    rom[500] = 4'b0101;
    rom[501] = 4'b0110;
    rom[502] = 4'b0110;
    rom[503] = 4'b0111;
    rom[504] = 4'b1000;
    rom[505] = 4'b0111;
    rom[506] = 4'b0111;
    rom[507] = 4'b0111;
    rom[508] = 4'b0111;
    rom[509] = 4'b1000;
    rom[510] = 4'b1001;
    rom[511] = 4'b1001;
    rom[512] = 4'b1001;
    rom[513] = 4'b1000;
    rom[514] = 4'b0101;
    rom[515] = 4'b0100;
    rom[516] = 4'b0100;
    rom[517] = 4'b0100;
    rom[518] = 4'b0100;
    rom[519] = 4'b0100;
    rom[520] = 4'b0110;
    rom[521] = 4'b0110;
    rom[522] = 4'b0110;
    rom[523] = 4'b0110;
    rom[524] = 4'b0101;
    rom[525] = 4'b0101;
    rom[526] = 4'b0101;
    rom[527] = 4'b0101;
    rom[528] = 4'b0100;
    rom[529] = 4'b0101;
    rom[530] = 4'b0101;
    rom[531] = 4'b0101;
    rom[532] = 4'b0110;
    rom[533] = 4'b0111;
    rom[534] = 4'b0110;
    rom[535] = 4'b0110;
    rom[536] = 4'b0110;
    rom[537] = 4'b1000;
    rom[538] = 4'b0111;
    rom[539] = 4'b0111;
    rom[540] = 4'b1000;
    rom[541] = 4'b1001;
    rom[542] = 4'b1001;
    rom[543] = 4'b1001;
    rom[544] = 4'b1001;
    rom[545] = 4'b1001;
    rom[546] = 4'b1000;
    rom[547] = 4'b1000;
    rom[548] = 4'b1000;
    rom[549] = 4'b1000;
    rom[550] = 4'b1000;
    rom[551] = 4'b1000;
    rom[552] = 4'b0101;
    rom[553] = 4'b0101;
    rom[554] = 4'b0101;
    rom[555] = 4'b0110;
    rom[556] = 4'b0110;
    rom[557] = 4'b1000;
    rom[558] = 4'b0111;
    rom[559] = 4'b0110;
    rom[560] = 4'b0101;
    rom[561] = 4'b0101;
    rom[562] = 4'b0110;
    rom[563] = 4'b0111;
    rom[564] = 4'b1000;
    rom[565] = 4'b0101;
    rom[566] = 4'b0101;
    rom[567] = 4'b0101;
    rom[568] = 4'b0101;
    rom[569] = 4'b1000;
    rom[570] = 4'b1000;
    rom[571] = 4'b1000;
    rom[572] = 4'b1001;
    rom[573] = 4'b1001;
    rom[574] = 4'b1001;
    rom[575] = 4'b1001;
    rom[576] = 4'b1001;
    rom[577] = 4'b1001;
    rom[578] = 4'b1001;
    rom[579] = 4'b1001;
    rom[580] = 4'b1001;
    rom[581] = 4'b1001;
    rom[582] = 4'b1001;
    rom[583] = 4'b1000;
    rom[584] = 4'b1000;
    rom[585] = 4'b0101;
    rom[586] = 4'b0011;
    rom[587] = 4'b0101;
    rom[588] = 4'b0101;
    rom[589] = 4'b1000;
    rom[590] = 4'b1000;
    rom[591] = 4'b1000;
    rom[592] = 4'b1000;
    rom[593] = 4'b1000;
    rom[594] = 4'b1000;
    rom[595] = 4'b1000;
    rom[596] = 4'b1000;
    rom[597] = 4'b0101;
    rom[598] = 4'b0101;
    rom[599] = 4'b0011;
    rom[600] = 4'b0111;
    rom[601] = 4'b1000;
    rom[602] = 4'b1000;
    rom[603] = 4'b1001;
    rom[604] = 4'b1001;
    rom[605] = 4'b1001;
    rom[606] = 4'b1001;
    rom[607] = 4'b1001;
    rom[608] = 4'b1001;
    rom[609] = 4'b1001;
    rom[610] = 4'b1001;
    rom[611] = 4'b1001;
    rom[612] = 4'b1001;
    rom[613] = 4'b1001;
    rom[614] = 4'b1001;
    rom[615] = 4'b1000;
    rom[616] = 4'b1000;
    rom[617] = 4'b1000;
    rom[618] = 4'b0011;
    rom[619] = 4'b0011;
    rom[620] = 4'b0101;
    rom[621] = 4'b1000;
    rom[622] = 4'b1001;
    rom[623] = 4'b1001;
    rom[624] = 4'b1001;
    rom[625] = 4'b1001;
    rom[626] = 4'b1001;
    rom[627] = 4'b1001;
    rom[628] = 4'b1000;
    rom[629] = 4'b0101;
    rom[630] = 4'b0011;
    rom[631] = 4'b0011;
    rom[632] = 4'b1000;
    rom[633] = 4'b1000;
    rom[634] = 4'b1000;
    rom[635] = 4'b1001;
    rom[636] = 4'b1001;
    rom[637] = 4'b1001;
    rom[638] = 4'b1001;
    rom[639] = 4'b1001;
  end
  always @(posedge clk) begin
    if(temp_pix_payload) begin
      rom_spinal_port0 <= rom[rom_addr];
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE      ";
      LINE_START : fsm_stateReg_string = "LINE_START";
      WAIT_POS : fsm_stateReg_string = "WAIT_POS  ";
      LINE_DRAW : fsm_stateReg_string = "LINE_DRAW ";
      LINE_END : fsm_stateReg_string = "LINE_END  ";
      default : fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE      ";
      LINE_START : fsm_stateNext_string = "LINE_START";
      WAIT_POS : fsm_stateNext_string = "WAIT_POS  ";
      LINE_DRAW : fsm_stateNext_string = "LINE_DRAW ";
      LINE_END : fsm_stateNext_string = "LINE_END  ";
      default : fsm_stateNext_string = "??????????";
    endcase
  end
  `endif

  assign y_diff = ($signed(temp_y_diff) - $signed(temp_y_diff_1));
  assign y_diff_scale = (y_diff >>> 2'd2);
  assign y_valid = ((! y_diff[9]) && ($signed(y_diff_scale) < $signed(8'h14)));
  assign sop = (x == sx_early_r);
  always @(*) begin
    scale_cnt_willIncrement = 1'b0;
    if(draw_running) begin
      scale_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    scale_cnt_willClear = 1'b0;
    x_cnt_willClear = 1'b0;
    fsm_wantStart = 1'b0;
    draw_running = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      LINE_START : begin
        if(y_valid) begin
          fsm_stateNext = WAIT_POS;
        end else begin
          fsm_stateNext = IDLE;
        end
      end
      WAIT_POS : begin
        if(sop) begin
          x_cnt_willClear = 1'b1;
          scale_cnt_willClear = 1'b1;
          fsm_stateNext = LINE_DRAW;
        end
      end
      LINE_DRAW : begin
        draw_running = 1'b1;
        if((x_cnt_willOverflowIfInc && scale_cnt_willOverflowIfInc)) begin
          fsm_stateNext = LINE_END;
        end
      end
      LINE_END : begin
        fsm_stateNext = IDLE;
      end
      default : begin
        if(sol) begin
          fsm_stateNext = LINE_START;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign scale_cnt_willOverflowIfInc = (scale_cnt_value == 2'b11);
  assign scale_cnt_willOverflow = (scale_cnt_willOverflowIfInc && scale_cnt_willIncrement);
  always @(*) begin
    scale_cnt_valueNext = (scale_cnt_value + temp_scale_cnt_valueNext);
    if(scale_cnt_willClear) begin
      scale_cnt_valueNext = 2'b00;
    end
  end

  always @(*) begin
    x_cnt_willIncrement = 1'b0;
    if(scale_cnt_willOverflowIfInc) begin
      x_cnt_willIncrement = 1'b1;
    end
  end

  assign x_cnt_willOverflowIfInc = (x_cnt_value == 5'h1f);
  assign x_cnt_willOverflow = (x_cnt_willOverflowIfInc && x_cnt_willIncrement);
  always @(*) begin
    x_cnt_valueNext = (x_cnt_value + temp_x_cnt_valueNext);
    if(x_cnt_willClear) begin
      x_cnt_valueNext = 5'h0;
    end
  end

  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  assign pix_valid = draw_running_delay_2;
  assign pix_payload = rom_spinal_port0;
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_LINE_START = ((fsm_stateNext != LINE_START) && (fsm_stateReg == LINE_START));
  assign fsm_onExit_WAIT_POS = ((fsm_stateNext != WAIT_POS) && (fsm_stateReg == WAIT_POS));
  assign fsm_onExit_LINE_DRAW = ((fsm_stateNext != LINE_DRAW) && (fsm_stateReg == LINE_DRAW));
  assign fsm_onExit_LINE_END = ((fsm_stateNext != LINE_END) && (fsm_stateReg == LINE_END));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_LINE_START = ((fsm_stateNext == LINE_START) && (fsm_stateReg != LINE_START));
  assign fsm_onEntry_WAIT_POS = ((fsm_stateNext == WAIT_POS) && (fsm_stateReg != WAIT_POS));
  assign fsm_onEntry_LINE_DRAW = ((fsm_stateNext == LINE_DRAW) && (fsm_stateReg != LINE_DRAW));
  assign fsm_onEntry_LINE_END = ((fsm_stateNext == LINE_END) && (fsm_stateReg != LINE_END));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_early_r <= 10'h0;
      rom_addr_block <= 10'h0;
      rom_addr <= 10'h0;
      scale_cnt_value <= 2'b00;
      x_cnt_value <= 5'h0;
      fsm_stateReg <= IDLE;
    end else begin
      scale_cnt_value <= scale_cnt_valueNext;
      x_cnt_value <= x_cnt_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        LINE_START : begin
          if(y_valid) begin
            sx_early_r <= (sx_orig - 10'h001);
          end
        end
        WAIT_POS : begin
          rom_addr_block <= temp_rom_addr_block[9:0];
        end
        LINE_DRAW : begin
          rom_addr <= (rom_addr_block + temp_rom_addr);
        end
        LINE_END : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    draw_running_delay_1 <= draw_running;
    draw_running_delay_2 <= draw_running_delay_1;
  end


endmodule
