// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : tetris_core
// Git hash  : 39db3a2cb8f7a078d16a5dce7d14097771ef6fa2

`timescale 1ns/1ps

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
  output wire [3:0]    vga_color_b,
  output wire          screen_is_ready,
  output wire          vga_sof
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
  assign screen_is_ready = game_display_inst_screen_is_ready;
  assign vga_sof = game_display_inst_sof;

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
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;

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
  wire                controller_inst_debug_place_new;
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
    .playfiedl_in_idle        (playfield_inst_fsm_is_idle         ), //i
    .playfiedl_allow_action   (playfield_inst_motion_is_allowed   ), //i
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
    .debug_place_new          (controller_inst_debug_place_new    ), //o
    .core_clk                 (core_clk                           ), //i
    .core_rst                 (core_rst                           )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(temp_piece_in_payload)
      I : temp_piece_in_payload_string = "I";
      J : temp_piece_in_payload_string = "J";
      L : temp_piece_in_payload_string = "L";
      O : temp_piece_in_payload_string = "O";
      S : temp_piece_in_payload_string = "S";
      T : temp_piece_in_payload_string = "T";
      Z : temp_piece_in_payload_string = "Z";
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
    $readmemb("tetris_core.v_toplevel_game_display_inst_lbcp_rom.bin",rom);
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
  output wire [8:0]    draw_x_orig,
  output wire [7:0]    draw_y_orig,
  output reg           draw_field_done,
  output reg           bf_clear_start,
  input  wire          bf_clear_done,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam IDLE = 4'd0;
  localparam FETCH = 4'd1;
  localparam DATA_READY = 4'd2;
  localparam DRAW = 4'd3;
  localparam WAIT_DONE = 4'd4;
  localparam PRE_DRAW_SCORE = 4'd5;
  localparam DRAW_DIGIT = 4'd6;
  localparam WAIT_DRAW_DIGIT_DONE = 4'd7;
  localparam POST_DRAW_SCORE = 4'd8;
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
  wire                bcd_inst_data_out_dec_valid;
  wire       [15:0]   bcd_inst_data_out_dec_payload;
  wire       [1:0]    temp_digital_cnt_valueNext;
  wire       [0:0]    temp_digital_cnt_valueNext_1;
  reg        [3:0]    temp_itf_word;
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
  reg        [15:0]   score;
  wire       [3:0]    score_vec_0;
  wire       [3:0]    score_vec_1;
  wire       [3:0]    score_vec_2;
  wire       [3:0]    score_vec_3;
  reg                 digital_cnt_willIncrement;
  reg                 digital_cnt_willClear;
  reg        [1:0]    digital_cnt_valueNext;
  reg        [1:0]    digital_cnt_value;
  wire                digital_cnt_willOverflowIfInc;
  wire                digital_cnt_willOverflow;
  reg                 itf_start;
  wire       [6:0]    itf_word;
  wire       [2:0]    itf_scale;
  wire       [3:0]    itf_color;
  wire                itf_done;
  reg                 wr_row_cnt_willIncrement;
  wire                wr_row_cnt_willClear;
  reg        [4:0]    wr_row_cnt_valueNext;
  reg        [4:0]    wr_row_cnt_value;
  wire                wr_row_cnt_willOverflowIfInc;
  wire                wr_row_cnt_willOverflow;
  (* keep *) reg                 rd_en;
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
  wire                data_ready;
  reg                 wait_date_readout;
  reg                 wait_date_readout_regNext;
  wire                gen_start;
  reg        [3:0]    ft_color;
  reg        [8:0]    x;
  reg        [7:0]    y;
  wire       [8:0]    x_next;
  wire       [7:0]    y_next;
  reg                 itf_start_1;
  wire       [7:0]    itf_width;
  wire       [7:0]    itf_height;
  wire       [3:0]    itf_in_color;
  wire       [3:0]    itf_pat_color;
  wire       [1:0]    itf_fill_pattern;
  wire                itf_done_1;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  wire                itf_start_2;
  wire       [6:0]    itf_word_1;
  wire       [2:0]    itf_scale_1;
  wire       [3:0]    itf_color_1;
  wire                itf_done_2;
  reg                 cnt_willIncrement;
  wire                cnt_willClear;
  reg        [3:0]    cnt_valueNext;
  reg        [3:0]    cnt_value;
  wire                cnt_willOverflowIfInc;
  wire                cnt_willOverflow;
  wire       [8:0]    x_1;
  wire       [7:0]    y_1;
  wire                itf_start_3;
  wire       [7:0]    itf_width_1;
  wire       [7:0]    itf_height_1;
  wire       [3:0]    itf_in_color_1;
  wire       [3:0]    itf_pat_color_1;
  wire       [1:0]    itf_fill_pattern_1;
  wire                itf_done_3;
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
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_FETCH;
  wire                fsm_onExit_DATA_READY;
  wire                fsm_onExit_DRAW;
  wire                fsm_onExit_WAIT_DONE;
  wire                fsm_onExit_PRE_DRAW_SCORE;
  wire                fsm_onExit_DRAW_DIGIT;
  wire                fsm_onExit_WAIT_DRAW_DIGIT_DONE;
  wire                fsm_onExit_POST_DRAW_SCORE;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_FETCH;
  wire                fsm_onEntry_DATA_READY;
  wire                fsm_onEntry_DRAW;
  wire                fsm_onEntry_WAIT_DONE;
  wire                fsm_onEntry_PRE_DRAW_SCORE;
  wire                fsm_onEntry_DRAW_DIGIT;
  wire                fsm_onEntry_WAIT_DRAW_DIGIT_DONE;
  wire                fsm_onEntry_POST_DRAW_SCORE;
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
  reg [159:0] fsm_stateReg_string;
  reg [159:0] fsm_stateNext_string;
  reg [167:0] stepup_fsm_stateReg_string;
  reg [167:0] stepup_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [9:0] memory [0:21];
  (* ram_style = "distributed" *) reg [6:0] rom [0:10];
  reg [42:0] wall_rom [0:3];

  assign temp_when = (cnt_value == 4'b0101);
  assign temp_when_1 = (cnt_value == 4'b1010);
  assign temp_digital_cnt_valueNext_1 = digital_cnt_willIncrement;
  assign temp_digital_cnt_valueNext = {1'd0, temp_digital_cnt_valueNext_1};
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
    $readmemb("tetris_core.v_toplevel_game_display_inst_draw_controller_rom.bin",rom);
  end
  assign rom_spinal_port0 = rom[cnt_value];
  initial begin
    $readmemb("tetris_core.v_toplevel_game_display_inst_draw_controller_wall_rom.bin",wall_rom);
  end
  assign wall_rom_spinal_port0 = wall_rom[cnt_value_1];
  bcd bcd_inst (
    .data_in_bin_valid    (score_val_valid                    ), //i
    .data_in_bin_payload  (score_val_payload[9:0]             ), //i
    .data_out_dec_valid   (bcd_inst_data_out_dec_valid        ), //o
    .data_out_dec_payload (bcd_inst_data_out_dec_payload[15:0]), //o
    .core_clk             (core_clk                           ), //i
    .core_rst             (core_rst                           )  //i
  );
  always @(*) begin
    case(digital_cnt_value)
      2'b00 : temp_itf_word = score_vec_0;
      2'b01 : temp_itf_word = score_vec_1;
      2'b10 : temp_itf_word = score_vec_2;
      default : temp_itf_word = score_vec_3;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE                ";
      FETCH : fsm_stateReg_string = "FETCH               ";
      DATA_READY : fsm_stateReg_string = "DATA_READY          ";
      DRAW : fsm_stateReg_string = "DRAW                ";
      WAIT_DONE : fsm_stateReg_string = "WAIT_DONE           ";
      PRE_DRAW_SCORE : fsm_stateReg_string = "PRE_DRAW_SCORE      ";
      DRAW_DIGIT : fsm_stateReg_string = "DRAW_DIGIT          ";
      WAIT_DRAW_DIGIT_DONE : fsm_stateReg_string = "WAIT_DRAW_DIGIT_DONE";
      POST_DRAW_SCORE : fsm_stateReg_string = "POST_DRAW_SCORE     ";
      default : fsm_stateReg_string = "????????????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE                ";
      FETCH : fsm_stateNext_string = "FETCH               ";
      DATA_READY : fsm_stateNext_string = "DATA_READY          ";
      DRAW : fsm_stateNext_string = "DRAW                ";
      WAIT_DONE : fsm_stateNext_string = "WAIT_DONE           ";
      PRE_DRAW_SCORE : fsm_stateNext_string = "PRE_DRAW_SCORE      ";
      DRAW_DIGIT : fsm_stateNext_string = "DRAW_DIGIT          ";
      WAIT_DRAW_DIGIT_DONE : fsm_stateNext_string = "WAIT_DRAW_DIGIT_DONE";
      POST_DRAW_SCORE : fsm_stateNext_string = "POST_DRAW_SCORE     ";
      default : fsm_stateNext_string = "????????????????????";
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

  assign score_vec_0 = score[15 : 12];
  assign score_vec_1 = score[11 : 8];
  assign score_vec_2 = score[7 : 4];
  assign score_vec_3 = score[3 : 0];
  always @(*) begin
    digital_cnt_willIncrement = 1'b0;
    if(row_val_valid) begin
      digital_cnt_willIncrement = 1'b1;
    end
    digital_cnt_willIncrement = 1'b0;
    if(fsm_onExit_WAIT_DRAW_DIGIT_DONE) begin
      digital_cnt_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    digital_cnt_willClear = 1'b0;
    itf_start = 1'b0;
    itf_start_1 = 1'b0;
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
        itf_start_1 = 1'b1;
        fsm_stateNext = WAIT_DONE;
      end
      WAIT_DONE : begin
        if(itf_done_1) begin
          if((row_cnt_willOverflowIfInc && col_cnt_willOverflowIfInc)) begin
            row_cnt_inc = 1'b1;
            col_cnt_inc = 1'b1;
            fsm_stateNext = PRE_DRAW_SCORE;
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
      PRE_DRAW_SCORE : begin
        fsm_stateNext = DRAW_DIGIT;
      end
      DRAW_DIGIT : begin
        itf_start = 1'b1;
        fsm_stateNext = WAIT_DRAW_DIGIT_DONE;
      end
      WAIT_DRAW_DIGIT_DONE : begin
        if(itf_done) begin
          if(digital_cnt_willOverflowIfInc) begin
            fsm_stateNext = POST_DRAW_SCORE;
          end else begin
            fsm_stateNext = DRAW_DIGIT;
          end
        end
      end
      POST_DRAW_SCORE : begin
        digital_cnt_willClear = 1'b1;
        draw_field_done = 1'b1;
        fsm_stateNext = IDLE;
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

  assign digital_cnt_willOverflowIfInc = (digital_cnt_value == 2'b11);
  assign digital_cnt_willOverflow = (digital_cnt_willOverflowIfInc && digital_cnt_willIncrement);
  always @(*) begin
    digital_cnt_valueNext = (digital_cnt_value + temp_digital_cnt_valueNext);
    if(digital_cnt_willClear) begin
      digital_cnt_valueNext = 2'b00;
    end
  end

  assign itf_scale = 3'b001;
  assign itf_color = 4'b0110;
  assign itf_word = {3'b011,temp_itf_word};
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
  assign row_bits_next = (row_bits <<< 1);
  assign data_ready = ((! row_val_valid) && row_val_valid_regNext);
  assign gen_start = ((! wait_date_readout) && wait_date_readout_regNext);
  always @(*) begin
    ft_color = 4'b0010;
    if(row_bits[9]) begin
      ft_color = 4'b1001;
    end
  end

  assign x_next = (x + 9'h009);
  assign y_next = (y + 8'h09);
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
        if(itf_done_2) begin
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
        if(itf_done_2) begin
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
        if(itf_done_3) begin
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
  assign itf_word_1 = rom_spinal_port0;
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
  assign itf_scale_1 = stepup_scale;
  assign itf_color_1 = stepup_color;
  assign itf_start_2 = stepup_start_char_draw;
  assign itf_start_3 = stepup_start_block_draw;
  assign stepup_fsm_wantExit = 1'b0;
  assign stepup_fsm_wantKill = 1'b0;
  always @(*) begin
    bf_clear_start = 1'b0;
    if(stepup_fsm_onEntry_CLEAN_SCREEN) begin
      bf_clear_start = 1'b1;
    end
  end

  assign draw_char_start = (itf_start_2 || itf_start);
  assign draw_char_scale = (itf_start_2 ? itf_scale_1 : itf_scale);
  assign draw_char_color = (itf_start_2 ? itf_color_1 : itf_color);
  assign draw_char_word = (itf_start_2 ? itf_word_1 : itf_word);
  assign itf_done_2 = draw_char_done;
  assign itf_done = draw_char_done;
  assign draw_block_start = (itf_start_1 || itf_start_3);
  assign draw_block_width = (itf_start_1 ? itf_width : itf_width_1);
  assign draw_block_height = (itf_start_1 ? itf_height : itf_height_1);
  assign draw_block_in_color = (itf_start_1 ? itf_in_color : itf_in_color_1);
  assign draw_block_pat_color = itf_pat_color_1;
  assign draw_block_fill_pattern = (itf_start_1 ? itf_fill_pattern : itf_fill_pattern_1);
  assign itf_done_1 = draw_block_done;
  assign itf_done_3 = draw_block_done;
  assign draw_x_orig = (x | stepup_x);
  assign draw_y_orig = (y | stepup_y);
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_FETCH = ((fsm_stateNext != FETCH) && (fsm_stateReg == FETCH));
  assign fsm_onExit_DATA_READY = ((fsm_stateNext != DATA_READY) && (fsm_stateReg == DATA_READY));
  assign fsm_onExit_DRAW = ((fsm_stateNext != DRAW) && (fsm_stateReg == DRAW));
  assign fsm_onExit_WAIT_DONE = ((fsm_stateNext != WAIT_DONE) && (fsm_stateReg == WAIT_DONE));
  assign fsm_onExit_PRE_DRAW_SCORE = ((fsm_stateNext != PRE_DRAW_SCORE) && (fsm_stateReg == PRE_DRAW_SCORE));
  assign fsm_onExit_DRAW_DIGIT = ((fsm_stateNext != DRAW_DIGIT) && (fsm_stateReg == DRAW_DIGIT));
  assign fsm_onExit_WAIT_DRAW_DIGIT_DONE = ((fsm_stateNext != WAIT_DRAW_DIGIT_DONE) && (fsm_stateReg == WAIT_DRAW_DIGIT_DONE));
  assign fsm_onExit_POST_DRAW_SCORE = ((fsm_stateNext != POST_DRAW_SCORE) && (fsm_stateReg == POST_DRAW_SCORE));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_FETCH = ((fsm_stateNext == FETCH) && (fsm_stateReg != FETCH));
  assign fsm_onEntry_DATA_READY = ((fsm_stateNext == DATA_READY) && (fsm_stateReg != DATA_READY));
  assign fsm_onEntry_DRAW = ((fsm_stateNext == DRAW) && (fsm_stateReg != DRAW));
  assign fsm_onEntry_WAIT_DONE = ((fsm_stateNext == WAIT_DONE) && (fsm_stateReg != WAIT_DONE));
  assign fsm_onEntry_PRE_DRAW_SCORE = ((fsm_stateNext == PRE_DRAW_SCORE) && (fsm_stateReg != PRE_DRAW_SCORE));
  assign fsm_onEntry_DRAW_DIGIT = ((fsm_stateNext == DRAW_DIGIT) && (fsm_stateReg != DRAW_DIGIT));
  assign fsm_onEntry_WAIT_DRAW_DIGIT_DONE = ((fsm_stateNext == WAIT_DRAW_DIGIT_DONE) && (fsm_stateReg != WAIT_DRAW_DIGIT_DONE));
  assign fsm_onEntry_POST_DRAW_SCORE = ((fsm_stateNext == POST_DRAW_SCORE) && (fsm_stateReg != POST_DRAW_SCORE));
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
      score <= 16'h0;
      digital_cnt_value <= 2'b00;
      wr_row_cnt_value <= 5'h0;
      col_cnt_value <= 4'b0000;
      row_cnt_value <= 5'h0;
      row_val_valid_regNext <= 1'b0;
      wait_date_readout <= 1'b0;
      wait_date_readout_regNext <= 1'b0;
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
      if(bcd_inst_data_out_dec_valid) begin
        score <= bcd_inst_data_out_dec_payload;
      end
      digital_cnt_value <= digital_cnt_valueNext;
      wr_row_cnt_value <= wr_row_cnt_valueNext;
      col_cnt_value <= col_cnt_valueNext;
      row_cnt_value <= row_cnt_valueNext;
      row_val_valid_regNext <= row_val_valid;
      if(data_ready) begin
        wait_date_readout <= 1'b1;
      end else begin
        if(draw_openning_start) begin
          wait_date_readout <= 1'b0;
        end
      end
      wait_date_readout_regNext <= wait_date_readout;
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
      case(fsm_stateReg)
        FETCH : begin
        end
        DATA_READY : begin
        end
        DRAW : begin
        end
        WAIT_DONE : begin
        end
        PRE_DRAW_SCORE : begin
          x <= 9'h0d2;
          y <= 8'h50;
        end
        DRAW_DIGIT : begin
        end
        WAIT_DRAW_DIGIT_DONE : begin
        end
        POST_DRAW_SCORE : begin
        end
        default : begin
        end
      endcase
      if(fsm_onExit_WAIT_DRAW_DIGIT_DONE) begin
        x <= (x + 9'h014);
      end
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
          if(itf_done_2) begin
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
          if(itf_done_2) begin
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
    if(1'b0) begin
      h_cnt_isDone <= h_cnt_willOverflow;
    end
    if(1'b0) begin
      v_cnt_isDone <= v_cnt_willOverflow;
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
  reg                 x_scale_cnt_isDone;
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
  reg                 y_scale_cnt_isDone;
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
    if(1'b0) begin
      x_scale_cnt_isDone <= x_scale_cnt_willOverflow;
    end
    if(1'b0) begin
      y_scale_cnt_isDone <= y_scale_cnt_willOverflow;
    end
    rom_rd_en_regNext <= rom_rd_en;
  end

  always @(posedge core_clk) begin
    color_delay_1 <= color;
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
    $readmemb("tetris_core.v_toplevel_game_display_inst_fb_memory.bin",memory);
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

module controller (
  input  wire          game_start,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          move_down,
  input  wire          rotate,
  input  wire          drop,
  input  wire          screen_is_ready,
  input  wire          playfiedl_in_idle,
  input  wire          playfiedl_allow_action,
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
  (* keep *) output wire          debug_place_new,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam IDLE = 4'd0;
  localparam GAME_START = 4'd1;
  localparam RANDOM_GEN = 4'd2;
  localparam PLACE = 4'd3;
  localparam END_1 = 4'd4;
  localparam FALLING = 4'd5;
  localparam DOWN = 4'd6;
  localparam DROP = 4'd7;
  localparam WAIT_ALLOW_ACTION = 4'd8;
  localparam MOVE = 4'd9;
  localparam LOCK = 4'd10;
  localparam LOCKDOWN = 4'd11;
  localparam CLEAN = 4'd12;
  localparam WAIT_TIME = 4'd13;

  wire       [17:0]   temp_drop_timeout_counter_valueNext;
  wire       [0:0]    temp_drop_timeout_counter_valueNext_1;
  wire       [17:0]   temp_lock_timeout_counter_valueNext;
  wire       [0:0]    temp_lock_timeout_counter_valueNext_1;
  wire       [9:0]    temp_temp_motion_voted_2;
  wire       [9:0]    temp_temp_motion_voted_2_1;
  wire       [4:0]    temp_temp_motion_voted_2_2;
  wire                temp_when;
  reg                 drop_timeout_state;
  reg                 drop_timeout_stateRise;
  wire                drop_timeout_counter_willIncrement;
  reg                 drop_timeout_counter_willClear;
  reg        [17:0]   drop_timeout_counter_valueNext;
  reg        [17:0]   drop_timeout_counter_value;
  wire                drop_timeout_counter_willOverflowIfInc;
  wire                drop_timeout_counter_willOverflow;
  reg                 lock_timeout_state;
  reg                 lock_timeout_stateRise;
  wire                lock_timeout_counter_willIncrement;
  reg                 lock_timeout_counter_willClear;
  reg        [17:0]   lock_timeout_counter_valueNext;
  reg        [17:0]   lock_timeout_counter_value;
  wire                lock_timeout_counter_willOverflowIfInc;
  wire                lock_timeout_counter_willOverflow;
  reg        [4:0]    motion_request;
  wire       [4:0]    priority_1;
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
  wire                debug_place_new_cnt_willClear;
  reg        [0:0]    debug_place_new_cnt_valueNext;
  reg        [0:0]    debug_place_new_cnt_value;
  wire                debug_place_new_cnt_willOverflowIfInc;
  wire                debug_place_new_cnt_willOverflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_GAME_START;
  wire                fsm_onExit_RANDOM_GEN;
  wire                fsm_onExit_PLACE;
  wire                fsm_onExit_END_1;
  wire                fsm_onExit_FALLING;
  wire                fsm_onExit_DOWN;
  wire                fsm_onExit_DROP;
  wire                fsm_onExit_WAIT_ALLOW_ACTION;
  wire                fsm_onExit_MOVE;
  wire                fsm_onExit_LOCK;
  wire                fsm_onExit_LOCKDOWN;
  wire                fsm_onExit_CLEAN;
  wire                fsm_onExit_WAIT_TIME;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_GAME_START;
  wire                fsm_onEntry_RANDOM_GEN;
  wire                fsm_onEntry_PLACE;
  wire                fsm_onEntry_END_1;
  wire                fsm_onEntry_FALLING;
  wire                fsm_onEntry_DOWN;
  wire                fsm_onEntry_DROP;
  wire                fsm_onEntry_WAIT_ALLOW_ACTION;
  wire                fsm_onEntry_MOVE;
  wire                fsm_onEntry_LOCK;
  wire                fsm_onEntry_LOCKDOWN;
  wire                fsm_onEntry_CLEAN;
  wire                fsm_onEntry_WAIT_TIME;
  `ifndef SYNTHESIS
  reg [135:0] fsm_stateReg_string;
  reg [135:0] fsm_stateNext_string;
  `endif


  assign temp_when = (! collision_status_payload);
  assign temp_drop_timeout_counter_valueNext_1 = drop_timeout_counter_willIncrement;
  assign temp_drop_timeout_counter_valueNext = {17'd0, temp_drop_timeout_counter_valueNext_1};
  assign temp_lock_timeout_counter_valueNext_1 = lock_timeout_counter_willIncrement;
  assign temp_lock_timeout_counter_valueNext = {17'd0, temp_lock_timeout_counter_valueNext_1};
  assign temp_temp_motion_voted_2 = (temp_motion_voted_1 - temp_temp_motion_voted_2_1);
  assign temp_temp_motion_voted_2_2 = priority_1;
  assign temp_temp_motion_voted_2_1 = {5'd0, temp_temp_motion_voted_2_2};
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE             ";
      GAME_START : fsm_stateReg_string = "GAME_START       ";
      RANDOM_GEN : fsm_stateReg_string = "RANDOM_GEN       ";
      PLACE : fsm_stateReg_string = "PLACE            ";
      END_1 : fsm_stateReg_string = "END_1            ";
      FALLING : fsm_stateReg_string = "FALLING          ";
      DOWN : fsm_stateReg_string = "DOWN             ";
      DROP : fsm_stateReg_string = "DROP             ";
      WAIT_ALLOW_ACTION : fsm_stateReg_string = "WAIT_ALLOW_ACTION";
      MOVE : fsm_stateReg_string = "MOVE             ";
      LOCK : fsm_stateReg_string = "LOCK             ";
      LOCKDOWN : fsm_stateReg_string = "LOCKDOWN         ";
      CLEAN : fsm_stateReg_string = "CLEAN            ";
      WAIT_TIME : fsm_stateReg_string = "WAIT_TIME        ";
      default : fsm_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE             ";
      GAME_START : fsm_stateNext_string = "GAME_START       ";
      RANDOM_GEN : fsm_stateNext_string = "RANDOM_GEN       ";
      PLACE : fsm_stateNext_string = "PLACE            ";
      END_1 : fsm_stateNext_string = "END_1            ";
      FALLING : fsm_stateNext_string = "FALLING          ";
      DOWN : fsm_stateNext_string = "DOWN             ";
      DROP : fsm_stateNext_string = "DROP             ";
      WAIT_ALLOW_ACTION : fsm_stateNext_string = "WAIT_ALLOW_ACTION";
      MOVE : fsm_stateNext_string = "MOVE             ";
      LOCK : fsm_stateNext_string = "LOCK             ";
      LOCKDOWN : fsm_stateNext_string = "LOCKDOWN         ";
      CLEAN : fsm_stateNext_string = "CLEAN            ";
      WAIT_TIME : fsm_stateNext_string = "WAIT_TIME        ";
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
      GAME_START : begin
        if(screen_is_ready) begin
          fsm_stateNext = RANDOM_GEN;
        end
      end
      RANDOM_GEN : begin
        gen_piece_en = 1'b1;
        fsm_stateNext = PLACE;
      end
      PLACE : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = END_1;
          end else begin
            fsm_stateNext = FALLING;
          end
        end
      end
      END_1 : begin
        if(game_start) begin
          softReset = 1'b1;
          game_restart = 1'b1;
          fsm_stateNext = GAME_START;
        end
      end
      FALLING : begin
        if((move_down_1 && playfiedl_allow_action)) begin
          fsm_stateNext = DOWN;
        end
        if((drop_1 && playfiedl_allow_action)) begin
          fsm_stateNext = DROP;
        end
        if((move_left_1 && playfiedl_allow_action)) begin
          move_out_left = 1'b1;
          fsm_stateNext = MOVE;
        end
        if((move_right_1 && playfiedl_allow_action)) begin
          move_out_right = 1'b1;
          fsm_stateNext = MOVE;
        end
        if((rotate_1 && playfiedl_allow_action)) begin
          move_out_rotate = 1'b1;
          fsm_stateNext = MOVE;
        end
        if(drop_timeout_state) begin
          fsm_stateNext = LOCK;
        end
      end
      DOWN : begin
        if(collision_status_valid) begin
          if(temp_when) begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
          end
          fsm_stateNext = FALLING;
        end
      end
      DROP : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = LOCKDOWN;
          end else begin
            fsm_stateNext = WAIT_ALLOW_ACTION;
          end
        end
      end
      WAIT_ALLOW_ACTION : begin
        if(playfiedl_allow_action) begin
          fsm_stateNext = DROP;
        end
      end
      MOVE : begin
        if(collision_status_valid) begin
          fsm_stateNext = FALLING;
        end
      end
      LOCK : begin
        if(collision_status_valid) begin
          if(collision_status_payload) begin
            fsm_stateNext = LOCKDOWN;
          end else begin
            drop_timeout_counter_willClear = 1'b1;
            drop_timeout_stateRise = 1'b0;
            fsm_stateNext = FALLING;
          end
        end
      end
      LOCKDOWN : begin
        if(lock_timeout_state) begin
          lock = 1'b1;
          fsm_stateNext = CLEAN;
        end
      end
      CLEAN : begin
        if(playfiedl_in_idle) begin
          lock_timeout_counter_willClear = 1'b1;
          lock_timeout_stateRise = 1'b0;
          fsm_stateNext = WAIT_TIME;
        end
      end
      WAIT_TIME : begin
        if(lock_timeout_state) begin
          fsm_stateNext = RANDOM_GEN;
        end
      end
      default : begin
        if(game_start) begin
          fsm_stateNext = GAME_START;
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
      fsm_stateNext = IDLE;
    end
  end

  assign drop_timeout_counter_willOverflowIfInc = (drop_timeout_counter_value == 18'h30d3f);
  assign drop_timeout_counter_willOverflow = (drop_timeout_counter_willOverflowIfInc && drop_timeout_counter_willIncrement);
  always @(*) begin
    if(drop_timeout_counter_willOverflow) begin
      drop_timeout_counter_valueNext = 18'h0;
    end else begin
      drop_timeout_counter_valueNext = (drop_timeout_counter_value + temp_drop_timeout_counter_valueNext);
    end
    if(drop_timeout_counter_willClear) begin
      drop_timeout_counter_valueNext = 18'h0;
    end
  end

  assign drop_timeout_counter_willIncrement = 1'b1;
  assign lock_timeout_counter_willOverflowIfInc = (lock_timeout_counter_value == 18'h30d3f);
  assign lock_timeout_counter_willOverflow = (lock_timeout_counter_willOverflowIfInc && lock_timeout_counter_willIncrement);
  always @(*) begin
    if(lock_timeout_counter_willOverflow) begin
      lock_timeout_counter_valueNext = 18'h0;
    end else begin
      lock_timeout_counter_valueNext = (lock_timeout_counter_value + temp_lock_timeout_counter_valueNext);
    end
    if(lock_timeout_counter_willClear) begin
      lock_timeout_counter_valueNext = 18'h0;
    end
  end

  assign lock_timeout_counter_willIncrement = 1'b1;
  assign priority_1 = 5'h01;
  assign temp_motion_voted = motion_request;
  assign temp_motion_voted_1 = {temp_motion_voted,temp_motion_voted};
  assign temp_motion_voted_2 = (temp_motion_voted_1 & (~ temp_temp_motion_voted_2));
  assign motion_voted = (temp_motion_voted_2[9 : 5] | temp_motion_voted_2[4 : 0]);
  assign drop_1 = motion_voted[0];
  assign move_down_1 = motion_voted[1];
  assign move_left_1 = motion_voted[2];
  assign move_right_1 = motion_voted[3];
  assign rotate_1 = motion_voted[4];
  assign debug_place_new_cnt_willClear = 1'b0;
  assign debug_place_new_cnt_willOverflowIfInc = (debug_place_new_cnt_value == 1'b1);
  assign debug_place_new_cnt_willOverflow = (debug_place_new_cnt_willOverflowIfInc && debug_place_new_cnt_willIncrement);
  always @(*) begin
    debug_place_new_cnt_valueNext = (debug_place_new_cnt_value + debug_place_new_cnt_willIncrement);
    if(debug_place_new_cnt_willClear) begin
      debug_place_new_cnt_valueNext = 1'b0;
    end
  end

  assign debug_place_new = debug_place_new_cnt_willOverflow;
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

  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_GAME_START = ((fsm_stateNext != GAME_START) && (fsm_stateReg == GAME_START));
  assign fsm_onExit_RANDOM_GEN = ((fsm_stateNext != RANDOM_GEN) && (fsm_stateReg == RANDOM_GEN));
  assign fsm_onExit_PLACE = ((fsm_stateNext != PLACE) && (fsm_stateReg == PLACE));
  assign fsm_onExit_END_1 = ((fsm_stateNext != END_1) && (fsm_stateReg == END_1));
  assign fsm_onExit_FALLING = ((fsm_stateNext != FALLING) && (fsm_stateReg == FALLING));
  assign fsm_onExit_DOWN = ((fsm_stateNext != DOWN) && (fsm_stateReg == DOWN));
  assign fsm_onExit_DROP = ((fsm_stateNext != DROP) && (fsm_stateReg == DROP));
  assign fsm_onExit_WAIT_ALLOW_ACTION = ((fsm_stateNext != WAIT_ALLOW_ACTION) && (fsm_stateReg == WAIT_ALLOW_ACTION));
  assign fsm_onExit_MOVE = ((fsm_stateNext != MOVE) && (fsm_stateReg == MOVE));
  assign fsm_onExit_LOCK = ((fsm_stateNext != LOCK) && (fsm_stateReg == LOCK));
  assign fsm_onExit_LOCKDOWN = ((fsm_stateNext != LOCKDOWN) && (fsm_stateReg == LOCKDOWN));
  assign fsm_onExit_CLEAN = ((fsm_stateNext != CLEAN) && (fsm_stateReg == CLEAN));
  assign fsm_onExit_WAIT_TIME = ((fsm_stateNext != WAIT_TIME) && (fsm_stateReg == WAIT_TIME));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_GAME_START = ((fsm_stateNext == GAME_START) && (fsm_stateReg != GAME_START));
  assign fsm_onEntry_RANDOM_GEN = ((fsm_stateNext == RANDOM_GEN) && (fsm_stateReg != RANDOM_GEN));
  assign fsm_onEntry_PLACE = ((fsm_stateNext == PLACE) && (fsm_stateReg != PLACE));
  assign fsm_onEntry_END_1 = ((fsm_stateNext == END_1) && (fsm_stateReg != END_1));
  assign fsm_onEntry_FALLING = ((fsm_stateNext == FALLING) && (fsm_stateReg != FALLING));
  assign fsm_onEntry_DOWN = ((fsm_stateNext == DOWN) && (fsm_stateReg != DOWN));
  assign fsm_onEntry_DROP = ((fsm_stateNext == DROP) && (fsm_stateReg != DROP));
  assign fsm_onEntry_WAIT_ALLOW_ACTION = ((fsm_stateNext == WAIT_ALLOW_ACTION) && (fsm_stateReg != WAIT_ALLOW_ACTION));
  assign fsm_onEntry_MOVE = ((fsm_stateNext == MOVE) && (fsm_stateReg != MOVE));
  assign fsm_onEntry_LOCK = ((fsm_stateNext == LOCK) && (fsm_stateReg != LOCK));
  assign fsm_onEntry_LOCKDOWN = ((fsm_stateNext == LOCKDOWN) && (fsm_stateReg != LOCKDOWN));
  assign fsm_onEntry_CLEAN = ((fsm_stateNext == CLEAN) && (fsm_stateReg != CLEAN));
  assign fsm_onEntry_WAIT_TIME = ((fsm_stateNext == WAIT_TIME) && (fsm_stateReg != WAIT_TIME));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      drop_timeout_state <= 1'b0;
      drop_timeout_counter_value <= 18'h0;
      lock_timeout_state <= 1'b0;
      lock_timeout_counter_value <= 18'h0;
      motion_request <= 5'h0;
      drop_regNext <= 1'b0;
      move_down_regNext <= 1'b0;
      move_left_regNext <= 1'b0;
      move_right_regNext <= 1'b0;
      rotate_regNext <= 1'b0;
      debug_place_new_cnt_value <= 1'b0;
      fsm_stateReg <= IDLE;
    end else begin
      drop_timeout_counter_value <= drop_timeout_counter_valueNext;
      if(drop_timeout_counter_willOverflow) begin
        drop_timeout_state <= 1'b1;
      end
      lock_timeout_counter_value <= lock_timeout_counter_valueNext;
      if(lock_timeout_counter_willOverflow) begin
        lock_timeout_state <= 1'b1;
      end
      drop_regNext <= drop;
      if((drop && (! drop_regNext))) begin
        motion_request[0] <= 1'b1;
      end
      move_down_regNext <= move_down;
      if((move_down && (! move_down_regNext))) begin
        motion_request[1] <= 1'b1;
      end
      move_left_regNext <= move_left;
      if((move_left && (! move_left_regNext))) begin
        motion_request[2] <= 1'b1;
      end
      move_right_regNext <= move_right;
      if((move_right && (! move_right_regNext))) begin
        motion_request[3] <= 1'b1;
      end
      rotate_regNext <= rotate;
      if((rotate && (! rotate_regNext))) begin
        motion_request[4] <= 1'b1;
      end
      debug_place_new_cnt_value <= debug_place_new_cnt_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
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
        DOWN : begin
          if(collision_status_valid) begin
            if(temp_when) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        DROP : begin
        end
        WAIT_ALLOW_ACTION : begin
        end
        MOVE : begin
        end
        LOCK : begin
          if(collision_status_valid) begin
            if(!collision_status_payload) begin
              drop_timeout_state <= 1'b0;
            end
          end
        end
        LOCKDOWN : begin
        end
        CLEAN : begin
          if(playfiedl_in_idle) begin
            lock_timeout_state <= 1'b0;
          end
        end
        WAIT_TIME : begin
        end
        default : begin
        end
      endcase
      if(fsm_onExit_PLACE) begin
        drop_timeout_state <= 1'b0;
      end
      if(fsm_onExit_FALLING) begin
        motion_request <= 5'h0;
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
  localparam I = 3'd0;
  localparam J = 3'd1;
  localparam L = 3'd2;
  localparam O = 3'd3;
  localparam S = 3'd4;
  localparam T = 3'd5;
  localparam Z = 3'd6;
  localparam NO = 3'd0;
  localparam LEFT = 3'd1;
  localparam RIGHT = 3'd2;
  localparam DOWN = 3'd3;
  localparam ROTATE = 3'd4;
  localparam PLACE = 3'd5;
  localparam IDLE = 5'd0;
  localparam READOUT = 5'd1;
  localparam LOAD_TO_CHECKER = 5'd2;
  localparam COLLISION_CHECK = 5'd3;
  localparam REPORT_COLLISION = 5'd4;
  localparam END_OF_COLLISION = 5'd5;
  localparam PASS = 5'd6;
  localparam WAIT_CONTROL = 5'd7;
  localparam ROTATION = 5'd8;
  localparam PRE_CHECK = 5'd9;
  localparam LOCKER_WRITE_0 = 5'd10;
  localparam LOCKER_WRITE_1 = 5'd11;
  localparam WAIT_LOCKER_WRITE_DONE = 5'd12;
  localparam LOCKER_READ = 5'd13;
  localparam WAIT_LOCKER_READ_DONE = 5'd14;
  localparam CLEAR_REGION = 5'd15;
  localparam CHECK_ROW_FULL = 5'd16;
  localparam ROW_REMOVE = 5'd17;
  localparam ROW_REMOVE_DONE = 5'd18;

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
  reg                 playfield_update_score_regNext;
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
  wire                main_fsm_onExit_IDLE;
  wire                main_fsm_onExit_READOUT;
  wire                main_fsm_onExit_LOAD_TO_CHECKER;
  wire                main_fsm_onExit_COLLISION_CHECK;
  wire                main_fsm_onExit_REPORT_COLLISION;
  wire                main_fsm_onExit_END_OF_COLLISION;
  wire                main_fsm_onExit_PASS;
  wire                main_fsm_onExit_WAIT_CONTROL;
  wire                main_fsm_onExit_ROTATION;
  wire                main_fsm_onExit_PRE_CHECK;
  wire                main_fsm_onExit_LOCKER_WRITE_0;
  wire                main_fsm_onExit_LOCKER_WRITE_1;
  wire                main_fsm_onExit_WAIT_LOCKER_WRITE_DONE;
  wire                main_fsm_onExit_LOCKER_READ;
  wire                main_fsm_onExit_WAIT_LOCKER_READ_DONE;
  wire                main_fsm_onExit_CLEAR_REGION;
  wire                main_fsm_onExit_CHECK_ROW_FULL;
  wire                main_fsm_onExit_ROW_REMOVE;
  wire                main_fsm_onExit_ROW_REMOVE_DONE;
  wire                main_fsm_onEntry_IDLE;
  wire                main_fsm_onEntry_READOUT;
  wire                main_fsm_onEntry_LOAD_TO_CHECKER;
  wire                main_fsm_onEntry_COLLISION_CHECK;
  wire                main_fsm_onEntry_REPORT_COLLISION;
  wire                main_fsm_onEntry_END_OF_COLLISION;
  wire                main_fsm_onEntry_PASS;
  wire                main_fsm_onEntry_WAIT_CONTROL;
  wire                main_fsm_onEntry_ROTATION;
  wire                main_fsm_onEntry_PRE_CHECK;
  wire                main_fsm_onEntry_LOCKER_WRITE_0;
  wire                main_fsm_onEntry_LOCKER_WRITE_1;
  wire                main_fsm_onEntry_WAIT_LOCKER_WRITE_DONE;
  wire                main_fsm_onEntry_LOCKER_READ;
  wire                main_fsm_onEntry_WAIT_LOCKER_READ_DONE;
  wire                main_fsm_onEntry_CLEAR_REGION;
  wire                main_fsm_onEntry_CHECK_ROW_FULL;
  wire                main_fsm_onEntry_ROW_REMOVE;
  wire                main_fsm_onEntry_ROW_REMOVE_DONE;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_string;
  reg [7:0] piece_payload_string;
  reg [47:0] action_1_string;
  reg [175:0] main_fsm_stateReg_string;
  reg [175:0] main_fsm_stateNext_string;
  `endif

  (* ram_style = "distributed" *) reg [9:0] locker_region [0:3];

  assign temp_when = (action_1 == PLACE);
  assign temp_when_1 = (action_1 == DOWN);
  assign temp_when_2 = (action_1 == ROTATE);
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
      I : piece_in_payload_string = "I";
      J : piece_in_payload_string = "J";
      L : piece_in_payload_string = "L";
      O : piece_in_payload_string = "O";
      S : piece_in_payload_string = "S";
      T : piece_in_payload_string = "T";
      Z : piece_in_payload_string = "Z";
      default : piece_in_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(piece_payload)
      I : piece_payload_string = "I";
      J : piece_payload_string = "J";
      L : piece_payload_string = "L";
      O : piece_payload_string = "O";
      S : piece_payload_string = "S";
      T : piece_payload_string = "T";
      Z : piece_payload_string = "Z";
      default : piece_payload_string = "?";
    endcase
  end
  always @(*) begin
    case(action_1)
      NO : action_1_string = "NO    ";
      LEFT : action_1_string = "LEFT  ";
      RIGHT : action_1_string = "RIGHT ";
      DOWN : action_1_string = "DOWN  ";
      ROTATE : action_1_string = "ROTATE";
      PLACE : action_1_string = "PLACE ";
      default : action_1_string = "??????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateReg)
      IDLE : main_fsm_stateReg_string = "IDLE                  ";
      READOUT : main_fsm_stateReg_string = "READOUT               ";
      LOAD_TO_CHECKER : main_fsm_stateReg_string = "LOAD_TO_CHECKER       ";
      COLLISION_CHECK : main_fsm_stateReg_string = "COLLISION_CHECK       ";
      REPORT_COLLISION : main_fsm_stateReg_string = "REPORT_COLLISION      ";
      END_OF_COLLISION : main_fsm_stateReg_string = "END_OF_COLLISION      ";
      PASS : main_fsm_stateReg_string = "PASS                  ";
      WAIT_CONTROL : main_fsm_stateReg_string = "WAIT_CONTROL          ";
      ROTATION : main_fsm_stateReg_string = "ROTATION              ";
      PRE_CHECK : main_fsm_stateReg_string = "PRE_CHECK             ";
      LOCKER_WRITE_0 : main_fsm_stateReg_string = "LOCKER_WRITE_0        ";
      LOCKER_WRITE_1 : main_fsm_stateReg_string = "LOCKER_WRITE_1        ";
      WAIT_LOCKER_WRITE_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_WRITE_DONE";
      LOCKER_READ : main_fsm_stateReg_string = "LOCKER_READ           ";
      WAIT_LOCKER_READ_DONE : main_fsm_stateReg_string = "WAIT_LOCKER_READ_DONE ";
      CLEAR_REGION : main_fsm_stateReg_string = "CLEAR_REGION          ";
      CHECK_ROW_FULL : main_fsm_stateReg_string = "CHECK_ROW_FULL        ";
      ROW_REMOVE : main_fsm_stateReg_string = "ROW_REMOVE            ";
      ROW_REMOVE_DONE : main_fsm_stateReg_string = "ROW_REMOVE_DONE       ";
      default : main_fsm_stateReg_string = "??????????????????????";
    endcase
  end
  always @(*) begin
    case(main_fsm_stateNext)
      IDLE : main_fsm_stateNext_string = "IDLE                  ";
      READOUT : main_fsm_stateNext_string = "READOUT               ";
      LOAD_TO_CHECKER : main_fsm_stateNext_string = "LOAD_TO_CHECKER       ";
      COLLISION_CHECK : main_fsm_stateNext_string = "COLLISION_CHECK       ";
      REPORT_COLLISION : main_fsm_stateNext_string = "REPORT_COLLISION      ";
      END_OF_COLLISION : main_fsm_stateNext_string = "END_OF_COLLISION      ";
      PASS : main_fsm_stateNext_string = "PASS                  ";
      WAIT_CONTROL : main_fsm_stateNext_string = "WAIT_CONTROL          ";
      ROTATION : main_fsm_stateNext_string = "ROTATION              ";
      PRE_CHECK : main_fsm_stateNext_string = "PRE_CHECK             ";
      LOCKER_WRITE_0 : main_fsm_stateNext_string = "LOCKER_WRITE_0        ";
      LOCKER_WRITE_1 : main_fsm_stateNext_string = "LOCKER_WRITE_1        ";
      WAIT_LOCKER_WRITE_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_WRITE_DONE";
      LOCKER_READ : main_fsm_stateNext_string = "LOCKER_READ           ";
      WAIT_LOCKER_READ_DONE : main_fsm_stateNext_string = "WAIT_LOCKER_READ_DONE ";
      CLEAR_REGION : main_fsm_stateNext_string = "CLEAR_REGION          ";
      CHECK_ROW_FULL : main_fsm_stateNext_string = "CHECK_ROW_FULL        ";
      ROW_REMOVE : main_fsm_stateNext_string = "ROW_REMOVE            ";
      ROW_REMOVE_DONE : main_fsm_stateNext_string = "ROW_REMOVE_DONE       ";
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
      READOUT : begin
        output_en = 1'b1;
        if((playfield_addr_access_port_payload == flow_row)) begin
          dma_flow_dma_start = 1'b1;
        end
        if(row_out_done) begin
          if(main_fsm_will_goto_idle) begin
            main_fsm_stateNext = IDLE;
          end else begin
            main_fsm_stateNext = WAIT_CONTROL;
          end
        end
      end
      LOAD_TO_CHECKER : begin
        load_piece = 1'b1;
        main_fsm_stateNext = COLLISION_CHECK;
      end
      COLLISION_CHECK : begin
        if(collision_checker_is_collision_valid) begin
          if(collision_checker_is_collision_payload) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = PASS;
          end
        end
      end
      REPORT_COLLISION : begin
        status_valid = 1'b1;
        status_payload = 1'b1;
        if(temp_when) begin
          main_fsm_stateNext = IDLE;
        end else begin
          main_fsm_stateNext = END_OF_COLLISION;
        end
      end
      END_OF_COLLISION : begin
        if((((action_1 == LEFT) || (action_1 == RIGHT)) || (action_1 == ROTATE))) begin
          load_piece = 1'b1;
        end
        main_fsm_stateNext = WAIT_CONTROL;
      end
      PASS : begin
        if((action_1 == PLACE)) begin
          flow_update = 1'b1;
        end
        if((action_1 == LEFT)) begin
          flow_update = 1'b1;
          piece_buffer_left_shift_all = 1'b1;
        end
        if((action_1 == RIGHT)) begin
          flow_update = 1'b1;
          piece_buffer_right_shift_all = 1'b1;
        end
        if(temp_when_1) begin
          flow_update = 1'b1;
        end
        if(temp_when_2) begin
          flow_update = 1'b1;
        end
        main_fsm_stateNext = READOUT;
      end
      WAIT_CONTROL : begin
        if(move_in_left) begin
          if(checker_overflowIfLeft) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            checker_left_shift = 1'b1;
            main_fsm_stateNext = PRE_CHECK;
          end
        end
        if(move_in_right) begin
          if(checker_overflowIfRight) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            checker_right_shift = 1'b1;
            main_fsm_stateNext = PRE_CHECK;
          end
        end
        if(move_in_down) begin
          if(checker_overflowIfDown) begin
            main_fsm_stateNext = REPORT_COLLISION;
          end else begin
            main_fsm_stateNext = PRE_CHECK;
          end
        end
        if(move_in_rotate) begin
          main_fsm_stateNext = ROTATION;
        end
        if(lock) begin
          main_fsm_stateNext = LOCKER_WRITE_0;
        end
      end
      ROTATION : begin
        if(temp_when_3) begin
          main_fsm_stateNext = REPORT_COLLISION;
        end else begin
          load_piece = 1'b1;
          main_fsm_stateNext = PRE_CHECK;
        end
      end
      PRE_CHECK : begin
        main_fsm_stateNext = COLLISION_CHECK;
      end
      LOCKER_WRITE_0 : begin
        dma_flow_dma_start = 1'b1;
        main_fsm_stateNext = LOCKER_WRITE_1;
      end
      LOCKER_WRITE_1 : begin
        dma_locker_dma_start = 1'b1;
        main_fsm_stateNext = WAIT_LOCKER_WRITE_DONE;
      end
      WAIT_LOCKER_WRITE_DONE : begin
        if(row_out_done) begin
          main_fsm_stateNext = LOCKER_READ;
        end
      end
      LOCKER_READ : begin
        dma_playfield_dma_start = 1'b1;
        main_fsm_stateNext = WAIT_LOCKER_READ_DONE;
      end
      WAIT_LOCKER_READ_DONE : begin
        playfield_freeze = 1'b1;
        if(locker_readou_is_done) begin
          main_fsm_stateNext = CLEAR_REGION;
        end
      end
      CLEAR_REGION : begin
        playfield_update_score = 1'b1;
        main_fsm_stateNext = CHECK_ROW_FULL;
      end
      CHECK_ROW_FULL : begin
        if(playfield_isRowFull) begin
          main_fsm_stateNext = ROW_REMOVE;
        end else begin
          main_fsm_stateNext = READOUT;
        end
      end
      ROW_REMOVE : begin
        playfield_clear = 1'b1;
        main_fsm_stateNext = ROW_REMOVE_DONE;
      end
      ROW_REMOVE_DONE : begin
        main_fsm_stateNext = CHECK_ROW_FULL;
      end
      default : begin
        if(piece_valid) begin
          main_fsm_stateNext = LOAD_TO_CHECKER;
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
      main_fsm_stateNext = IDLE;
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
  assign score_val_valid = (playfield_update_score_regNext && ((! game_restart) && game_restart_regNext));
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
  assign motion_is_allowed = (main_fsm_stateReg == WAIT_CONTROL);
  assign fsm_is_idle = (main_fsm_stateReg == IDLE);
  assign temp_flow_region_0 = 40'h0;
  assign main_fsm_onExit_IDLE = ((main_fsm_stateNext != IDLE) && (main_fsm_stateReg == IDLE));
  assign main_fsm_onExit_READOUT = ((main_fsm_stateNext != READOUT) && (main_fsm_stateReg == READOUT));
  assign main_fsm_onExit_LOAD_TO_CHECKER = ((main_fsm_stateNext != LOAD_TO_CHECKER) && (main_fsm_stateReg == LOAD_TO_CHECKER));
  assign main_fsm_onExit_COLLISION_CHECK = ((main_fsm_stateNext != COLLISION_CHECK) && (main_fsm_stateReg == COLLISION_CHECK));
  assign main_fsm_onExit_REPORT_COLLISION = ((main_fsm_stateNext != REPORT_COLLISION) && (main_fsm_stateReg == REPORT_COLLISION));
  assign main_fsm_onExit_END_OF_COLLISION = ((main_fsm_stateNext != END_OF_COLLISION) && (main_fsm_stateReg == END_OF_COLLISION));
  assign main_fsm_onExit_PASS = ((main_fsm_stateNext != PASS) && (main_fsm_stateReg == PASS));
  assign main_fsm_onExit_WAIT_CONTROL = ((main_fsm_stateNext != WAIT_CONTROL) && (main_fsm_stateReg == WAIT_CONTROL));
  assign main_fsm_onExit_ROTATION = ((main_fsm_stateNext != ROTATION) && (main_fsm_stateReg == ROTATION));
  assign main_fsm_onExit_PRE_CHECK = ((main_fsm_stateNext != PRE_CHECK) && (main_fsm_stateReg == PRE_CHECK));
  assign main_fsm_onExit_LOCKER_WRITE_0 = ((main_fsm_stateNext != LOCKER_WRITE_0) && (main_fsm_stateReg == LOCKER_WRITE_0));
  assign main_fsm_onExit_LOCKER_WRITE_1 = ((main_fsm_stateNext != LOCKER_WRITE_1) && (main_fsm_stateReg == LOCKER_WRITE_1));
  assign main_fsm_onExit_WAIT_LOCKER_WRITE_DONE = ((main_fsm_stateNext != WAIT_LOCKER_WRITE_DONE) && (main_fsm_stateReg == WAIT_LOCKER_WRITE_DONE));
  assign main_fsm_onExit_LOCKER_READ = ((main_fsm_stateNext != LOCKER_READ) && (main_fsm_stateReg == LOCKER_READ));
  assign main_fsm_onExit_WAIT_LOCKER_READ_DONE = ((main_fsm_stateNext != WAIT_LOCKER_READ_DONE) && (main_fsm_stateReg == WAIT_LOCKER_READ_DONE));
  assign main_fsm_onExit_CLEAR_REGION = ((main_fsm_stateNext != CLEAR_REGION) && (main_fsm_stateReg == CLEAR_REGION));
  assign main_fsm_onExit_CHECK_ROW_FULL = ((main_fsm_stateNext != CHECK_ROW_FULL) && (main_fsm_stateReg == CHECK_ROW_FULL));
  assign main_fsm_onExit_ROW_REMOVE = ((main_fsm_stateNext != ROW_REMOVE) && (main_fsm_stateReg == ROW_REMOVE));
  assign main_fsm_onExit_ROW_REMOVE_DONE = ((main_fsm_stateNext != ROW_REMOVE_DONE) && (main_fsm_stateReg == ROW_REMOVE_DONE));
  assign main_fsm_onEntry_IDLE = ((main_fsm_stateNext == IDLE) && (main_fsm_stateReg != IDLE));
  assign main_fsm_onEntry_READOUT = ((main_fsm_stateNext == READOUT) && (main_fsm_stateReg != READOUT));
  assign main_fsm_onEntry_LOAD_TO_CHECKER = ((main_fsm_stateNext == LOAD_TO_CHECKER) && (main_fsm_stateReg != LOAD_TO_CHECKER));
  assign main_fsm_onEntry_COLLISION_CHECK = ((main_fsm_stateNext == COLLISION_CHECK) && (main_fsm_stateReg != COLLISION_CHECK));
  assign main_fsm_onEntry_REPORT_COLLISION = ((main_fsm_stateNext == REPORT_COLLISION) && (main_fsm_stateReg != REPORT_COLLISION));
  assign main_fsm_onEntry_END_OF_COLLISION = ((main_fsm_stateNext == END_OF_COLLISION) && (main_fsm_stateReg != END_OF_COLLISION));
  assign main_fsm_onEntry_PASS = ((main_fsm_stateNext == PASS) && (main_fsm_stateReg != PASS));
  assign main_fsm_onEntry_WAIT_CONTROL = ((main_fsm_stateNext == WAIT_CONTROL) && (main_fsm_stateReg != WAIT_CONTROL));
  assign main_fsm_onEntry_ROTATION = ((main_fsm_stateNext == ROTATION) && (main_fsm_stateReg != ROTATION));
  assign main_fsm_onEntry_PRE_CHECK = ((main_fsm_stateNext == PRE_CHECK) && (main_fsm_stateReg != PRE_CHECK));
  assign main_fsm_onEntry_LOCKER_WRITE_0 = ((main_fsm_stateNext == LOCKER_WRITE_0) && (main_fsm_stateReg != LOCKER_WRITE_0));
  assign main_fsm_onEntry_LOCKER_WRITE_1 = ((main_fsm_stateNext == LOCKER_WRITE_1) && (main_fsm_stateReg != LOCKER_WRITE_1));
  assign main_fsm_onEntry_WAIT_LOCKER_WRITE_DONE = ((main_fsm_stateNext == WAIT_LOCKER_WRITE_DONE) && (main_fsm_stateReg != WAIT_LOCKER_WRITE_DONE));
  assign main_fsm_onEntry_LOCKER_READ = ((main_fsm_stateNext == LOCKER_READ) && (main_fsm_stateReg != LOCKER_READ));
  assign main_fsm_onEntry_WAIT_LOCKER_READ_DONE = ((main_fsm_stateNext == WAIT_LOCKER_READ_DONE) && (main_fsm_stateReg != WAIT_LOCKER_READ_DONE));
  assign main_fsm_onEntry_CLEAR_REGION = ((main_fsm_stateNext == CLEAR_REGION) && (main_fsm_stateReg != CLEAR_REGION));
  assign main_fsm_onEntry_CHECK_ROW_FULL = ((main_fsm_stateNext == CHECK_ROW_FULL) && (main_fsm_stateReg != CHECK_ROW_FULL));
  assign main_fsm_onEntry_ROW_REMOVE = ((main_fsm_stateNext == ROW_REMOVE) && (main_fsm_stateReg != ROW_REMOVE));
  assign main_fsm_onEntry_ROW_REMOVE_DONE = ((main_fsm_stateNext == ROW_REMOVE_DONE) && (main_fsm_stateReg != ROW_REMOVE_DONE));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      piece_valid <= 1'b0;
      action_1 <= NO;
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
      playfield_update_score_regNext <= 1'b0;
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
      main_fsm_stateReg <= IDLE;
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
      if(game_restart) begin
        playfield_total_score <= 10'h0;
      end else begin
        if(playfield_update_score) begin
          playfield_total_score <= (playfield_total_score + temp_playfield_total_score);
        end
      end
      playfield_update_score_regNext <= playfield_update_score;
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
        READOUT : begin
        end
        LOAD_TO_CHECKER : begin
        end
        COLLISION_CHECK : begin
        end
        REPORT_COLLISION : begin
          if(!temp_when) begin
            if((action_1 == ROTATE)) begin
              piece_buffer_rot_cur <= piece_buffer_rot_backup;
            end
          end
        end
        END_OF_COLLISION : begin
          action_1 <= NO;
        end
        PASS : begin
          if(temp_when_1) begin
            checker_row_backup <= checker_row;
          end
          if(temp_when_2) begin
            piece_buffer_rot_backup <= piece_buffer_rot_cur;
          end
        end
        WAIT_CONTROL : begin
          if(move_in_left) begin
            if(!checker_overflowIfLeft) begin
              action_1 <= LEFT;
            end
          end
          if(move_in_right) begin
            if(!checker_overflowIfRight) begin
              action_1 <= RIGHT;
            end
          end
          if(move_in_down) begin
            if(!checker_overflowIfDown) begin
              checker_row <= (checker_row + 5'h01);
              action_1 <= DOWN;
            end
          end
          if(move_in_rotate) begin
            piece_buffer_rot_cur <= (piece_buffer_rot_cur + 2'b01);
          end
        end
        ROTATION : begin
          if(!temp_when_3) begin
            action_1 <= ROTATE;
          end
        end
        PRE_CHECK : begin
        end
        LOCKER_WRITE_0 : begin
        end
        LOCKER_WRITE_1 : begin
          dma_locker_dma_channel_0_enable <= 1'b1;
        end
        WAIT_LOCKER_WRITE_DONE : begin
        end
        LOCKER_READ : begin
          dma_playfield_dma_channel_2_enable <= 1'b1;
          dma_playfield_dma_base_addr <= flow_row;
          dma_playfield_dma_word_count <= 5'h03;
        end
        WAIT_LOCKER_READ_DONE : begin
        end
        CLEAR_REGION : begin
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
        CHECK_ROW_FULL : begin
          if(!playfield_isRowFull) begin
            main_fsm_will_goto_idle <= 1'b1;
          end
        end
        ROW_REMOVE : begin
        end
        ROW_REMOVE_DONE : begin
        end
        default : begin
          dma_flow_dma_channel_0_enable <= 1'b1;
          dma_checker_dma_channel_0_enable <= 1'b1;
          main_fsm_will_goto_idle <= 1'b0;
          if(piece_valid) begin
            action_1 <= PLACE;
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
        action_1 <= NO;
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
        I : begin
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
        J : begin
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
        L : begin
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
        O : begin
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
        S : begin
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
        T : begin
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

module bcd (
  input  wire          data_in_bin_valid,
  input  wire [9:0]    data_in_bin_payload,
  output wire          data_out_dec_valid,
  output wire [15:0]   data_out_dec_payload,
  input  wire          core_clk,
  input  wire          core_rst
);
  localparam BOOT = 3'd0;
  localparam IDLE = 3'd1;
  localparam ADD3_CHECK = 3'd2;
  localparam SHIFT = 3'd3;
  localparam DONE = 3'd4;

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
  wire                fsm_onExit_BOOT;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_ADD3_CHECK;
  wire                fsm_onExit_SHIFT;
  wire                fsm_onExit_DONE;
  wire                fsm_onEntry_BOOT;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_ADD3_CHECK;
  wire                fsm_onEntry_SHIFT;
  wire                fsm_onEntry_DONE;
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
      BOOT : fsm_stateReg_string = "BOOT      ";
      IDLE : fsm_stateReg_string = "IDLE      ";
      ADD3_CHECK : fsm_stateReg_string = "ADD3_CHECK";
      SHIFT : fsm_stateReg_string = "SHIFT     ";
      DONE : fsm_stateReg_string = "DONE      ";
      default : fsm_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      BOOT : fsm_stateNext_string = "BOOT      ";
      IDLE : fsm_stateNext_string = "IDLE      ";
      ADD3_CHECK : fsm_stateNext_string = "ADD3_CHECK";
      SHIFT : fsm_stateNext_string = "SHIFT     ";
      DONE : fsm_stateNext_string = "DONE      ";
      default : fsm_stateNext_string = "??????????";
    endcase
  end
  `endif

  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      IDLE : begin
        if(data_in_bin_valid) begin
          fsm_stateNext = ADD3_CHECK;
        end
      end
      ADD3_CHECK : begin
        fsm_stateNext = SHIFT;
      end
      SHIFT : begin
        if((shiftCounter == 4'b1001)) begin
          fsm_stateNext = DONE;
        end else begin
          fsm_stateNext = ADD3_CHECK;
        end
      end
      DONE : begin
        fsm_stateNext = IDLE;
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = IDLE;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = BOOT;
    end
  end

  assign fsm_wantKill = 1'b0;
  assign data_out_dec_valid = (fsm_stateReg == DONE);
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
  assign fsm_onExit_BOOT = ((fsm_stateNext != BOOT) && (fsm_stateReg == BOOT));
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_ADD3_CHECK = ((fsm_stateNext != ADD3_CHECK) && (fsm_stateReg == ADD3_CHECK));
  assign fsm_onExit_SHIFT = ((fsm_stateNext != SHIFT) && (fsm_stateReg == SHIFT));
  assign fsm_onExit_DONE = ((fsm_stateNext != DONE) && (fsm_stateReg == DONE));
  assign fsm_onEntry_BOOT = ((fsm_stateNext == BOOT) && (fsm_stateReg != BOOT));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_ADD3_CHECK = ((fsm_stateNext == ADD3_CHECK) && (fsm_stateReg != ADD3_CHECK));
  assign fsm_onEntry_SHIFT = ((fsm_stateNext == SHIFT) && (fsm_stateReg != SHIFT));
  assign fsm_onEntry_DONE = ((fsm_stateNext == DONE) && (fsm_stateReg != DONE));
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      shiftRegister <= 26'h0;
      shiftCounter <= 4'b0000;
      isProcessing <= 1'b0;
      fsm_stateReg <= BOOT;
    end else begin
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        IDLE : begin
          if(data_in_bin_valid) begin
            shiftRegister <= {16'd0, temp_shiftRegister_5};
            shiftCounter <= 4'b0000;
            isProcessing <= 1'b1;
          end
        end
        ADD3_CHECK : begin
          shiftRegister <= temp_shiftRegister;
        end
        SHIFT : begin
          shiftRegister <= (shiftRegister <<< 1);
          shiftCounter <= (shiftCounter + 4'b0001);
        end
        DONE : begin
          isProcessing <= 1'b0;
        end
        default : begin
        end
      endcase
    end
  end


endmodule
