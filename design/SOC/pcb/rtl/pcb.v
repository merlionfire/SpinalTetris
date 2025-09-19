// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : pcb
// Git hash  : 57c638189b4e0ddb5195fdfb622c25acf3882cef

`timescale 1ns/1ps

module pcb (
  input  wire          CLK_50M,
  input  wire          BTN_SOUTH,
  input  wire          BTN_WEST,
  input  wire          BTN_NORTH,
  input  wire          BTN_EAST,
  input  wire [3:0]    SW,
  input  wire          ROT_A,
  input  wire          ROT_B,
  input  wire          ROT_CENTER,
  inout  wire          PS2_CLK,
  inout  wire          PS2_DATA,
  output wire [3:0]    VGA_B,
  output wire [3:0]    VGA_G,
  output wire [3:0]    VGA_R,
  output wire          VGA_HSYNC,
  output wire          VGA_VSYNC
);

  wire                dcm_inst_CLKDV_OUT;
  wire                dcm_inst_CLKIN_IBUFG_OUT;
  wire                dcm_inst_CLK0_OUT;
  wire                dcm_inst_LOCKED_OUT;
  wire                dcm_inst_CLK2X_OUT;
  wire                CLK0_OUT_BUFG_O;
  wire       [3:0]    picouser_inst_btn_out;
  wire       [3:0]    picouser_inst_sws_out;
  wire       [3:0]    picouser_inst_rot_out;
  wire                tetris_top_inst_btns_rot_clr;
  wire                tetris_top_inst_vga_vSync;
  wire                tetris_top_inst_vga_hSync;
  wire                tetris_top_inst_vga_colorEn;
  wire       [3:0]    tetris_top_inst_vga_color_r;
  wire       [3:0]    tetris_top_inst_vga_color_g;
  wire       [3:0]    tetris_top_inst_vga_color_b;
  (* keep *) wire                core_fast_clk;
  (* keep *) wire                dcm_clocked;
  wire       [3:0]    btn_out;
  wire       [3:0]    sws_out;
  wire       [3:0]    rot_out;
  wire                rot_clr;
  wire                btn_north_1;
  wire                btn_east_1;
  wire                btn_south_1;
  wire                btn_west_1;
  wire                rot_push;
  wire                rot_pop;
  wire                rot_left;
  wire                rot_right;
  wire                btns_btn_north;
  wire                btns_btn_east;
  wire                btns_btn_south;
  wire                btns_btn_west;
  wire                btns_rot_push;
  wire                btns_rot_pop;
  wire                btns_rot_left;
  wire                btns_rot_right;
  wire                btns_rot_clr;

  dcm dcm_inst (
    .CLKIN_IN        (CLK_50M                 ), //i
    .RST_IN          (1'b0                    ), //i
    .CLKDV_OUT       (dcm_inst_CLKDV_OUT      ), //o
    .CLKIN_IBUFG_OUT (dcm_inst_CLKIN_IBUFG_OUT), //o
    .CLK0_OUT        (dcm_inst_CLK0_OUT       ), //o
    .LOCKED_OUT      (dcm_inst_LOCKED_OUT     ), //o
    .CLK2X_OUT       (dcm_inst_CLK2X_OUT      )  //o
  );
  BUFG CLK0_OUT_BUFG (
    .I (dcm_inst_CLK0_OUT), //i
    .O (CLK0_OUT_BUFG_O  )  //o
  );
  picouser picouser_inst (
    .BTN_EAST   (BTN_EAST                  ), //i
    .BTN_NORTH  (BTN_NORTH                 ), //i
    .BTN_SOUTH  (BTN_SOUTH                 ), //i
    .BTN_WEST   (BTN_WEST                  ), //i
    .SW         (SW[3:0]                   ), //i
    .ROT_A      (ROT_A                     ), //i
    .ROT_B      (ROT_B                     ), //i
    .ROT_CENTER (ROT_CENTER                ), //i
    .rot_clr    (rot_clr                   ), //i
    .clk        (CLK0_OUT_BUFG_O           ), //i
    .btn_out    (picouser_inst_btn_out[3:0]), //o
    .sws_out    (picouser_inst_sws_out[3:0]), //o
    .rot_out    (picouser_inst_rot_out[3:0])  //o
  );
  (* keep_hierarchy = "yes" *) tetris_top tetris_top_inst (
    .core_clk       (CLK0_OUT_BUFG_O                 ), //i
    .core_rst       (btn_north_1                     ), //i
    .vga_clk        (dcm_inst_CLKDV_OUT              ), //i
    .vga_rst        (btn_north_1                     ), //i
    .btns_btn_north (btns_btn_north                  ), //i
    .btns_btn_east  (btns_btn_east                   ), //i
    .btns_btn_south (btns_btn_south                  ), //i
    .btns_btn_west  (btns_btn_west                   ), //i
    .btns_rot_push  (btns_rot_push                   ), //i
    .btns_rot_pop   (btns_rot_pop                    ), //i
    .btns_rot_left  (btns_rot_left                   ), //i
    .btns_rot_right (btns_rot_right                  ), //i
    .btns_rot_clr   (tetris_top_inst_btns_rot_clr    ), //o
    .ps2_clk        (PS2_CLK                         ), //~
    .ps2_data       (PS2_DATA                        ), //~
    .vga_vSync      (tetris_top_inst_vga_vSync       ), //o
    .vga_hSync      (tetris_top_inst_vga_hSync       ), //o
    .vga_colorEn    (tetris_top_inst_vga_colorEn     ), //o
    .vga_color_r    (tetris_top_inst_vga_color_r[3:0]), //o
    .vga_color_g    (tetris_top_inst_vga_color_g[3:0]), //o
    .vga_color_b    (tetris_top_inst_vga_color_b[3:0])  //o
  );
  assign core_fast_clk = dcm_inst_CLK2X_OUT;
  assign dcm_clocked = dcm_inst_LOCKED_OUT;
  assign btn_out = picouser_inst_btn_out;
  assign sws_out = picouser_inst_sws_out;
  assign rot_out = picouser_inst_rot_out;
  assign btn_north_1 = btn_out[3];
  assign btn_east_1 = btn_out[2];
  assign btn_south_1 = btn_out[1];
  assign btn_west_1 = btn_out[0];
  assign rot_push = rot_out[3];
  assign rot_pop = rot_out[2];
  assign rot_left = rot_out[1];
  assign rot_right = rot_out[0];
  assign btns_btn_north = btn_north_1;
  assign btns_btn_east = btn_east_1;
  assign btns_btn_south = btn_south_1;
  assign btns_btn_west = btn_west_1;
  assign btns_rot_push = rot_push;
  assign btns_rot_pop = rot_pop;
  assign btns_rot_left = rot_left;
  assign btns_rot_right = rot_right;
  assign rot_clr = btns_rot_clr;
  assign btns_rot_clr = tetris_top_inst_btns_rot_clr;
  assign VGA_HSYNC = tetris_top_inst_vga_hSync;
  assign VGA_VSYNC = tetris_top_inst_vga_vSync;
  assign VGA_R = tetris_top_inst_vga_color_r;
  assign VGA_G = tetris_top_inst_vga_color_g;
  assign VGA_B = tetris_top_inst_vga_color_b;

endmodule

module tetris_top (
  input  wire          core_clk,
  input  wire          core_rst,
  input  wire          vga_clk,
  input  wire          vga_rst,
  input  wire          btns_btn_north,
  input  wire          btns_btn_east,
  input  wire          btns_btn_south,
  input  wire          btns_btn_west,
  input  wire          btns_rot_push,
  input  wire          btns_rot_pop,
  input  wire          btns_rot_left,
  input  wire          btns_rot_right,
  output wire          btns_rot_clr,
  inout  wire          ps2_clk,
  inout  wire          ps2_data,
  output wire          vga_vSync,
  output wire          vga_hSync,
  output wire          vga_colorEn,
  output wire [3:0]    vga_color_r,
  output wire [3:0]    vga_color_g,
  output wire [3:0]    vga_color_b
);

  wire                tetris_core_inst_ctrl_allowed;
  wire                tetris_core_inst_vga_vSync;
  wire                tetris_core_inst_vga_hSync;
  wire                tetris_core_inst_vga_colorEn;
  wire       [3:0]    tetris_core_inst_vga_color_r;
  wire       [3:0]    tetris_core_inst_vga_color_g;
  wire       [3:0]    tetris_core_inst_vga_color_b;
  wire                kd_ps2_inst_rd_data_valid;
  wire       [7:0]    kd_ps2_inst_rd_data_payload;
  wire       [4:0]    kd_ps2_inst_keys_valid;
  reg                 tetris_core_inst_ctrl_allowed_regNext;
  reg                 temp_rotate;
  reg                 btns_btn_south_regNext;

  tetris_core tetris_core_inst (
    .core_clk     (core_clk                         ), //i
    .core_rst     (core_rst                         ), //i
    .vga_clk      (vga_clk                          ), //i
    .vga_rst      (vga_rst                          ), //i
    .game_start   (btns_btn_west                    ), //i
    .move_left    (btns_rot_right                   ), //i
    .move_right   (btns_rot_left                    ), //i
    .move_down    (btns_rot_push                    ), //i
    .rotate       (temp_rotate                      ), //i
    .ctrl_allowed (tetris_core_inst_ctrl_allowed    ), //o
    .vga_vSync    (tetris_core_inst_vga_vSync       ), //o
    .vga_hSync    (tetris_core_inst_vga_hSync       ), //o
    .vga_colorEn  (tetris_core_inst_vga_colorEn     ), //o
    .vga_color_r  (tetris_core_inst_vga_color_r[3:0]), //o
    .vga_color_g  (tetris_core_inst_vga_color_g[3:0]), //o
    .vga_color_b  (tetris_core_inst_vga_color_b[3:0])  //o
  );
  kd_ps2 kd_ps2_inst (
    .ps2_clk         (ps2_clk                         ), //~
    .ps2_data        (ps2_data                        ), //~
    .rd_data_valid   (kd_ps2_inst_rd_data_valid       ), //o
    .rd_data_payload (kd_ps2_inst_rd_data_payload[7:0]), //o
    .keys_valid      (kd_ps2_inst_keys_valid[4:0]     ), //o
    .core_rst        (core_rst                        ), //i
    .core_clk        (core_clk                        )  //i
  );
  assign vga_vSync = tetris_core_inst_vga_vSync;
  assign vga_hSync = tetris_core_inst_vga_hSync;
  assign vga_colorEn = tetris_core_inst_vga_colorEn;
  assign vga_color_r = tetris_core_inst_vga_color_r;
  assign vga_color_g = tetris_core_inst_vga_color_g;
  assign vga_color_b = tetris_core_inst_vga_color_b;
  assign btns_rot_clr = (tetris_core_inst_ctrl_allowed && (! tetris_core_inst_ctrl_allowed_regNext));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      tetris_core_inst_ctrl_allowed_regNext <= 1'b0;
      temp_rotate <= 1'b0;
      btns_btn_south_regNext <= 1'b0;
    end else begin
      tetris_core_inst_ctrl_allowed_regNext <= tetris_core_inst_ctrl_allowed;
      btns_btn_south_regNext <= btns_btn_south;
      if((btns_btn_south && (! btns_btn_south_regNext))) begin
        temp_rotate <= 1'b1;
      end
      if(btns_rot_clr) begin
        temp_rotate <= 1'b0;
      end
    end
  end


endmodule

module kd_ps2 (
  inout  wire          ps2_clk,
  inout  wire          ps2_data,
  output wire          rd_data_valid,
  output wire [7:0]    rd_data_payload,
  output reg  [4:0]    keys_valid,
  input  wire          core_rst,
  input  wire          core_clk
);
  localparam IDLE = 2'd0;
  localparam WAIT_BREAK = 2'd1;
  localparam WAIT_LAST = 2'd2;
  localparam DEFAULT_1 = 2'd3;

  wire                ps2_inst_ps2_tx_done;
  wire                ps2_inst_ps2_tx_ready;
  wire                ps2_inst_ps2_rddata_valid;
  wire       [7:0]    ps2_inst_ps2_rd_data;
  wire                ps2_inst_ps2_rx_ready;
  wire                is_key_received;
  wire                is_key_2nd_recevied;
  wire                break_tick;
  wire                rx_fsm_wantExit;
  reg                 rx_fsm_wantStart;
  wire                rx_fsm_wantKill;
  wire                is_fsm_in_idle;
  wire                is_fsm_exit_wait_last;
  wire                up_tick;
  reg                 up_valid;
  wire                up_tick_2nd;
  wire                down_tick;
  reg                 down_valid;
  wire                down_tick_2nd;
  wire                left_tick;
  reg                 left_valid;
  wire                left_tick_2nd;
  wire                right_tick;
  reg                 right_valid;
  wire                right_tick_2nd;
  wire                space_tick;
  reg                 space_valid;
  wire                space_tick_2nd;
  reg        [1:0]    rx_fsm_stateReg;
  reg        [1:0]    rx_fsm_stateNext;
  wire                rx_fsm_onExit_IDLE;
  wire                rx_fsm_onExit_WAIT_BREAK;
  wire                rx_fsm_onExit_WAIT_LAST;
  wire                rx_fsm_onExit_DEFAULT_1;
  wire                rx_fsm_onEntry_IDLE;
  wire                rx_fsm_onEntry_WAIT_BREAK;
  wire                rx_fsm_onEntry_WAIT_LAST;
  wire                rx_fsm_onEntry_DEFAULT_1;
  `ifndef SYNTHESIS
  reg [79:0] rx_fsm_stateReg_string;
  reg [79:0] rx_fsm_stateNext_string;
  `endif


  ps2_host_rxtx ps2_inst (
    .clk              (core_clk                 ), //i
    .rst              (core_rst                 ), //i
    .ps2_clk          (ps2_clk                  ), //~
    .ps2_data         (ps2_data                 ), //~
    .ps2_wr_stb       (1'b0                     ), //i
    .ps2_wr_data      (8'h0                     ), //i
    .ps2_tx_done      (ps2_inst_ps2_tx_done     ), //o
    .ps2_tx_ready     (ps2_inst_ps2_tx_ready    ), //o
    .ps2_rddata_valid (ps2_inst_ps2_rddata_valid), //o
    .ps2_rd_data      (ps2_inst_ps2_rd_data[7:0]), //o
    .ps2_rx_ready     (ps2_inst_ps2_rx_ready    )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(rx_fsm_stateReg)
      IDLE : rx_fsm_stateReg_string = "IDLE      ";
      WAIT_BREAK : rx_fsm_stateReg_string = "WAIT_BREAK";
      WAIT_LAST : rx_fsm_stateReg_string = "WAIT_LAST ";
      DEFAULT_1 : rx_fsm_stateReg_string = "DEFAULT_1 ";
      default : rx_fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(rx_fsm_stateNext)
      IDLE : rx_fsm_stateNext_string = "IDLE      ";
      WAIT_BREAK : rx_fsm_stateNext_string = "WAIT_BREAK";
      WAIT_LAST : rx_fsm_stateNext_string = "WAIT_LAST ";
      DEFAULT_1 : rx_fsm_stateNext_string = "DEFAULT_1 ";
      default : rx_fsm_stateNext_string = "??????????";
    endcase
  end
  `endif

  assign rd_data_valid = ps2_inst_ps2_rddata_valid;
  assign rd_data_payload = ps2_inst_ps2_rd_data;
  assign break_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'hf0));
  assign rx_fsm_wantExit = 1'b0;
  always @(*) begin
    rx_fsm_wantStart = 1'b0;
    rx_fsm_stateNext = rx_fsm_stateReg;
    case(rx_fsm_stateReg)
      WAIT_BREAK : begin
        if(break_tick) begin
          rx_fsm_stateNext = WAIT_LAST;
        end
      end
      WAIT_LAST : begin
        if(is_key_2nd_recevied) begin
          rx_fsm_stateNext = IDLE;
        end
      end
      DEFAULT_1 : begin
        rx_fsm_stateNext = IDLE;
      end
      default : begin
        if(is_key_received) begin
          rx_fsm_stateNext = WAIT_BREAK;
        end
        rx_fsm_wantStart = 1'b1;
      end
    endcase
    if(rx_fsm_wantKill) begin
      rx_fsm_stateNext = IDLE;
    end
  end

  assign rx_fsm_wantKill = 1'b0;
  assign up_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1d));
  assign up_tick_2nd = (up_tick && up_valid);
  always @(*) begin
    keys_valid[0] = up_valid;
    keys_valid[1] = down_valid;
    keys_valid[2] = left_valid;
    keys_valid[3] = right_valid;
    keys_valid[4] = space_valid;
  end

  assign down_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1b));
  assign down_tick_2nd = (down_tick && down_valid);
  assign left_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1c));
  assign left_tick_2nd = (left_tick && left_valid);
  assign right_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h23));
  assign right_tick_2nd = (right_tick && right_valid);
  assign space_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h29));
  assign space_tick_2nd = (space_tick && space_valid);
  assign is_key_received = (|{space_tick,{right_tick,{left_tick,{down_tick,up_tick}}}});
  assign is_key_2nd_recevied = (|{space_tick_2nd,{right_tick_2nd,{left_tick_2nd,{down_tick_2nd,up_tick_2nd}}}});
  assign rx_fsm_onExit_IDLE = ((rx_fsm_stateNext != IDLE) && (rx_fsm_stateReg == IDLE));
  assign rx_fsm_onExit_WAIT_BREAK = ((rx_fsm_stateNext != WAIT_BREAK) && (rx_fsm_stateReg == WAIT_BREAK));
  assign rx_fsm_onExit_WAIT_LAST = ((rx_fsm_stateNext != WAIT_LAST) && (rx_fsm_stateReg == WAIT_LAST));
  assign rx_fsm_onExit_DEFAULT_1 = ((rx_fsm_stateNext != DEFAULT_1) && (rx_fsm_stateReg == DEFAULT_1));
  assign rx_fsm_onEntry_IDLE = ((rx_fsm_stateNext == IDLE) && (rx_fsm_stateReg != IDLE));
  assign rx_fsm_onEntry_WAIT_BREAK = ((rx_fsm_stateNext == WAIT_BREAK) && (rx_fsm_stateReg != WAIT_BREAK));
  assign rx_fsm_onEntry_WAIT_LAST = ((rx_fsm_stateNext == WAIT_LAST) && (rx_fsm_stateReg != WAIT_LAST));
  assign rx_fsm_onEntry_DEFAULT_1 = ((rx_fsm_stateNext == DEFAULT_1) && (rx_fsm_stateReg != DEFAULT_1));
  assign is_fsm_in_idle = (rx_fsm_stateReg == IDLE);
  assign is_fsm_exit_wait_last = ((rx_fsm_stateNext != WAIT_LAST) && (rx_fsm_stateReg == WAIT_LAST));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      up_valid <= 1'b0;
      down_valid <= 1'b0;
      left_valid <= 1'b0;
      right_valid <= 1'b0;
      space_valid <= 1'b0;
      rx_fsm_stateReg <= IDLE;
    end else begin
      if(is_fsm_in_idle) begin
        up_valid <= up_tick;
      end
      if(is_fsm_exit_wait_last) begin
        up_valid <= 1'b0;
      end
      if(is_fsm_in_idle) begin
        down_valid <= down_tick;
      end
      if(is_fsm_exit_wait_last) begin
        down_valid <= 1'b0;
      end
      if(is_fsm_in_idle) begin
        left_valid <= left_tick;
      end
      if(is_fsm_exit_wait_last) begin
        left_valid <= 1'b0;
      end
      if(is_fsm_in_idle) begin
        right_valid <= right_tick;
      end
      if(is_fsm_exit_wait_last) begin
        right_valid <= 1'b0;
      end
      if(is_fsm_in_idle) begin
        space_valid <= space_tick;
      end
      if(is_fsm_exit_wait_last) begin
        space_valid <= 1'b0;
      end
      rx_fsm_stateReg <= rx_fsm_stateNext;
    end
  end


endmodule

module tetris_core (
  input  wire          core_clk,
  input  wire          core_rst,
  input  wire          vga_clk,
  input  wire          vga_rst,
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  output wire          ctrl_allowed,
  output wire          vga_vSync,
  output wire          vga_hSync,
  output wire          vga_colorEn,
  output wire [3:0]    vga_color_r,
  output wire [3:0]    vga_color_g,
  output wire [3:0]    vga_color_b
);

  wire                game_logic_inst_row_val_valid;
  wire       [9:0]    game_logic_inst_row_val_payload;
  wire                game_logic_inst_ctrl_allowed;
  wire                game_logic_inst_softReset;
  wire                game_logic_inst_game_restart;
  wire                game_display_inst_vga_vSync;
  wire                game_display_inst_vga_hSync;
  wire                game_display_inst_vga_colorEn;
  wire       [3:0]    game_display_inst_vga_color_r;
  wire       [3:0]    game_display_inst_vga_color_g;
  wire       [3:0]    game_display_inst_vga_color_b;
  wire                game_display_inst_draw_done;
  wire                game_display_inst_draw_field_done;
  wire                game_display_inst_screen_is_ready;
  wire                game_display_inst_sof;

  logic_top game_logic_inst (
    .game_start      (game_start                          ), //i
    .move_left       (move_left                           ), //i
    .move_right      (move_right                          ), //i
    .move_down       (move_down                           ), //i
    .rotate          (rotate                              ), //i
    .row_val_valid   (game_logic_inst_row_val_valid       ), //o
    .row_val_payload (game_logic_inst_row_val_payload[9:0]), //o
    .draw_field_done (game_display_inst_draw_field_done   ), //i
    .screen_is_ready (game_display_inst_screen_is_ready   ), //i
    .vga_sof         (game_display_inst_sof               ), //i
    .ctrl_allowed    (game_logic_inst_ctrl_allowed        ), //o
    .softReset       (game_logic_inst_softReset           ), //o
    .game_restart    (game_logic_inst_game_restart        ), //o
    .core_clk        (core_clk                            ), //i
    .core_rst        (core_rst                            )  //i
  );
  display_top game_display_inst (
    .vga_vSync       (game_display_inst_vga_vSync         ), //o
    .vga_hSync       (game_display_inst_vga_hSync         ), //o
    .vga_colorEn     (game_display_inst_vga_colorEn       ), //o
    .vga_color_r     (game_display_inst_vga_color_r[3:0]  ), //o
    .vga_color_g     (game_display_inst_vga_color_g[3:0]  ), //o
    .vga_color_b     (game_display_inst_vga_color_b[3:0]  ), //o
    .softRest        (game_logic_inst_softReset           ), //i
    .core_clk        (core_clk                            ), //i
    .core_rst        (core_rst                            ), //i
    .vga_clk         (vga_clk                             ), //i
    .vga_rst         (vga_rst                             ), //i
    .row_val_valid   (game_logic_inst_row_val_valid       ), //i
    .row_val_payload (game_logic_inst_row_val_payload[9:0]), //i
    .game_start      (game_start                          ), //i
    .game_restart    (game_logic_inst_game_restart        ), //i
    .draw_done       (game_display_inst_draw_done         ), //o
    .draw_field_done (game_display_inst_draw_field_done   ), //o
    .screen_is_ready (game_display_inst_screen_is_ready   ), //o
    .sof             (game_display_inst_sof               )  //o
  );
  assign ctrl_allowed = game_logic_inst_ctrl_allowed;
  assign vga_vSync = game_display_inst_vga_vSync;
  assign vga_hSync = game_display_inst_vga_hSync;
  assign vga_colorEn = game_display_inst_vga_colorEn;
  assign vga_color_r = game_display_inst_vga_color_r;
  assign vga_color_g = game_display_inst_vga_color_g;
  assign vga_color_b = game_display_inst_vga_color_b;

endmodule

