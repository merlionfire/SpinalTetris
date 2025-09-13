// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : display_top
// Git hash  : 0ba87d8f6dc393cafd790a511174b6e6b4938351

`timescale 1ns/1ps

module display_top (
  output wire          vga_vSync,
  output wire          vga_hSync,
  output wire          vga_colorEn,
  output reg  [3:0]    vga_color_r,
  output reg  [3:0]    vga_color_g,
  output reg  [3:0]    vga_color_b,
  input  wire          game_restart,
  input  wire          core_clk,
  input  wire          core_rst,
  input  wire          vga_clk,
  input  wire          vga_rst,
  input  wire          row_val_valid,
  input  wire [9:0]    row_val_payload,
  input  wire          game_start,
  input  wire          debug_draw_char_start,
  input  wire [6:0]    debug_draw_char_word,
  input  wire [2:0]    debug_draw_char_scale,
  input  wire [3:0]    debug_draw_char_color,
  input  wire          debug_draw_block_start,
  input  wire [8:0]    debug_draw_x_orig,
  input  wire [7:0]    debug_draw_y_orig,
  input  wire [7:0]    debug_draw_block_width,
  input  wire [7:0]    debug_draw_block_height,
  input  wire [3:0]    debug_draw_block_in_color,
  input  wire [3:0]    debug_draw_block_pat_color,
  input  wire [1:0]    debug_draw_block_fill_pattern,
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
  wire                io_sos_buffercc_io_dataOut;
  wire                io_sof_buffercc_io_dataOut;
  wire                lb_load_valid_buffercc_io_dataOut;
  wire       [8:0]    temp_dma_fb_fetch_en_cnt_valueNext;
  wire       [0:0]    temp_dma_fb_fetch_en_cnt_valueNext_1;
  wire       [16:0]   temp_dma_fb_fetch_addr_valueNext;
  wire       [0:0]    temp_dma_fb_fetch_addr_valueNext_1;
  wire       [1:0]    mux_sel;
  reg        [8:0]    temp_h_cnt;
  reg        [7:0]    temp_v_cnt;
  reg                 temp_draw_done;
  reg                 io_colorEn_regNext;
  reg                 fb_scale_cnt_willIncrement;
  wire                fb_scale_cnt_willClear;
  reg        [0:0]    fb_scale_cnt_valueNext;
  reg        [0:0]    fb_scale_cnt_value;
  wire                fb_scale_cnt_willOverflowIfInc;
  wire                fb_scale_cnt_willOverflow;
  wire                lb_load_valid;
  reg                 io_hSync_delay_1;
  reg                 io_hSync_delay_2;
  reg                 io_vSync_delay_1;
  reg                 io_vSync_delay_2;
  reg                 io_colorEn_delay_1;
  reg                 io_colorEn_delay_2;
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
    .start      (debug_draw_char_start            ), //i
    .word       (debug_draw_char_word[6:0]        ), //i
    .color      (debug_draw_char_color[3:0]       ), //i
    .scale      (debug_draw_char_scale[2:0]       ), //i
    .h_cnt      (draw_char_engine_1_h_cnt[8:0]    ), //o
    .v_cnt      (draw_char_engine_1_v_cnt[7:0]    ), //o
    .is_running (draw_char_engine_1_is_running    ), //o
    .out_valid  (draw_char_engine_1_out_valid     ), //o
    .out_color  (draw_char_engine_1_out_color[3:0]), //o
    .done       (draw_char_engine_1_done          ), //o
    .core_clk   (core_clk                         ), //i
    .core_rst   (core_rst                         )  //i
  );
  draw_block_engine draw_block_engine_1 (
    .start        (debug_draw_block_start            ), //i
    .width        (debug_draw_block_width[7:0]       ), //i
    .height       (debug_draw_block_height[7:0]      ), //i
    .in_color     (debug_draw_block_in_color[3:0]    ), //i
    .pat_color    (debug_draw_block_pat_color[3:0]   ), //i
    .fill_pattern (debug_draw_block_fill_pattern[1:0]), //i
    .h_cnt        (draw_block_engine_1_h_cnt[8:0]    ), //o
    .v_cnt        (draw_block_engine_1_v_cnt[7:0]    ), //o
    .is_running   (draw_block_engine_1_is_running    ), //o
    .out_valid    (draw_block_engine_1_out_valid     ), //o
    .out_color    (draw_block_engine_1_out_color[3:0]), //o
    .done         (draw_block_engine_1_done          ), //o
    .core_clk     (core_clk                          ), //i
    .core_rst     (core_rst                          )  //i
  );
  fb_addr_gen fb_addr_gen_inst (
    .x        (debug_draw_x_orig[8:0]         ), //i
    .y        (debug_draw_y_orig[7:0]         ), //i
    .start    (fb_addr_gen_inst_start         ), //i
    .h_cnt    (temp_h_cnt[8:0]                ), //i
    .v_cnt    (temp_v_cnt[7:0]                ), //i
    .out_addr (fb_addr_gen_inst_out_addr[16:0]), //o
    .core_clk (core_clk                       ), //i
    .core_rst (core_rst                       )  //i
  );
  display_controller draw_controller (
    .draw_openning_start     (dma_sof                                     ), //i
    .game_start              (1'b0                                        ), //i
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
    .io_softReset (game_restart            ), //i
    .io_sof       (vga_sync_io_sof     ), //o
    .io_sol       (vga_sync_io_sol     ), //o
    .io_sos       (vga_sync_io_sos     ), //o
    .io_hSync     (vga_sync_io_hSync   ), //o
    .io_vSync     (vga_sync_io_vSync   ), //o
    .io_colorEn   (vga_sync_io_colorEn ), //o
    .io_vColorEn  (vga_sync_io_vColorEn), //o
    .io_x         (vga_sync_io_x[9:0]  ), //o
    .io_y         (vga_sync_io_y[9:0]  ), //o
    .vga_clk      (vga_clk             ), //i
    .vga_rst      (vga_rst             )  //i
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
    .rd_start       (vga_sync_io_sol       ), //i
    .rd_out_valid   (lb_rd_out_valid       ), //o
    .rd_out_payload (lb_rd_out_payload[3:0]), //o
    .core_clk       (core_clk              ), //i
    .core_rst       (core_rst              ), //i
    .vga_clk        (vga_clk               ), //i
    .vga_rst        (vga_rst               )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC io_sos_buffercc (
    .io_dataIn  (vga_sync_io_sos           ), //i
    .io_dataOut (io_sos_buffercc_io_dataOut), //o
    .core_clk   (core_clk                  ), //i
    .core_rst   (core_rst                  )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC io_sof_buffercc (
    .io_dataIn  (vga_sync_io_sof           ), //i
    .io_dataOut (io_sof_buffercc_io_dataOut), //o
    .core_clk   (core_clk                  ), //i
    .core_rst   (core_rst                  )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC lb_load_valid_buffercc (
    .io_dataIn  (lb_load_valid                    ), //i
    .io_dataOut (lb_load_valid_buffercc_io_dataOut), //o
    .core_clk   (core_clk                         ), //i
    .core_rst   (core_rst                         )  //i
  );
  assign draw_field_done = draw_controller_draw_field_done;
  assign mux_sel = {draw_char_engine_1_is_running,draw_block_engine_1_is_running};
  assign fb_addr_gen_inst_start = (debug_draw_char_start || debug_draw_block_start);
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
    if(((! vga_sync_io_colorEn) && io_colorEn_regNext)) begin
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
  assign lbcp_io_addr = lb_rd_out_payload;
  assign vga_hSync = io_hSync_delay_2;
  assign vga_vSync = io_vSync_delay_2;
  assign vga_colorEn = io_colorEn_delay_2;
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
  assign temp_dma_sos = io_sos_buffercc_io_dataOut;
  assign dma_sos = (temp_dma_sos && (! temp_dma_sos_1));
  assign dma_sof = io_sof_buffercc_io_dataOut;
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

  assign dma_fb_fetch_en_cnt_willOverflowIfInc = (dma_fb_fetch_en_cnt_value == 9'h13f);
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

  assign dma_fb_fetch_addr_willOverflowIfInc = (dma_fb_fetch_addr_value == 17'h12bff);
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
      io_colorEn_regNext <= 1'b0;
      fb_scale_cnt_value <= 1'b0;
      is_bg_color <= 1'b0;
    end else begin
      io_colorEn_regNext <= vga_sync_io_colorEn;
      fb_scale_cnt_value <= fb_scale_cnt_valueNext;
      is_bg_color <= (lb_rd_out_payload == 4'b0010);
    end
  end

  always @(posedge vga_clk) begin
    io_hSync_delay_1 <= vga_sync_io_hSync;
    io_hSync_delay_2 <= io_hSync_delay_1;
    io_vSync_delay_1 <= vga_sync_io_vSync;
    io_vSync_delay_2 <= io_vSync_delay_1;
    io_colorEn_delay_1 <= vga_sync_io_colorEn;
    io_colorEn_delay_2 <= io_colorEn_delay_1;
  end


endmodule

//BufferCC_2 replaced by BufferCC

//BufferCC_1 replaced by BufferCC

module BufferCC (
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
  (* ram_style = "distributed" *) reg [3:0] ram [0:319];

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
        if((wr_addr == 9'h13f)) begin
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
        if(((rd_addr == 9'h13f) && rd_scale_cnt_willOverflowIfInc)) begin
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
    $readmemb("display_top.v_toplevel_lbcp_rom.bin",rom);
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
    $readmemb("display_top.v_toplevel_draw_controller_rom.bin",rom);
  end
  assign rom_spinal_port0 = rom[cnt_value];
  initial begin
    $readmemb("display_top.v_toplevel_draw_controller_wall_rom.bin",wall_rom);
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
  always @(*) begin
    if(cnt_willOverflow) begin
      cnt_valueNext = 4'b0000;
    end else begin
      cnt_valueNext = (cnt_value + temp_cnt_valueNext);
    end
    if(cnt_willClear) begin
      cnt_valueNext = 4'b0000;
    end
  end

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
        x <= 9'h03b;
        y <= 8'h14;
      end
      if(draw_field_done) begin
        x <= 9'h0;
        y <= 8'h0;
      end else begin
        if(col_cnt_willOverflow) begin
          x <= 9'h03b;
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

  wire       [10:0]   temp_v_next_in_fb;
  wire       [9:0]    temp_v_next_in_fb_1;
  wire       [10:0]   temp_v_next_in_fb_2;
  wire       [16:0]   temp_addr;
  wire       [16:0]   temp_addr_1;
  reg        [8:0]    x_reg;
  reg        [7:0]    y_reg;
  wire       [7:0]    v_next;
  wire       [10:0]   v_next_in_fb;
  reg        [8:0]    h_reg;
  reg        [10:0]   v_reg;
  reg        [16:0]   addr;

  assign temp_v_next_in_fb_1 = ({2'd0,v_next} <<< 2'd2);
  assign temp_v_next_in_fb = {1'd0, temp_v_next_in_fb_1};
  assign temp_v_next_in_fb_2 = {3'd0, v_next};
  assign temp_addr = {8'd0, h_reg};
  assign temp_addr_1 = ({6'd0,v_reg} <<< 3'd6);
  assign v_next = (y_reg + v_cnt);
  assign v_next_in_fb = (temp_v_next_in_fb + temp_v_next_in_fb_2);
  assign out_addr = addr;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      x_reg <= 9'h0;
      y_reg <= 8'h0;
      h_reg <= 9'h0;
      v_reg <= 11'h0;
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
  (* ram_style = "block" *) reg [3:0] memory [0:76799];

  assign temp_full_addr_valueNext_1 = full_addr_willIncrement;
  assign temp_full_addr_valueNext = {16'd0, temp_full_addr_valueNext_1};
  initial begin
    $readmemb("display_top.v_toplevel_fb_memory.bin",memory);
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
  assign full_addr_willOverflowIfInc = (full_addr_value == 17'h12bff);
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
