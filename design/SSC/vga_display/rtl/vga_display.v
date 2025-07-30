// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : vga_display
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module vga_display (
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
  input  wire          draw_char_start,
  input  wire [6:0]    draw_char_word,
  input  wire [2:0]    draw_char_scale,
  input  wire [3:0]    draw_char_color,
  input  wire [7:0]    draw_x_orig,
  input  wire [6:0]    draw_y_orig,
  output wire          draw_done
);

  wire       [3:0]    core_fb_wr_data;
  wire       [8:0]    rb_y;
  wire       [8:0]    sp_y;
  wire       [8:0]    ascii_y;
  wire       [3:0]    lbcp_io_addr;
  wire       [3:0]    core_fb_rd_data;
  wire       [7:0]    core_draw_char_engine_h_cnt;
  wire       [6:0]    core_draw_char_engine_v_cnt;
  wire                core_draw_char_engine_is_running;
  wire                core_draw_char_engine_out_valid;
  wire       [3:0]    core_draw_char_engine_out_color;
  wire                core_draw_char_engine_done;
  wire       [14:0]   core_fb_addr_gen_inst_out_addr;
  wire                vga_sync_io_sof;
  wire                vga_sync_io_sol;
  wire                vga_sync_io_sos;
  wire                vga_sync_io_hSync;
  wire                vga_sync_io_vSync;
  wire                vga_sync_io_colorEn;
  wire                vga_sync_io_vColorEn;
  wire       [9:0]    vga_sync_io_x;
  wire       [9:0]    vga_sync_io_y;
  wire                rb_color_valid_1;
  wire       [3:0]    rb_color_payload_r_1;
  wire       [3:0]    rb_color_payload_g_1;
  wire       [3:0]    rb_color_payload_b_1;
  wire                sp_pix_valid;
  wire       [3:0]    sp_pix_payload;
  wire                cp_io_color_valid;
  wire       [11:0]   cp_io_color_payload;
  wire                ascii_color_valid;
  wire       [3:0]    ascii_color_payload_r;
  wire       [3:0]    ascii_color_payload_g;
  wire       [3:0]    ascii_color_payload_b;
  wire                lbcp_io_color_valid;
  wire       [11:0]   lbcp_io_color_payload;
  wire                lb_rd_out_valid;
  wire       [3:0]    lb_rd_out_payload;
  wire                io_sol_buffercc_io_dataOut;
  wire                io_sof_buffercc_io_dataOut;
  wire                lb_load_valid_buffercc_io_dataOut;
  wire       [1:0]    temp_fb_scale_cnt_valueNext;
  wire       [0:0]    temp_fb_scale_cnt_valueNext_1;
  wire       [7:0]    temp_dma_fb_fetch_en_cnt_valueNext;
  wire       [0:0]    temp_dma_fb_fetch_en_cnt_valueNext_1;
  wire       [14:0]   temp_dma_fb_fetch_addr_valueNext;
  wire       [0:0]    temp_dma_fb_fetch_addr_valueNext_1;
  reg                 done_regNext;
  reg                 lb_row_valid;
  reg                 io_colorEn_regNext;
  reg                 fb_scale_cnt_willIncrement;
  wire                fb_scale_cnt_willClear;
  reg        [1:0]    fb_scale_cnt_valueNext;
  reg        [1:0]    fb_scale_cnt_value;
  wire                fb_scale_cnt_willOverflowIfInc;
  wire                fb_scale_cnt_willOverflow;
  wire                lb_load_valid;
  reg                 lb_rd_start;
  reg                 io_hSync_delay_1;
  reg                 io_hSync_delay_2;
  reg                 io_hSync_delay_3;
  reg                 io_vSync_delay_1;
  reg                 io_vSync_delay_2;
  reg                 io_vSync_delay_3;
  reg                 io_colorEn_delay_1;
  reg                 io_colorEn_delay_2;
  reg                 io_colorEn_delay_3;
  reg                 color_delay_1_valid;
  reg        [3:0]    color_delay_1_payload_r;
  reg        [3:0]    color_delay_1_payload_g;
  reg        [3:0]    color_delay_1_payload_b;
  reg                 rb_color_valid;
  reg        [3:0]    rb_color_payload_r;
  reg        [3:0]    rb_color_payload_g;
  reg        [3:0]    rb_color_payload_b;
  wire                pixel_debug_valid;
  wire       [3:0]    pixel_debug_payload_r;
  wire       [3:0]    pixel_debug_payload_g;
  wire       [3:0]    pixel_debug_payload_b;
  wire                dma_sol;
  wire                dma_sof;
  wire                dma_row_valid;
  reg                 dma_fb_fetch_en;
  reg                 dma_fb_fetch_en_cnt_willIncrement;
  reg                 dma_fb_fetch_en_cnt_willClear;
  reg        [7:0]    dma_fb_fetch_en_cnt_valueNext;
  reg        [7:0]    dma_fb_fetch_en_cnt_value;
  wire                dma_fb_fetch_en_cnt_willOverflowIfInc;
  wire                dma_fb_fetch_en_cnt_willOverflow;
  reg                 dma_fb_fetch_addr_willIncrement;
  reg                 dma_fb_fetch_addr_willClear;
  reg        [14:0]   dma_fb_fetch_addr_valueNext;
  reg        [14:0]   dma_fb_fetch_addr_value;
  wire                dma_fb_fetch_addr_willOverflowIfInc;
  wire                dma_fb_fetch_addr_willOverflow;
  wire                dma_lb_wr_valid;
  wire       [3:0]    dma_lb_wr_payload;
  reg                 dma_fb_fetch_en_regNext;

  assign temp_fb_scale_cnt_valueNext_1 = fb_scale_cnt_willIncrement;
  assign temp_fb_scale_cnt_valueNext = {1'd0, temp_fb_scale_cnt_valueNext_1};
  assign temp_dma_fb_fetch_en_cnt_valueNext_1 = dma_fb_fetch_en_cnt_willIncrement;
  assign temp_dma_fb_fetch_en_cnt_valueNext = {7'd0, temp_dma_fb_fetch_en_cnt_valueNext_1};
  assign temp_dma_fb_fetch_addr_valueNext_1 = dma_fb_fetch_addr_willIncrement;
  assign temp_dma_fb_fetch_addr_valueNext = {14'd0, temp_dma_fb_fetch_addr_valueNext_1};
  bram_2p core_fb (
    .wr_en    (core_draw_char_engine_out_valid     ), //i
    .wr_addr  (core_fb_addr_gen_inst_out_addr[14:0]), //i
    .wr_data  (core_fb_wr_data[3:0]                ), //i
    .rd_en    (dma_fb_fetch_en                     ), //i
    .rd_addr  (dma_fb_fetch_addr_value[14:0]       ), //i
    .rd_data  (core_fb_rd_data[3:0]                ), //o
    .core_clk (core_clk                            ), //i
    .core_rst (core_rst                            )  //i
  );
  draw_char_engine core_draw_char_engine (
    .start      (draw_char_start                     ), //i
    .word       (draw_char_word[6:0]                 ), //i
    .color      (draw_char_color[3:0]                ), //i
    .scale      (draw_char_scale[2:0]                ), //i
    .h_cnt      (core_draw_char_engine_h_cnt[7:0]    ), //o
    .v_cnt      (core_draw_char_engine_v_cnt[6:0]    ), //o
    .is_running (core_draw_char_engine_is_running    ), //o
    .out_valid  (core_draw_char_engine_out_valid     ), //o
    .out_color  (core_draw_char_engine_out_color[3:0]), //o
    .done       (core_draw_char_engine_done          ), //o
    .core_clk   (core_clk                            ), //i
    .core_rst   (core_rst                            )  //i
  );
  fb_addr_gen core_fb_addr_gen_inst (
    .x        (draw_x_orig[7:0]                    ), //i
    .y        (draw_y_orig[6:0]                    ), //i
    .start    (draw_char_start                     ), //i
    .h_cnt    (core_draw_char_engine_h_cnt[7:0]    ), //i
    .v_cnt    (core_draw_char_engine_v_cnt[6:0]    ), //i
    .out_addr (core_fb_addr_gen_inst_out_addr[14:0]), //o
    .core_clk (core_clk                            ), //i
    .core_rst (core_rst                            )  //i
  );
  vga_sync_gen vga_sync (
    .io_softReset (softRest            ), //i
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
  racing_beam rb (
    .x               (vga_sync_io_x[9:0]       ), //i
    .y               (rb_y[8:0]                ), //i
    .sof             (vga_sync_io_sof          ), //i
    .color_en        (vga_sync_io_colorEn      ), //i
    .color_valid     (rb_color_valid_1         ), //o
    .color_payload_r (rb_color_payload_r_1[3:0]), //o
    .color_payload_g (rb_color_payload_g_1[3:0]), //o
    .color_payload_b (rb_color_payload_b_1[3:0]), //o
    .vga_clk         (vga_clk                  ), //i
    .vga_rst         (vga_rst                  )  //i
  );
  sprite sp (
    .x           (vga_sync_io_x[9:0] ), //i
    .y           (sp_y[8:0]          ), //i
    .sol         (vga_sync_io_sol    ), //i
    .sx_orig     (10'h00a            ), //i
    .sy_orig     (9'h014             ), //i
    .pix_valid   (sp_pix_valid       ), //o
    .pix_payload (sp_pix_payload[3:0]), //o
    .vga_clk     (vga_clk            ), //i
    .vga_rst     (vga_rst            )  //i
  );
  color_palettes cp (
    .io_addr          (sp_pix_payload[3:0]      ), //i
    .io_rd_en         (sp_pix_valid             ), //i
    .io_color_valid   (cp_io_color_valid        ), //o
    .io_color_payload (cp_io_color_payload[11:0]), //o
    .vga_clk          (vga_clk                  ), //i
    .vga_rst          (vga_rst                  )  //i
  );
  char_tile ascii (
    .x               (vga_sync_io_x[9:0]        ), //i
    .y               (ascii_y[8:0]              ), //i
    .sol             (vga_sync_io_sol           ), //i
    .sx_orig         (10'h150                   ), //i
    .sy_orig         (9'h080                    ), //i
    .color_en        (                          ), //i
    .color_valid     (ascii_color_valid         ), //o
    .color_payload_r (ascii_color_payload_r[3:0]), //o
    .color_payload_g (ascii_color_payload_g[3:0]), //o
    .color_payload_b (ascii_color_payload_b[3:0]), //o
    .vga_clk         (vga_clk                   ), //i
    .vga_rst         (vga_rst                   )  //i
  );
  color_palettes_1 lbcp (
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
    .rd_start       (lb_rd_start           ), //i
    .rd_out_valid   (lb_rd_out_valid       ), //o
    .rd_out_payload (lb_rd_out_payload[3:0]), //o
    .core_clk       (core_clk              ), //i
    .core_rst       (core_rst              ), //i
    .vga_clk        (vga_clk               ), //i
    .vga_rst        (vga_rst               )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC io_sol_buffercc (
    .io_dataIn  (vga_sync_io_sol           ), //i
    .io_dataOut (io_sol_buffercc_io_dataOut), //o
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
  assign core_fb_wr_data = core_draw_char_engine_out_color;
  assign draw_done = done_regNext;
  assign rb_y = vga_sync_io_y[8:0];
  assign sp_y = vga_sync_io_y[8:0];
  assign ascii_y = vga_sync_io_y[8:0];
  always @(*) begin
    fb_scale_cnt_willIncrement = 1'b0;
    if((lb_row_valid && ((! vga_sync_io_colorEn) && io_colorEn_regNext))) begin
      fb_scale_cnt_willIncrement = 1'b1;
    end
  end

  assign fb_scale_cnt_willClear = 1'b0;
  assign fb_scale_cnt_willOverflowIfInc = (fb_scale_cnt_value == 2'b11);
  assign fb_scale_cnt_willOverflow = (fb_scale_cnt_willOverflowIfInc && fb_scale_cnt_willIncrement);
  always @(*) begin
    fb_scale_cnt_valueNext = (fb_scale_cnt_value + temp_fb_scale_cnt_valueNext);
    if(fb_scale_cnt_willClear) begin
      fb_scale_cnt_valueNext = 2'b00;
    end
  end

  assign lb_load_valid = ((fb_scale_cnt_value == 2'b00) && lb_row_valid);
  assign lbcp_io_addr = lb_rd_out_payload;
  assign vga_hSync = io_hSync_delay_3;
  assign vga_vSync = io_vSync_delay_3;
  assign vga_colorEn = io_colorEn_delay_3;
  always @(*) begin
    if(lbcp_io_color_valid) begin
      vga_color_b = lbcp_io_color_payload[3 : 0];
      vga_color_g = lbcp_io_color_payload[7 : 4];
      vga_color_r = lbcp_io_color_payload[11 : 8];
    end else begin
      if(ascii_color_valid) begin
        vga_color_r = ascii_color_payload_r;
        vga_color_g = ascii_color_payload_g;
        vga_color_b = ascii_color_payload_b;
      end else begin
        if(cp_io_color_valid) begin
          vga_color_b = cp_io_color_payload[3 : 0];
          vga_color_g = cp_io_color_payload[7 : 4];
          vga_color_r = cp_io_color_payload[11 : 8];
        end else begin
          vga_color_r = rb_color_payload_r;
          vga_color_g = rb_color_payload_g;
          vga_color_b = rb_color_payload_b;
        end
      end
    end
  end

  assign pixel_debug_valid = vga_colorEn;
  assign pixel_debug_payload_r = vga_color_r;
  assign pixel_debug_payload_g = vga_color_g;
  assign pixel_debug_payload_b = vga_color_b;
  assign dma_sol = io_sol_buffercc_io_dataOut;
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

  assign dma_fb_fetch_en_cnt_willOverflowIfInc = (dma_fb_fetch_en_cnt_value == 8'h9f);
  assign dma_fb_fetch_en_cnt_willOverflow = (dma_fb_fetch_en_cnt_willOverflowIfInc && dma_fb_fetch_en_cnt_willIncrement);
  always @(*) begin
    if(dma_fb_fetch_en_cnt_willOverflow) begin
      dma_fb_fetch_en_cnt_valueNext = 8'h0;
    end else begin
      dma_fb_fetch_en_cnt_valueNext = (dma_fb_fetch_en_cnt_value + temp_dma_fb_fetch_en_cnt_valueNext);
    end
    if(dma_fb_fetch_en_cnt_willClear) begin
      dma_fb_fetch_en_cnt_valueNext = 8'h0;
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

  assign dma_fb_fetch_addr_willOverflowIfInc = (dma_fb_fetch_addr_value == 15'h4aff);
  assign dma_fb_fetch_addr_willOverflow = (dma_fb_fetch_addr_willOverflowIfInc && dma_fb_fetch_addr_willIncrement);
  always @(*) begin
    if(dma_fb_fetch_addr_willOverflow) begin
      dma_fb_fetch_addr_valueNext = 15'h0;
    end else begin
      dma_fb_fetch_addr_valueNext = (dma_fb_fetch_addr_value + temp_dma_fb_fetch_addr_valueNext);
    end
    if(dma_fb_fetch_addr_willClear) begin
      dma_fb_fetch_addr_valueNext = 15'h0;
    end
  end

  assign dma_lb_wr_valid = dma_fb_fetch_en_regNext;
  assign dma_lb_wr_payload = core_fb_rd_data;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      done_regNext <= 1'b0;
      dma_fb_fetch_en <= 1'b0;
      dma_fb_fetch_en_cnt_value <= 8'h0;
      dma_fb_fetch_addr_value <= 15'h0;
      dma_fb_fetch_en_regNext <= 1'b0;
    end else begin
      done_regNext <= core_draw_char_engine_done;
      dma_fb_fetch_en_cnt_value <= dma_fb_fetch_en_cnt_valueNext;
      dma_fb_fetch_addr_value <= dma_fb_fetch_addr_valueNext;
      if(dma_row_valid) begin
        if(dma_sol) begin
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
      lb_row_valid <= 1'b0;
      io_colorEn_regNext <= 1'b0;
      fb_scale_cnt_value <= 2'b00;
      lb_rd_start <= 1'b0;
    end else begin
      io_colorEn_regNext <= vga_sync_io_colorEn;
      fb_scale_cnt_value <= fb_scale_cnt_valueNext;
      if(((10'h0c8 <= vga_sync_io_y) && (vga_sync_io_y < 10'h2a8))) begin
        lb_row_valid <= 1'b1;
      end else begin
        lb_row_valid <= 1'b0;
      end
      lb_rd_start <= ((vga_sync_io_colorEn && (vga_sync_io_x == 10'h00a)) && lb_row_valid);
    end
  end

  always @(posedge vga_clk) begin
    io_hSync_delay_1 <= vga_sync_io_hSync;
    io_hSync_delay_2 <= io_hSync_delay_1;
    io_hSync_delay_3 <= io_hSync_delay_2;
    io_vSync_delay_1 <= vga_sync_io_vSync;
    io_vSync_delay_2 <= io_vSync_delay_1;
    io_vSync_delay_3 <= io_vSync_delay_2;
    io_colorEn_delay_1 <= vga_sync_io_colorEn;
    io_colorEn_delay_2 <= io_colorEn_delay_1;
    io_colorEn_delay_3 <= io_colorEn_delay_2;
    color_delay_1_valid <= rb_color_valid_1;
    color_delay_1_payload_r <= rb_color_payload_r_1;
    color_delay_1_payload_g <= rb_color_payload_g_1;
    color_delay_1_payload_b <= rb_color_payload_b_1;
    rb_color_valid <= color_delay_1_valid;
    rb_color_payload_r <= color_delay_1_payload_r;
    rb_color_payload_g <= color_delay_1_payload_g;
    rb_color_payload_b <= color_delay_1_payload_b;
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
  always @(posedge core_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
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
  wire       [1:0]    temp_rd_scale_cnt_valueNext;
  wire       [0:0]    temp_rd_scale_cnt_valueNext_1;
  reg        [7:0]    wr_addr;
  reg        [7:0]    rd_addr;
  reg                 rd_enable;
  reg                 rd_scale_cnt_willIncrement;
  reg                 rd_scale_cnt_willClear;
  reg        [1:0]    rd_scale_cnt_valueNext;
  reg        [1:0]    rd_scale_cnt_value;
  wire                rd_scale_cnt_willOverflowIfInc;
  wire                rd_scale_cnt_willOverflow;
  wire                rd_valid;
  wire                rd_inc_enable;
  wire                rd_data_valid;
  wire       [3:0]    rd_data_payload;
  wire       [3:0]    rd_rd_data;
  reg                 rd_valid_regNext;
  reg [3:0] ram [0:159];

  assign temp_rd_scale_cnt_valueNext_1 = rd_scale_cnt_willIncrement;
  assign temp_rd_scale_cnt_valueNext = {1'd0, temp_rd_scale_cnt_valueNext_1};
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

  assign rd_scale_cnt_willOverflowIfInc = (rd_scale_cnt_value == 2'b11);
  assign rd_scale_cnt_willOverflow = (rd_scale_cnt_willOverflowIfInc && rd_scale_cnt_willIncrement);
  always @(*) begin
    rd_scale_cnt_valueNext = (rd_scale_cnt_value + temp_rd_scale_cnt_valueNext);
    if(rd_scale_cnt_willClear) begin
      rd_scale_cnt_valueNext = 2'b00;
    end
  end

  assign rd_valid = ((rd_scale_cnt_value == 2'b00) && rd_enable);
  assign rd_inc_enable = (rd_scale_cnt_willOverflowIfInc && rd_enable);
  assign rd_rd_data = ram_spinal_port1;
  assign rd_data_valid = rd_valid_regNext;
  assign rd_data_payload = rd_rd_data;
  assign rd_out_valid = rd_data_valid;
  assign rd_out_payload = rd_data_payload;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      wr_addr <= 8'h0;
    end else begin
      if(wr_in_valid) begin
        if((wr_addr == 8'h9f)) begin
          wr_addr <= 8'h0;
        end else begin
          wr_addr <= (wr_addr + 8'h01);
        end
      end
    end
  end

  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      rd_addr <= 8'h0;
      rd_enable <= 1'b0;
      rd_scale_cnt_value <= 2'b00;
      rd_valid_regNext <= 1'b0;
    end else begin
      rd_scale_cnt_value <= rd_scale_cnt_valueNext;
      if(rd_start) begin
        rd_enable <= 1'b1;
      end else begin
        if(((rd_addr == 8'h9f) && rd_scale_cnt_willOverflowIfInc)) begin
          rd_enable <= 1'b0;
        end
      end
      if(rd_start) begin
        rd_addr <= 8'h0;
      end else begin
        if(rd_inc_enable) begin
          rd_addr <= (rd_addr + 8'h01);
        end
      end
      rd_valid_regNext <= rd_valid;
    end
  end


endmodule

module color_palettes_1 (
  input  wire [3:0]    io_addr,
  input  wire          io_rd_en,
  output wire          io_color_valid,
  output wire [11:0]   io_color_payload,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  reg        [11:0]   rom_spinal_port0;
  reg                 io_rd_en_regNext;
  reg [11:0] rom [0:15];

  initial begin
    $readmemb("vga_display.v_toplevel_lbcp_rom.bin",rom);
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

module char_tile (
  input  wire [9:0]    x,
  input  wire [8:0]    y,
  input  wire          sol,
  input  wire [9:0]    sx_orig,
  input  wire [8:0]    sy_orig,
  input  wire          color_en,
  output wire          color_valid,
  output wire [3:0]    color_payload_r,
  output wire [3:0]    color_payload_g,
  output wire [3:0]    color_payload_b,
  input  wire          vga_clk,
  input  wire          vga_rst
);
  localparam IDLE = 3'd0;
  localparam LINE_START = 3'd1;
  localparam WAIT_POS = 3'd2;
  localparam FETCG_PIXEL = 3'd3;
  localparam LINE_END = 3'd4;

  wire       [7:0]    ascii_font16X8_inst_font_bitmap_byte;
  wire       [9:0]    temp_y_diff;
  wire       [9:0]    temp_y_diff_1;
  wire       [6:0]    temp_x_cnt_valueNext;
  wire       [0:0]    temp_x_cnt_valueNext_1;
  wire       [7:0]    temp_when;
  wire       [13:0]   temp_rom_addr_block_1;
  wire       [13:0]   temp_rom_addr_block_2;
  wire       [4:0]    temp_rom_addr_block_3;
  wire       [13:0]   temp_rom_addr_block_4;
  wire       [3:0]    temp_rom_addr_block_5;
  wire       [10:0]   temp_rom_addr;
  wire       [8:0]    temp_rom_addr_1;
  wire       [3:0]    temp_rom_addr_2;
  wire       [9:0]    y_diff;
  wire       [8:0]    y_diff_scale;
  wire                y_valid;
  reg        [9:0]    sx_early_r;
  wire                sop;
  reg        [10:0]   rom_addr_block;
  reg        [10:0]   rom_addr;
  reg                 draw_running;
  reg                 scale_cnt_willIncrement;
  reg                 scale_cnt_willClear;
  reg        [0:0]    scale_cnt_valueNext;
  reg        [0:0]    scale_cnt_value;
  wire                scale_cnt_willOverflowIfInc;
  wire                scale_cnt_willOverflow;
  reg                 x_cnt_willIncrement;
  reg                 x_cnt_willClear;
  reg        [6:0]    x_cnt_valueNext;
  reg        [6:0]    x_cnt_value;
  wire                x_cnt_willOverflowIfInc;
  wire                x_cnt_willOverflow;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [2:0]    temp_x_pixel_offset;
  reg        [2:0]    x_pixel_offset;
  reg        [3:0]    color_r;
  reg        [3:0]    color_g;
  reg        [3:0]    color_b;
  reg                 draw_running_delay_1;
  reg                 draw_running_delay_2;
  reg                 draw_running_delay_3;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire       [8:0]    temp_rom_addr_block;
  wire                fsm_onExit_IDLE;
  wire                fsm_onExit_LINE_START;
  wire                fsm_onExit_WAIT_POS;
  wire                fsm_onExit_FETCG_PIXEL;
  wire                fsm_onExit_LINE_END;
  wire                fsm_onEntry_IDLE;
  wire                fsm_onEntry_LINE_START;
  wire                fsm_onEntry_WAIT_POS;
  wire                fsm_onEntry_FETCG_PIXEL;
  wire                fsm_onEntry_LINE_END;
  `ifndef SYNTHESIS
  reg [87:0] fsm_stateReg_string;
  reg [87:0] fsm_stateNext_string;
  `endif


  assign temp_y_diff = {1'b0,y};
  assign temp_y_diff_1 = {1'b0,sy_orig};
  assign temp_x_cnt_valueNext_1 = x_cnt_willIncrement;
  assign temp_x_cnt_valueNext = {6'd0, temp_x_cnt_valueNext_1};
  assign temp_when = {ascii_font16X8_inst_font_bitmap_byte[0],{ascii_font16X8_inst_font_bitmap_byte[1],{ascii_font16X8_inst_font_bitmap_byte[2],{ascii_font16X8_inst_font_bitmap_byte[3],{ascii_font16X8_inst_font_bitmap_byte[4],{ascii_font16X8_inst_font_bitmap_byte[5],{ascii_font16X8_inst_font_bitmap_byte[6],ascii_font16X8_inst_font_bitmap_byte[7]}}}}}}};
  assign temp_rom_addr_block_1 = (temp_rom_addr_block_2 + temp_rom_addr_block_4);
  assign temp_rom_addr_block_2 = (temp_rom_addr_block_3 * 9'h100);
  assign temp_rom_addr_block_3 = (temp_rom_addr_block >>> 3'd4);
  assign temp_rom_addr_block_5 = temp_rom_addr_block[3 : 0];
  assign temp_rom_addr_block_4 = {10'd0, temp_rom_addr_block_5};
  assign temp_rom_addr_1 = (temp_rom_addr_2 * 5'h10);
  assign temp_rom_addr = {2'd0, temp_rom_addr_1};
  assign temp_rom_addr_2 = (x_cnt_value >>> 2'd3);
  ascii_font16x8 #(
    .wordWidth    (8 ),
    .addressWidth (11)
  ) ascii_font16X8_inst (
    .clk              (vga_clk                                  ), //i
    .font_bitmap_addr (rom_addr[10:0]                           ), //i
    .font_bitmap_byte (ascii_font16X8_inst_font_bitmap_byte[7:0])  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      IDLE : fsm_stateReg_string = "IDLE       ";
      LINE_START : fsm_stateReg_string = "LINE_START ";
      WAIT_POS : fsm_stateReg_string = "WAIT_POS   ";
      FETCG_PIXEL : fsm_stateReg_string = "FETCG_PIXEL";
      LINE_END : fsm_stateReg_string = "LINE_END   ";
      default : fsm_stateReg_string = "???????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      IDLE : fsm_stateNext_string = "IDLE       ";
      LINE_START : fsm_stateNext_string = "LINE_START ";
      WAIT_POS : fsm_stateNext_string = "WAIT_POS   ";
      FETCG_PIXEL : fsm_stateNext_string = "FETCG_PIXEL";
      LINE_END : fsm_stateNext_string = "LINE_END   ";
      default : fsm_stateNext_string = "???????????";
    endcase
  end
  `endif

  assign y_diff = ($signed(temp_y_diff) - $signed(temp_y_diff_1));
  assign y_diff_scale = (y_diff >>> 1'd1);
  assign y_valid = ((! y_diff[9]) && ($signed(y_diff_scale) < $signed(9'h080)));
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
          fsm_stateNext = FETCG_PIXEL;
        end
      end
      FETCG_PIXEL : begin
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

  assign scale_cnt_willOverflowIfInc = (scale_cnt_value == 1'b1);
  assign scale_cnt_willOverflow = (scale_cnt_willOverflowIfInc && scale_cnt_willIncrement);
  always @(*) begin
    scale_cnt_valueNext = (scale_cnt_value + scale_cnt_willIncrement);
    if(scale_cnt_willClear) begin
      scale_cnt_valueNext = 1'b0;
    end
  end

  always @(*) begin
    x_cnt_willIncrement = 1'b0;
    if(scale_cnt_willOverflowIfInc) begin
      x_cnt_willIncrement = 1'b1;
    end
  end

  assign x_cnt_willOverflowIfInc = (x_cnt_value == 7'h7f);
  assign x_cnt_willOverflow = (x_cnt_willOverflowIfInc && x_cnt_willIncrement);
  always @(*) begin
    x_cnt_valueNext = (x_cnt_value + temp_x_cnt_valueNext);
    if(x_cnt_willClear) begin
      x_cnt_valueNext = 7'h0;
    end
  end

  assign fsm_wantExit = 1'b0;
  assign fsm_wantKill = 1'b0;
  assign color_payload_r = color_r;
  assign color_payload_g = color_g;
  assign color_payload_b = color_b;
  assign color_valid = draw_running_delay_3;
  assign temp_rom_addr_block = y_diff_scale;
  assign fsm_onExit_IDLE = ((fsm_stateNext != IDLE) && (fsm_stateReg == IDLE));
  assign fsm_onExit_LINE_START = ((fsm_stateNext != LINE_START) && (fsm_stateReg == LINE_START));
  assign fsm_onExit_WAIT_POS = ((fsm_stateNext != WAIT_POS) && (fsm_stateReg == WAIT_POS));
  assign fsm_onExit_FETCG_PIXEL = ((fsm_stateNext != FETCG_PIXEL) && (fsm_stateReg == FETCG_PIXEL));
  assign fsm_onExit_LINE_END = ((fsm_stateNext != LINE_END) && (fsm_stateReg == LINE_END));
  assign fsm_onEntry_IDLE = ((fsm_stateNext == IDLE) && (fsm_stateReg != IDLE));
  assign fsm_onEntry_LINE_START = ((fsm_stateNext == LINE_START) && (fsm_stateReg != LINE_START));
  assign fsm_onEntry_WAIT_POS = ((fsm_stateNext == WAIT_POS) && (fsm_stateReg != WAIT_POS));
  assign fsm_onEntry_FETCG_PIXEL = ((fsm_stateNext == FETCG_PIXEL) && (fsm_stateReg != FETCG_PIXEL));
  assign fsm_onEntry_LINE_END = ((fsm_stateNext == LINE_END) && (fsm_stateReg != LINE_END));
  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      sx_early_r <= 10'h0;
      rom_addr_block <= 11'h0;
      rom_addr <= 11'h0;
      scale_cnt_value <= 1'b0;
      x_cnt_value <= 7'h0;
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
          rom_addr_block <= temp_rom_addr_block_1[10:0];
        end
        FETCG_PIXEL : begin
          rom_addr <= (rom_addr_block + temp_rom_addr);
        end
        LINE_END : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge vga_clk) begin
    temp_x_pixel_offset <= x_cnt_value[2 : 0];
    x_pixel_offset <= temp_x_pixel_offset;
    if(temp_when[x_pixel_offset]) begin
      color_b <= 4'b1100;
      color_g <= 4'b1100;
      color_r <= 4'b1100;
    end else begin
      color_b <= 4'b1010;
      color_g <= 4'b1100;
      color_r <= 4'b0000;
    end
    draw_running_delay_1 <= draw_running;
    draw_running_delay_2 <= draw_running_delay_1;
    draw_running_delay_3 <= draw_running_delay_2;
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
  reg [11:0] rom [0:15];

  initial begin
    $readmemb("vga_display.v_toplevel_cp_rom.bin",rom);
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

module sprite (
  input  wire [9:0]    x,
  input  wire [8:0]    y,
  input  wire          sol,
  input  wire [9:0]    sx_orig,
  input  wire [8:0]    sy_orig,
  output wire          pix_valid,
  output wire [3:0]    pix_payload,
  input  wire          vga_clk,
  input  wire          vga_rst
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
    $readmemb("vga_display.v_toplevel_sp_rom.bin",rom);
  end
  always @(posedge vga_clk) begin
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
  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
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

  always @(posedge vga_clk) begin
    draw_running_delay_1 <= draw_running;
    draw_running_delay_2 <= draw_running_delay_1;
  end


endmodule

module racing_beam (
  input  wire [9:0]    x,
  input  wire [8:0]    y,
  input  wire          sof,
  input  wire          color_en,
  output wire          color_valid,
  output wire [3:0]    color_payload_r,
  output wire [3:0]    color_payload_g,
  output wire [3:0]    color_payload_b,
  input  wire          vga_clk,
  input  wire          vga_rst
);

  wire                temp_when;
  wire                temp_when_1;
  wire       [3:0]    temp_roster_bar_color_r;
  wire       [3:0]    temp_roster_bar_color_r_1;
  wire       [3:0]    temp_roster_bar_color_g;
  wire       [3:0]    temp_roster_bar_color_g_1;
  wire       [3:0]    temp_roster_bar_color_b;
  wire       [3:0]    temp_roster_bar_color_b_1;
  reg                 color_en_regNext;
  wire                eol;
  reg        [3:0]    roster_bar_color_r;
  reg        [3:0]    roster_bar_color_g;
  reg        [3:0]    roster_bar_color_b;
  reg                 roster_bar_inc;
  reg        [3:0]    roster_bar_color_cnt;
  reg        [0:0]    roster_bar_line_cnt;
  reg        [3:0]    hitomezashi_color_r;
  reg        [3:0]    hitomezashi_color_g;
  reg        [3:0]    hitomezashi_color_b;
  wire       [39:0]   hitomezashi_vStart;
  wire       [29:0]   hitomezashi_hStart;
  reg                 hitomezashi_last_h_stitch;
  wire                hitomezashi_v_line;
  wire                hitomezashi_h_line;
  wire                hitomezashi_v_on;
  wire                hitomezashi_h_on;
  wire                hitomezashi_stitch;
  reg                 color_en_regNext_1;

  assign temp_when = (roster_bar_line_cnt == 1'b1);
  assign temp_when_1 = (roster_bar_color_cnt == 4'b1111);
  assign temp_roster_bar_color_r = (roster_bar_color_r + 4'b0001);
  assign temp_roster_bar_color_r_1 = (roster_bar_color_r - 4'b0001);
  assign temp_roster_bar_color_g = (roster_bar_color_g + 4'b0001);
  assign temp_roster_bar_color_g_1 = (roster_bar_color_g - 4'b0001);
  assign temp_roster_bar_color_b = (roster_bar_color_b + 4'b0001);
  assign temp_roster_bar_color_b_1 = (roster_bar_color_b - 4'b0001);
  assign eol = ((! color_en) && color_en_regNext);
  assign hitomezashi_vStart = 40'hb7ab5cb286;
  assign hitomezashi_hStart = 30'h15c2c25d;
  assign hitomezashi_v_line = (x[3 : 0] == 4'b0000);
  assign hitomezashi_h_line = (y[3 : 0] == 4'b0000);
  assign hitomezashi_v_on = (y[4] ^ hitomezashi_vStart[x[9 : 4]]);
  assign hitomezashi_h_on = (x[4] ^ hitomezashi_hStart[y[8 : 4]]);
  assign hitomezashi_stitch = (((hitomezashi_v_line && hitomezashi_v_on) || (hitomezashi_h_line && hitomezashi_h_on)) || hitomezashi_last_h_stitch);
  assign color_payload_r = roster_bar_color_r;
  assign color_payload_g = roster_bar_color_g;
  assign color_payload_b = roster_bar_color_b;
  assign color_valid = color_en_regNext_1;
  always @(posedge vga_clk) begin
    color_en_regNext <= color_en;
    if(sof) begin
      roster_bar_color_b <= 4'b0110;
      roster_bar_color_g <= 4'b0010;
      roster_bar_color_r <= 4'b0001;
    end else begin
      if(eol) begin
        if(temp_when) begin
          if(!temp_when_1) begin
            roster_bar_color_r <= (roster_bar_inc ? temp_roster_bar_color_r : temp_roster_bar_color_r_1);
            roster_bar_color_g <= (roster_bar_inc ? temp_roster_bar_color_g : temp_roster_bar_color_g_1);
            roster_bar_color_b <= (roster_bar_inc ? temp_roster_bar_color_b : temp_roster_bar_color_b_1);
          end
        end
      end
    end
    hitomezashi_color_r <= (hitomezashi_stitch ? 4'b1111 : 4'b0001);
    hitomezashi_color_g <= (hitomezashi_stitch ? 4'b1100 : 4'b0011);
    hitomezashi_color_b <= (hitomezashi_stitch ? 4'b0000 : 4'b0111);
    color_en_regNext_1 <= color_en;
  end

  always @(posedge vga_clk or posedge vga_rst) begin
    if(vga_rst) begin
      roster_bar_inc <= 1'b0;
      roster_bar_color_cnt <= 4'b0000;
      roster_bar_line_cnt <= 1'b0;
      hitomezashi_last_h_stitch <= 1'b0;
    end else begin
      if(sof) begin
        roster_bar_inc <= 1'b1;
      end else begin
        if(eol) begin
          if(temp_when) begin
            roster_bar_line_cnt <= 1'b0;
            if(temp_when_1) begin
              roster_bar_inc <= (! roster_bar_inc);
              roster_bar_color_cnt <= 4'b0000;
            end else begin
              roster_bar_color_cnt <= (roster_bar_color_cnt + 4'b0001);
            end
          end else begin
            roster_bar_line_cnt <= (roster_bar_line_cnt + 1'b1);
          end
        end
      end
      hitomezashi_last_h_stitch <= (hitomezashi_h_line && hitomezashi_h_on);
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

module fb_addr_gen (
  input  wire [7:0]    x,
  input  wire [6:0]    y,
  input  wire          start,
  input  wire [7:0]    h_cnt,
  input  wire [6:0]    v_cnt,
  output wire [14:0]   out_addr,
  input  wire          core_clk,
  input  wire          core_rst
);

  wire       [14:0]   temp_v_next_in_fb;
  wire       [14:0]   temp_v_next_in_fb_1;
  wire       [14:0]   temp_addr;
  reg        [7:0]    x_reg;
  reg        [6:0]    y_reg;
  wire       [6:0]    v_next;
  wire       [14:0]   v_next_in_fb;
  reg        [7:0]    h_reg;
  reg        [14:0]   v_reg;
  reg        [14:0]   addr;

  assign temp_v_next_in_fb = {8'd0, v_next};
  assign temp_v_next_in_fb_1 = {8'd0, v_next};
  assign temp_addr = {7'd0, h_reg};
  assign v_next = (y_reg + v_cnt);
  assign v_next_in_fb = (temp_v_next_in_fb + temp_v_next_in_fb_1);
  assign out_addr = addr;
  always @(posedge core_clk or posedge core_rst) begin
    if(core_rst) begin
      x_reg <= 8'h0;
      y_reg <= 7'h0;
      h_reg <= 8'h0;
      v_reg <= 15'h0;
      addr <= 15'h0;
    end else begin
      if(start) begin
        x_reg <= x;
      end
      if(start) begin
        y_reg <= y;
      end
      h_reg <= (x_reg + h_cnt);
      v_reg <= v_next_in_fb;
      addr <= (temp_addr + v_reg);
    end
  end


endmodule

module draw_char_engine (
  input  wire          start,
  input  wire [6:0]    word,
  input  wire [3:0]    color,
  input  wire [2:0]    scale,
  output wire [7:0]    h_cnt,
  output wire [6:0]    v_cnt,
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
  reg        [7:0]    h_cnt_1;
  reg        [6:0]    v_cnt_1;
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
      h_cnt_1 <= 8'h0;
      v_cnt_1 <= 7'h0;
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
          h_cnt_1 <= 8'h0;
        end else begin
          h_cnt_1 <= (h_cnt_1 + 8'h01);
        end
      end
      if(rom_rd_en) begin
        if(y_last_cycle) begin
          v_cnt_1 <= 7'h0;
        end else begin
          if(x_last_cycle) begin
            v_cnt_1 <= (v_cnt_1 + 7'h01);
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
  input  wire [14:0]   wr_addr,
  input  wire [3:0]    wr_data,
  input  wire          rd_en,
  input  wire [14:0]   rd_addr,
  output wire [3:0]    rd_data,
  input  wire          core_clk,
  input  wire          core_rst
);

  reg        [3:0]    memory_spinal_port1;
  reg [3:0] memory [0:19199];

  initial begin
    $readmemb("vga_display.v_toplevel_core_fb_memory.bin",memory);
  end
  always @(posedge core_clk) begin
    if(wr_en) begin
      memory[wr_addr] <= wr_data;
    end
  end

  always @(posedge core_clk) begin
    if(rd_en) begin
      memory_spinal_port1 <= memory[rd_addr];
    end
  end

  assign rd_data = memory_spinal_port1;

endmodule