module display_top (
  output wire          vga_vSync,
  output wire          vga_hSync,
  output wire          vga_colorEn,
  output reg  [3:0]    vga_color_r,
  output reg  [3:0]    vga_color_g,
  output reg  [3:0]    vga_color_b,
  input  wire          softRest,
  input  wire          core_clk,
  input  wire          core_rst,
  input  wire          vga_clk,
  input  wire          vga_rst,
  input  wire          row_val_valid,
  input  wire [9:0]    row_val_payload,
  input  wire          game_start,
  input  wire          game_restart,
  output wire          draw_done,
  output wire          draw_field_done,
  output wire          screen_is_ready,
  output wire          sof
);

  wire                fb_wr_en;
  reg        [3:0]    fb_wr_data;
  wire                fb_addr_gen_inst_start;
  wire       [3:0]    lbcp_io_addr;
  wire       [3:0]    fb_rd_data;
  wire                fb_clear_done;
  wire       [8:0]    draw_char_engine_1_h_cnt;
  wire       [7:0]    draw_char_engine_1_v_cnt;
  wire                draw_char_engine_1_is_running;
  wire                draw_char_engine_1_out_valid;
  wire       [3:0]    draw_char_engine_1_out_color;
  wire                draw_char_engine_1_done;
  wire       [8:0]    draw_block_engine_1_h_cnt;
  wire       [7:0]    draw_block_engine_1_v_cnt;
  wire                draw_block_engine_1_is_running;
  wire                draw_block_engine_1_out_valid;
  wire       [3:0]    draw_block_engine_1_out_color;
  wire                draw_block_engine_1_done;
  wire       [16:0]   fb_addr_gen_inst_out_addr;
  wire                draw_controller_screen_is_ready;
  wire                draw_controller_draw_char_start;
  wire       [6:0]    draw_controller_draw_char_word;
  wire       [2:0]    draw_controller_draw_char_scale;
  wire       [3:0]    draw_controller_draw_char_color;
  wire                draw_controller_draw_block_start;
  wire       [7:0]    draw_controller_draw_block_width;
  wire       [7:0]    draw_controller_draw_block_height;
  wire       [3:0]    draw_controller_draw_block_in_color;
  wire       [3:0]    draw_controller_draw_block_pat_color;
  wire       [1:0]    draw_controller_draw_block_fill_pattern;
  wire       [8:0]    draw_controller_draw_x_orig;
  wire       [7:0]    draw_controller_draw_y_orig;
  wire                draw_controller_draw_field_done;
  wire                draw_controller_bf_clear_start;
  wire                vga_sync_io_sof;
  wire                vga_sync_io_sol;
  wire                vga_sync_io_sos;
  wire                vga_sync_io_hSync;
  wire                vga_sync_io_vSync;
  wire                vga_sync_io_colorEn;
  wire                vga_sync_io_vColorEn;
  wire       [9:0]    vga_sync_io_x;
  wire       [9:0]    vga_sync_io_y;
  wire                lbcp_io_color_valid;
  wire       [11:0]   lbcp_io_color_payload;
  wire                lb_rd_out_valid;
  wire       [3:0]    lb_rd_out_payload;
  wire                softRest_buffercc_io_dataOut;
  wire                vga_sync_io_sos_buffercc_io_dataOut;
  wire                vga_sync_io_sof_buffercc_io_dataOut;
  wire                lb_load_valid_buffercc_io_dataOut;
  wire       [4:0]    temp_temp_rd_start_1;
  wire       [0:0]    temp_temp_rd_start_1_1;
  wire       [8:0]    temp_dma_fb_fetch_en_cnt_valueNext;
  wire       [0:0]    temp_dma_fb_fetch_en_cnt_valueNext_1;
  wire       [16:0]   temp_dma_fb_fetch_addr_valueNext;
  wire       [0:0]    temp_dma_fb_fetch_addr_valueNext_1;
  wire       [1:0]    mux_sel;
  reg        [8:0]    temp_h_cnt;
  reg        [7:0]    temp_v_cnt;
  reg                 temp_draw_done;
  reg                 vga_sync_io_colorEn_regNext;
  reg                 fb_scale_cnt_willIncrement;
  wire                fb_scale_cnt_willClear;
  reg        [0:0]    fb_scale_cnt_valueNext;
  reg        [0:0]    fb_scale_cnt_value;
  wire                fb_scale_cnt_willOverflowIfInc;
  wire                fb_scale_cnt_willOverflow;
  wire                lb_load_valid;
  reg                 temp_1;
  reg                 temp_rd_start;
  reg        [4:0]    temp_rd_start_1;
  reg        [4:0]    temp_rd_start_2;
  wire                temp_rd_start_3;
  wire                temp_rd_start_4;
  reg                 vga_sync_io_hSync_delay_1;
  reg                 vga_sync_io_hSync_delay_2;
  reg                 vga_sync_io_vSync_delay_1;
  reg                 vga_sync_io_vSync_delay_2;
  reg                 vga_sync_io_colorEn_delay_1;
  reg                 vga_sync_io_colorEn_delay_2;
  reg                 is_bg_color;
  wire                pixel_debug_valid;
  wire       [3:0]    pixel_debug_payload_r;
  wire       [3:0]    pixel_debug_payload_g;
  wire       [3:0]    pixel_debug_payload_b;
  wire                temp_dma_sos;
  reg                 temp_dma_sos_1;
  wire                dma_sos;
  wire                dma_sof;
  wire                dma_row_valid;
  reg                 dma_fb_fetch_en;
  reg                 dma_fb_fetch_en_cnt_willIncrement;
  reg                 dma_fb_fetch_en_cnt_willClear;
  reg        [8:0]    dma_fb_fetch_en_cnt_valueNext;
  reg        [8:0]    dma_fb_fetch_en_cnt_value;
  wire                dma_fb_fetch_en_cnt_willOverflowIfInc;
  wire                dma_fb_fetch_en_cnt_willOverflow;
  reg                 dma_fb_fetch_addr_willIncrement;
  reg                 dma_fb_fetch_addr_willClear;
  reg        [16:0]   dma_fb_fetch_addr_valueNext;
  reg        [16:0]   dma_fb_fetch_addr_value;
  wire                dma_fb_fetch_addr_willOverflowIfInc;
  wire                dma_fb_fetch_addr_willOverflow;
  wire                dma_lb_wr_valid;
  wire       [3:0]    dma_lb_wr_payload;
  reg                 dma_fb_fetch_en_regNext;

  assign temp_temp_rd_start_1_1 = temp_rd_start;
  assign temp_temp_rd_start_1 = {4'd0, temp_temp_rd_start_1_1};
  assign temp_dma_fb_fetch_en_cnt_valueNext_1 = dma_fb_fetch_en_cnt_willIncrement;
  assign temp_dma_fb_fetch_en_cnt_valueNext = {8'd0, temp_dma_fb_fetch_en_cnt_valueNext_1};
  assign temp_dma_fb_fetch_addr_valueNext_1 = dma_fb_fetch_addr_willIncrement;
  assign temp_dma_fb_fetch_addr_valueNext = {16'd0, temp_dma_fb_fetch_addr_valueNext_1};
  bram_2p fb (
    .wr_en       (fb_wr_en                       ), //i
    .wr_addr     (fb_addr_gen_inst_out_addr[16:0]), //i
    .wr_data     (fb_wr_data[3:0]                ), //i
    .rd_en       (dma_fb_fetch_en                ), //i
    .rd_addr     (dma_fb_fetch_addr_value[16:0]  ), //i
    .rd_data     (fb_rd_data[3:0]                ), //o
    .clear_start (draw_controller_bf_clear_start ), //i
    .clear_done  (fb_clear_done                  ), //o
    .core_clk    (core_clk                       ), //i
    .core_rst    (core_rst                       )  //i
  );
  draw_char_engine draw_char_engine_1 (
    .start      (draw_controller_draw_char_start     ), //i
    .word       (draw_controller_draw_char_word[6:0] ), //i
    .color      (draw_controller_draw_char_color[3:0]), //i
    .scale      (draw_controller_draw_char_scale[2:0]), //i
    .h_cnt      (draw_char_engine_1_h_cnt[8:0]       ), //o
    .v_cnt      (draw_char_engine_1_v_cnt[7:0]       ), //o
    .is_running (draw_char_engine_1_is_running       ), //o
    .out_valid  (draw_char_engine_1_out_valid        ), //o
    .out_color  (draw_char_engine_1_out_color[3:0]   ), //o
    .done       (draw_char_engine_1_done             ), //o
    .core_clk   (core_clk                            ), //i
    .core_rst   (core_rst                            )  //i
  );
  draw_block_engine draw_block_engine_1 (
    .start        (draw_controller_draw_block_start            ), //i
    .width        (draw_controller_draw_block_width[7:0]       ), //i
    .height       (draw_controller_draw_block_height[7:0]      ), //i
    .in_color     (draw_controller_draw_block_in_color[3:0]    ), //i
    .pat_color    (draw_controller_draw_block_pat_color[3:0]   ), //i
    .fill_pattern (draw_controller_draw_block_fill_pattern[1:0]), //i
    .h_cnt        (draw_block_engine_1_h_cnt[8:0]              ), //o
    .v_cnt        (draw_block_engine_1_v_cnt[7:0]              ), //o
    .is_running   (draw_block_engine_1_is_running              ), //o
    .out_valid    (draw_block_engine_1_out_valid               ), //o
    .out_color    (draw_block_engine_1_out_color[3:0]          ), //o
    .done         (draw_block_engine_1_done                    ), //o
    .core_clk     (core_clk                                    ), //i
    .core_rst     (core_rst                                    )  //i
  );
  fb_addr_gen fb_addr_gen_inst (
    .x        (draw_controller_draw_x_orig[8:0]), //i
    .y        (draw_controller_draw_y_orig[7:0]), //i
    .start    (fb_addr_gen_inst_start          ), //i
    .h_cnt    (temp_h_cnt[8:0]                 ), //i
    .v_cnt    (temp_v_cnt[7:0]                 ), //i
    .out_addr (fb_addr_gen_inst_out_addr[16:0] ), //o
    .core_clk (core_clk                        ), //i
    .core_rst (core_rst                        )  //i
  );
  display_controller draw_controller (
    .game_restart            (game_restart                                ), //i
    .draw_openning_start     (dma_sof                                     ), //i
    .game_start              (game_start                                  ), //i
    .row_val_valid           (row_val_valid                               ), //i
    .row_val_payload         (row_val_payload[9:0]                        ), //i
    .screen_is_ready         (draw_controller_screen_is_ready             ), //o
    .draw_char_start         (draw_controller_draw_char_start             ), //o
    .draw_char_word          (draw_controller_draw_char_word[6:0]         ), //o
    .draw_char_scale         (draw_controller_draw_char_scale[2:0]        ), //o
    .draw_char_color         (draw_controller_draw_char_color[3:0]        ), //o
    .draw_char_done          (draw_char_engine_1_done                     ), //i
    .draw_block_start        (draw_controller_draw_block_start            ), //o
    .draw_block_width        (draw_controller_draw_block_width[7:0]       ), //o
    .draw_block_height       (draw_controller_draw_block_height[7:0]      ), //o
    .draw_block_in_color     (draw_controller_draw_block_in_color[3:0]    ), //o
    .draw_block_pat_color    (draw_controller_draw_block_pat_color[3:0]   ), //o
    .draw_block_fill_pattern (draw_controller_draw_block_fill_pattern[1:0]), //o
    .draw_block_done         (draw_block_engine_1_done                    ), //i
    .draw_x_orig             (draw_controller_draw_x_orig[8:0]            ), //o
    .draw_y_orig             (draw_controller_draw_y_orig[7:0]            ), //o
    .draw_field_done         (draw_controller_draw_field_done             ), //o
    .bf_clear_start          (draw_controller_bf_clear_start              ), //o
    .bf_clear_done           (fb_clear_done                               ), //i
    .core_clk                (core_clk                                    ), //i
    .core_rst                (core_rst                                    )  //i
  );
  vga_sync_gen vga_sync (
    .io_softReset (softRest_buffercc_io_dataOut), //i
    .io_sof       (vga_sync_io_sof             ), //o
    .io_sol       (vga_sync_io_sol             ), //o
    .io_sos       (vga_sync_io_sos             ), //o
    .io_hSync     (vga_sync_io_hSync           ), //o
    .io_vSync     (vga_sync_io_vSync           ), //o
    .io_colorEn   (vga_sync_io_colorEn         ), //o
    .io_vColorEn  (vga_sync_io_vColorEn        ), //o
    .io_x         (vga_sync_io_x[9:0]          ), //o
    .io_y         (vga_sync_io_y[9:0]          ), //o
    .vga_clk      (vga_clk                     ), //i
    .vga_rst      (vga_rst                     )  //i
  );
  color_palettes lbcp (
    .io_addr          (lbcp_io_addr[3:0]          ), //i
    .io_rd_en         (lb_rd_out_valid            ), //i
    .io_color_valid   (lbcp_io_color_valid        ), //o
    .io_color_payload (lbcp_io_color_payload[11:0]), //o
    .vga_clk          (vga_clk                    ), //i
    .vga_rst          (vga_rst                    )  //i
  );
  linebuffer lb (
    .wr_in_valid    (dma_lb_wr_valid       ), //i
    .wr_in_payload  (dma_lb_wr_payload[3:0]), //i
    .rd_start       (temp_rd_start_4       ), //i
    .rd_out_valid   (lb_rd_out_valid       ), //o
    .rd_out_payload (lb_rd_out_payload[3:0]), //o
    .core_clk       (core_clk              ), //i
    .core_rst       (core_rst              ), //i
    .vga_clk        (vga_clk               ), //i
    .vga_rst        (vga_rst               )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC softRest_buffercc (
    .io_dataIn  (softRest                    ), //i
    .io_dataOut (softRest_buffercc_io_dataOut), //o
    .vga_clk    (vga_clk                     ), //i
    .vga_rst    (vga_rst                     )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC_1 vga_sync_io_sos_buffercc (
    .io_dataIn  (vga_sync_io_sos                    ), //i
    .io_dataOut (vga_sync_io_sos_buffercc_io_dataOut), //o
    .core_clk   (core_clk                           ), //i
    .core_rst   (core_rst                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC_1 vga_sync_io_sof_buffercc (
    .io_dataIn  (vga_sync_io_sof                    ), //i
    .io_dataOut (vga_sync_io_sof_buffercc_io_dataOut), //o
    .core_clk   (core_clk                           ), //i
    .core_rst   (core_rst                           )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC_1 lb_load_valid_buffercc (
    .io_dataIn  (lb_load_valid                    ), //i
    .io_dataOut (lb_load_valid_buffercc_io_dataOut), //o
    .core_clk   (core_clk                         ), //i
    .core_rst   (core_rst                         )  //i
  );
  assign draw_field_done = draw_controller_draw_field_done;
  assign mux_sel = {draw_char_engine_1_is_running,draw_block_engine_1_is_running};
  assign fb_addr_gen_inst_start = (draw_controller_draw_char_start || draw_controller_draw_block_start);
  always @(*) begin
    case(mux_sel)
      2'b01 : begin
        temp_h_cnt = draw_block_engine_1_h_cnt;
      end
      2'b10 : begin
        temp_h_cnt = draw_char_engine_1_h_cnt;
      end
      default : begin
        temp_h_cnt = 9'h0;
      end
    endcase
  end

  always @(*) begin
    case(mux_sel)
      2'b01 : begin
        temp_v_cnt = draw_block_engine_1_v_cnt;
      end
      2'b10 : begin
        temp_v_cnt = draw_char_engine_1_v_cnt;
      end
      default : begin
        temp_v_cnt = 8'h0;
      end
    endcase
  end

  assign fb_wr_en = (draw_char_engine_1_out_valid || draw_block_engine_1_out_valid);
  always @(*) begin
    if(draw_char_engine_1_out_valid) begin
      fb_wr_data = draw_char_engine_1_out_color;
    end else begin
      fb_wr_data = draw_block_engine_1_out_color;
    end
  end

  assign draw_done = temp_draw_done;
  assign screen_is_ready = draw_controller_screen_is_ready;
  always @(*) begin
    fb_scale_cnt_willIncrement = 1'b0;
    if(((! vga_sync_io_colorEn) && vga_sync_io_colorEn_regNext)) begin
      fb_scale_cnt_willIncrement = 1'b1;
    end
  end

  assign fb_scale_cnt_willClear = 1'b0;
  assign fb_scale_cnt_willOverflowIfInc = (fb_scale_cnt_value == 1'b1);
  assign fb_scale_cnt_willOverflow = (fb_scale_cnt_willOverflowIfInc && fb_scale_cnt_willIncrement);
  always @(*) begin
    fb_scale_cnt_valueNext = (fb_scale_cnt_value + fb_scale_cnt_willIncrement);
    if(fb_scale_cnt_willClear) begin
      fb_scale_cnt_valueNext = 1'b0;
    end
  end

  assign lb_load_valid = ((fb_scale_cnt_value == 1'b0) && vga_sync_io_vColorEn);
  always @(*) begin
    temp_rd_start = 1'b0;
    if(temp_1) begin
      temp_rd_start = 1'b1;
    end
  end

  assign temp_rd_start_3 = (temp_rd_start_2 == 5'h1f);
  assign temp_rd_start_4 = (temp_rd_start_3 && temp_rd_start);
  always @(*) begin
    temp_rd_start_1 = (temp_rd_start_2 + temp_temp_rd_start_1);
    if(1'b0) begin
      temp_rd_start_1 = 5'h0;
    end
  end

  assign lbcp_io_addr = lb_rd_out_payload;
  assign vga_hSync = vga_sync_io_hSync_delay_2;
  assign vga_vSync = vga_sync_io_vSync_delay_2;
  assign vga_colorEn = vga_sync_io_colorEn_delay_2;
  always @(*) begin
    if(lbcp_io_color_valid) begin
      if(is_bg_color) begin
        vga_color_b = 4'b0111;
        vga_color_g = 4'b0011;
        vga_color_r = 4'b0001;
      end else begin
        vga_color_b = lbcp_io_color_payload[3 : 0];
        vga_color_g = lbcp_io_color_payload[7 : 4];
        vga_color_r = lbcp_io_color_payload[11 : 8];
      end
    end else begin
      vga_color_b = 4'b0000;
      vga_color_g = 4'b0000;
      vga_color_r = 4'b0000;
    end
  end

  assign pixel_debug_valid = vga_colorEn;
  assign pixel_debug_payload_r = vga_color_r;
  assign pixel_debug_payload_g = vga_color_g;
  assign pixel_debug_payload_b = vga_color_b;
  assign temp_dma_sos = vga_sync_io_sos_buffercc_io_dataOut;
  assign dma_sos = (temp_dma_sos && (! temp_dma_sos_1));
  assign dma_sof = vga_sync_io_sof_buffercc_io_dataOut;
  assign dma_row_valid = lb_load_valid_buffercc_io_dataOut;
  always @(*) begin
    dma_fb_fetch_en_cnt_willIncrement = 1'b0;
    if(dma_fb_fetch_en) begin
      dma_fb_fetch_en_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    dma_fb_fetch_en_cnt_willClear = 1'b0;
    if(dma_row_valid) begin
      if(dma_fb_fetch_en_cnt_willOverflowIfInc) begin
        dma_fb_fetch_en_cnt_willClear = 1'b1;
      end
    end
  end

  assign dma_fb_fetch_en_cnt_willOverflowIfInc = (dma_fb_fetch_en_cnt_value == 9'h11f);
  assign dma_fb_fetch_en_cnt_willOverflow = (dma_fb_fetch_en_cnt_willOverflowIfInc && dma_fb_fetch_en_cnt_willIncrement);
  always @(*) begin
    if(dma_fb_fetch_en_cnt_willOverflow) begin
      dma_fb_fetch_en_cnt_valueNext = 9'h0;
    end else begin
      dma_fb_fetch_en_cnt_valueNext = (dma_fb_fetch_en_cnt_value + temp_dma_fb_fetch_en_cnt_valueNext);
    end
    if(dma_fb_fetch_en_cnt_willClear) begin
      dma_fb_fetch_en_cnt_valueNext = 9'h0;
    end
  end

  always @(*) begin
    dma_fb_fetch_addr_willIncrement = 1'b0;
    if(dma_fb_fetch_en) begin
      dma_fb_fetch_addr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    dma_fb_fetch_addr_willClear = 1'b0;
    if(dma_sof) begin
      dma_fb_fetch_addr_willClear = 1'b1;
    end
  end

  assign dma_fb_fetch_addr_willOverflowIfInc = (dma_fb_fetch_addr_value == 17'h10dff);
  assign dma_fb_fetch_addr_willOverflow = (dma_fb_fetch_addr_willOverflowIfInc && dma_fb_fetch_addr_willIncrement);
  always @(*) begin
    if(dma_fb_fetch_addr_willOverflow) begin
      dma_fb_fetch_addr_valueNext = 17'h0;
    end else begin
      dma_fb_fetch_addr_valueNext = (dma_fb_fetch_addr_value + temp_dma_fb_fetch_addr_valueNext);
    end
    if(dma_fb_fetch_addr_willClear) begin
      dma_fb_fetch_addr_valueNext = 17'h0;
    end
  end

  assign dma_lb_wr_valid = dma_fb_fetch_en_regNext;
  assign dma_lb_wr_payload = fb_rd_data;
  assign sof = dma_sof;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      temp_draw_done <= 1'b0;
      temp_dma_sos_1 <= 1'b0;
      dma_fb_fetch_en <= 1'b0;
      dma_fb_fetch_en_cnt_value <= 9'h0;
      dma_fb_fetch_addr_value <= 17'h0;
      dma_fb_fetch_en_regNext <= 1'b0;
    end else begin
      temp_draw_done <= (draw_char_engine_1_done || draw_block_engine_1_done);
      temp_dma_sos_1 <= temp_dma_sos;
      dma_fb_fetch_en_cnt_value <= dma_fb_fetch_en_cnt_valueNext;
      dma_fb_fetch_addr_value <= dma_fb_fetch_addr_valueNext;
      if(dma_row_valid) begin
        if(dma_sos) begin
          dma_fb_fetch_en <= 1'b1;
        end
        if(dma_fb_fetch_en_cnt_willOverflowIfInc) begin
          dma_fb_fetch_en <= 1'b0;
        end
      end
      dma_fb_fetch_en_regNext <= dma_fb_fetch_en;
    end
  end

  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      vga_sync_io_colorEn_regNext <= 1'b0;
      fb_scale_cnt_value <= 1'b0;
      temp_1 <= 1'b0;
      temp_rd_start_2 <= 5'h0;
      is_bg_color <= 1'b0;
    end else begin
      vga_sync_io_colorEn_regNext <= vga_sync_io_colorEn;
      fb_scale_cnt_value <= fb_scale_cnt_valueNext;
      temp_rd_start_2 <= temp_rd_start_1;
      if(vga_sync_io_sol) begin
        temp_1 <= 1'b1;
      end
      if(temp_rd_start_3) begin
        temp_1 <= 1'b0;
      end
      is_bg_color <= (lb_rd_out_payload == 4'b0010);
    end
  end

  always @(posedge vga_clk) begin
    vga_sync_io_hSync_delay_1 <= vga_sync_io_hSync;
    vga_sync_io_hSync_delay_2 <= vga_sync_io_hSync_delay_1;
    vga_sync_io_vSync_delay_1 <= vga_sync_io_vSync;
    vga_sync_io_vSync_delay_2 <= vga_sync_io_vSync_delay_1;
    vga_sync_io_colorEn_delay_1 <= vga_sync_io_colorEn;
    vga_sync_io_colorEn_delay_2 <= vga_sync_io_colorEn_delay_1;
  end


endmodule

module logic_top (
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  output wire          row_val_valid,
  output wire [9:0]    row_val_payload,
  input  wire          draw_field_done,
  input  wire          screen_is_ready,
  input  wire          vga_sof,
  output wire          ctrl_allowed,
  output reg           softReset,
  output reg           game_restart,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;
  localparam STANDBY = 4'd0;
  localparam MOVE = 4'd1;
  localparam CHECK = 4'd2;
  localparam ERASE = 4'd3;
  localparam UPDATE = 4'd4;
  localparam START_REFRESH = 4'd5;
  localparam WAIT_FRESH_DONE = 4'd6;
  localparam STATUS = 4'd7;
  localparam FREEZE_CTRL = 4'd8;
  localparam IDLE = 4'd0;
  localparam GAME_START = 4'd1;
  localparam RANDOM_GEN = 4'd2;
  localparam PLACE = 4'd3;
  localparam END_1 = 4'd4;
  localparam FALLING = 4'd5;
  localparam LOCK = 4'd6;
  localparam LOCKDOWN = 4'd7;
  localparam PATTERN = 4'd8;

  reg                 play_field_1_fetch;
  wire                piece_gen_io_shape_valid;
  wire       [2:0]    piece_gen_io_shape_payload;
  wire                picoller_inst_piece_in_ready;
  wire                picoller_inst_collision_out_valid;
  wire                picoller_inst_collision_out_payload;
  wire                picoller_inst_block_pos_valid;
  wire       [3:0]    picoller_inst_block_pos_payload_x;
  wire       [4:0]    picoller_inst_block_pos_payload_y;
  wire                play_field_1_clear_done;
  wire                play_field_1_block_val_valid;
  wire                play_field_1_block_val_payload;
  wire                play_field_1_row_val_valid;
  wire       [9:0]    play_field_1_row_val_payload;
  wire                play_field_1_lines_cleared_valid;
  wire       [4:0]    play_field_1_lines_cleared_payload;
  wire       [5:0]    temp_freeze_ctrl_cnt_valueNext;
  wire       [0:0]    temp_freeze_ctrl_cnt_valueNext_1;
  wire       [24:0]   temp_main_fsm_drop_timeout_counter_valueNext;
  wire       [0:0]    temp_main_fsm_drop_timeout_counter_valueNext_1;
  wire       [24:0]   temp_main_fsm_lock_timeout_counter_valueNext;
  wire       [0:0]    temp_main_fsm_lock_timeout_counter_valueNext_1;
  wire       [7:0]    temp_score_total_score;
  wire                temp_when;
  wire                temp_when_1;
  wire                temp_when_2;
  wire                temp_when_3;
  wire                piece_req_valid;
  wire                piece_req_ready;
  reg        [3:0]    piece_req_payload_orign_x;
  reg        [4:0]    piece_req_payload_orign_y;
  wire       [2:0]    piece_req_payload_type;
  reg        [1:0]    piece_req_payload_rot;
  reg                 update;
  reg                 block_set;
  reg                 clear_start;
  reg                 restart;
  wire                collision_in_valid;
  wire                collision_in_payload;
  reg                 lines_cleared_num_valid;
  reg        [4:0]    lines_cleared_num_payload;
  reg        [4:0]    id_debug;
  reg                 gen_piece_en;
  reg                 block_skip_en;
  wire       [3:0]    start_x;
  wire       [4:0]    start_y;
  reg        [3:0]    pos_x_cur;
  reg        [4:0]    pos_y_cur;
  reg        [1:0]    rot_cur;
  reg        [2:0]    shape_cur;
  reg                 req_valid;
  reg        [3:0]    pos_x_chk;
  reg        [4:0]    pos_y_chk;
  reg        [1:0]    rot_chk;
  reg        [2:0]    shape_chk;
  reg                 move_en;
  reg                 ctrl_en;
  reg                 drop_down;
  reg                 place_en;
  reg                 playfield_fsm_result;
  reg                 playfield_fsm_reset;
  wire                fsm_is_place;
  reg                 freeze_ctrl_cnt_willIncrement;
  reg                 freeze_ctrl_cnt_willClear;
  reg        [5:0]    freeze_ctrl_cnt_valueNext;
  reg        [5:0]    freeze_ctrl_cnt_value;
  wire                freeze_ctrl_cnt_willOverflowIfInc;
  wire                freeze_ctrl_cnt_willOverflow;
  reg        [2:0]    debug_move_type;
  wire                playfield_fsm_wantExit;
  reg                 playfield_fsm_wantStart;
  wire                playfield_fsm_wantKill;
  wire                main_fsm_wantExit;
  reg                 main_fsm_wantStart;
  wire                main_fsm_wantKill;
  reg                 main_fsm_drop_timeout_state;
  reg                 main_fsm_drop_timeout_stateRise;
  wire                main_fsm_drop_timeout_counter_willIncrement;
  reg                 main_fsm_drop_timeout_counter_willClear;
  reg        [24:0]   main_fsm_drop_timeout_counter_valueNext;
  reg        [24:0]   main_fsm_drop_timeout_counter_value;
  wire                main_fsm_drop_timeout_counter_willOverflowIfInc;
  wire                main_fsm_drop_timeout_counter_willOverflow;
  reg                 main_fsm_lock_timeout_state;
  reg                 main_fsm_lock_timeout_stateRise;
  wire                main_fsm_lock_timeout_counter_willIncrement;
  reg                 main_fsm_lock_timeout_counter_willClear;
  reg        [24:0]   main_fsm_lock_timeout_counter_valueNext;
  reg        [24:0]   main_fsm_lock_timeout_counter_value;
  wire                main_fsm_lock_timeout_counter_willOverflowIfInc;
  wire                main_fsm_lock_timeout_counter_willOverflow;
  wire       [3:0]    main_fsm_debug;
  wire       [3:0]    playfield_fsm_debug;
  reg        [7:0]    score_total_score;
  reg        [2:0]    score_score_with_bonus;
  reg        [3:0]    playfield_fsm_stateReg;
  reg        [3:0]    playfield_fsm_stateNext;
  wire                playfield_fsm_onExit_STANDBY;
  wire                playfield_fsm_onExit_MOVE;
  wire                playfield_fsm_onExit_CHECK;
  wire                playfield_fsm_onExit_ERASE;
  wire                playfield_fsm_onExit_UPDATE;
  wire                playfield_fsm_onExit_START_REFRESH;
  wire                playfield_fsm_onExit_WAIT_FRESH_DONE;
  wire                playfield_fsm_onExit_STATUS;
  wire                playfield_fsm_onExit_FREEZE_CTRL;
  wire                playfield_fsm_onEntry_STANDBY;
  wire                playfield_fsm_onEntry_MOVE;
  wire                playfield_fsm_onEntry_CHECK;
  wire                playfield_fsm_onEntry_ERASE;
  wire                playfield_fsm_onEntry_UPDATE;
  wire                playfield_fsm_onEntry_START_REFRESH;
  wire                playfield_fsm_onEntry_WAIT_FRESH_DONE;
  wire                playfield_fsm_onEntry_STATUS;
  wire                playfield_fsm_onEntry_FREEZE_CTRL;
  reg        [3:0]    main_fsm_stateReg;
  reg        [3:0]    main_fsm_stateNext;
  wire                main_fsm_onExit_IDLE;
  wire                main_fsm_onExit_GAME_START;
  wire                main_fsm_onExit_RANDOM_GEN;
  wire       [2:0]    temp_shape_cur;
  wire                main_fsm_onExit_PLACE;
  wire                main_fsm_onExit_END_1;
  wire                main_fsm_onExit_FALLING;
  wire                main_fsm_onExit_LOCK;
  wire                main_fsm_onExit_LOCKDOWN;
  wire                main_fsm_onExit_PATTERN;
  wire                main_fsm_onEntry_IDLE;
  wire                main_fsm_onEntry_GAME_START;
  wire                main_fsm_onEntry_RANDOM_GEN;
  wire                main_fsm_onEntry_PLACE;
  wire                main_fsm_onEntry_END_1;
  wire                main_fsm_onEntry_FALLING;
  wire                main_fsm_onEntry_LOCK;
  wire                main_fsm_onEntry_LOCKDOWN;
  wire                main_fsm_onEntry_PATTERN;
  `ifndef SYNTHESIS
  reg [7:0] piece_req_payload_type_string;
  reg [7:0] shape_cur_string;
  reg [7:0] shape_chk_string;
  reg [119:0] playfield_fsm_stateReg_string;
  reg [119:0] playfield_fsm_stateNext_string;
  reg [79:0] main_fsm_stateReg_string;
  reg [79:0] main_fsm_stateNext_string;
  reg [7:0] temp_shape_cur_string;
  `endif


  assign temp_when = (ctrl_en && move_left);
  assign temp_when_1 = (ctrl_en && move_right);
  assign temp_when_2 = (ctrl_en && rotate);
  assign temp_when_3 = ((ctrl_en && move_down) || drop_down);
  assign temp_freeze_ctrl_cnt_valueNext_1 = freeze_ctrl_cnt_willIncrement;
  assign temp_freeze_ctrl_cnt_valueNext = {5'd0, temp_freeze_ctrl_cnt_valueNext_1};
  assign temp_main_fsm_drop_timeout_counter_valueNext_1 = main_fsm_drop_timeout_counter_willIncrement;
  assign temp_main_fsm_drop_timeout_counter_valueNext = {24'd0, temp_main_fsm_drop_timeout_counter_valueNext_1};
  assign temp_main_fsm_lock_timeout_counter_valueNext_1 = main_fsm_lock_timeout_counter_willIncrement;
  assign temp_main_fsm_lock_timeout_counter_valueNext = {24'd0, temp_main_fsm_lock_timeout_counter_valueNext_1};
  assign temp_score_total_score = {5'd0, score_score_with_bonus};
  seven_bag_rng piece_gen (
    .io_enable        (gen_piece_en                   ), //i
    .io_shape_valid   (piece_gen_io_shape_valid       ), //o
    .io_shape_payload (piece_gen_io_shape_payload[2:0]), //o
    .core_clk         (core_clk                       ), //i
    .core_rst         (core_rst                       )  //i
  );
  picoller picoller_inst (
    .piece_in_valid           (piece_req_valid                       ), //i
    .piece_in_ready           (picoller_inst_piece_in_ready          ), //o
    .piece_in_payload_orign_x (piece_req_payload_orign_x[3:0]        ), //i
    .piece_in_payload_orign_y (piece_req_payload_orign_y[4:0]        ), //i
    .piece_in_payload_type    (piece_req_payload_type[2:0]           ), //i
    .piece_in_payload_rot     (piece_req_payload_rot[1:0]            ), //i
    .collision_out_valid      (picoller_inst_collision_out_valid     ), //o
    .collision_out_payload    (picoller_inst_collision_out_payload   ), //o
    .update                   (update                                ), //i
    .block_set                (block_set                             ), //i
    .block_skip_en            (block_skip_en                         ), //i
    .block_pos_valid          (picoller_inst_block_pos_valid         ), //o
    .block_pos_payload_x      (picoller_inst_block_pos_payload_x[3:0]), //o
    .block_pos_payload_y      (picoller_inst_block_pos_payload_y[4:0]), //o
    .block_val_valid          (play_field_1_block_val_valid          ), //i
    .block_val_payload        (play_field_1_block_val_payload        ), //i
    .core_clk                 (core_clk                              ), //i
    .core_rst                 (core_rst                              )  //i
  );
  play_field play_field_1 (
    .block_pos_valid       (picoller_inst_block_pos_valid          ), //i
    .block_pos_payload_x   (picoller_inst_block_pos_payload_x[3:0] ), //i
    .block_pos_payload_y   (picoller_inst_block_pos_payload_y[4:0] ), //i
    .update                (update                                 ), //i
    .clear_start           (clear_start                            ), //i
    .block_set             (block_set                              ), //i
    .restart               (restart                                ), //i
    .fetch                 (play_field_1_fetch                     ), //i
    .clear_done            (play_field_1_clear_done                ), //o
    .block_val_valid       (play_field_1_block_val_valid           ), //o
    .block_val_payload     (play_field_1_block_val_payload         ), //o
    .row_val_valid         (play_field_1_row_val_valid             ), //o
    .row_val_payload       (play_field_1_row_val_payload[9:0]      ), //o
    .lines_cleared_valid   (play_field_1_lines_cleared_valid       ), //o
    .lines_cleared_payload (play_field_1_lines_cleared_payload[4:0]), //o
    .core_clk              (core_clk                               ), //i
    .core_rst              (core_rst                               )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_req_payload_type)
      I : piece_req_payload_type_string = "I";
      J : piece_req_payload_type_string = "J";
      L : piece_req_payload_type_string = "L";
      O : piece_req_payload_type_string = "O";
      S : piece_req_payload_type_string = "S";
      T : piece_req_payload_type_string = "T";
      Z : piece_req_payload_type_string = "Z";
      default : piece_req_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(shape_cur)
      I : shape_cur_string = "I";
      J : shape_cur_string = "J";
      L : shape_cur_string = "L";
      O : shape_cur_string = "O";
      S : shape_cur_string = "S";
      T : shape_cur_string = "T";
      Z : shape_cur_string = "Z";
      default : shape_cur_string = "?";
    endcase
  end
  always @(*) begin
    case(shape_chk)
      I : shape_chk_string = "I";
      J : shape_chk_string = "J";
      L : shape_chk_string = "L";
      O : shape_chk_string = "O";
      S : shape_chk_string = "S";
      T : shape_chk_string = "T";
      Z : shape_chk_string = "Z";
      default : shape_chk_string = "?";
    endcase
  end
  always @(*) begin
    case(playfield_fsm_stateReg)
      STANDBY : playfield_fsm_stateReg_string = "STANDBY        ";
      MOVE : playfield_fsm_stateReg_string = "MOVE           ";
      CHECK : playfield_fsm_stateReg_string = "CHECK          ";
      ERASE : playfield_fsm_stateReg_string = "ERASE          ";
      UPDATE : playfield_fsm_stateReg_string = "UPDATE         ";
      START_REFRESH : playfield_fsm_stateReg_string = "START_REFRESH  ";
      WAIT_FRESH_DONE : playfield_fsm_stateReg_string = "WAIT_FRESH_DONE";
      STATUS : playfield_fsm_stateReg_string = "STATUS         ";
      FREEZE_CTRL : playfield_fsm_stateReg_string = "FREEZE_CTRL    ";
      default : playfield_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(playfield_fsm_stateNext)
      STANDBY : playfield_fsm_stateNext_string = "STANDBY        ";
      MOVE : playfield_fsm_stateNext_string = "MOVE           ";
      CHECK : playfield_fsm_stateNext_string = "CHECK          ";
      ERASE : playfield_fsm_stateNext_string = "ERASE          ";
      UPDATE : playfield_fsm_stateNext_string = "UPDATE         ";
      START_REFRESH : playfield_fsm_stateNext_string = "START_REFRESH  ";
      WAIT_FRESH_DONE : playfield_fsm_stateNext_string = "WAIT_FRESH_DONE";
      STATUS : playfield_fsm_stateNext_string = "STATUS         ";
      FREEZE_CTRL : playfield_fsm_stateNext_string = "FREEZE_CTRL    ";
      default : playfield_fsm_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateReg)
      IDLE : main_fsm_stateReg_string = "IDLE      ";
      GAME_START : main_fsm_stateReg_string = "GAME_START";
      RANDOM_GEN : main_fsm_stateReg_string = "RANDOM_GEN";
      PLACE : main_fsm_stateReg_string = "PLACE     ";
      END_1 : main_fsm_stateReg_string = "END_1     ";
      FALLING : main_fsm_stateReg_string = "FALLING   ";
      LOCK : main_fsm_stateReg_string = "LOCK      ";
      LOCKDOWN : main_fsm_stateReg_string = "LOCKDOWN  ";
      PATTERN : main_fsm_stateReg_string = "PATTERN   ";
      default : main_fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateNext)
      IDLE : main_fsm_stateNext_string = "IDLE      ";
      GAME_START : main_fsm_stateNext_string = "GAME_START";
      RANDOM_GEN : main_fsm_stateNext_string = "RANDOM_GEN";
      PLACE : main_fsm_stateNext_string = "PLACE     ";
      END_1 : main_fsm_stateNext_string = "END_1     ";
      FALLING : main_fsm_stateNext_string = "FALLING   ";
      LOCK : main_fsm_stateNext_string = "LOCK      ";
      LOCKDOWN : main_fsm_stateNext_string = "LOCKDOWN  ";
      PATTERN : main_fsm_stateNext_string = "PATTERN   ";
      default : main_fsm_stateNext_string = "??????????";
    endcase
  end
  always @(*) begin
    case(temp_shape_cur)
      I : temp_shape_cur_string = "I";
      J : temp_shape_cur_string = "J";
      L : temp_shape_cur_string = "L";
      O : temp_shape_cur_string = "O";
      S : temp_shape_cur_string = "S";
      T : temp_shape_cur_string = "T";
      Z : temp_shape_cur_string = "Z";
      default : temp_shape_cur_string = "?";
    endcase
  end
  `endif

  assign piece_req_ready = picoller_inst_piece_in_ready;
  assign collision_in_valid = picoller_inst_collision_out_valid;
  assign collision_in_payload = picoller_inst_collision_out_payload;
  assign row_val_valid = play_field_1_row_val_valid;
  assign row_val_payload = play_field_1_row_val_payload;
  assign start_x = 4'b0101;
  assign start_y = 5'h0;
  always @(*) begin
    piece_req_payload_orign_x = pos_x_cur;
    piece_req_payload_orign_y = pos_y_cur;
    piece_req_payload_rot = rot_cur;
    playfield_fsm_wantStart = 1'b0;
    play_field_1_fetch = 1'b0;
    playfield_fsm_stateNext = playfield_fsm_stateReg;
    case(playfield_fsm_stateReg)
      MOVE : begin
        if(temp_when) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(temp_when_1) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(temp_when_2) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(temp_when_3) begin
          playfield_fsm_stateNext = CHECK;
        end
        if(place_en) begin
          playfield_fsm_stateNext = CHECK;
        end
      end
      CHECK : begin
        piece_req_payload_orign_x = pos_x_chk;
        piece_req_payload_orign_y = pos_y_chk;
        piece_req_payload_rot = rot_chk;
        if(collision_in_valid) begin
          if(collision_in_payload) begin
            playfield_fsm_stateNext = STATUS;
          end else begin
            if(fsm_is_place) begin
              playfield_fsm_stateNext = UPDATE;
            end else begin
              playfield_fsm_stateNext = ERASE;
            end
          end
        end
      end
      ERASE : begin
        if(collision_in_valid) begin
          playfield_fsm_stateNext = UPDATE;
        end
      end
      UPDATE : begin
        if(collision_in_valid) begin
          playfield_fsm_stateNext = START_REFRESH;
        end
      end
      START_REFRESH : begin
        if(vga_sof) begin
          play_field_1_fetch = 1'b1;
          playfield_fsm_stateNext = WAIT_FRESH_DONE;
        end
      end
      WAIT_FRESH_DONE : begin
        if(draw_field_done) begin
          playfield_fsm_stateNext = STATUS;
        end
      end
      STATUS : begin
        playfield_fsm_stateNext = FREEZE_CTRL;
      end
      FREEZE_CTRL : begin
        if(freeze_ctrl_cnt_willOverflow) begin
          playfield_fsm_stateNext = MOVE;
        end
      end
      default : begin
        if(move_en) begin
          playfield_fsm_stateNext = MOVE;
        end
        playfield_fsm_wantStart = 1'b1;
      end
    endcase
    if(playfield_fsm_wantKill) begin
      playfield_fsm_stateNext = STANDBY;
    end
  end

  assign piece_req_payload_type = shape_cur;
  assign piece_req_valid = req_valid;
  always @(*) begin
    freeze_ctrl_cnt_willIncrement = 1'b0;
    if(vga_sof) begin
      freeze_ctrl_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    freeze_ctrl_cnt_willClear = 1'b0;
    if(playfield_fsm_onEntry_FREEZE_CTRL) begin
      freeze_ctrl_cnt_willClear = 1'b1;
    end
  end

  assign freeze_ctrl_cnt_willOverflowIfInc = (freeze_ctrl_cnt_value == 6'h27);
  assign freeze_ctrl_cnt_willOverflow = (freeze_ctrl_cnt_willOverflowIfInc && freeze_ctrl_cnt_willIncrement);
  always @(*) begin
    if(freeze_ctrl_cnt_willOverflow) begin
      freeze_ctrl_cnt_valueNext = 6'h0;
    end else begin
      freeze_ctrl_cnt_valueNext = (freeze_ctrl_cnt_value + temp_freeze_ctrl_cnt_valueNext);
    end
    if(freeze_ctrl_cnt_willClear) begin
      freeze_ctrl_cnt_valueNext = 6'h0;
    end
  end

  assign playfield_fsm_wantExit = 1'b0;
  assign playfield_fsm_wantKill = 1'b0;
  assign ctrl_allowed = (playfield_fsm_stateReg == MOVE);
  always @(*) begin
    game_restart = 1'b0;
    main_fsm_wantStart = 1'b0;
    softReset = 1'b0;
    main_fsm_stateNext = main_fsm_stateReg;
    case(main_fsm_stateReg)
      GAME_START : begin
        if(screen_is_ready) begin
          main_fsm_stateNext = RANDOM_GEN;
        end
      end
      RANDOM_GEN : begin
        if(piece_gen_io_shape_valid) begin
          main_fsm_stateNext = PLACE;
        end
      end
      PLACE : begin
        if((playfield_fsm_stateReg == STATUS)) begin
          if(playfield_fsm_result) begin
            main_fsm_stateNext = FALLING;
          end else begin
            main_fsm_stateNext = END_1;
          end
        end
      end
      END_1 : begin
        softReset = 1'b1;
        game_restart = 1'b1;
        main_fsm_stateNext = IDLE;
      end
      FALLING : begin
        if((main_fsm_drop_timeout_state && (playfield_fsm_stateReg == MOVE))) begin
          main_fsm_stateNext = LOCK;
        end
      end
      LOCK : begin
        if((playfield_fsm_stateReg == STATUS)) begin
          if(playfield_fsm_result) begin
            main_fsm_stateNext = FALLING;
          end else begin
            main_fsm_stateNext = LOCKDOWN;
          end
        end
      end
      LOCKDOWN : begin
        if(main_fsm_lock_timeout_state) begin
          main_fsm_stateNext = PATTERN;
        end
      end
      PATTERN : begin
        if(play_field_1_clear_done) begin
          main_fsm_stateNext = RANDOM_GEN;
        end
      end
      default : begin
        if(game_start) begin
          main_fsm_stateNext = GAME_START;
        end
        main_fsm_wantStart = 1'b1;
      end
    endcase
    if(main_fsm_wantKill) begin
      main_fsm_stateNext = IDLE;
    end
  end

  assign main_fsm_wantExit = 1'b0;
  assign main_fsm_wantKill = 1'b0;
  always @(*) begin
    main_fsm_drop_timeout_stateRise = 1'b0;
    main_fsm_drop_timeout_counter_willClear = 1'b0;
    if(main_fsm_drop_timeout_counter_willOverflow) begin
      main_fsm_drop_timeout_stateRise = (! main_fsm_drop_timeout_state);
    end
    if(main_fsm_onEntry_FALLING) begin
      main_fsm_drop_timeout_counter_willClear = 1'b1;
      main_fsm_drop_timeout_stateRise = 1'b0;
    end
  end

  assign main_fsm_drop_timeout_counter_willOverflowIfInc = (main_fsm_drop_timeout_counter_value == 25'h168decf);
  assign main_fsm_drop_timeout_counter_willOverflow = (main_fsm_drop_timeout_counter_willOverflowIfInc && main_fsm_drop_timeout_counter_willIncrement);
  always @(*) begin
    if(main_fsm_drop_timeout_counter_willOverflow) begin
      main_fsm_drop_timeout_counter_valueNext = 25'h0;
    end else begin
      main_fsm_drop_timeout_counter_valueNext = (main_fsm_drop_timeout_counter_value + temp_main_fsm_drop_timeout_counter_valueNext);
    end
    if(main_fsm_drop_timeout_counter_willClear) begin
      main_fsm_drop_timeout_counter_valueNext = 25'h0;
    end
  end

  assign main_fsm_drop_timeout_counter_willIncrement = 1'b1;
  always @(*) begin
    main_fsm_lock_timeout_stateRise = 1'b0;
    main_fsm_lock_timeout_counter_willClear = 1'b0;
    if(main_fsm_lock_timeout_counter_willOverflow) begin
      main_fsm_lock_timeout_stateRise = (! main_fsm_lock_timeout_state);
    end
    if(main_fsm_onEntry_LOCKDOWN) begin
      main_fsm_lock_timeout_counter_willClear = 1'b1;
      main_fsm_lock_timeout_stateRise = 1'b0;
    end
  end

  assign main_fsm_lock_timeout_counter_willOverflowIfInc = (main_fsm_lock_timeout_counter_value == 25'h17d783f);
  assign main_fsm_lock_timeout_counter_willOverflow = (main_fsm_lock_timeout_counter_willOverflowIfInc && main_fsm_lock_timeout_counter_willIncrement);
  always @(*) begin
    if(main_fsm_lock_timeout_counter_willOverflow) begin
      main_fsm_lock_timeout_counter_valueNext = 25'h0;
    end else begin
      main_fsm_lock_timeout_counter_valueNext = (main_fsm_lock_timeout_counter_value + temp_main_fsm_lock_timeout_counter_valueNext);
    end
    if(main_fsm_lock_timeout_counter_willClear) begin
      main_fsm_lock_timeout_counter_valueNext = 25'h0;
    end
  end

  assign main_fsm_lock_timeout_counter_willIncrement = 1'b1;
  assign fsm_is_place = (main_fsm_stateReg == PLACE);
  always @(*) begin
    score_score_with_bonus = 3'b000;
    case(lines_cleared_num_payload)
      5'h01 : begin
        score_score_with_bonus = 3'b001;
      end
      5'h02 : begin
        score_score_with_bonus = 3'b010;
      end
      5'h03 : begin
        score_score_with_bonus = 3'b011;
      end
      5'h04 : begin
        score_score_with_bonus = 3'b100;
      end
      default : begin
      end
    endcase
  end

  assign playfield_fsm_onExit_STANDBY = ((playfield_fsm_stateNext != STANDBY) && (playfield_fsm_stateReg == STANDBY));
  assign playfield_fsm_onExit_MOVE = ((playfield_fsm_stateNext != MOVE) && (playfield_fsm_stateReg == MOVE));
  assign playfield_fsm_onExit_CHECK = ((playfield_fsm_stateNext != CHECK) && (playfield_fsm_stateReg == CHECK));
  assign playfield_fsm_onExit_ERASE = ((playfield_fsm_stateNext != ERASE) && (playfield_fsm_stateReg == ERASE));
  assign playfield_fsm_onExit_UPDATE = ((playfield_fsm_stateNext != UPDATE) && (playfield_fsm_stateReg == UPDATE));
  assign playfield_fsm_onExit_START_REFRESH = ((playfield_fsm_stateNext != START_REFRESH) && (playfield_fsm_stateReg == START_REFRESH));
  assign playfield_fsm_onExit_WAIT_FRESH_DONE = ((playfield_fsm_stateNext != WAIT_FRESH_DONE) && (playfield_fsm_stateReg == WAIT_FRESH_DONE));
  assign playfield_fsm_onExit_STATUS = ((playfield_fsm_stateNext != STATUS) && (playfield_fsm_stateReg == STATUS));
  assign playfield_fsm_onExit_FREEZE_CTRL = ((playfield_fsm_stateNext != FREEZE_CTRL) && (playfield_fsm_stateReg == FREEZE_CTRL));
  assign playfield_fsm_onEntry_STANDBY = ((playfield_fsm_stateNext == STANDBY) && (playfield_fsm_stateReg != STANDBY));
  assign playfield_fsm_onEntry_MOVE = ((playfield_fsm_stateNext == MOVE) && (playfield_fsm_stateReg != MOVE));
  assign playfield_fsm_onEntry_CHECK = ((playfield_fsm_stateNext == CHECK) && (playfield_fsm_stateReg != CHECK));
  assign playfield_fsm_onEntry_ERASE = ((playfield_fsm_stateNext == ERASE) && (playfield_fsm_stateReg != ERASE));
  assign playfield_fsm_onEntry_UPDATE = ((playfield_fsm_stateNext == UPDATE) && (playfield_fsm_stateReg != UPDATE));
  assign playfield_fsm_onEntry_START_REFRESH = ((playfield_fsm_stateNext == START_REFRESH) && (playfield_fsm_stateReg != START_REFRESH));
  assign playfield_fsm_onEntry_WAIT_FRESH_DONE = ((playfield_fsm_stateNext == WAIT_FRESH_DONE) && (playfield_fsm_stateReg != WAIT_FRESH_DONE));
  assign playfield_fsm_onEntry_STATUS = ((playfield_fsm_stateNext == STATUS) && (playfield_fsm_stateReg != STATUS));
  assign playfield_fsm_onEntry_FREEZE_CTRL = ((playfield_fsm_stateNext == FREEZE_CTRL) && (playfield_fsm_stateReg != FREEZE_CTRL));
  assign playfield_fsm_debug = playfield_fsm_stateReg;
  assign main_fsm_onExit_IDLE = ((main_fsm_stateNext != IDLE) && (main_fsm_stateReg == IDLE));
  assign main_fsm_onExit_GAME_START = ((main_fsm_stateNext != GAME_START) && (main_fsm_stateReg == GAME_START));
  assign main_fsm_onExit_RANDOM_GEN = ((main_fsm_stateNext != RANDOM_GEN) && (main_fsm_stateReg == RANDOM_GEN));
  assign temp_shape_cur = piece_gen_io_shape_payload;
  assign main_fsm_onExit_PLACE = ((main_fsm_stateNext != PLACE) && (main_fsm_stateReg == PLACE));
  assign main_fsm_onExit_END_1 = ((main_fsm_stateNext != END_1) && (main_fsm_stateReg == END_1));
  assign main_fsm_onExit_FALLING = ((main_fsm_stateNext != FALLING) && (main_fsm_stateReg == FALLING));
  assign main_fsm_onExit_LOCK = ((main_fsm_stateNext != LOCK) && (main_fsm_stateReg == LOCK));
  assign main_fsm_onExit_LOCKDOWN = ((main_fsm_stateNext != LOCKDOWN) && (main_fsm_stateReg == LOCKDOWN));
  assign main_fsm_onExit_PATTERN = ((main_fsm_stateNext != PATTERN) && (main_fsm_stateReg == PATTERN));
  assign main_fsm_onEntry_IDLE = ((main_fsm_stateNext == IDLE) && (main_fsm_stateReg != IDLE));
  assign main_fsm_onEntry_GAME_START = ((main_fsm_stateNext == GAME_START) && (main_fsm_stateReg != GAME_START));
  assign main_fsm_onEntry_RANDOM_GEN = ((main_fsm_stateNext == RANDOM_GEN) && (main_fsm_stateReg != RANDOM_GEN));
  assign main_fsm_onEntry_PLACE = ((main_fsm_stateNext == PLACE) && (main_fsm_stateReg != PLACE));
  assign main_fsm_onEntry_END_1 = ((main_fsm_stateNext == END_1) && (main_fsm_stateReg != END_1));
  assign main_fsm_onEntry_FALLING = ((main_fsm_stateNext == FALLING) && (main_fsm_stateReg != FALLING));
  assign main_fsm_onEntry_LOCK = ((main_fsm_stateNext == LOCK) && (main_fsm_stateReg != LOCK));
  assign main_fsm_onEntry_LOCKDOWN = ((main_fsm_stateNext == LOCKDOWN) && (main_fsm_stateReg != LOCKDOWN));
  assign main_fsm_onEntry_PATTERN = ((main_fsm_stateNext == PATTERN) && (main_fsm_stateReg != PATTERN));
  assign main_fsm_debug = main_fsm_stateReg;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      update <= 1'b0;
      block_set <= 1'b0;
      clear_start <= 1'b0;
      restart <= 1'b0;
      lines_cleared_num_valid <= 1'b0;
      id_debug <= 5'h0;
      gen_piece_en <= 1'b0;
      block_skip_en <= 1'b0;
      pos_x_cur <= 4'b0000;
      pos_y_cur <= 5'h0;
      rot_cur <= 2'b00;
      req_valid <= 1'b0;
      pos_x_chk <= 4'b0000;
      pos_y_chk <= 5'h0;
      rot_chk <= 2'b00;
      move_en <= 1'b0;
      ctrl_en <= 1'b0;
      drop_down <= 1'b0;
      place_en <= 1'b0;
      playfield_fsm_result <= 1'b0;
      playfield_fsm_reset <= 1'b0;
      freeze_ctrl_cnt_value <= 6'h0;
      debug_move_type <= 3'b000;
      main_fsm_drop_timeout_state <= 1'b0;
      main_fsm_drop_timeout_counter_value <= 25'h0;
      main_fsm_lock_timeout_state <= 1'b0;
      main_fsm_lock_timeout_counter_value <= 25'h0;
      score_total_score <= 8'h0;
      playfield_fsm_stateReg <= STANDBY;
      main_fsm_stateReg <= IDLE;
    end else begin
      lines_cleared_num_valid <= play_field_1_lines_cleared_valid;
      req_valid <= 1'b0;
      update <= 1'b0;
      block_set <= 1'b1;
      freeze_ctrl_cnt_value <= freeze_ctrl_cnt_valueNext;
      gen_piece_en <= 1'b0;
      drop_down <= 1'b0;
      move_en <= 1'b0;
      place_en <= 1'b0;
      restart <= 1'b0;
      playfield_fsm_reset <= 1'b0;
      clear_start <= 1'b0;
      main_fsm_drop_timeout_counter_value <= main_fsm_drop_timeout_counter_valueNext;
      if(main_fsm_drop_timeout_counter_willOverflow) begin
        main_fsm_drop_timeout_state <= 1'b1;
      end
      main_fsm_lock_timeout_counter_value <= main_fsm_lock_timeout_counter_valueNext;
      if(main_fsm_lock_timeout_counter_willOverflow) begin
        main_fsm_lock_timeout_state <= 1'b1;
      end
      if((main_fsm_stateReg == GAME_START)) begin
        score_total_score <= 8'h0;
      end
      if(lines_cleared_num_valid) begin
        score_total_score <= (score_total_score + temp_score_total_score);
      end
      playfield_fsm_stateReg <= playfield_fsm_stateNext;
      case(playfield_fsm_stateReg)
        MOVE : begin
          block_set <= 1'b0;
          pos_x_chk <= pos_x_cur;
          pos_y_chk <= pos_y_cur;
          rot_chk <= rot_cur;
          if(temp_when) begin
            pos_x_chk <= (pos_x_cur - 4'b0001);
          end
          if(temp_when_1) begin
            pos_x_chk <= (pos_x_cur + 4'b0001);
            debug_move_type <= 3'b010;
          end
          if(temp_when_2) begin
            rot_chk <= (rot_cur + 2'b01);
            debug_move_type <= 3'b011;
          end
          if(temp_when_3) begin
            pos_y_chk <= (pos_y_cur + 5'h01);
          end
          if(ctrl_en) begin
            if(move_left) begin
              debug_move_type <= 3'b001;
            end else begin
              if(move_right) begin
                debug_move_type <= 3'b010;
              end else begin
                if(move_down) begin
                  debug_move_type <= 3'b011;
                end else begin
                  if(rotate) begin
                    debug_move_type <= 3'b100;
                  end
                end
              end
            end
          end else begin
            if(drop_down) begin
              debug_move_type <= 3'b101;
            end else begin
              if(place_en) begin
                debug_move_type <= 3'b110;
              end
            end
          end
        end
        CHECK : begin
          block_skip_en <= (! fsm_is_place);
        end
        ERASE : begin
          update <= 1'b1;
          block_set <= 1'b0;
        end
        UPDATE : begin
          update <= 1'b1;
          if(collision_in_valid) begin
            playfield_fsm_result <= 1'b1;
          end
        end
        START_REFRESH : begin
          block_set <= 1'b0;
        end
        WAIT_FRESH_DONE : begin
        end
        STATUS : begin
          block_set <= 1'b0;
        end
        FREEZE_CTRL : begin
        end
        default : begin
        end
      endcase
      if(playfield_fsm_onExit_MOVE) begin
        playfield_fsm_result <= 1'b0;
      end
      if(playfield_fsm_onExit_CHECK) begin
        block_skip_en <= 1'b0;
      end
      if(playfield_fsm_onExit_ERASE) begin
        pos_x_cur <= pos_x_chk;
        pos_y_cur <= pos_y_chk;
        rot_cur <= rot_chk;
      end
      if(playfield_fsm_onEntry_CHECK) begin
        req_valid <= 1'b1;
      end
      if(playfield_fsm_onEntry_ERASE) begin
        req_valid <= 1'b1;
      end
      if(playfield_fsm_onEntry_UPDATE) begin
        req_valid <= 1'b1;
      end
      main_fsm_stateReg <= main_fsm_stateNext;
      case(main_fsm_stateReg)
        GAME_START : begin
        end
        RANDOM_GEN : begin
        end
        PLACE : begin
        end
        END_1 : begin
        end
        FALLING : begin
        end
        LOCK : begin
        end
        LOCKDOWN : begin
        end
        PATTERN : begin
        end
        default : begin
          restart <= 1'b1;
        end
      endcase
      if(main_fsm_onExit_RANDOM_GEN) begin
        pos_x_cur <= start_x;
        pos_y_cur <= start_y;
        rot_cur <= 2'b00;
      end
      if(main_fsm_onEntry_RANDOM_GEN) begin
        move_en <= 1'b1;
        gen_piece_en <= 1'b1;
      end
      if(main_fsm_onEntry_PLACE) begin
        place_en <= 1'b1;
        id_debug <= (id_debug + 5'h01);
      end
      if(main_fsm_onEntry_FALLING) begin
        main_fsm_drop_timeout_state <= 1'b0;
        ctrl_en <= 1'b1;
      end
      if(main_fsm_onEntry_LOCK) begin
        ctrl_en <= 1'b0;
        drop_down <= 1'b1;
      end
      if(main_fsm_onEntry_LOCKDOWN) begin
        main_fsm_lock_timeout_state <= 1'b0;
      end
      if(main_fsm_onEntry_PATTERN) begin
        playfield_fsm_reset <= 1'b1;
        clear_start <= 1'b1;
      end
    end
  end

  always @(posedge core_clk) begin
    lines_cleared_num_payload <= play_field_1_lines_cleared_payload;
    case(playfield_fsm_stateReg)
      MOVE : begin
        shape_chk <= shape_cur;
      end
      CHECK : begin
      end
      ERASE : begin
      end
      UPDATE : begin
      end
      START_REFRESH : begin
      end
      WAIT_FRESH_DONE : begin
      end
      STATUS : begin
      end
      FREEZE_CTRL : begin
      end
      default : begin
      end
    endcase
    if(main_fsm_onExit_RANDOM_GEN) begin
      shape_cur <= temp_shape_cur;
    end
  end


endmodule

//BufferCC_3 replaced by BufferCC_1

//BufferCC_2 replaced by BufferCC_1

module BufferCC_1 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          core_clk,
  input  wire          core_rst
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module BufferCC (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module linebuffer (
  input  wire          wr_in_valid,
  input  wire [3:0]    wr_in_payload,
  input  wire          rd_start,
  output wire          rd_out_valid,
  output wire [3:0]    rd_out_payload,
  input  wire          core_clk,
  input  wire          core_rst,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  reg        [3:0]    ram_spinal_port1;
  reg        [8:0]    wr_addr;
  reg        [8:0]    rd_addr;
  reg                 rd_enable;
  reg                 rd_scale_cnt_willIncrement;
  reg                 rd_scale_cnt_willClear;
  reg        [0:0]    rd_scale_cnt_valueNext;
  reg        [0:0]    rd_scale_cnt_value;
  wire                rd_scale_cnt_willOverflowIfInc;
  wire                rd_scale_cnt_willOverflow;
  wire                rd_valid;
  wire                rd_inc_enable;
  wire                rd_data_valid;
  wire       [3:0]    rd_data_payload;
  wire       [3:0]    rd_rd_data;
  reg                 rd_enable_regNext;
  (* ram_style = "distributed" *) reg [3:0] ram [0:287];

  always @(posedge core_clk) begin
    if(wr_in_valid) begin
      ram[wr_addr] <= wr_in_payload;
    end
  end

  always @(posedge vga_clk) begin
    if(rd_valid) begin
      ram_spinal_port1 <= ram[rd_addr];
    end
  end

  always @(*) begin
    rd_scale_cnt_willIncrement = 1'b0;
    if(rd_enable) begin
      rd_scale_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    rd_scale_cnt_willClear = 1'b0;
    if(rd_start) begin
      rd_scale_cnt_willClear = 1'b1;
    end
  end

  assign rd_scale_cnt_willOverflowIfInc = (rd_scale_cnt_value == 1'b1);
  assign rd_scale_cnt_willOverflow = (rd_scale_cnt_willOverflowIfInc && rd_scale_cnt_willIncrement);
  always @(*) begin
    rd_scale_cnt_valueNext = (rd_scale_cnt_value + rd_scale_cnt_willIncrement);
    if(rd_scale_cnt_willClear) begin
      rd_scale_cnt_valueNext = 1'b0;
    end
  end

  assign rd_valid = ((rd_scale_cnt_value == 1'b0) && rd_enable);
  assign rd_inc_enable = (rd_scale_cnt_willOverflowIfInc && rd_enable);
  assign rd_rd_data = ram_spinal_port1;
  assign rd_data_valid = rd_enable_regNext;
  assign rd_data_payload = rd_rd_data;
  assign rd_out_valid = rd_data_valid;
  assign rd_out_payload = rd_data_payload;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      wr_addr <= 9'h0;
    end else begin
      if(wr_in_valid) begin
        if((wr_addr == 9'h11f)) begin
          wr_addr <= 9'h0;
        end else begin
          wr_addr <= (wr_addr + 9'h001);
        end
      end
    end
  end

  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      rd_addr <= 9'h0;
      rd_enable <= 1'b0;
      rd_scale_cnt_value <= 1'b0;
      rd_enable_regNext <= 1'b0;
    end else begin
      rd_scale_cnt_value <= rd_scale_cnt_valueNext;
      if(rd_start) begin
        rd_enable <= 1'b1;
      end else begin
        if(((rd_addr == 9'h11f) && rd_scale_cnt_willOverflowIfInc)) begin
          rd_enable <= 1'b0;
        end
      end
      if(rd_start) begin
        rd_addr <= 9'h0;
      end else begin
        if(rd_inc_enable) begin
          rd_addr <= (rd_addr + 9'h001);
        end
      end
      rd_enable_regNext <= rd_enable;
    end
  end


endmodule

module color_palettes (
  input  wire [3:0]    io_addr,
  input  wire          io_rd_en,
  output wire          io_color_valid,
  output wire [11:0]   io_color_payload,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  reg        [11:0]   rom_spinal_port0;
  reg                 io_rd_en_regNext;
  (* ram_style = "distributed" *) reg [11:0] rom [0:15];

  initial begin
    $readmemb("pcb.v_toplevel_tetris_top_inst_tetris_core_inst_game_display_inst_lbcp_rom.bin",rom);
  end
  always @(posedge vga_clk) begin
    if(io_rd_en) begin
      rom_spinal_port0 <= rom[io_addr];
    end
  end

  assign io_color_payload = rom_spinal_port0;
  assign io_color_valid = io_rd_en_regNext;
  always @(posedge vga_clk) begin
    io_rd_en_regNext <= io_rd_en;
  end


endmodule

module vga_sync_gen (
  input  wire          io_softReset,
  output wire          io_sof,
  output wire          io_sol,
  output wire          io_sos,
  output wire          io_hSync,
  output wire          io_vSync,
  output wire          io_colorEn,
  output wire          io_vColorEn,
  output wire [9:0]    io_x,
  output wire [9:0]    io_y,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  wire       [10:0]   temp_io_x;
  wire       [10:0]   temp_io_y;
  wire       [10:0]   timings_h_syncStart;
  wire       [10:0]   timings_h_syncEnd;
  wire       [10:0]   timings_h_colorStart;
  wire       [10:0]   timings_h_colorEnd;
  wire                timings_h_polarity;
  wire       [10:0]   timings_v_syncStart;
  wire       [10:0]   timings_v_syncEnd;
  wire       [10:0]   timings_v_colorStart;
  wire       [10:0]   timings_v_colorEnd;
  wire                timings_v_polarity;
  wire                temp_1;
  reg        [10:0]   h_counter;
  wire                h_syncStart;
  wire                h_syncEnd;
  wire                h_colorStart;
  wire                h_colorEnd;
  reg                 h_sync;
  reg                 h_colorEn;
  reg        [10:0]   v_counter;
  wire                v_syncStart;
  wire                v_syncEnd;
  wire                v_colorStart;
  wire                v_colorEnd;
  reg                 v_sync;
  reg                 v_colorEn;
  wire                colorEn;

  assign temp_io_x = h_counter;
  assign temp_io_y = v_counter;
  assign timings_h_syncStart = 11'h7cf;
  assign timings_h_syncEnd = 11'h28f;
  assign timings_h_colorStart = 11'h7ff;
  assign timings_h_colorEnd = 11'h27f;
  assign timings_v_syncStart = 11'h7de;
  assign timings_v_syncEnd = 11'h1e9;
  assign timings_v_colorStart = 11'h7ff;
  assign timings_v_colorEnd = 11'h1df;
  assign timings_h_polarity = 1'b0;
  assign timings_v_polarity = 1'b0;
  assign temp_1 = 1'b1;
  assign h_syncStart = ($signed(h_counter) == $signed(timings_h_syncStart));
  assign h_syncEnd = ($signed(h_counter) == $signed(timings_h_syncEnd));
  assign h_colorStart = ($signed(h_counter) == $signed(timings_h_colorStart));
  assign h_colorEnd = ($signed(h_counter) == $signed(timings_h_colorEnd));
  assign v_syncStart = ($signed(v_counter) == $signed(timings_v_syncStart));
  assign v_syncEnd = ($signed(v_counter) == $signed(timings_v_syncEnd));
  assign v_colorStart = ($signed(v_counter) == $signed(timings_v_colorStart));
  assign v_colorEnd = ($signed(v_counter) == $signed(timings_v_colorEnd));
  assign colorEn = (h_colorEn && v_colorEn);
  assign io_sof = (v_syncStart && h_syncStart);
  assign io_hSync = (h_sync ^ timings_h_polarity);
  assign io_vSync = (v_sync ^ timings_v_polarity);
  assign io_colorEn = colorEn;
  assign io_x = temp_io_x[9:0];
  assign io_y = temp_io_y[9:0];
  assign io_sol = (h_colorStart && v_colorEn);
  assign io_sos = (h_syncStart && v_colorEn);
  assign io_vColorEn = v_colorEn;
  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      h_counter <= 11'h770;
      h_sync <= 1'b0;
      h_colorEn <= 1'b0;
      v_counter <= 11'h7dd;
      v_sync <= 1'b0;
      v_colorEn <= 1'b0;
    end else begin
      if(1'b1) begin
        h_counter <= ($signed(h_counter) + $signed(11'h001));
        if(h_syncEnd) begin
          h_counter <= 11'h770;
        end
      end
      if((temp_1 && h_syncStart)) begin
        h_sync <= 1'b1;
      end
      if((temp_1 && h_syncEnd)) begin
        h_sync <= 1'b0;
      end
      if((temp_1 && h_colorStart)) begin
        h_colorEn <= 1'b1;
      end
      if((temp_1 && h_colorEnd)) begin
        h_colorEn <= 1'b0;
      end
      if(io_softReset) begin
        h_counter <= 11'h770;
        h_sync <= 1'b0;
        h_colorEn <= 1'b0;
      end
      if(h_syncEnd) begin
        v_counter <= ($signed(v_counter) + $signed(11'h001));
        if(v_syncEnd) begin
          v_counter <= 11'h7dd;
        end
      end
      if((h_syncEnd && v_syncStart)) begin
        v_sync <= 1'b1;
      end
      if((h_syncEnd && v_syncEnd)) begin
        v_sync <= 1'b0;
      end
      if((h_syncEnd && v_colorStart)) begin
        v_colorEn <= 1'b1;
      end
      if((h_syncEnd && v_colorEnd)) begin
        v_colorEn <= 1'b0;
      end
      if(io_softReset) begin
        v_counter <= 11'h7dd;
        v_sync <= 1'b0;
        v_colorEn <= 1'b0;
      end
    end
  end


endmodule

module display_controller (
  input  wire          game_restart,
  input  wire          draw_openning_start,
  input  wire          game_start,
  input  wire          row_val_valid,
  input  wire [9:0]    row_val_payload,
  output reg           screen_is_ready,
  output wire          draw_char_start,
  output wire [6:0]    draw_char_word,
  output wire [2:0]    draw_char_scale,
  output wire [3:0]    draw_char_color,
  input  wire          draw_char_done,
  output wire          draw_block_start,
  output wire [7:0]    draw_block_width,
  output wire [7:0]    draw_block_height,
  output wire [3:0]    draw_block_in_color,
  output wire [3:0]    draw_block_pat_color,
  output wire [1:0]    draw_block_fill_pattern,
  input  wire          draw_block_done,
  output wire [8:0]    draw_x_orig,
  output wire [7:0]    draw_y_orig,
  output reg           draw_field_done,
  output reg           bf_clear_start,
  input  wire          bf_clear_done,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam IDLE = 3'd0;
  localparam FETCH = 3'd1;
  localparam DATA_READY = 3'd2;
  localparam DRAW = 3'd3;
  localparam WAIT_DONE = 3'd4;
  localparam SETUP_IDLE = 4'd0;
  localparam CLEAN_SCREEN = 4'd1;
  localparam START_DRAW_OPEN = 4'd2;
  localparam WAIT_DRAW_OPEN_DONE = 4'd3;
  localparam WAIT_GAME_START = 4'd4;
  localparam START_DRAW_STRING = 4'd5;
  localparam WAIT_DRAW_STRING_DONE = 4'd6;
  localparam WAIT_DRAW_SCORE = 4'd7;
  localparam PRE_DRAW_WALL = 4'd8;
  localparam START_DRAW_WALL = 4'd9;
  localparam WAIT_DRAW_WALL_DONE = 4'd10;
  localparam DRAW_SCORE = 4'd11;

  reg        [9:0]    memory_spinal_port1;
  wire       [6:0]    rom_spinal_port0;
  wire       [42:0]   wall_rom_spinal_port0;
  wire       [4:0]    temp_wr_row_cnt_valueNext;
  wire       [0:0]    temp_wr_row_cnt_valueNext_1;
  wire       [3:0]    temp_col_cnt_valueNext;
  wire       [0:0]    temp_col_cnt_valueNext_1;
  wire       [4:0]    temp_row_cnt_valueNext;
  wire       [0:0]    temp_row_cnt_valueNext_1;
  wire       [3:0]    temp_cnt_valueNext;
  wire       [0:0]    temp_cnt_valueNext_1;
  wire       [1:0]    temp_cnt_valueNext_1_1;
  wire       [0:0]    temp_cnt_valueNext_1_2;
  wire                temp_when;
  wire                temp_when_1;
  reg                 wr_row_cnt_willIncrement;
  wire                wr_row_cnt_willClear;
  reg        [4:0]    wr_row_cnt_valueNext;
  reg        [4:0]    wr_row_cnt_value;
  wire                wr_row_cnt_willOverflowIfInc;
  wire                wr_row_cnt_willOverflow;
  reg                 rd_en;
  reg                 row_cnt_inc;
  reg                 col_cnt_inc;
  reg                 col_cnt_willIncrement;
  wire                col_cnt_willClear;
  reg        [3:0]    col_cnt_valueNext;
  reg        [3:0]    col_cnt_value;
  wire                col_cnt_willOverflowIfInc;
  wire                col_cnt_willOverflow;
  reg                 row_cnt_willIncrement;
  wire                row_cnt_willClear;
  reg        [4:0]    row_cnt_valueNext;
  reg        [4:0]    row_cnt_value;
  wire                row_cnt_willOverflowIfInc;
  wire                row_cnt_willOverflow;
  wire       [9:0]    row_value;
  reg                 load;
  reg                 shift_en;
  reg        [9:0]    row_bits;
  wire       [9:0]    row_bits_next;
  reg                 row_val_valid_regNext;
  wire                gen_start;
  reg        [3:0]    ft_color;
  reg        [8:0]    x;
  reg        [7:0]    y;
  wire       [8:0]    x_next;
  wire       [7:0]    y_next;
  reg                 itf_start;
  wire       [7:0]    itf_width;
  wire       [7:0]    itf_height;
  wire       [3:0]    itf_in_color;
  wire       [3:0]    itf_pat_color;
  wire       [1:0]    itf_fill_pattern;
  wire                itf_done;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  wire                itf_start_1;
  wire       [6:0]    itf_word;
  wire       [2:0]    itf_scale;
  wire       [3:0]    itf_color;
  wire                itf_done_1;
  reg                 cnt_willIncrement;
  wire                cnt_willClear;
  reg        [3:0]    cnt_valueNext;
  reg        [3:0]    cnt_value;
  wire                cnt_willOverflowIfInc;
  wire                cnt_willOverflow;
  wire       [8:0]    x_1;
  wire       [7:0]    y_1;
  wire                itf_start_2;
  wire       [7:0]    itf_width_1;
  wire       [7:0]    itf_height_1;
  wire       [3:0]    itf_in_color_1;
  wire       [3:0]    itf_pat_color_1;
  wire       [1:0]    itf_fill_pattern_1;
  wire                itf_done_2;
  reg                 cnt_willIncrement_1;
  wire                cnt_willClear_1;
  reg        [1:0]    cnt_valueNext_1;
  reg        [1:0]    cnt_value_1;
  wire                cnt_willOverflowIfInc_1;
  wire                cnt_willOverflow_1;
  wire       [42:0]   blockInfo;
  reg        [8:0]    stepup_x;
  reg        [7:0]    stepup_y;
  reg        [2:0]    stepup_scale;
  reg        [3:0]    stepup_color;
  reg                 stepup_start_char_draw;
  reg                 stepup_start_block_draw;
  reg                 stepup_game_is_running;
  wire                stepup_fsm_wantExit;
  reg                 stepup_fsm_wantStart;
  wire                stepup_fsm_wantKill;
  wire       [3:0]    stepup_fsm_debug;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_FETCH;
  wire                fsm_onExit_DATA_READY;
  wire                fsm_onExit_DRAW;
  wire                fsm_onExit_WAIT_DONE;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_FETCH;
  wire                fsm_onEntry_DATA_READY;
  wire                fsm_onEntry_DRAW;
  wire                fsm_onEntry_WAIT_DONE;
  reg        [3:0]    stepup_fsm_stateReg;
  reg        [3:0]    stepup_fsm_stateNext;
  wire                stepup_fsm_onExit_SETUP_IDLE;
  wire                stepup_fsm_onExit_CLEAN_SCREEN;
  wire                stepup_fsm_onExit_START_DRAW_OPEN;
  wire                stepup_fsm_onExit_WAIT_DRAW_OPEN_DONE;
  wire                stepup_fsm_onExit_WAIT_GAME_START;
  wire                stepup_fsm_onExit_START_DRAW_STRING;
  wire                stepup_fsm_onExit_WAIT_DRAW_STRING_DONE;
  wire                stepup_fsm_onExit_WAIT_DRAW_SCORE;
  wire                stepup_fsm_onExit_PRE_DRAW_WALL;
  wire                stepup_fsm_onExit_START_DRAW_WALL;
  wire                stepup_fsm_onExit_WAIT_DRAW_WALL_DONE;
  wire                stepup_fsm_onExit_DRAW_SCORE;
  wire                stepup_fsm_onEntry_SETUP_IDLE;
  wire                stepup_fsm_onEntry_CLEAN_SCREEN;
  wire                stepup_fsm_onEntry_START_DRAW_OPEN;
  wire                stepup_fsm_onEntry_WAIT_DRAW_OPEN_DONE;
  wire                stepup_fsm_onEntry_WAIT_GAME_START;
  wire                stepup_fsm_onEntry_START_DRAW_STRING;
  wire                stepup_fsm_onEntry_WAIT_DRAW_STRING_DONE;
  wire                stepup_fsm_onEntry_WAIT_DRAW_SCORE;
  wire                stepup_fsm_onEntry_PRE_DRAW_WALL;
  wire                stepup_fsm_onEntry_START_DRAW_WALL;
  wire                stepup_fsm_onEntry_WAIT_DRAW_WALL_DONE;
  wire                stepup_fsm_onEntry_DRAW_SCORE;
  `ifndef SYNTHESIS
  reg [79:0] fsm_stateReg_string;
  reg [79:0] fsm_stateNext_string;
  reg [167:0] stepup_fsm_stateReg_string;
  reg [167:0] stepup_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [9:0] memory [0:21];
  (* ram_style = "distributed" *) reg [6:0] rom [0:10];
  reg [42:0] wall_rom [0:3];

  assign temp_when = (cnt_value == 4'b0101);
  assign temp_when_1 = (cnt_value == 4'b1010);
  assign temp_wr_row_cnt_valueNext_1 = wr_row_cnt_willIncrement;
  assign temp_wr_row_cnt_valueNext = {4'd0, temp_wr_row_cnt_valueNext_1};
  assign temp_col_cnt_valueNext_1 = col_cnt_willIncrement;
  assign temp_col_cnt_valueNext = {3'd0, temp_col_cnt_valueNext_1};
  assign temp_row_cnt_valueNext_1 = row_cnt_willIncrement;
  assign temp_row_cnt_valueNext = {4'd0, temp_row_cnt_valueNext_1};
  assign temp_cnt_valueNext_1 = cnt_willIncrement;
  assign temp_cnt_valueNext = {3'd0, temp_cnt_valueNext_1};
  assign temp_cnt_valueNext_1_2 = cnt_willIncrement_1;
  assign temp_cnt_valueNext_1_1 = {1'd0, temp_cnt_valueNext_1_2};
  always @(posedge core_clk) begin
    if(row_val_valid) begin
      memory[wr_row_cnt_value] <= row_val_payload;
    end
  end

  always @(posedge core_clk) begin
    if(rd_en) begin
      memory_spinal_port1 <= memory[row_cnt_value];
    end
  end

  initial begin
    $readmemb("pcb.v_toplevel_tetris_top_inst_tetris_core_inst_game_display_inst_draw_controller_rom.bin",rom);
  end
  assign rom_spinal_port0 = rom[cnt_value];
  initial begin
    $readmemb("pcb.v_toplevel_tetris_top_inst_tetris_core_inst_game_display_inst_draw_controller_wall_rom.bin",wall_rom);
  end
  assign wall_rom_spinal_port0 = wall_rom[cnt_value_1];
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE      ";
      FETCH : fsm_stateReg_string = "FETCH     ";
      DATA_READY : fsm_stateReg_string = "DATA_READY";
      DRAW : fsm_stateReg_string = "DRAW      ";
      WAIT_DONE : fsm_stateReg_string = "WAIT_DONE ";
      default : fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE      ";
      FETCH : fsm_stateNext_string = "FETCH     ";
      DATA_READY : fsm_stateNext_string = "DATA_READY";
      DRAW : fsm_stateNext_string = "DRAW      ";
      WAIT_DONE : fsm_stateNext_string = "WAIT_DONE ";
      default : fsm_stateNext_string = "??????????";
    endcase
  end
  always @(*) begin
    case(stepup_fsm_stateReg)
      SETUP_IDLE : stepup_fsm_stateReg_string = "SETUP_IDLE           ";
      CLEAN_SCREEN : stepup_fsm_stateReg_string = "CLEAN_SCREEN         ";
      START_DRAW_OPEN : stepup_fsm_stateReg_string = "START_DRAW_OPEN      ";
      WAIT_DRAW_OPEN_DONE : stepup_fsm_stateReg_string = "WAIT_DRAW_OPEN_DONE  ";
      WAIT_GAME_START : stepup_fsm_stateReg_string = "WAIT_GAME_START      ";
      START_DRAW_STRING : stepup_fsm_stateReg_string = "START_DRAW_STRING    ";
      WAIT_DRAW_STRING_DONE : stepup_fsm_stateReg_string = "WAIT_DRAW_STRING_DONE";
      WAIT_DRAW_SCORE : stepup_fsm_stateReg_string = "WAIT_DRAW_SCORE      ";
      PRE_DRAW_WALL : stepup_fsm_stateReg_string = "PRE_DRAW_WALL        ";
      START_DRAW_WALL : stepup_fsm_stateReg_string = "START_DRAW_WALL      ";
      WAIT_DRAW_WALL_DONE : stepup_fsm_stateReg_string = "WAIT_DRAW_WALL_DONE  ";
      DRAW_SCORE : stepup_fsm_stateReg_string = "DRAW_SCORE           ";
      default : stepup_fsm_stateReg_string = "?????????????????????";
    endcase
  end
  always @(*) begin
    case(stepup_fsm_stateNext)
      SETUP_IDLE : stepup_fsm_stateNext_string = "SETUP_IDLE           ";
      CLEAN_SCREEN : stepup_fsm_stateNext_string = "CLEAN_SCREEN         ";
      START_DRAW_OPEN : stepup_fsm_stateNext_string = "START_DRAW_OPEN      ";
      WAIT_DRAW_OPEN_DONE : stepup_fsm_stateNext_string = "WAIT_DRAW_OPEN_DONE  ";
      WAIT_GAME_START : stepup_fsm_stateNext_string = "WAIT_GAME_START      ";
      START_DRAW_STRING : stepup_fsm_stateNext_string = "START_DRAW_STRING    ";
      WAIT_DRAW_STRING_DONE : stepup_fsm_stateNext_string = "WAIT_DRAW_STRING_DONE";
      WAIT_DRAW_SCORE : stepup_fsm_stateNext_string = "WAIT_DRAW_SCORE      ";
      PRE_DRAW_WALL : stepup_fsm_stateNext_string = "PRE_DRAW_WALL        ";
      START_DRAW_WALL : stepup_fsm_stateNext_string = "START_DRAW_WALL      ";
      WAIT_DRAW_WALL_DONE : stepup_fsm_stateNext_string = "WAIT_DRAW_WALL_DONE  ";
      DRAW_SCORE : stepup_fsm_stateNext_string = "DRAW_SCORE           ";
      default : stepup_fsm_stateNext_string = "?????????????????????";
    endcase
  end
  `endif

  always @(*) begin
    wr_row_cnt_willIncrement = 1'b0;
    if(row_val_valid) begin
      wr_row_cnt_willIncrement = 1'b1;
    end
  end

  assign wr_row_cnt_willClear = 1'b0;
  assign wr_row_cnt_willOverflowIfInc = (wr_row_cnt_value == 5'h15);
  assign wr_row_cnt_willOverflow = (wr_row_cnt_willOverflowIfInc && wr_row_cnt_willIncrement);
  always @(*) begin
    if(wr_row_cnt_willOverflow) begin
      wr_row_cnt_valueNext = 5'h0;
    end else begin
      wr_row_cnt_valueNext = (wr_row_cnt_value + temp_wr_row_cnt_valueNext);
    end
    if(wr_row_cnt_willClear) begin
      wr_row_cnt_valueNext = 5'h0;
    end
  end

  always @(*) begin
    col_cnt_willIncrement = 1'b0;
    if(col_cnt_inc) begin
      col_cnt_willIncrement = 1'b1;
    end
  end

  assign col_cnt_willClear = 1'b0;
  assign col_cnt_willOverflowIfInc = (col_cnt_value == 4'b1001);
  assign col_cnt_willOverflow = (col_cnt_willOverflowIfInc && col_cnt_willIncrement);
  always @(*) begin
    if(col_cnt_willOverflow) begin
      col_cnt_valueNext = 4'b0000;
    end else begin
      col_cnt_valueNext = (col_cnt_value + temp_col_cnt_valueNext);
    end
    if(col_cnt_willClear) begin
      col_cnt_valueNext = 4'b0000;
    end
  end

  always @(*) begin
    row_cnt_willIncrement = 1'b0;
    if(row_cnt_inc) begin
      row_cnt_willIncrement = 1'b1;
    end
  end

  assign row_cnt_willClear = 1'b0;
  assign row_cnt_willOverflowIfInc = (row_cnt_value == 5'h15);
  assign row_cnt_willOverflow = (row_cnt_willOverflowIfInc && row_cnt_willIncrement);
  always @(*) begin
    if(row_cnt_willOverflow) begin
      row_cnt_valueNext = 5'h0;
    end else begin
      row_cnt_valueNext = (row_cnt_value + temp_row_cnt_valueNext);
    end
    if(row_cnt_willClear) begin
      row_cnt_valueNext = 5'h0;
    end
  end

  assign row_value = memory_spinal_port1;
  assign row_bits_next = (row_bits >>> 1);
  assign gen_start = ((! row_val_valid) && row_val_valid_regNext);
  always @(*) begin
    ft_color = 4'b0010;
    if(row_bits[0]) begin
      ft_color = 4'b1001;
    end
  end

  assign x_next = (x + 9'h009);
  assign y_next = (y + 8'h09);
  always @(*) begin
    itf_start = 1'b0;
    draw_field_done = 1'b0;
    fsm_wantStart = 1'b0;
    rd_en = 1'b0;
    load = 1'b0;
    col_cnt_inc = 1'b0;
    row_cnt_inc = 1'b0;
    shift_en = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      FETCH : begin
        rd_en = 1'b1;
        fsm_stateNext = DATA_READY;
      end
      DATA_READY : begin
        load = 1'b1;
        fsm_stateNext = DRAW;
      end
      DRAW : begin
        itf_start = 1'b1;
        fsm_stateNext = WAIT_DONE;
      end
      WAIT_DONE : begin
        if(itf_done) begin
          if((row_cnt_willOverflowIfInc && col_cnt_willOverflowIfInc)) begin
            row_cnt_inc = 1'b1;
            col_cnt_inc = 1'b1;
            draw_field_done = 1'b1;
            fsm_stateNext = IDLE;
          end else begin
            col_cnt_inc = 1'b1;
            if(col_cnt_willOverflowIfInc) begin
              row_cnt_inc = 1'b1;
              fsm_stateNext = FETCH;
            end else begin
              shift_en = 1'b1;
              fsm_stateNext = DRAW;
            end
          end
        end
      end
      default : begin
        if(gen_start) begin
          fsm_stateNext = FETCH;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign itf_in_color = ft_color;
  assign itf_width = 8'h08;
  assign itf_height = 8'h08;
  assign itf_fill_pattern = 2'b00;
  assign itf_pat_color = 4'b0000;
  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  always @(*) begin
    cnt_willIncrement = 1'b0;
    if(cnt_willOverflow) begin
      cnt_valueNext = 4'b0000;
    end else begin
      cnt_valueNext = (cnt_value + temp_cnt_valueNext);
    end
    if(cnt_willClear) begin
      cnt_valueNext = 4'b0000;
    end
    cnt_willIncrement_1 = 1'b0;
    stepup_fsm_wantStart = 1'b0;
    stepup_start_char_draw = 1'b0;
    stepup_start_block_draw = 1'b0;
    screen_is_ready = 1'b0;
    cnt_willIncrement = 1'b0;
    stepup_fsm_stateNext = stepup_fsm_stateReg;
    case(stepup_fsm_stateReg)
      CLEAN_SCREEN : begin
        if(bf_clear_done) begin
          if(stepup_game_is_running) begin
            cnt_valueNext = 4'b0110;
            stepup_fsm_stateNext = START_DRAW_STRING;
          end else begin
            stepup_fsm_stateNext = START_DRAW_OPEN;
          end
        end
      end
      START_DRAW_OPEN : begin
        stepup_start_char_draw = 1'b1;
        stepup_fsm_stateNext = WAIT_DRAW_OPEN_DONE;
      end
      WAIT_DRAW_OPEN_DONE : begin
        if(itf_done_1) begin
          cnt_willIncrement = 1'b1;
          if(temp_when) begin
            stepup_fsm_stateNext = WAIT_GAME_START;
          end else begin
            stepup_fsm_stateNext = START_DRAW_OPEN;
          end
        end
      end
      WAIT_GAME_START : begin
        if(game_start) begin
          stepup_fsm_stateNext = CLEAN_SCREEN;
        end
      end
      START_DRAW_STRING : begin
        stepup_start_char_draw = 1'b1;
        stepup_fsm_stateNext = WAIT_DRAW_STRING_DONE;
      end
      WAIT_DRAW_STRING_DONE : begin
        if(itf_done_1) begin
          cnt_willIncrement = 1'b1;
          if(temp_when_1) begin
            stepup_fsm_stateNext = WAIT_DRAW_SCORE;
          end else begin
            stepup_fsm_stateNext = START_DRAW_STRING;
          end
        end
      end
      WAIT_DRAW_SCORE : begin
        stepup_fsm_stateNext = PRE_DRAW_WALL;
      end
      PRE_DRAW_WALL : begin
        stepup_fsm_stateNext = START_DRAW_WALL;
      end
      START_DRAW_WALL : begin
        stepup_start_block_draw = 1'b1;
        stepup_fsm_stateNext = WAIT_DRAW_WALL_DONE;
      end
      WAIT_DRAW_WALL_DONE : begin
        if(itf_done_2) begin
          cnt_willIncrement_1 = 1'b1;
          if(cnt_willOverflow_1) begin
            stepup_fsm_stateNext = DRAW_SCORE;
          end else begin
            stepup_fsm_stateNext = PRE_DRAW_WALL;
          end
        end
      end
      DRAW_SCORE : begin
        screen_is_ready = 1'b1;
        if(game_restart) begin
          stepup_fsm_stateNext = CLEAN_SCREEN;
        end
      end
      default : begin
        if(draw_openning_start) begin
          stepup_fsm_stateNext = CLEAN_SCREEN;
        end
        stepup_fsm_wantStart = 1'b1;
      end
    endcase
    if(stepup_fsm_wantKill) begin
      stepup_fsm_stateNext = SETUP_IDLE;
    end
  end

  assign cnt_willClear = 1'b0;
  assign cnt_willOverflowIfInc = (cnt_value == 4'b1010);
  assign cnt_willOverflow = (cnt_willOverflowIfInc && cnt_willIncrement);
  assign itf_word = rom_spinal_port0;
  assign cnt_willClear_1 = 1'b0;
  assign cnt_willOverflowIfInc_1 = (cnt_value_1 == 2'b11);
  assign cnt_willOverflow_1 = (cnt_willOverflowIfInc_1 && cnt_willIncrement_1);
  always @(*) begin
    cnt_valueNext_1 = (cnt_value_1 + temp_cnt_valueNext_1_1);
    if(cnt_willClear_1) begin
      cnt_valueNext_1 = 2'b00;
    end
  end

  assign blockInfo = wall_rom_spinal_port0;
  assign x_1 = blockInfo[8 : 0];
  assign y_1 = blockInfo[16 : 9];
  assign itf_width_1 = blockInfo[24 : 17];
  assign itf_height_1 = blockInfo[32 : 25];
  assign itf_in_color_1 = blockInfo[36 : 33];
  assign itf_pat_color_1 = blockInfo[40 : 37];
  assign itf_fill_pattern_1 = blockInfo[42 : 41];
  assign itf_scale = stepup_scale;
  assign itf_color = stepup_color;
  assign itf_start_1 = stepup_start_char_draw;
  assign itf_start_2 = stepup_start_block_draw;
  assign stepup_fsm_wantExit = 1'b0;
  assign stepup_fsm_wantKill = 1'b0;
  always @(*) begin
    bf_clear_start = 1'b0;
    if(stepup_fsm_onEntry_CLEAN_SCREEN) begin
      bf_clear_start = 1'b1;
    end
  end

  assign draw_char_start = itf_start_1;
  assign draw_char_word = itf_word;
  assign draw_char_scale = itf_scale;
  assign draw_char_color = itf_color;
  assign itf_done_1 = draw_char_done;
  assign draw_block_start = (itf_start || itf_start_2);
  assign draw_block_width = (itf_start ? itf_width : itf_width_1);
  assign draw_block_height = (itf_start ? itf_height : itf_height_1);
  assign draw_block_in_color = (itf_start ? itf_in_color : itf_in_color_1);
  assign draw_block_pat_color = itf_pat_color_1;
  assign draw_block_fill_pattern = (itf_start ? itf_fill_pattern : itf_fill_pattern_1);
  assign itf_done = draw_block_done;
  assign itf_done_2 = draw_block_done;
  assign draw_x_orig = (x | stepup_x);
  assign draw_y_orig = (y | stepup_y);
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_FETCH = ((fsm_stateNext != FETCH) && (fsm_stateReg == FETCH));
  assign fsm_onExit_DATA_READY = ((fsm_stateNext != DATA_READY) && (fsm_stateReg == DATA_READY));
  assign fsm_onExit_DRAW = ((fsm_stateNext != DRAW) && (fsm_stateReg == DRAW));
  assign fsm_onExit_WAIT_DONE = ((fsm_stateNext != WAIT_DONE) && (fsm_stateReg == WAIT_DONE));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_FETCH = ((fsm_stateNext == FETCH) && (fsm_stateReg != FETCH));
  assign fsm_onEntry_DATA_READY = ((fsm_stateNext == DATA_READY) && (fsm_stateReg != DATA_READY));
  assign fsm_onEntry_DRAW = ((fsm_stateNext == DRAW) && (fsm_stateReg != DRAW));
  assign fsm_onEntry_WAIT_DONE = ((fsm_stateNext == WAIT_DONE) && (fsm_stateReg != WAIT_DONE));
  assign stepup_fsm_onExit_SETUP_IDLE = ((stepup_fsm_stateNext != SETUP_IDLE) && (stepup_fsm_stateReg == SETUP_IDLE));
  assign stepup_fsm_onExit_CLEAN_SCREEN = ((stepup_fsm_stateNext != CLEAN_SCREEN) && (stepup_fsm_stateReg == CLEAN_SCREEN));
  assign stepup_fsm_onExit_START_DRAW_OPEN = ((stepup_fsm_stateNext != START_DRAW_OPEN) && (stepup_fsm_stateReg == START_DRAW_OPEN));
  assign stepup_fsm_onExit_WAIT_DRAW_OPEN_DONE = ((stepup_fsm_stateNext != WAIT_DRAW_OPEN_DONE) && (stepup_fsm_stateReg == WAIT_DRAW_OPEN_DONE));
  assign stepup_fsm_onExit_WAIT_GAME_START = ((stepup_fsm_stateNext != WAIT_GAME_START) && (stepup_fsm_stateReg == WAIT_GAME_START));
  assign stepup_fsm_onExit_START_DRAW_STRING = ((stepup_fsm_stateNext != START_DRAW_STRING) && (stepup_fsm_stateReg == START_DRAW_STRING));
  assign stepup_fsm_onExit_WAIT_DRAW_STRING_DONE = ((stepup_fsm_stateNext != WAIT_DRAW_STRING_DONE) && (stepup_fsm_stateReg == WAIT_DRAW_STRING_DONE));
  assign stepup_fsm_onExit_WAIT_DRAW_SCORE = ((stepup_fsm_stateNext != WAIT_DRAW_SCORE) && (stepup_fsm_stateReg == WAIT_DRAW_SCORE));
  assign stepup_fsm_onExit_PRE_DRAW_WALL = ((stepup_fsm_stateNext != PRE_DRAW_WALL) && (stepup_fsm_stateReg == PRE_DRAW_WALL));
  assign stepup_fsm_onExit_START_DRAW_WALL = ((stepup_fsm_stateNext != START_DRAW_WALL) && (stepup_fsm_stateReg == START_DRAW_WALL));
  assign stepup_fsm_onExit_WAIT_DRAW_WALL_DONE = ((stepup_fsm_stateNext != WAIT_DRAW_WALL_DONE) && (stepup_fsm_stateReg == WAIT_DRAW_WALL_DONE));
  assign stepup_fsm_onExit_DRAW_SCORE = ((stepup_fsm_stateNext != DRAW_SCORE) && (stepup_fsm_stateReg == DRAW_SCORE));
  assign stepup_fsm_onEntry_SETUP_IDLE = ((stepup_fsm_stateNext == SETUP_IDLE) && (stepup_fsm_stateReg != SETUP_IDLE));
  assign stepup_fsm_onEntry_CLEAN_SCREEN = ((stepup_fsm_stateNext == CLEAN_SCREEN) && (stepup_fsm_stateReg != CLEAN_SCREEN));
  assign stepup_fsm_onEntry_START_DRAW_OPEN = ((stepup_fsm_stateNext == START_DRAW_OPEN) && (stepup_fsm_stateReg != START_DRAW_OPEN));
  assign stepup_fsm_onEntry_WAIT_DRAW_OPEN_DONE = ((stepup_fsm_stateNext == WAIT_DRAW_OPEN_DONE) && (stepup_fsm_stateReg != WAIT_DRAW_OPEN_DONE));
  assign stepup_fsm_onEntry_WAIT_GAME_START = ((stepup_fsm_stateNext == WAIT_GAME_START) && (stepup_fsm_stateReg != WAIT_GAME_START));
  assign stepup_fsm_onEntry_START_DRAW_STRING = ((stepup_fsm_stateNext == START_DRAW_STRING) && (stepup_fsm_stateReg != START_DRAW_STRING));
  assign stepup_fsm_onEntry_WAIT_DRAW_STRING_DONE = ((stepup_fsm_stateNext == WAIT_DRAW_STRING_DONE) && (stepup_fsm_stateReg != WAIT_DRAW_STRING_DONE));
  assign stepup_fsm_onEntry_WAIT_DRAW_SCORE = ((stepup_fsm_stateNext == WAIT_DRAW_SCORE) && (stepup_fsm_stateReg != WAIT_DRAW_SCORE));
  assign stepup_fsm_onEntry_PRE_DRAW_WALL = ((stepup_fsm_stateNext == PRE_DRAW_WALL) && (stepup_fsm_stateReg != PRE_DRAW_WALL));
  assign stepup_fsm_onEntry_START_DRAW_WALL = ((stepup_fsm_stateNext == START_DRAW_WALL) && (stepup_fsm_stateReg != START_DRAW_WALL));
  assign stepup_fsm_onEntry_WAIT_DRAW_WALL_DONE = ((stepup_fsm_stateNext == WAIT_DRAW_WALL_DONE) && (stepup_fsm_stateReg != WAIT_DRAW_WALL_DONE));
  assign stepup_fsm_onEntry_DRAW_SCORE = ((stepup_fsm_stateNext == DRAW_SCORE) && (stepup_fsm_stateReg != DRAW_SCORE));
  assign stepup_fsm_debug = stepup_fsm_stateReg;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      wr_row_cnt_value <= 5'h0;
      col_cnt_value <= 4'b0000;
      row_cnt_value <= 5'h0;
      row_val_valid_regNext <= 1'b0;
      x <= 9'h0;
      y <= 8'h0;
      cnt_value <= 4'b0000;
      cnt_value_1 <= 2'b00;
      stepup_x <= 9'h0;
      stepup_y <= 8'h0;
      stepup_game_is_running <= 1'b0;
      fsm_stateReg <= IDLE;
      stepup_fsm_stateReg <= SETUP_IDLE;
    end else begin
      wr_row_cnt_value <= wr_row_cnt_valueNext;
      col_cnt_value <= col_cnt_valueNext;
      row_cnt_value <= row_cnt_valueNext;
      row_val_valid_regNext <= row_val_valid;
      if(gen_start) begin
        x <= 9'h02b;
        y <= 8'h14;
      end
      if(draw_field_done) begin
        x <= 9'h0;
        y <= 8'h0;
      end else begin
        if(col_cnt_willOverflow) begin
          x <= 9'h02b;
        end else begin
          if(col_cnt_inc) begin
            x <= x_next;
          end
        end
        if(row_cnt_inc) begin
          y <= y_next;
        end
      end
      cnt_value <= cnt_valueNext;
      cnt_value_1 <= cnt_valueNext_1;
      fsm_stateReg <= fsm_stateNext;
      stepup_fsm_stateReg <= stepup_fsm_stateNext;
      case(stepup_fsm_stateReg)
        CLEAN_SCREEN : begin
          if(bf_clear_done) begin
            if(stepup_game_is_running) begin
              stepup_x <= 9'h0d2;
              stepup_y <= 8'h17;
            end else begin
              stepup_x <= 9'h018;
              stepup_y <= 8'h42;
            end
          end
        end
        START_DRAW_OPEN : begin
        end
        WAIT_DRAW_OPEN_DONE : begin
          if(itf_done_1) begin
            if(!temp_when) begin
              stepup_x <= (stepup_x + 9'h02e);
            end
          end
        end
        WAIT_GAME_START : begin
          if(game_start) begin
            stepup_game_is_running <= 1'b1;
          end
        end
        START_DRAW_STRING : begin
        end
        WAIT_DRAW_STRING_DONE : begin
          if(itf_done_1) begin
            if(!temp_when_1) begin
              stepup_x <= (stepup_x + 9'h00c);
            end
          end
        end
        WAIT_DRAW_SCORE : begin
        end
        PRE_DRAW_WALL : begin
          stepup_x <= x_1;
          stepup_y <= y_1;
        end
        START_DRAW_WALL : begin
        end
        WAIT_DRAW_WALL_DONE : begin
        end
        DRAW_SCORE : begin
          stepup_x <= 9'h0;
          stepup_y <= 8'h0;
        end
        default : begin
          stepup_game_is_running <= 1'b0;
        end
      endcase
    end
  end

  always @(posedge core_clk) begin
    if(load) begin
      row_bits <= row_value;
    end else begin
      if(shift_en) begin
        row_bits <= row_bits_next;
      end
    end
    case(stepup_fsm_stateReg)
      CLEAN_SCREEN : begin
        if(bf_clear_done) begin
          if(stepup_game_is_running) begin
            stepup_scale <= 3'b000;
            stepup_color <= 4'b0110;
          end else begin
            stepup_scale <= 3'b010;
            stepup_color <= 4'b0110;
          end
        end
      end
      START_DRAW_OPEN : begin
      end
      WAIT_DRAW_OPEN_DONE : begin
      end
      WAIT_GAME_START : begin
      end
      START_DRAW_STRING : begin
      end
      WAIT_DRAW_STRING_DONE : begin
      end
      WAIT_DRAW_SCORE : begin
      end
      PRE_DRAW_WALL : begin
      end
      START_DRAW_WALL : begin
      end
      WAIT_DRAW_WALL_DONE : begin
      end
      DRAW_SCORE : begin
      end
      default : begin
      end
    endcase
  end


endmodule

module fb_addr_gen (
  input  wire [8:0]    x,
  input  wire [7:0]    y,
  input  wire          start,
  input  wire [8:0]    h_cnt,
  input  wire [7:0]    v_cnt,
  output wire [16:0]   out_addr,
  input  wire          core_clk,
  input  wire          core_rst
);

  wire       [11:0]   temp_v_next_in_fb;
  wire       [10:0]   temp_v_next_in_fb_1;
  wire       [11:0]   temp_v_next_in_fb_2;
  wire       [16:0]   temp_addr;
  wire       [16:0]   temp_addr_1;
  reg        [8:0]    x_reg;
  reg        [7:0]    y_reg;
  wire       [7:0]    v_next;
  wire       [11:0]   v_next_in_fb;
  reg        [8:0]    h_reg;
  reg        [11:0]   v_reg;
  reg        [16:0]   addr;

  assign temp_v_next_in_fb_1 = ({3'd0,v_next} <<< 2'd3);
  assign temp_v_next_in_fb = {1'd0, temp_v_next_in_fb_1};
  assign temp_v_next_in_fb_2 = {4'd0, v_next};
  assign temp_addr = {8'd0, h_reg};
  assign temp_addr_1 = ({5'd0,v_reg} <<< 3'd5);
  assign v_next = (y_reg + v_cnt);
  assign v_next_in_fb = (temp_v_next_in_fb + temp_v_next_in_fb_2);
  assign out_addr = addr;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      x_reg <= 9'h0;
      y_reg <= 8'h0;
      h_reg <= 9'h0;
      v_reg <= 12'h0;
      addr <= 17'h0;
    end else begin
      if(start) begin
        x_reg <= x;
      end
      if(start) begin
        y_reg <= y;
      end
      h_reg <= (x_reg + h_cnt);
      v_reg <= v_next_in_fb;
      addr <= (temp_addr + temp_addr_1);
    end
  end


endmodule

module draw_block_engine (
  input  wire          start,
  input  wire [7:0]    width,
  input  wire [7:0]    height,
  input  wire [3:0]    in_color,
  input  wire [3:0]    pat_color,
  input  wire [1:0]    fill_pattern,
  output wire [8:0]    h_cnt,
  output wire [7:0]    v_cnt,
  output wire          is_running,
  output wire          out_valid,
  output wire [3:0]    out_color,
  output wire          done,
  input  wire          core_clk,
  input  wire          core_rst
);

  wire       [7:0]    temp_h_cnt_valueNext;
  wire       [0:0]    temp_h_cnt_valueNext_1;
  wire       [7:0]    temp_v_cnt_valueNext;
  wire       [0:0]    temp_v_cnt_valueNext_1;
  reg        [3:0]    in_color_1;
  reg        [7:0]    width_reg;
  reg        [7:0]    height_reg;
  reg        [1:0]    fill_pattern_reg;
  reg                 addr_comp_active;
  reg                 h_cnt_willIncrement;
  wire                h_cnt_willClear;
  reg        [7:0]    h_cnt_valueNext;
  reg        [7:0]    h_cnt_value;
  wire                h_cnt_willOverflowIfInc;
  wire                h_cnt_willOverflow;
  reg                 v_cnt_willIncrement;
  wire                v_cnt_willClear;
  reg        [7:0]    v_cnt_valueNext;
  reg        [7:0]    v_cnt_value;
  wire                v_cnt_willOverflowIfInc;
  wire                v_cnt_willOverflow;
  wire                cnt_last;
  reg                 active_1d;
  reg                 border_en;
  reg                 fill_en;
  reg                 no_pattern;
  reg                 active_2d;
  reg        [3:0]    in_color_1_delay_1;
  reg        [3:0]    out_color_1;
  reg        [3:0]    pat_color_delay_1;
  reg        [3:0]    pat_color_delay_2;
  reg        [3:0]    pat_color_delay_3;

  assign temp_h_cnt_valueNext_1 = h_cnt_willIncrement;
  assign temp_h_cnt_valueNext = {7'd0, temp_h_cnt_valueNext_1};
  assign temp_v_cnt_valueNext_1 = v_cnt_willIncrement;
  assign temp_v_cnt_valueNext = {7'd0, temp_v_cnt_valueNext_1};
  always @(*) begin
    h_cnt_willIncrement = 1'b0;
    if(addr_comp_active) begin
      h_cnt_willIncrement = 1'b1;
    end
  end

  assign h_cnt_willClear = 1'b0;
  assign h_cnt_willOverflowIfInc = (h_cnt_value == width_reg);
  assign h_cnt_willOverflow = (h_cnt_willOverflowIfInc && h_cnt_willIncrement);
  always @(*) begin
    if(h_cnt_willOverflow) begin
      h_cnt_valueNext = 8'h0;
    end else begin
      h_cnt_valueNext = (h_cnt_value + temp_h_cnt_valueNext);
    end
    if(h_cnt_willClear) begin
      h_cnt_valueNext = 8'h0;
    end
  end

  always @(*) begin
    v_cnt_willIncrement = 1'b0;
    if((h_cnt_willOverflowIfInc && addr_comp_active)) begin
      v_cnt_willIncrement = 1'b1;
    end
  end

  assign v_cnt_willClear = 1'b0;
  assign v_cnt_willOverflowIfInc = (v_cnt_value == height_reg);
  assign v_cnt_willOverflow = (v_cnt_willOverflowIfInc && v_cnt_willIncrement);
  always @(*) begin
    if(v_cnt_willOverflow) begin
      v_cnt_valueNext = 8'h0;
    end else begin
      v_cnt_valueNext = (v_cnt_value + temp_v_cnt_valueNext);
    end
    if(v_cnt_willClear) begin
      v_cnt_valueNext = 8'h0;
    end
  end

  assign cnt_last = (v_cnt_willOverflowIfInc && h_cnt_willOverflowIfInc);
  assign out_valid = active_2d;
  assign out_color = out_color_1;
  assign done = ((! active_1d) && active_2d);
  assign h_cnt = {1'd0, h_cnt_value};
  assign v_cnt = v_cnt_value;
  assign is_running = addr_comp_active;
  always @(posedge core_clk) begin
    if(start) begin
      in_color_1 <= in_color;
    end
    in_color_1_delay_1 <= in_color_1;
    out_color_1 <= in_color_1_delay_1;
    if(((border_en || fill_en) && (! no_pattern))) begin
      out_color_1 <= pat_color_delay_3;
    end
  end

  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      width_reg <= 8'h0;
      height_reg <= 8'h0;
      fill_pattern_reg <= 2'b00;
      addr_comp_active <= 1'b0;
      h_cnt_value <= 8'h0;
      v_cnt_value <= 8'h0;
      active_1d <= 1'b0;
      border_en <= 1'b0;
      fill_en <= 1'b0;
      no_pattern <= 1'b0;
      active_2d <= 1'b0;
    end else begin
      if(start) begin
        width_reg <= width;
      end
      if(start) begin
        height_reg <= height;
      end
      if(start) begin
        fill_pattern_reg <= fill_pattern;
      end
      h_cnt_value <= h_cnt_valueNext;
      v_cnt_value <= v_cnt_valueNext;
      if(start) begin
        addr_comp_active <= 1'b1;
      end else begin
        if(cnt_last) begin
          addr_comp_active <= 1'b0;
        end
      end
      active_1d <= addr_comp_active;
      no_pattern <= (((fill_pattern_reg == 2'b00) || (width_reg < 8'h03)) || (height_reg < 8'h03));
      border_en <= (((((h_cnt_value == 8'h0) || h_cnt_willOverflowIfInc) || (v_cnt_value == 8'h0)) || v_cnt_willOverflowIfInc) && (! (fill_pattern_reg == 2'b00)));
      case(fill_pattern_reg)
        2'b10 : begin
          fill_en <= (! (h_cnt_value[0] || v_cnt_value[0]));
        end
        2'b11 : begin
          fill_en <= (h_cnt_value[1 : 0] == v_cnt_value[1 : 0]);
        end
        default : begin
          fill_en <= 1'b0;
        end
      endcase
      active_2d <= active_1d;
    end
  end

  always @(posedge core_clk) begin
    pat_color_delay_1 <= pat_color;
    pat_color_delay_2 <= pat_color_delay_1;
    pat_color_delay_3 <= pat_color_delay_2;
  end


endmodule

module draw_char_engine (
  input  wire          start,
  input  wire [6:0]    word,
  input  wire [3:0]    color,
  input  wire [2:0]    scale,
  output wire [8:0]    h_cnt,
  output wire [7:0]    v_cnt,
  output wire          is_running,
  output wire          out_valid,
  output wire [3:0]    out_color,
  output wire          done,
  input  wire          core_clk,
  input  wire          core_rst
);

  wire       [10:0]   ascii_font16X8_inst_font_bitmap_addr;
  wire       [7:0]    ascii_font16X8_inst_font_bitmap_byte;
  wire       [2:0]    temp_x_scale_cnt_valueNext;
  wire       [0:0]    temp_x_scale_cnt_valueNext_1;
  wire       [2:0]    temp_x_cnt_valueNext;
  wire       [0:0]    temp_x_cnt_valueNext_1;
  wire       [2:0]    temp_y_scale_cnt_valueNext;
  wire       [0:0]    temp_y_scale_cnt_valueNext_1;
  wire       [3:0]    temp_y_cnt_valueNext;
  wire       [0:0]    temp_y_cnt_valueNext_1;
  wire       [7:0]    temp_when;
  reg        [6:0]    word_reg;
  reg                 rom_rd_en;
  reg                 x_scale_cnt_willIncrement;
  wire                x_scale_cnt_willClear;
  reg        [2:0]    x_scale_cnt_valueNext;
  reg        [2:0]    x_scale_cnt_value;
  wire                x_scale_cnt_willOverflowIfInc;
  wire                x_scale_cnt_willOverflow;
  reg                 x_cnt_willIncrement;
  wire                x_cnt_willClear;
  reg        [2:0]    x_cnt_valueNext;
  reg        [2:0]    x_cnt_value;
  wire                x_cnt_willOverflowIfInc;
  wire                x_cnt_willOverflow;
  wire                x_last_cycle;
  reg                 y_scale_cnt_willIncrement;
  wire                y_scale_cnt_willClear;
  reg        [2:0]    y_scale_cnt_valueNext;
  reg        [2:0]    y_scale_cnt_value;
  wire                y_scale_cnt_willOverflowIfInc;
  wire                y_scale_cnt_willOverflow;
  reg                 y_cnt_willIncrement;
  wire                y_cnt_willClear;
  reg        [3:0]    y_cnt_valueNext;
  reg        [3:0]    y_cnt_value;
  wire                y_cnt_willOverflowIfInc;
  wire                y_cnt_willOverflow;
  wire                y_last_cycle;
  wire                cnt_last;
  reg        [8:0]    h_cnt_1;
  reg        [7:0]    v_cnt_1;
  reg        [3:0]    char_color;
  reg        [2:0]    pix_idx;
  reg        [3:0]    color_delay_1;
  reg                 rom_rd_en_delay_1;
  reg                 rom_rd_en_delay_2;
  reg                 rom_rd_en_regNext;

  assign temp_x_scale_cnt_valueNext_1 = x_scale_cnt_willIncrement;
  assign temp_x_scale_cnt_valueNext = {2'd0, temp_x_scale_cnt_valueNext_1};
  assign temp_x_cnt_valueNext_1 = x_cnt_willIncrement;
  assign temp_x_cnt_valueNext = {2'd0, temp_x_cnt_valueNext_1};
  assign temp_y_scale_cnt_valueNext_1 = y_scale_cnt_willIncrement;
  assign temp_y_scale_cnt_valueNext = {2'd0, temp_y_scale_cnt_valueNext_1};
  assign temp_y_cnt_valueNext_1 = y_cnt_willIncrement;
  assign temp_y_cnt_valueNext = {3'd0, temp_y_cnt_valueNext_1};
  assign temp_when = {ascii_font16X8_inst_font_bitmap_byte[0],{ascii_font16X8_inst_font_bitmap_byte[1],{ascii_font16X8_inst_font_bitmap_byte[2],{ascii_font16X8_inst_font_bitmap_byte[3],{ascii_font16X8_inst_font_bitmap_byte[4],{ascii_font16X8_inst_font_bitmap_byte[5],{ascii_font16X8_inst_font_bitmap_byte[6],ascii_font16X8_inst_font_bitmap_byte[7]}}}}}}};
  ascii_font16x8 #(
    .wordWidth    (8 ),
    .addressWidth (11)
  ) ascii_font16X8_inst (
    .clk              (core_clk                                  ), //i
    .font_bitmap_addr (ascii_font16X8_inst_font_bitmap_addr[10:0]), //i
    .font_bitmap_byte (ascii_font16X8_inst_font_bitmap_byte[7:0] )  //o
  );
  always @(*) begin
    x_scale_cnt_willIncrement = 1'b0;
    if(rom_rd_en) begin
      x_scale_cnt_willIncrement = 1'b1;
    end
  end

  assign x_scale_cnt_willClear = 1'b0;
  assign x_scale_cnt_willOverflowIfInc = (x_scale_cnt_value == scale);
  assign x_scale_cnt_willOverflow = (x_scale_cnt_willOverflowIfInc && x_scale_cnt_willIncrement);
  always @(*) begin
    if(x_scale_cnt_willOverflow) begin
      x_scale_cnt_valueNext = 3'b000;
    end else begin
      x_scale_cnt_valueNext = (x_scale_cnt_value + temp_x_scale_cnt_valueNext);
    end
    if(x_scale_cnt_willClear) begin
      x_scale_cnt_valueNext = 3'b000;
    end
  end

  always @(*) begin
    x_cnt_willIncrement = 1'b0;
    if(x_scale_cnt_willOverflow) begin
      x_cnt_willIncrement = 1'b1;
    end
  end

  assign x_cnt_willClear = 1'b0;
  assign x_cnt_willOverflowIfInc = (x_cnt_value == 3'b111);
  assign x_cnt_willOverflow = (x_cnt_willOverflowIfInc && x_cnt_willIncrement);
  always @(*) begin
    x_cnt_valueNext = (x_cnt_value + temp_x_cnt_valueNext);
    if(x_cnt_willClear) begin
      x_cnt_valueNext = 3'b000;
    end
  end

  assign x_last_cycle = (x_cnt_willOverflow && x_scale_cnt_willOverflow);
  always @(*) begin
    y_scale_cnt_willIncrement = 1'b0;
    if(x_last_cycle) begin
      y_scale_cnt_willIncrement = 1'b1;
    end
  end

  assign y_scale_cnt_willClear = 1'b0;
  assign y_scale_cnt_willOverflowIfInc = (y_scale_cnt_value == scale);
  assign y_scale_cnt_willOverflow = (y_scale_cnt_willOverflowIfInc && y_scale_cnt_willIncrement);
  always @(*) begin
    if(y_scale_cnt_willOverflow) begin
      y_scale_cnt_valueNext = 3'b000;
    end else begin
      y_scale_cnt_valueNext = (y_scale_cnt_value + temp_y_scale_cnt_valueNext);
    end
    if(y_scale_cnt_willClear) begin
      y_scale_cnt_valueNext = 3'b000;
    end
  end

  always @(*) begin
    y_cnt_willIncrement = 1'b0;
    if((y_scale_cnt_willOverflow && x_last_cycle)) begin
      y_cnt_willIncrement = 1'b1;
    end
  end

  assign y_cnt_willClear = 1'b0;
  assign y_cnt_willOverflowIfInc = (y_cnt_value == 4'b1111);
  assign y_cnt_willOverflow = (y_cnt_willOverflowIfInc && y_cnt_willIncrement);
  always @(*) begin
    y_cnt_valueNext = (y_cnt_value + temp_y_cnt_valueNext);
    if(y_cnt_willClear) begin
      y_cnt_valueNext = 4'b0000;
    end
  end

  assign y_last_cycle = (y_cnt_willOverflowIfInc && y_scale_cnt_willOverflow);
  assign cnt_last = (x_last_cycle && y_last_cycle);
  assign ascii_font16X8_inst_font_bitmap_addr = {word_reg,y_cnt_value};
  assign out_color = char_color;
  assign out_valid = rom_rd_en_delay_2;
  assign done = ((! rom_rd_en) && rom_rd_en_regNext);
  assign h_cnt = h_cnt_1;
  assign v_cnt = v_cnt_1;
  assign is_running = rom_rd_en;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      word_reg <= 7'h0;
      rom_rd_en <= 1'b0;
      x_scale_cnt_value <= 3'b000;
      x_cnt_value <= 3'b000;
      y_scale_cnt_value <= 3'b000;
      y_cnt_value <= 4'b0000;
      h_cnt_1 <= 9'h0;
      v_cnt_1 <= 8'h0;
      char_color <= 4'b0000;
      pix_idx <= 3'b000;
      rom_rd_en_delay_1 <= 1'b0;
      rom_rd_en_delay_2 <= 1'b0;
    end else begin
      if(start) begin
        word_reg <= word;
      end
      x_scale_cnt_value <= x_scale_cnt_valueNext;
      x_cnt_value <= x_cnt_valueNext;
      y_scale_cnt_value <= y_scale_cnt_valueNext;
      y_cnt_value <= y_cnt_valueNext;
      if(start) begin
        rom_rd_en <= 1'b1;
      end else begin
        if(cnt_last) begin
          rom_rd_en <= 1'b0;
        end
      end
      if(rom_rd_en) begin
        if(x_last_cycle) begin
          h_cnt_1 <= 9'h0;
        end else begin
          h_cnt_1 <= (h_cnt_1 + 9'h001);
        end
      end
      if(rom_rd_en) begin
        if(y_last_cycle) begin
          v_cnt_1 <= 8'h0;
        end else begin
          if(x_last_cycle) begin
            v_cnt_1 <= (v_cnt_1 + 8'h01);
          end
        end
      end
      pix_idx <= x_cnt_value;
      if(temp_when[pix_idx]) begin
        char_color <= color_delay_1;
      end else begin
        char_color <= 4'b0010;
      end
      rom_rd_en_delay_1 <= rom_rd_en;
      rom_rd_en_delay_2 <= rom_rd_en_delay_1;
    end
  end

  always @(posedge core_clk) begin
    color_delay_1 <= color;
  end

  always @(posedge core_clk) begin
    rom_rd_en_regNext <= rom_rd_en;
  end


endmodule

module bram_2p (
  input  wire          wr_en,
  input  wire [16:0]   wr_addr,
  input  wire [3:0]    wr_data,
  input  wire          rd_en,
  input  wire [16:0]   rd_addr,
  output wire [3:0]    rd_data,
  input  wire          clear_start,
  output wire          clear_done,
  input  wire          core_clk,
  input  wire          core_rst
);

  reg        [3:0]    memory_spinal_port1;
  wire       [16:0]   temp_full_addr_valueNext;
  wire       [0:0]    temp_full_addr_valueNext_1;
  reg                 addr_inc;
  reg                 full_addr_willIncrement;
  wire                full_addr_willClear;
  reg        [16:0]   full_addr_valueNext;
  reg        [16:0]   full_addr_value;
  wire                full_addr_willOverflowIfInc;
  wire                full_addr_willOverflow;
  reg                 addr_inc_regNext;
  wire       [16:0]   wr_addr_1;
  wire       [3:0]    wr_data_1;
  wire                wr_en_1;
  (* ram_style = "block" *) reg [3:0] memory [0:69119];

  assign temp_full_addr_valueNext_1 = full_addr_willIncrement;
  assign temp_full_addr_valueNext = {16'd0, temp_full_addr_valueNext_1};
  initial begin
    $readmemb("pcb.v_toplevel_tetris_top_inst_tetris_core_inst_game_display_inst_fb_memory.bin",memory);
  end
  always @(posedge core_clk) begin
    if(wr_en_1) begin
      memory[wr_addr_1] <= wr_data_1;
    end
  end

  always @(posedge core_clk) begin
    if(rd_en) begin
      memory_spinal_port1 <= memory[rd_addr];
    end
  end

  always @(*) begin
    full_addr_willIncrement = 1'b0;
    if(addr_inc) begin
      full_addr_willIncrement = 1'b1;
    end
  end

  assign full_addr_willClear = 1'b0;
  assign full_addr_willOverflowIfInc = (full_addr_value == 17'h10dff);
  assign full_addr_willOverflow = (full_addr_willOverflowIfInc && full_addr_willIncrement);
  always @(*) begin
    if(full_addr_willOverflow) begin
      full_addr_valueNext = 17'h0;
    end else begin
      full_addr_valueNext = (full_addr_value + temp_full_addr_valueNext);
    end
    if(full_addr_willClear) begin
      full_addr_valueNext = 17'h0;
    end
  end

  assign clear_done = ((! addr_inc) && addr_inc_regNext);
  assign wr_addr_1 = (addr_inc ? full_addr_value : wr_addr);
  assign wr_data_1 = (addr_inc ? 4'b0010 : wr_data);
  assign wr_en_1 = (addr_inc || wr_en);
  assign rd_data = memory_spinal_port1;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      addr_inc <= 1'b0;
      full_addr_value <= 17'h0;
      addr_inc_regNext <= 1'b0;
    end else begin
      if(clear_start) begin
        addr_inc <= 1'b1;
      end
      full_addr_value <= full_addr_valueNext;
      if(full_addr_willOverflow) begin
        addr_inc <= 1'b0;
      end
      addr_inc_regNext <= addr_inc;
    end
  end


endmodule

module play_field (
  input  wire          block_pos_valid,
  input  wire [3:0]    block_pos_payload_x,
  input  wire [4:0]    block_pos_payload_y,
  input  wire          update,
  input  wire          clear_start,
  input  wire          block_set,
  input  wire          restart,
  input  wire          fetch,
  output reg           clear_done,
  output wire          block_val_valid,
  output wire          block_val_payload,
  output wire          row_val_valid,
  output wire [9:0]    row_val_payload,
  output reg           lines_cleared_valid,
  output reg  [4:0]    lines_cleared_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam IDLE = 3'd0;
  localparam ENABLE_ROWS = 3'd1;
  localparam ROWS_FULL_READY = 3'd2;
  localparam LOCK = 3'd3;
  localparam CHECK = 3'd4;
  localparam CLEAR = 3'd5;
  localparam SHIFT = 3'd6;

  wire                row_0_io_row;
  wire                shift_ctrl_0_io_full_locked;
  wire                row_1_io_row;
  wire                shift_ctrl_1_1_io_full_locked;
  wire                row_2_io_row;
  wire                shift_ctrl_2_1_io_full_locked;
  wire                row_3_io_row;
  wire                shift_ctrl_3_1_io_full_locked;
  wire                row_4_io_row;
  wire                shift_ctrl_4_1_io_full_locked;
  wire                row_5_io_row;
  wire                shift_ctrl_5_1_io_full_locked;
  wire                row_6_io_row;
  wire                shift_ctrl_6_1_io_full_locked;
  wire                row_7_io_row;
  wire                shift_ctrl_7_1_io_full_locked;
  wire                row_8_io_row;
  wire                shift_ctrl_8_1_io_full_locked;
  wire                row_9_io_row;
  wire                shift_ctrl_9_1_io_full_locked;
  wire                row_10_io_row;
  wire                shift_ctrl_10_1_io_full_locked;
  wire                row_11_io_row;
  wire                shift_ctrl_11_1_io_full_locked;
  wire                row_12_io_row;
  wire                shift_ctrl_12_1_io_full_locked;
  wire                row_13_io_row;
  wire                shift_ctrl_13_1_io_full_locked;
  wire                row_14_io_row;
  wire                shift_ctrl_14_1_io_full_locked;
  wire                row_15_io_row;
  wire                shift_ctrl_15_1_io_full_locked;
  wire                row_16_io_row;
  wire                shift_ctrl_16_1_io_full_locked;
  wire                row_17_io_row;
  wire                shift_ctrl_17_1_io_full_locked;
  wire                row_18_io_row;
  wire                shift_ctrl_18_1_io_full_locked;
  wire                row_19_io_row;
  wire                shift_ctrl_19_1_io_full_locked;
  wire                row_20_io_row;
  wire                shift_ctrl_20_1_io_full_locked;
  wire                row_21_io_row;
  wire                shift_ctrl_21_1_io_full_locked;
  wire       [9:0]    row_0_io_blocks_out;
  wire                row_0_io_full;
  wire                shift_ctrl_0_io_full_out;
  wire                shift_ctrl_0_io_holes_out;
  wire                shift_ctrl_0_io_shift_en;
  wire                shift_ctrl_0_io_clear_en;
  wire       [9:0]    row_1_io_blocks_out;
  wire                row_1_io_full;
  wire                shift_ctrl_1_1_io_full_out;
  wire                shift_ctrl_1_1_io_holes_out;
  wire                shift_ctrl_1_1_io_shift_en;
  wire                shift_ctrl_1_1_io_clear_en;
  wire       [9:0]    row_2_io_blocks_out;
  wire                row_2_io_full;
  wire                shift_ctrl_2_1_io_full_out;
  wire                shift_ctrl_2_1_io_holes_out;
  wire                shift_ctrl_2_1_io_shift_en;
  wire                shift_ctrl_2_1_io_clear_en;
  wire       [9:0]    row_3_io_blocks_out;
  wire                row_3_io_full;
  wire                shift_ctrl_3_1_io_full_out;
  wire                shift_ctrl_3_1_io_holes_out;
  wire                shift_ctrl_3_1_io_shift_en;
  wire                shift_ctrl_3_1_io_clear_en;
  wire       [9:0]    row_4_io_blocks_out;
  wire                row_4_io_full;
  wire                shift_ctrl_4_1_io_full_out;
  wire                shift_ctrl_4_1_io_holes_out;
  wire                shift_ctrl_4_1_io_shift_en;
  wire                shift_ctrl_4_1_io_clear_en;
  wire       [9:0]    row_5_io_blocks_out;
  wire                row_5_io_full;
  wire                shift_ctrl_5_1_io_full_out;
  wire                shift_ctrl_5_1_io_holes_out;
  wire                shift_ctrl_5_1_io_shift_en;
  wire                shift_ctrl_5_1_io_clear_en;
  wire       [9:0]    row_6_io_blocks_out;
  wire                row_6_io_full;
  wire                shift_ctrl_6_1_io_full_out;
  wire                shift_ctrl_6_1_io_holes_out;
  wire                shift_ctrl_6_1_io_shift_en;
  wire                shift_ctrl_6_1_io_clear_en;
  wire       [9:0]    row_7_io_blocks_out;
  wire                row_7_io_full;
  wire                shift_ctrl_7_1_io_full_out;
  wire                shift_ctrl_7_1_io_holes_out;
  wire                shift_ctrl_7_1_io_shift_en;
  wire                shift_ctrl_7_1_io_clear_en;
  wire       [9:0]    row_8_io_blocks_out;
  wire                row_8_io_full;
  wire                shift_ctrl_8_1_io_full_out;
  wire                shift_ctrl_8_1_io_holes_out;
  wire                shift_ctrl_8_1_io_shift_en;
  wire                shift_ctrl_8_1_io_clear_en;
  wire       [9:0]    row_9_io_blocks_out;
  wire                row_9_io_full;
  wire                shift_ctrl_9_1_io_full_out;
  wire                shift_ctrl_9_1_io_holes_out;
  wire                shift_ctrl_9_1_io_shift_en;
  wire                shift_ctrl_9_1_io_clear_en;
  wire       [9:0]    row_10_io_blocks_out;
  wire                row_10_io_full;
  wire                shift_ctrl_10_1_io_full_out;
  wire                shift_ctrl_10_1_io_holes_out;
  wire                shift_ctrl_10_1_io_shift_en;
  wire                shift_ctrl_10_1_io_clear_en;
  wire       [9:0]    row_11_io_blocks_out;
  wire                row_11_io_full;
  wire                shift_ctrl_11_1_io_full_out;
  wire                shift_ctrl_11_1_io_holes_out;
  wire                shift_ctrl_11_1_io_shift_en;
  wire                shift_ctrl_11_1_io_clear_en;
  wire       [9:0]    row_12_io_blocks_out;
  wire                row_12_io_full;
  wire                shift_ctrl_12_1_io_full_out;
  wire                shift_ctrl_12_1_io_holes_out;
  wire                shift_ctrl_12_1_io_shift_en;
  wire                shift_ctrl_12_1_io_clear_en;
  wire       [9:0]    row_13_io_blocks_out;
  wire                row_13_io_full;
  wire                shift_ctrl_13_1_io_full_out;
  wire                shift_ctrl_13_1_io_holes_out;
  wire                shift_ctrl_13_1_io_shift_en;
  wire                shift_ctrl_13_1_io_clear_en;
  wire       [9:0]    row_14_io_blocks_out;
  wire                row_14_io_full;
  wire                shift_ctrl_14_1_io_full_out;
  wire                shift_ctrl_14_1_io_holes_out;
  wire                shift_ctrl_14_1_io_shift_en;
  wire                shift_ctrl_14_1_io_clear_en;
  wire       [9:0]    row_15_io_blocks_out;
  wire                row_15_io_full;
  wire                shift_ctrl_15_1_io_full_out;
  wire                shift_ctrl_15_1_io_holes_out;
  wire                shift_ctrl_15_1_io_shift_en;
  wire                shift_ctrl_15_1_io_clear_en;
  wire       [9:0]    row_16_io_blocks_out;
  wire                row_16_io_full;
  wire                shift_ctrl_16_1_io_full_out;
  wire                shift_ctrl_16_1_io_holes_out;
  wire                shift_ctrl_16_1_io_shift_en;
  wire                shift_ctrl_16_1_io_clear_en;
  wire       [9:0]    row_17_io_blocks_out;
  wire                row_17_io_full;
  wire                shift_ctrl_17_1_io_full_out;
  wire                shift_ctrl_17_1_io_holes_out;
  wire                shift_ctrl_17_1_io_shift_en;
  wire                shift_ctrl_17_1_io_clear_en;
  wire       [9:0]    row_18_io_blocks_out;
  wire                row_18_io_full;
  wire                shift_ctrl_18_1_io_full_out;
  wire                shift_ctrl_18_1_io_holes_out;
  wire                shift_ctrl_18_1_io_shift_en;
  wire                shift_ctrl_18_1_io_clear_en;
  wire       [9:0]    row_19_io_blocks_out;
  wire                row_19_io_full;
  wire                shift_ctrl_19_1_io_full_out;
  wire                shift_ctrl_19_1_io_holes_out;
  wire                shift_ctrl_19_1_io_shift_en;
  wire                shift_ctrl_19_1_io_clear_en;
  wire       [9:0]    row_20_io_blocks_out;
  wire                row_20_io_full;
  wire                shift_ctrl_20_1_io_full_out;
  wire                shift_ctrl_20_1_io_holes_out;
  wire                shift_ctrl_20_1_io_shift_en;
  wire                shift_ctrl_20_1_io_clear_en;
  wire       [9:0]    row_21_io_blocks_out;
  wire                row_21_io_full;
  wire                shift_ctrl_21_1_io_full_out;
  wire                shift_ctrl_21_1_io_holes_out;
  wire                shift_ctrl_21_1_io_shift_en;
  wire                shift_ctrl_21_1_io_clear_en;
  wire       [4:0]    temp_lines_cleared_payload_8;
  wire       [4:0]    temp_lines_cleared_payload_9;
  reg        [4:0]    temp_lines_cleared_payload_10;
  wire       [2:0]    temp_lines_cleared_payload_11;
  reg        [4:0]    temp_lines_cleared_payload_12;
  wire       [2:0]    temp_lines_cleared_payload_13;
  wire       [4:0]    temp_lines_cleared_payload_14;
  reg        [4:0]    temp_lines_cleared_payload_15;
  wire       [2:0]    temp_lines_cleared_payload_16;
  reg        [4:0]    temp_lines_cleared_payload_17;
  wire       [2:0]    temp_lines_cleared_payload_18;
  wire       [4:0]    temp_lines_cleared_payload_19;
  wire       [4:0]    temp_lines_cleared_payload_20;
  reg        [4:0]    temp_lines_cleared_payload_21;
  wire       [2:0]    temp_lines_cleared_payload_22;
  reg        [4:0]    temp_lines_cleared_payload_23;
  wire       [2:0]    temp_lines_cleared_payload_24;
  wire       [4:0]    temp_lines_cleared_payload_25;
  reg        [4:0]    temp_lines_cleared_payload_26;
  wire       [2:0]    temp_lines_cleared_payload_27;
  reg        [4:0]    temp_lines_cleared_payload_28;
  wire       [2:0]    temp_lines_cleared_payload_29;
  wire       [0:0]    temp_lines_cleared_payload_30;
  wire       [9:0]    temp_row_status;
  reg                 enable_rows;
  reg                 lock;
  reg                 clear;
  reg                 shift;
  wire                shift_done;
  reg        [21:0]   rows_full;
  wire       [4:0]    temp_lines_cleared_payload;
  wire       [4:0]    temp_lines_cleared_payload_1;
  wire       [4:0]    temp_lines_cleared_payload_2;
  wire       [4:0]    temp_lines_cleared_payload_3;
  wire       [4:0]    temp_lines_cleared_payload_4;
  wire       [4:0]    temp_lines_cleared_payload_5;
  wire       [4:0]    temp_lines_cleared_payload_6;
  wire       [4:0]    temp_lines_cleared_payload_7;
  wire       [9:0]    rowsblocks_0;
  wire       [9:0]    rowsblocks_1;
  wire       [9:0]    rowsblocks_2;
  wire       [9:0]    rowsblocks_3;
  wire       [9:0]    rowsblocks_4;
  wire       [9:0]    rowsblocks_5;
  wire       [9:0]    rowsblocks_6;
  wire       [9:0]    rowsblocks_7;
  wire       [9:0]    rowsblocks_8;
  wire       [9:0]    rowsblocks_9;
  wire       [9:0]    rowsblocks_10;
  wire       [9:0]    rowsblocks_11;
  wire       [9:0]    rowsblocks_12;
  wire       [9:0]    rowsblocks_13;
  wire       [9:0]    rowsblocks_14;
  wire       [9:0]    rowsblocks_15;
  wire       [9:0]    rowsblocks_16;
  wire       [9:0]    rowsblocks_17;
  wire       [9:0]    rowsblocks_18;
  wire       [9:0]    rowsblocks_19;
  wire       [9:0]    rowsblocks_20;
  wire       [9:0]    rowsblocks_21;
  reg        [9:0]    cols_select;
  reg        [21:0]   rows_select;
  reg                 fetch_runing;
  wire                clear_fsm_wantExit;
  reg                 clear_fsm_wantStart;
  wire                clear_fsm_wantKill;
  reg                 update_en;
  reg                 temp_shift_done;
  reg                 block_pos_valid_regNext;
  wire       [9:0]    row_status;
  reg                 fetch_runing_regNext;
  reg        [9:0]    row_status_regNext;
  reg        [2:0]    clear_fsm_stateReg;
  reg        [2:0]    clear_fsm_stateNext;
  wire                clear_fsm_onExit_IDLE;
  wire                clear_fsm_onExit_ENABLE_ROWS;
  wire                clear_fsm_onExit_ROWS_FULL_READY;
  wire                clear_fsm_onExit_LOCK;
  wire                clear_fsm_onExit_CHECK;
  wire                clear_fsm_onExit_CLEAR;
  wire                clear_fsm_onExit_SHIFT;
  wire                clear_fsm_onEntry_IDLE;
  wire                clear_fsm_onEntry_ENABLE_ROWS;
  wire                clear_fsm_onEntry_ROWS_FULL_READY;
  wire                clear_fsm_onEntry_LOCK;
  wire                clear_fsm_onEntry_CHECK;
  wire                clear_fsm_onEntry_CLEAR;
  wire                clear_fsm_onEntry_SHIFT;
  `ifndef SYNTHESIS
  reg [119:0] clear_fsm_stateReg_string;
  reg [119:0] clear_fsm_stateNext_string;
  `endif


  assign temp_lines_cleared_payload_8 = (temp_lines_cleared_payload_9 + temp_lines_cleared_payload_14);
  assign temp_lines_cleared_payload_9 = (temp_lines_cleared_payload_10 + temp_lines_cleared_payload_12);
  assign temp_lines_cleared_payload_14 = (temp_lines_cleared_payload_15 + temp_lines_cleared_payload_17);
  assign temp_lines_cleared_payload_19 = (temp_lines_cleared_payload_20 + temp_lines_cleared_payload_25);
  assign temp_lines_cleared_payload_20 = (temp_lines_cleared_payload_21 + temp_lines_cleared_payload_23);
  assign temp_lines_cleared_payload_25 = (temp_lines_cleared_payload_26 + temp_lines_cleared_payload_28);
  assign temp_lines_cleared_payload_30 = rows_full[21];
  assign temp_lines_cleared_payload_29 = {2'd0, temp_lines_cleared_payload_30};
  assign temp_lines_cleared_payload_11 = {rows_full[2],{rows_full[1],rows_full[0]}};
  assign temp_lines_cleared_payload_13 = {rows_full[5],{rows_full[4],rows_full[3]}};
  assign temp_lines_cleared_payload_16 = {rows_full[8],{rows_full[7],rows_full[6]}};
  assign temp_lines_cleared_payload_18 = {rows_full[11],{rows_full[10],rows_full[9]}};
  assign temp_lines_cleared_payload_22 = {rows_full[14],{rows_full[13],rows_full[12]}};
  assign temp_lines_cleared_payload_24 = {rows_full[17],{rows_full[16],rows_full[15]}};
  assign temp_lines_cleared_payload_27 = {rows_full[20],{rows_full[19],rows_full[18]}};
  assign temp_row_status = ((((((10'h0 | rowsblocks_0) | rowsblocks_1) | rowsblocks_2) | rowsblocks_3) | rowsblocks_4) | rowsblocks_5);
  row_blocks row_0 (
    .io_row        (row_0_io_row            ), //i
    .io_cols       (cols_select[9:0]        ), //i
    .io_block_pos  (10'h0                   ), //i
    .io_shift      (shift_ctrl_0_io_shift_en), //i
    .io_update     (update_en               ), //i
    .io_block_set  (block_set               ), //i
    .io_clear      (shift_ctrl_0_io_clear_en), //i
    .io_blocks_out (row_0_io_blocks_out[9:0]), //o
    .io_full       (row_0_io_full           ), //o
    .core_clk      (core_clk                ), //i
    .core_rst      (core_rst                )  //i
  );
  shift_ctrl shift_ctrl_0 (
    .io_full_in     (1'b0                       ), //i
    .io_full_out    (shift_ctrl_0_io_full_out   ), //o
    .io_full_locked (shift_ctrl_0_io_full_locked), //i
    .io_lock        (lock                       ), //i
    .io_restart     (restart                    ), //i
    .io_shift       (shift                      ), //i
    .io_clear       (clear                      ), //i
    .io_holes_in    (shift_ctrl_1_1_io_holes_out), //i
    .io_holes_out   (shift_ctrl_0_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_0_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_0_io_clear_en   ), //o
    .core_clk       (core_clk                   ), //i
    .core_rst       (core_rst                   )  //i
  );
  row_blocks row_1 (
    .io_row        (row_1_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_0[9:0]         ), //i
    .io_shift      (shift_ctrl_1_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_1_1_io_clear_en), //i
    .io_blocks_out (row_1_io_blocks_out[9:0]  ), //o
    .io_full       (row_1_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_1_1 (
    .io_full_in     (shift_ctrl_0_io_full_out     ), //i
    .io_full_out    (shift_ctrl_1_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_1_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_2_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_1_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_1_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_1_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_2 (
    .io_row        (row_2_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_1[9:0]         ), //i
    .io_shift      (shift_ctrl_2_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_2_1_io_clear_en), //i
    .io_blocks_out (row_2_io_blocks_out[9:0]  ), //o
    .io_full       (row_2_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_2_1 (
    .io_full_in     (shift_ctrl_1_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_2_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_2_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_3_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_2_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_2_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_2_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_3 (
    .io_row        (row_3_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_2[9:0]         ), //i
    .io_shift      (shift_ctrl_3_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_3_1_io_clear_en), //i
    .io_blocks_out (row_3_io_blocks_out[9:0]  ), //o
    .io_full       (row_3_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_3_1 (
    .io_full_in     (shift_ctrl_2_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_3_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_3_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_4_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_3_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_3_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_3_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_4 (
    .io_row        (row_4_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_3[9:0]         ), //i
    .io_shift      (shift_ctrl_4_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_4_1_io_clear_en), //i
    .io_blocks_out (row_4_io_blocks_out[9:0]  ), //o
    .io_full       (row_4_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_4_1 (
    .io_full_in     (shift_ctrl_3_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_4_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_4_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_5_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_4_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_4_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_4_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_5 (
    .io_row        (row_5_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_4[9:0]         ), //i
    .io_shift      (shift_ctrl_5_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_5_1_io_clear_en), //i
    .io_blocks_out (row_5_io_blocks_out[9:0]  ), //o
    .io_full       (row_5_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_5_1 (
    .io_full_in     (shift_ctrl_4_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_5_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_5_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_6_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_5_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_5_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_5_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_6 (
    .io_row        (row_6_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_5[9:0]         ), //i
    .io_shift      (shift_ctrl_6_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_6_1_io_clear_en), //i
    .io_blocks_out (row_6_io_blocks_out[9:0]  ), //o
    .io_full       (row_6_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_6_1 (
    .io_full_in     (shift_ctrl_5_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_6_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_6_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_7_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_6_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_6_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_6_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_7 (
    .io_row        (row_7_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_6[9:0]         ), //i
    .io_shift      (shift_ctrl_7_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_7_1_io_clear_en), //i
    .io_blocks_out (row_7_io_blocks_out[9:0]  ), //o
    .io_full       (row_7_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_7_1 (
    .io_full_in     (shift_ctrl_6_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_7_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_7_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_8_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_7_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_7_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_7_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_8 (
    .io_row        (row_8_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_7[9:0]         ), //i
    .io_shift      (shift_ctrl_8_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_8_1_io_clear_en), //i
    .io_blocks_out (row_8_io_blocks_out[9:0]  ), //o
    .io_full       (row_8_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_8_1 (
    .io_full_in     (shift_ctrl_7_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_8_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_8_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_9_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_8_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_8_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_8_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_9 (
    .io_row        (row_9_io_row              ), //i
    .io_cols       (cols_select[9:0]          ), //i
    .io_block_pos  (rowsblocks_8[9:0]         ), //i
    .io_shift      (shift_ctrl_9_1_io_shift_en), //i
    .io_update     (update_en                 ), //i
    .io_block_set  (block_set                 ), //i
    .io_clear      (shift_ctrl_9_1_io_clear_en), //i
    .io_blocks_out (row_9_io_blocks_out[9:0]  ), //o
    .io_full       (row_9_io_full             ), //o
    .core_clk      (core_clk                  ), //i
    .core_rst      (core_rst                  )  //i
  );
  shift_ctrl shift_ctrl_9_1 (
    .io_full_in     (shift_ctrl_8_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_9_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_9_1_io_full_locked), //i
    .io_lock        (lock                         ), //i
    .io_restart     (restart                      ), //i
    .io_shift       (shift                        ), //i
    .io_clear       (clear                        ), //i
    .io_holes_in    (shift_ctrl_10_1_io_holes_out ), //i
    .io_holes_out   (shift_ctrl_9_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_9_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_9_1_io_clear_en   ), //o
    .core_clk       (core_clk                     ), //i
    .core_rst       (core_rst                     )  //i
  );
  row_blocks row_10 (
    .io_row        (row_10_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_9[9:0]          ), //i
    .io_shift      (shift_ctrl_10_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_10_1_io_clear_en), //i
    .io_blocks_out (row_10_io_blocks_out[9:0]  ), //o
    .io_full       (row_10_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_10_1 (
    .io_full_in     (shift_ctrl_9_1_io_full_out    ), //i
    .io_full_out    (shift_ctrl_10_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_10_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_11_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_10_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_10_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_10_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_11 (
    .io_row        (row_11_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_10[9:0]         ), //i
    .io_shift      (shift_ctrl_11_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_11_1_io_clear_en), //i
    .io_blocks_out (row_11_io_blocks_out[9:0]  ), //o
    .io_full       (row_11_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_11_1 (
    .io_full_in     (shift_ctrl_10_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_11_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_11_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_12_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_11_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_11_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_11_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_12 (
    .io_row        (row_12_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_11[9:0]         ), //i
    .io_shift      (shift_ctrl_12_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_12_1_io_clear_en), //i
    .io_blocks_out (row_12_io_blocks_out[9:0]  ), //o
    .io_full       (row_12_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_12_1 (
    .io_full_in     (shift_ctrl_11_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_12_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_12_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_13_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_12_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_12_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_12_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_13 (
    .io_row        (row_13_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_12[9:0]         ), //i
    .io_shift      (shift_ctrl_13_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_13_1_io_clear_en), //i
    .io_blocks_out (row_13_io_blocks_out[9:0]  ), //o
    .io_full       (row_13_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_13_1 (
    .io_full_in     (shift_ctrl_12_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_13_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_13_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_14_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_13_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_13_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_13_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_14 (
    .io_row        (row_14_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_13[9:0]         ), //i
    .io_shift      (shift_ctrl_14_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_14_1_io_clear_en), //i
    .io_blocks_out (row_14_io_blocks_out[9:0]  ), //o
    .io_full       (row_14_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_14_1 (
    .io_full_in     (shift_ctrl_13_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_14_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_14_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_15_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_14_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_14_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_14_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_15 (
    .io_row        (row_15_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_14[9:0]         ), //i
    .io_shift      (shift_ctrl_15_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_15_1_io_clear_en), //i
    .io_blocks_out (row_15_io_blocks_out[9:0]  ), //o
    .io_full       (row_15_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_15_1 (
    .io_full_in     (shift_ctrl_14_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_15_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_15_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_16_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_15_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_15_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_15_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_16 (
    .io_row        (row_16_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_15[9:0]         ), //i
    .io_shift      (shift_ctrl_16_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_16_1_io_clear_en), //i
    .io_blocks_out (row_16_io_blocks_out[9:0]  ), //o
    .io_full       (row_16_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_16_1 (
    .io_full_in     (shift_ctrl_15_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_16_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_16_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_17_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_16_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_16_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_16_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_17 (
    .io_row        (row_17_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_16[9:0]         ), //i
    .io_shift      (shift_ctrl_17_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_17_1_io_clear_en), //i
    .io_blocks_out (row_17_io_blocks_out[9:0]  ), //o
    .io_full       (row_17_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_17_1 (
    .io_full_in     (shift_ctrl_16_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_17_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_17_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_18_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_17_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_17_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_17_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_18 (
    .io_row        (row_18_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_17[9:0]         ), //i
    .io_shift      (shift_ctrl_18_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_18_1_io_clear_en), //i
    .io_blocks_out (row_18_io_blocks_out[9:0]  ), //o
    .io_full       (row_18_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_18_1 (
    .io_full_in     (shift_ctrl_17_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_18_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_18_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_19_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_18_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_18_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_18_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_19 (
    .io_row        (row_19_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_18[9:0]         ), //i
    .io_shift      (shift_ctrl_19_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_19_1_io_clear_en), //i
    .io_blocks_out (row_19_io_blocks_out[9:0]  ), //o
    .io_full       (row_19_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_19_1 (
    .io_full_in     (shift_ctrl_18_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_19_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_19_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_20_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_19_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_19_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_19_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_20 (
    .io_row        (row_20_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_19[9:0]         ), //i
    .io_shift      (shift_ctrl_20_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_20_1_io_clear_en), //i
    .io_blocks_out (row_20_io_blocks_out[9:0]  ), //o
    .io_full       (row_20_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_20_1 (
    .io_full_in     (shift_ctrl_19_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_20_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_20_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (shift_ctrl_21_1_io_holes_out  ), //i
    .io_holes_out   (shift_ctrl_20_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_20_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_20_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  row_blocks row_21 (
    .io_row        (row_21_io_row              ), //i
    .io_cols       (cols_select[9:0]           ), //i
    .io_block_pos  (rowsblocks_20[9:0]         ), //i
    .io_shift      (shift_ctrl_21_1_io_shift_en), //i
    .io_update     (update_en                  ), //i
    .io_block_set  (block_set                  ), //i
    .io_clear      (shift_ctrl_21_1_io_clear_en), //i
    .io_blocks_out (row_21_io_blocks_out[9:0]  ), //o
    .io_full       (row_21_io_full             ), //o
    .core_clk      (core_clk                   ), //i
    .core_rst      (core_rst                   )  //i
  );
  shift_ctrl shift_ctrl_21_1 (
    .io_full_in     (shift_ctrl_20_1_io_full_out   ), //i
    .io_full_out    (shift_ctrl_21_1_io_full_out   ), //o
    .io_full_locked (shift_ctrl_21_1_io_full_locked), //i
    .io_lock        (lock                          ), //i
    .io_restart     (restart                       ), //i
    .io_shift       (shift                         ), //i
    .io_clear       (clear                         ), //i
    .io_holes_in    (1'b0                          ), //i
    .io_holes_out   (shift_ctrl_21_1_io_holes_out  ), //o
    .io_shift_en    (shift_ctrl_21_1_io_shift_en   ), //o
    .io_clear_en    (shift_ctrl_21_1_io_clear_en   ), //o
    .core_clk       (core_clk                      ), //i
    .core_rst       (core_rst                      )  //i
  );
  always @(*) begin
    case(temp_lines_cleared_payload_11)
      3'b000 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_10 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_13)
      3'b000 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_12 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_16)
      3'b000 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_15 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_18)
      3'b000 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_17 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_22)
      3'b000 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_21 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_24)
      3'b000 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_23 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_27)
      3'b000 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_26 = temp_lines_cleared_payload_7;
    endcase
  end

  always @(*) begin
    case(temp_lines_cleared_payload_29)
      3'b000 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload;
      3'b001 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_1;
      3'b010 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_2;
      3'b011 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_3;
      3'b100 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_4;
      3'b101 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_5;
      3'b110 : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_6;
      default : temp_lines_cleared_payload_28 = temp_lines_cleared_payload_7;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(clear_fsm_stateReg)
      IDLE : clear_fsm_stateReg_string = "IDLE           ";
      ENABLE_ROWS : clear_fsm_stateReg_string = "ENABLE_ROWS    ";
      ROWS_FULL_READY : clear_fsm_stateReg_string = "ROWS_FULL_READY";
      LOCK : clear_fsm_stateReg_string = "LOCK           ";
      CHECK : clear_fsm_stateReg_string = "CHECK          ";
      CLEAR : clear_fsm_stateReg_string = "CLEAR          ";
      SHIFT : clear_fsm_stateReg_string = "SHIFT          ";
      default : clear_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(clear_fsm_stateNext)
      IDLE : clear_fsm_stateNext_string = "IDLE           ";
      ENABLE_ROWS : clear_fsm_stateNext_string = "ENABLE_ROWS    ";
      ROWS_FULL_READY : clear_fsm_stateNext_string = "ROWS_FULL_READY";
      LOCK : clear_fsm_stateNext_string = "LOCK           ";
      CHECK : clear_fsm_stateNext_string = "CHECK          ";
      CLEAR : clear_fsm_stateNext_string = "CLEAR          ";
      SHIFT : clear_fsm_stateNext_string = "SHIFT          ";
      default : clear_fsm_stateNext_string = "???????????????";
    endcase
  end
  `endif

  assign temp_lines_cleared_payload = 5'h0;
  assign temp_lines_cleared_payload_1 = 5'h01;
  assign temp_lines_cleared_payload_2 = 5'h01;
  assign temp_lines_cleared_payload_3 = 5'h02;
  assign temp_lines_cleared_payload_4 = 5'h01;
  assign temp_lines_cleared_payload_5 = 5'h02;
  assign temp_lines_cleared_payload_6 = 5'h02;
  assign temp_lines_cleared_payload_7 = 5'h03;
  assign clear_fsm_wantExit = 1'b0;
  always @(*) begin
    clear_fsm_wantStart = 1'b0;
    enable_rows = 1'b0;
    lock = 1'b0;
    clear = 1'b0;
    shift = 1'b0;
    clear_done = 1'b0;
    clear_fsm_stateNext = clear_fsm_stateReg;
    case(clear_fsm_stateReg)
      ENABLE_ROWS : begin
        enable_rows = 1'b1;
        clear_fsm_stateNext = ROWS_FULL_READY;
      end
      ROWS_FULL_READY : begin
        clear_fsm_stateNext = LOCK;
      end
      LOCK : begin
        lock = 1'b1;
        clear_fsm_stateNext = CHECK;
      end
      CHECK : begin
        if(shift_ctrl_0_io_holes_out) begin
          clear_fsm_stateNext = CLEAR;
        end else begin
          clear_done = 1'b1;
          clear_fsm_stateNext = IDLE;
        end
      end
      CLEAR : begin
        clear = 1'b1;
        clear_fsm_stateNext = SHIFT;
      end
      SHIFT : begin
        shift = 1'b1;
        if(shift_done) begin
          clear_fsm_stateNext = ENABLE_ROWS;
        end
      end
      default : begin
        if(clear_start) begin
          clear_fsm_stateNext = ENABLE_ROWS;
        end
        clear_fsm_wantStart = 1'b1;
      end
    endcase
    if(clear_fsm_wantKill) begin
      clear_fsm_stateNext = IDLE;
    end
  end

  assign clear_fsm_wantKill = 1'b0;
  assign shift_ctrl_0_io_full_locked = rows_full[0];
  assign row_0_io_row = rows_select[0];
  assign rowsblocks_0 = row_0_io_blocks_out;
  assign shift_ctrl_1_1_io_full_locked = rows_full[1];
  assign row_1_io_row = rows_select[1];
  assign rowsblocks_1 = row_1_io_blocks_out;
  assign shift_ctrl_2_1_io_full_locked = rows_full[2];
  assign row_2_io_row = rows_select[2];
  assign rowsblocks_2 = row_2_io_blocks_out;
  assign shift_ctrl_3_1_io_full_locked = rows_full[3];
  assign row_3_io_row = rows_select[3];
  assign rowsblocks_3 = row_3_io_blocks_out;
  assign shift_ctrl_4_1_io_full_locked = rows_full[4];
  assign row_4_io_row = rows_select[4];
  assign rowsblocks_4 = row_4_io_blocks_out;
  assign shift_ctrl_5_1_io_full_locked = rows_full[5];
  assign row_5_io_row = rows_select[5];
  assign rowsblocks_5 = row_5_io_blocks_out;
  assign shift_ctrl_6_1_io_full_locked = rows_full[6];
  assign row_6_io_row = rows_select[6];
  assign rowsblocks_6 = row_6_io_blocks_out;
  assign shift_ctrl_7_1_io_full_locked = rows_full[7];
  assign row_7_io_row = rows_select[7];
  assign rowsblocks_7 = row_7_io_blocks_out;
  assign shift_ctrl_8_1_io_full_locked = rows_full[8];
  assign row_8_io_row = rows_select[8];
  assign rowsblocks_8 = row_8_io_blocks_out;
  assign shift_ctrl_9_1_io_full_locked = rows_full[9];
  assign row_9_io_row = rows_select[9];
  assign rowsblocks_9 = row_9_io_blocks_out;
  assign shift_ctrl_10_1_io_full_locked = rows_full[10];
  assign row_10_io_row = rows_select[10];
  assign rowsblocks_10 = row_10_io_blocks_out;
  assign shift_ctrl_11_1_io_full_locked = rows_full[11];
  assign row_11_io_row = rows_select[11];
  assign rowsblocks_11 = row_11_io_blocks_out;
  assign shift_ctrl_12_1_io_full_locked = rows_full[12];
  assign row_12_io_row = rows_select[12];
  assign rowsblocks_12 = row_12_io_blocks_out;
  assign shift_ctrl_13_1_io_full_locked = rows_full[13];
  assign row_13_io_row = rows_select[13];
  assign rowsblocks_13 = row_13_io_blocks_out;
  assign shift_ctrl_14_1_io_full_locked = rows_full[14];
  assign row_14_io_row = rows_select[14];
  assign rowsblocks_14 = row_14_io_blocks_out;
  assign shift_ctrl_15_1_io_full_locked = rows_full[15];
  assign row_15_io_row = rows_select[15];
  assign rowsblocks_15 = row_15_io_blocks_out;
  assign shift_ctrl_16_1_io_full_locked = rows_full[16];
  assign row_16_io_row = rows_select[16];
  assign rowsblocks_16 = row_16_io_blocks_out;
  assign shift_ctrl_17_1_io_full_locked = rows_full[17];
  assign row_17_io_row = rows_select[17];
  assign rowsblocks_17 = row_17_io_blocks_out;
  assign shift_ctrl_18_1_io_full_locked = rows_full[18];
  assign row_18_io_row = rows_select[18];
  assign rowsblocks_18 = row_18_io_blocks_out;
  assign shift_ctrl_19_1_io_full_locked = rows_full[19];
  assign row_19_io_row = rows_select[19];
  assign rowsblocks_19 = row_19_io_blocks_out;
  assign shift_ctrl_20_1_io_full_locked = rows_full[20];
  assign row_20_io_row = rows_select[20];
  assign rowsblocks_20 = row_20_io_blocks_out;
  assign shift_ctrl_21_1_io_full_locked = rows_full[21];
  assign row_21_io_row = rows_select[21];
  assign rowsblocks_21 = row_21_io_blocks_out;
  assign shift_done = temp_shift_done;
  assign block_val_valid = block_pos_valid_regNext;
  assign row_status = ((((((((((((((((temp_row_status | rowsblocks_6) | rowsblocks_7) | rowsblocks_8) | rowsblocks_9) | rowsblocks_10) | rowsblocks_11) | rowsblocks_12) | rowsblocks_13) | rowsblocks_14) | rowsblocks_15) | rowsblocks_16) | rowsblocks_17) | rowsblocks_18) | rowsblocks_19) | rowsblocks_20) | rowsblocks_21);
  assign block_val_payload = (|(row_status & cols_select));
  assign row_val_valid = fetch_runing_regNext;
  assign row_val_payload = row_status_regNext;
  assign clear_fsm_onExit_IDLE = ((clear_fsm_stateNext != IDLE) && (clear_fsm_stateReg == IDLE));
  assign clear_fsm_onExit_ENABLE_ROWS = ((clear_fsm_stateNext != ENABLE_ROWS) && (clear_fsm_stateReg == ENABLE_ROWS));
  assign clear_fsm_onExit_ROWS_FULL_READY = ((clear_fsm_stateNext != ROWS_FULL_READY) && (clear_fsm_stateReg == ROWS_FULL_READY));
  assign clear_fsm_onExit_LOCK = ((clear_fsm_stateNext != LOCK) && (clear_fsm_stateReg == LOCK));
  assign clear_fsm_onExit_CHECK = ((clear_fsm_stateNext != CHECK) && (clear_fsm_stateReg == CHECK));
  assign clear_fsm_onExit_CLEAR = ((clear_fsm_stateNext != CLEAR) && (clear_fsm_stateReg == CLEAR));
  assign clear_fsm_onExit_SHIFT = ((clear_fsm_stateNext != SHIFT) && (clear_fsm_stateReg == SHIFT));
  assign clear_fsm_onEntry_IDLE = ((clear_fsm_stateNext == IDLE) && (clear_fsm_stateReg != IDLE));
  assign clear_fsm_onEntry_ENABLE_ROWS = ((clear_fsm_stateNext == ENABLE_ROWS) && (clear_fsm_stateReg != ENABLE_ROWS));
  assign clear_fsm_onEntry_ROWS_FULL_READY = ((clear_fsm_stateNext == ROWS_FULL_READY) && (clear_fsm_stateReg != ROWS_FULL_READY));
  assign clear_fsm_onEntry_LOCK = ((clear_fsm_stateNext == LOCK) && (clear_fsm_stateReg != LOCK));
  assign clear_fsm_onEntry_CHECK = ((clear_fsm_stateNext == CHECK) && (clear_fsm_stateReg != CHECK));
  assign clear_fsm_onEntry_CLEAR = ((clear_fsm_stateNext == CLEAR) && (clear_fsm_stateReg != CLEAR));
  assign clear_fsm_onEntry_SHIFT = ((clear_fsm_stateNext == SHIFT) && (clear_fsm_stateReg != SHIFT));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      rows_full <= 22'h0;
      lines_cleared_valid <= 1'b0;
      cols_select <= 10'h0;
      rows_select <= 22'h0;
      fetch_runing <= 1'b0;
      temp_shift_done <= 1'b0;
      block_pos_valid_regNext <= 1'b0;
      fetch_runing_regNext <= 1'b0;
      clear_fsm_stateReg <= IDLE;
    end else begin
      if(block_pos_valid) begin
        case(block_pos_payload_x)
          4'b0001 : begin
            cols_select <= 10'h001;
          end
          4'b0010 : begin
            cols_select <= 10'h002;
          end
          4'b0011 : begin
            cols_select <= 10'h004;
          end
          4'b0100 : begin
            cols_select <= 10'h008;
          end
          4'b0101 : begin
            cols_select <= 10'h010;
          end
          4'b0110 : begin
            cols_select <= 10'h020;
          end
          4'b0111 : begin
            cols_select <= 10'h040;
          end
          4'b1000 : begin
            cols_select <= 10'h080;
          end
          4'b1001 : begin
            cols_select <= 10'h100;
          end
          4'b1010 : begin
            cols_select <= 10'h200;
          end
          default : begin
            cols_select <= 10'bxxxxxxxxxx;
          end
        endcase
      end
      if(enable_rows) begin
        rows_select <= 22'h3fffff;
      end
      if(block_pos_valid) begin
        case(block_pos_payload_y)
          5'h0 : begin
            rows_select <= 22'h000001;
          end
          5'h01 : begin
            rows_select <= 22'h000002;
          end
          5'h02 : begin
            rows_select <= 22'h000004;
          end
          5'h03 : begin
            rows_select <= 22'h000008;
          end
          5'h04 : begin
            rows_select <= 22'h000010;
          end
          5'h05 : begin
            rows_select <= 22'h000020;
          end
          5'h06 : begin
            rows_select <= 22'h000040;
          end
          5'h07 : begin
            rows_select <= 22'h000080;
          end
          5'h08 : begin
            rows_select <= 22'h000100;
          end
          5'h09 : begin
            rows_select <= 22'h000200;
          end
          5'h0a : begin
            rows_select <= 22'h000400;
          end
          5'h0b : begin
            rows_select <= 22'h000800;
          end
          5'h0c : begin
            rows_select <= 22'h001000;
          end
          5'h0d : begin
            rows_select <= 22'h002000;
          end
          5'h0e : begin
            rows_select <= 22'h004000;
          end
          5'h0f : begin
            rows_select <= 22'h008000;
          end
          5'h10 : begin
            rows_select <= 22'h010000;
          end
          5'h11 : begin
            rows_select <= 22'h020000;
          end
          5'h12 : begin
            rows_select <= 22'h040000;
          end
          5'h13 : begin
            rows_select <= 22'h080000;
          end
          5'h14 : begin
            rows_select <= 22'h100000;
          end
          5'h15 : begin
            rows_select <= 22'h200000;
          end
          default : begin
            rows_select <= 22'bxxxxxxxxxxxxxxxxxxxxxx;
          end
        endcase
      end
      if(fetch) begin
        fetch_runing <= 1'b1;
        rows_select <= 22'h0;
        rows_select[0] <= 1'b1;
      end else begin
        if(rows_select[21]) begin
          fetch_runing <= 1'b0;
        end
      end
      if(fetch_runing) begin
        rows_select <= (rows_select <<< 1);
      end
      lines_cleared_valid <= 1'b0;
      rows_full[0] <= row_0_io_full;
      rows_full[1] <= row_1_io_full;
      rows_full[2] <= row_2_io_full;
      rows_full[3] <= row_3_io_full;
      rows_full[4] <= row_4_io_full;
      rows_full[5] <= row_5_io_full;
      rows_full[6] <= row_6_io_full;
      rows_full[7] <= row_7_io_full;
      rows_full[8] <= row_8_io_full;
      rows_full[9] <= row_9_io_full;
      rows_full[10] <= row_10_io_full;
      rows_full[11] <= row_11_io_full;
      rows_full[12] <= row_12_io_full;
      rows_full[13] <= row_13_io_full;
      rows_full[14] <= row_14_io_full;
      rows_full[15] <= row_15_io_full;
      rows_full[16] <= row_16_io_full;
      rows_full[17] <= row_17_io_full;
      rows_full[18] <= row_18_io_full;
      rows_full[19] <= row_19_io_full;
      rows_full[20] <= row_20_io_full;
      rows_full[21] <= row_21_io_full;
      temp_shift_done <= (! shift_ctrl_0_io_holes_out);
      block_pos_valid_regNext <= block_pos_valid;
      fetch_runing_regNext <= fetch_runing;
      clear_fsm_stateReg <= clear_fsm_stateNext;
      if(clear_fsm_onExit_CHECK) begin
        if((! clear_done)) begin
          lines_cleared_valid <= 1'b1;
        end
      end
    end
  end

  always @(posedge core_clk) begin
    lines_cleared_payload <= (temp_lines_cleared_payload_8 + temp_lines_cleared_payload_19);
    update_en <= (block_pos_valid && update);
    row_status_regNext <= row_status;
  end


endmodule

module picoller (
  input  wire          piece_in_valid,
  output wire          piece_in_ready,
  input  wire [3:0]    piece_in_payload_orign_x,
  input  wire [4:0]    piece_in_payload_orign_y,
  input  wire [2:0]    piece_in_payload_type,
  input  wire [1:0]    piece_in_payload_rot,
  output wire          collision_out_valid,
  output wire          collision_out_payload,
  input  wire          update,
  input  wire          block_set,
  input  wire          block_skip_en,
  output wire          block_pos_valid,
  output wire [3:0]    block_pos_payload_x,
  output wire [4:0]    block_pos_payload_y,
  input  wire          block_val_valid,
  input  wire          block_val_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;

  wire                collision_checker_1_block_wr_en;
  wire                piece_checker_1_piece_in_ready;
  wire                piece_checker_1_blocks_out_valid;
  wire       [3:0]    piece_checker_1_blocks_out_payload_x;
  wire       [4:0]    piece_checker_1_blocks_out_payload_y;
  wire                piece_checker_1_collision_out_valid;
  wire                piece_checker_1_collision_out_payload;
  wire                collision_checker_1_block_pos_valid;
  wire       [3:0]    collision_checker_1_block_pos_payload_x;
  wire       [4:0]    collision_checker_1_block_pos_payload_y;
  wire                collision_checker_1_hit_status_valid;
  wire                collision_checker_1_hit_status_payload_is_occupied;
  wire                collision_checker_1_hit_status_payload_is_wall;
  wire                piece_checker_1_blocks_out_toFlow_valid;
  wire       [3:0]    piece_checker_1_blocks_out_toFlow_payload_x;
  wire       [4:0]    piece_checker_1_blocks_out_toFlow_payload_y;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_type_string;
  `endif


  piece_checker piece_checker_1 (
    .piece_in_valid                 (piece_in_valid                                    ), //i
    .piece_in_ready                 (piece_checker_1_piece_in_ready                    ), //o
    .piece_in_payload_orign_x       (piece_in_payload_orign_x[3:0]                     ), //i
    .piece_in_payload_orign_y       (piece_in_payload_orign_y[4:0]                     ), //i
    .piece_in_payload_type          (piece_in_payload_type[2:0]                        ), //i
    .piece_in_payload_rot           (piece_in_payload_rot[1:0]                         ), //i
    .blocks_out_valid               (piece_checker_1_blocks_out_valid                  ), //o
    .blocks_out_ready               (1'b1                                              ), //i
    .blocks_out_payload_x           (piece_checker_1_blocks_out_payload_x[3:0]         ), //o
    .blocks_out_payload_y           (piece_checker_1_blocks_out_payload_y[4:0]         ), //o
    .hit_status_valid               (collision_checker_1_hit_status_valid              ), //i
    .hit_status_payload_is_occupied (collision_checker_1_hit_status_payload_is_occupied), //i
    .hit_status_payload_is_wall     (collision_checker_1_hit_status_payload_is_wall    ), //i
    .collision_out_valid            (piece_checker_1_collision_out_valid               ), //o
    .collision_out_payload          (piece_checker_1_collision_out_payload             ), //o
    .core_clk                       (core_clk                                          ), //i
    .core_rst                       (core_rst                                          )  //i
  );
  collision_checker collision_checker_1 (
    .block_in_valid                 (piece_checker_1_blocks_out_toFlow_valid           ), //i
    .block_in_payload_x             (piece_checker_1_blocks_out_toFlow_payload_x[3:0]  ), //i
    .block_in_payload_y             (piece_checker_1_blocks_out_toFlow_payload_y[4:0]  ), //i
    .block_skip_en                  (block_skip_en                                     ), //i
    .block_wr_en                    (collision_checker_1_block_wr_en                   ), //i
    .block_pos_valid                (collision_checker_1_block_pos_valid               ), //o
    .block_pos_payload_x            (collision_checker_1_block_pos_payload_x[3:0]      ), //o
    .block_pos_payload_y            (collision_checker_1_block_pos_payload_y[4:0]      ), //o
    .block_val_valid                (block_val_valid                                   ), //i
    .block_val_payload              (block_val_payload                                 ), //i
    .hit_status_valid               (collision_checker_1_hit_status_valid              ), //o
    .hit_status_payload_is_occupied (collision_checker_1_hit_status_payload_is_occupied), //o
    .hit_status_payload_is_wall     (collision_checker_1_hit_status_payload_is_wall    ), //o
    .core_clk                       (core_clk                                          ), //i
    .core_rst                       (core_rst                                          )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_in_payload_type)
      I : piece_in_payload_type_string = "I";
      J : piece_in_payload_type_string = "J";
      L : piece_in_payload_type_string = "L";
      O : piece_in_payload_type_string = "O";
      S : piece_in_payload_type_string = "S";
      T : piece_in_payload_type_string = "T";
      Z : piece_in_payload_type_string = "Z";
      default : piece_in_payload_type_string = "?";
    endcase
  end
  `endif

  assign piece_in_ready = piece_checker_1_piece_in_ready;
  assign collision_out_valid = piece_checker_1_collision_out_valid;
  assign collision_out_payload = piece_checker_1_collision_out_payload;
  assign piece_checker_1_blocks_out_toFlow_valid = piece_checker_1_blocks_out_valid;
  assign piece_checker_1_blocks_out_toFlow_payload_x = piece_checker_1_blocks_out_payload_x;
  assign piece_checker_1_blocks_out_toFlow_payload_y = piece_checker_1_blocks_out_payload_y;
  assign collision_checker_1_block_wr_en = (update && block_set);
  assign block_pos_valid = collision_checker_1_block_pos_valid;
  assign block_pos_payload_x = collision_checker_1_block_pos_payload_x;
  assign block_pos_payload_y = collision_checker_1_block_pos_payload_y;

endmodule

module seven_bag_rng (
  input  wire          io_enable,
  output reg           io_shape_valid,
  output wire [2:0]    io_shape_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam IDLE = 3'd0;
  localparam CHECK = 3'd1;
  localparam OUTPUT_1 = 3'd2;
  localparam DONE = 3'd3;
  localparam SHIFT = 3'd4;
  localparam ELEMENT = 3'd5;

  wire                temp_when;
  reg        [5:0]    lfsr;
  reg        [2:0]    generatedNumbers_0;
  reg        [2:0]    generatedNumbers_1;
  reg        [2:0]    generatedNumbers_2;
  reg        [2:0]    generatedNumbers_3;
  reg        [2:0]    generatedNumbers_4;
  reg        [2:0]    generatedNumbers_5;
  reg        [2:0]    generatedNumbers_6;
  reg        [2:0]    count;
  reg                 existed;
  reg                 shift;
  wire       [2:0]    nextNumber;
  reg                 invalid;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire       [7:0]    temp_1;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_CHECK;
  wire                fsm_onExit_OUTPUT_1;
  wire                fsm_onExit_DONE;
  wire                fsm_onExit_SHIFT;
  wire                fsm_onExit_ELEMENT;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_CHECK;
  wire                fsm_onEntry_OUTPUT_1;
  wire                fsm_onEntry_DONE;
  wire                fsm_onEntry_SHIFT;
  wire                fsm_onEntry_ELEMENT;
  `ifndef SYNTHESIS
  reg [63:0] fsm_stateReg_string;
  reg [63:0] fsm_stateNext_string;
  `endif


  assign temp_when = (count == 3'b111);
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE    ";
      CHECK : fsm_stateReg_string = "CHECK   ";
      OUTPUT_1 : fsm_stateReg_string = "OUTPUT_1";
      DONE : fsm_stateReg_string = "DONE    ";
      SHIFT : fsm_stateReg_string = "SHIFT   ";
      ELEMENT : fsm_stateReg_string = "ELEMENT ";
      default : fsm_stateReg_string = "????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE    ";
      CHECK : fsm_stateNext_string = "CHECK   ";
      OUTPUT_1 : fsm_stateNext_string = "OUTPUT_1";
      DONE : fsm_stateNext_string = "DONE    ";
      SHIFT : fsm_stateNext_string = "SHIFT   ";
      ELEMENT : fsm_stateNext_string = "ELEMENT ";
      default : fsm_stateNext_string = "????????";
    endcase
  end
  `endif

  assign nextNumber = lfsr[2 : 0];
  assign io_shape_payload = nextNumber;
  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    shift = 1'b0;
    io_shape_valid = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      CHECK : begin
        if((existed || invalid)) begin
          fsm_stateNext = SHIFT;
        end else begin
          fsm_stateNext = OUTPUT_1;
        end
      end
      OUTPUT_1 : begin
        io_shape_valid = 1'b1;
        shift = 1'b1;
        fsm_stateNext = DONE;
      end
      DONE : begin
        fsm_stateNext = IDLE;
      end
      SHIFT : begin
        shift = 1'b1;
        fsm_stateNext = ELEMENT;
      end
      ELEMENT : begin
        fsm_stateNext = CHECK;
      end
      default : begin
        if(io_enable) begin
          fsm_stateNext = CHECK;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = IDLE;
    end
  end

  assign fsm_wantKill = 1'b0;
  assign temp_1 = ({7'd0,1'b1} <<< count);
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_CHECK = ((fsm_stateNext != CHECK) && (fsm_stateReg == CHECK));
  assign fsm_onExit_OUTPUT_1 = ((fsm_stateNext != OUTPUT_1) && (fsm_stateReg == OUTPUT_1));
  assign fsm_onExit_DONE = ((fsm_stateNext != DONE) && (fsm_stateReg == DONE));
  assign fsm_onExit_SHIFT = ((fsm_stateNext != SHIFT) && (fsm_stateReg == SHIFT));
  assign fsm_onExit_ELEMENT = ((fsm_stateNext != ELEMENT) && (fsm_stateReg == ELEMENT));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_CHECK = ((fsm_stateNext == CHECK) && (fsm_stateReg != CHECK));
  assign fsm_onEntry_OUTPUT_1 = ((fsm_stateNext == OUTPUT_1) && (fsm_stateReg != OUTPUT_1));
  assign fsm_onEntry_DONE = ((fsm_stateNext == DONE) && (fsm_stateReg != DONE));
  assign fsm_onEntry_SHIFT = ((fsm_stateNext == SHIFT) && (fsm_stateReg != SHIFT));
  assign fsm_onEntry_ELEMENT = ((fsm_stateNext == ELEMENT) && (fsm_stateReg != ELEMENT));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      lfsr <= 6'h2d;
      count <= 3'b000;
      fsm_stateReg <= IDLE;
    end else begin
      if(shift) begin
        lfsr <= {lfsr[4 : 0],(lfsr[5] ^ lfsr[3])};
      end
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        CHECK : begin
        end
        OUTPUT_1 : begin
          count <= (count + 3'b001);
        end
        DONE : begin
          if(temp_when) begin
            count <= 3'b000;
          end
        end
        SHIFT : begin
        end
        ELEMENT : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge core_clk) begin
    invalid <= (nextNumber == 3'b111);
    existed <= 1'b0;
    if(((3'b000 < count) && (nextNumber == generatedNumbers_0))) begin
      existed <= 1'b1;
    end
    if(((3'b001 < count) && (nextNumber == generatedNumbers_1))) begin
      existed <= 1'b1;
    end
    if(((3'b010 < count) && (nextNumber == generatedNumbers_2))) begin
      existed <= 1'b1;
    end
    if(((3'b011 < count) && (nextNumber == generatedNumbers_3))) begin
      existed <= 1'b1;
    end
    if(((3'b100 < count) && (nextNumber == generatedNumbers_4))) begin
      existed <= 1'b1;
    end
    if(((3'b101 < count) && (nextNumber == generatedNumbers_5))) begin
      existed <= 1'b1;
    end
    if(((3'b110 < count) && (nextNumber == generatedNumbers_6))) begin
      existed <= 1'b1;
    end
    case(fsm_stateReg)
      CHECK : begin
      end
      OUTPUT_1 : begin
        if(temp_1[0]) begin
          generatedNumbers_0 <= nextNumber;
        end
        if(temp_1[1]) begin
          generatedNumbers_1 <= nextNumber;
        end
        if(temp_1[2]) begin
          generatedNumbers_2 <= nextNumber;
        end
        if(temp_1[3]) begin
          generatedNumbers_3 <= nextNumber;
        end
        if(temp_1[4]) begin
          generatedNumbers_4 <= nextNumber;
        end
        if(temp_1[5]) begin
          generatedNumbers_5 <= nextNumber;
        end
        if(temp_1[6]) begin
          generatedNumbers_6 <= nextNumber;
        end
      end
      DONE : begin
        if(temp_when) begin
          generatedNumbers_0 <= 3'b000;
          generatedNumbers_1 <= 3'b000;
          generatedNumbers_2 <= 3'b000;
          generatedNumbers_3 <= 3'b000;
          generatedNumbers_4 <= 3'b000;
          generatedNumbers_5 <= 3'b000;
          generatedNumbers_6 <= 3'b000;
        end
      end
      SHIFT : begin
      end
      ELEMENT : begin
      end
      default : begin
      end
    endcase
  end


endmodule

//shift_ctrl_21 replaced by shift_ctrl

//row_blocks_21 replaced by row_blocks

//shift_ctrl_20 replaced by shift_ctrl

//row_blocks_20 replaced by row_blocks

//shift_ctrl_19 replaced by shift_ctrl

//row_blocks_19 replaced by row_blocks

//shift_ctrl_18 replaced by shift_ctrl

//row_blocks_18 replaced by row_blocks

//shift_ctrl_17 replaced by shift_ctrl

//row_blocks_17 replaced by row_blocks

//shift_ctrl_16 replaced by shift_ctrl

//row_blocks_16 replaced by row_blocks

//shift_ctrl_15 replaced by shift_ctrl

//row_blocks_15 replaced by row_blocks

//shift_ctrl_14 replaced by shift_ctrl

//row_blocks_14 replaced by row_blocks

//shift_ctrl_13 replaced by shift_ctrl

//row_blocks_13 replaced by row_blocks

//shift_ctrl_12 replaced by shift_ctrl

//row_blocks_12 replaced by row_blocks

//shift_ctrl_11 replaced by shift_ctrl

//row_blocks_11 replaced by row_blocks

//shift_ctrl_10 replaced by shift_ctrl

//row_blocks_10 replaced by row_blocks

//shift_ctrl_9 replaced by shift_ctrl

//row_blocks_9 replaced by row_blocks

//shift_ctrl_8 replaced by shift_ctrl

//row_blocks_8 replaced by row_blocks

//shift_ctrl_7 replaced by shift_ctrl

//row_blocks_7 replaced by row_blocks

//shift_ctrl_6 replaced by shift_ctrl

//row_blocks_6 replaced by row_blocks

//shift_ctrl_5 replaced by shift_ctrl

//row_blocks_5 replaced by row_blocks

//shift_ctrl_4 replaced by shift_ctrl

//row_blocks_4 replaced by row_blocks

//shift_ctrl_3 replaced by shift_ctrl

//row_blocks_3 replaced by row_blocks

//shift_ctrl_2 replaced by shift_ctrl

//row_blocks_2 replaced by row_blocks

//shift_ctrl_1 replaced by shift_ctrl

//row_blocks_1 replaced by row_blocks

module shift_ctrl (
  input  wire          io_full_in,
  output wire          io_full_out,
  input  wire          io_full_locked,
  input  wire          io_lock,
  input  wire          io_restart,
  input  wire          io_shift,
  input  wire          io_clear,
  input  wire          io_holes_in,
  output wire          io_holes_out,
  output wire          io_shift_en,
  output wire          io_clear_en,
  input  wire          core_clk,
  input  wire          core_rst
);

  reg                 full_wire;
  reg                 full_reg;

  always @(*) begin
    if(io_lock) begin
      full_wire = io_full_locked;
    end else begin
      if(io_shift_en) begin
        full_wire = io_full_in;
      end else begin
        full_wire = full_reg;
      end
    end
  end

  assign io_full_out = full_reg;
  assign io_holes_out = (io_holes_in || full_reg);
  assign io_shift_en = (io_holes_out && io_shift);
  assign io_clear_en = (io_restart || (io_clear && full_reg));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      full_reg <= 1'b0;
    end else begin
      full_reg <= full_wire;
    end
  end


endmodule

module row_blocks (
  input  wire          io_row,
  input  wire [9:0]    io_cols,
  input  wire [9:0]    io_block_pos,
  input  wire          io_shift,
  input  wire          io_update,
  input  wire          io_block_set,
  input  wire          io_clear,
  output reg  [9:0]    io_blocks_out,
  output wire          io_full,
  input  wire          core_clk,
  input  wire          core_rst
);

  wire                row_update;
  wire                temp_1;
  reg                 temp_io_blocks_out;
  wire                temp_2;
  reg                 temp_io_blocks_out_1;
  wire                temp_3;
  reg                 temp_io_blocks_out_2;
  wire                temp_4;
  reg                 temp_io_blocks_out_3;
  wire                temp_5;
  reg                 temp_io_blocks_out_4;
  wire                temp_6;
  reg                 temp_io_blocks_out_5;
  wire                temp_7;
  reg                 temp_io_blocks_out_6;
  wire                temp_8;
  reg                 temp_io_blocks_out_7;
  wire                temp_9;
  reg                 temp_io_blocks_out_8;
  wire                temp_10;
  reg                 temp_io_blocks_out_9;

  assign io_full = (&io_blocks_out);
  assign row_update = (io_update && io_row);
  assign temp_1 = (row_update && io_cols[0]);
  always @(*) begin
    io_blocks_out[0] = (io_row && temp_io_blocks_out);
    io_blocks_out[1] = (io_row && temp_io_blocks_out_1);
    io_blocks_out[2] = (io_row && temp_io_blocks_out_2);
    io_blocks_out[3] = (io_row && temp_io_blocks_out_3);
    io_blocks_out[4] = (io_row && temp_io_blocks_out_4);
    io_blocks_out[5] = (io_row && temp_io_blocks_out_5);
    io_blocks_out[6] = (io_row && temp_io_blocks_out_6);
    io_blocks_out[7] = (io_row && temp_io_blocks_out_7);
    io_blocks_out[8] = (io_row && temp_io_blocks_out_8);
    io_blocks_out[9] = (io_row && temp_io_blocks_out_9);
  end

  assign temp_2 = (row_update && io_cols[1]);
  assign temp_3 = (row_update && io_cols[2]);
  assign temp_4 = (row_update && io_cols[3]);
  assign temp_5 = (row_update && io_cols[4]);
  assign temp_6 = (row_update && io_cols[5]);
  assign temp_7 = (row_update && io_cols[6]);
  assign temp_8 = (row_update && io_cols[7]);
  assign temp_9 = (row_update && io_cols[8]);
  assign temp_10 = (row_update && io_cols[9]);
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      temp_io_blocks_out <= 1'b0;
      temp_io_blocks_out_1 <= 1'b0;
      temp_io_blocks_out_2 <= 1'b0;
      temp_io_blocks_out_3 <= 1'b0;
      temp_io_blocks_out_4 <= 1'b0;
      temp_io_blocks_out_5 <= 1'b0;
      temp_io_blocks_out_6 <= 1'b0;
      temp_io_blocks_out_7 <= 1'b0;
      temp_io_blocks_out_8 <= 1'b0;
      temp_io_blocks_out_9 <= 1'b0;
    end else begin
      if(io_shift) begin
        temp_io_blocks_out <= io_block_pos[0];
      end
      if((temp_1 && io_block_set)) begin
        temp_io_blocks_out <= 1'b1;
      end
      if((io_clear || (temp_1 && (! io_block_set)))) begin
        temp_io_blocks_out <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_1 <= io_block_pos[1];
      end
      if((temp_2 && io_block_set)) begin
        temp_io_blocks_out_1 <= 1'b1;
      end
      if((io_clear || (temp_2 && (! io_block_set)))) begin
        temp_io_blocks_out_1 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_2 <= io_block_pos[2];
      end
      if((temp_3 && io_block_set)) begin
        temp_io_blocks_out_2 <= 1'b1;
      end
      if((io_clear || (temp_3 && (! io_block_set)))) begin
        temp_io_blocks_out_2 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_3 <= io_block_pos[3];
      end
      if((temp_4 && io_block_set)) begin
        temp_io_blocks_out_3 <= 1'b1;
      end
      if((io_clear || (temp_4 && (! io_block_set)))) begin
        temp_io_blocks_out_3 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_4 <= io_block_pos[4];
      end
      if((temp_5 && io_block_set)) begin
        temp_io_blocks_out_4 <= 1'b1;
      end
      if((io_clear || (temp_5 && (! io_block_set)))) begin
        temp_io_blocks_out_4 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_5 <= io_block_pos[5];
      end
      if((temp_6 && io_block_set)) begin
        temp_io_blocks_out_5 <= 1'b1;
      end
      if((io_clear || (temp_6 && (! io_block_set)))) begin
        temp_io_blocks_out_5 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_6 <= io_block_pos[6];
      end
      if((temp_7 && io_block_set)) begin
        temp_io_blocks_out_6 <= 1'b1;
      end
      if((io_clear || (temp_7 && (! io_block_set)))) begin
        temp_io_blocks_out_6 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_7 <= io_block_pos[7];
      end
      if((temp_8 && io_block_set)) begin
        temp_io_blocks_out_7 <= 1'b1;
      end
      if((io_clear || (temp_8 && (! io_block_set)))) begin
        temp_io_blocks_out_7 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_8 <= io_block_pos[8];
      end
      if((temp_9 && io_block_set)) begin
        temp_io_blocks_out_8 <= 1'b1;
      end
      if((io_clear || (temp_9 && (! io_block_set)))) begin
        temp_io_blocks_out_8 <= 1'b0;
      end
      if(io_shift) begin
        temp_io_blocks_out_9 <= io_block_pos[9];
      end
      if((temp_10 && io_block_set)) begin
        temp_io_blocks_out_9 <= 1'b1;
      end
      if((io_clear || (temp_10 && (! io_block_set)))) begin
        temp_io_blocks_out_9 <= 1'b0;
      end
    end
  end


endmodule

module collision_checker (
  input  wire          block_in_valid,
  input  wire [3:0]    block_in_payload_x,
  input  wire [4:0]    block_in_payload_y,
  input  wire          block_skip_en,
  input  wire          block_wr_en,
  output wire          block_pos_valid,
  output wire [3:0]    block_pos_payload_x,
  output wire [4:0]    block_pos_payload_y,
  input  wire          block_val_valid,
  input  wire          block_val_payload,
  output wire          hit_status_valid,
  output wire          hit_status_payload_is_occupied,
  output wire          hit_status_payload_is_wall,
  input  wire          core_clk,
  input  wire          core_rst
);

  wire       [3:0]    blocks_prev_reset_x;
  wire       [4:0]    blocks_prev_reset_y;
  wire                temp_1;
  wire       [3:0]    blocks_prev_0_x;
  wire       [4:0]    blocks_prev_0_y;
  wire       [3:0]    blocks_prev_1_x;
  wire       [4:0]    blocks_prev_1_y;
  wire       [3:0]    blocks_prev_2_x;
  wire       [4:0]    blocks_prev_2_y;
  wire       [3:0]    blocks_prev_3_x;
  wire       [4:0]    blocks_prev_3_y;
  reg        [3:0]    temp_blocks_prev_0_x;
  reg        [4:0]    temp_blocks_prev_0_y;
  reg        [3:0]    temp_blocks_prev_1_x;
  reg        [4:0]    temp_blocks_prev_1_y;
  reg        [3:0]    temp_blocks_prev_2_x;
  reg        [4:0]    temp_blocks_prev_2_y;
  reg        [3:0]    temp_blocks_prev_3_x;
  reg        [4:0]    temp_blocks_prev_3_y;
  wire                block_req_valid;
  wire       [3:0]    block_req_payload_x;
  wire       [4:0]    block_req_payload_y;
  wire                block_skip;
  reg        [3:0]    bit_sel;
  reg                 wall_hit;
  reg                 bottom_hit;
  wire                left_wall_hit;
  wire                right_wall_hit;
  wire                wall_hit_pre;
  reg                 valid_1d;
  wire                valid_fall_edge;
  reg                 valid_fall_edge_1d;
  wire                occupied_enable;
  reg                 occupied;

  assign blocks_prev_reset_x = 4'b0000;
  assign blocks_prev_reset_y = 5'h0;
  assign temp_1 = (block_in_valid && block_wr_en);
  assign blocks_prev_0_x = temp_blocks_prev_0_x;
  assign blocks_prev_0_y = temp_blocks_prev_0_y;
  assign blocks_prev_1_x = temp_blocks_prev_1_x;
  assign blocks_prev_1_y = temp_blocks_prev_1_y;
  assign blocks_prev_2_x = temp_blocks_prev_2_x;
  assign blocks_prev_2_y = temp_blocks_prev_2_y;
  assign blocks_prev_3_x = temp_blocks_prev_3_x;
  assign blocks_prev_3_y = temp_blocks_prev_3_y;
  assign block_skip = (((((1'b0 || ((blocks_prev_0_x == block_in_payload_x) && (blocks_prev_0_y == block_in_payload_y))) || ((blocks_prev_1_x == block_in_payload_x) && (blocks_prev_1_y == block_in_payload_y))) || ((blocks_prev_2_x == block_in_payload_x) && (blocks_prev_2_y == block_in_payload_y))) || ((blocks_prev_3_x == block_in_payload_x) && (blocks_prev_3_y == block_in_payload_y))) && block_skip_en);
  assign block_req_payload_x = block_in_payload_x;
  assign block_req_payload_y = block_in_payload_y;
  assign block_req_valid = ((! block_skip) && block_in_valid);
  assign block_pos_valid = block_req_valid;
  assign block_pos_payload_x = block_req_payload_x;
  assign block_pos_payload_y = block_req_payload_y;
  assign left_wall_hit = (! (|bit_sel));
  assign right_wall_hit = (4'b1011 <= bit_sel);
  assign wall_hit_pre = (((bottom_hit || left_wall_hit) || right_wall_hit) || wall_hit);
  assign valid_fall_edge = ((! block_in_valid) && valid_1d);
  assign occupied_enable = (block_val_valid && (! occupied));
  assign hit_status_valid = valid_fall_edge_1d;
  assign hit_status_payload_is_wall = wall_hit;
  assign hit_status_payload_is_occupied = (occupied && (! wall_hit));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      temp_blocks_prev_0_x <= blocks_prev_reset_x;
      temp_blocks_prev_0_y <= blocks_prev_reset_y;
      temp_blocks_prev_1_x <= blocks_prev_reset_x;
      temp_blocks_prev_1_y <= blocks_prev_reset_y;
      temp_blocks_prev_2_x <= blocks_prev_reset_x;
      temp_blocks_prev_2_y <= blocks_prev_reset_y;
      temp_blocks_prev_3_x <= blocks_prev_reset_x;
      temp_blocks_prev_3_y <= blocks_prev_reset_y;
      bit_sel <= 4'b0000;
      wall_hit <= 1'b0;
      bottom_hit <= 1'b0;
      valid_1d <= 1'b0;
      valid_fall_edge_1d <= 1'b0;
      occupied <= 1'b0;
    end else begin
      if(temp_1) begin
        temp_blocks_prev_0_x <= block_in_payload_x;
        temp_blocks_prev_0_y <= block_in_payload_y;
      end
      if(temp_1) begin
        temp_blocks_prev_1_x <= temp_blocks_prev_0_x;
        temp_blocks_prev_1_y <= temp_blocks_prev_0_y;
      end
      if(temp_1) begin
        temp_blocks_prev_2_x <= temp_blocks_prev_1_x;
        temp_blocks_prev_2_y <= temp_blocks_prev_1_y;
      end
      if(temp_1) begin
        temp_blocks_prev_3_x <= temp_blocks_prev_2_x;
        temp_blocks_prev_3_y <= temp_blocks_prev_2_y;
      end
      bit_sel <= block_req_payload_x;
      bottom_hit <= (5'h16 <= block_req_payload_y);
      valid_1d <= block_in_valid;
      valid_fall_edge_1d <= valid_fall_edge;
      if(valid_fall_edge_1d) begin
        wall_hit <= 1'b0;
      end
      if(valid_1d) begin
        wall_hit <= wall_hit_pre;
      end
      if(occupied_enable) begin
        occupied <= block_val_payload;
      end
      if(valid_fall_edge_1d) begin
        occupied <= 1'b0;
      end
    end
  end


endmodule

module piece_checker (
  input  wire          piece_in_valid,
  output reg           piece_in_ready,
  input  wire [3:0]    piece_in_payload_orign_x,
  input  wire [4:0]    piece_in_payload_orign_y,
  input  wire [2:0]    piece_in_payload_type,
  input  wire [1:0]    piece_in_payload_rot,
  output wire          blocks_out_valid,
  input  wire          blocks_out_ready,
  output wire [3:0]    blocks_out_payload_x,
  output wire [4:0]    blocks_out_payload_y,
  input  wire          hit_status_valid,
  input  wire          hit_status_payload_is_occupied,
  input  wire          hit_status_payload_is_wall,
  output wire          collision_out_valid,
  output wire          collision_out_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;

  wire       [1:0]    temp_temp_blk_offset_payload_x_1;
  wire       [0:0]    temp_temp_blk_offset_payload_x_1_1;
  reg        [3:0]    temp_temp_blk_offset_payload_x_4;
  wire       [3:0]    temp_test_blk_pos_x;
  wire       [4:0]    temp_test_blk_pos_y;
  reg        [1:0]    blks_offset_0_x;
  reg        [1:0]    blks_offset_0_y;
  reg        [1:0]    blks_offset_1_x;
  reg        [1:0]    blks_offset_1_y;
  reg        [1:0]    blks_offset_2_x;
  reg        [1:0]    blks_offset_2_y;
  reg        [1:0]    blks_offset_3_x;
  reg        [1:0]    blks_offset_3_y;
  wire                piece_valid;
  reg                 piece_ready;
  wire       [3:0]    piece_payload_orign_x;
  wire       [4:0]    piece_payload_orign_y;
  wire       [2:0]    piece_payload_type;
  wire       [1:0]    piece_payload_rot;
  reg                 piece_in_rValid;
  wire                piece_in_fire;
  reg        [3:0]    piece_in_rData_orign_x;
  reg        [4:0]    piece_in_rData_orign_y;
  reg        [2:0]    piece_in_rData_type;
  reg        [1:0]    piece_in_rData_rot;
  wire                blk_offset_valid;
  wire                blk_offset_ready;
  wire       [1:0]    blk_offset_payload_x;
  wire       [1:0]    blk_offset_payload_y;
  wire                piece_stage_valid;
  wire                piece_stage_ready;
  wire       [3:0]    piece_stage_payload_orign_x;
  wire       [4:0]    piece_stage_payload_orign_y;
  wire       [2:0]    piece_stage_payload_type;
  wire       [1:0]    piece_stage_payload_rot;
  reg                 piece_rValid;
  reg        [3:0]    piece_rData_orign_x;
  reg        [4:0]    piece_rData_orign_y;
  reg        [2:0]    piece_rData_type;
  reg        [1:0]    piece_rData_rot;
  wire                piece_offset_valid;
  wire                piece_offset_ready;
  wire       [1:0]    piece_offset_payload_0_x;
  wire       [1:0]    piece_offset_payload_0_y;
  wire       [1:0]    piece_offset_payload_1_x;
  wire       [1:0]    piece_offset_payload_1_y;
  wire       [1:0]    piece_offset_payload_2_x;
  wire       [1:0]    piece_offset_payload_2_y;
  wire       [1:0]    piece_offset_payload_3_x;
  wire       [1:0]    piece_offset_payload_3_y;
  wire                blk_offset_fire;
  reg                 temp_blk_offset_payload_x;
  reg        [1:0]    temp_blk_offset_payload_x_1;
  reg        [1:0]    temp_blk_offset_payload_x_2;
  wire                temp_piece_offset_ready;
  wire       [15:0]   temp_blk_offset_payload_x_3;
  wire       [3:0]    temp_blk_offset_payload_x_4;
  wire       [3:0]    test_blk_pos_x;
  wire       [4:0]    test_blk_pos_y;
  wire                blk_offset_translated_valid;
  reg                 blk_offset_translated_ready;
  wire       [3:0]    blk_offset_translated_payload_x;
  wire       [4:0]    blk_offset_translated_payload_y;
  wire                blk_offset_translated_m2sPipe_valid;
  wire                blk_offset_translated_m2sPipe_ready;
  wire       [3:0]    blk_offset_translated_m2sPipe_payload_x;
  wire       [4:0]    blk_offset_translated_m2sPipe_payload_y;
  reg                 blk_offset_translated_rValid;
  reg        [3:0]    blk_offset_translated_rData_x;
  reg        [4:0]    blk_offset_translated_rData_y;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_type_string;
  reg [7:0] piece_payload_type_string;
  reg [7:0] piece_in_rData_type_string;
  reg [7:0] piece_stage_payload_type_string;
  reg [7:0] piece_rData_type_string;
  `endif


  assign temp_temp_blk_offset_payload_x_1_1 = temp_blk_offset_payload_x;
  assign temp_temp_blk_offset_payload_x_1 = {1'd0, temp_temp_blk_offset_payload_x_1_1};
  assign temp_test_blk_pos_x = {2'd0, blk_offset_payload_x};
  assign temp_test_blk_pos_y = {3'd0, blk_offset_payload_y};
  always @(*) begin
    case(temp_blk_offset_payload_x_2)
      2'b00 : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[3 : 0];
      2'b01 : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[7 : 4];
      2'b10 : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[11 : 8];
      default : temp_temp_blk_offset_payload_x_4 = temp_blk_offset_payload_x_3[15 : 12];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_in_payload_type)
      I : piece_in_payload_type_string = "I";
      J : piece_in_payload_type_string = "J";
      L : piece_in_payload_type_string = "L";
      O : piece_in_payload_type_string = "O";
      S : piece_in_payload_type_string = "S";
      T : piece_in_payload_type_string = "T";
      Z : piece_in_payload_type_string = "Z";
      default : piece_in_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_payload_type)
      I : piece_payload_type_string = "I";
      J : piece_payload_type_string = "J";
      L : piece_payload_type_string = "L";
      O : piece_payload_type_string = "O";
      S : piece_payload_type_string = "S";
      T : piece_payload_type_string = "T";
      Z : piece_payload_type_string = "Z";
      default : piece_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_in_rData_type)
      I : piece_in_rData_type_string = "I";
      J : piece_in_rData_type_string = "J";
      L : piece_in_rData_type_string = "L";
      O : piece_in_rData_type_string = "O";
      S : piece_in_rData_type_string = "S";
      T : piece_in_rData_type_string = "T";
      Z : piece_in_rData_type_string = "Z";
      default : piece_in_rData_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_stage_payload_type)
      I : piece_stage_payload_type_string = "I";
      J : piece_stage_payload_type_string = "J";
      L : piece_stage_payload_type_string = "L";
      O : piece_stage_payload_type_string = "O";
      S : piece_stage_payload_type_string = "S";
      T : piece_stage_payload_type_string = "T";
      Z : piece_stage_payload_type_string = "Z";
      default : piece_stage_payload_type_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_rData_type)
      I : piece_rData_type_string = "I";
      J : piece_rData_type_string = "J";
      L : piece_rData_type_string = "L";
      O : piece_rData_type_string = "O";
      S : piece_rData_type_string = "S";
      T : piece_rData_type_string = "T";
      Z : piece_rData_type_string = "Z";
      default : piece_rData_type_string = "?";
    endcase
  end
  `endif

  assign piece_in_fire = (piece_in_valid && piece_in_ready);
  always @(*) begin
    piece_in_ready = piece_ready;
    if((! piece_valid)) begin
      piece_in_ready = 1'b1;
    end
  end

  assign piece_valid = piece_in_rValid;
  assign piece_payload_orign_x = piece_in_rData_orign_x;
  assign piece_payload_orign_y = piece_in_rData_orign_y;
  assign piece_payload_type = piece_in_rData_type;
  assign piece_payload_rot = piece_in_rData_rot;
  always @(*) begin
    piece_ready = piece_stage_ready;
    if((! piece_stage_valid)) begin
      piece_ready = 1'b1;
    end
  end

  assign piece_stage_valid = piece_rValid;
  assign piece_stage_payload_orign_x = piece_rData_orign_x;
  assign piece_stage_payload_orign_y = piece_rData_orign_y;
  assign piece_stage_payload_type = piece_rData_type;
  assign piece_stage_payload_rot = piece_rData_rot;
  assign piece_offset_valid = piece_stage_valid;
  assign piece_stage_ready = piece_offset_ready;
  assign piece_offset_payload_0_x = blks_offset_0_x;
  assign piece_offset_payload_0_y = blks_offset_0_y;
  assign piece_offset_payload_1_x = blks_offset_1_x;
  assign piece_offset_payload_1_y = blks_offset_1_y;
  assign piece_offset_payload_2_x = blks_offset_2_x;
  assign piece_offset_payload_2_y = blks_offset_2_y;
  assign piece_offset_payload_3_x = blks_offset_3_x;
  assign piece_offset_payload_3_y = blks_offset_3_y;
  assign blk_offset_fire = (blk_offset_valid && blk_offset_ready);
  always @(*) begin
    temp_blk_offset_payload_x = 1'b0;
    if(blk_offset_fire) begin
      temp_blk_offset_payload_x = 1'b1;
    end
  end

  assign temp_piece_offset_ready = (temp_blk_offset_payload_x_2 == 2'b11);
  always @(*) begin
    temp_blk_offset_payload_x_1 = (temp_blk_offset_payload_x_2 + temp_temp_blk_offset_payload_x_1);
    if(1'b0) begin
      temp_blk_offset_payload_x_1 = 2'b00;
    end
  end

  assign blk_offset_valid = piece_offset_valid;
  assign temp_blk_offset_payload_x_3 = {{piece_offset_payload_3_y,piece_offset_payload_3_x},{{piece_offset_payload_2_y,piece_offset_payload_2_x},{{piece_offset_payload_1_y,piece_offset_payload_1_x},{piece_offset_payload_0_y,piece_offset_payload_0_x}}}};
  assign temp_blk_offset_payload_x_4 = temp_temp_blk_offset_payload_x_4;
  assign blk_offset_payload_x = temp_blk_offset_payload_x_4[1 : 0];
  assign blk_offset_payload_y = temp_blk_offset_payload_x_4[3 : 2];
  assign piece_offset_ready = (blk_offset_ready && temp_piece_offset_ready);
  assign test_blk_pos_x = (piece_payload_orign_x + temp_test_blk_pos_x);
  assign test_blk_pos_y = (piece_payload_orign_y + temp_test_blk_pos_y);
  assign blk_offset_translated_valid = blk_offset_valid;
  assign blk_offset_ready = blk_offset_translated_ready;
  assign blk_offset_translated_payload_x = test_blk_pos_x;
  assign blk_offset_translated_payload_y = test_blk_pos_y;
  always @(*) begin
    blk_offset_translated_ready = blk_offset_translated_m2sPipe_ready;
    if((! blk_offset_translated_m2sPipe_valid)) begin
      blk_offset_translated_ready = 1'b1;
    end
  end

  assign blk_offset_translated_m2sPipe_valid = blk_offset_translated_rValid;
  assign blk_offset_translated_m2sPipe_payload_x = blk_offset_translated_rData_x;
  assign blk_offset_translated_m2sPipe_payload_y = blk_offset_translated_rData_y;
  assign blocks_out_valid = blk_offset_translated_m2sPipe_valid;
  assign blk_offset_translated_m2sPipe_ready = blocks_out_ready;
  assign blocks_out_payload_x = blk_offset_translated_m2sPipe_payload_x;
  assign blocks_out_payload_y = blk_offset_translated_m2sPipe_payload_y;
  assign collision_out_valid = hit_status_valid;
  assign collision_out_payload = (hit_status_payload_is_occupied || hit_status_payload_is_wall);
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      blks_offset_0_x <= 2'b00;
      blks_offset_0_y <= 2'b00;
      blks_offset_1_x <= 2'b00;
      blks_offset_1_y <= 2'b00;
      blks_offset_2_x <= 2'b00;
      blks_offset_2_y <= 2'b00;
      blks_offset_3_x <= 2'b00;
      blks_offset_3_y <= 2'b00;
      piece_in_rValid <= 1'b0;
      piece_rValid <= 1'b0;
      temp_blk_offset_payload_x_2 <= 2'b00;
      blk_offset_translated_rValid <= 1'b0;
    end else begin
      if(piece_in_ready) begin
        piece_in_rValid <= piece_in_valid;
      end
      case(piece_payload_type)
        O : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
          endcase
        end
        T : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        J : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        Z : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        I : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b11;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b11;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b11;
              blks_offset_3_y <= 2'b10;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b11;
            end
          endcase
        end
        S : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b00;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b00;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b10;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b10;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b10;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b00;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b01;
              blks_offset_2_y <= 2'b01;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
        default : begin
          case(piece_payload_rot)
            2'b00 : begin
              blks_offset_0_x <= 2'b00;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b10;
              blks_offset_3_y <= 2'b01;
            end
            2'b01 : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b00;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b10;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b10;
            end
            2'b10 : begin
              blks_offset_0_x <= 2'b10;
              blks_offset_0_y <= 2'b01;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b00;
              blks_offset_2_y <= 2'b10;
              blks_offset_3_x <= 2'b00;
              blks_offset_3_y <= 2'b01;
            end
            default : begin
              blks_offset_0_x <= 2'b01;
              blks_offset_0_y <= 2'b10;
              blks_offset_1_x <= 2'b01;
              blks_offset_1_y <= 2'b01;
              blks_offset_2_x <= 2'b00;
              blks_offset_2_y <= 2'b00;
              blks_offset_3_x <= 2'b01;
              blks_offset_3_y <= 2'b00;
            end
          endcase
        end
      endcase
      if(piece_ready) begin
        piece_rValid <= piece_valid;
      end
      temp_blk_offset_payload_x_2 <= temp_blk_offset_payload_x_1;
      if(blk_offset_translated_ready) begin
        blk_offset_translated_rValid <= blk_offset_translated_valid;
      end
    end
  end

  always @(posedge core_clk) begin
    if(piece_in_fire) begin
      piece_in_rData_orign_x <= piece_in_payload_orign_x;
      piece_in_rData_orign_y <= piece_in_payload_orign_y;
      piece_in_rData_type <= piece_in_payload_type;
      piece_in_rData_rot <= piece_in_payload_rot;
    end
    if(piece_ready) begin
      piece_rData_orign_x <= piece_payload_orign_x;
      piece_rData_orign_y <= piece_payload_orign_y;
      piece_rData_type <= piece_payload_type;
      piece_rData_rot <= piece_payload_rot;
    end
    if(blk_offset_translated_ready) begin
      blk_offset_translated_rData_x <= blk_offset_translated_payload_x;
      blk_offset_translated_rData_y <= blk_offset_translated_payload_y;
    end
  end


endmodule
