// Generator : SpinalHDL v1.15.0    git head : 05a01af3d3345aa0afcaad8e0186dde13a359db2
// Component : tetris_top
// Git hash  : 3d467bff18f916b687d55ae2a8e3528df145783c

`timescale 1ns/1ps

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
  output wire          uart_txd,
  input  wire          uart_rxd,
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
  wire       [5:0]    kd_ps2_inst_keys_valid;
  wire                uart_inst_io_uart_txd;
  wire                uart_inst_io_game_start;
  wire                uart_inst_io_move_left;
  wire                uart_inst_io_move_right;
  wire                uart_inst_io_move_down;
  wire                uart_inst_io_rotate;
  wire                uart_inst_io_drop;
  reg                 ctrl_allowed_regNext;
  wire                temp_btns_rot_clr;

  tetris_core tetris_core_inst (
    .core_clk     (core_clk                         ), //i
    .core_rst     (core_rst                         ), //i
    .vga_clk      (vga_clk                          ), //i
    .vga_rst      (vga_rst                          ), //i
    .game_start   (uart_inst_io_game_start          ), //i
    .move_left    (uart_inst_io_move_left           ), //i
    .move_right   (uart_inst_io_move_right          ), //i
    .move_down    (uart_inst_io_move_down           ), //i
    .rotate       (uart_inst_io_rotate              ), //i
    .drop         (uart_inst_io_drop                ), //i
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
    .keys_valid      (kd_ps2_inst_keys_valid[5:0]     ), //o
    .core_rst        (core_rst                        ), //i
    .core_clk        (core_clk                        )  //i
  );
  uart_controller uart_inst (
    .io_uart_txd     (uart_inst_io_uart_txd  ), //o
    .io_uart_rxd     (uart_rxd               ), //i
    .io_controlReset (temp_btns_rot_clr      ), //i
    .io_game_start   (uart_inst_io_game_start), //o
    .io_move_left    (uart_inst_io_move_left ), //o
    .io_move_right   (uart_inst_io_move_right), //o
    .io_move_down    (uart_inst_io_move_down ), //o
    .io_rotate       (uart_inst_io_rotate    ), //o
    .io_drop         (uart_inst_io_drop      ), //o
    .core_clk        (core_clk               ), //i
    .core_rst        (core_rst               )  //i
  );
  assign uart_txd = uart_inst_io_uart_txd;
  assign vga_vSync = tetris_core_inst_vga_vSync;
  assign vga_hSync = tetris_core_inst_vga_hSync;
  assign vga_colorEn = tetris_core_inst_vga_colorEn;
  assign vga_color_r = tetris_core_inst_vga_color_r;
  assign vga_color_g = tetris_core_inst_vga_color_g;
  assign vga_color_b = tetris_core_inst_vga_color_b;
  assign temp_btns_rot_clr = (tetris_core_inst_ctrl_allowed && (! ctrl_allowed_regNext));
  assign btns_rot_clr = temp_btns_rot_clr;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      ctrl_allowed_regNext <= 1'b0;
    end else begin
      ctrl_allowed_regNext <= tetris_core_inst_ctrl_allowed;
    end
  end


endmodule

module uart_controller (
  output wire          io_uart_txd,
  input  wire          io_uart_rxd,
  input  wire          io_controlReset,
  output wire          io_game_start,
  output wire          io_move_left,
  output wire          io_move_right,
  output wire          io_move_down,
  output wire          io_rotate,
  output wire          io_drop,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;

  wire                uartCtrl_1_io_write_ready;
  wire                uartCtrl_1_io_read_valid;
  wire       [7:0]    uartCtrl_1_io_read_payload;
  wire                uartCtrl_1_io_uart_txd;
  wire                uartCtrl_1_io_readError;
  wire                uartCtrl_1_io_readBreak;
  reg                 game_start_reg;
  reg                 move_left_reg;
  reg                 move_right_reg;
  reg                 move_down_reg;
  reg                 rotate_reg;
  reg                 drop_reg;

  UartCtrl uartCtrl_1 (
    .io_config_frame_dataLength (3'b111                         ), //i
    .io_config_frame_stop       (UartStopType_ONE               ), //i
    .io_config_frame_parity     (UartParityType_NONE            ), //i
    .io_config_clockDivider     (20'h00145                      ), //i
    .io_write_valid             (1'b0                           ), //i
    .io_write_ready             (uartCtrl_1_io_write_ready      ), //o
    .io_write_payload           (8'h0                           ), //i
    .io_read_valid              (uartCtrl_1_io_read_valid       ), //o
    .io_read_ready              (1'b1                           ), //i
    .io_read_payload            (uartCtrl_1_io_read_payload[7:0]), //o
    .io_uart_txd                (uartCtrl_1_io_uart_txd         ), //o
    .io_uart_rxd                (io_uart_rxd                    ), //i
    .io_readError               (uartCtrl_1_io_readError        ), //o
    .io_writeBreak              (1'b0                           ), //i
    .io_readBreak               (uartCtrl_1_io_readBreak        ), //o
    .core_clk                   (core_clk                       ), //i
    .core_rst                   (core_rst                       )  //i
  );
  assign io_uart_txd = uartCtrl_1_io_uart_txd;
  assign io_game_start = game_start_reg;
  assign io_move_left = move_left_reg;
  assign io_move_right = move_right_reg;
  assign io_move_down = move_down_reg;
  assign io_rotate = rotate_reg;
  assign io_drop = drop_reg;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      game_start_reg <= 1'b0;
      move_left_reg <= 1'b0;
      move_right_reg <= 1'b0;
      move_down_reg <= 1'b0;
      rotate_reg <= 1'b0;
      drop_reg <= 1'b0;
    end else begin
      if(io_controlReset) begin
        game_start_reg <= 1'b0;
        move_left_reg <= 1'b0;
        move_right_reg <= 1'b0;
        move_down_reg <= 1'b0;
        rotate_reg <= 1'b0;
        drop_reg <= 1'b0;
      end else begin
        game_start_reg <= 1'b0;
        move_left_reg <= 1'b0;
        move_right_reg <= 1'b0;
        move_down_reg <= 1'b0;
        rotate_reg <= 1'b0;
        drop_reg <= 1'b0;
        if(uartCtrl_1_io_read_valid) begin
          case(uartCtrl_1_io_read_payload)
            8'h77 : begin
              game_start_reg <= 1'b1;
            end
            8'h61 : begin
              move_left_reg <= 1'b1;
            end
            8'h64 : begin
              move_right_reg <= 1'b1;
            end
            8'h73 : begin
              move_down_reg <= 1'b1;
            end
            8'h20 : begin
              rotate_reg <= 1'b1;
            end
            8'h0d : begin
              drop_reg <= 1'b1;
            end
            default : begin
            end
          endcase
        end
      end
    end
  end


endmodule

module kd_ps2 (
  inout  wire          ps2_clk,
  inout  wire          ps2_data,
  output wire          rd_data_valid,
  output wire [7:0]    rd_data_payload,
  output reg  [5:0]    keys_valid,
  input  wire          core_rst,
  input  wire          core_clk
);
  localparam rx_fsm_IDLE = 2'd0;
  localparam rx_fsm_WAIT_BREAK = 2'd1;
  localparam rx_fsm_WAIT_LAST = 2'd2;
  localparam rx_fsm_DEFAULT_1 = 2'd3;

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
  wire                start_tick;
  reg                 start_valid;
  wire                start_tick_2nd;
  wire                down_tick;
  reg                 down_valid;
  wire                down_tick_2nd;
  wire                left_tick;
  reg                 left_valid;
  wire                left_tick_2nd;
  wire                right_tick;
  reg                 right_valid;
  wire                right_tick_2nd;
  wire                rotate_tick;
  reg                 rotate_valid;
  wire                rotate_tick_2nd;
  wire                drop_tick;
  reg                 drop_valid;
  wire                drop_tick_2nd;
  reg        [1:0]    rx_fsm_stateReg;
  reg        [1:0]    rx_fsm_stateNext;
  wire                rx_fsm_onEntry_IDLE;
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
      rx_fsm_IDLE : rx_fsm_stateReg_string = "IDLE      ";
      rx_fsm_WAIT_BREAK : rx_fsm_stateReg_string = "WAIT_BREAK";
      rx_fsm_WAIT_LAST : rx_fsm_stateReg_string = "WAIT_LAST ";
      rx_fsm_DEFAULT_1 : rx_fsm_stateReg_string = "DEFAULT_1 ";
      default : rx_fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(rx_fsm_stateNext)
      rx_fsm_IDLE : rx_fsm_stateNext_string = "IDLE      ";
      rx_fsm_WAIT_BREAK : rx_fsm_stateNext_string = "WAIT_BREAK";
      rx_fsm_WAIT_LAST : rx_fsm_stateNext_string = "WAIT_LAST ";
      rx_fsm_DEFAULT_1 : rx_fsm_stateNext_string = "DEFAULT_1 ";
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
      rx_fsm_WAIT_BREAK : begin
        if(break_tick) begin
          rx_fsm_stateNext = rx_fsm_WAIT_LAST;
        end
      end
      rx_fsm_WAIT_LAST : begin
        if(is_key_2nd_recevied) begin
          rx_fsm_stateNext = rx_fsm_IDLE;
        end
      end
      rx_fsm_DEFAULT_1 : begin
        rx_fsm_stateNext = rx_fsm_IDLE;
      end
      default : begin
        if(is_key_received) begin
          rx_fsm_stateNext = rx_fsm_WAIT_BREAK;
        end
        rx_fsm_wantStart = 1'b1;
      end
    endcase
    if(rx_fsm_wantKill) begin
      rx_fsm_stateNext = rx_fsm_IDLE;
    end
  end

  assign rx_fsm_wantKill = 1'b0;
  assign start_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1d));
  assign start_tick_2nd = (start_tick && start_valid);
  always @(*) begin
    keys_valid[0] = start_valid;
    keys_valid[1] = down_valid;
    keys_valid[2] = left_valid;
    keys_valid[3] = right_valid;
    keys_valid[4] = rotate_valid;
    keys_valid[5] = drop_valid;
  end

  assign down_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1b));
  assign down_tick_2nd = (down_tick && down_valid);
  assign left_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1c));
  assign left_tick_2nd = (left_tick && left_valid);
  assign right_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h23));
  assign right_tick_2nd = (right_tick && right_valid);
  assign rotate_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h29));
  assign rotate_tick_2nd = (rotate_tick && rotate_valid);
  assign drop_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h5a));
  assign drop_tick_2nd = (drop_tick && drop_valid);
  assign is_key_received = (|{drop_tick,{rotate_tick,{right_tick,{left_tick,{down_tick,start_tick}}}}});
  assign is_key_2nd_recevied = (|{drop_tick_2nd,{rotate_tick_2nd,{right_tick_2nd,{left_tick_2nd,{down_tick_2nd,start_tick_2nd}}}}});
  assign rx_fsm_onEntry_IDLE = ((rx_fsm_stateNext == rx_fsm_IDLE) && (rx_fsm_stateReg != rx_fsm_IDLE));
  assign is_fsm_in_idle = (rx_fsm_stateReg == rx_fsm_IDLE);
  assign is_fsm_exit_wait_last = ((rx_fsm_stateNext != rx_fsm_WAIT_LAST) && (rx_fsm_stateReg == rx_fsm_WAIT_LAST));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      start_valid <= 1'b0;
      down_valid <= 1'b0;
      left_valid <= 1'b0;
      right_valid <= 1'b0;
      rotate_valid <= 1'b0;
      drop_valid <= 1'b0;
      rx_fsm_stateReg <= rx_fsm_IDLE;
    end else begin
      if(is_fsm_in_idle) begin
        start_valid <= start_tick;
      end
      if(is_fsm_exit_wait_last) begin
        start_valid <= 1'b0;
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
        rotate_valid <= rotate_tick;
      end
      if(is_fsm_exit_wait_last) begin
        rotate_valid <= 1'b0;
      end
      if(is_fsm_in_idle) begin
        drop_valid <= drop_tick;
      end
      if(is_fsm_exit_wait_last) begin
        drop_valid <= 1'b0;
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
  input  wire          drop,
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
  wire                game_logic_inst_score_val_valid;
  wire       [9:0]    game_logic_inst_score_val_payload;
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
    .game_start        (game_start                            ), //i
    .move_left         (move_left                             ), //i
    .move_right        (move_right                            ), //i
    .move_down         (move_down                             ), //i
    .rotate            (rotate                                ), //i
    .drop              (drop                                  ), //i
    .row_val_valid     (game_logic_inst_row_val_valid         ), //o
    .row_val_payload   (game_logic_inst_row_val_payload[9:0]  ), //o
    .score_val_valid   (game_logic_inst_score_val_valid       ), //o
    .score_val_payload (game_logic_inst_score_val_payload[9:0]), //o
    .draw_field_done   (game_display_inst_draw_field_done     ), //i
    .screen_is_ready   (game_display_inst_screen_is_ready     ), //i
    .vga_sof           (game_display_inst_sof                 ), //i
    .ctrl_allowed      (game_logic_inst_ctrl_allowed          ), //o
    .softReset         (game_logic_inst_softReset             ), //o
    .game_restart      (game_logic_inst_game_restart          ), //o
    .core_clk          (core_clk                              ), //i
    .core_rst          (core_rst                              )  //i
  );
  display_top game_display_inst (
    .vga_vSync         (game_display_inst_vga_vSync           ), //o
    .vga_hSync         (game_display_inst_vga_hSync           ), //o
    .vga_colorEn       (game_display_inst_vga_colorEn         ), //o
    .vga_color_r       (game_display_inst_vga_color_r[3:0]    ), //o
    .vga_color_g       (game_display_inst_vga_color_g[3:0]    ), //o
    .vga_color_b       (game_display_inst_vga_color_b[3:0]    ), //o
    .softRest          (game_logic_inst_softReset             ), //i
    .core_clk          (core_clk                              ), //i
    .core_rst          (core_rst                              ), //i
    .vga_clk           (vga_clk                               ), //i
    .vga_rst           (vga_rst                               ), //i
    .row_val_valid     (game_logic_inst_row_val_valid         ), //i
    .row_val_payload   (game_logic_inst_row_val_payload[9:0]  ), //i
    .score_val_valid   (game_logic_inst_score_val_valid       ), //i
    .score_val_payload (game_logic_inst_score_val_payload[9:0]), //i
    .game_start        (game_start                            ), //i
    .game_restart      (game_logic_inst_game_restart          ), //i
    .draw_done         (game_display_inst_draw_done           ), //o
    .draw_field_done   (game_display_inst_draw_field_done     ), //o
    .screen_is_ready   (game_display_inst_screen_is_ready     ), //o
    .sof               (game_display_inst_sof                 )  //o
  );
  assign vga_vSync = game_display_inst_vga_vSync;
  assign vga_hSync = game_display_inst_vga_hSync;
  assign vga_colorEn = game_display_inst_vga_colorEn;
  assign vga_color_r = game_display_inst_vga_color_r;
  assign vga_color_g = game_display_inst_vga_color_g;
  assign vga_color_b = game_display_inst_vga_color_b;
  assign ctrl_allowed = game_logic_inst_ctrl_allowed;

endmodule

module UartCtrl (
  input  wire [2:0]    io_config_frame_dataLength,
  input  wire [0:0]    io_config_frame_stop,
  input  wire [1:0]    io_config_frame_parity,
  input  wire [19:0]   io_config_clockDivider,
  input  wire          io_write_valid,
  output reg           io_write_ready,
  input  wire [7:0]    io_write_payload,
  output wire          io_read_valid,
  input  wire          io_read_ready,
  output wire [7:0]    io_read_payload,
  output wire          io_uart_txd,
  input  wire          io_uart_rxd,
  output wire          io_readError,
  input  wire          io_writeBreak,
  output wire          io_readBreak,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;

  wire                tx_io_write_ready;
  wire                tx_io_txd;
  wire                rx_io_read_valid;
  wire       [7:0]    rx_io_read_payload;
  wire                rx_io_rts;
  wire                rx_io_error;
  wire                rx_io_break;
  reg        [19:0]   clockDivider_counter;
  wire                clockDivider_tick;
  reg                 clockDivider_tickReg;
  reg                 io_write_throwWhen_valid;
  wire                io_write_throwWhen_ready;
  wire       [7:0]    io_write_throwWhen_payload;
  `ifndef SYNTHESIS
  reg [23:0] io_config_frame_stop_string;
  reg [31:0] io_config_frame_parity_string;
  `endif


  UartCtrlTx tx (
    .io_configFrame_dataLength (io_config_frame_dataLength[2:0]), //i
    .io_configFrame_stop       (io_config_frame_stop           ), //i
    .io_configFrame_parity     (io_config_frame_parity[1:0]    ), //i
    .io_samplingTick           (clockDivider_tickReg           ), //i
    .io_write_valid            (io_write_throwWhen_valid       ), //i
    .io_write_ready            (tx_io_write_ready              ), //o
    .io_write_payload          (io_write_throwWhen_payload[7:0]), //i
    .io_cts                    (1'b0                           ), //i
    .io_txd                    (tx_io_txd                      ), //o
    .io_break                  (io_writeBreak                  ), //i
    .core_clk                  (core_clk                       ), //i
    .core_rst                  (core_rst                       )  //i
  );
  UartCtrlRx rx (
    .io_configFrame_dataLength (io_config_frame_dataLength[2:0]), //i
    .io_configFrame_stop       (io_config_frame_stop           ), //i
    .io_configFrame_parity     (io_config_frame_parity[1:0]    ), //i
    .io_samplingTick           (clockDivider_tickReg           ), //i
    .io_read_valid             (rx_io_read_valid               ), //o
    .io_read_ready             (io_read_ready                  ), //i
    .io_read_payload           (rx_io_read_payload[7:0]        ), //o
    .io_rxd                    (io_uart_rxd                    ), //i
    .io_rts                    (rx_io_rts                      ), //o
    .io_error                  (rx_io_error                    ), //o
    .io_break                  (rx_io_break                    ), //o
    .core_clk                  (core_clk                       ), //i
    .core_rst                  (core_rst                       )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_config_frame_stop)
      UartStopType_ONE : io_config_frame_stop_string = "ONE";
      UartStopType_TWO : io_config_frame_stop_string = "TWO";
      default : io_config_frame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_config_frame_parity)
      UartParityType_NONE : io_config_frame_parity_string = "NONE";
      UartParityType_EVEN : io_config_frame_parity_string = "EVEN";
      UartParityType_ODD : io_config_frame_parity_string = "ODD ";
      default : io_config_frame_parity_string = "????";
    endcase
  end
  `endif

  assign clockDivider_tick = (clockDivider_counter == 20'h0);
  always @(*) begin
    io_write_throwWhen_valid = io_write_valid;
    io_write_ready = io_write_throwWhen_ready;
    if(rx_io_break) begin
      io_write_throwWhen_valid = 1'b0;
      io_write_ready = 1'b1;
    end
  end

  assign io_write_throwWhen_payload = io_write_payload;
  assign io_write_throwWhen_ready = tx_io_write_ready;
  assign io_read_valid = rx_io_read_valid;
  assign io_read_payload = rx_io_read_payload;
  assign io_uart_txd = tx_io_txd;
  assign io_readError = rx_io_error;
  assign io_readBreak = rx_io_break;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      clockDivider_counter <= 20'h0;
      clockDivider_tickReg <= 1'b0;
    end else begin
      clockDivider_tickReg <= clockDivider_tick;
      clockDivider_counter <= (clockDivider_counter - 20'h00001);
      if(clockDivider_tick) begin
        clockDivider_counter <= io_config_clockDivider;
      end
    end
  end


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
  input  wire          score_val_valid,
  input  wire [9:0]    score_val_payload,
  input  wire          game_start,
  input  wire          game_restart,
  output wire          draw_done,
  output wire          draw_field_done,
  output wire          screen_is_ready,
  output wire          sof
);

  wire                frame_buffer_wr_en;
  reg        [3:0]    frame_buffer_wr_data;
  wire                frame_buffer_addr_gen_start;
  wire       [3:0]    line_buffer_palette_addr;
  wire                frame_buffer_rd_data_valid;
  wire       [3:0]    frame_buffer_rd_data_payload;
  wire                frame_buffer_clear_done;
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
  wire       [16:0]   frame_buffer_addr_gen_out_addr;
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
  wire                line_buffer_palette_color_valid;
  wire       [11:0]   line_buffer_palette_color_payload;
  wire                line_buffer_rd_out_valid;
  wire       [3:0]    line_buffer_rd_out_payload;
  wire                softRest_buffercc_io_dataOut;
  wire                line_fetch_toggle_buffercc_io_dataOut;
  wire                frame_start_toggle_buffercc_io_dataOut;
  wire       [4:0]    temp_temp_rd_start_1;
  wire       [0:0]    temp_temp_rd_start_1_1;
  wire       [8:0]    temp_dmaArea_lineFetchPixelCounter_valueNext;
  wire       [0:0]    temp_dmaArea_lineFetchPixelCounter_valueNext_1;
  wire       [16:0]   temp_dmaArea_frameBufferReadAddr_valueNext;
  wire       [0:0]    temp_dmaArea_frameBufferReadAddr_valueNext_1;
  wire       [1:0]    activeDrawEngineMask;
  wire                drawEnginesOverlap;
  reg        [8:0]    temp_h_cnt;
  reg        [7:0]    temp_v_cnt;
  reg                 temp_draw_done;
  reg                 vga_sync_io_colorEn_regNext;
  reg                 fbScaleCounter_willIncrement;
  wire                fbScaleCounter_willDecrement;
  wire                fbScaleCounter_willClear;
  wire                fbScaleCounter_willLoad;
  reg        [0:0]    fbScaleCounter_valueNext;
  reg        [0:0]    fbScaleCounter_value;
  wire                fbScaleCounter_willOverflowIfInc;
  wire                fbScaleCounter_willUnderflowIfDec;
  wire                fbScaleCounter_willOverflow;
  wire                fbScaleCounter_willUnderflow;
  wire                lineFetchAllowed;
  wire                lineFetchPulse;
  reg                 line_fetch_toggle;
  reg                 frame_start_toggle;
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
  reg                 isBackgroundIndex;
  wire                pixel_debug_valid;
  wire       [3:0]    pixel_debug_payload_r;
  wire       [3:0]    pixel_debug_payload_g;
  wire       [3:0]    pixel_debug_payload_b;
  wire                dmaArea_lineFetchToggleCore;
  wire                dmaArea_frameStartToggleCore;
  reg                 dmaArea_lineFetchToggleCore_regNext;
  wire                dmaArea_lineFetchStart;
  reg                 dmaArea_frameStartToggleCore_regNext;
  wire                dmaArea_frameStart;
  reg                 dmaArea_frameBufferFetchActive;
  reg                 dmaArea_lineFetchPixelCounter_willIncrement;
  wire                dmaArea_lineFetchPixelCounter_willDecrement;
  reg                 dmaArea_lineFetchPixelCounter_willClear;
  wire                dmaArea_lineFetchPixelCounter_willLoad;
  reg        [8:0]    dmaArea_lineFetchPixelCounter_valueNext;
  reg        [8:0]    dmaArea_lineFetchPixelCounter_value;
  wire                dmaArea_lineFetchPixelCounter_willOverflowIfInc;
  wire                dmaArea_lineFetchPixelCounter_willUnderflowIfDec;
  wire                dmaArea_lineFetchPixelCounter_willOverflow;
  wire                dmaArea_lineFetchPixelCounter_willUnderflow;
  reg                 dmaArea_frameBufferReadAddr_willIncrement;
  wire                dmaArea_frameBufferReadAddr_willDecrement;
  reg                 dmaArea_frameBufferReadAddr_willClear;
  wire                dmaArea_frameBufferReadAddr_willLoad;
  reg        [16:0]   dmaArea_frameBufferReadAddr_valueNext;
  reg        [16:0]   dmaArea_frameBufferReadAddr_value;
  wire                dmaArea_frameBufferReadAddr_willOverflowIfInc;
  wire                dmaArea_frameBufferReadAddr_willUnderflowIfDec;
  wire                dmaArea_frameBufferReadAddr_willOverflow;
  wire                dmaArea_frameBufferReadAddr_willUnderflow;
  wire                dmaArea_lineFetchWhileBusy;

  assign temp_temp_rd_start_1_1 = temp_rd_start;
  assign temp_temp_rd_start_1 = {4'd0, temp_temp_rd_start_1_1};
  assign temp_dmaArea_lineFetchPixelCounter_valueNext_1 = dmaArea_lineFetchPixelCounter_willIncrement;
  assign temp_dmaArea_lineFetchPixelCounter_valueNext = {8'd0, temp_dmaArea_lineFetchPixelCounter_valueNext_1};
  assign temp_dmaArea_frameBufferReadAddr_valueNext_1 = dmaArea_frameBufferReadAddr_willIncrement;
  assign temp_dmaArea_frameBufferReadAddr_valueNext = {16'd0, temp_dmaArea_frameBufferReadAddr_valueNext_1};
  Bram2p_4x69120 frame_buffer (
    .wr_en           (frame_buffer_wr_en                     ), //i
    .wr_addr         (frame_buffer_addr_gen_out_addr[16:0]   ), //i
    .wr_data         (frame_buffer_wr_data[3:0]              ), //i
    .rd_en           (dmaArea_frameBufferFetchActive         ), //i
    .rd_addr         (dmaArea_frameBufferReadAddr_value[16:0]), //i
    .rd_data_valid   (frame_buffer_rd_data_valid             ), //o
    .rd_data_payload (frame_buffer_rd_data_payload[3:0]      ), //o
    .clear_start     (draw_controller_bf_clear_start         ), //i
    .clear_done      (frame_buffer_clear_done                ), //o
    .core_rst        (core_rst                               ), //i
    .core_clk        (core_clk                               )  //i
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
  fb_addr_gen frame_buffer_addr_gen (
    .x        (draw_controller_draw_x_orig[8:0]    ), //i
    .y        (draw_controller_draw_y_orig[7:0]    ), //i
    .start    (frame_buffer_addr_gen_start         ), //i
    .h_cnt    (temp_h_cnt[8:0]                     ), //i
    .v_cnt    (temp_v_cnt[7:0]                     ), //i
    .out_addr (frame_buffer_addr_gen_out_addr[16:0]), //o
    .core_clk (core_clk                            ), //i
    .core_rst (core_rst                            )  //i
  );
  display_controller draw_controller (
    .game_restart            (game_restart                                ), //i
    .frame_start             (dmaArea_frameStart                          ), //i
    .game_start              (game_start                                  ), //i
    .row_val_valid           (row_val_valid                               ), //i
    .row_val_payload         (row_val_payload[9:0]                        ), //i
    .score_val_valid         (score_val_valid                             ), //i
    .score_val_payload       (score_val_payload[9:0]                      ), //i
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
    .bf_clear_done           (frame_buffer_clear_done                     ), //i
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
  color_palette line_buffer_palette (
    .addr          (line_buffer_palette_addr[3:0]          ), //i
    .rd_en         (line_buffer_rd_out_valid               ), //i
    .color_valid   (line_buffer_palette_color_valid        ), //o
    .color_payload (line_buffer_palette_color_payload[11:0]), //o
    .vga_clk       (vga_clk                                ), //i
    .vga_rst       (vga_rst                                )  //i
  );
  linebuffer line_buffer (
    .wr_in_valid    (frame_buffer_rd_data_valid       ), //i
    .wr_in_payload  (frame_buffer_rd_data_payload[3:0]), //i
    .rd_start       (temp_rd_start_4                  ), //i
    .rd_out_valid   (line_buffer_rd_out_valid         ), //o
    .rd_out_payload (line_buffer_rd_out_payload[3:0]  ), //o
    .core_clk       (core_clk                         ), //i
    .core_rst       (core_rst                         ), //i
    .vga_clk        (vga_clk                          ), //i
    .vga_rst        (vga_rst                          )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC softRest_buffercc (
    .io_dataIn  (softRest                    ), //i
    .io_dataOut (softRest_buffercc_io_dataOut), //o
    .vga_clk    (vga_clk                     ), //i
    .vga_rst    (vga_rst                     )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC_1 line_fetch_toggle_buffercc (
    .io_dataIn  (line_fetch_toggle                    ), //i
    .io_dataOut (line_fetch_toggle_buffercc_io_dataOut), //o
    .core_clk   (core_clk                             ), //i
    .core_rst   (core_rst                             )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC_1 frame_start_toggle_buffercc (
    .io_dataIn  (frame_start_toggle                    ), //i
    .io_dataOut (frame_start_toggle_buffercc_io_dataOut), //o
    .core_clk   (core_clk                              ), //i
    .core_rst   (core_rst                              )  //i
  );
  assign draw_field_done = draw_controller_draw_field_done;
  assign activeDrawEngineMask = {draw_char_engine_1_is_running,draw_block_engine_1_is_running};
  assign drawEnginesOverlap = (draw_char_engine_1_is_running && draw_block_engine_1_is_running);
  assign frame_buffer_addr_gen_start = (draw_controller_draw_char_start || draw_controller_draw_block_start);
  always @(*) begin
    case(activeDrawEngineMask)
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
    case(activeDrawEngineMask)
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

  assign frame_buffer_wr_en = (draw_char_engine_1_out_valid || draw_block_engine_1_out_valid);
  always @(*) begin
    frame_buffer_wr_data = draw_block_engine_1_out_color;
    if(draw_char_engine_1_out_valid) begin
      frame_buffer_wr_data = draw_char_engine_1_out_color;
    end
  end

  assign draw_done = temp_draw_done;
  assign screen_is_ready = draw_controller_screen_is_ready;
  always @(*) begin
    fbScaleCounter_willIncrement = 1'b0;
    if(((! vga_sync_io_colorEn) && vga_sync_io_colorEn_regNext)) begin
      fbScaleCounter_willIncrement = 1'b1;
    end
  end

  assign fbScaleCounter_willDecrement = 1'b0;
  assign fbScaleCounter_willClear = 1'b0;
  assign fbScaleCounter_willLoad = 1'b0;
  assign fbScaleCounter_willOverflowIfInc = (fbScaleCounter_value == 1'b1);
  assign fbScaleCounter_willUnderflowIfDec = (fbScaleCounter_value == 1'b0);
  assign fbScaleCounter_willOverflow = (fbScaleCounter_willOverflowIfInc && fbScaleCounter_willIncrement);
  always @(*) begin
    fbScaleCounter_valueNext = (fbScaleCounter_value + fbScaleCounter_willIncrement);
    if(fbScaleCounter_willClear) begin
      fbScaleCounter_valueNext = 1'b0;
    end
  end

  assign fbScaleCounter_willUnderflow = (fbScaleCounter_willUnderflowIfDec && fbScaleCounter_willDecrement);
  assign lineFetchAllowed = ((fbScaleCounter_value == 1'b0) && vga_sync_io_vColorEn);
  assign lineFetchPulse = (vga_sync_io_sos && lineFetchAllowed);
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

  assign line_buffer_palette_addr = line_buffer_rd_out_payload;
  assign vga_hSync = vga_sync_io_hSync_delay_2;
  assign vga_vSync = vga_sync_io_vSync_delay_2;
  assign vga_colorEn = vga_sync_io_colorEn_delay_2;
  always @(*) begin
    if(line_buffer_palette_color_valid) begin
      if(isBackgroundIndex) begin
        vga_color_b = 4'b0111;
        vga_color_g = 4'b0011;
        vga_color_r = 4'b0001;
      end else begin
        vga_color_b = line_buffer_palette_color_payload[3 : 0];
        vga_color_g = line_buffer_palette_color_payload[7 : 4];
        vga_color_r = line_buffer_palette_color_payload[11 : 8];
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
  assign dmaArea_lineFetchToggleCore = line_fetch_toggle_buffercc_io_dataOut;
  assign dmaArea_frameStartToggleCore = frame_start_toggle_buffercc_io_dataOut;
  assign dmaArea_lineFetchStart = (dmaArea_lineFetchToggleCore != dmaArea_lineFetchToggleCore_regNext);
  assign dmaArea_frameStart = (dmaArea_frameStartToggleCore != dmaArea_frameStartToggleCore_regNext);
  always @(*) begin
    dmaArea_lineFetchPixelCounter_willIncrement = 1'b0;
    if(dmaArea_frameBufferFetchActive) begin
      dmaArea_lineFetchPixelCounter_willIncrement = 1'b1;
    end
  end

  assign dmaArea_lineFetchPixelCounter_willDecrement = 1'b0;
  always @(*) begin
    dmaArea_lineFetchPixelCounter_willClear = 1'b0;
    if(dmaArea_lineFetchPixelCounter_willOverflowIfInc) begin
      dmaArea_lineFetchPixelCounter_willClear = 1'b1;
    end
  end

  assign dmaArea_lineFetchPixelCounter_willLoad = 1'b0;
  assign dmaArea_lineFetchPixelCounter_willOverflowIfInc = (dmaArea_lineFetchPixelCounter_value == 9'h11f);
  assign dmaArea_lineFetchPixelCounter_willUnderflowIfDec = (dmaArea_lineFetchPixelCounter_value == 9'h0);
  assign dmaArea_lineFetchPixelCounter_willOverflow = (dmaArea_lineFetchPixelCounter_willOverflowIfInc && dmaArea_lineFetchPixelCounter_willIncrement);
  always @(*) begin
    dmaArea_lineFetchPixelCounter_valueNext = (dmaArea_lineFetchPixelCounter_value + temp_dmaArea_lineFetchPixelCounter_valueNext);
    if(dmaArea_lineFetchPixelCounter_willOverflow) begin
      dmaArea_lineFetchPixelCounter_valueNext = 9'h0;
    end
    if(dmaArea_lineFetchPixelCounter_willClear) begin
      dmaArea_lineFetchPixelCounter_valueNext = 9'h0;
    end
  end

  assign dmaArea_lineFetchPixelCounter_willUnderflow = (dmaArea_lineFetchPixelCounter_willUnderflowIfDec && dmaArea_lineFetchPixelCounter_willDecrement);
  always @(*) begin
    dmaArea_frameBufferReadAddr_willIncrement = 1'b0;
    if(dmaArea_frameBufferFetchActive) begin
      dmaArea_frameBufferReadAddr_willIncrement = 1'b1;
    end
  end

  assign dmaArea_frameBufferReadAddr_willDecrement = 1'b0;
  always @(*) begin
    dmaArea_frameBufferReadAddr_willClear = 1'b0;
    if(dmaArea_frameStart) begin
      dmaArea_frameBufferReadAddr_willClear = 1'b1;
    end
  end

  assign dmaArea_frameBufferReadAddr_willLoad = 1'b0;
  assign dmaArea_frameBufferReadAddr_willOverflowIfInc = (dmaArea_frameBufferReadAddr_value == 17'h10dff);
  assign dmaArea_frameBufferReadAddr_willUnderflowIfDec = (dmaArea_frameBufferReadAddr_value == 17'h0);
  assign dmaArea_frameBufferReadAddr_willOverflow = (dmaArea_frameBufferReadAddr_willOverflowIfInc && dmaArea_frameBufferReadAddr_willIncrement);
  always @(*) begin
    dmaArea_frameBufferReadAddr_valueNext = (dmaArea_frameBufferReadAddr_value + temp_dmaArea_frameBufferReadAddr_valueNext);
    if(dmaArea_frameBufferReadAddr_willOverflow) begin
      dmaArea_frameBufferReadAddr_valueNext = 17'h0;
    end
    if(dmaArea_frameBufferReadAddr_willClear) begin
      dmaArea_frameBufferReadAddr_valueNext = 17'h0;
    end
  end

  assign dmaArea_frameBufferReadAddr_willUnderflow = (dmaArea_frameBufferReadAddr_willUnderflowIfDec && dmaArea_frameBufferReadAddr_willDecrement);
  assign dmaArea_lineFetchWhileBusy = (dmaArea_lineFetchStart && dmaArea_frameBufferFetchActive);
  assign sof = dmaArea_frameStart;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      temp_draw_done <= 1'b0;
      dmaArea_lineFetchToggleCore_regNext <= 1'b0;
      dmaArea_frameStartToggleCore_regNext <= 1'b0;
      dmaArea_frameBufferFetchActive <= 1'b0;
      dmaArea_lineFetchPixelCounter_value <= 9'h0;
      dmaArea_frameBufferReadAddr_value <= 17'h0;
    end else begin
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! drawEnginesOverlap)); // display_top.scala:L250
        `else
          if(!(! drawEnginesOverlap)) begin
            $display("FAILURE display_top.core: char and block draw engines must not run simultaneously"); // display_top.scala:L250
            $finish;
          end
        `endif
      `endif
      temp_draw_done <= (draw_char_engine_1_done || draw_block_engine_1_done);
      dmaArea_lineFetchToggleCore_regNext <= dmaArea_lineFetchToggleCore;
      dmaArea_frameStartToggleCore_regNext <= dmaArea_frameStartToggleCore;
      dmaArea_lineFetchPixelCounter_value <= dmaArea_lineFetchPixelCounter_valueNext;
      dmaArea_frameBufferReadAddr_value <= dmaArea_frameBufferReadAddr_valueNext;
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! dmaArea_lineFetchWhileBusy)); // display_top.scala:L397
        `else
          if(!(! dmaArea_lineFetchWhileBusy)) begin
            $display("FAILURE display_top.dma: new line fetch started before the previous framebuffer burst completed"); // display_top.scala:L397
            $finish;
          end
        `endif
      `endif
      if(dmaArea_lineFetchStart) begin
        dmaArea_frameBufferFetchActive <= 1'b1;
      end
      if(dmaArea_lineFetchPixelCounter_willOverflowIfInc) begin
        dmaArea_frameBufferFetchActive <= 1'b0;
      end
    end
  end

  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      vga_sync_io_colorEn_regNext <= 1'b0;
      fbScaleCounter_value <= 1'b0;
      line_fetch_toggle <= 1'b0;
      frame_start_toggle <= 1'b0;
      temp_1 <= 1'b0;
      temp_rd_start_2 <= 5'h0;
      isBackgroundIndex <= 1'b0;
    end else begin
      vga_sync_io_colorEn_regNext <= vga_sync_io_colorEn;
      fbScaleCounter_value <= fbScaleCounter_valueNext;
      if(lineFetchPulse) begin
        line_fetch_toggle <= (! line_fetch_toggle);
      end
      if(vga_sync_io_sof) begin
        frame_start_toggle <= (! frame_start_toggle);
      end
      temp_rd_start_2 <= temp_rd_start_1;
      if(vga_sync_io_sol) begin
        temp_1 <= 1'b1;
      end
      if(temp_rd_start_3) begin
        temp_1 <= 1'b0;
      end
      isBackgroundIndex <= (line_buffer_rd_out_payload == 4'b0010);
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
  input  wire          drop,
  output wire          row_val_valid,
  output wire [9:0]    row_val_payload,
  output wire          score_val_valid,
  output wire [9:0]    score_val_payload,
  input  wire          draw_field_done,
  input  wire          screen_is_ready,
  input  wire          vga_sof,
  output wire          ctrl_allowed,
  output wire          softReset,
  output wire          game_restart,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam TYPE_1_I = 3'd0;
  localparam TYPE_1_J = 3'd1;
  localparam TYPE_1_L = 3'd2;
  localparam TYPE_1_O = 3'd3;
  localparam TYPE_1_S = 3'd4;
  localparam TYPE_1_T = 3'd5;
  localparam TYPE_1_Z = 3'd6;

  wire                playfield_inst_piece_in_valid;
  wire                piece_gen_inst_io_shape_valid;
  wire       [2:0]    piece_gen_inst_io_shape_payload;
  wire                playfield_inst_status_valid;
  wire                playfield_inst_status_payload;
  wire                playfield_inst_row_val_valid;
  wire       [9:0]    playfield_inst_row_val_payload;
  wire                playfield_inst_score_val_valid;
  wire       [9:0]    playfield_inst_score_val_payload;
  wire                playfield_inst_motion_is_allowed;
  wire                playfield_inst_fsm_is_idle;
  wire                controller_inst_game_restart;
  wire                controller_inst_softReset;
  wire                controller_inst_gen_piece_en;
  wire                controller_inst_move_out_left;
  wire                controller_inst_move_out_right;
  wire                controller_inst_move_out_rotate;
  wire                controller_inst_move_out_down;
  wire                controller_inst_lock;
  reg                 playfield_inst_status_stage_valid;
  reg                 playfield_inst_status_stage_payload;
  wire       [3:0]    temp_piece_in_valid;
  wire       [2:0]    temp_piece_in_payload;
  `ifndef SYNTHESIS
  reg [7:0] temp_piece_in_payload_string;
  `endif


  seven_bag_rng piece_gen_inst (
    .io_enable        (controller_inst_gen_piece_en        ), //i
    .io_shape_valid   (piece_gen_inst_io_shape_valid       ), //o
    .io_shape_payload (piece_gen_inst_io_shape_payload[2:0]), //o
    .core_clk         (core_clk                            ), //i
    .core_rst         (core_rst                            )  //i
  );
  playfield playfield_inst (
    .piece_in_valid    (playfield_inst_piece_in_valid        ), //i
    .piece_in_payload  (temp_piece_in_payload[2:0]           ), //i
    .status_valid      (playfield_inst_status_valid          ), //o
    .status_payload    (playfield_inst_status_payload        ), //o
    .move_in_left      (controller_inst_move_out_left        ), //i
    .move_in_right     (controller_inst_move_out_right       ), //i
    .move_in_rotate    (controller_inst_move_out_rotate      ), //i
    .move_in_down      (controller_inst_move_out_down        ), //i
    .lock              (controller_inst_lock                 ), //i
    .game_restart      (controller_inst_game_restart         ), //i
    .row_val_valid     (playfield_inst_row_val_valid         ), //o
    .row_val_payload   (playfield_inst_row_val_payload[9:0]  ), //o
    .score_val_valid   (playfield_inst_score_val_valid       ), //o
    .score_val_payload (playfield_inst_score_val_payload[9:0]), //o
    .motion_is_allowed (playfield_inst_motion_is_allowed     ), //o
    .fsm_is_idle       (playfield_inst_fsm_is_idle           ), //o
    .core_clk          (core_clk                             ), //i
    .core_rst          (core_rst                             )  //i
  );
  controller controller_inst (
    .game_start               (game_start                         ), //i
    .move_left                (move_left                          ), //i
    .move_right               (move_right                         ), //i
    .move_down                (move_down                          ), //i
    .rotate                   (rotate                             ), //i
    .drop                     (drop                               ), //i
    .screen_is_ready          (screen_is_ready                    ), //i
    .playfield_in_idle        (playfield_inst_fsm_is_idle         ), //i
    .playfield_allow_action   (playfield_inst_motion_is_allowed   ), //i
    .game_restart             (controller_inst_game_restart       ), //o
    .softReset                (controller_inst_softReset          ), //o
    .gen_piece_en             (controller_inst_gen_piece_en       ), //o
    .collision_status_valid   (playfield_inst_status_stage_valid  ), //i
    .collision_status_payload (playfield_inst_status_stage_payload), //i
    .move_out_left            (controller_inst_move_out_left      ), //o
    .move_out_right           (controller_inst_move_out_right     ), //o
    .move_out_rotate          (controller_inst_move_out_rotate    ), //o
    .move_out_down            (controller_inst_move_out_down      ), //o
    .lock                     (controller_inst_lock               ), //o
    .core_clk                 (core_clk                           ), //i
    .core_rst                 (core_rst                           )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(temp_piece_in_payload)
      TYPE_1_I : temp_piece_in_payload_string = "I";
      TYPE_1_J : temp_piece_in_payload_string = "J";
      TYPE_1_L : temp_piece_in_payload_string = "L";
      TYPE_1_O : temp_piece_in_payload_string = "O";
      TYPE_1_S : temp_piece_in_payload_string = "S";
      TYPE_1_T : temp_piece_in_payload_string = "T";
      TYPE_1_Z : temp_piece_in_payload_string = "Z";
      default : temp_piece_in_payload_string = "?";
    endcase
  end
  `endif

  assign temp_piece_in_valid = {piece_gen_inst_io_shape_payload,piece_gen_inst_io_shape_valid};
  assign playfield_inst_piece_in_valid = temp_piece_in_valid[0];
  assign temp_piece_in_payload = temp_piece_in_valid[3 : 1];
  assign softReset = controller_inst_softReset;
  assign game_restart = controller_inst_game_restart;
  assign row_val_valid = playfield_inst_row_val_valid;
  assign row_val_payload = playfield_inst_row_val_payload;
  assign score_val_valid = playfield_inst_score_val_valid;
  assign score_val_payload = playfield_inst_score_val_payload;
  assign ctrl_allowed = playfield_inst_motion_is_allowed;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      playfield_inst_status_stage_valid <= 1'b0;
    end else begin
      playfield_inst_status_stage_valid <= playfield_inst_status_valid;
    end
  end

  always @(posedge core_clk) begin
    playfield_inst_status_stage_payload <= playfield_inst_status_payload;
  end


endmodule

module UartCtrlRx (
  input  wire [2:0]    io_configFrame_dataLength,
  input  wire [0:0]    io_configFrame_stop,
  input  wire [1:0]    io_configFrame_parity,
  input  wire          io_samplingTick,
  output wire          io_read_valid,
  input  wire          io_read_ready,
  output wire [7:0]    io_read_payload,
  input  wire          io_rxd,
  output wire          io_rts,
  output reg           io_error,
  output wire          io_break,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;
  localparam UartCtrlRxState_IDLE = 3'd0;
  localparam UartCtrlRxState_START = 3'd1;
  localparam UartCtrlRxState_DATA = 3'd2;
  localparam UartCtrlRxState_PARITY = 3'd3;
  localparam UartCtrlRxState_STOP = 3'd4;

  wire                io_rxd_buffercc_io_dataOut;
  wire                temp_sampler_value;
  wire                temp_sampler_value_1;
  wire                temp_sampler_value_2;
  wire                temp_sampler_value_3;
  wire                temp_sampler_value_4;
  wire                temp_sampler_value_5;
  wire                temp_sampler_value_6;
  wire                temp_when;
  wire                temp_when_1;
  wire                temp_when_2;
  wire                temp_when_3;
  wire       [2:0]    temp_when_4;
  wire       [0:0]    temp_when_5;
  reg                 temp_io_rts;
  wire                sampler_synchronizer;
  wire                sampler_samples_0;
  reg                 sampler_samples_1;
  reg                 sampler_samples_2;
  reg                 sampler_samples_3;
  reg                 sampler_samples_4;
  reg                 sampler_value;
  reg                 sampler_tick;
  reg        [2:0]    bitTimer_counter;
  reg                 bitTimer_tick;
  reg        [2:0]    bitCounter_value;
  reg        [6:0]    break_counter;
  wire                break_valid;
  reg        [2:0]    stateMachine_state;
  reg                 stateMachine_parity;
  reg        [7:0]    stateMachine_shifter;
  reg                 stateMachine_validReg;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  `endif


  assign temp_when_2 = (stateMachine_parity == sampler_value);
  assign temp_when_3 = (! sampler_value);
  assign temp_when = ((sampler_tick && (! sampler_value)) && (! break_valid));
  assign temp_when_1 = (bitCounter_value == io_configFrame_dataLength);
  assign temp_when_5 = ((io_configFrame_stop == UartStopType_ONE) ? 1'b0 : 1'b1);
  assign temp_when_4 = {2'd0, temp_when_5};
  assign temp_sampler_value = ((((1'b0 || ((temp_sampler_value_1 && sampler_samples_1) && sampler_samples_2)) || (((temp_sampler_value_2 && sampler_samples_0) && sampler_samples_1) && sampler_samples_3)) || (((1'b1 && sampler_samples_0) && sampler_samples_2) && sampler_samples_3)) || (((1'b1 && sampler_samples_1) && sampler_samples_2) && sampler_samples_3));
  assign temp_sampler_value_3 = (((1'b1 && sampler_samples_0) && sampler_samples_1) && sampler_samples_4);
  assign temp_sampler_value_4 = ((1'b1 && sampler_samples_0) && sampler_samples_2);
  assign temp_sampler_value_5 = (1'b1 && sampler_samples_1);
  assign temp_sampler_value_6 = 1'b1;
  assign temp_sampler_value_1 = (1'b1 && sampler_samples_0);
  assign temp_sampler_value_2 = 1'b1;
  (* keep_hierarchy = "TRUE" *) BufferCC_3 io_rxd_buffercc (
    .io_dataIn  (io_rxd                    ), //i
    .io_dataOut (io_rxd_buffercc_io_dataOut), //o
    .core_clk   (core_clk                  ), //i
    .core_rst   (core_rst                  )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      UartStopType_ONE : io_configFrame_stop_string = "ONE";
      UartStopType_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      UartParityType_NONE : io_configFrame_parity_string = "NONE";
      UartParityType_EVEN : io_configFrame_parity_string = "EVEN";
      UartParityType_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      UartCtrlRxState_IDLE : stateMachine_state_string = "IDLE  ";
      UartCtrlRxState_START : stateMachine_state_string = "START ";
      UartCtrlRxState_DATA : stateMachine_state_string = "DATA  ";
      UartCtrlRxState_PARITY : stateMachine_state_string = "PARITY";
      UartCtrlRxState_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    io_error = 1'b0;
    case(stateMachine_state)
      UartCtrlRxState_IDLE : begin
      end
      UartCtrlRxState_START : begin
      end
      UartCtrlRxState_DATA : begin
      end
      UartCtrlRxState_PARITY : begin
        if(bitTimer_tick) begin
          if(!temp_when_2) begin
            io_error = 1'b1;
          end
        end
      end
      default : begin
        if(bitTimer_tick) begin
          if(temp_when_3) begin
            io_error = 1'b1;
          end
        end
      end
    endcase
  end

  assign io_rts = temp_io_rts;
  assign sampler_synchronizer = io_rxd_buffercc_io_dataOut;
  assign sampler_samples_0 = sampler_synchronizer;
  always @(*) begin
    bitTimer_tick = 1'b0;
    if(sampler_tick) begin
      if((bitTimer_counter == 3'b000)) begin
        bitTimer_tick = 1'b1;
      end
    end
  end

  assign break_valid = (break_counter == 7'h68);
  assign io_break = break_valid;
  assign io_read_valid = stateMachine_validReg;
  assign io_read_payload = stateMachine_shifter;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      temp_io_rts <= 1'b0;
      sampler_samples_1 <= 1'b1;
      sampler_samples_2 <= 1'b1;
      sampler_samples_3 <= 1'b1;
      sampler_samples_4 <= 1'b1;
      sampler_value <= 1'b1;
      sampler_tick <= 1'b0;
      break_counter <= 7'h0;
      stateMachine_state <= UartCtrlRxState_IDLE;
      stateMachine_validReg <= 1'b0;
    end else begin
      temp_io_rts <= (! io_read_ready);
      if(io_samplingTick) begin
        sampler_samples_1 <= sampler_samples_0;
      end
      if(io_samplingTick) begin
        sampler_samples_2 <= sampler_samples_1;
      end
      if(io_samplingTick) begin
        sampler_samples_3 <= sampler_samples_2;
      end
      if(io_samplingTick) begin
        sampler_samples_4 <= sampler_samples_3;
      end
      sampler_value <= ((((((temp_sampler_value || temp_sampler_value_3) || (temp_sampler_value_4 && sampler_samples_4)) || ((temp_sampler_value_5 && sampler_samples_2) && sampler_samples_4)) || (((temp_sampler_value_6 && sampler_samples_0) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_1) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_2) && sampler_samples_3) && sampler_samples_4));
      sampler_tick <= io_samplingTick;
      if(sampler_value) begin
        break_counter <= 7'h0;
      end else begin
        if((io_samplingTick && (! break_valid))) begin
          break_counter <= (break_counter + 7'h01);
        end
      end
      stateMachine_validReg <= 1'b0;
      case(stateMachine_state)
        UartCtrlRxState_IDLE : begin
          if(temp_when) begin
            stateMachine_state <= UartCtrlRxState_START;
          end
        end
        UartCtrlRxState_START : begin
          if(bitTimer_tick) begin
            stateMachine_state <= UartCtrlRxState_DATA;
            if((sampler_value == 1'b1)) begin
              stateMachine_state <= UartCtrlRxState_IDLE;
            end
          end
        end
        UartCtrlRxState_DATA : begin
          if(bitTimer_tick) begin
            if(temp_when_1) begin
              if((io_configFrame_parity == UartParityType_NONE)) begin
                stateMachine_state <= UartCtrlRxState_STOP;
                stateMachine_validReg <= 1'b1;
              end else begin
                stateMachine_state <= UartCtrlRxState_PARITY;
              end
            end
          end
        end
        UartCtrlRxState_PARITY : begin
          if(bitTimer_tick) begin
            if(temp_when_2) begin
              stateMachine_state <= UartCtrlRxState_STOP;
              stateMachine_validReg <= 1'b1;
            end else begin
              stateMachine_state <= UartCtrlRxState_IDLE;
            end
          end
        end
        default : begin
          if(bitTimer_tick) begin
            if(temp_when_3) begin
              stateMachine_state <= UartCtrlRxState_IDLE;
            end else begin
              if((bitCounter_value == temp_when_4)) begin
                stateMachine_state <= UartCtrlRxState_IDLE;
              end
            end
          end
        end
      endcase
    end
  end

  always @(posedge core_clk) begin
    if(sampler_tick) begin
      bitTimer_counter <= (bitTimer_counter - 3'b001);
    end
    if(bitTimer_tick) begin
      bitCounter_value <= (bitCounter_value + 3'b001);
    end
    if(bitTimer_tick) begin
      stateMachine_parity <= (stateMachine_parity ^ sampler_value);
    end
    case(stateMachine_state)
      UartCtrlRxState_IDLE : begin
        if(temp_when) begin
          bitTimer_counter <= 3'b010;
        end
      end
      UartCtrlRxState_START : begin
        if(bitTimer_tick) begin
          bitCounter_value <= 3'b000;
          stateMachine_parity <= (io_configFrame_parity == UartParityType_ODD);
        end
      end
      UartCtrlRxState_DATA : begin
        if(bitTimer_tick) begin
          stateMachine_shifter[bitCounter_value] <= sampler_value;
          if(temp_when_1) begin
            bitCounter_value <= 3'b000;
          end
        end
      end
      UartCtrlRxState_PARITY : begin
        if(bitTimer_tick) begin
          bitCounter_value <= 3'b000;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module UartCtrlTx (
  input  wire [2:0]    io_configFrame_dataLength,
  input  wire [0:0]    io_configFrame_stop,
  input  wire [1:0]    io_configFrame_parity,
  input  wire          io_samplingTick,
  input  wire          io_write_valid,
  output reg           io_write_ready,
  input  wire [7:0]    io_write_payload,
  input  wire          io_cts,
  output wire          io_txd,
  input  wire          io_break,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;
  localparam UartCtrlTxState_IDLE = 3'd0;
  localparam UartCtrlTxState_START = 3'd1;
  localparam UartCtrlTxState_DATA = 3'd2;
  localparam UartCtrlTxState_PARITY = 3'd3;
  localparam UartCtrlTxState_STOP = 3'd4;

  wire       [2:0]    temp_clockDivider_counter_valueNext;
  wire       [0:0]    temp_clockDivider_counter_valueNext_1;
  wire                temp_when;
  wire       [2:0]    temp_when_1;
  wire       [0:0]    temp_when_2;
  reg                 clockDivider_counter_willIncrement;
  wire                clockDivider_counter_willDecrement;
  wire                clockDivider_counter_willClear;
  wire                clockDivider_counter_willLoad;
  reg        [2:0]    clockDivider_counter_valueNext;
  reg        [2:0]    clockDivider_counter_value;
  wire                clockDivider_counter_willOverflowIfInc;
  wire                clockDivider_counter_willUnderflowIfDec;
  wire                clockDivider_counter_willOverflow;
  wire                clockDivider_counter_willUnderflow;
  reg        [2:0]    tickCounter_value;
  reg        [2:0]    stateMachine_state;
  reg                 stateMachine_parity;
  reg                 stateMachine_txd;
  wire       [2:0]    temp_stateMachine_state;
  reg                 temp_io_txd;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  reg [47:0] temp_stateMachine_state_string;
  `endif


  assign temp_when = (tickCounter_value == io_configFrame_dataLength);
  assign temp_clockDivider_counter_valueNext_1 = clockDivider_counter_willIncrement;
  assign temp_clockDivider_counter_valueNext = {2'd0, temp_clockDivider_counter_valueNext_1};
  assign temp_when_2 = ((io_configFrame_stop == UartStopType_ONE) ? 1'b0 : 1'b1);
  assign temp_when_1 = {2'd0, temp_when_2};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      UartStopType_ONE : io_configFrame_stop_string = "ONE";
      UartStopType_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      UartParityType_NONE : io_configFrame_parity_string = "NONE";
      UartParityType_EVEN : io_configFrame_parity_string = "EVEN";
      UartParityType_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      UartCtrlTxState_IDLE : stateMachine_state_string = "IDLE  ";
      UartCtrlTxState_START : stateMachine_state_string = "START ";
      UartCtrlTxState_DATA : stateMachine_state_string = "DATA  ";
      UartCtrlTxState_PARITY : stateMachine_state_string = "PARITY";
      UartCtrlTxState_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  always @(*) begin
    case(temp_stateMachine_state)
      UartCtrlTxState_IDLE : temp_stateMachine_state_string = "IDLE  ";
      UartCtrlTxState_START : temp_stateMachine_state_string = "START ";
      UartCtrlTxState_DATA : temp_stateMachine_state_string = "DATA  ";
      UartCtrlTxState_PARITY : temp_stateMachine_state_string = "PARITY";
      UartCtrlTxState_STOP : temp_stateMachine_state_string = "STOP  ";
      default : temp_stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    clockDivider_counter_willIncrement = 1'b0;
    if(io_samplingTick) begin
      clockDivider_counter_willIncrement = 1'b1;
    end
  end

  assign clockDivider_counter_willDecrement = 1'b0;
  assign clockDivider_counter_willClear = 1'b0;
  assign clockDivider_counter_willLoad = 1'b0;
  assign clockDivider_counter_willOverflowIfInc = (clockDivider_counter_value == 3'b111);
  assign clockDivider_counter_willUnderflowIfDec = (clockDivider_counter_value == 3'b000);
  assign clockDivider_counter_willOverflow = (clockDivider_counter_willOverflowIfInc && clockDivider_counter_willIncrement);
  always @(*) begin
    clockDivider_counter_valueNext = (clockDivider_counter_value + temp_clockDivider_counter_valueNext);
    if(clockDivider_counter_willClear) begin
      clockDivider_counter_valueNext = 3'b000;
    end
  end

  assign clockDivider_counter_willUnderflow = (clockDivider_counter_willUnderflowIfDec && clockDivider_counter_willDecrement);
  always @(*) begin
    stateMachine_txd = 1'b1;
    io_write_ready = io_break;
    case(stateMachine_state)
      UartCtrlTxState_IDLE : begin
      end
      UartCtrlTxState_START : begin
        stateMachine_txd = 1'b0;
      end
      UartCtrlTxState_DATA : begin
        stateMachine_txd = io_write_payload[tickCounter_value];
        if(clockDivider_counter_willOverflow) begin
          if(temp_when) begin
            io_write_ready = 1'b1;
          end
        end
      end
      UartCtrlTxState_PARITY : begin
        stateMachine_txd = stateMachine_parity;
      end
      default : begin
      end
    endcase
  end

  assign temp_stateMachine_state = (io_write_valid ? UartCtrlTxState_START : UartCtrlTxState_IDLE);
  assign io_txd = temp_io_txd;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      clockDivider_counter_value <= 3'b000;
      stateMachine_state <= UartCtrlTxState_IDLE;
      temp_io_txd <= 1'b1;
    end else begin
      clockDivider_counter_value <= clockDivider_counter_valueNext;
      case(stateMachine_state)
        UartCtrlTxState_IDLE : begin
          if(((io_write_valid && (! io_cts)) && clockDivider_counter_willOverflow)) begin
            stateMachine_state <= UartCtrlTxState_START;
          end
        end
        UartCtrlTxState_START : begin
          if(clockDivider_counter_willOverflow) begin
            stateMachine_state <= UartCtrlTxState_DATA;
          end
        end
        UartCtrlTxState_DATA : begin
          if(clockDivider_counter_willOverflow) begin
            if(temp_when) begin
              if((io_configFrame_parity == UartParityType_NONE)) begin
                stateMachine_state <= UartCtrlTxState_STOP;
              end else begin
                stateMachine_state <= UartCtrlTxState_PARITY;
              end
            end
          end
        end
        UartCtrlTxState_PARITY : begin
          if(clockDivider_counter_willOverflow) begin
            stateMachine_state <= UartCtrlTxState_STOP;
          end
        end
        default : begin
          if(clockDivider_counter_willOverflow) begin
            if((tickCounter_value == temp_when_1)) begin
              stateMachine_state <= temp_stateMachine_state;
            end
          end
        end
      endcase
      temp_io_txd <= (stateMachine_txd && (! io_break));
    end
  end

  always @(posedge core_clk) begin
    if(clockDivider_counter_willOverflow) begin
      tickCounter_value <= (tickCounter_value + 3'b001);
    end
    if(clockDivider_counter_willOverflow) begin
      stateMachine_parity <= (stateMachine_parity ^ stateMachine_txd);
    end
    case(stateMachine_state)
      UartCtrlTxState_IDLE : begin
      end
      UartCtrlTxState_START : begin
        if(clockDivider_counter_willOverflow) begin
          stateMachine_parity <= (io_configFrame_parity == UartParityType_ODD);
          tickCounter_value <= 3'b000;
        end
      end
      UartCtrlTxState_DATA : begin
        if(clockDivider_counter_willOverflow) begin
          if(temp_when) begin
            tickCounter_value <= 3'b000;
          end
        end
      end
      UartCtrlTxState_PARITY : begin
        if(clockDivider_counter_willOverflow) begin
          tickCounter_value <= 3'b000;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

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
  wire                rd_scale_cnt_willDecrement;
  reg                 rd_scale_cnt_willClear;
  wire                rd_scale_cnt_willLoad;
  reg        [0:0]    rd_scale_cnt_valueNext;
  reg        [0:0]    rd_scale_cnt_value;
  wire                rd_scale_cnt_willOverflowIfInc;
  wire                rd_scale_cnt_willUnderflowIfDec;
  wire                rd_scale_cnt_willOverflow;
  wire                rd_scale_cnt_willUnderflow;
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

  assign rd_scale_cnt_willDecrement = 1'b0;
  always @(*) begin
    rd_scale_cnt_willClear = 1'b0;
    if(rd_start) begin
      rd_scale_cnt_willClear = 1'b1;
    end
  end

  assign rd_scale_cnt_willLoad = 1'b0;
  assign rd_scale_cnt_willOverflowIfInc = (rd_scale_cnt_value == 1'b1);
  assign rd_scale_cnt_willUnderflowIfDec = (rd_scale_cnt_value == 1'b0);
  assign rd_scale_cnt_willOverflow = (rd_scale_cnt_willOverflowIfInc && rd_scale_cnt_willIncrement);
  always @(*) begin
    rd_scale_cnt_valueNext = (rd_scale_cnt_value + rd_scale_cnt_willIncrement);
    if(rd_scale_cnt_willClear) begin
      rd_scale_cnt_valueNext = 1'b0;
    end
  end

  assign rd_scale_cnt_willUnderflow = (rd_scale_cnt_willUnderflowIfDec && rd_scale_cnt_willDecrement);
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

module color_palette (
  input  wire [3:0]    addr,
  input  wire          rd_en,
  output wire          color_valid,
  output wire [11:0]   color_payload,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  reg        [11:0]   rom_spinal_port0;
  reg                 rd_en_regNext;
  (* ram_style = "distributed" *) reg [11:0] rom [0:15];

  initial begin
    $readmemb("tetris_top.v_toplevel_tetris_core_inst_game_display_inst_line_buffer_palette_rom.bin",rom);
  end
  always @(posedge vga_clk) begin
    if(rd_en) begin
      rom_spinal_port0 <= rom[addr];
    end
  end

  assign color_payload = rom_spinal_port0;
  assign color_valid = rd_en_regNext;
  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      rd_en_regNext <= 1'b0;
    end else begin
      rd_en_regNext <= rd_en;
    end
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
  input  wire          frame_start,
  input  wire          game_start,
  input  wire          row_val_valid,
  input  wire [9:0]    row_val_payload,
  input  wire          score_val_valid,
  input  wire [9:0]    score_val_payload,
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
  output reg  [8:0]    draw_x_orig,
  output reg  [7:0]    draw_y_orig,
  output reg           draw_field_done,
  output reg           bf_clear_start,
  input  wire          bf_clear_done,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam runtime_renderer_fsm_IDLE = 3'd0;
  localparam runtime_renderer_fsm_FETCH_ROW = 3'd1;
  localparam runtime_renderer_fsm_LOAD_ROW = 3'd2;
  localparam runtime_renderer_fsm_DRAW_FIELD_BLOCK = 3'd3;
  localparam runtime_renderer_fsm_WAIT_FIELD_BLOCK_DONE = 3'd4;
  localparam runtime_renderer_fsm_DRAW_SCORE_DIGIT = 3'd5;
  localparam runtime_renderer_fsm_WAIT_SCORE_DIGIT_DONE = 3'd6;
  localparam runtime_renderer_fsm_COMPLETE = 3'd7;
  localparam setup_renderer_fsm_SETUP_IDLE = 4'd0;
  localparam setup_renderer_fsm_CLEAN_SCREEN = 4'd1;
  localparam setup_renderer_fsm_DRAW_OPENING_TEXT = 4'd2;
  localparam setup_renderer_fsm_WAIT_OPENING_TEXT_DONE = 4'd3;
  localparam setup_renderer_fsm_WAIT_GAME_START = 4'd4;
  localparam setup_renderer_fsm_DRAW_STATIC_TEXT = 4'd5;
  localparam setup_renderer_fsm_WAIT_STATIC_TEXT_DONE = 4'd6;
  localparam setup_renderer_fsm_DRAW_WALL = 4'd7;
  localparam setup_renderer_fsm_WAIT_WALL_DONE = 4'd8;
  localparam setup_renderer_fsm_RUNNING = 4'd9;
  localparam setup_renderer_fsm_WAIT_RUNTIME_IDLE = 4'd10;

  wire       [6:0]    text_rom_rom_spinal_port0;
  wire       [42:0]   wall_rom_wallMem_spinal_port0;
  reg        [9:0]    playfield_storage_memory_spinal_port1;
  wire                score_cache_bcdInst_data_out_dec_valid;
  wire       [15:0]   score_cache_bcdInst_data_out_dec_payload;
  wire       [3:0]    temp_text_rom_charCounter_valueNext;
  wire       [0:0]    temp_text_rom_charCounter_valueNext_1;
  wire       [1:0]    temp_wall_rom_wallCounter_valueNext;
  wire       [0:0]    temp_wall_rom_wallCounter_valueNext_1;
  wire       [4:0]    temp_playfield_storage_writeRowCounter_valueNext;
  wire       [0:0]    temp_playfield_storage_writeRowCounter_valueNext_1;
  wire       [4:0]    temp_runtime_renderer_rowCounter_valueNext;
  wire       [0:0]    temp_runtime_renderer_rowCounter_valueNext_1;
  wire       [3:0]    temp_runtime_renderer_colCounter_valueNext;
  wire       [0:0]    temp_runtime_renderer_colCounter_valueNext_1;
  wire       [1:0]    temp_runtime_renderer_scoreDigitCounter_valueNext;
  wire       [0:0]    temp_runtime_renderer_scoreDigitCounter_valueNext_1;
  wire                temp_when;
  reg        [3:0]    temp_runtime_renderer_scoreCommand_word;
  wire                temp_when_1;
  wire                temp_when_2;
  wire                temp_when_3;
  reg                 runtimeRenderEnable;
  reg                 runtimeRenderBusy;
  reg                 runtimeRenderStart;
  reg                 clearPendingPlayfieldRender;
  wire                setupCharDone;
  wire                runtimeScoreCharDone;
  wire                setupBlockDone;
  wire                runtimeFieldBlockDone;
  reg        [15:0]   score_cache_scoreReg;
  wire       [3:0]    score_cache_digits_0;
  wire       [3:0]    score_cache_digits_1;
  wire       [3:0]    score_cache_digits_2;
  wire       [3:0]    score_cache_digits_3;
  reg                 text_rom_charCounter_willIncrement;
  wire                text_rom_charCounter_willDecrement;
  reg                 text_rom_charCounter_willClear;
  reg                 text_rom_charCounter_willLoad;
  reg        [3:0]    text_rom_charCounter_valueNext;
  reg        [3:0]    text_rom_charCounter_value;
  wire                text_rom_charCounter_willOverflowIfInc;
  wire                text_rom_charCounter_willUnderflowIfDec;
  wire                text_rom_charCounter_willOverflow;
  wire                text_rom_charCounter_willUnderflow;
  wire       [6:0]    text_rom_word;
  reg                 wall_rom_wallCounter_willIncrement;
  wire                wall_rom_wallCounter_willDecrement;
  reg                 wall_rom_wallCounter_willClear;
  wire                wall_rom_wallCounter_willLoad;
  reg        [1:0]    wall_rom_wallCounter_valueNext;
  reg        [1:0]    wall_rom_wallCounter_value;
  wire                wall_rom_wallCounter_willOverflowIfInc;
  wire                wall_rom_wallCounter_willUnderflowIfDec;
  wire                wall_rom_wallCounter_willOverflow;
  wire                wall_rom_wallCounter_willUnderflow;
  wire                wall_rom_command_start;
  wire       [8:0]    wall_rom_command_x_orig;
  wire       [7:0]    wall_rom_command_y_orig;
  wire       [7:0]    wall_rom_command_width;
  wire       [7:0]    wall_rom_command_height;
  wire       [3:0]    wall_rom_command_in_color;
  wire       [3:0]    wall_rom_command_pat_color;
  wire       [1:0]    wall_rom_command_fill_pattern;
  wire       [42:0]   wall_rom_blockInfo;
  reg                 pendingPlayfieldRender;
  reg                 playfield_storage_writeRowCounter_willIncrement;
  wire                playfield_storage_writeRowCounter_willDecrement;
  wire                playfield_storage_writeRowCounter_willClear;
  wire                playfield_storage_writeRowCounter_willLoad;
  reg        [4:0]    playfield_storage_writeRowCounter_valueNext;
  reg        [4:0]    playfield_storage_writeRowCounter_value;
  wire                playfield_storage_writeRowCounter_willOverflowIfInc;
  wire                playfield_storage_writeRowCounter_willUnderflowIfDec;
  wire                playfield_storage_writeRowCounter_willOverflow;
  wire                playfield_storage_writeRowCounter_willUnderflow;
  reg                 row_val_valid_regNext;
  wire                playfield_storage_rowBurstComplete;
  reg                 runtime_renderer_blockCommand_start;
  reg        [8:0]    runtime_renderer_blockCommand_x_orig;
  reg        [7:0]    runtime_renderer_blockCommand_y_orig;
  reg        [7:0]    runtime_renderer_blockCommand_width;
  reg        [7:0]    runtime_renderer_blockCommand_height;
  reg        [3:0]    runtime_renderer_blockCommand_in_color;
  reg        [3:0]    runtime_renderer_blockCommand_pat_color;
  reg        [1:0]    runtime_renderer_blockCommand_fill_pattern;
  reg                 runtime_renderer_scoreCommand_start;
  reg        [8:0]    runtime_renderer_scoreCommand_x_orig;
  reg        [7:0]    runtime_renderer_scoreCommand_y_orig;
  reg        [6:0]    runtime_renderer_scoreCommand_word;
  reg        [2:0]    runtime_renderer_scoreCommand_scale;
  reg        [3:0]    runtime_renderer_scoreCommand_color;
  (* keep *) reg                 runtime_renderer_readEnable;
  reg                 runtime_renderer_rowCounter_willIncrement;
  wire                runtime_renderer_rowCounter_willDecrement;
  reg                 runtime_renderer_rowCounter_willClear;
  wire                runtime_renderer_rowCounter_willLoad;
  reg        [4:0]    runtime_renderer_rowCounter_valueNext;
  reg        [4:0]    runtime_renderer_rowCounter_value;
  wire                runtime_renderer_rowCounter_willOverflowIfInc;
  wire                runtime_renderer_rowCounter_willUnderflowIfDec;
  wire                runtime_renderer_rowCounter_willOverflow;
  wire                runtime_renderer_rowCounter_willUnderflow;
  reg                 runtime_renderer_colCounter_willIncrement;
  wire                runtime_renderer_colCounter_willDecrement;
  reg                 runtime_renderer_colCounter_willClear;
  wire                runtime_renderer_colCounter_willLoad;
  reg        [3:0]    runtime_renderer_colCounter_valueNext;
  reg        [3:0]    runtime_renderer_colCounter_value;
  wire                runtime_renderer_colCounter_willOverflowIfInc;
  wire                runtime_renderer_colCounter_willUnderflowIfDec;
  wire                runtime_renderer_colCounter_willOverflow;
  wire                runtime_renderer_colCounter_willUnderflow;
  reg                 runtime_renderer_scoreDigitCounter_willIncrement;
  wire                runtime_renderer_scoreDigitCounter_willDecrement;
  reg                 runtime_renderer_scoreDigitCounter_willClear;
  wire                runtime_renderer_scoreDigitCounter_willLoad;
  reg        [1:0]    runtime_renderer_scoreDigitCounter_valueNext;
  reg        [1:0]    runtime_renderer_scoreDigitCounter_value;
  wire                runtime_renderer_scoreDigitCounter_willOverflowIfInc;
  wire                runtime_renderer_scoreDigitCounter_willUnderflowIfDec;
  wire                runtime_renderer_scoreDigitCounter_willOverflow;
  wire                runtime_renderer_scoreDigitCounter_willUnderflow;
  wire       [9:0]    runtime_renderer_rowValue;
  reg        [9:0]    runtime_renderer_rowBits;
  reg        [8:0]    runtime_renderer_fieldX;
  reg        [7:0]    runtime_renderer_fieldY;
  reg        [8:0]    runtime_renderer_scoreX;
  reg        [3:0]    runtime_renderer_fieldColor;
  wire                runtime_renderer_fsm_wantExit;
  reg                 runtime_renderer_fsm_wantStart;
  wire                runtime_renderer_fsm_wantKill;
  reg                 setup_renderer_charCommand_start;
  reg        [8:0]    setup_renderer_charCommand_x_orig;
  reg        [7:0]    setup_renderer_charCommand_y_orig;
  reg        [6:0]    setup_renderer_charCommand_word;
  reg        [2:0]    setup_renderer_charCommand_scale;
  reg        [3:0]    setup_renderer_charCommand_color;
  reg                 setup_renderer_blockCommand_start;
  reg        [8:0]    setup_renderer_blockCommand_x_orig;
  reg        [7:0]    setup_renderer_blockCommand_y_orig;
  reg        [7:0]    setup_renderer_blockCommand_width;
  reg        [7:0]    setup_renderer_blockCommand_height;
  reg        [3:0]    setup_renderer_blockCommand_in_color;
  reg        [3:0]    setup_renderer_blockCommand_pat_color;
  reg        [1:0]    setup_renderer_blockCommand_fill_pattern;
  reg        [8:0]    setup_renderer_textX;
  reg        [7:0]    setup_renderer_textY;
  reg        [2:0]    setup_renderer_textScale;
  reg        [3:0]    setup_renderer_textColor;
  reg                 setup_renderer_gameIsRunning;
  wire                setup_renderer_fsm_wantExit;
  reg                 setup_renderer_fsm_wantStart;
  wire                setup_renderer_fsm_wantKill;
  wire       [3:0]    setup_renderer_fsmDebug;
  reg                 selectedCharCommand_start;
  reg        [8:0]    selectedCharCommand_x_orig;
  reg        [7:0]    selectedCharCommand_y_orig;
  reg        [6:0]    selectedCharCommand_word;
  reg        [2:0]    selectedCharCommand_scale;
  reg        [3:0]    selectedCharCommand_color;
  reg                 selectedBlockCommand_start;
  reg        [8:0]    selectedBlockCommand_x_orig;
  reg        [7:0]    selectedBlockCommand_y_orig;
  reg        [7:0]    selectedBlockCommand_width;
  reg        [7:0]    selectedBlockCommand_height;
  reg        [3:0]    selectedBlockCommand_in_color;
  reg        [3:0]    selectedBlockCommand_pat_color;
  reg        [1:0]    selectedBlockCommand_fill_pattern;
  wire                charStartCollision;
  wire                blockStartCollision;
  wire                drawStartCollision;
  reg                 charOwnerIsSetup;
  reg                 blockOwnerIsSetup;
  reg        [2:0]    runtime_renderer_fsm_stateReg;
  reg        [2:0]    runtime_renderer_fsm_stateNext;
  reg        [3:0]    setup_renderer_fsm_stateReg;
  reg        [3:0]    setup_renderer_fsm_stateNext;
  wire                setup_renderer_fsm_onEntry_CLEAN_SCREEN;
  `ifndef SYNTHESIS
  reg [167:0] runtime_renderer_fsm_stateReg_string;
  reg [167:0] runtime_renderer_fsm_stateNext_string;
  reg [175:0] setup_renderer_fsm_stateReg_string;
  reg [175:0] setup_renderer_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [6:0] text_rom_rom [0:10];
  reg [42:0] wall_rom_wallMem [0:3];
  (* ram_style = "distributed" *) reg [9:0] playfield_storage_memory [0:21];

  assign temp_when_2 = (text_rom_charCounter_value == 4'b0101);
  assign temp_when_3 = (text_rom_charCounter_value == 4'b1010);
  assign temp_when = (runtime_renderer_rowCounter_willOverflowIfInc && runtime_renderer_colCounter_willOverflowIfInc);
  assign temp_when_1 = ((pendingPlayfieldRender && frame_start) && runtimeRenderEnable);
  assign temp_text_rom_charCounter_valueNext_1 = text_rom_charCounter_willIncrement;
  assign temp_text_rom_charCounter_valueNext = {3'd0, temp_text_rom_charCounter_valueNext_1};
  assign temp_wall_rom_wallCounter_valueNext_1 = wall_rom_wallCounter_willIncrement;
  assign temp_wall_rom_wallCounter_valueNext = {1'd0, temp_wall_rom_wallCounter_valueNext_1};
  assign temp_playfield_storage_writeRowCounter_valueNext_1 = playfield_storage_writeRowCounter_willIncrement;
  assign temp_playfield_storage_writeRowCounter_valueNext = {4'd0, temp_playfield_storage_writeRowCounter_valueNext_1};
  assign temp_runtime_renderer_rowCounter_valueNext_1 = runtime_renderer_rowCounter_willIncrement;
  assign temp_runtime_renderer_rowCounter_valueNext = {4'd0, temp_runtime_renderer_rowCounter_valueNext_1};
  assign temp_runtime_renderer_colCounter_valueNext_1 = runtime_renderer_colCounter_willIncrement;
  assign temp_runtime_renderer_colCounter_valueNext = {3'd0, temp_runtime_renderer_colCounter_valueNext_1};
  assign temp_runtime_renderer_scoreDigitCounter_valueNext_1 = runtime_renderer_scoreDigitCounter_willIncrement;
  assign temp_runtime_renderer_scoreDigitCounter_valueNext = {1'd0, temp_runtime_renderer_scoreDigitCounter_valueNext_1};
  initial begin
    $readmemb("tetris_top.v_toplevel_tetris_core_inst_game_display_inst_draw_controller_text_rom_rom.bin",text_rom_rom);
  end
  assign text_rom_rom_spinal_port0 = text_rom_rom[text_rom_charCounter_value];
  initial begin
    $readmemb("tetris_top.v_toplevel_tetris_core_inst_game_display_inst_draw_controller_wall_rom_wallMem.bin",wall_rom_wallMem);
  end
  assign wall_rom_wallMem_spinal_port0 = wall_rom_wallMem[wall_rom_wallCounter_value];
  always @(posedge core_clk) begin
    if(row_val_valid) begin
      playfield_storage_memory[playfield_storage_writeRowCounter_value] <= row_val_payload;
    end
  end

  always @(posedge core_clk) begin
    if(runtime_renderer_readEnable) begin
      playfield_storage_memory_spinal_port1 <= playfield_storage_memory[runtime_renderer_rowCounter_value];
    end
  end

  bcd score_cache_bcdInst (
    .data_in_bin_valid    (score_val_valid                               ), //i
    .data_in_bin_payload  (score_val_payload[9:0]                        ), //i
    .data_out_dec_valid   (score_cache_bcdInst_data_out_dec_valid        ), //o
    .data_out_dec_payload (score_cache_bcdInst_data_out_dec_payload[15:0]), //o
    .core_clk             (core_clk                                      ), //i
    .core_rst             (core_rst                                      )  //i
  );
  always @(*) begin
    case(runtime_renderer_scoreDigitCounter_value)
      2'b00 : temp_runtime_renderer_scoreCommand_word = score_cache_digits_0;
      2'b01 : temp_runtime_renderer_scoreCommand_word = score_cache_digits_1;
      2'b10 : temp_runtime_renderer_scoreCommand_word = score_cache_digits_2;
      default : temp_runtime_renderer_scoreCommand_word = score_cache_digits_3;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(runtime_renderer_fsm_stateReg)
      runtime_renderer_fsm_IDLE : runtime_renderer_fsm_stateReg_string = "IDLE                 ";
      runtime_renderer_fsm_FETCH_ROW : runtime_renderer_fsm_stateReg_string = "FETCH_ROW            ";
      runtime_renderer_fsm_LOAD_ROW : runtime_renderer_fsm_stateReg_string = "LOAD_ROW             ";
      runtime_renderer_fsm_DRAW_FIELD_BLOCK : runtime_renderer_fsm_stateReg_string = "DRAW_FIELD_BLOCK     ";
      runtime_renderer_fsm_WAIT_FIELD_BLOCK_DONE : runtime_renderer_fsm_stateReg_string = "WAIT_FIELD_BLOCK_DONE";
      runtime_renderer_fsm_DRAW_SCORE_DIGIT : runtime_renderer_fsm_stateReg_string = "DRAW_SCORE_DIGIT     ";
      runtime_renderer_fsm_WAIT_SCORE_DIGIT_DONE : runtime_renderer_fsm_stateReg_string = "WAIT_SCORE_DIGIT_DONE";
      runtime_renderer_fsm_COMPLETE : runtime_renderer_fsm_stateReg_string = "COMPLETE             ";
      default : runtime_renderer_fsm_stateReg_string = "?????????????????????";
    endcase
  end
  always @(*) begin
    case(runtime_renderer_fsm_stateNext)
      runtime_renderer_fsm_IDLE : runtime_renderer_fsm_stateNext_string = "IDLE                 ";
      runtime_renderer_fsm_FETCH_ROW : runtime_renderer_fsm_stateNext_string = "FETCH_ROW            ";
      runtime_renderer_fsm_LOAD_ROW : runtime_renderer_fsm_stateNext_string = "LOAD_ROW             ";
      runtime_renderer_fsm_DRAW_FIELD_BLOCK : runtime_renderer_fsm_stateNext_string = "DRAW_FIELD_BLOCK     ";
      runtime_renderer_fsm_WAIT_FIELD_BLOCK_DONE : runtime_renderer_fsm_stateNext_string = "WAIT_FIELD_BLOCK_DONE";
      runtime_renderer_fsm_DRAW_SCORE_DIGIT : runtime_renderer_fsm_stateNext_string = "DRAW_SCORE_DIGIT     ";
      runtime_renderer_fsm_WAIT_SCORE_DIGIT_DONE : runtime_renderer_fsm_stateNext_string = "WAIT_SCORE_DIGIT_DONE";
      runtime_renderer_fsm_COMPLETE : runtime_renderer_fsm_stateNext_string = "COMPLETE             ";
      default : runtime_renderer_fsm_stateNext_string = "?????????????????????";
    endcase
  end
  always @(*) begin
    case(setup_renderer_fsm_stateReg)
      setup_renderer_fsm_SETUP_IDLE : setup_renderer_fsm_stateReg_string = "SETUP_IDLE            ";
      setup_renderer_fsm_CLEAN_SCREEN : setup_renderer_fsm_stateReg_string = "CLEAN_SCREEN          ";
      setup_renderer_fsm_DRAW_OPENING_TEXT : setup_renderer_fsm_stateReg_string = "DRAW_OPENING_TEXT     ";
      setup_renderer_fsm_WAIT_OPENING_TEXT_DONE : setup_renderer_fsm_stateReg_string = "WAIT_OPENING_TEXT_DONE";
      setup_renderer_fsm_WAIT_GAME_START : setup_renderer_fsm_stateReg_string = "WAIT_GAME_START       ";
      setup_renderer_fsm_DRAW_STATIC_TEXT : setup_renderer_fsm_stateReg_string = "DRAW_STATIC_TEXT      ";
      setup_renderer_fsm_WAIT_STATIC_TEXT_DONE : setup_renderer_fsm_stateReg_string = "WAIT_STATIC_TEXT_DONE ";
      setup_renderer_fsm_DRAW_WALL : setup_renderer_fsm_stateReg_string = "DRAW_WALL             ";
      setup_renderer_fsm_WAIT_WALL_DONE : setup_renderer_fsm_stateReg_string = "WAIT_WALL_DONE        ";
      setup_renderer_fsm_RUNNING : setup_renderer_fsm_stateReg_string = "RUNNING               ";
      setup_renderer_fsm_WAIT_RUNTIME_IDLE : setup_renderer_fsm_stateReg_string = "WAIT_RUNTIME_IDLE     ";
      default : setup_renderer_fsm_stateReg_string = "??????????????????????";
    endcase
  end
  always @(*) begin
    case(setup_renderer_fsm_stateNext)
      setup_renderer_fsm_SETUP_IDLE : setup_renderer_fsm_stateNext_string = "SETUP_IDLE            ";
      setup_renderer_fsm_CLEAN_SCREEN : setup_renderer_fsm_stateNext_string = "CLEAN_SCREEN          ";
      setup_renderer_fsm_DRAW_OPENING_TEXT : setup_renderer_fsm_stateNext_string = "DRAW_OPENING_TEXT     ";
      setup_renderer_fsm_WAIT_OPENING_TEXT_DONE : setup_renderer_fsm_stateNext_string = "WAIT_OPENING_TEXT_DONE";
      setup_renderer_fsm_WAIT_GAME_START : setup_renderer_fsm_stateNext_string = "WAIT_GAME_START       ";
      setup_renderer_fsm_DRAW_STATIC_TEXT : setup_renderer_fsm_stateNext_string = "DRAW_STATIC_TEXT      ";
      setup_renderer_fsm_WAIT_STATIC_TEXT_DONE : setup_renderer_fsm_stateNext_string = "WAIT_STATIC_TEXT_DONE ";
      setup_renderer_fsm_DRAW_WALL : setup_renderer_fsm_stateNext_string = "DRAW_WALL             ";
      setup_renderer_fsm_WAIT_WALL_DONE : setup_renderer_fsm_stateNext_string = "WAIT_WALL_DONE        ";
      setup_renderer_fsm_RUNNING : setup_renderer_fsm_stateNext_string = "RUNNING               ";
      setup_renderer_fsm_WAIT_RUNTIME_IDLE : setup_renderer_fsm_stateNext_string = "WAIT_RUNTIME_IDLE     ";
      default : setup_renderer_fsm_stateNext_string = "??????????????????????";
    endcase
  end
  `endif

  always @(*) begin
    screen_is_ready = 1'b0;
    runtimeRenderEnable = 1'b0;
    clearPendingPlayfieldRender = 1'b0;
    text_rom_charCounter_willIncrement = 1'b0;
    text_rom_charCounter_willClear = 1'b0;
    text_rom_charCounter_willLoad = 1'b0;
    text_rom_charCounter_valueNext = (text_rom_charCounter_value + temp_text_rom_charCounter_valueNext);
    if(text_rom_charCounter_willOverflow) begin
      text_rom_charCounter_valueNext = 4'b0000;
    end
    if(text_rom_charCounter_willClear) begin
      text_rom_charCounter_valueNext = 4'b0000;
    end
    wall_rom_wallCounter_willIncrement = 1'b0;
    wall_rom_wallCounter_willClear = 1'b0;
    setup_renderer_charCommand_start = 1'b0;
    setup_renderer_charCommand_x_orig = 9'h0;
    setup_renderer_charCommand_y_orig = 8'h0;
    setup_renderer_charCommand_word = 7'h0;
    setup_renderer_charCommand_scale = 3'b000;
    setup_renderer_charCommand_color = 4'b0000;
    setup_renderer_blockCommand_start = 1'b0;
    setup_renderer_blockCommand_x_orig = 9'h0;
    setup_renderer_blockCommand_y_orig = 8'h0;
    setup_renderer_blockCommand_width = 8'h0;
    setup_renderer_blockCommand_height = 8'h0;
    setup_renderer_blockCommand_in_color = 4'b0000;
    setup_renderer_blockCommand_pat_color = 4'b0000;
    setup_renderer_blockCommand_fill_pattern = 2'b00;
    setup_renderer_fsm_wantStart = 1'b0;
    setup_renderer_fsm_stateNext = setup_renderer_fsm_stateReg;
    case(setup_renderer_fsm_stateReg)
      setup_renderer_fsm_CLEAN_SCREEN : begin
        if(bf_clear_done) begin
          wall_rom_wallCounter_willClear = 1'b1;
          if(setup_renderer_gameIsRunning) begin
            text_rom_charCounter_valueNext = 4'b0110;
            text_rom_charCounter_willLoad = 1'b1;
            setup_renderer_fsm_stateNext = setup_renderer_fsm_DRAW_STATIC_TEXT;
          end else begin
            text_rom_charCounter_willClear = 1'b1;
            setup_renderer_fsm_stateNext = setup_renderer_fsm_DRAW_OPENING_TEXT;
          end
        end
      end
      setup_renderer_fsm_DRAW_OPENING_TEXT : begin
        setup_renderer_charCommand_start = 1'b1;
        setup_renderer_charCommand_x_orig = setup_renderer_textX;
        setup_renderer_charCommand_y_orig = setup_renderer_textY;
        setup_renderer_charCommand_scale = setup_renderer_textScale;
        setup_renderer_charCommand_color = setup_renderer_textColor;
        setup_renderer_charCommand_word = text_rom_word;
        setup_renderer_fsm_stateNext = setup_renderer_fsm_WAIT_OPENING_TEXT_DONE;
      end
      setup_renderer_fsm_WAIT_OPENING_TEXT_DONE : begin
        if(setupCharDone) begin
          if(temp_when_2) begin
            setup_renderer_fsm_stateNext = setup_renderer_fsm_WAIT_GAME_START;
          end else begin
            text_rom_charCounter_willIncrement = 1'b1;
            setup_renderer_fsm_stateNext = setup_renderer_fsm_DRAW_OPENING_TEXT;
          end
        end
      end
      setup_renderer_fsm_WAIT_GAME_START : begin
        if(game_start) begin
          setup_renderer_fsm_stateNext = setup_renderer_fsm_CLEAN_SCREEN;
        end
      end
      setup_renderer_fsm_DRAW_STATIC_TEXT : begin
        setup_renderer_charCommand_start = 1'b1;
        setup_renderer_charCommand_x_orig = setup_renderer_textX;
        setup_renderer_charCommand_y_orig = setup_renderer_textY;
        setup_renderer_charCommand_scale = setup_renderer_textScale;
        setup_renderer_charCommand_color = setup_renderer_textColor;
        setup_renderer_charCommand_word = text_rom_word;
        setup_renderer_fsm_stateNext = setup_renderer_fsm_WAIT_STATIC_TEXT_DONE;
      end
      setup_renderer_fsm_WAIT_STATIC_TEXT_DONE : begin
        if(setupCharDone) begin
          if(temp_when_3) begin
            setup_renderer_fsm_stateNext = setup_renderer_fsm_DRAW_WALL;
          end else begin
            text_rom_charCounter_willIncrement = 1'b1;
            setup_renderer_fsm_stateNext = setup_renderer_fsm_DRAW_STATIC_TEXT;
          end
        end
      end
      setup_renderer_fsm_DRAW_WALL : begin
        setup_renderer_blockCommand_start = wall_rom_command_start;
        setup_renderer_blockCommand_x_orig = wall_rom_command_x_orig;
        setup_renderer_blockCommand_y_orig = wall_rom_command_y_orig;
        setup_renderer_blockCommand_width = wall_rom_command_width;
        setup_renderer_blockCommand_height = wall_rom_command_height;
        setup_renderer_blockCommand_in_color = wall_rom_command_in_color;
        setup_renderer_blockCommand_pat_color = wall_rom_command_pat_color;
        setup_renderer_blockCommand_fill_pattern = wall_rom_command_fill_pattern;
        setup_renderer_fsm_stateNext = setup_renderer_fsm_WAIT_WALL_DONE;
      end
      setup_renderer_fsm_WAIT_WALL_DONE : begin
        if(setupBlockDone) begin
          if(wall_rom_wallCounter_willOverflowIfInc) begin
            setup_renderer_fsm_stateNext = setup_renderer_fsm_RUNNING;
          end else begin
            wall_rom_wallCounter_willIncrement = 1'b1;
            setup_renderer_fsm_stateNext = setup_renderer_fsm_DRAW_WALL;
          end
        end
      end
      setup_renderer_fsm_RUNNING : begin
        runtimeRenderEnable = 1'b1;
        screen_is_ready = 1'b1;
        if(game_restart) begin
          clearPendingPlayfieldRender = 1'b1;
          if((runtimeRenderBusy || runtimeRenderStart)) begin
            setup_renderer_fsm_stateNext = setup_renderer_fsm_WAIT_RUNTIME_IDLE;
          end else begin
            setup_renderer_fsm_stateNext = setup_renderer_fsm_CLEAN_SCREEN;
          end
        end
      end
      setup_renderer_fsm_WAIT_RUNTIME_IDLE : begin
        clearPendingPlayfieldRender = 1'b1;
        if((! runtimeRenderBusy)) begin
          setup_renderer_fsm_stateNext = setup_renderer_fsm_CLEAN_SCREEN;
        end
      end
      default : begin
        if(frame_start) begin
          text_rom_charCounter_willClear = 1'b1;
          wall_rom_wallCounter_willClear = 1'b1;
          setup_renderer_fsm_stateNext = setup_renderer_fsm_CLEAN_SCREEN;
        end
        setup_renderer_fsm_wantStart = 1'b1;
      end
    endcase
    if(setup_renderer_fsm_wantKill) begin
      setup_renderer_fsm_stateNext = setup_renderer_fsm_SETUP_IDLE;
    end
  end

  always @(*) begin
    draw_field_done = 1'b0;
    runtimeRenderBusy = 1'b0;
    runtimeRenderStart = 1'b0;
    runtime_renderer_blockCommand_start = 1'b0;
    runtime_renderer_blockCommand_x_orig = 9'h0;
    runtime_renderer_blockCommand_y_orig = 8'h0;
    runtime_renderer_blockCommand_width = 8'h0;
    runtime_renderer_blockCommand_height = 8'h0;
    runtime_renderer_blockCommand_in_color = 4'b0000;
    runtime_renderer_blockCommand_pat_color = 4'b0000;
    runtime_renderer_blockCommand_fill_pattern = 2'b00;
    runtime_renderer_scoreCommand_start = 1'b0;
    runtime_renderer_scoreCommand_x_orig = 9'h0;
    runtime_renderer_scoreCommand_y_orig = 8'h0;
    runtime_renderer_scoreCommand_word = 7'h0;
    runtime_renderer_scoreCommand_scale = 3'b000;
    runtime_renderer_scoreCommand_color = 4'b0000;
    runtime_renderer_readEnable = 1'b0;
    runtime_renderer_rowCounter_willIncrement = 1'b0;
    runtime_renderer_rowCounter_willClear = 1'b0;
    runtime_renderer_colCounter_willIncrement = 1'b0;
    runtime_renderer_colCounter_willClear = 1'b0;
    runtime_renderer_scoreDigitCounter_willIncrement = 1'b0;
    runtime_renderer_scoreDigitCounter_willClear = 1'b0;
    runtime_renderer_fsm_wantStart = 1'b0;
    runtime_renderer_fsm_stateNext = runtime_renderer_fsm_stateReg;
    case(runtime_renderer_fsm_stateReg)
      runtime_renderer_fsm_FETCH_ROW : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_readEnable = 1'b1;
        runtime_renderer_fsm_stateNext = runtime_renderer_fsm_LOAD_ROW;
      end
      runtime_renderer_fsm_LOAD_ROW : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_fsm_stateNext = runtime_renderer_fsm_DRAW_FIELD_BLOCK;
      end
      runtime_renderer_fsm_DRAW_FIELD_BLOCK : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_blockCommand_start = 1'b1;
        runtime_renderer_blockCommand_x_orig = runtime_renderer_fieldX;
        runtime_renderer_blockCommand_y_orig = runtime_renderer_fieldY;
        runtime_renderer_blockCommand_width = 8'h07;
        runtime_renderer_blockCommand_height = 8'h07;
        runtime_renderer_blockCommand_in_color = runtime_renderer_fieldColor;
        runtime_renderer_blockCommand_pat_color = 4'b0010;
        runtime_renderer_blockCommand_fill_pattern = 2'b00;
        runtime_renderer_fsm_stateNext = runtime_renderer_fsm_WAIT_FIELD_BLOCK_DONE;
      end
      runtime_renderer_fsm_WAIT_FIELD_BLOCK_DONE : begin
        runtimeRenderBusy = 1'b1;
        if(runtimeFieldBlockDone) begin
          if(temp_when) begin
            runtime_renderer_scoreDigitCounter_willClear = 1'b1;
            runtime_renderer_fsm_stateNext = runtime_renderer_fsm_DRAW_SCORE_DIGIT;
          end else begin
            if(runtime_renderer_colCounter_willOverflowIfInc) begin
              runtime_renderer_colCounter_willClear = 1'b1;
              runtime_renderer_rowCounter_willIncrement = 1'b1;
              runtime_renderer_fsm_stateNext = runtime_renderer_fsm_FETCH_ROW;
            end else begin
              runtime_renderer_colCounter_willIncrement = 1'b1;
              runtime_renderer_fsm_stateNext = runtime_renderer_fsm_DRAW_FIELD_BLOCK;
            end
          end
        end
      end
      runtime_renderer_fsm_DRAW_SCORE_DIGIT : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_scoreCommand_start = 1'b1;
        runtime_renderer_scoreCommand_x_orig = runtime_renderer_scoreX;
        runtime_renderer_scoreCommand_y_orig = 8'h50;
        runtime_renderer_scoreCommand_scale = 3'b000;
        runtime_renderer_scoreCommand_color = 4'b0110;
        runtime_renderer_scoreCommand_word = {3'b011,temp_runtime_renderer_scoreCommand_word};
        runtime_renderer_fsm_stateNext = runtime_renderer_fsm_WAIT_SCORE_DIGIT_DONE;
      end
      runtime_renderer_fsm_WAIT_SCORE_DIGIT_DONE : begin
        runtimeRenderBusy = 1'b1;
        if(runtimeScoreCharDone) begin
          if(runtime_renderer_scoreDigitCounter_willOverflowIfInc) begin
            runtime_renderer_fsm_stateNext = runtime_renderer_fsm_COMPLETE;
          end else begin
            runtime_renderer_scoreDigitCounter_willIncrement = 1'b1;
            runtime_renderer_fsm_stateNext = runtime_renderer_fsm_DRAW_SCORE_DIGIT;
          end
        end
      end
      runtime_renderer_fsm_COMPLETE : begin
        draw_field_done = 1'b1;
        runtime_renderer_fsm_stateNext = runtime_renderer_fsm_IDLE;
      end
      default : begin
        if(temp_when_1) begin
          runtimeRenderStart = 1'b1;
          runtime_renderer_rowCounter_willClear = 1'b1;
          runtime_renderer_colCounter_willClear = 1'b1;
          runtime_renderer_scoreDigitCounter_willClear = 1'b1;
          runtime_renderer_fsm_stateNext = runtime_renderer_fsm_FETCH_ROW;
        end
        runtime_renderer_fsm_wantStart = 1'b1;
      end
    endcase
    if(runtime_renderer_fsm_wantKill) begin
      runtime_renderer_fsm_stateNext = runtime_renderer_fsm_IDLE;
    end
  end

  always @(*) begin
    bf_clear_start = 1'b0;
    if(setup_renderer_fsm_onEntry_CLEAN_SCREEN) begin
      bf_clear_start = 1'b1;
    end
  end

  assign score_cache_digits_0 = score_cache_scoreReg[15 : 12];
  assign score_cache_digits_1 = score_cache_scoreReg[11 : 8];
  assign score_cache_digits_2 = score_cache_scoreReg[7 : 4];
  assign score_cache_digits_3 = score_cache_scoreReg[3 : 0];
  assign text_rom_charCounter_willDecrement = 1'b0;
  assign text_rom_charCounter_willOverflowIfInc = (text_rom_charCounter_value == 4'b1010);
  assign text_rom_charCounter_willUnderflowIfDec = (text_rom_charCounter_value == 4'b0000);
  assign text_rom_charCounter_willOverflow = (text_rom_charCounter_willOverflowIfInc && text_rom_charCounter_willIncrement);
  assign text_rom_charCounter_willUnderflow = (text_rom_charCounter_willUnderflowIfDec && text_rom_charCounter_willDecrement);
  assign text_rom_word = text_rom_rom_spinal_port0;
  assign wall_rom_wallCounter_willDecrement = 1'b0;
  assign wall_rom_wallCounter_willLoad = 1'b0;
  assign wall_rom_wallCounter_willOverflowIfInc = (wall_rom_wallCounter_value == 2'b11);
  assign wall_rom_wallCounter_willUnderflowIfDec = (wall_rom_wallCounter_value == 2'b00);
  assign wall_rom_wallCounter_willOverflow = (wall_rom_wallCounter_willOverflowIfInc && wall_rom_wallCounter_willIncrement);
  always @(*) begin
    wall_rom_wallCounter_valueNext = (wall_rom_wallCounter_value + temp_wall_rom_wallCounter_valueNext);
    if(wall_rom_wallCounter_willClear) begin
      wall_rom_wallCounter_valueNext = 2'b00;
    end
  end

  assign wall_rom_wallCounter_willUnderflow = (wall_rom_wallCounter_willUnderflowIfDec && wall_rom_wallCounter_willDecrement);
  assign wall_rom_command_start = 1'b1;
  assign wall_rom_blockInfo = wall_rom_wallMem_spinal_port0;
  assign wall_rom_command_x_orig = wall_rom_blockInfo[8 : 0];
  assign wall_rom_command_y_orig = wall_rom_blockInfo[16 : 9];
  assign wall_rom_command_width = wall_rom_blockInfo[24 : 17];
  assign wall_rom_command_height = wall_rom_blockInfo[32 : 25];
  assign wall_rom_command_in_color = wall_rom_blockInfo[36 : 33];
  assign wall_rom_command_pat_color = wall_rom_blockInfo[40 : 37];
  assign wall_rom_command_fill_pattern = wall_rom_blockInfo[42 : 41];
  always @(*) begin
    playfield_storage_writeRowCounter_willIncrement = 1'b0;
    if(row_val_valid) begin
      playfield_storage_writeRowCounter_willIncrement = 1'b1;
    end
  end

  assign playfield_storage_writeRowCounter_willDecrement = 1'b0;
  assign playfield_storage_writeRowCounter_willClear = 1'b0;
  assign playfield_storage_writeRowCounter_willLoad = 1'b0;
  assign playfield_storage_writeRowCounter_willOverflowIfInc = (playfield_storage_writeRowCounter_value == 5'h15);
  assign playfield_storage_writeRowCounter_willUnderflowIfDec = (playfield_storage_writeRowCounter_value == 5'h0);
  assign playfield_storage_writeRowCounter_willOverflow = (playfield_storage_writeRowCounter_willOverflowIfInc && playfield_storage_writeRowCounter_willIncrement);
  always @(*) begin
    playfield_storage_writeRowCounter_valueNext = (playfield_storage_writeRowCounter_value + temp_playfield_storage_writeRowCounter_valueNext);
    if(playfield_storage_writeRowCounter_willOverflow) begin
      playfield_storage_writeRowCounter_valueNext = 5'h0;
    end
    if(playfield_storage_writeRowCounter_willClear) begin
      playfield_storage_writeRowCounter_valueNext = 5'h0;
    end
  end

  assign playfield_storage_writeRowCounter_willUnderflow = (playfield_storage_writeRowCounter_willUnderflowIfDec && playfield_storage_writeRowCounter_willDecrement);
  assign playfield_storage_rowBurstComplete = ((! row_val_valid) && row_val_valid_regNext);
  assign runtime_renderer_rowCounter_willDecrement = 1'b0;
  assign runtime_renderer_rowCounter_willLoad = 1'b0;
  assign runtime_renderer_rowCounter_willOverflowIfInc = (runtime_renderer_rowCounter_value == 5'h15);
  assign runtime_renderer_rowCounter_willUnderflowIfDec = (runtime_renderer_rowCounter_value == 5'h0);
  assign runtime_renderer_rowCounter_willOverflow = (runtime_renderer_rowCounter_willOverflowIfInc && runtime_renderer_rowCounter_willIncrement);
  always @(*) begin
    runtime_renderer_rowCounter_valueNext = (runtime_renderer_rowCounter_value + temp_runtime_renderer_rowCounter_valueNext);
    if(runtime_renderer_rowCounter_willOverflow) begin
      runtime_renderer_rowCounter_valueNext = 5'h0;
    end
    if(runtime_renderer_rowCounter_willClear) begin
      runtime_renderer_rowCounter_valueNext = 5'h0;
    end
  end

  assign runtime_renderer_rowCounter_willUnderflow = (runtime_renderer_rowCounter_willUnderflowIfDec && runtime_renderer_rowCounter_willDecrement);
  assign runtime_renderer_colCounter_willDecrement = 1'b0;
  assign runtime_renderer_colCounter_willLoad = 1'b0;
  assign runtime_renderer_colCounter_willOverflowIfInc = (runtime_renderer_colCounter_value == 4'b1001);
  assign runtime_renderer_colCounter_willUnderflowIfDec = (runtime_renderer_colCounter_value == 4'b0000);
  assign runtime_renderer_colCounter_willOverflow = (runtime_renderer_colCounter_willOverflowIfInc && runtime_renderer_colCounter_willIncrement);
  always @(*) begin
    runtime_renderer_colCounter_valueNext = (runtime_renderer_colCounter_value + temp_runtime_renderer_colCounter_valueNext);
    if(runtime_renderer_colCounter_willOverflow) begin
      runtime_renderer_colCounter_valueNext = 4'b0000;
    end
    if(runtime_renderer_colCounter_willClear) begin
      runtime_renderer_colCounter_valueNext = 4'b0000;
    end
  end

  assign runtime_renderer_colCounter_willUnderflow = (runtime_renderer_colCounter_willUnderflowIfDec && runtime_renderer_colCounter_willDecrement);
  assign runtime_renderer_scoreDigitCounter_willDecrement = 1'b0;
  assign runtime_renderer_scoreDigitCounter_willLoad = 1'b0;
  assign runtime_renderer_scoreDigitCounter_willOverflowIfInc = (runtime_renderer_scoreDigitCounter_value == 2'b11);
  assign runtime_renderer_scoreDigitCounter_willUnderflowIfDec = (runtime_renderer_scoreDigitCounter_value == 2'b00);
  assign runtime_renderer_scoreDigitCounter_willOverflow = (runtime_renderer_scoreDigitCounter_willOverflowIfInc && runtime_renderer_scoreDigitCounter_willIncrement);
  always @(*) begin
    runtime_renderer_scoreDigitCounter_valueNext = (runtime_renderer_scoreDigitCounter_value + temp_runtime_renderer_scoreDigitCounter_valueNext);
    if(runtime_renderer_scoreDigitCounter_willClear) begin
      runtime_renderer_scoreDigitCounter_valueNext = 2'b00;
    end
  end

  assign runtime_renderer_scoreDigitCounter_willUnderflow = (runtime_renderer_scoreDigitCounter_willUnderflowIfDec && runtime_renderer_scoreDigitCounter_willDecrement);
  assign runtime_renderer_rowValue = playfield_storage_memory_spinal_port1;
  always @(*) begin
    runtime_renderer_fieldColor = 4'b0010;
    if(runtime_renderer_rowBits[9]) begin
      runtime_renderer_fieldColor = 4'b1001;
    end
  end

  assign runtime_renderer_fsm_wantExit = 1'b0;
  assign runtime_renderer_fsm_wantKill = 1'b0;
  assign setup_renderer_fsm_wantExit = 1'b0;
  assign setup_renderer_fsm_wantKill = 1'b0;
  always @(*) begin
    selectedCharCommand_start = 1'b0;
    selectedCharCommand_x_orig = 9'h0;
    selectedCharCommand_y_orig = 8'h0;
    selectedCharCommand_word = 7'h0;
    selectedCharCommand_scale = 3'b000;
    selectedCharCommand_color = 4'b0000;
    if(setup_renderer_charCommand_start) begin
      selectedCharCommand_start = setup_renderer_charCommand_start;
      selectedCharCommand_x_orig = setup_renderer_charCommand_x_orig;
      selectedCharCommand_y_orig = setup_renderer_charCommand_y_orig;
      selectedCharCommand_word = setup_renderer_charCommand_word;
      selectedCharCommand_scale = setup_renderer_charCommand_scale;
      selectedCharCommand_color = setup_renderer_charCommand_color;
    end else begin
      if(runtime_renderer_scoreCommand_start) begin
        selectedCharCommand_start = runtime_renderer_scoreCommand_start;
        selectedCharCommand_x_orig = runtime_renderer_scoreCommand_x_orig;
        selectedCharCommand_y_orig = runtime_renderer_scoreCommand_y_orig;
        selectedCharCommand_word = runtime_renderer_scoreCommand_word;
        selectedCharCommand_scale = runtime_renderer_scoreCommand_scale;
        selectedCharCommand_color = runtime_renderer_scoreCommand_color;
      end
    end
  end

  always @(*) begin
    selectedBlockCommand_start = 1'b0;
    selectedBlockCommand_x_orig = 9'h0;
    selectedBlockCommand_y_orig = 8'h0;
    selectedBlockCommand_width = 8'h0;
    selectedBlockCommand_height = 8'h0;
    selectedBlockCommand_in_color = 4'b0000;
    selectedBlockCommand_pat_color = 4'b0000;
    selectedBlockCommand_fill_pattern = 2'b00;
    if(setup_renderer_blockCommand_start) begin
      selectedBlockCommand_start = setup_renderer_blockCommand_start;
      selectedBlockCommand_x_orig = setup_renderer_blockCommand_x_orig;
      selectedBlockCommand_y_orig = setup_renderer_blockCommand_y_orig;
      selectedBlockCommand_width = setup_renderer_blockCommand_width;
      selectedBlockCommand_height = setup_renderer_blockCommand_height;
      selectedBlockCommand_in_color = setup_renderer_blockCommand_in_color;
      selectedBlockCommand_pat_color = setup_renderer_blockCommand_pat_color;
      selectedBlockCommand_fill_pattern = setup_renderer_blockCommand_fill_pattern;
    end else begin
      if(runtime_renderer_blockCommand_start) begin
        selectedBlockCommand_start = runtime_renderer_blockCommand_start;
        selectedBlockCommand_x_orig = runtime_renderer_blockCommand_x_orig;
        selectedBlockCommand_y_orig = runtime_renderer_blockCommand_y_orig;
        selectedBlockCommand_width = runtime_renderer_blockCommand_width;
        selectedBlockCommand_height = runtime_renderer_blockCommand_height;
        selectedBlockCommand_in_color = runtime_renderer_blockCommand_in_color;
        selectedBlockCommand_pat_color = runtime_renderer_blockCommand_pat_color;
        selectedBlockCommand_fill_pattern = runtime_renderer_blockCommand_fill_pattern;
      end
    end
  end

  assign charStartCollision = (setup_renderer_charCommand_start && runtime_renderer_scoreCommand_start);
  assign blockStartCollision = (setup_renderer_blockCommand_start && runtime_renderer_blockCommand_start);
  assign drawStartCollision = ((setup_renderer_charCommand_start && (setup_renderer_blockCommand_start || runtime_renderer_blockCommand_start)) || (runtime_renderer_scoreCommand_start && (setup_renderer_blockCommand_start || runtime_renderer_blockCommand_start)));
  assign setupCharDone = (draw_char_done && charOwnerIsSetup);
  assign runtimeScoreCharDone = (draw_char_done && (! charOwnerIsSetup));
  assign setupBlockDone = (draw_block_done && blockOwnerIsSetup);
  assign runtimeFieldBlockDone = (draw_block_done && (! blockOwnerIsSetup));
  assign draw_char_start = selectedCharCommand_start;
  assign draw_char_word = selectedCharCommand_word;
  assign draw_char_scale = selectedCharCommand_scale;
  assign draw_char_color = selectedCharCommand_color;
  assign draw_block_start = selectedBlockCommand_start;
  assign draw_block_width = selectedBlockCommand_width;
  assign draw_block_height = selectedBlockCommand_height;
  assign draw_block_in_color = selectedBlockCommand_in_color;
  assign draw_block_pat_color = selectedBlockCommand_pat_color;
  assign draw_block_fill_pattern = selectedBlockCommand_fill_pattern;
  always @(*) begin
    draw_x_orig = 9'h0;
    draw_y_orig = 8'h0;
    if(selectedCharCommand_start) begin
      draw_x_orig = selectedCharCommand_x_orig;
      draw_y_orig = selectedCharCommand_y_orig;
    end else begin
      if(selectedBlockCommand_start) begin
        draw_x_orig = selectedBlockCommand_x_orig;
        draw_y_orig = selectedBlockCommand_y_orig;
      end
    end
  end

  assign setup_renderer_fsm_onEntry_CLEAN_SCREEN = ((setup_renderer_fsm_stateNext == setup_renderer_fsm_CLEAN_SCREEN) && (setup_renderer_fsm_stateReg != setup_renderer_fsm_CLEAN_SCREEN));
  assign setup_renderer_fsmDebug = setup_renderer_fsm_stateReg;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      score_cache_scoreReg <= 16'h0;
      text_rom_charCounter_value <= 4'b0000;
      wall_rom_wallCounter_value <= 2'b00;
      pendingPlayfieldRender <= 1'b0;
      playfield_storage_writeRowCounter_value <= 5'h0;
      row_val_valid_regNext <= 1'b0;
      runtime_renderer_rowCounter_value <= 5'h0;
      runtime_renderer_colCounter_value <= 4'b0000;
      runtime_renderer_scoreDigitCounter_value <= 2'b00;
      runtime_renderer_rowBits <= 10'h0;
      runtime_renderer_fieldX <= 9'h0;
      runtime_renderer_fieldY <= 8'h0;
      runtime_renderer_scoreX <= 9'h0;
      setup_renderer_textX <= 9'h0;
      setup_renderer_textY <= 8'h0;
      setup_renderer_textScale <= 3'b000;
      setup_renderer_textColor <= 4'b0000;
      setup_renderer_gameIsRunning <= 1'b0;
      charOwnerIsSetup <= 1'b0;
      blockOwnerIsSetup <= 1'b0;
      runtime_renderer_fsm_stateReg <= runtime_renderer_fsm_IDLE;
      setup_renderer_fsm_stateReg <= setup_renderer_fsm_SETUP_IDLE;
    end else begin
      if(score_cache_bcdInst_data_out_dec_valid) begin
        score_cache_scoreReg <= score_cache_bcdInst_data_out_dec_payload;
      end
      text_rom_charCounter_value <= text_rom_charCounter_valueNext;
      wall_rom_wallCounter_value <= wall_rom_wallCounter_valueNext;
      playfield_storage_writeRowCounter_value <= playfield_storage_writeRowCounter_valueNext;
      row_val_valid_regNext <= row_val_valid;
      if(clearPendingPlayfieldRender) begin
        pendingPlayfieldRender <= 1'b0;
      end else begin
        if(playfield_storage_rowBurstComplete) begin
          pendingPlayfieldRender <= 1'b1;
        end else begin
          if(runtimeRenderStart) begin
            pendingPlayfieldRender <= 1'b0;
          end
        end
      end
      runtime_renderer_rowCounter_value <= runtime_renderer_rowCounter_valueNext;
      runtime_renderer_colCounter_value <= runtime_renderer_colCounter_valueNext;
      runtime_renderer_scoreDigitCounter_value <= runtime_renderer_scoreDigitCounter_valueNext;
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! charStartCollision)); // display_controller.scala:L656
        `else
          if(!(! charStartCollision)) begin
            $display("FAILURE display_controller: setup and runtime score char commands must not start together"); // display_controller.scala:L656
            $finish;
          end
        `endif
      `endif
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! blockStartCollision)); // display_controller.scala:L657
        `else
          if(!(! blockStartCollision)) begin
            $display("FAILURE display_controller: setup and runtime block commands must not start together"); // display_controller.scala:L657
            $finish;
          end
        `endif
      `endif
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! drawStartCollision)); // display_controller.scala:L658
        `else
          if(!(! drawStartCollision)) begin
            $display("FAILURE display_controller: char and block engines must not receive start in the same cycle"); // display_controller.scala:L658
            $finish;
          end
        `endif
      `endif
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! (draw_char_done && draw_char_start))); // display_controller.scala:L660
        `else
          if(!(! (draw_char_done && draw_char_start))) begin
            $display("FAILURE draw_char: done and start must not coincide"); // display_controller.scala:L660
            $finish;
          end
        `endif
      `endif
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! (playfield_storage_rowBurstComplete && (playfield_storage_writeRowCounter_value != 5'h0)))); // display_controller.scala:L666
        `else
          if(!(! (playfield_storage_rowBurstComplete && (playfield_storage_writeRowCounter_value != 5'h0)))) begin
            $display("FAILURE row_val: burst ended before rowBlocksNum rows were received"); // display_controller.scala:L666
            $finish;
          end
        `endif
      `endif
      if(selectedCharCommand_start) begin
        charOwnerIsSetup <= setup_renderer_charCommand_start;
      end
      if(selectedBlockCommand_start) begin
        blockOwnerIsSetup <= setup_renderer_blockCommand_start;
      end
      runtime_renderer_fsm_stateReg <= runtime_renderer_fsm_stateNext;
      case(runtime_renderer_fsm_stateReg)
        runtime_renderer_fsm_FETCH_ROW : begin
        end
        runtime_renderer_fsm_LOAD_ROW : begin
          runtime_renderer_rowBits <= runtime_renderer_rowValue;
        end
        runtime_renderer_fsm_DRAW_FIELD_BLOCK : begin
        end
        runtime_renderer_fsm_WAIT_FIELD_BLOCK_DONE : begin
          if(runtimeFieldBlockDone) begin
            if(temp_when) begin
              runtime_renderer_scoreX <= 9'h0d6;
            end else begin
              if(runtime_renderer_colCounter_willOverflowIfInc) begin
                runtime_renderer_fieldX <= 9'h02b;
                runtime_renderer_fieldY <= (runtime_renderer_fieldY + 8'h09);
              end else begin
                runtime_renderer_rowBits <= (runtime_renderer_rowBits <<< 1);
                runtime_renderer_fieldX <= (runtime_renderer_fieldX + 9'h009);
              end
            end
          end
        end
        runtime_renderer_fsm_DRAW_SCORE_DIGIT : begin
        end
        runtime_renderer_fsm_WAIT_SCORE_DIGIT_DONE : begin
          if(runtimeScoreCharDone) begin
            if(!runtime_renderer_scoreDigitCounter_willOverflowIfInc) begin
              runtime_renderer_scoreX <= (runtime_renderer_scoreX + 9'h00c);
            end
          end
        end
        runtime_renderer_fsm_COMPLETE : begin
        end
        default : begin
          if(temp_when_1) begin
            runtime_renderer_fieldX <= 9'h02b;
            runtime_renderer_fieldY <= 8'h14;
          end
        end
      endcase
      setup_renderer_fsm_stateReg <= setup_renderer_fsm_stateNext;
      case(setup_renderer_fsm_stateReg)
        setup_renderer_fsm_CLEAN_SCREEN : begin
          if(bf_clear_done) begin
            if(setup_renderer_gameIsRunning) begin
              setup_renderer_textX <= 9'h0d2;
              setup_renderer_textY <= 8'h17;
              setup_renderer_textScale <= 3'b000;
              setup_renderer_textColor <= 4'b0110;
            end else begin
              setup_renderer_textX <= 9'h018;
              setup_renderer_textY <= 8'h42;
              setup_renderer_textScale <= 3'b010;
              setup_renderer_textColor <= 4'b0110;
            end
          end
        end
        setup_renderer_fsm_DRAW_OPENING_TEXT : begin
        end
        setup_renderer_fsm_WAIT_OPENING_TEXT_DONE : begin
          if(setupCharDone) begin
            if(!temp_when_2) begin
              setup_renderer_textX <= (setup_renderer_textX + 9'h02e);
            end
          end
        end
        setup_renderer_fsm_WAIT_GAME_START : begin
          if(game_start) begin
            setup_renderer_gameIsRunning <= 1'b1;
          end
        end
        setup_renderer_fsm_DRAW_STATIC_TEXT : begin
        end
        setup_renderer_fsm_WAIT_STATIC_TEXT_DONE : begin
          if(setupCharDone) begin
            if(!temp_when_3) begin
              setup_renderer_textX <= (setup_renderer_textX + 9'h00c);
            end
          end
        end
        setup_renderer_fsm_DRAW_WALL : begin
        end
        setup_renderer_fsm_WAIT_WALL_DONE : begin
        end
        setup_renderer_fsm_RUNNING : begin
        end
        setup_renderer_fsm_WAIT_RUNTIME_IDLE : begin
        end
        default : begin
        end
      endcase
    end
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
  reg        [3:0]    pat_color_1;
  reg                 addr_comp_active;
  reg                 h_cnt_willIncrement;
  wire                h_cnt_willClear;
  reg        [7:0]    h_cnt_valueNext;
  reg        [7:0]    h_cnt_value;
  wire                h_cnt_willOverflowIfInc;
  wire                h_cnt_willOverflow;
  reg                 h_cnt_isDone;
  reg                 v_cnt_willIncrement;
  wire                v_cnt_willClear;
  reg        [7:0]    v_cnt_valueNext;
  reg        [7:0]    v_cnt_value;
  wire                v_cnt_willOverflowIfInc;
  wire                v_cnt_willOverflow;
  reg                 v_cnt_isDone;
  wire                cnt_last;
  reg                 active_1d;
  reg                 border_en;
  reg                 fill_en;
  reg                 no_pattern;
  reg        [3:0]    in_color_1d;
  reg        [3:0]    pat_color_1d;
  reg                 active_2d;
  reg        [3:0]    out_color_1;

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
    if(start) begin
      pat_color_1 <= pat_color;
    end
    if(1'b0) begin
      h_cnt_isDone <= h_cnt_willOverflow;
    end
    if(1'b0) begin
      v_cnt_isDone <= v_cnt_willOverflow;
    end
    in_color_1d <= in_color_1;
    pat_color_1d <= pat_color_1;
    if(((border_en || fill_en) && (! no_pattern))) begin
      out_color_1 <= pat_color_1d;
    end else begin
      out_color_1 <= in_color_1d;
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
  reg        [2:0]    scale_reg;
  reg        [3:0]    color_reg;
  reg                 rom_rd_en;
  reg                 x_scale_cnt_willIncrement;
  wire                x_scale_cnt_willClear;
  reg        [2:0]    x_scale_cnt_valueNext;
  reg        [2:0]    x_scale_cnt_value;
  wire                x_scale_cnt_willOverflowIfInc;
  wire                x_scale_cnt_willOverflow;
  reg                 x_scale_cnt_isDone;
  reg                 x_cnt_willIncrement;
  wire                x_cnt_willDecrement;
  wire                x_cnt_willClear;
  wire                x_cnt_willLoad;
  reg        [2:0]    x_cnt_valueNext;
  reg        [2:0]    x_cnt_value;
  wire                x_cnt_willOverflowIfInc;
  wire                x_cnt_willUnderflowIfDec;
  wire                x_cnt_willOverflow;
  wire                x_cnt_willUnderflow;
  wire                x_last_cycle;
  reg                 y_scale_cnt_willIncrement;
  wire                y_scale_cnt_willClear;
  reg        [2:0]    y_scale_cnt_valueNext;
  reg        [2:0]    y_scale_cnt_value;
  wire                y_scale_cnt_willOverflowIfInc;
  wire                y_scale_cnt_willOverflow;
  reg                 y_scale_cnt_isDone;
  reg                 y_cnt_willIncrement;
  wire                y_cnt_willDecrement;
  wire                y_cnt_willClear;
  wire                y_cnt_willLoad;
  reg        [3:0]    y_cnt_valueNext;
  reg        [3:0]    y_cnt_value;
  wire                y_cnt_willOverflowIfInc;
  wire                y_cnt_willUnderflowIfDec;
  wire                y_cnt_willOverflow;
  wire                y_cnt_willUnderflow;
  wire                y_last_cycle;
  wire                cnt_last;
  reg        [8:0]    h_cnt_1;
  reg        [7:0]    v_cnt_1;
  reg        [3:0]    char_color;
  reg        [2:0]    pix_idx;
  reg        [3:0]    color_reg_delay_1;
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
  assign x_scale_cnt_willOverflowIfInc = (x_scale_cnt_value == scale_reg);
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

  assign x_cnt_willDecrement = 1'b0;
  assign x_cnt_willClear = 1'b0;
  assign x_cnt_willLoad = 1'b0;
  assign x_cnt_willOverflowIfInc = (x_cnt_value == 3'b111);
  assign x_cnt_willUnderflowIfDec = (x_cnt_value == 3'b000);
  assign x_cnt_willOverflow = (x_cnt_willOverflowIfInc && x_cnt_willIncrement);
  always @(*) begin
    x_cnt_valueNext = (x_cnt_value + temp_x_cnt_valueNext);
    if(x_cnt_willClear) begin
      x_cnt_valueNext = 3'b000;
    end
  end

  assign x_cnt_willUnderflow = (x_cnt_willUnderflowIfDec && x_cnt_willDecrement);
  assign x_last_cycle = (x_cnt_willOverflow && x_scale_cnt_willOverflow);
  always @(*) begin
    y_scale_cnt_willIncrement = 1'b0;
    if(x_last_cycle) begin
      y_scale_cnt_willIncrement = 1'b1;
    end
  end

  assign y_scale_cnt_willClear = 1'b0;
  assign y_scale_cnt_willOverflowIfInc = (y_scale_cnt_value == scale_reg);
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

  assign y_cnt_willDecrement = 1'b0;
  assign y_cnt_willClear = 1'b0;
  assign y_cnt_willLoad = 1'b0;
  assign y_cnt_willOverflowIfInc = (y_cnt_value == 4'b1111);
  assign y_cnt_willUnderflowIfDec = (y_cnt_value == 4'b0000);
  assign y_cnt_willOverflow = (y_cnt_willOverflowIfInc && y_cnt_willIncrement);
  always @(*) begin
    y_cnt_valueNext = (y_cnt_value + temp_y_cnt_valueNext);
    if(y_cnt_willClear) begin
      y_cnt_valueNext = 4'b0000;
    end
  end

  assign y_cnt_willUnderflow = (y_cnt_willUnderflowIfDec && y_cnt_willDecrement);
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
      scale_reg <= 3'b000;
      color_reg <= 4'b0000;
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
      if(start) begin
        scale_reg <= scale;
      end
      if(start) begin
        color_reg <= color;
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
        char_color <= color_reg_delay_1;
      end else begin
        char_color <= 4'b0010;
      end
      rom_rd_en_delay_1 <= rom_rd_en;
      rom_rd_en_delay_2 <= rom_rd_en_delay_1;
    end
  end

  always @(posedge core_clk) begin
    if(1'b0) begin
      x_scale_cnt_isDone <= x_scale_cnt_willOverflow;
    end
    if(1'b0) begin
      y_scale_cnt_isDone <= y_scale_cnt_willOverflow;
    end
    rom_rd_en_regNext <= rom_rd_en;
  end

  always @(posedge core_clk) begin
    color_reg_delay_1 <= color_reg;
  end


endmodule

module Bram2p_4x69120 (
  input  wire          wr_en,
  input  wire [16:0]   wr_addr,
  input  wire [3:0]    wr_data,
  input  wire          rd_en,
  input  wire [16:0]   rd_addr,
  output wire          rd_data_valid,
  output wire [3:0]    rd_data_payload,
  input  wire          clear_start,
  output wire          clear_done,
  input  wire          core_rst,
  input  wire          core_clk
);

  reg        [3:0]    memory_spinal_port1;
  wire       [16:0]   temp_clear_addr_valueNext;
  wire       [0:0]    temp_clear_addr_valueNext_1;
  reg                 clear_start_regNext;
  wire                clear_start_rise;
  reg                 clear_busy;
  reg                 clear_addr_willIncrement;
  wire                clear_addr_willDecrement;
  wire                clear_addr_willClear;
  wire                clear_addr_willLoad;
  reg        [16:0]   clear_addr_valueNext;
  reg        [16:0]   clear_addr_value;
  wire                clear_addr_willOverflowIfInc;
  wire                clear_addr_willUnderflowIfDec;
  wire                clear_addr_willOverflow;
  wire                clear_addr_willUnderflow;
  wire       [16:0]   wr_addr_1;
  wire       [3:0]    wr_data_1;
  wire                wr_en_1;
  reg                 rd_en_regNext;
  wire                external_write_during_clear;
  (* ram_style = "block" *) reg [3:0] memory [0:69119];

  assign temp_clear_addr_valueNext_1 = clear_addr_willIncrement;
  assign temp_clear_addr_valueNext = {16'd0, temp_clear_addr_valueNext_1};
  initial begin
    $readmemb("tetris_top.v_toplevel_tetris_core_inst_game_display_inst_frame_buffer_memory.bin",memory);
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

  WriteWhileClearAssert writeWhileClearAssert_1 (
    .clk (core_clk                   ), //i
    .rst (core_rst                   ), //i
    .vld (external_write_during_clear)  //i
  );
  assign clear_start_rise = (clear_start && (! clear_start_regNext));
  always @(*) begin
    clear_addr_willIncrement = 1'b0;
    if(clear_busy) begin
      clear_addr_willIncrement = 1'b1;
    end
  end

  assign clear_addr_willDecrement = 1'b0;
  assign clear_addr_willClear = 1'b0;
  assign clear_addr_willLoad = 1'b0;
  assign clear_addr_willOverflowIfInc = (clear_addr_value == 17'h10dff);
  assign clear_addr_willUnderflowIfDec = (clear_addr_value == 17'h0);
  assign clear_addr_willOverflow = (clear_addr_willOverflowIfInc && clear_addr_willIncrement);
  always @(*) begin
    clear_addr_valueNext = (clear_addr_value + temp_clear_addr_valueNext);
    if(clear_addr_willOverflow) begin
      clear_addr_valueNext = 17'h0;
    end
    if(clear_addr_willClear) begin
      clear_addr_valueNext = 17'h0;
    end
  end

  assign clear_addr_willUnderflow = (clear_addr_willUnderflowIfDec && clear_addr_willDecrement);
  assign clear_done = clear_addr_willOverflow;
  assign wr_addr_1 = (clear_busy ? clear_addr_value : wr_addr);
  assign wr_data_1 = (clear_busy ? 4'b0010 : wr_data);
  assign wr_en_1 = (clear_busy || wr_en);
  assign rd_data_valid = rd_en_regNext;
  assign rd_data_payload = memory_spinal_port1;
  assign external_write_during_clear = (clear_busy && wr_en);
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      clear_start_regNext <= 1'b0;
      clear_busy <= 1'b0;
      clear_addr_value <= 17'h0;
      rd_en_regNext <= 1'b0;
    end else begin
      clear_start_regNext <= clear_start;
      if(clear_start_rise) begin
        clear_busy <= 1'b1;
      end
      clear_addr_value <= clear_addr_valueNext;
      if(clear_addr_willOverflow) begin
        clear_busy <= 1'b0;
      end
      rd_en_regNext <= rd_en;
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! external_write_during_clear)); // Bram2p.scala:L115
        `else
          if(!(! external_write_during_clear)) begin
            $display("FAILURE Bram2p: external write requested while clear is active"); // Bram2p.scala:L115
            $finish;
          end
        `endif
      `endif
    end
  end


endmodule

module controller (
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  input  wire          drop,
  input  wire          screen_is_ready,
  input  wire          playfield_in_idle,
  input  wire          playfield_allow_action,
  output reg           game_restart,
  output reg           softReset,
  output reg           gen_piece_en,
  input  wire          collision_status_valid,
  input  wire          collision_status_payload,
  output reg           move_out_left,
  output reg           move_out_right,
  output reg           move_out_rotate,
  output reg           move_out_down,
  output reg           lock,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam fsm_1_IDLE = 4'd0;
  localparam fsm_1_GAME_START = 4'd1;
  localparam fsm_1_RANDOM_GEN = 4'd2;
  localparam fsm_1_PLACE = 4'd3;
  localparam fsm_1_END_1 = 4'd4;
  localparam fsm_1_FALLING = 4'd5;
  localparam fsm_1_DOWN = 4'd6;
  localparam fsm_1_DROP = 4'd7;
  localparam fsm_1_WAIT_ALLOW_ACTION = 4'd8;
  localparam fsm_1_MOVE = 4'd9;
  localparam fsm_1_RRE_LOCK = 4'd10;
  localparam fsm_1_LOCK = 4'd11;
  localparam fsm_1_LOCKDOWN = 4'd12;
  localparam fsm_1_CLEAN = 4'd13;
  localparam fsm_1_WAIT_TIME = 4'd14;

  wire       [17:0]   temp_drop_timeout_counter_valueNext;
  wire       [0:0]    temp_drop_timeout_counter_valueNext_1;
  wire       [15:0]   temp_lock_timeout_counter_valueNext;
  wire       [0:0]    temp_lock_timeout_counter_valueNext_1;
  wire       [2:0]    temp_9;
  reg        [2:0]    temp_10;
  wire       [2:0]    temp_11;
  reg        [2:0]    temp_12;
  wire       [2:0]    temp_13;
  wire       [1:0]    temp_14;
  wire       [9:0]    temp_temp_motion_voted_2;
  wire       [9:0]    temp_temp_motion_voted_2_1;
  wire       [4:0]    temp_temp_motion_voted_2_2;
  wire                temp_when;
  reg                 drop_timeout_state;
  reg                 drop_timeout_stateRise;
  wire                drop_timeout_counter_willIncrement;
  wire                drop_timeout_counter_willDecrement;
  reg                 drop_timeout_counter_willClear;
  wire                drop_timeout_counter_willLoad;
  reg        [17:0]   drop_timeout_counter_valueNext;
  reg        [17:0]   drop_timeout_counter_value;
  wire                drop_timeout_counter_willOverflowIfInc;
  wire                drop_timeout_counter_willUnderflowIfDec;
  wire                drop_timeout_counter_willOverflow;
  wire                drop_timeout_counter_willUnderflow;
  reg                 lock_timeout_state;
  reg                 lock_timeout_stateRise;
  wire                lock_timeout_counter_willIncrement;
  wire                lock_timeout_counter_willDecrement;
  reg                 lock_timeout_counter_willClear;
  wire                lock_timeout_counter_willLoad;
  reg        [15:0]   lock_timeout_counter_valueNext;
  reg        [15:0]   lock_timeout_counter_value;
  wire                lock_timeout_counter_willOverflowIfInc;
  wire                lock_timeout_counter_willUnderflowIfDec;
  wire                lock_timeout_counter_willOverflow;
  wire                lock_timeout_counter_willUnderflow;
  reg        [4:0]    motion_request;
  reg                 clear_motion_request;
  wire       [4:0]    priority_1;
  wire       [2:0]    temp_1;
  wire       [2:0]    temp_2;
  wire       [2:0]    temp_3;
  wire       [2:0]    temp_4;
  wire       [2:0]    temp_5;
  wire       [2:0]    temp_6;
  wire       [2:0]    temp_7;
  wire       [2:0]    temp_8;
  wire                drop_1;
  wire                move_down_1;
  wire                move_left_1;
  wire                move_right_1;
  wire                rotate_1;
  reg                 drop_regNext;
  reg                 move_down_regNext;
  reg                 move_left_regNext;
  reg                 move_right_regNext;
  reg                 rotate_regNext;
  wire       [4:0]    temp_motion_voted;
  wire       [9:0]    temp_motion_voted_1;
  wire       [9:0]    temp_motion_voted_2;
  wire       [4:0]    motion_voted;
  reg                 debug_place_new_cnt_willIncrement;
  wire                debug_place_new_cnt_willDecrement;
  wire                debug_place_new_cnt_willClear;
  wire                debug_place_new_cnt_willLoad;
  reg        [0:0]    debug_place_new_cnt_valueNext;
  reg        [0:0]    debug_place_new_cnt_value;
  wire                debug_place_new_cnt_willOverflowIfInc;
  wire                debug_place_new_cnt_willUnderflowIfDec;
  wire                debug_place_new_cnt_willOverflow;
  wire                debug_place_new_cnt_willUnderflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                fsm_onExit_PLACE;
  wire                fsm_onExit_FALLING;
  wire                fsm_onEntry_DOWN;
  wire                fsm_onEntry_DROP;
  wire                fsm_onEntry_LOCK;
  wire                fsm_onEntry_LOCKDOWN;
  `ifndef SYNTHESIS
  reg [135:0] fsm_stateReg_string;
  reg [135:0] fsm_stateNext_string;
  `endif


  assign temp_when = (! collision_status_payload);
  assign temp_drop_timeout_counter_valueNext_1 = drop_timeout_counter_willIncrement;
  assign temp_drop_timeout_counter_valueNext = {17'd0, temp_drop_timeout_counter_valueNext_1};
  assign temp_lock_timeout_counter_valueNext_1 = lock_timeout_counter_willIncrement;
  assign temp_lock_timeout_counter_valueNext = {15'd0, temp_lock_timeout_counter_valueNext_1};
  assign temp_9 = (temp_10 + temp_12);
  assign temp_14 = {priority_1[4],priority_1[3]};
  assign temp_13 = {1'd0, temp_14};
  assign temp_temp_motion_voted_2 = (temp_motion_voted_1 - temp_temp_motion_voted_2_1);
  assign temp_temp_motion_voted_2_2 = priority_1;
  assign temp_temp_motion_voted_2_1 = {5'd0, temp_temp_motion_voted_2_2};
  assign temp_11 = {priority_1[2],{priority_1[1],priority_1[0]}};
  always @(*) begin
    case(temp_11)
      3'b000 : temp_10 = temp_1;
      3'b001 : temp_10 = temp_2;
      3'b010 : temp_10 = temp_3;
      3'b011 : temp_10 = temp_4;
      3'b100 : temp_10 = temp_5;
      3'b101 : temp_10 = temp_6;
      3'b110 : temp_10 = temp_7;
      default : temp_10 = temp_8;
    endcase
  end

  always @(*) begin
    case(temp_13)
      3'b000 : temp_12 = temp_1;
      3'b001 : temp_12 = temp_2;
      3'b010 : temp_12 = temp_3;
      3'b011 : temp_12 = temp_4;
      3'b100 : temp_12 = temp_5;
      3'b101 : temp_12 = temp_6;
      3'b110 : temp_12 = temp_7;
      default : temp_12 = temp_8;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_1_IDLE : fsm_stateReg_string = "IDLE             ";
      fsm_1_GAME_START : fsm_stateReg_string = "GAME_START       ";
      fsm_1_RANDOM_GEN : fsm_stateReg_string = "RANDOM_GEN       ";
      fsm_1_PLACE : fsm_stateReg_string = "PLACE            ";
      fsm_1_END_1 : fsm_stateReg_string = "END_1            ";
      fsm_1_FALLING : fsm_stateReg_string = "FALLING          ";
      fsm_1_DOWN : fsm_stateReg_string = "DOWN             ";
      fsm_1_DROP : fsm_stateReg_string = "DROP             ";
      fsm_1_WAIT_ALLOW_ACTION : fsm_stateReg_string = "WAIT_ALLOW_ACTION";
      fsm_1_MOVE : fsm_stateReg_string = "MOVE             ";
      fsm_1_RRE_LOCK : fsm_stateReg_string = "RRE_LOCK         ";
      fsm_1_LOCK : fsm_stateReg_string = "LOCK             ";
      fsm_1_LOCKDOWN : fsm_stateReg_string = "LOCKDOWN         ";
      fsm_1_CLEAN : fsm_stateReg_string = "CLEAN            ";
      fsm_1_WAIT_TIME : fsm_stateReg_string = "WAIT_TIME        ";
      default : fsm_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_1_IDLE : fsm_stateNext_string = "IDLE             ";
      fsm_1_GAME_START : fsm_stateNext_string = "GAME_START       ";
      fsm_1_RANDOM_GEN : fsm_stateNext_string = "RANDOM_GEN       ";
      fsm_1_PLACE : fsm_stateNext_string = "PLACE            ";
      fsm_1_END_1 : fsm_stateNext_string = "END_1            ";
      fsm_1_FALLING : fsm_stateNext_string = "FALLING          ";
      fsm_1_DOWN : fsm_stateNext_string = "DOWN             ";
      fsm_1_DROP : fsm_stateNext_string = "DROP             ";
      fsm_1_WAIT_ALLOW_ACTION : fsm_stateNext_string = "WAIT_ALLOW_ACTION";
      fsm_1_MOVE : fsm_stateNext_string = "MOVE             ";
      fsm_1_RRE_LOCK : fsm_stateNext_string = "RRE_LOCK         ";
      fsm_1_LOCK : fsm_stateNext_string = "LOCK             ";
      fsm_1_LOCKDOWN : fsm_stateNext_string = "LOCKDOWN         ";
      fsm_1_CLEAN : fsm_stateNext_string = "CLEAN            ";
      fsm_1_WAIT_TIME : fsm_stateNext_string = "WAIT_TIME        ";
      default : fsm_stateNext_string = "?????????????????";
    endcase
  end
  `endif

  always @(*) begin
    drop_timeout_stateRise = 1'b0;
    drop_timeout_counter_willClear = 1'b0;
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_stateRise = (! drop_timeout_state);
    end
    lock_timeout_stateRise = 1'b0;
    lock_timeout_counter_willClear = 1'b0;
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_stateRise = (! lock_timeout_state);
    end
    debug_place_new_cnt_willIncrement = 1'b0;
    fsm_wantStart = 1'b0;
    gen_piece_en = 1'b0;
    move_out_left = 1'b0;
    move_out_right = 1'b0;
    move_out_rotate = 1'b0;
    softReset = 1'b0;
    game_restart = 1'b0;
    lock = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_1_GAME_START : begin
        if(screen_is_ready) begin
          fsm_stateNext = fsm_1_RANDOM_GEN;
        end
      end
      fsm_1_RANDOM_GEN : begin
        gen_piece_en = 1'b1;
        fsm_stateNext = fsm_1_PLACE;
      end
      fsm_1_PLACE : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = fsm_1_END_1;
          end else begin
            fsm_stateNext = fsm_1_FALLING;
          end
        end
      end
      fsm_1_END_1 : begin
        if(game_start) begin
          softReset = 1'b1;
          game_restart = 1'b1;
          fsm_stateNext = fsm_1_GAME_START;
        end
      end
      fsm_1_FALLING : begin
        if((move_down_1 && playfield_allow_action)) begin
          fsm_stateNext = fsm_1_DOWN;
        end
        if((drop_1 && playfield_allow_action)) begin
          fsm_stateNext = fsm_1_DROP;
        end
        if((move_left_1 && playfield_allow_action)) begin
          move_out_left = 1'b1;
          fsm_stateNext = fsm_1_MOVE;
        end
        if((move_right_1 && playfield_allow_action)) begin
          move_out_right = 1'b1;
          fsm_stateNext = fsm_1_MOVE;
        end
        if((rotate_1 && playfield_allow_action)) begin
          move_out_rotate = 1'b1;
          fsm_stateNext = fsm_1_MOVE;
        end
        if(drop_timeout_state) begin
          fsm_stateNext = fsm_1_RRE_LOCK;
        end
      end
      fsm_1_DOWN : begin
        if(collision_status_valid) begin
          if(temp_when) begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
          end
          fsm_stateNext = fsm_1_FALLING;
        end
      end
      fsm_1_DROP : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = fsm_1_LOCKDOWN;
          end else begin
            fsm_stateNext = fsm_1_WAIT_ALLOW_ACTION;
          end
        end
      end
      fsm_1_WAIT_ALLOW_ACTION : begin
        if(playfield_allow_action) begin
          fsm_stateNext = fsm_1_DROP;
        end
      end
      fsm_1_MOVE : begin
        if(collision_status_valid) begin
          fsm_stateNext = fsm_1_FALLING;
        end
      end
      fsm_1_RRE_LOCK : begin
        if(playfield_allow_action) begin
          fsm_stateNext = fsm_1_LOCK;
        end
      end
      fsm_1_LOCK : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = fsm_1_LOCKDOWN;
          end else begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
            fsm_stateNext = fsm_1_FALLING;
          end
        end
      end
      fsm_1_LOCKDOWN : begin
        if(lock_timeout_state) begin
          lock = 1'b1;
          fsm_stateNext = fsm_1_CLEAN;
        end
      end
      fsm_1_CLEAN : begin
        if(playfield_in_idle) begin
          lock_timeout_counter_willClear = 1'b1;
          lock_timeout_stateRise = 1'b0;
          fsm_stateNext = fsm_1_WAIT_TIME;
        end
      end
      fsm_1_WAIT_TIME : begin
        if(lock_timeout_state) begin
          fsm_stateNext = fsm_1_RANDOM_GEN;
        end
      end
      default : begin
        if(game_start) begin
          fsm_stateNext = fsm_1_GAME_START;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_onExit_PLACE) begin
      drop_timeout_counter_willClear = 1'b1;
      drop_timeout_stateRise = 1'b0;
      debug_place_new_cnt_willIncrement = 1'b1;
    end
    if(fsm_onEntry_LOCKDOWN) begin
      lock_timeout_counter_willClear = 1'b1;
      lock_timeout_stateRise = 1'b0;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_1_IDLE;
    end
  end

  assign drop_timeout_counter_willDecrement = 1'b0;
  assign drop_timeout_counter_willLoad = 1'b0;
  assign drop_timeout_counter_willOverflowIfInc = (drop_timeout_counter_value == 18'h30d3f);
  assign drop_timeout_counter_willUnderflowIfDec = (drop_timeout_counter_value == 18'h0);
  assign drop_timeout_counter_willOverflow = (drop_timeout_counter_willOverflowIfInc && drop_timeout_counter_willIncrement);
  always @(*) begin
    drop_timeout_counter_valueNext = (drop_timeout_counter_value + temp_drop_timeout_counter_valueNext);
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_counter_valueNext = 18'h0;
    end
    if(drop_timeout_counter_willClear) begin
      drop_timeout_counter_valueNext = 18'h0;
    end
  end

  assign drop_timeout_counter_willUnderflow = (drop_timeout_counter_willUnderflowIfDec && drop_timeout_counter_willDecrement);
  assign drop_timeout_counter_willIncrement = 1'b1;
  assign lock_timeout_counter_willDecrement = 1'b0;
  assign lock_timeout_counter_willLoad = 1'b0;
  assign lock_timeout_counter_willOverflowIfInc = (lock_timeout_counter_value == 16'hc34f);
  assign lock_timeout_counter_willUnderflowIfDec = (lock_timeout_counter_value == 16'h0);
  assign lock_timeout_counter_willOverflow = (lock_timeout_counter_willOverflowIfInc && lock_timeout_counter_willIncrement);
  always @(*) begin
    lock_timeout_counter_valueNext = (lock_timeout_counter_value + temp_lock_timeout_counter_valueNext);
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_counter_valueNext = 16'h0;
    end
    if(lock_timeout_counter_willClear) begin
      lock_timeout_counter_valueNext = 16'h0;
    end
  end

  assign lock_timeout_counter_willUnderflow = (lock_timeout_counter_willUnderflowIfDec && lock_timeout_counter_willDecrement);
  assign lock_timeout_counter_willIncrement = 1'b1;
  assign priority_1 = 5'h01;
  assign temp_1 = 3'b000;
  assign temp_2 = 3'b001;
  assign temp_3 = 3'b001;
  assign temp_4 = 3'b010;
  assign temp_5 = 3'b001;
  assign temp_6 = 3'b010;
  assign temp_7 = 3'b010;
  assign temp_8 = 3'b011;
  assign temp_motion_voted = motion_request;
  assign temp_motion_voted_1 = {temp_motion_voted,temp_motion_voted};
  assign temp_motion_voted_2 = (temp_motion_voted_1 & (~ temp_temp_motion_voted_2));
  assign motion_voted = (temp_motion_voted_2[9 : 5] | temp_motion_voted_2[4 : 0]);
  assign drop_1 = motion_voted[0];
  assign move_down_1 = motion_voted[1];
  assign move_left_1 = motion_voted[2];
  assign move_right_1 = motion_voted[3];
  assign rotate_1 = motion_voted[4];
  assign debug_place_new_cnt_willDecrement = 1'b0;
  assign debug_place_new_cnt_willClear = 1'b0;
  assign debug_place_new_cnt_willLoad = 1'b0;
  assign debug_place_new_cnt_willOverflowIfInc = (debug_place_new_cnt_value == 1'b1);
  assign debug_place_new_cnt_willUnderflowIfDec = (debug_place_new_cnt_value == 1'b0);
  assign debug_place_new_cnt_willOverflow = (debug_place_new_cnt_willOverflowIfInc && debug_place_new_cnt_willIncrement);
  always @(*) begin
    debug_place_new_cnt_valueNext = (debug_place_new_cnt_value + debug_place_new_cnt_willIncrement);
    if(debug_place_new_cnt_willClear) begin
      debug_place_new_cnt_valueNext = 1'b0;
    end
  end

  assign debug_place_new_cnt_willUnderflow = (debug_place_new_cnt_willUnderflowIfDec && debug_place_new_cnt_willDecrement);
  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  always @(*) begin
    move_out_down = 1'b0;
    if(fsm_onEntry_DOWN) begin
      move_out_down = 1'b1;
    end
    if(fsm_onEntry_DROP) begin
      move_out_down = 1'b1;
    end
    if(fsm_onEntry_LOCK) begin
      move_out_down = 1'b1;
    end
  end

  always @(*) begin
    clear_motion_request = 1'b0;
    if(fsm_onExit_FALLING) begin
      clear_motion_request = 1'b1;
    end
  end

  assign fsm_onExit_PLACE = ((fsm_stateNext != fsm_1_PLACE) && (fsm_stateReg == fsm_1_PLACE));
  assign fsm_onExit_FALLING = ((fsm_stateNext != fsm_1_FALLING) && (fsm_stateReg == fsm_1_FALLING));
  assign fsm_onEntry_DOWN = ((fsm_stateNext == fsm_1_DOWN) && (fsm_stateReg != fsm_1_DOWN));
  assign fsm_onEntry_DROP = ((fsm_stateNext == fsm_1_DROP) && (fsm_stateReg != fsm_1_DROP));
  assign fsm_onEntry_LOCK = ((fsm_stateNext == fsm_1_LOCK) && (fsm_stateReg != fsm_1_LOCK));
  assign fsm_onEntry_LOCKDOWN = ((fsm_stateNext == fsm_1_LOCKDOWN) && (fsm_stateReg != fsm_1_LOCKDOWN));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      drop_timeout_state <= 1'b0;
      drop_timeout_counter_value <= 18'h0;
      lock_timeout_state <= 1'b0;
      lock_timeout_counter_value <= 16'h0;
      motion_request <= 5'h0;
      drop_regNext <= 1'b0;
      move_down_regNext <= 1'b0;
      move_left_regNext <= 1'b0;
      move_right_regNext <= 1'b0;
      rotate_regNext <= 1'b0;
      debug_place_new_cnt_value <= 1'b0;
      fsm_stateReg <= fsm_1_IDLE;
    end else begin
      drop_timeout_counter_value <= drop_timeout_counter_valueNext;
      if(drop_timeout_counter_willOverflow) begin
        drop_timeout_state <= 1'b1;
      end
      lock_timeout_counter_value <= lock_timeout_counter_valueNext;
      if(lock_timeout_counter_willOverflow) begin
        lock_timeout_state <= 1'b1;
      end
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((temp_9 == 3'b001)); // controller.scala:L126
        `else
          if(!(temp_9 == 3'b001)) begin
            $display("FAILURE priority must be one-hot"); // controller.scala:L126
            $finish;
          end
        `endif
      `endif
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[0] <= 1'b0;
      end else begin
        if((drop && (! drop_regNext))) begin
          motion_request[0] <= 1'b1;
        end
      end
      drop_regNext <= drop;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[1] <= 1'b0;
      end else begin
        if((move_down && (! move_down_regNext))) begin
          motion_request[1] <= 1'b1;
        end
      end
      move_down_regNext <= move_down;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[2] <= 1'b0;
      end else begin
        if((move_left && (! move_left_regNext))) begin
          motion_request[2] <= 1'b1;
        end
      end
      move_left_regNext <= move_left;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[3] <= 1'b0;
      end else begin
        if((move_right && (! move_right_regNext))) begin
          motion_request[3] <= 1'b1;
        end
      end
      move_right_regNext <= move_right;
      if(((game_start || game_restart) || clear_motion_request)) begin
        motion_request[4] <= 1'b0;
      end else begin
        if((rotate && (! rotate_regNext))) begin
          motion_request[4] <= 1'b1;
        end
      end
      rotate_regNext <= rotate;
      debug_place_new_cnt_value <= debug_place_new_cnt_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_1_GAME_START : begin
        end
        fsm_1_RANDOM_GEN : begin
        end
        fsm_1_PLACE : begin
        end
        fsm_1_END_1 : begin
        end
        fsm_1_FALLING : begin
        end
        fsm_1_DOWN : begin
          if(collision_status_valid) begin
            if(temp_when) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        fsm_1_DROP : begin
        end
        fsm_1_WAIT_ALLOW_ACTION : begin
        end
        fsm_1_MOVE : begin
        end
        fsm_1_RRE_LOCK : begin
        end
        fsm_1_LOCK : begin
          if(collision_status_valid) begin
            if(!collision_status_payload) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        fsm_1_LOCKDOWN : begin
        end
        fsm_1_CLEAN : begin
          if(playfield_in_idle) begin
            lock_timeout_state <= 1'b0;
          end
        end
        fsm_1_WAIT_TIME : begin
        end
        default : begin
        end
      endcase
      if(fsm_onExit_PLACE) begin
        drop_timeout_state <= 1'b0;
      end
      if(fsm_onEntry_LOCKDOWN) begin
        lock_timeout_state <= 1'b0;
      end
    end
  end


endmodule

module playfield (
  input  wire          piece_in_valid,
  input  wire [2:0]    piece_in_payload,
  output reg           status_valid,
  output reg           status_payload,
  input  wire          move_in_left,
  input  wire          move_in_right,
  input  wire          move_in_rotate,
  input  wire          move_in_down,
  input  wire          lock,
  input  wire          game_restart,
  output wire          row_val_valid,
  output reg  [9:0]    row_val_payload,
  output wire          score_val_valid,
  output wire [9:0]    score_val_payload,
  output wire          motion_is_allowed,
  output wire          fsm_is_idle,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam TYPE_1_I = 3'd0;
  localparam TYPE_1_J = 3'd1;
  localparam TYPE_1_L = 3'd2;
  localparam TYPE_1_O = 3'd3;
  localparam TYPE_1_S = 3'd4;
  localparam TYPE_1_T = 3'd5;
  localparam TYPE_1_Z = 3'd6;
  localparam ACTION_NO = 3'd0;
  localparam ACTION_LEFT = 3'd1;
  localparam ACTION_RIGHT = 3'd2;
  localparam ACTION_DOWN = 3'd3;
  localparam ACTION_ROTATE = 3'd4;
  localparam ACTION_PLACE = 3'd5;
  localparam main_fsm_IDLE = 5'd0;
  localparam main_fsm_READOUT = 5'd1;
  localparam main_fsm_LOAD_TO_CHECKER = 5'd2;
  localparam main_fsm_COLLISION_CHECK = 5'd3;
  localparam main_fsm_REPORT_COLLISION = 5'd4;
  localparam main_fsm_END_OF_COLLISION = 5'd5;
  localparam main_fsm_PASS = 5'd6;
  localparam main_fsm_WAIT_CONTROL = 5'd7;
  localparam main_fsm_ROTATION = 5'd8;
  localparam main_fsm_PRE_CHECK = 5'd9;
  localparam main_fsm_LOCKER_WRITE_0 = 5'd10;
  localparam main_fsm_LOCKER_WRITE_1 = 5'd11;
  localparam main_fsm_WAIT_LOCKER_WRITE_DONE = 5'd12;
  localparam main_fsm_LOCKER_READ = 5'd13;
  localparam main_fsm_WAIT_LOCKER_READ_DONE = 5'd14;
  localparam main_fsm_CLEAR_REGION = 5'd15;
  localparam main_fsm_CHECK_ROW_FULL = 5'd16;
  localparam main_fsm_ROW_REMOVE = 5'd17;
  localparam main_fsm_ROW_REMOVE_DONE = 5'd18;

  reg        [9:0]    locker_region_spinal_port1;
  wire       [1:0]    temp_piece_buffer_pieces_0_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_0_overflow_1;
  wire       [1:0]    temp_piece_buffer_pieces_1_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_1_overflow_1;
  wire       [1:0]    temp_piece_buffer_pieces_2_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_2_overflow_1;
  wire       [1:0]    temp_piece_buffer_pieces_3_overflow;
  wire       [1:0]    temp_piece_buffer_pieces_3_overflow_1;
  reg        [9:0]    temp_checker_readout;
  wire       [4:0]    temp_playfield_count_8;
  wire       [4:0]    temp_playfield_count_9;
  reg        [4:0]    temp_playfield_count_10;
  wire       [2:0]    temp_playfield_count_11;
  reg        [4:0]    temp_playfield_count_12;
  wire       [2:0]    temp_playfield_count_13;
  wire       [4:0]    temp_playfield_count_14;
  reg        [4:0]    temp_playfield_count_15;
  wire       [2:0]    temp_playfield_count_16;
  reg        [4:0]    temp_playfield_count_17;
  wire       [2:0]    temp_playfield_count_18;
  wire       [4:0]    temp_playfield_count_19;
  wire       [4:0]    temp_playfield_count_20;
  reg        [4:0]    temp_playfield_count_21;
  wire       [2:0]    temp_playfield_count_22;
  reg        [4:0]    temp_playfield_count_23;
  wire       [2:0]    temp_playfield_count_24;
  wire       [4:0]    temp_playfield_count_25;
  reg        [4:0]    temp_playfield_count_26;
  wire       [2:0]    temp_playfield_count_27;
  reg        [4:0]    temp_playfield_count_28;
  wire       [2:0]    temp_playfield_count_29;
  wire       [0:0]    temp_playfield_count_30;
  wire       [21:0]   temp_playfield_lowestOne;
  wire       [9:0]    temp_playfield_total_score;
  reg        [9:0]    temp_flow_readout;
  wire                temp_locker_region_port;
  reg        [9:0]    temp_checker_region_0;
  reg        [9:0]    temp_checker_region_1;
  reg        [9:0]    temp_checker_region_2;
  reg        [9:0]    temp_checker_region_3;
  wire                temp_when;
  wire                temp_when_1;
  wire                temp_when_2;
  reg                 temp_when_3;
  reg                 piece_valid;
  reg        [2:0]    piece_payload;
  reg                 load_piece;
  reg        [2:0]    action_1;
  reg        [1:0]    piece_buffer_rot_cur;
  reg        [1:0]    piece_buffer_rot_backup;
  reg                 piece_buffer_left_shift_all;
  reg                 piece_buffer_right_shift_all;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_0_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_0_region_0;
  wire       [9:0]    piece_buffer_pieces_0_region_1;
  wire       [9:0]    piece_buffer_pieces_0_region_2;
  wire       [9:0]    piece_buffer_pieces_0_region_3;
  wire                piece_buffer_pieces_0_left_overflow;
  wire                piece_buffer_pieces_0_right_overflow;
  wire                piece_buffer_pieces_0_overflow;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_1_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_1_region_0;
  wire       [9:0]    piece_buffer_pieces_1_region_1;
  wire       [9:0]    piece_buffer_pieces_1_region_2;
  wire       [9:0]    piece_buffer_pieces_1_region_3;
  wire                piece_buffer_pieces_1_left_overflow;
  wire                piece_buffer_pieces_1_right_overflow;
  wire                piece_buffer_pieces_1_overflow;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_2_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_2_region_0;
  wire       [9:0]    piece_buffer_pieces_2_region_1;
  wire       [9:0]    piece_buffer_pieces_2_region_2;
  wire       [9:0]    piece_buffer_pieces_2_region_3;
  wire                piece_buffer_pieces_2_left_overflow;
  wire                piece_buffer_pieces_2_right_overflow;
  wire                piece_buffer_pieces_2_overflow;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_0;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_1;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_2;
  reg        [13:0]   piece_buffer_pieces_3_region_extra_3;
  wire       [9:0]    piece_buffer_pieces_3_region_0;
  wire       [9:0]    piece_buffer_pieces_3_region_1;
  wire       [9:0]    piece_buffer_pieces_3_region_2;
  wire       [9:0]    piece_buffer_pieces_3_region_3;
  wire                piece_buffer_pieces_3_left_overflow;
  wire                piece_buffer_pieces_3_right_overflow;
  wire                piece_buffer_pieces_3_overflow;
  reg        [4:0]    checker_row;
  reg        [4:0]    checker_row_backup;
  wire                checker_read_req;
  wire                checker_addr_access_port_valid;
  wire       [1:0]    checker_addr_access_port_payload;
  reg        [9:0]    checker_region_0;
  reg        [9:0]    checker_region_1;
  reg        [9:0]    checker_region_2;
  reg        [9:0]    checker_region_3;
  reg        [9:0]    checker_readout;
  wire                checker_restore;
  reg                 checker_right_shift;
  reg                 checker_left_shift;
  wire                checker_overflowIfLeft;
  wire                checker_overflowIfRight;
  wire                checker_overflowIfDown;
  wire                playfield_reset;
  reg                 playfield_freeze;
  reg                 playfield_clear;
  reg                 playfield_update_score;
  wire       [4:0]    playfield_access_row_base;
  wire                playfield_read_req_port_valid;
  wire       [4:0]    playfield_read_req_port_payload;
  wire                playfield_write_req_port_valid;
  wire       [4:0]    playfield_write_req_port_payload;
  wire                playfield_addr_access_port_valid;
  wire       [4:0]    playfield_addr_access_port_payload;
  reg        [9:0]    playfield_readout;
  wire                playfield_write_in_port_valid;
  wire       [9:0]    playfield_write_in_port_payload;
  reg        [9:0]    playfield_region_0;
  reg        [9:0]    playfield_region_1;
  reg        [9:0]    playfield_region_2;
  reg        [9:0]    playfield_region_3;
  reg        [9:0]    playfield_region_4;
  reg        [9:0]    playfield_region_5;
  reg        [9:0]    playfield_region_6;
  reg        [9:0]    playfield_region_7;
  reg        [9:0]    playfield_region_8;
  reg        [9:0]    playfield_region_9;
  reg        [9:0]    playfield_region_10;
  reg        [9:0]    playfield_region_11;
  reg        [9:0]    playfield_region_12;
  reg        [9:0]    playfield_region_13;
  reg        [9:0]    playfield_region_14;
  reg        [9:0]    playfield_region_15;
  reg        [9:0]    playfield_region_16;
  reg        [9:0]    playfield_region_17;
  reg        [9:0]    playfield_region_18;
  reg        [9:0]    playfield_region_19;
  reg        [9:0]    playfield_region_20;
  reg        [9:0]    playfield_region_21;
  reg        [21:0]   playfield_row_sel;
  wire                playfield_address_beyond_limit;
  wire       [219:0]  temp_playfield_region_0;
  reg        [21:0]   playfield_ones;
  wire       [4:0]    temp_playfield_count;
  wire       [4:0]    temp_playfield_count_1;
  wire       [4:0]    temp_playfield_count_2;
  wire       [4:0]    temp_playfield_count_3;
  wire       [4:0]    temp_playfield_count_4;
  wire       [4:0]    temp_playfield_count_5;
  wire       [4:0]    temp_playfield_count_6;
  wire       [4:0]    temp_playfield_count_7;
  reg        [4:0]    playfield_count;
  wire                playfield_isRowFull;
  wire       [21:0]   playfield_lowestOne;
  wire       [21:0]   playfield_rows_to_clear;
  reg        [9:0]    playfield_total_score;
  reg                 playfield_update_score_delay_1;
  reg                 playfield_lock_score;
  reg                 playfield_lock_score_1d;
  reg                 game_restart_regNext;
  reg        [4:0]    flow_row;
  wire                flow_read_req;
  wire                flow_addr_access_port_valid;
  wire       [1:0]    flow_addr_access_port_payload;
  reg        [9:0]    flow_region_0;
  reg        [9:0]    flow_region_1;
  reg        [9:0]    flow_region_2;
  reg        [9:0]    flow_region_3;
  reg        [9:0]    flow_readout;
  reg                 flow_update;
  reg        [3:0]    flow_row_occuppied;
  reg                 collision_checker_start;
  reg                 collision_checker_collision_bits_valid;
  reg                 collision_checker_collision_bits_payload;
  wire                collision_checker_src_0_valid;
  wire       [9:0]    collision_checker_src_0_payload;
  wire                collision_checker_src_1_valid;
  wire       [9:0]    collision_checker_src_1_payload;
  reg                 collision_checker_check_status;
  wire                collision_checker_is_collision_valid;
  wire                collision_checker_is_collision_payload;
  reg                 collision_checker_collision_bits_valid_regNext;
  reg                 output_en;
  wire                playfield_dataout_valid;
  wire       [9:0]    playfield_dataout_payload;
  wire                src_0_valid;
  wire       [9:0]    src_0_payload;
  wire                src_1_valid;
  wire       [9:0]    src_1_payload;
  wire                src_2_valid;
  wire       [9:0]    src_2_payload;
  reg                 playfield_dataout_stage_valid;
  reg        [9:0]    playfield_dataout_stage_payload;
  wire       [9:0]    row_merged;
  reg                 src_0_valid_regNext;
  wire                row_out_done;
  wire                locker_addr_access_port_valid;
  wire       [1:0]    locker_addr_access_port_payload;
  wire                locker_data_in_port_valid;
  wire       [9:0]    locker_data_in_port_payload;
  wire       [9:0]    locker_readout;
  reg                 locker_addr_access_port_valid_regNext;
  wire                locker_readou_is_done;
  reg        [4:0]    dma_playfield_dma_base_addr;
  reg        [4:0]    dma_playfield_dma_word_count;
  reg                 dma_playfield_dma_start;
  reg        [4:0]    dma_playfield_dma_req_counter;
  wire                dma_playfield_dma_counter_is_last;
  reg                 dma_playfield_dma_start_regNext;
  wire                dma_playfield_dma_trig;
  reg                 dma_playfield_dma_req_valid;
  reg                 dma_playfield_dma_req_valid_regNext;
  reg        [4:0]    dma_playfield_dma_addr;
  wire       [9:0]    dma_playfield_dma_source_0;
  wire       [9:0]    dma_playfield_dma_source_1;
  wire                dma_playfield_dma_sink_0_valid;
  wire       [9:0]    dma_playfield_dma_sink_0_payload;
  wire                dma_playfield_dma_sink_1_valid;
  wire       [9:0]    dma_playfield_dma_sink_1_payload;
  wire                dma_playfield_dma_sink_2_valid;
  wire       [9:0]    dma_playfield_dma_sink_2_payload;
  reg                 dma_playfield_dma_req_valid_1d;
  wire                dma_playfield_dma_channel_0_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_payload;
  reg                 dma_playfield_dma_channel_0_enable;
  wire                dma_playfield_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_data_in_payload;
  wire                dma_playfield_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_data_out_payload;
  wire                dma_playfield_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_playfield_dma_channel_0_data_inter_payload;
  wire                dma_playfield_dma_channel_1_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_payload;
  reg                 dma_playfield_dma_channel_1_enable;
  wire                dma_playfield_dma_channel_1_data_in_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_data_in_payload;
  wire                dma_playfield_dma_channel_1_data_out_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_data_out_payload;
  wire                dma_playfield_dma_channel_1_data_inter_valid;
  wire       [9:0]    dma_playfield_dma_channel_1_data_inter_payload;
  wire                dma_playfield_dma_channel_2_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_payload;
  reg                 dma_playfield_dma_channel_2_enable;
  wire                dma_playfield_dma_channel_2_data_in_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_data_in_payload;
  wire                dma_playfield_dma_channel_2_data_out_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_data_out_payload;
  wire                dma_playfield_dma_channel_2_data_inter_valid;
  wire       [9:0]    dma_playfield_dma_channel_2_data_inter_payload;
  wire       [1:0]    dma_checker_dma_base_addr;
  wire       [1:0]    dma_checker_dma_word_count;
  reg                 dma_checker_dma_start;
  reg        [1:0]    dma_checker_dma_req_counter;
  wire                dma_checker_dma_counter_is_last;
  reg                 dma_checker_dma_start_regNext;
  wire                dma_checker_dma_trig;
  reg                 dma_checker_dma_req_valid;
  reg                 dma_checker_dma_req_valid_regNext;
  reg        [1:0]    dma_checker_dma_addr;
  wire       [9:0]    dma_checker_dma_source_0;
  wire                dma_checker_dma_sink_0_valid;
  wire       [9:0]    dma_checker_dma_sink_0_payload;
  reg                 dma_checker_dma_req_valid_1d;
  wire                dma_checker_dma_channel_0_valid;
  wire       [9:0]    dma_checker_dma_channel_0_payload;
  reg                 dma_checker_dma_channel_0_enable;
  wire                dma_checker_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_checker_dma_channel_0_data_in_payload;
  wire                dma_checker_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_checker_dma_channel_0_data_out_payload;
  wire                dma_checker_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_checker_dma_channel_0_data_inter_payload;
  wire       [1:0]    dma_flow_dma_base_addr;
  wire       [1:0]    dma_flow_dma_word_count;
  reg                 dma_flow_dma_start;
  reg        [1:0]    dma_flow_dma_req_counter;
  wire                dma_flow_dma_counter_is_last;
  reg                 dma_flow_dma_start_regNext;
  wire                dma_flow_dma_trig;
  reg                 dma_flow_dma_req_valid;
  reg                 dma_flow_dma_req_valid_regNext;
  reg        [1:0]    dma_flow_dma_addr;
  wire       [9:0]    dma_flow_dma_source_0;
  wire                dma_flow_dma_sink_0_valid;
  wire       [9:0]    dma_flow_dma_sink_0_payload;
  reg                 dma_flow_dma_req_valid_1d;
  wire                dma_flow_dma_channel_0_valid;
  wire       [9:0]    dma_flow_dma_channel_0_payload;
  reg                 dma_flow_dma_channel_0_enable;
  wire                dma_flow_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_flow_dma_channel_0_data_in_payload;
  wire                dma_flow_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_flow_dma_channel_0_data_out_payload;
  wire                dma_flow_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_flow_dma_channel_0_data_inter_payload;
  wire       [1:0]    dma_locker_dma_base_addr;
  wire       [1:0]    dma_locker_dma_word_count;
  reg                 dma_locker_dma_start;
  reg        [1:0]    dma_locker_dma_req_counter;
  wire                dma_locker_dma_counter_is_last;
  reg                 dma_locker_dma_start_regNext;
  wire                dma_locker_dma_trig;
  reg                 dma_locker_dma_req_valid;
  reg                 dma_locker_dma_req_valid_regNext;
  reg        [1:0]    dma_locker_dma_addr;
  wire       [9:0]    dma_locker_dma_source_0;
  wire       [9:0]    dma_locker_dma_source_1;
  wire                dma_locker_dma_sink_0_valid;
  wire       [9:0]    dma_locker_dma_sink_0_payload;
  wire                dma_locker_dma_sink_1_valid;
  wire       [9:0]    dma_locker_dma_sink_1_payload;
  reg                 dma_locker_dma_req_valid_1d;
  wire                dma_locker_dma_channel_0_valid;
  wire       [9:0]    dma_locker_dma_channel_0_payload;
  reg                 dma_locker_dma_channel_0_enable;
  wire                dma_locker_dma_channel_0_data_in_valid;
  wire       [9:0]    dma_locker_dma_channel_0_data_in_payload;
  wire                dma_locker_dma_channel_0_data_out_valid;
  wire       [9:0]    dma_locker_dma_channel_0_data_out_payload;
  wire                dma_locker_dma_channel_0_data_inter_valid;
  wire       [9:0]    dma_locker_dma_channel_0_data_inter_payload;
  wire                dma_locker_dma_channel_1_valid;
  wire       [9:0]    dma_locker_dma_channel_1_payload;
  reg                 dma_locker_dma_channel_1_enable;
  wire                dma_locker_dma_channel_1_data_in_valid;
  wire       [9:0]    dma_locker_dma_channel_1_data_in_payload;
  wire                dma_locker_dma_channel_1_data_out_valid;
  wire       [9:0]    dma_locker_dma_channel_1_data_out_payload;
  wire                dma_locker_dma_channel_1_data_inter_valid;
  wire       [9:0]    dma_locker_dma_channel_1_data_inter_payload;
  wire                main_fsm_wantExit;
  reg                 main_fsm_wantStart;
  wire                main_fsm_wantKill;
  reg                 main_fsm_will_goto_idle;
  reg        [4:0]    main_fsm_stateReg;
  reg        [4:0]    main_fsm_stateNext;
  wire       [39:0]   temp_flow_region_0;
  wire                main_fsm_onExit_READOUT;
  wire                main_fsm_onExit_COLLISION_CHECK;
  wire                main_fsm_onExit_PASS;
  wire                main_fsm_onExit_WAIT_LOCKER_WRITE_DONE;
  wire                main_fsm_onExit_WAIT_LOCKER_READ_DONE;
  wire                main_fsm_onEntry_READOUT;
  wire                main_fsm_onEntry_COLLISION_CHECK;
  wire                main_fsm_onEntry_PASS;
  wire                main_fsm_onEntry_LOCKER_WRITE_0;
  wire                main_fsm_onEntry_LOCKER_READ;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_string;
  reg [7:0] piece_payload_string;
  reg [47:0] action_1_string;
  reg [175:0] main_fsm_stateReg_string;
  reg [175:0] main_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [9:0] locker_region [0:3];

  assign temp_when = (action_1 == ACTION_PLACE);
  assign temp_when_1 = (action_1 == ACTION_DOWN);
  assign temp_when_2 = (action_1 == ACTION_ROTATE);
  assign temp_playfield_count_8 = (temp_playfield_count_9 + temp_playfield_count_14);
  assign temp_playfield_count_9 = (temp_playfield_count_10 + temp_playfield_count_12);
  assign temp_playfield_count_14 = (temp_playfield_count_15 + temp_playfield_count_17);
  assign temp_playfield_count_19 = (temp_playfield_count_20 + temp_playfield_count_25);
  assign temp_playfield_count_20 = (temp_playfield_count_21 + temp_playfield_count_23);
  assign temp_playfield_count_25 = (temp_playfield_count_26 + temp_playfield_count_28);
  assign temp_playfield_count_30 = playfield_ones[21];
  assign temp_playfield_count_29 = {2'd0, temp_playfield_count_30};
  assign temp_playfield_lowestOne = (playfield_ones - 22'h000001);
  assign temp_playfield_total_score = {5'd0, playfield_count};
  assign temp_locker_region_port = (locker_addr_access_port_valid && locker_data_in_port_valid);
  assign temp_playfield_count_11 = {playfield_ones[2],{playfield_ones[1],playfield_ones[0]}};
  assign temp_playfield_count_13 = {playfield_ones[5],{playfield_ones[4],playfield_ones[3]}};
  assign temp_playfield_count_16 = {playfield_ones[8],{playfield_ones[7],playfield_ones[6]}};
  assign temp_playfield_count_18 = {playfield_ones[11],{playfield_ones[10],playfield_ones[9]}};
  assign temp_playfield_count_22 = {playfield_ones[14],{playfield_ones[13],playfield_ones[12]}};
  assign temp_playfield_count_24 = {playfield_ones[17],{playfield_ones[16],playfield_ones[15]}};
  assign temp_playfield_count_27 = {playfield_ones[20],{playfield_ones[19],playfield_ones[18]}};
  assign temp_piece_buffer_pieces_0_overflow = piece_buffer_pieces_0_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_0_overflow_1 = piece_buffer_pieces_0_region_extra_0[1 : 0];
  assign temp_piece_buffer_pieces_1_overflow = piece_buffer_pieces_1_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_1_overflow_1 = piece_buffer_pieces_1_region_extra_0[1 : 0];
  assign temp_piece_buffer_pieces_2_overflow = piece_buffer_pieces_2_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_2_overflow_1 = piece_buffer_pieces_2_region_extra_0[1 : 0];
  assign temp_piece_buffer_pieces_3_overflow = piece_buffer_pieces_3_region_extra_0[13 : 12];
  assign temp_piece_buffer_pieces_3_overflow_1 = piece_buffer_pieces_3_region_extra_0[1 : 0];
  always @(posedge core_clk) begin
    if(temp_locker_region_port) begin
      locker_region[locker_addr_access_port_payload] <= locker_data_in_port_payload;
    end
  end

  always @(posedge core_clk) begin
    if(locker_addr_access_port_valid) begin
      locker_region_spinal_port1 <= locker_region[locker_addr_access_port_payload];
    end
  end

  always @(*) begin
    case(checker_addr_access_port_payload)
      2'b00 : temp_checker_readout = checker_region_0;
      2'b01 : temp_checker_readout = checker_region_1;
      2'b10 : temp_checker_readout = checker_region_2;
      default : temp_checker_readout = checker_region_3;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_11)
      3'b000 : temp_playfield_count_10 = temp_playfield_count;
      3'b001 : temp_playfield_count_10 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_10 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_10 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_10 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_10 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_10 = temp_playfield_count_6;
      default : temp_playfield_count_10 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_13)
      3'b000 : temp_playfield_count_12 = temp_playfield_count;
      3'b001 : temp_playfield_count_12 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_12 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_12 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_12 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_12 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_12 = temp_playfield_count_6;
      default : temp_playfield_count_12 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_16)
      3'b000 : temp_playfield_count_15 = temp_playfield_count;
      3'b001 : temp_playfield_count_15 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_15 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_15 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_15 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_15 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_15 = temp_playfield_count_6;
      default : temp_playfield_count_15 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_18)
      3'b000 : temp_playfield_count_17 = temp_playfield_count;
      3'b001 : temp_playfield_count_17 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_17 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_17 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_17 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_17 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_17 = temp_playfield_count_6;
      default : temp_playfield_count_17 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_22)
      3'b000 : temp_playfield_count_21 = temp_playfield_count;
      3'b001 : temp_playfield_count_21 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_21 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_21 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_21 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_21 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_21 = temp_playfield_count_6;
      default : temp_playfield_count_21 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_24)
      3'b000 : temp_playfield_count_23 = temp_playfield_count;
      3'b001 : temp_playfield_count_23 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_23 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_23 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_23 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_23 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_23 = temp_playfield_count_6;
      default : temp_playfield_count_23 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_27)
      3'b000 : temp_playfield_count_26 = temp_playfield_count;
      3'b001 : temp_playfield_count_26 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_26 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_26 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_26 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_26 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_26 = temp_playfield_count_6;
      default : temp_playfield_count_26 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(temp_playfield_count_29)
      3'b000 : temp_playfield_count_28 = temp_playfield_count;
      3'b001 : temp_playfield_count_28 = temp_playfield_count_1;
      3'b010 : temp_playfield_count_28 = temp_playfield_count_2;
      3'b011 : temp_playfield_count_28 = temp_playfield_count_3;
      3'b100 : temp_playfield_count_28 = temp_playfield_count_4;
      3'b101 : temp_playfield_count_28 = temp_playfield_count_5;
      3'b110 : temp_playfield_count_28 = temp_playfield_count_6;
      default : temp_playfield_count_28 = temp_playfield_count_7;
    endcase
  end

  always @(*) begin
    case(flow_addr_access_port_payload)
      2'b00 : temp_flow_readout = flow_region_0;
      2'b01 : temp_flow_readout = flow_region_1;
      2'b10 : temp_flow_readout = flow_region_2;
      default : temp_flow_readout = flow_region_3;
    endcase
  end

  always @(*) begin
    case(piece_buffer_rot_cur)
      2'b00 : begin
        temp_checker_region_0 = piece_buffer_pieces_0_region_0;
        temp_checker_region_1 = piece_buffer_pieces_0_region_1;
        temp_checker_region_2 = piece_buffer_pieces_0_region_2;
        temp_checker_region_3 = piece_buffer_pieces_0_region_3;
        temp_when_3 = piece_buffer_pieces_0_overflow;
      end
      2'b01 : begin
        temp_checker_region_0 = piece_buffer_pieces_1_region_0;
        temp_checker_region_1 = piece_buffer_pieces_1_region_1;
        temp_checker_region_2 = piece_buffer_pieces_1_region_2;
        temp_checker_region_3 = piece_buffer_pieces_1_region_3;
        temp_when_3 = piece_buffer_pieces_1_overflow;
      end
      2'b10 : begin
        temp_checker_region_0 = piece_buffer_pieces_2_region_0;
        temp_checker_region_1 = piece_buffer_pieces_2_region_1;
        temp_checker_region_2 = piece_buffer_pieces_2_region_2;
        temp_checker_region_3 = piece_buffer_pieces_2_region_3;
        temp_when_3 = piece_buffer_pieces_2_overflow;
      end
      default : begin
        temp_checker_region_0 = piece_buffer_pieces_3_region_0;
        temp_checker_region_1 = piece_buffer_pieces_3_region_1;
        temp_checker_region_2 = piece_buffer_pieces_3_region_2;
        temp_checker_region_3 = piece_buffer_pieces_3_region_3;
        temp_when_3 = piece_buffer_pieces_3_overflow;
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(piece_in_payload)
      TYPE_1_I : piece_in_payload_string = "I";
      TYPE_1_J : piece_in_payload_string = "J";
      TYPE_1_L : piece_in_payload_string = "L";
      TYPE_1_O : piece_in_payload_string = "O";
      TYPE_1_S : piece_in_payload_string = "S";
      TYPE_1_T : piece_in_payload_string = "T";
      TYPE_1_Z : piece_in_payload_string = "Z";
      default : piece_in_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_payload)
      TYPE_1_I : piece_payload_string = "I";
      TYPE_1_J : piece_payload_string = "J";
      TYPE_1_L : piece_payload_string = "L";
      TYPE_1_O : piece_payload_string = "O";
      TYPE_1_S : piece_payload_string = "S";
      TYPE_1_T : piece_payload_string = "T";
      TYPE_1_Z : piece_payload_string = "Z";
      default : piece_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(action_1)
      ACTION_NO : action_1_string = "NO    ";
      ACTION_LEFT : action_1_string = "LEFT  ";
      ACTION_RIGHT : action_1_string = "RIGHT ";
      ACTION_DOWN : action_1_string = "DOWN  ";
      ACTION_ROTATE : action_1_string = "ROTATE";
      ACTION_PLACE : action_1_string = "PLACE ";
      default : action_1_string = "??????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateReg)
      main_fsm_IDLE : main_fsm_stateReg_string = "IDLE                  ";
      main_fsm_READOUT : main_fsm_stateReg_string = "READOUT               ";
      main_fsm_LOAD_TO_CHECKER : main_fsm_stateReg_string = "LOAD_TO_CHECKER       ";
      main_fsm_COLLISION_CHECK : main_fsm_stateReg_string = "COLLISION_CHECK       ";
      main_fsm_REPORT_COLLISION : main_fsm_stateReg_string = "REPORT_COLLISION      ";
      main_fsm_END_OF_COLLISION : main_fsm_stateReg_string = "END_OF_COLLISION      ";
      main_fsm_PASS : main_fsm_stateReg_string = "PASS                  ";
      main_fsm_WAIT_CONTROL : main_fsm_stateReg_string = "WAIT_CONTROL          ";
      main_fsm_ROTATION : main_fsm_stateReg_string = "ROTATION              ";
      main_fsm_PRE_CHECK : main_fsm_stateReg_string = "PRE_CHECK             ";
      main_fsm_LOCKER_WRITE_0 : main_fsm_stateReg_string = "LOCKER_WRITE_0        ";
      main_fsm_LOCKER_WRITE_1 : main_fsm_stateReg_string = "LOCKER_WRITE_1        ";
      main_fsm_WAIT_LOCKER_WRITE_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_WRITE_DONE";
      main_fsm_LOCKER_READ : main_fsm_stateReg_string = "LOCKER_READ           ";
      main_fsm_WAIT_LOCKER_READ_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_READ_DONE ";
      main_fsm_CLEAR_REGION : main_fsm_stateReg_string = "CLEAR_REGION          ";
      main_fsm_CHECK_ROW_FULL : main_fsm_stateReg_string = "CHECK_ROW_FULL        ";
      main_fsm_ROW_REMOVE : main_fsm_stateReg_string = "ROW_REMOVE            ";
      main_fsm_ROW_REMOVE_DONE : main_fsm_stateReg_string = "ROW_REMOVE_DONE       ";
      default : main_fsm_stateReg_string = "??????????????????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateNext)
      main_fsm_IDLE : main_fsm_stateNext_string = "IDLE                  ";
      main_fsm_READOUT : main_fsm_stateNext_string = "READOUT               ";
      main_fsm_LOAD_TO_CHECKER : main_fsm_stateNext_string = "LOAD_TO_CHECKER       ";
      main_fsm_COLLISION_CHECK : main_fsm_stateNext_string = "COLLISION_CHECK       ";
      main_fsm_REPORT_COLLISION : main_fsm_stateNext_string = "REPORT_COLLISION      ";
      main_fsm_END_OF_COLLISION : main_fsm_stateNext_string = "END_OF_COLLISION      ";
      main_fsm_PASS : main_fsm_stateNext_string = "PASS                  ";
      main_fsm_WAIT_CONTROL : main_fsm_stateNext_string = "WAIT_CONTROL          ";
      main_fsm_ROTATION : main_fsm_stateNext_string = "ROTATION              ";
      main_fsm_PRE_CHECK : main_fsm_stateNext_string = "PRE_CHECK             ";
      main_fsm_LOCKER_WRITE_0 : main_fsm_stateNext_string = "LOCKER_WRITE_0        ";
      main_fsm_LOCKER_WRITE_1 : main_fsm_stateNext_string = "LOCKER_WRITE_1        ";
      main_fsm_WAIT_LOCKER_WRITE_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_WRITE_DONE";
      main_fsm_LOCKER_READ : main_fsm_stateNext_string = "LOCKER_READ           ";
      main_fsm_WAIT_LOCKER_READ_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_READ_DONE ";
      main_fsm_CLEAR_REGION : main_fsm_stateNext_string = "CLEAR_REGION          ";
      main_fsm_CHECK_ROW_FULL : main_fsm_stateNext_string = "CHECK_ROW_FULL        ";
      main_fsm_ROW_REMOVE : main_fsm_stateNext_string = "ROW_REMOVE            ";
      main_fsm_ROW_REMOVE_DONE : main_fsm_stateNext_string = "ROW_REMOVE_DONE       ";
      default : main_fsm_stateNext_string = "??????????????????????";
    endcase
  end
  `endif

  always @(*) begin
    load_piece = 1'b0;
    piece_buffer_left_shift_all = 1'b0;
    piece_buffer_right_shift_all = 1'b0;
    checker_right_shift = 1'b0;
    checker_left_shift = 1'b0;
    playfield_freeze = 1'b0;
    playfield_clear = 1'b0;
    playfield_update_score = 1'b0;
    flow_update = 1'b0;
    collision_checker_start = 1'b0;
    output_en = 1'b0;
    dma_playfield_dma_start = 1'b0;
    dma_checker_dma_start = 1'b0;
    dma_flow_dma_start = 1'b0;
    dma_locker_dma_start = 1'b0;
    main_fsm_wantStart = 1'b0;
    status_valid = 1'b0;
    status_payload = 1'b0;
    main_fsm_stateNext = main_fsm_stateReg;
    case(main_fsm_stateReg)
      main_fsm_READOUT : begin
        output_en = 1'b1;
        if((playfield_addr_access_port_payload == flow_row)) begin
          dma_flow_dma_start = 1'b1;
        end
        if(row_out_done) begin
          if(main_fsm_will_goto_idle) begin
            main_fsm_stateNext = main_fsm_IDLE;
          end else begin
            main_fsm_stateNext = main_fsm_WAIT_CONTROL;
          end
        end
      end
      main_fsm_LOAD_TO_CHECKER : begin
        load_piece = 1'b1;
        main_fsm_stateNext = main_fsm_COLLISION_CHECK;
      end
      main_fsm_COLLISION_CHECK : begin
        if(collision_checker_is_collision_valid) begin
          if(collision_checker_is_collision_payload) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = main_fsm_PASS;
          end
        end
      end
      main_fsm_REPORT_COLLISION : begin
        status_valid = 1'b1;
        status_payload = 1'b1;
        if(temp_when) begin
          main_fsm_stateNext = main_fsm_IDLE;
        end else begin
          main_fsm_stateNext = main_fsm_END_OF_COLLISION;
        end
      end
      main_fsm_END_OF_COLLISION : begin
        if((((action_1 == ACTION_LEFT) || (action_1 == ACTION_RIGHT)) || (action_1 == ACTION_ROTATE))) begin
          load_piece = 1'b1;
        end
        main_fsm_stateNext = main_fsm_WAIT_CONTROL;
      end
      main_fsm_PASS : begin
        if((action_1 == ACTION_PLACE)) begin
          flow_update = 1'b1;
        end
        if((action_1 == ACTION_LEFT)) begin
          flow_update = 1'b1;
          piece_buffer_left_shift_all = 1'b1;
        end
        if((action_1 == ACTION_RIGHT)) begin
          flow_update = 1'b1;
          piece_buffer_right_shift_all = 1'b1;
        end
        if(temp_when_1) begin
          flow_update = 1'b1;
        end
        if(temp_when_2) begin
          flow_update = 1'b1;
        end
        main_fsm_stateNext = main_fsm_READOUT;
      end
      main_fsm_WAIT_CONTROL : begin
        if(move_in_left) begin
          if(checker_overflowIfLeft) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            checker_left_shift = 1'b1;
            main_fsm_stateNext = main_fsm_PRE_CHECK;
          end
        end
        if(move_in_right) begin
          if(checker_overflowIfRight) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            checker_right_shift = 1'b1;
            main_fsm_stateNext = main_fsm_PRE_CHECK;
          end
        end
        if(move_in_down) begin
          if(checker_overflowIfDown) begin
            main_fsm_stateNext = main_fsm_REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = main_fsm_PRE_CHECK;
          end
        end
        if(move_in_rotate) begin
          main_fsm_stateNext = main_fsm_ROTATION;
        end
        if(lock) begin
          main_fsm_stateNext = main_fsm_LOCKER_WRITE_0;
        end
      end
      main_fsm_ROTATION : begin
        if(temp_when_3) begin
          main_fsm_stateNext = main_fsm_REPORT_COLLISION;
        end else begin
          load_piece = 1'b1;
          main_fsm_stateNext = main_fsm_PRE_CHECK;
        end
      end
      main_fsm_PRE_CHECK : begin
        main_fsm_stateNext = main_fsm_COLLISION_CHECK;
      end
      main_fsm_LOCKER_WRITE_0 : begin
        dma_flow_dma_start = 1'b1;
        main_fsm_stateNext = main_fsm_LOCKER_WRITE_1;
      end
      main_fsm_LOCKER_WRITE_1 : begin
        dma_locker_dma_start = 1'b1;
        main_fsm_stateNext = main_fsm_WAIT_LOCKER_WRITE_DONE;
      end
      main_fsm_WAIT_LOCKER_WRITE_DONE : begin
        if(row_out_done) begin
          main_fsm_stateNext = main_fsm_LOCKER_READ;
        end
      end
      main_fsm_LOCKER_READ : begin
        dma_playfield_dma_start = 1'b1;
        main_fsm_stateNext = main_fsm_WAIT_LOCKER_READ_DONE;
      end
      main_fsm_WAIT_LOCKER_READ_DONE : begin
        playfield_freeze = 1'b1;
        if(locker_readou_is_done) begin
          main_fsm_stateNext = main_fsm_CLEAR_REGION;
        end
      end
      main_fsm_CLEAR_REGION : begin
        playfield_update_score = 1'b1;
        main_fsm_stateNext = main_fsm_CHECK_ROW_FULL;
      end
      main_fsm_CHECK_ROW_FULL : begin
        if(playfield_isRowFull) begin
          main_fsm_stateNext = main_fsm_ROW_REMOVE;
        end else begin
          main_fsm_stateNext = main_fsm_READOUT;
        end
      end
      main_fsm_ROW_REMOVE : begin
        playfield_clear = 1'b1;
        main_fsm_stateNext = main_fsm_ROW_REMOVE_DONE;
      end
      main_fsm_ROW_REMOVE_DONE : begin
        main_fsm_stateNext = main_fsm_CHECK_ROW_FULL;
      end
      default : begin
        if(piece_valid) begin
          main_fsm_stateNext = main_fsm_LOAD_TO_CHECKER;
        end
        main_fsm_wantStart = 1'b1;
      end
    endcase
    if(main_fsm_onExit_READOUT) begin
      dma_playfield_dma_start = 1'b0;
      dma_flow_dma_start = 1'b0;
    end
    if(main_fsm_onExit_COLLISION_CHECK) begin
      dma_playfield_dma_start = 1'b0;
      dma_checker_dma_start = 1'b0;
    end
    if(main_fsm_onExit_WAIT_LOCKER_WRITE_DONE) begin
      dma_playfield_dma_start = 1'b0;
      dma_flow_dma_start = 1'b0;
      dma_locker_dma_start = 1'b0;
    end
    if(main_fsm_onExit_WAIT_LOCKER_READ_DONE) begin
      dma_locker_dma_start = 1'b0;
      dma_playfield_dma_start = 1'b0;
    end
    if(main_fsm_onEntry_READOUT) begin
      dma_playfield_dma_start = 1'b1;
    end
    if(main_fsm_onEntry_COLLISION_CHECK) begin
      collision_checker_start = 1'b1;
      dma_playfield_dma_start = 1'b1;
      dma_checker_dma_start = 1'b1;
    end
    if(main_fsm_onEntry_PASS) begin
      status_valid = 1'b1;
      status_payload = 1'b0;
    end
    if(main_fsm_onEntry_LOCKER_WRITE_0) begin
      dma_playfield_dma_start = 1'b1;
    end
    if(main_fsm_onEntry_LOCKER_READ) begin
      dma_locker_dma_start = 1'b1;
      playfield_freeze = 1'b1;
    end
    if(main_fsm_wantKill) begin
      main_fsm_stateNext = main_fsm_IDLE;
    end
  end

  assign piece_buffer_pieces_0_left_overflow = 1'b0;
  assign piece_buffer_pieces_0_right_overflow = 1'b0;
  assign piece_buffer_pieces_0_overflow = (((((piece_buffer_pieces_0_left_overflow || (|temp_piece_buffer_pieces_0_overflow)) || (|piece_buffer_pieces_0_region_extra_1[13 : 12])) || (|piece_buffer_pieces_0_region_extra_2[13 : 12])) || (|piece_buffer_pieces_0_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_0_right_overflow || (|temp_piece_buffer_pieces_0_overflow_1)) || (|piece_buffer_pieces_0_region_extra_1[1 : 0])) || (|piece_buffer_pieces_0_region_extra_2[1 : 0])) || (|piece_buffer_pieces_0_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_1_left_overflow = 1'b0;
  assign piece_buffer_pieces_1_right_overflow = 1'b0;
  assign piece_buffer_pieces_1_overflow = (((((piece_buffer_pieces_1_left_overflow || (|temp_piece_buffer_pieces_1_overflow)) || (|piece_buffer_pieces_1_region_extra_1[13 : 12])) || (|piece_buffer_pieces_1_region_extra_2[13 : 12])) || (|piece_buffer_pieces_1_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_1_right_overflow || (|temp_piece_buffer_pieces_1_overflow_1)) || (|piece_buffer_pieces_1_region_extra_1[1 : 0])) || (|piece_buffer_pieces_1_region_extra_2[1 : 0])) || (|piece_buffer_pieces_1_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_2_left_overflow = 1'b0;
  assign piece_buffer_pieces_2_right_overflow = 1'b0;
  assign piece_buffer_pieces_2_overflow = (((((piece_buffer_pieces_2_left_overflow || (|temp_piece_buffer_pieces_2_overflow)) || (|piece_buffer_pieces_2_region_extra_1[13 : 12])) || (|piece_buffer_pieces_2_region_extra_2[13 : 12])) || (|piece_buffer_pieces_2_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_2_right_overflow || (|temp_piece_buffer_pieces_2_overflow_1)) || (|piece_buffer_pieces_2_region_extra_1[1 : 0])) || (|piece_buffer_pieces_2_region_extra_2[1 : 0])) || (|piece_buffer_pieces_2_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_3_left_overflow = 1'b0;
  assign piece_buffer_pieces_3_right_overflow = 1'b0;
  assign piece_buffer_pieces_3_overflow = (((((piece_buffer_pieces_3_left_overflow || (|temp_piece_buffer_pieces_3_overflow)) || (|piece_buffer_pieces_3_region_extra_1[13 : 12])) || (|piece_buffer_pieces_3_region_extra_2[13 : 12])) || (|piece_buffer_pieces_3_region_extra_3[13 : 12])) || ((((piece_buffer_pieces_3_right_overflow || (|temp_piece_buffer_pieces_3_overflow_1)) || (|piece_buffer_pieces_3_region_extra_1[1 : 0])) || (|piece_buffer_pieces_3_region_extra_2[1 : 0])) || (|piece_buffer_pieces_3_region_extra_3[1 : 0])));
  assign piece_buffer_pieces_0_region_0 = piece_buffer_pieces_0_region_extra_0[11 : 2];
  assign piece_buffer_pieces_0_region_1 = piece_buffer_pieces_0_region_extra_1[11 : 2];
  assign piece_buffer_pieces_0_region_2 = piece_buffer_pieces_0_region_extra_2[11 : 2];
  assign piece_buffer_pieces_0_region_3 = piece_buffer_pieces_0_region_extra_3[11 : 2];
  assign piece_buffer_pieces_1_region_0 = piece_buffer_pieces_1_region_extra_0[11 : 2];
  assign piece_buffer_pieces_1_region_1 = piece_buffer_pieces_1_region_extra_1[11 : 2];
  assign piece_buffer_pieces_1_region_2 = piece_buffer_pieces_1_region_extra_2[11 : 2];
  assign piece_buffer_pieces_1_region_3 = piece_buffer_pieces_1_region_extra_3[11 : 2];
  assign piece_buffer_pieces_2_region_0 = piece_buffer_pieces_2_region_extra_0[11 : 2];
  assign piece_buffer_pieces_2_region_1 = piece_buffer_pieces_2_region_extra_1[11 : 2];
  assign piece_buffer_pieces_2_region_2 = piece_buffer_pieces_2_region_extra_2[11 : 2];
  assign piece_buffer_pieces_2_region_3 = piece_buffer_pieces_2_region_extra_3[11 : 2];
  assign piece_buffer_pieces_3_region_0 = piece_buffer_pieces_3_region_extra_0[11 : 2];
  assign piece_buffer_pieces_3_region_1 = piece_buffer_pieces_3_region_extra_1[11 : 2];
  assign piece_buffer_pieces_3_region_2 = piece_buffer_pieces_3_region_extra_2[11 : 2];
  assign piece_buffer_pieces_3_region_3 = piece_buffer_pieces_3_region_extra_3[11 : 2];
  assign checker_read_req = 1'b0;
  assign checker_restore = 1'b0;
  assign checker_overflowIfLeft = (((checker_region_0[9] || checker_region_1[9]) || checker_region_2[9]) || checker_region_3[9]);
  assign checker_overflowIfRight = (((checker_region_0[0] || checker_region_1[0]) || checker_region_2[0]) || checker_region_3[0]);
  assign checker_overflowIfDown = ((((checker_row == 5'h15) || ((checker_row == 5'h14) && (|checker_region_1))) || ((checker_row == 5'h13) && (|checker_region_2))) || ((checker_row == 5'h12) && (|checker_region_3)));
  assign playfield_reset = 1'b0;
  assign playfield_access_row_base = 5'h0;
  assign playfield_read_req_port_valid = 1'b0;
  assign playfield_read_req_port_payload = 5'h0;
  assign playfield_write_req_port_valid = 1'b0;
  assign playfield_write_req_port_payload = 5'h0;
  always @(*) begin
    playfield_row_sel = 22'h0;
    case(playfield_addr_access_port_payload)
      5'h0 : begin
        playfield_row_sel[0] = 1'b1;
      end
      5'h01 : begin
        playfield_row_sel[1] = 1'b1;
      end
      5'h02 : begin
        playfield_row_sel[2] = 1'b1;
      end
      5'h03 : begin
        playfield_row_sel[3] = 1'b1;
      end
      5'h04 : begin
        playfield_row_sel[4] = 1'b1;
      end
      5'h05 : begin
        playfield_row_sel[5] = 1'b1;
      end
      5'h06 : begin
        playfield_row_sel[6] = 1'b1;
      end
      5'h07 : begin
        playfield_row_sel[7] = 1'b1;
      end
      5'h08 : begin
        playfield_row_sel[8] = 1'b1;
      end
      5'h09 : begin
        playfield_row_sel[9] = 1'b1;
      end
      5'h0a : begin
        playfield_row_sel[10] = 1'b1;
      end
      5'h0b : begin
        playfield_row_sel[11] = 1'b1;
      end
      5'h0c : begin
        playfield_row_sel[12] = 1'b1;
      end
      5'h0d : begin
        playfield_row_sel[13] = 1'b1;
      end
      5'h0e : begin
        playfield_row_sel[14] = 1'b1;
      end
      5'h0f : begin
        playfield_row_sel[15] = 1'b1;
      end
      5'h10 : begin
        playfield_row_sel[16] = 1'b1;
      end
      5'h11 : begin
        playfield_row_sel[17] = 1'b1;
      end
      5'h12 : begin
        playfield_row_sel[18] = 1'b1;
      end
      5'h13 : begin
        playfield_row_sel[19] = 1'b1;
      end
      5'h14 : begin
        playfield_row_sel[20] = 1'b1;
      end
      5'h15 : begin
        playfield_row_sel[21] = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign playfield_address_beyond_limit = (5'h15 < playfield_addr_access_port_payload);
  assign temp_playfield_region_0 = 220'h0;
  assign temp_playfield_count = 5'h0;
  assign temp_playfield_count_1 = 5'h01;
  assign temp_playfield_count_2 = 5'h01;
  assign temp_playfield_count_3 = 5'h02;
  assign temp_playfield_count_4 = 5'h01;
  assign temp_playfield_count_5 = 5'h02;
  assign temp_playfield_count_6 = 5'h02;
  assign temp_playfield_count_7 = 5'h03;
  assign playfield_isRowFull = (|playfield_ones);
  assign playfield_lowestOne = (playfield_ones & (~ temp_playfield_lowestOne));
  assign playfield_rows_to_clear = (playfield_lowestOne - 22'h000001);
  assign score_val_valid = (playfield_lock_score_1d || ((! game_restart) && game_restart_regNext));
  assign score_val_payload = playfield_total_score;
  assign flow_read_req = 1'b0;
  always @(*) begin
    flow_row_occuppied[0] = (|flow_region_0);
    flow_row_occuppied[1] = (|flow_region_1);
    flow_row_occuppied[2] = (|flow_region_2);
    flow_row_occuppied[3] = (|flow_region_3);
  end

  assign collision_checker_is_collision_valid = ((! collision_checker_collision_bits_valid) && collision_checker_collision_bits_valid_regNext);
  assign collision_checker_is_collision_payload = collision_checker_check_status;
  assign src_0_valid = playfield_dataout_stage_valid;
  assign src_0_payload = playfield_dataout_stage_payload;
  assign row_val_valid = (src_0_valid && output_en);
  always @(*) begin
    row_val_payload = src_0_payload;
    if((src_0_valid && src_1_valid)) begin
      row_val_payload = row_merged;
    end
  end

  assign row_merged = (src_0_payload | src_1_payload);
  assign row_out_done = ((! src_0_valid) && src_0_valid_regNext);
  assign locker_readout = locker_region_spinal_port1;
  assign locker_readou_is_done = ((! locker_addr_access_port_valid) && locker_addr_access_port_valid_regNext);
  assign dma_playfield_dma_counter_is_last = (dma_playfield_dma_req_counter == dma_playfield_dma_word_count);
  assign dma_playfield_dma_trig = (dma_playfield_dma_start && (! dma_playfield_dma_start_regNext));
  assign playfield_addr_access_port_valid = dma_playfield_dma_req_valid;
  assign playfield_addr_access_port_payload = (dma_playfield_dma_req_counter + dma_playfield_dma_base_addr);
  assign dma_playfield_dma_channel_0_data_in_valid = dma_playfield_dma_channel_0_valid;
  assign dma_playfield_dma_channel_0_data_in_payload = dma_playfield_dma_channel_0_payload;
  assign dma_playfield_dma_channel_0_data_inter_valid = (dma_playfield_dma_channel_0_data_in_valid && dma_playfield_dma_channel_0_enable);
  assign dma_playfield_dma_channel_0_data_inter_payload = dma_playfield_dma_channel_0_data_in_payload;
  assign dma_playfield_dma_channel_0_data_out_valid = dma_playfield_dma_channel_0_data_inter_valid;
  assign dma_playfield_dma_channel_0_data_out_payload = dma_playfield_dma_channel_0_data_inter_payload;
  assign dma_playfield_dma_channel_1_data_in_valid = dma_playfield_dma_channel_1_valid;
  assign dma_playfield_dma_channel_1_data_in_payload = dma_playfield_dma_channel_1_payload;
  assign dma_playfield_dma_channel_1_data_inter_valid = (dma_playfield_dma_channel_1_data_in_valid && dma_playfield_dma_channel_1_enable);
  assign dma_playfield_dma_channel_1_data_inter_payload = dma_playfield_dma_channel_1_data_in_payload;
  assign dma_playfield_dma_channel_1_data_out_valid = dma_playfield_dma_channel_1_data_inter_valid;
  assign dma_playfield_dma_channel_1_data_out_payload = dma_playfield_dma_channel_1_data_inter_payload;
  assign dma_playfield_dma_channel_2_data_in_valid = dma_playfield_dma_channel_2_valid;
  assign dma_playfield_dma_channel_2_data_in_payload = dma_playfield_dma_channel_2_payload;
  assign dma_playfield_dma_channel_2_data_inter_valid = (dma_playfield_dma_channel_2_data_in_valid && dma_playfield_dma_channel_2_enable);
  assign dma_playfield_dma_channel_2_data_inter_payload = dma_playfield_dma_channel_2_data_in_payload;
  assign dma_playfield_dma_channel_2_data_out_valid = dma_playfield_dma_channel_2_data_inter_valid;
  assign dma_playfield_dma_channel_2_data_out_payload = dma_playfield_dma_channel_2_data_inter_payload;
  assign dma_playfield_dma_channel_0_valid = dma_playfield_dma_req_valid_1d;
  assign dma_playfield_dma_channel_0_payload = dma_playfield_dma_source_0;
  assign dma_playfield_dma_sink_0_valid = dma_playfield_dma_channel_0_data_out_valid;
  assign dma_playfield_dma_sink_0_payload = dma_playfield_dma_channel_0_data_out_payload;
  assign dma_playfield_dma_channel_1_valid = dma_playfield_dma_req_valid_1d;
  assign dma_playfield_dma_channel_1_payload = dma_playfield_dma_source_0;
  assign dma_playfield_dma_sink_1_valid = dma_playfield_dma_channel_1_data_out_valid;
  assign dma_playfield_dma_sink_1_payload = dma_playfield_dma_channel_1_data_out_payload;
  assign dma_playfield_dma_channel_2_valid = dma_playfield_dma_req_valid;
  assign dma_playfield_dma_channel_2_payload = dma_playfield_dma_source_1;
  assign dma_playfield_dma_sink_2_valid = dma_playfield_dma_channel_2_data_out_valid;
  assign dma_playfield_dma_sink_2_payload = dma_playfield_dma_channel_2_data_out_payload;
  assign dma_playfield_dma_source_0 = playfield_readout;
  assign dma_playfield_dma_source_1 = src_2_payload;
  assign collision_checker_src_0_valid = dma_playfield_dma_sink_0_valid;
  assign collision_checker_src_0_payload = dma_playfield_dma_sink_0_payload;
  assign playfield_dataout_valid = dma_playfield_dma_sink_1_valid;
  assign playfield_dataout_payload = dma_playfield_dma_sink_1_payload;
  assign playfield_write_in_port_valid = dma_playfield_dma_sink_2_valid;
  assign playfield_write_in_port_payload = dma_playfield_dma_sink_2_payload;
  assign dma_checker_dma_base_addr = 2'b00;
  assign dma_checker_dma_word_count = 2'b11;
  assign dma_checker_dma_counter_is_last = (dma_checker_dma_req_counter == dma_checker_dma_word_count);
  assign dma_checker_dma_trig = (dma_checker_dma_start && (! dma_checker_dma_start_regNext));
  assign checker_addr_access_port_valid = dma_checker_dma_req_valid;
  assign checker_addr_access_port_payload = (dma_checker_dma_req_counter + dma_checker_dma_base_addr);
  assign dma_checker_dma_channel_0_data_in_valid = dma_checker_dma_channel_0_valid;
  assign dma_checker_dma_channel_0_data_in_payload = dma_checker_dma_channel_0_payload;
  assign dma_checker_dma_channel_0_data_inter_valid = (dma_checker_dma_channel_0_data_in_valid && dma_checker_dma_channel_0_enable);
  assign dma_checker_dma_channel_0_data_inter_payload = dma_checker_dma_channel_0_data_in_payload;
  assign dma_checker_dma_channel_0_data_out_valid = dma_checker_dma_channel_0_data_inter_valid;
  assign dma_checker_dma_channel_0_data_out_payload = dma_checker_dma_channel_0_data_inter_payload;
  assign dma_checker_dma_channel_0_valid = dma_checker_dma_req_valid_1d;
  assign dma_checker_dma_channel_0_payload = dma_checker_dma_source_0;
  assign dma_checker_dma_sink_0_valid = dma_checker_dma_channel_0_data_out_valid;
  assign dma_checker_dma_sink_0_payload = dma_checker_dma_channel_0_data_out_payload;
  assign dma_checker_dma_source_0 = checker_readout;
  assign collision_checker_src_1_valid = dma_checker_dma_sink_0_valid;
  assign collision_checker_src_1_payload = dma_checker_dma_sink_0_payload;
  assign dma_flow_dma_base_addr = 2'b00;
  assign dma_flow_dma_word_count = 2'b11;
  assign dma_flow_dma_counter_is_last = (dma_flow_dma_req_counter == dma_flow_dma_word_count);
  assign dma_flow_dma_trig = (dma_flow_dma_start && (! dma_flow_dma_start_regNext));
  assign flow_addr_access_port_valid = dma_flow_dma_req_valid;
  assign flow_addr_access_port_payload = (dma_flow_dma_req_counter + dma_flow_dma_base_addr);
  assign dma_flow_dma_channel_0_data_in_valid = dma_flow_dma_channel_0_valid;
  assign dma_flow_dma_channel_0_data_in_payload = dma_flow_dma_channel_0_payload;
  assign dma_flow_dma_channel_0_data_inter_valid = (dma_flow_dma_channel_0_data_in_valid && dma_flow_dma_channel_0_enable);
  assign dma_flow_dma_channel_0_data_inter_payload = dma_flow_dma_channel_0_data_in_payload;
  assign dma_flow_dma_channel_0_data_out_valid = dma_flow_dma_channel_0_data_inter_valid;
  assign dma_flow_dma_channel_0_data_out_payload = dma_flow_dma_channel_0_data_inter_payload;
  assign dma_flow_dma_channel_0_valid = dma_flow_dma_req_valid_1d;
  assign dma_flow_dma_channel_0_payload = dma_flow_dma_source_0;
  assign dma_flow_dma_sink_0_valid = dma_flow_dma_channel_0_data_out_valid;
  assign dma_flow_dma_sink_0_payload = dma_flow_dma_channel_0_data_out_payload;
  assign dma_flow_dma_source_0 = flow_readout;
  assign src_1_valid = dma_flow_dma_sink_0_valid;
  assign src_1_payload = dma_flow_dma_sink_0_payload;
  assign dma_locker_dma_base_addr = 2'b00;
  assign dma_locker_dma_word_count = 2'b11;
  assign dma_locker_dma_counter_is_last = (dma_locker_dma_req_counter == dma_locker_dma_word_count);
  assign dma_locker_dma_trig = (dma_locker_dma_start && (! dma_locker_dma_start_regNext));
  assign locker_addr_access_port_valid = dma_locker_dma_req_valid;
  assign locker_addr_access_port_payload = (dma_locker_dma_req_counter + dma_locker_dma_base_addr);
  assign dma_locker_dma_channel_0_data_in_valid = dma_locker_dma_channel_0_valid;
  assign dma_locker_dma_channel_0_data_in_payload = dma_locker_dma_channel_0_payload;
  assign dma_locker_dma_channel_0_data_inter_valid = (dma_locker_dma_channel_0_data_in_valid && dma_locker_dma_channel_0_enable);
  assign dma_locker_dma_channel_0_data_inter_payload = dma_locker_dma_channel_0_data_in_payload;
  assign dma_locker_dma_channel_0_data_out_valid = dma_locker_dma_channel_0_data_inter_valid;
  assign dma_locker_dma_channel_0_data_out_payload = dma_locker_dma_channel_0_data_inter_payload;
  assign dma_locker_dma_channel_1_data_in_valid = dma_locker_dma_channel_1_valid;
  assign dma_locker_dma_channel_1_data_in_payload = dma_locker_dma_channel_1_payload;
  assign dma_locker_dma_channel_1_data_inter_valid = (dma_locker_dma_channel_1_data_in_valid && dma_locker_dma_channel_1_enable);
  assign dma_locker_dma_channel_1_data_inter_payload = dma_locker_dma_channel_1_data_in_payload;
  assign dma_locker_dma_channel_1_data_out_valid = dma_locker_dma_channel_1_data_inter_valid;
  assign dma_locker_dma_channel_1_data_out_payload = dma_locker_dma_channel_1_data_inter_payload;
  assign dma_locker_dma_channel_0_valid = dma_locker_dma_req_valid;
  assign dma_locker_dma_channel_0_payload = dma_locker_dma_source_0;
  assign dma_locker_dma_sink_0_valid = dma_locker_dma_channel_0_data_out_valid;
  assign dma_locker_dma_sink_0_payload = dma_locker_dma_channel_0_data_out_payload;
  assign dma_locker_dma_channel_1_valid = dma_locker_dma_req_valid_1d;
  assign dma_locker_dma_channel_1_payload = dma_locker_dma_source_1;
  assign dma_locker_dma_sink_1_valid = dma_locker_dma_channel_1_data_out_valid;
  assign dma_locker_dma_sink_1_payload = dma_locker_dma_channel_1_data_out_payload;
  assign dma_locker_dma_source_0 = row_merged;
  assign dma_locker_dma_source_1 = locker_readout;
  assign locker_data_in_port_valid = dma_locker_dma_sink_0_valid;
  assign locker_data_in_port_payload = dma_locker_dma_sink_0_payload;
  assign src_2_valid = dma_locker_dma_sink_1_valid;
  assign src_2_payload = dma_locker_dma_sink_1_payload;
  assign main_fsm_wantExit = 1'b0;
  assign main_fsm_wantKill = 1'b0;
  assign motion_is_allowed = (main_fsm_stateReg == main_fsm_WAIT_CONTROL);
  assign fsm_is_idle = (main_fsm_stateReg == main_fsm_IDLE);
  assign temp_flow_region_0 = 40'h0;
  assign main_fsm_onExit_READOUT = ((main_fsm_stateNext != main_fsm_READOUT) && (main_fsm_stateReg == main_fsm_READOUT));
  assign main_fsm_onExit_COLLISION_CHECK = ((main_fsm_stateNext != main_fsm_COLLISION_CHECK) && (main_fsm_stateReg == main_fsm_COLLISION_CHECK));
  assign main_fsm_onExit_PASS = ((main_fsm_stateNext != main_fsm_PASS) && (main_fsm_stateReg == main_fsm_PASS));
  assign main_fsm_onExit_WAIT_LOCKER_WRITE_DONE = ((main_fsm_stateNext != main_fsm_WAIT_LOCKER_WRITE_DONE) && (main_fsm_stateReg == main_fsm_WAIT_LOCKER_WRITE_DONE));
  assign main_fsm_onExit_WAIT_LOCKER_READ_DONE = ((main_fsm_stateNext != main_fsm_WAIT_LOCKER_READ_DONE) && (main_fsm_stateReg == main_fsm_WAIT_LOCKER_READ_DONE));
  assign main_fsm_onEntry_READOUT = ((main_fsm_stateNext == main_fsm_READOUT) && (main_fsm_stateReg != main_fsm_READOUT));
  assign main_fsm_onEntry_COLLISION_CHECK = ((main_fsm_stateNext == main_fsm_COLLISION_CHECK) && (main_fsm_stateReg != main_fsm_COLLISION_CHECK));
  assign main_fsm_onEntry_PASS = ((main_fsm_stateNext == main_fsm_PASS) && (main_fsm_stateReg != main_fsm_PASS));
  assign main_fsm_onEntry_LOCKER_WRITE_0 = ((main_fsm_stateNext == main_fsm_LOCKER_WRITE_0) && (main_fsm_stateReg != main_fsm_LOCKER_WRITE_0));
  assign main_fsm_onEntry_LOCKER_READ = ((main_fsm_stateNext == main_fsm_LOCKER_READ) && (main_fsm_stateReg != main_fsm_LOCKER_READ));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      piece_valid <= 1'b0;
      action_1 <= ACTION_NO;
      piece_buffer_rot_cur <= 2'b00;
      piece_buffer_rot_backup <= 2'b00;
      checker_row <= 5'h0;
      checker_row_backup <= 5'h0;
      playfield_region_0 <= 10'h0;
      playfield_region_1 <= 10'h0;
      playfield_region_2 <= 10'h0;
      playfield_region_3 <= 10'h0;
      playfield_region_4 <= 10'h0;
      playfield_region_5 <= 10'h0;
      playfield_region_6 <= 10'h0;
      playfield_region_7 <= 10'h0;
      playfield_region_8 <= 10'h0;
      playfield_region_9 <= 10'h0;
      playfield_region_10 <= 10'h0;
      playfield_region_11 <= 10'h0;
      playfield_region_12 <= 10'h0;
      playfield_region_13 <= 10'h0;
      playfield_region_14 <= 10'h0;
      playfield_region_15 <= 10'h0;
      playfield_region_16 <= 10'h0;
      playfield_region_17 <= 10'h0;
      playfield_region_18 <= 10'h0;
      playfield_region_19 <= 10'h0;
      playfield_region_20 <= 10'h0;
      playfield_region_21 <= 10'h0;
      playfield_ones <= 22'h0;
      playfield_count <= 5'h0;
      playfield_total_score <= 10'h0;
      playfield_update_score_delay_1 <= 1'b0;
      playfield_lock_score <= 1'b0;
      playfield_lock_score_1d <= 1'b0;
      flow_row <= 5'h0;
      flow_region_0 <= 10'h0;
      flow_region_1 <= 10'h0;
      flow_region_2 <= 10'h0;
      flow_region_3 <= 10'h0;
      collision_checker_collision_bits_valid <= 1'b0;
      collision_checker_check_status <= 1'b0;
      collision_checker_collision_bits_valid_regNext <= 1'b0;
      playfield_dataout_stage_valid <= 1'b0;
      src_0_valid_regNext <= 1'b0;
      locker_addr_access_port_valid_regNext <= 1'b0;
      dma_playfield_dma_base_addr <= 5'h0;
      dma_playfield_dma_word_count <= 5'h03;
      dma_playfield_dma_req_counter <= 5'h0;
      dma_playfield_dma_start_regNext <= 1'b0;
      dma_playfield_dma_req_valid <= 1'b0;
      dma_playfield_dma_req_valid_regNext <= 1'b0;
      dma_playfield_dma_req_valid_1d <= 1'b0;
      dma_playfield_dma_channel_0_enable <= 1'b0;
      dma_playfield_dma_channel_1_enable <= 1'b0;
      dma_playfield_dma_channel_2_enable <= 1'b0;
      dma_checker_dma_req_counter <= 2'b00;
      dma_checker_dma_start_regNext <= 1'b0;
      dma_checker_dma_req_valid <= 1'b0;
      dma_checker_dma_req_valid_regNext <= 1'b0;
      dma_checker_dma_req_valid_1d <= 1'b0;
      dma_checker_dma_channel_0_enable <= 1'b0;
      dma_flow_dma_req_counter <= 2'b00;
      dma_flow_dma_start_regNext <= 1'b0;
      dma_flow_dma_req_valid <= 1'b0;
      dma_flow_dma_req_valid_regNext <= 1'b0;
      dma_flow_dma_req_valid_1d <= 1'b0;
      dma_flow_dma_channel_0_enable <= 1'b0;
      dma_locker_dma_req_counter <= 2'b00;
      dma_locker_dma_start_regNext <= 1'b0;
      dma_locker_dma_req_valid <= 1'b0;
      dma_locker_dma_req_valid_regNext <= 1'b0;
      dma_locker_dma_req_valid_1d <= 1'b0;
      dma_locker_dma_channel_0_enable <= 1'b0;
      dma_locker_dma_channel_1_enable <= 1'b0;
      main_fsm_will_goto_idle <= 1'b0;
      main_fsm_stateReg <= main_fsm_IDLE;
    end else begin
      piece_valid <= piece_in_valid;
      if(!playfield_address_beyond_limit) begin
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[0]) begin
            playfield_region_0 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[1]) begin
            playfield_region_1 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[2]) begin
            playfield_region_2 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[3]) begin
            playfield_region_3 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[4]) begin
            playfield_region_4 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[5]) begin
            playfield_region_5 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[6]) begin
            playfield_region_6 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[7]) begin
            playfield_region_7 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[8]) begin
            playfield_region_8 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[9]) begin
            playfield_region_9 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[10]) begin
            playfield_region_10 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[11]) begin
            playfield_region_11 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[12]) begin
            playfield_region_12 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[13]) begin
            playfield_region_13 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[14]) begin
            playfield_region_14 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[15]) begin
            playfield_region_15 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[16]) begin
            playfield_region_16 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[17]) begin
            playfield_region_17 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[18]) begin
            playfield_region_18 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[19]) begin
            playfield_region_19 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[20]) begin
            playfield_region_20 <= playfield_write_in_port_payload;
          end
        end
        if(playfield_write_in_port_valid) begin
          if(playfield_row_sel[21]) begin
            playfield_region_21 <= playfield_write_in_port_payload;
          end
        end
      end
      if(game_restart) begin
        playfield_region_0 <= temp_playfield_region_0[9 : 0];
        playfield_region_1 <= temp_playfield_region_0[19 : 10];
        playfield_region_2 <= temp_playfield_region_0[29 : 20];
        playfield_region_3 <= temp_playfield_region_0[39 : 30];
        playfield_region_4 <= temp_playfield_region_0[49 : 40];
        playfield_region_5 <= temp_playfield_region_0[59 : 50];
        playfield_region_6 <= temp_playfield_region_0[69 : 60];
        playfield_region_7 <= temp_playfield_region_0[79 : 70];
        playfield_region_8 <= temp_playfield_region_0[89 : 80];
        playfield_region_9 <= temp_playfield_region_0[99 : 90];
        playfield_region_10 <= temp_playfield_region_0[109 : 100];
        playfield_region_11 <= temp_playfield_region_0[119 : 110];
        playfield_region_12 <= temp_playfield_region_0[129 : 120];
        playfield_region_13 <= temp_playfield_region_0[139 : 130];
        playfield_region_14 <= temp_playfield_region_0[149 : 140];
        playfield_region_15 <= temp_playfield_region_0[159 : 150];
        playfield_region_16 <= temp_playfield_region_0[169 : 160];
        playfield_region_17 <= temp_playfield_region_0[179 : 170];
        playfield_region_18 <= temp_playfield_region_0[189 : 180];
        playfield_region_19 <= temp_playfield_region_0[199 : 190];
        playfield_region_20 <= temp_playfield_region_0[209 : 200];
        playfield_region_21 <= temp_playfield_region_0[219 : 210];
      end
      playfield_ones[0] <= (&playfield_region_0);
      playfield_ones[1] <= (&playfield_region_1);
      playfield_ones[2] <= (&playfield_region_2);
      playfield_ones[3] <= (&playfield_region_3);
      playfield_ones[4] <= (&playfield_region_4);
      playfield_ones[5] <= (&playfield_region_5);
      playfield_ones[6] <= (&playfield_region_6);
      playfield_ones[7] <= (&playfield_region_7);
      playfield_ones[8] <= (&playfield_region_8);
      playfield_ones[9] <= (&playfield_region_9);
      playfield_ones[10] <= (&playfield_region_10);
      playfield_ones[11] <= (&playfield_region_11);
      playfield_ones[12] <= (&playfield_region_12);
      playfield_ones[13] <= (&playfield_region_13);
      playfield_ones[14] <= (&playfield_region_14);
      playfield_ones[15] <= (&playfield_region_15);
      playfield_ones[16] <= (&playfield_region_16);
      playfield_ones[17] <= (&playfield_region_17);
      playfield_ones[18] <= (&playfield_region_18);
      playfield_ones[19] <= (&playfield_region_19);
      playfield_ones[20] <= (&playfield_region_20);
      playfield_ones[21] <= (&playfield_region_21);
      playfield_count <= (temp_playfield_count_8 + temp_playfield_count_19);
      if((playfield_clear && playfield_rows_to_clear[0])) begin
        playfield_region_1 <= playfield_region_0;
      end
      if((playfield_clear && playfield_rows_to_clear[1])) begin
        playfield_region_2 <= playfield_region_1;
      end
      if((playfield_clear && playfield_rows_to_clear[2])) begin
        playfield_region_3 <= playfield_region_2;
      end
      if((playfield_clear && playfield_rows_to_clear[3])) begin
        playfield_region_4 <= playfield_region_3;
      end
      if((playfield_clear && playfield_rows_to_clear[4])) begin
        playfield_region_5 <= playfield_region_4;
      end
      if((playfield_clear && playfield_rows_to_clear[5])) begin
        playfield_region_6 <= playfield_region_5;
      end
      if((playfield_clear && playfield_rows_to_clear[6])) begin
        playfield_region_7 <= playfield_region_6;
      end
      if((playfield_clear && playfield_rows_to_clear[7])) begin
        playfield_region_8 <= playfield_region_7;
      end
      if((playfield_clear && playfield_rows_to_clear[8])) begin
        playfield_region_9 <= playfield_region_8;
      end
      if((playfield_clear && playfield_rows_to_clear[9])) begin
        playfield_region_10 <= playfield_region_9;
      end
      if((playfield_clear && playfield_rows_to_clear[10])) begin
        playfield_region_11 <= playfield_region_10;
      end
      if((playfield_clear && playfield_rows_to_clear[11])) begin
        playfield_region_12 <= playfield_region_11;
      end
      if((playfield_clear && playfield_rows_to_clear[12])) begin
        playfield_region_13 <= playfield_region_12;
      end
      if((playfield_clear && playfield_rows_to_clear[13])) begin
        playfield_region_14 <= playfield_region_13;
      end
      if((playfield_clear && playfield_rows_to_clear[14])) begin
        playfield_region_15 <= playfield_region_14;
      end
      if((playfield_clear && playfield_rows_to_clear[15])) begin
        playfield_region_16 <= playfield_region_15;
      end
      if((playfield_clear && playfield_rows_to_clear[16])) begin
        playfield_region_17 <= playfield_region_16;
      end
      if((playfield_clear && playfield_rows_to_clear[17])) begin
        playfield_region_18 <= playfield_region_17;
      end
      if((playfield_clear && playfield_rows_to_clear[18])) begin
        playfield_region_19 <= playfield_region_18;
      end
      if((playfield_clear && playfield_rows_to_clear[19])) begin
        playfield_region_20 <= playfield_region_19;
      end
      if((playfield_clear && playfield_rows_to_clear[20])) begin
        playfield_region_21 <= playfield_region_20;
      end
      if(playfield_clear) begin
        playfield_region_0 <= 10'h0;
      end
      playfield_update_score_delay_1 <= playfield_update_score;
      playfield_lock_score <= playfield_update_score_delay_1;
      playfield_lock_score_1d <= playfield_lock_score;
      if(game_restart) begin
        playfield_total_score <= 10'h0;
      end else begin
        if(playfield_lock_score) begin
          playfield_total_score <= (playfield_total_score + temp_playfield_total_score);
        end
      end
      if(flow_update) begin
        flow_region_0 <= checker_region_0;
        flow_region_1 <= checker_region_1;
        flow_region_2 <= checker_region_2;
        flow_region_3 <= checker_region_3;
        flow_row <= checker_row;
      end
      collision_checker_collision_bits_valid <= collision_checker_src_0_valid;
      if((collision_checker_collision_bits_valid && collision_checker_collision_bits_payload)) begin
        collision_checker_check_status <= 1'b1;
      end
      if(collision_checker_start) begin
        collision_checker_check_status <= 1'b0;
      end
      collision_checker_collision_bits_valid_regNext <= collision_checker_collision_bits_valid;
      playfield_dataout_stage_valid <= playfield_dataout_valid;
      src_0_valid_regNext <= src_0_valid;
      locker_addr_access_port_valid_regNext <= locker_addr_access_port_valid;
      dma_playfield_dma_start_regNext <= dma_playfield_dma_start;
      if(dma_playfield_dma_counter_is_last) begin
        dma_playfield_dma_req_valid <= 1'b0;
      end
      if(dma_playfield_dma_trig) begin
        dma_playfield_dma_req_valid <= 1'b1;
      end
      if(dma_playfield_dma_req_valid) begin
        dma_playfield_dma_req_counter <= (dma_playfield_dma_req_counter + 5'h01);
      end else begin
        if(((! dma_playfield_dma_req_valid) && dma_playfield_dma_req_valid_regNext)) begin
          dma_playfield_dma_req_counter <= 5'h0;
        end
      end
      dma_playfield_dma_req_valid_regNext <= dma_playfield_dma_req_valid;
      dma_playfield_dma_req_valid_1d <= dma_playfield_dma_req_valid;
      dma_checker_dma_start_regNext <= dma_checker_dma_start;
      if(dma_checker_dma_counter_is_last) begin
        dma_checker_dma_req_valid <= 1'b0;
      end
      if(dma_checker_dma_trig) begin
        dma_checker_dma_req_valid <= 1'b1;
      end
      if(dma_checker_dma_req_valid) begin
        dma_checker_dma_req_counter <= (dma_checker_dma_req_counter + 2'b01);
      end else begin
        if(((! dma_checker_dma_req_valid) && dma_checker_dma_req_valid_regNext)) begin
          dma_checker_dma_req_counter <= 2'b00;
        end
      end
      dma_checker_dma_req_valid_regNext <= dma_checker_dma_req_valid;
      dma_checker_dma_req_valid_1d <= dma_checker_dma_req_valid;
      dma_flow_dma_start_regNext <= dma_flow_dma_start;
      if(dma_flow_dma_counter_is_last) begin
        dma_flow_dma_req_valid <= 1'b0;
      end
      if(dma_flow_dma_trig) begin
        dma_flow_dma_req_valid <= 1'b1;
      end
      if(dma_flow_dma_req_valid) begin
        dma_flow_dma_req_counter <= (dma_flow_dma_req_counter + 2'b01);
      end else begin
        if(((! dma_flow_dma_req_valid) && dma_flow_dma_req_valid_regNext)) begin
          dma_flow_dma_req_counter <= 2'b00;
        end
      end
      dma_flow_dma_req_valid_regNext <= dma_flow_dma_req_valid;
      dma_flow_dma_req_valid_1d <= dma_flow_dma_req_valid;
      dma_locker_dma_start_regNext <= dma_locker_dma_start;
      if(dma_locker_dma_counter_is_last) begin
        dma_locker_dma_req_valid <= 1'b0;
      end
      if(dma_locker_dma_trig) begin
        dma_locker_dma_req_valid <= 1'b1;
      end
      if(dma_locker_dma_req_valid) begin
        dma_locker_dma_req_counter <= (dma_locker_dma_req_counter + 2'b01);
      end else begin
        if(((! dma_locker_dma_req_valid) && dma_locker_dma_req_valid_regNext)) begin
          dma_locker_dma_req_counter <= 2'b00;
        end
      end
      dma_locker_dma_req_valid_regNext <= dma_locker_dma_req_valid;
      dma_locker_dma_req_valid_1d <= dma_locker_dma_req_valid;
      main_fsm_stateReg <= main_fsm_stateNext;
      case(main_fsm_stateReg)
        main_fsm_READOUT : begin
        end
        main_fsm_LOAD_TO_CHECKER : begin
        end
        main_fsm_COLLISION_CHECK : begin
        end
        main_fsm_REPORT_COLLISION : begin
          if(!temp_when) begin
            if((action_1 == ACTION_ROTATE)) begin
              piece_buffer_rot_cur <= piece_buffer_rot_backup;
            end
          end
        end
        main_fsm_END_OF_COLLISION : begin
          action_1 <= ACTION_NO;
        end
        main_fsm_PASS : begin
          if(temp_when_1) begin
            checker_row_backup <= checker_row;
          end
          if(temp_when_2) begin
            piece_buffer_rot_backup <= piece_buffer_rot_cur;
          end
        end
        main_fsm_WAIT_CONTROL : begin
          if(move_in_left) begin
            if(!checker_overflowIfLeft) begin
              action_1 <= ACTION_LEFT;
            end
          end
          if(move_in_right) begin
            if(!checker_overflowIfRight) begin
              action_1 <= ACTION_RIGHT;
            end
          end
          if(move_in_down) begin
            if(!checker_overflowIfDown) begin
              checker_row <= (checker_row + 5'h01);
              action_1 <= ACTION_DOWN;
            end
          end
          if(move_in_rotate) begin
            piece_buffer_rot_cur <= (piece_buffer_rot_cur + 2'b01);
          end
        end
        main_fsm_ROTATION : begin
          if(!temp_when_3) begin
            action_1 <= ACTION_ROTATE;
          end
        end
        main_fsm_PRE_CHECK : begin
        end
        main_fsm_LOCKER_WRITE_0 : begin
        end
        main_fsm_LOCKER_WRITE_1 : begin
          dma_locker_dma_channel_0_enable <= 1'b1;
        end
        main_fsm_WAIT_LOCKER_WRITE_DONE : begin
        end
        main_fsm_LOCKER_READ : begin
          dma_playfield_dma_channel_2_enable <= 1'b1;
          dma_playfield_dma_base_addr <= flow_row;
          dma_playfield_dma_word_count <= 5'h03;
        end
        main_fsm_WAIT_LOCKER_READ_DONE : begin
        end
        main_fsm_CLEAR_REGION : begin
          piece_buffer_rot_cur <= 2'b00;
          piece_buffer_rot_backup <= 2'b00;
          flow_region_0 <= temp_flow_region_0[9 : 0];
          flow_region_1 <= temp_flow_region_0[19 : 10];
          flow_region_2 <= temp_flow_region_0[29 : 20];
          flow_region_3 <= temp_flow_region_0[39 : 30];
          flow_row <= 5'h0;
          checker_row <= 5'h0;
          checker_row_backup <= 5'h0;
        end
        main_fsm_CHECK_ROW_FULL : begin
          if(!playfield_isRowFull) begin
            main_fsm_will_goto_idle <= 1'b1;
          end
        end
        main_fsm_ROW_REMOVE : begin
        end
        main_fsm_ROW_REMOVE_DONE : begin
        end
        default : begin
          dma_flow_dma_channel_0_enable <= 1'b1;
          dma_checker_dma_channel_0_enable <= 1'b1;
          main_fsm_will_goto_idle <= 1'b0;
          if(piece_valid) begin
            action_1 <= ACTION_PLACE;
          end
        end
      endcase
      if(main_fsm_onExit_READOUT) begin
        dma_playfield_dma_channel_1_enable <= 1'b0;
      end
      if(main_fsm_onExit_COLLISION_CHECK) begin
        dma_playfield_dma_channel_0_enable <= 1'b0;
      end
      if(main_fsm_onExit_PASS) begin
        action_1 <= ACTION_NO;
      end
      if(main_fsm_onExit_WAIT_LOCKER_WRITE_DONE) begin
        dma_playfield_dma_channel_1_enable <= 1'b0;
        dma_locker_dma_channel_0_enable <= 1'b0;
      end
      if(main_fsm_onExit_WAIT_LOCKER_READ_DONE) begin
        dma_locker_dma_channel_1_enable <= 1'b0;
        dma_playfield_dma_channel_2_enable <= 1'b0;
      end
      if(main_fsm_onEntry_READOUT) begin
        dma_playfield_dma_channel_1_enable <= 1'b1;
        dma_playfield_dma_base_addr <= 5'h0;
        dma_playfield_dma_word_count <= 5'h15;
      end
      if(main_fsm_onEntry_COLLISION_CHECK) begin
        dma_playfield_dma_channel_0_enable <= 1'b1;
        dma_playfield_dma_base_addr <= checker_row;
        dma_playfield_dma_word_count <= 5'h03;
      end
      if(main_fsm_onEntry_LOCKER_WRITE_0) begin
        dma_playfield_dma_channel_1_enable <= 1'b1;
        dma_playfield_dma_base_addr <= flow_row;
        dma_playfield_dma_word_count <= 5'h03;
      end
      if(main_fsm_onEntry_LOCKER_READ) begin
        dma_locker_dma_channel_1_enable <= 1'b1;
      end
    end
  end

  always @(posedge core_clk) begin
    if(piece_in_valid) begin
      piece_payload <= piece_in_payload;
    end
    if(piece_valid) begin
      case(piece_payload)
        TYPE_1_I : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01e0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_1 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0040;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h01e0;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0080;
        end
        TYPE_1_J : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0100;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0040;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_L : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0040;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_2 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0100;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_O : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_3_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_S : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0180;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0100;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        TYPE_1_T : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_0_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h01c0;
          piece_buffer_pieces_2_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
        default : begin
          piece_buffer_pieces_0_region_extra_0 <= 14'h0180;
          piece_buffer_pieces_0_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_0_region_extra_2 <= 14'h0;
          piece_buffer_pieces_0_region_extra_3 <= 14'h0;
          piece_buffer_pieces_1_region_extra_0 <= 14'h0040;
          piece_buffer_pieces_1_region_extra_1 <= 14'h00c0;
          piece_buffer_pieces_1_region_extra_2 <= 14'h0080;
          piece_buffer_pieces_1_region_extra_3 <= 14'h0;
          piece_buffer_pieces_2_region_extra_0 <= 14'h0;
          piece_buffer_pieces_2_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_2_region_extra_2 <= 14'h00c0;
          piece_buffer_pieces_2_region_extra_3 <= 14'h0;
          piece_buffer_pieces_3_region_extra_0 <= 14'h0080;
          piece_buffer_pieces_3_region_extra_1 <= 14'h0180;
          piece_buffer_pieces_3_region_extra_2 <= 14'h0100;
          piece_buffer_pieces_3_region_extra_3 <= 14'h0;
        end
      endcase
    end
    if(piece_buffer_left_shift_all) begin
      piece_buffer_pieces_0_region_extra_0 <= (piece_buffer_pieces_0_region_extra_0 <<< 1);
      piece_buffer_pieces_0_region_extra_1 <= (piece_buffer_pieces_0_region_extra_1 <<< 1);
      piece_buffer_pieces_0_region_extra_2 <= (piece_buffer_pieces_0_region_extra_2 <<< 1);
      piece_buffer_pieces_0_region_extra_3 <= (piece_buffer_pieces_0_region_extra_3 <<< 1);
      piece_buffer_pieces_1_region_extra_0 <= (piece_buffer_pieces_1_region_extra_0 <<< 1);
      piece_buffer_pieces_1_region_extra_1 <= (piece_buffer_pieces_1_region_extra_1 <<< 1);
      piece_buffer_pieces_1_region_extra_2 <= (piece_buffer_pieces_1_region_extra_2 <<< 1);
      piece_buffer_pieces_1_region_extra_3 <= (piece_buffer_pieces_1_region_extra_3 <<< 1);
      piece_buffer_pieces_2_region_extra_0 <= (piece_buffer_pieces_2_region_extra_0 <<< 1);
      piece_buffer_pieces_2_region_extra_1 <= (piece_buffer_pieces_2_region_extra_1 <<< 1);
      piece_buffer_pieces_2_region_extra_2 <= (piece_buffer_pieces_2_region_extra_2 <<< 1);
      piece_buffer_pieces_2_region_extra_3 <= (piece_buffer_pieces_2_region_extra_3 <<< 1);
      piece_buffer_pieces_3_region_extra_0 <= (piece_buffer_pieces_3_region_extra_0 <<< 1);
      piece_buffer_pieces_3_region_extra_1 <= (piece_buffer_pieces_3_region_extra_1 <<< 1);
      piece_buffer_pieces_3_region_extra_2 <= (piece_buffer_pieces_3_region_extra_2 <<< 1);
      piece_buffer_pieces_3_region_extra_3 <= (piece_buffer_pieces_3_region_extra_3 <<< 1);
    end
    if(piece_buffer_right_shift_all) begin
      piece_buffer_pieces_0_region_extra_0 <= (piece_buffer_pieces_0_region_extra_0 >>> 1);
      piece_buffer_pieces_0_region_extra_1 <= (piece_buffer_pieces_0_region_extra_1 >>> 1);
      piece_buffer_pieces_0_region_extra_2 <= (piece_buffer_pieces_0_region_extra_2 >>> 1);
      piece_buffer_pieces_0_region_extra_3 <= (piece_buffer_pieces_0_region_extra_3 >>> 1);
      piece_buffer_pieces_1_region_extra_0 <= (piece_buffer_pieces_1_region_extra_0 >>> 1);
      piece_buffer_pieces_1_region_extra_1 <= (piece_buffer_pieces_1_region_extra_1 >>> 1);
      piece_buffer_pieces_1_region_extra_2 <= (piece_buffer_pieces_1_region_extra_2 >>> 1);
      piece_buffer_pieces_1_region_extra_3 <= (piece_buffer_pieces_1_region_extra_3 >>> 1);
      piece_buffer_pieces_2_region_extra_0 <= (piece_buffer_pieces_2_region_extra_0 >>> 1);
      piece_buffer_pieces_2_region_extra_1 <= (piece_buffer_pieces_2_region_extra_1 >>> 1);
      piece_buffer_pieces_2_region_extra_2 <= (piece_buffer_pieces_2_region_extra_2 >>> 1);
      piece_buffer_pieces_2_region_extra_3 <= (piece_buffer_pieces_2_region_extra_3 >>> 1);
      piece_buffer_pieces_3_region_extra_0 <= (piece_buffer_pieces_3_region_extra_0 >>> 1);
      piece_buffer_pieces_3_region_extra_1 <= (piece_buffer_pieces_3_region_extra_1 >>> 1);
      piece_buffer_pieces_3_region_extra_2 <= (piece_buffer_pieces_3_region_extra_2 >>> 1);
      piece_buffer_pieces_3_region_extra_3 <= (piece_buffer_pieces_3_region_extra_3 >>> 1);
    end
    checker_readout <= temp_checker_readout;
    if(playfield_address_beyond_limit) begin
      playfield_readout <= 10'h3ff;
    end else begin
      if(playfield_row_sel[0]) begin
        playfield_readout <= playfield_region_0;
      end
      if(playfield_row_sel[1]) begin
        playfield_readout <= playfield_region_1;
      end
      if(playfield_row_sel[2]) begin
        playfield_readout <= playfield_region_2;
      end
      if(playfield_row_sel[3]) begin
        playfield_readout <= playfield_region_3;
      end
      if(playfield_row_sel[4]) begin
        playfield_readout <= playfield_region_4;
      end
      if(playfield_row_sel[5]) begin
        playfield_readout <= playfield_region_5;
      end
      if(playfield_row_sel[6]) begin
        playfield_readout <= playfield_region_6;
      end
      if(playfield_row_sel[7]) begin
        playfield_readout <= playfield_region_7;
      end
      if(playfield_row_sel[8]) begin
        playfield_readout <= playfield_region_8;
      end
      if(playfield_row_sel[9]) begin
        playfield_readout <= playfield_region_9;
      end
      if(playfield_row_sel[10]) begin
        playfield_readout <= playfield_region_10;
      end
      if(playfield_row_sel[11]) begin
        playfield_readout <= playfield_region_11;
      end
      if(playfield_row_sel[12]) begin
        playfield_readout <= playfield_region_12;
      end
      if(playfield_row_sel[13]) begin
        playfield_readout <= playfield_region_13;
      end
      if(playfield_row_sel[14]) begin
        playfield_readout <= playfield_region_14;
      end
      if(playfield_row_sel[15]) begin
        playfield_readout <= playfield_region_15;
      end
      if(playfield_row_sel[16]) begin
        playfield_readout <= playfield_region_16;
      end
      if(playfield_row_sel[17]) begin
        playfield_readout <= playfield_region_17;
      end
      if(playfield_row_sel[18]) begin
        playfield_readout <= playfield_region_18;
      end
      if(playfield_row_sel[19]) begin
        playfield_readout <= playfield_region_19;
      end
      if(playfield_row_sel[20]) begin
        playfield_readout <= playfield_region_20;
      end
      if(playfield_row_sel[21]) begin
        playfield_readout <= playfield_region_21;
      end
    end
    game_restart_regNext <= game_restart;
    flow_readout <= temp_flow_readout;
    collision_checker_collision_bits_payload <= (|(collision_checker_src_0_payload & collision_checker_src_1_payload));
    playfield_dataout_stage_payload <= playfield_dataout_payload;
    if(load_piece) begin
      checker_region_0 <= temp_checker_region_0;
    end
    if(checker_right_shift) begin
      checker_region_0 <= (checker_region_0 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_0 <= (checker_region_0 <<< 1);
    end
    if(checker_restore) begin
      checker_region_0 <= flow_region_0;
    end
    if(load_piece) begin
      checker_region_1 <= temp_checker_region_1;
    end
    if(checker_right_shift) begin
      checker_region_1 <= (checker_region_1 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_1 <= (checker_region_1 <<< 1);
    end
    if(checker_restore) begin
      checker_region_1 <= flow_region_1;
    end
    if(load_piece) begin
      checker_region_2 <= temp_checker_region_2;
    end
    if(checker_right_shift) begin
      checker_region_2 <= (checker_region_2 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_2 <= (checker_region_2 <<< 1);
    end
    if(checker_restore) begin
      checker_region_2 <= flow_region_2;
    end
    if(load_piece) begin
      checker_region_3 <= temp_checker_region_3;
    end
    if(checker_right_shift) begin
      checker_region_3 <= (checker_region_3 >>> 1);
    end
    if(checker_left_shift) begin
      checker_region_3 <= (checker_region_3 <<< 1);
    end
    if(checker_restore) begin
      checker_region_3 <= flow_region_3;
    end
  end


endmodule

module seven_bag_rng (
  input  wire          io_enable,
  output reg           io_shape_valid,
  output wire [2:0]    io_shape_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam fsm_IDLE = 3'd0;
  localparam fsm_CHECK = 3'd1;
  localparam fsm_OUTPUT_1 = 3'd2;
  localparam fsm_DONE = 3'd3;
  localparam fsm_SHIFT = 3'd4;
  localparam fsm_ELEMENT = 3'd5;

  reg        [5:0]    lfsr;
  reg        [2:0]    generatedNumbers_0;
  reg        [2:0]    generatedNumbers_1;
  reg        [2:0]    generatedNumbers_2;
  reg        [2:0]    generatedNumbers_3;
  reg        [2:0]    generatedNumbers_4;
  reg        [2:0]    generatedNumbers_5;
  reg        [2:0]    generatedNumbers_6;
  reg        [2:0]    generatedNumbers_7;
  reg        [2:0]    count;
  reg                 existedOrInvalid;
  reg                 shift;
  wire       [2:0]    nextNumber;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire       [7:0]    temp_1;
  `ifndef SYNTHESIS
  reg [63:0] fsm_stateReg_string;
  reg [63:0] fsm_stateNext_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_IDLE : fsm_stateReg_string = "IDLE    ";
      fsm_CHECK : fsm_stateReg_string = "CHECK   ";
      fsm_OUTPUT_1 : fsm_stateReg_string = "OUTPUT_1";
      fsm_DONE : fsm_stateReg_string = "DONE    ";
      fsm_SHIFT : fsm_stateReg_string = "SHIFT   ";
      fsm_ELEMENT : fsm_stateReg_string = "ELEMENT ";
      default : fsm_stateReg_string = "????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_IDLE : fsm_stateNext_string = "IDLE    ";
      fsm_CHECK : fsm_stateNext_string = "CHECK   ";
      fsm_OUTPUT_1 : fsm_stateNext_string = "OUTPUT_1";
      fsm_DONE : fsm_stateNext_string = "DONE    ";
      fsm_SHIFT : fsm_stateNext_string = "SHIFT   ";
      fsm_ELEMENT : fsm_stateNext_string = "ELEMENT ";
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
      fsm_CHECK : begin
        if(existedOrInvalid) begin
          fsm_stateNext = fsm_SHIFT;
        end else begin
          fsm_stateNext = fsm_OUTPUT_1;
        end
      end
      fsm_OUTPUT_1 : begin
        io_shape_valid = 1'b1;
        shift = 1'b1;
        fsm_stateNext = fsm_DONE;
      end
      fsm_DONE : begin
        fsm_stateNext = fsm_IDLE;
      end
      fsm_SHIFT : begin
        shift = 1'b1;
        fsm_stateNext = fsm_ELEMENT;
      end
      fsm_ELEMENT : begin
        fsm_stateNext = fsm_CHECK;
      end
      default : begin
        if(io_enable) begin
          fsm_stateNext = fsm_CHECK;
        end
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_IDLE;
    end
  end

  assign fsm_wantKill = 1'b0;
  assign temp_1 = ({7'd0,1'b1} <<< count);
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      lfsr <= 6'h2d;
      generatedNumbers_0 <= 3'b111;
      generatedNumbers_1 <= 3'b111;
      generatedNumbers_2 <= 3'b111;
      generatedNumbers_3 <= 3'b111;
      generatedNumbers_4 <= 3'b111;
      generatedNumbers_5 <= 3'b111;
      generatedNumbers_6 <= 3'b111;
      generatedNumbers_7 <= 3'b111;
      count <= 3'b000;
      fsm_stateReg <= fsm_IDLE;
    end else begin
      if(shift) begin
        lfsr <= {lfsr[4 : 0],(lfsr[5] ^ lfsr[3])};
      end
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! (io_shape_valid && (io_shape_payload == 3'b111)))); // seven_bag_rng.scala:L41
        `else
          if(!(! (io_shape_valid && (io_shape_payload == 3'b111)))) begin
            $display("FAILURE seven_bag_rng: valid shape must never be 7"); // seven_bag_rng.scala:L41
            $finish;
          end
        `endif
      `endif
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_CHECK : begin
        end
        fsm_OUTPUT_1 : begin
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
          if(temp_1[7]) begin
            generatedNumbers_7 <= nextNumber;
          end
          count <= (count + 3'b001);
        end
        fsm_DONE : begin
          if((count == 3'b111)) begin
            count <= 3'b000;
            generatedNumbers_0 <= 3'b111;
            generatedNumbers_1 <= 3'b111;
            generatedNumbers_2 <= 3'b111;
            generatedNumbers_3 <= 3'b111;
            generatedNumbers_4 <= 3'b111;
            generatedNumbers_5 <= 3'b111;
            generatedNumbers_6 <= 3'b111;
          end
        end
        fsm_SHIFT : begin
        end
        fsm_ELEMENT : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge core_clk) begin
    existedOrInvalid <= 1'b0;
    if((nextNumber == generatedNumbers_0)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_1)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_2)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_3)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_4)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_5)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_6)) begin
      existedOrInvalid <= 1'b1;
    end
    if((nextNumber == generatedNumbers_7)) begin
      existedOrInvalid <= 1'b1;
    end
  end


endmodule

module BufferCC_3 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          core_clk,
  input  wire          core_rst
);

  (* async_reg = "true" , altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW" *) reg                 buffers_0;
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

module bcd (
  input  wire          data_in_bin_valid,
  input  wire [9:0]    data_in_bin_payload,
  output wire          data_out_dec_valid,
  output wire [15:0]   data_out_dec_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam fsm_2_BOOT = 3'd0;
  localparam fsm_2_IDLE = 3'd1;
  localparam fsm_2_ADD3_CHECK = 3'd2;
  localparam fsm_2_SHIFT = 3'd3;
  localparam fsm_2_DONE = 3'd4;

  wire       [9:0]    temp_shiftRegister_5;
  wire       [3:0]    temp_temp_shiftRegister;
  wire       [3:0]    temp_temp_shiftRegister_1;
  wire       [3:0]    temp_temp_shiftRegister_2;
  wire       [3:0]    temp_temp_shiftRegister_3;
  reg        [25:0]   shiftRegister;
  reg        [3:0]    shiftCounter;
  reg                 isProcessing;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  reg        [25:0]   temp_shiftRegister;
  wire       [3:0]    temp_shiftRegister_1;
  wire       [3:0]    temp_shiftRegister_2;
  wire       [3:0]    temp_shiftRegister_3;
  wire       [3:0]    temp_shiftRegister_4;
  `ifndef SYNTHESIS
  reg [79:0] fsm_stateReg_string;
  reg [79:0] fsm_stateNext_string;
  `endif


  assign temp_shiftRegister_5 = data_in_bin_payload;
  assign temp_temp_shiftRegister = (temp_shiftRegister_1 + 4'b0011);
  assign temp_temp_shiftRegister_1 = (temp_shiftRegister_2 + 4'b0011);
  assign temp_temp_shiftRegister_2 = (temp_shiftRegister_3 + 4'b0011);
  assign temp_temp_shiftRegister_3 = (temp_shiftRegister_4 + 4'b0011);
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_2_BOOT : fsm_stateReg_string = "BOOT      ";
      fsm_2_IDLE : fsm_stateReg_string = "IDLE      ";
      fsm_2_ADD3_CHECK : fsm_stateReg_string = "ADD3_CHECK";
      fsm_2_SHIFT : fsm_stateReg_string = "SHIFT     ";
      fsm_2_DONE : fsm_stateReg_string = "DONE      ";
      default : fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_2_BOOT : fsm_stateNext_string = "BOOT      ";
      fsm_2_IDLE : fsm_stateNext_string = "IDLE      ";
      fsm_2_ADD3_CHECK : fsm_stateNext_string = "ADD3_CHECK";
      fsm_2_SHIFT : fsm_stateNext_string = "SHIFT     ";
      fsm_2_DONE : fsm_stateNext_string = "DONE      ";
      default : fsm_stateNext_string = "??????????";
    endcase
  end
  `endif

  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_2_IDLE : begin
        if(data_in_bin_valid) begin
          fsm_stateNext = fsm_2_ADD3_CHECK;
        end
      end
      fsm_2_ADD3_CHECK : begin
        fsm_stateNext = fsm_2_SHIFT;
      end
      fsm_2_SHIFT : begin
        if((shiftCounter == 4'b1001)) begin
          fsm_stateNext = fsm_2_DONE;
        end else begin
          fsm_stateNext = fsm_2_ADD3_CHECK;
        end
      end
      fsm_2_DONE : begin
        fsm_stateNext = fsm_2_IDLE;
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_2_IDLE;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_2_BOOT;
    end
  end

  assign fsm_wantKill = 1'b0;
  assign data_out_dec_valid = (fsm_stateReg == fsm_2_DONE);
  assign data_out_dec_payload = shiftRegister[25 : 10];
  always @(*) begin
    temp_shiftRegister = shiftRegister;
    if((4'b0101 <= temp_shiftRegister_1)) begin
      temp_shiftRegister[13 : 10] = temp_temp_shiftRegister;
    end
    if((4'b0101 <= temp_shiftRegister_2)) begin
      temp_shiftRegister[17 : 14] = temp_temp_shiftRegister_1;
    end
    if((4'b0101 <= temp_shiftRegister_3)) begin
      temp_shiftRegister[21 : 18] = temp_temp_shiftRegister_2;
    end
    if((4'b0101 <= temp_shiftRegister_4)) begin
      temp_shiftRegister[25 : 22] = temp_temp_shiftRegister_3;
    end
  end

  assign temp_shiftRegister_1 = shiftRegister[13 : 10];
  assign temp_shiftRegister_2 = shiftRegister[17 : 14];
  assign temp_shiftRegister_3 = shiftRegister[21 : 18];
  assign temp_shiftRegister_4 = shiftRegister[25 : 22];
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      shiftRegister <= 26'h0;
      shiftCounter <= 4'b0000;
      isProcessing <= 1'b0;
      fsm_stateReg <= fsm_2_BOOT;
    end else begin
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_2_IDLE : begin
          if(data_in_bin_valid) begin
            shiftRegister <= {16'd0, temp_shiftRegister_5};
            shiftCounter <= 4'b0000;
            isProcessing <= 1'b1;
          end
        end
        fsm_2_ADD3_CHECK : begin
          shiftRegister <= temp_shiftRegister;
        end
        fsm_2_SHIFT : begin
          shiftRegister <= (shiftRegister <<< 1);
          shiftCounter <= (shiftCounter + 4'b0001);
        end
        fsm_2_DONE : begin
          isProcessing <= 1'b0;
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module WriteWhileClearAssert
(
  input wire clk,
  input wire rst,
  input wire vld
);
`ifdef SIM
  // SVA: vld must never be high
  chk_no_write_during_clear : assert property (
    @(posedge clk) disable iff (rst)
    !vld
  ) else $error("Bram2p: external write requested while clear is active");
`endif
endmodule

