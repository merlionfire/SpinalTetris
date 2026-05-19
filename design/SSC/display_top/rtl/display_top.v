// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : display_top
// Git hash  : 368ea5849555199e0e9a28d11425797e410264a4

`timescale 1ns/1ps

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
  wire       [8:0]    temp_dmaArea_lineFetchPixelCounter_valueNext;
  wire       [0:0]    temp_dmaArea_lineFetchPixelCounter_valueNext_1;
  wire       [16:0]   temp_dmaArea_frameBufferReadAddr_valueNext;
  wire       [0:0]    temp_dmaArea_frameBufferReadAddr_valueNext_1;
  wire       [1:0]    activeDrawEngineMask;
  wire                drawEnginesOverlap;
  reg        [8:0]    temp_h_cnt;
  reg        [7:0]    temp_v_cnt;
  reg                 temp_draw_done;
  reg                 io_colorEn_regNext;
  reg                 fbScaleCounter_willIncrement;
  wire                fbScaleCounter_willClear;
  reg        [0:0]    fbScaleCounter_valueNext;
  reg        [0:0]    fbScaleCounter_value;
  wire                fbScaleCounter_willOverflowIfInc;
  wire                fbScaleCounter_willOverflow;
  wire                lineFetchAllowed;
  wire                lineFetchPulse;
  reg                 line_fetch_toggle;
  reg                 frame_start_toggle;
  reg                 io_hSync_delay_1;
  reg                 io_hSync_delay_2;
  reg                 io_vSync_delay_1;
  reg                 io_vSync_delay_2;
  reg                 io_colorEn_delay_1;
  reg                 io_colorEn_delay_2;
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
  reg                 dmaArea_lineFetchPixelCounter_willClear;
  reg        [8:0]    dmaArea_lineFetchPixelCounter_valueNext;
  reg        [8:0]    dmaArea_lineFetchPixelCounter_value;
  wire                dmaArea_lineFetchPixelCounter_willOverflowIfInc;
  wire                dmaArea_lineFetchPixelCounter_willOverflow;
  reg                 dmaArea_frameBufferReadAddr_willIncrement;
  reg                 dmaArea_frameBufferReadAddr_willClear;
  reg        [16:0]   dmaArea_frameBufferReadAddr_valueNext;
  reg        [16:0]   dmaArea_frameBufferReadAddr_value;
  wire                dmaArea_frameBufferReadAddr_willOverflowIfInc;
  wire                dmaArea_frameBufferReadAddr_willOverflow;
  wire                dmaArea_lineFetchWhileBusy;

  assign temp_dmaArea_lineFetchPixelCounter_valueNext_1 = dmaArea_lineFetchPixelCounter_willIncrement;
  assign temp_dmaArea_lineFetchPixelCounter_valueNext = {8'd0, temp_dmaArea_lineFetchPixelCounter_valueNext_1};
  assign temp_dmaArea_frameBufferReadAddr_valueNext_1 = dmaArea_frameBufferReadAddr_willIncrement;
  assign temp_dmaArea_frameBufferReadAddr_valueNext = {16'd0, temp_dmaArea_frameBufferReadAddr_valueNext_1};
  Bram2p_4x76800 frame_buffer (
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
  fb_addr_gen frame_buffer_addr_gen (
    .x        (debug_draw_x_orig[8:0]              ), //i
    .y        (debug_draw_y_orig[7:0]              ), //i
    .start    (frame_buffer_addr_gen_start         ), //i
    .h_cnt    (temp_h_cnt[8:0]                     ), //i
    .v_cnt    (temp_v_cnt[7:0]                     ), //i
    .out_addr (frame_buffer_addr_gen_out_addr[16:0]), //o
    .core_clk (core_clk                            ), //i
    .core_rst (core_rst                            )  //i
  );
  display_controller draw_controller (
    .game_restart            (game_restart                                ), //i
    .frame_start             (1'b0                                        ), //i
    .game_start              (1'b0                                        ), //i
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
    .rd_start       (vga_sync_io_sol                  ), //i
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
  assign frame_buffer_addr_gen_start = (debug_draw_char_start || debug_draw_block_start);
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
    if(((! vga_sync_io_colorEn) && io_colorEn_regNext)) begin
      fbScaleCounter_willIncrement = 1'b1;
    end
  end

  assign fbScaleCounter_willClear = 1'b0;
  assign fbScaleCounter_willOverflowIfInc = (fbScaleCounter_value == 1'b1);
  assign fbScaleCounter_willOverflow = (fbScaleCounter_willOverflowIfInc && fbScaleCounter_willIncrement);
  always @(*) begin
    fbScaleCounter_valueNext = (fbScaleCounter_value + fbScaleCounter_willIncrement);
    if(fbScaleCounter_willClear) begin
      fbScaleCounter_valueNext = 1'b0;
    end
  end

  assign lineFetchAllowed = ((fbScaleCounter_value == 1'b0) && vga_sync_io_vColorEn);
  assign lineFetchPulse = (vga_sync_io_sos && lineFetchAllowed);
  assign line_buffer_palette_addr = line_buffer_rd_out_payload;
  assign vga_hSync = io_hSync_delay_2;
  assign vga_vSync = io_vSync_delay_2;
  assign vga_colorEn = io_colorEn_delay_2;
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

  always @(*) begin
    dmaArea_lineFetchPixelCounter_willClear = 1'b0;
    if(dmaArea_lineFetchPixelCounter_willOverflowIfInc) begin
      dmaArea_lineFetchPixelCounter_willClear = 1'b1;
    end
  end

  assign dmaArea_lineFetchPixelCounter_willOverflowIfInc = (dmaArea_lineFetchPixelCounter_value == 9'h13f);
  assign dmaArea_lineFetchPixelCounter_willOverflow = (dmaArea_lineFetchPixelCounter_willOverflowIfInc && dmaArea_lineFetchPixelCounter_willIncrement);
  always @(*) begin
    if(dmaArea_lineFetchPixelCounter_willOverflow) begin
      dmaArea_lineFetchPixelCounter_valueNext = 9'h0;
    end else begin
      dmaArea_lineFetchPixelCounter_valueNext = (dmaArea_lineFetchPixelCounter_value + temp_dmaArea_lineFetchPixelCounter_valueNext);
    end
    if(dmaArea_lineFetchPixelCounter_willClear) begin
      dmaArea_lineFetchPixelCounter_valueNext = 9'h0;
    end
  end

  always @(*) begin
    dmaArea_frameBufferReadAddr_willIncrement = 1'b0;
    if(dmaArea_frameBufferFetchActive) begin
      dmaArea_frameBufferReadAddr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    dmaArea_frameBufferReadAddr_willClear = 1'b0;
    if(dmaArea_frameStart) begin
      dmaArea_frameBufferReadAddr_willClear = 1'b1;
    end
  end

  assign dmaArea_frameBufferReadAddr_willOverflowIfInc = (dmaArea_frameBufferReadAddr_value == 17'h12bff);
  assign dmaArea_frameBufferReadAddr_willOverflow = (dmaArea_frameBufferReadAddr_willOverflowIfInc && dmaArea_frameBufferReadAddr_willIncrement);
  always @(*) begin
    if(dmaArea_frameBufferReadAddr_willOverflow) begin
      dmaArea_frameBufferReadAddr_valueNext = 17'h0;
    end else begin
      dmaArea_frameBufferReadAddr_valueNext = (dmaArea_frameBufferReadAddr_value + temp_dmaArea_frameBufferReadAddr_valueNext);
    end
    if(dmaArea_frameBufferReadAddr_willClear) begin
      dmaArea_frameBufferReadAddr_valueNext = 17'h0;
    end
  end

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
      io_colorEn_regNext <= 1'b0;
      fbScaleCounter_value <= 1'b0;
      line_fetch_toggle <= 1'b0;
      frame_start_toggle <= 1'b0;
      isBackgroundIndex <= 1'b0;
    end else begin
      io_colorEn_regNext <= vga_sync_io_colorEn;
      fbScaleCounter_value <= fbScaleCounter_valueNext;
      if(lineFetchPulse) begin
        line_fetch_toggle <= (! line_fetch_toggle);
      end
      if(vga_sync_io_sof) begin
        frame_start_toggle <= (! frame_start_toggle);
      end
      isBackgroundIndex <= (line_buffer_rd_out_payload == 4'b0010);
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
    $readmemb("display_top.v_toplevel_line_buffer_palette_rom.bin",rom);
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
  localparam IDLE = 3'd0;
  localparam FETCH_ROW = 3'd1;
  localparam LOAD_ROW = 3'd2;
  localparam DRAW_FIELD_BLOCK = 3'd3;
  localparam WAIT_FIELD_BLOCK_DONE = 3'd4;
  localparam DRAW_SCORE_DIGIT = 3'd5;
  localparam WAIT_SCORE_DIGIT_DONE = 3'd6;
  localparam COMPLETE = 3'd7;
  localparam SETUP_IDLE = 4'd0;
  localparam CLEAN_SCREEN = 4'd1;
  localparam DRAW_OPENING_TEXT = 4'd2;
  localparam WAIT_OPENING_TEXT_DONE = 4'd3;
  localparam WAIT_GAME_START = 4'd4;
  localparam DRAW_STATIC_TEXT = 4'd5;
  localparam WAIT_STATIC_TEXT_DONE = 4'd6;
  localparam DRAW_WALL = 4'd7;
  localparam WAIT_WALL_DONE = 4'd8;
  localparam RUNNING = 4'd9;
  localparam WAIT_RUNTIME_IDLE = 4'd10;

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
  reg                 text_rom_charCounter_willClear;
  reg        [3:0]    text_rom_charCounter_valueNext;
  reg        [3:0]    text_rom_charCounter_value;
  wire                text_rom_charCounter_willOverflowIfInc;
  wire                text_rom_charCounter_willOverflow;
  wire       [6:0]    text_rom_word;
  reg                 wall_rom_wallCounter_willIncrement;
  reg                 wall_rom_wallCounter_willClear;
  reg        [1:0]    wall_rom_wallCounter_valueNext;
  reg        [1:0]    wall_rom_wallCounter_value;
  wire                wall_rom_wallCounter_willOverflowIfInc;
  wire                wall_rom_wallCounter_willOverflow;
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
  wire                playfield_storage_writeRowCounter_willClear;
  reg        [4:0]    playfield_storage_writeRowCounter_valueNext;
  reg        [4:0]    playfield_storage_writeRowCounter_value;
  wire                playfield_storage_writeRowCounter_willOverflowIfInc;
  wire                playfield_storage_writeRowCounter_willOverflow;
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
  reg                 runtime_renderer_rowCounter_willClear;
  reg        [4:0]    runtime_renderer_rowCounter_valueNext;
  reg        [4:0]    runtime_renderer_rowCounter_value;
  wire                runtime_renderer_rowCounter_willOverflowIfInc;
  wire                runtime_renderer_rowCounter_willOverflow;
  reg                 runtime_renderer_colCounter_willIncrement;
  reg                 runtime_renderer_colCounter_willClear;
  reg        [3:0]    runtime_renderer_colCounter_valueNext;
  reg        [3:0]    runtime_renderer_colCounter_value;
  wire                runtime_renderer_colCounter_willOverflowIfInc;
  wire                runtime_renderer_colCounter_willOverflow;
  reg                 runtime_renderer_scoreDigitCounter_willIncrement;
  reg                 runtime_renderer_scoreDigitCounter_willClear;
  reg        [1:0]    runtime_renderer_scoreDigitCounter_valueNext;
  reg        [1:0]    runtime_renderer_scoreDigitCounter_value;
  wire                runtime_renderer_scoreDigitCounter_willOverflowIfInc;
  wire                runtime_renderer_scoreDigitCounter_willOverflow;
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
  wire                runtime_renderer_fsm_onExit_IDLE;
  wire                runtime_renderer_fsm_onExit_FETCH_ROW;
  wire                runtime_renderer_fsm_onExit_LOAD_ROW;
  wire                runtime_renderer_fsm_onExit_DRAW_FIELD_BLOCK;
  wire                runtime_renderer_fsm_onExit_WAIT_FIELD_BLOCK_DONE;
  wire                runtime_renderer_fsm_onExit_DRAW_SCORE_DIGIT;
  wire                runtime_renderer_fsm_onExit_WAIT_SCORE_DIGIT_DONE;
  wire                runtime_renderer_fsm_onExit_COMPLETE;
  wire                runtime_renderer_fsm_onEntry_IDLE;
  wire                runtime_renderer_fsm_onEntry_FETCH_ROW;
  wire                runtime_renderer_fsm_onEntry_LOAD_ROW;
  wire                runtime_renderer_fsm_onEntry_DRAW_FIELD_BLOCK;
  wire                runtime_renderer_fsm_onEntry_WAIT_FIELD_BLOCK_DONE;
  wire                runtime_renderer_fsm_onEntry_DRAW_SCORE_DIGIT;
  wire                runtime_renderer_fsm_onEntry_WAIT_SCORE_DIGIT_DONE;
  wire                runtime_renderer_fsm_onEntry_COMPLETE;
  reg        [3:0]    setup_renderer_fsm_stateReg;
  reg        [3:0]    setup_renderer_fsm_stateNext;
  wire                setup_renderer_fsm_onExit_SETUP_IDLE;
  wire                setup_renderer_fsm_onExit_CLEAN_SCREEN;
  wire                setup_renderer_fsm_onExit_DRAW_OPENING_TEXT;
  wire                setup_renderer_fsm_onExit_WAIT_OPENING_TEXT_DONE;
  wire                setup_renderer_fsm_onExit_WAIT_GAME_START;
  wire                setup_renderer_fsm_onExit_DRAW_STATIC_TEXT;
  wire                setup_renderer_fsm_onExit_WAIT_STATIC_TEXT_DONE;
  wire                setup_renderer_fsm_onExit_DRAW_WALL;
  wire                setup_renderer_fsm_onExit_WAIT_WALL_DONE;
  wire                setup_renderer_fsm_onExit_RUNNING;
  wire                setup_renderer_fsm_onExit_WAIT_RUNTIME_IDLE;
  wire                setup_renderer_fsm_onEntry_SETUP_IDLE;
  wire                setup_renderer_fsm_onEntry_CLEAN_SCREEN;
  wire                setup_renderer_fsm_onEntry_DRAW_OPENING_TEXT;
  wire                setup_renderer_fsm_onEntry_WAIT_OPENING_TEXT_DONE;
  wire                setup_renderer_fsm_onEntry_WAIT_GAME_START;
  wire                setup_renderer_fsm_onEntry_DRAW_STATIC_TEXT;
  wire                setup_renderer_fsm_onEntry_WAIT_STATIC_TEXT_DONE;
  wire                setup_renderer_fsm_onEntry_DRAW_WALL;
  wire                setup_renderer_fsm_onEntry_WAIT_WALL_DONE;
  wire                setup_renderer_fsm_onEntry_RUNNING;
  wire                setup_renderer_fsm_onEntry_WAIT_RUNTIME_IDLE;
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
    $readmemb("display_top.v_toplevel_draw_controller_text_rom_rom.bin",text_rom_rom);
  end
  assign text_rom_rom_spinal_port0 = text_rom_rom[text_rom_charCounter_value];
  initial begin
    $readmemb("display_top.v_toplevel_draw_controller_wall_rom_wallMem.bin",wall_rom_wallMem);
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
      IDLE : runtime_renderer_fsm_stateReg_string = "IDLE                 ";
      FETCH_ROW : runtime_renderer_fsm_stateReg_string = "FETCH_ROW            ";
      LOAD_ROW : runtime_renderer_fsm_stateReg_string = "LOAD_ROW             ";
      DRAW_FIELD_BLOCK : runtime_renderer_fsm_stateReg_string = "DRAW_FIELD_BLOCK     ";
      WAIT_FIELD_BLOCK_DONE : runtime_renderer_fsm_stateReg_string = "WAIT_FIELD_BLOCK_DONE";
      DRAW_SCORE_DIGIT : runtime_renderer_fsm_stateReg_string = "DRAW_SCORE_DIGIT     ";
      WAIT_SCORE_DIGIT_DONE : runtime_renderer_fsm_stateReg_string = "WAIT_SCORE_DIGIT_DONE";
      COMPLETE : runtime_renderer_fsm_stateReg_string = "COMPLETE             ";
      default : runtime_renderer_fsm_stateReg_string = "?????????????????????";
    endcase
  end
  always @(*) begin
    case(runtime_renderer_fsm_stateNext)
      IDLE : runtime_renderer_fsm_stateNext_string = "IDLE                 ";
      FETCH_ROW : runtime_renderer_fsm_stateNext_string = "FETCH_ROW            ";
      LOAD_ROW : runtime_renderer_fsm_stateNext_string = "LOAD_ROW             ";
      DRAW_FIELD_BLOCK : runtime_renderer_fsm_stateNext_string = "DRAW_FIELD_BLOCK     ";
      WAIT_FIELD_BLOCK_DONE : runtime_renderer_fsm_stateNext_string = "WAIT_FIELD_BLOCK_DONE";
      DRAW_SCORE_DIGIT : runtime_renderer_fsm_stateNext_string = "DRAW_SCORE_DIGIT     ";
      WAIT_SCORE_DIGIT_DONE : runtime_renderer_fsm_stateNext_string = "WAIT_SCORE_DIGIT_DONE";
      COMPLETE : runtime_renderer_fsm_stateNext_string = "COMPLETE             ";
      default : runtime_renderer_fsm_stateNext_string = "?????????????????????";
    endcase
  end
  always @(*) begin
    case(setup_renderer_fsm_stateReg)
      SETUP_IDLE : setup_renderer_fsm_stateReg_string = "SETUP_IDLE            ";
      CLEAN_SCREEN : setup_renderer_fsm_stateReg_string = "CLEAN_SCREEN          ";
      DRAW_OPENING_TEXT : setup_renderer_fsm_stateReg_string = "DRAW_OPENING_TEXT     ";
      WAIT_OPENING_TEXT_DONE : setup_renderer_fsm_stateReg_string = "WAIT_OPENING_TEXT_DONE";
      WAIT_GAME_START : setup_renderer_fsm_stateReg_string = "WAIT_GAME_START       ";
      DRAW_STATIC_TEXT : setup_renderer_fsm_stateReg_string = "DRAW_STATIC_TEXT      ";
      WAIT_STATIC_TEXT_DONE : setup_renderer_fsm_stateReg_string = "WAIT_STATIC_TEXT_DONE ";
      DRAW_WALL : setup_renderer_fsm_stateReg_string = "DRAW_WALL             ";
      WAIT_WALL_DONE : setup_renderer_fsm_stateReg_string = "WAIT_WALL_DONE        ";
      RUNNING : setup_renderer_fsm_stateReg_string = "RUNNING               ";
      WAIT_RUNTIME_IDLE : setup_renderer_fsm_stateReg_string = "WAIT_RUNTIME_IDLE     ";
      default : setup_renderer_fsm_stateReg_string = "??????????????????????";
    endcase
  end
  always @(*) begin
    case(setup_renderer_fsm_stateNext)
      SETUP_IDLE : setup_renderer_fsm_stateNext_string = "SETUP_IDLE            ";
      CLEAN_SCREEN : setup_renderer_fsm_stateNext_string = "CLEAN_SCREEN          ";
      DRAW_OPENING_TEXT : setup_renderer_fsm_stateNext_string = "DRAW_OPENING_TEXT     ";
      WAIT_OPENING_TEXT_DONE : setup_renderer_fsm_stateNext_string = "WAIT_OPENING_TEXT_DONE";
      WAIT_GAME_START : setup_renderer_fsm_stateNext_string = "WAIT_GAME_START       ";
      DRAW_STATIC_TEXT : setup_renderer_fsm_stateNext_string = "DRAW_STATIC_TEXT      ";
      WAIT_STATIC_TEXT_DONE : setup_renderer_fsm_stateNext_string = "WAIT_STATIC_TEXT_DONE ";
      DRAW_WALL : setup_renderer_fsm_stateNext_string = "DRAW_WALL             ";
      WAIT_WALL_DONE : setup_renderer_fsm_stateNext_string = "WAIT_WALL_DONE        ";
      RUNNING : setup_renderer_fsm_stateNext_string = "RUNNING               ";
      WAIT_RUNTIME_IDLE : setup_renderer_fsm_stateNext_string = "WAIT_RUNTIME_IDLE     ";
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
    if(text_rom_charCounter_willOverflow) begin
      text_rom_charCounter_valueNext = 4'b0000;
    end else begin
      text_rom_charCounter_valueNext = (text_rom_charCounter_value + temp_text_rom_charCounter_valueNext);
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
      CLEAN_SCREEN : begin
        if(bf_clear_done) begin
          wall_rom_wallCounter_willClear = 1'b1;
          if(setup_renderer_gameIsRunning) begin
            text_rom_charCounter_valueNext = 4'b0110;
            setup_renderer_fsm_stateNext = DRAW_STATIC_TEXT;
          end else begin
            text_rom_charCounter_willClear = 1'b1;
            setup_renderer_fsm_stateNext = DRAW_OPENING_TEXT;
          end
        end
      end
      DRAW_OPENING_TEXT : begin
        setup_renderer_charCommand_start = 1'b1;
        setup_renderer_charCommand_x_orig = setup_renderer_textX;
        setup_renderer_charCommand_y_orig = setup_renderer_textY;
        setup_renderer_charCommand_scale = setup_renderer_textScale;
        setup_renderer_charCommand_color = setup_renderer_textColor;
        setup_renderer_charCommand_word = text_rom_word;
        setup_renderer_fsm_stateNext = WAIT_OPENING_TEXT_DONE;
      end
      WAIT_OPENING_TEXT_DONE : begin
        if(setupCharDone) begin
          if(temp_when_2) begin
            setup_renderer_fsm_stateNext = WAIT_GAME_START;
          end else begin
            text_rom_charCounter_willIncrement = 1'b1;
            setup_renderer_fsm_stateNext = DRAW_OPENING_TEXT;
          end
        end
      end
      WAIT_GAME_START : begin
        if(game_start) begin
          setup_renderer_fsm_stateNext = CLEAN_SCREEN;
        end
      end
      DRAW_STATIC_TEXT : begin
        setup_renderer_charCommand_start = 1'b1;
        setup_renderer_charCommand_x_orig = setup_renderer_textX;
        setup_renderer_charCommand_y_orig = setup_renderer_textY;
        setup_renderer_charCommand_scale = setup_renderer_textScale;
        setup_renderer_charCommand_color = setup_renderer_textColor;
        setup_renderer_charCommand_word = text_rom_word;
        setup_renderer_fsm_stateNext = WAIT_STATIC_TEXT_DONE;
      end
      WAIT_STATIC_TEXT_DONE : begin
        if(setupCharDone) begin
          if(temp_when_3) begin
            setup_renderer_fsm_stateNext = DRAW_WALL;
          end else begin
            text_rom_charCounter_willIncrement = 1'b1;
            setup_renderer_fsm_stateNext = DRAW_STATIC_TEXT;
          end
        end
      end
      DRAW_WALL : begin
        setup_renderer_blockCommand_start = wall_rom_command_start;
        setup_renderer_blockCommand_x_orig = wall_rom_command_x_orig;
        setup_renderer_blockCommand_y_orig = wall_rom_command_y_orig;
        setup_renderer_blockCommand_width = wall_rom_command_width;
        setup_renderer_blockCommand_height = wall_rom_command_height;
        setup_renderer_blockCommand_in_color = wall_rom_command_in_color;
        setup_renderer_blockCommand_pat_color = wall_rom_command_pat_color;
        setup_renderer_blockCommand_fill_pattern = wall_rom_command_fill_pattern;
        setup_renderer_fsm_stateNext = WAIT_WALL_DONE;
      end
      WAIT_WALL_DONE : begin
        if(setupBlockDone) begin
          if(wall_rom_wallCounter_willOverflowIfInc) begin
            setup_renderer_fsm_stateNext = RUNNING;
          end else begin
            wall_rom_wallCounter_willIncrement = 1'b1;
            setup_renderer_fsm_stateNext = DRAW_WALL;
          end
        end
      end
      RUNNING : begin
        runtimeRenderEnable = 1'b1;
        screen_is_ready = 1'b1;
        if(game_restart) begin
          clearPendingPlayfieldRender = 1'b1;
          if(runtimeRenderBusy) begin
            setup_renderer_fsm_stateNext = WAIT_RUNTIME_IDLE;
          end else begin
            setup_renderer_fsm_stateNext = CLEAN_SCREEN;
          end
        end
      end
      WAIT_RUNTIME_IDLE : begin
        clearPendingPlayfieldRender = 1'b1;
        if((! runtimeRenderBusy)) begin
          setup_renderer_fsm_stateNext = CLEAN_SCREEN;
        end
      end
      default : begin
        if(frame_start) begin
          text_rom_charCounter_willClear = 1'b1;
          wall_rom_wallCounter_willClear = 1'b1;
          setup_renderer_fsm_stateNext = CLEAN_SCREEN;
        end
        setup_renderer_fsm_wantStart = 1'b1;
      end
    endcase
    if(setup_renderer_fsm_wantKill) begin
      setup_renderer_fsm_stateNext = SETUP_IDLE;
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
      FETCH_ROW : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_readEnable = 1'b1;
        runtime_renderer_fsm_stateNext = LOAD_ROW;
      end
      LOAD_ROW : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_fsm_stateNext = DRAW_FIELD_BLOCK;
      end
      DRAW_FIELD_BLOCK : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_blockCommand_start = 1'b1;
        runtime_renderer_blockCommand_x_orig = runtime_renderer_fieldX;
        runtime_renderer_blockCommand_y_orig = runtime_renderer_fieldY;
        runtime_renderer_blockCommand_width = 8'h07;
        runtime_renderer_blockCommand_height = 8'h07;
        runtime_renderer_blockCommand_in_color = runtime_renderer_fieldColor;
        runtime_renderer_blockCommand_pat_color = 4'b0010;
        runtime_renderer_blockCommand_fill_pattern = 2'b00;
        runtime_renderer_fsm_stateNext = WAIT_FIELD_BLOCK_DONE;
      end
      WAIT_FIELD_BLOCK_DONE : begin
        runtimeRenderBusy = 1'b1;
        if(runtimeFieldBlockDone) begin
          if(temp_when) begin
            runtime_renderer_scoreDigitCounter_willClear = 1'b1;
            runtime_renderer_fsm_stateNext = DRAW_SCORE_DIGIT;
          end else begin
            if(runtime_renderer_colCounter_willOverflowIfInc) begin
              runtime_renderer_colCounter_willClear = 1'b1;
              runtime_renderer_rowCounter_willIncrement = 1'b1;
              runtime_renderer_fsm_stateNext = FETCH_ROW;
            end else begin
              runtime_renderer_colCounter_willIncrement = 1'b1;
              runtime_renderer_fsm_stateNext = DRAW_FIELD_BLOCK;
            end
          end
        end
      end
      DRAW_SCORE_DIGIT : begin
        runtimeRenderBusy = 1'b1;
        runtime_renderer_scoreCommand_start = 1'b1;
        runtime_renderer_scoreCommand_x_orig = runtime_renderer_scoreX;
        runtime_renderer_scoreCommand_y_orig = 8'h50;
        runtime_renderer_scoreCommand_scale = 3'b000;
        runtime_renderer_scoreCommand_color = 4'b0110;
        runtime_renderer_scoreCommand_word = {3'b011,temp_runtime_renderer_scoreCommand_word};
        runtime_renderer_fsm_stateNext = WAIT_SCORE_DIGIT_DONE;
      end
      WAIT_SCORE_DIGIT_DONE : begin
        runtimeRenderBusy = 1'b1;
        if(runtimeScoreCharDone) begin
          if(runtime_renderer_scoreDigitCounter_willOverflowIfInc) begin
            runtime_renderer_fsm_stateNext = COMPLETE;
          end else begin
            runtime_renderer_scoreDigitCounter_willIncrement = 1'b1;
            runtime_renderer_fsm_stateNext = DRAW_SCORE_DIGIT;
          end
        end
      end
      COMPLETE : begin
        draw_field_done = 1'b1;
        runtime_renderer_fsm_stateNext = IDLE;
      end
      default : begin
        if(temp_when_1) begin
          runtimeRenderStart = 1'b1;
          runtime_renderer_rowCounter_willClear = 1'b1;
          runtime_renderer_colCounter_willClear = 1'b1;
          runtime_renderer_scoreDigitCounter_willClear = 1'b1;
          runtime_renderer_fsm_stateNext = FETCH_ROW;
        end
        runtime_renderer_fsm_wantStart = 1'b1;
      end
    endcase
    if(runtime_renderer_fsm_wantKill) begin
      runtime_renderer_fsm_stateNext = IDLE;
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
  assign text_rom_charCounter_willOverflowIfInc = (text_rom_charCounter_value == 4'b1010);
  assign text_rom_charCounter_willOverflow = (text_rom_charCounter_willOverflowIfInc && text_rom_charCounter_willIncrement);
  assign text_rom_word = text_rom_rom_spinal_port0;
  assign wall_rom_wallCounter_willOverflowIfInc = (wall_rom_wallCounter_value == 2'b11);
  assign wall_rom_wallCounter_willOverflow = (wall_rom_wallCounter_willOverflowIfInc && wall_rom_wallCounter_willIncrement);
  always @(*) begin
    wall_rom_wallCounter_valueNext = (wall_rom_wallCounter_value + temp_wall_rom_wallCounter_valueNext);
    if(wall_rom_wallCounter_willClear) begin
      wall_rom_wallCounter_valueNext = 2'b00;
    end
  end

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

  assign playfield_storage_writeRowCounter_willClear = 1'b0;
  assign playfield_storage_writeRowCounter_willOverflowIfInc = (playfield_storage_writeRowCounter_value == 5'h15);
  assign playfield_storage_writeRowCounter_willOverflow = (playfield_storage_writeRowCounter_willOverflowIfInc && playfield_storage_writeRowCounter_willIncrement);
  always @(*) begin
    if(playfield_storage_writeRowCounter_willOverflow) begin
      playfield_storage_writeRowCounter_valueNext = 5'h0;
    end else begin
      playfield_storage_writeRowCounter_valueNext = (playfield_storage_writeRowCounter_value + temp_playfield_storage_writeRowCounter_valueNext);
    end
    if(playfield_storage_writeRowCounter_willClear) begin
      playfield_storage_writeRowCounter_valueNext = 5'h0;
    end
  end

  assign playfield_storage_rowBurstComplete = ((! row_val_valid) && row_val_valid_regNext);
  assign runtime_renderer_rowCounter_willOverflowIfInc = (runtime_renderer_rowCounter_value == 5'h15);
  assign runtime_renderer_rowCounter_willOverflow = (runtime_renderer_rowCounter_willOverflowIfInc && runtime_renderer_rowCounter_willIncrement);
  always @(*) begin
    if(runtime_renderer_rowCounter_willOverflow) begin
      runtime_renderer_rowCounter_valueNext = 5'h0;
    end else begin
      runtime_renderer_rowCounter_valueNext = (runtime_renderer_rowCounter_value + temp_runtime_renderer_rowCounter_valueNext);
    end
    if(runtime_renderer_rowCounter_willClear) begin
      runtime_renderer_rowCounter_valueNext = 5'h0;
    end
  end

  assign runtime_renderer_colCounter_willOverflowIfInc = (runtime_renderer_colCounter_value == 4'b1001);
  assign runtime_renderer_colCounter_willOverflow = (runtime_renderer_colCounter_willOverflowIfInc && runtime_renderer_colCounter_willIncrement);
  always @(*) begin
    if(runtime_renderer_colCounter_willOverflow) begin
      runtime_renderer_colCounter_valueNext = 4'b0000;
    end else begin
      runtime_renderer_colCounter_valueNext = (runtime_renderer_colCounter_value + temp_runtime_renderer_colCounter_valueNext);
    end
    if(runtime_renderer_colCounter_willClear) begin
      runtime_renderer_colCounter_valueNext = 4'b0000;
    end
  end

  assign runtime_renderer_scoreDigitCounter_willOverflowIfInc = (runtime_renderer_scoreDigitCounter_value == 2'b11);
  assign runtime_renderer_scoreDigitCounter_willOverflow = (runtime_renderer_scoreDigitCounter_willOverflowIfInc && runtime_renderer_scoreDigitCounter_willIncrement);
  always @(*) begin
    runtime_renderer_scoreDigitCounter_valueNext = (runtime_renderer_scoreDigitCounter_value + temp_runtime_renderer_scoreDigitCounter_valueNext);
    if(runtime_renderer_scoreDigitCounter_willClear) begin
      runtime_renderer_scoreDigitCounter_valueNext = 2'b00;
    end
  end

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

  assign runtime_renderer_fsm_onExit_IDLE = ((runtime_renderer_fsm_stateNext != IDLE) && (runtime_renderer_fsm_stateReg == IDLE));
  assign runtime_renderer_fsm_onExit_FETCH_ROW = ((runtime_renderer_fsm_stateNext != FETCH_ROW) && (runtime_renderer_fsm_stateReg == FETCH_ROW));
  assign runtime_renderer_fsm_onExit_LOAD_ROW = ((runtime_renderer_fsm_stateNext != LOAD_ROW) && (runtime_renderer_fsm_stateReg == LOAD_ROW));
  assign runtime_renderer_fsm_onExit_DRAW_FIELD_BLOCK = ((runtime_renderer_fsm_stateNext != DRAW_FIELD_BLOCK) && (runtime_renderer_fsm_stateReg == DRAW_FIELD_BLOCK));
  assign runtime_renderer_fsm_onExit_WAIT_FIELD_BLOCK_DONE = ((runtime_renderer_fsm_stateNext != WAIT_FIELD_BLOCK_DONE) && (runtime_renderer_fsm_stateReg == WAIT_FIELD_BLOCK_DONE));
  assign runtime_renderer_fsm_onExit_DRAW_SCORE_DIGIT = ((runtime_renderer_fsm_stateNext != DRAW_SCORE_DIGIT) && (runtime_renderer_fsm_stateReg == DRAW_SCORE_DIGIT));
  assign runtime_renderer_fsm_onExit_WAIT_SCORE_DIGIT_DONE = ((runtime_renderer_fsm_stateNext != WAIT_SCORE_DIGIT_DONE) && (runtime_renderer_fsm_stateReg == WAIT_SCORE_DIGIT_DONE));
  assign runtime_renderer_fsm_onExit_COMPLETE = ((runtime_renderer_fsm_stateNext != COMPLETE) && (runtime_renderer_fsm_stateReg == COMPLETE));
  assign runtime_renderer_fsm_onEntry_IDLE = ((runtime_renderer_fsm_stateNext == IDLE) && (runtime_renderer_fsm_stateReg != IDLE));
  assign runtime_renderer_fsm_onEntry_FETCH_ROW = ((runtime_renderer_fsm_stateNext == FETCH_ROW) && (runtime_renderer_fsm_stateReg != FETCH_ROW));
  assign runtime_renderer_fsm_onEntry_LOAD_ROW = ((runtime_renderer_fsm_stateNext == LOAD_ROW) && (runtime_renderer_fsm_stateReg != LOAD_ROW));
  assign runtime_renderer_fsm_onEntry_DRAW_FIELD_BLOCK = ((runtime_renderer_fsm_stateNext == DRAW_FIELD_BLOCK) && (runtime_renderer_fsm_stateReg != DRAW_FIELD_BLOCK));
  assign runtime_renderer_fsm_onEntry_WAIT_FIELD_BLOCK_DONE = ((runtime_renderer_fsm_stateNext == WAIT_FIELD_BLOCK_DONE) && (runtime_renderer_fsm_stateReg != WAIT_FIELD_BLOCK_DONE));
  assign runtime_renderer_fsm_onEntry_DRAW_SCORE_DIGIT = ((runtime_renderer_fsm_stateNext == DRAW_SCORE_DIGIT) && (runtime_renderer_fsm_stateReg != DRAW_SCORE_DIGIT));
  assign runtime_renderer_fsm_onEntry_WAIT_SCORE_DIGIT_DONE = ((runtime_renderer_fsm_stateNext == WAIT_SCORE_DIGIT_DONE) && (runtime_renderer_fsm_stateReg != WAIT_SCORE_DIGIT_DONE));
  assign runtime_renderer_fsm_onEntry_COMPLETE = ((runtime_renderer_fsm_stateNext == COMPLETE) && (runtime_renderer_fsm_stateReg != COMPLETE));
  assign setup_renderer_fsm_onExit_SETUP_IDLE = ((setup_renderer_fsm_stateNext != SETUP_IDLE) && (setup_renderer_fsm_stateReg == SETUP_IDLE));
  assign setup_renderer_fsm_onExit_CLEAN_SCREEN = ((setup_renderer_fsm_stateNext != CLEAN_SCREEN) && (setup_renderer_fsm_stateReg == CLEAN_SCREEN));
  assign setup_renderer_fsm_onExit_DRAW_OPENING_TEXT = ((setup_renderer_fsm_stateNext != DRAW_OPENING_TEXT) && (setup_renderer_fsm_stateReg == DRAW_OPENING_TEXT));
  assign setup_renderer_fsm_onExit_WAIT_OPENING_TEXT_DONE = ((setup_renderer_fsm_stateNext != WAIT_OPENING_TEXT_DONE) && (setup_renderer_fsm_stateReg == WAIT_OPENING_TEXT_DONE));
  assign setup_renderer_fsm_onExit_WAIT_GAME_START = ((setup_renderer_fsm_stateNext != WAIT_GAME_START) && (setup_renderer_fsm_stateReg == WAIT_GAME_START));
  assign setup_renderer_fsm_onExit_DRAW_STATIC_TEXT = ((setup_renderer_fsm_stateNext != DRAW_STATIC_TEXT) && (setup_renderer_fsm_stateReg == DRAW_STATIC_TEXT));
  assign setup_renderer_fsm_onExit_WAIT_STATIC_TEXT_DONE = ((setup_renderer_fsm_stateNext != WAIT_STATIC_TEXT_DONE) && (setup_renderer_fsm_stateReg == WAIT_STATIC_TEXT_DONE));
  assign setup_renderer_fsm_onExit_DRAW_WALL = ((setup_renderer_fsm_stateNext != DRAW_WALL) && (setup_renderer_fsm_stateReg == DRAW_WALL));
  assign setup_renderer_fsm_onExit_WAIT_WALL_DONE = ((setup_renderer_fsm_stateNext != WAIT_WALL_DONE) && (setup_renderer_fsm_stateReg == WAIT_WALL_DONE));
  assign setup_renderer_fsm_onExit_RUNNING = ((setup_renderer_fsm_stateNext != RUNNING) && (setup_renderer_fsm_stateReg == RUNNING));
  assign setup_renderer_fsm_onExit_WAIT_RUNTIME_IDLE = ((setup_renderer_fsm_stateNext != WAIT_RUNTIME_IDLE) && (setup_renderer_fsm_stateReg == WAIT_RUNTIME_IDLE));
  assign setup_renderer_fsm_onEntry_SETUP_IDLE = ((setup_renderer_fsm_stateNext == SETUP_IDLE) && (setup_renderer_fsm_stateReg != SETUP_IDLE));
  assign setup_renderer_fsm_onEntry_CLEAN_SCREEN = ((setup_renderer_fsm_stateNext == CLEAN_SCREEN) && (setup_renderer_fsm_stateReg != CLEAN_SCREEN));
  assign setup_renderer_fsm_onEntry_DRAW_OPENING_TEXT = ((setup_renderer_fsm_stateNext == DRAW_OPENING_TEXT) && (setup_renderer_fsm_stateReg != DRAW_OPENING_TEXT));
  assign setup_renderer_fsm_onEntry_WAIT_OPENING_TEXT_DONE = ((setup_renderer_fsm_stateNext == WAIT_OPENING_TEXT_DONE) && (setup_renderer_fsm_stateReg != WAIT_OPENING_TEXT_DONE));
  assign setup_renderer_fsm_onEntry_WAIT_GAME_START = ((setup_renderer_fsm_stateNext == WAIT_GAME_START) && (setup_renderer_fsm_stateReg != WAIT_GAME_START));
  assign setup_renderer_fsm_onEntry_DRAW_STATIC_TEXT = ((setup_renderer_fsm_stateNext == DRAW_STATIC_TEXT) && (setup_renderer_fsm_stateReg != DRAW_STATIC_TEXT));
  assign setup_renderer_fsm_onEntry_WAIT_STATIC_TEXT_DONE = ((setup_renderer_fsm_stateNext == WAIT_STATIC_TEXT_DONE) && (setup_renderer_fsm_stateReg != WAIT_STATIC_TEXT_DONE));
  assign setup_renderer_fsm_onEntry_DRAW_WALL = ((setup_renderer_fsm_stateNext == DRAW_WALL) && (setup_renderer_fsm_stateReg != DRAW_WALL));
  assign setup_renderer_fsm_onEntry_WAIT_WALL_DONE = ((setup_renderer_fsm_stateNext == WAIT_WALL_DONE) && (setup_renderer_fsm_stateReg != WAIT_WALL_DONE));
  assign setup_renderer_fsm_onEntry_RUNNING = ((setup_renderer_fsm_stateNext == RUNNING) && (setup_renderer_fsm_stateReg != RUNNING));
  assign setup_renderer_fsm_onEntry_WAIT_RUNTIME_IDLE = ((setup_renderer_fsm_stateNext == WAIT_RUNTIME_IDLE) && (setup_renderer_fsm_stateReg != WAIT_RUNTIME_IDLE));
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
      runtime_renderer_fsm_stateReg <= IDLE;
      setup_renderer_fsm_stateReg <= SETUP_IDLE;
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
          assert((! charStartCollision)); // display_controller.scala:L644
        `else
          if(!(! charStartCollision)) begin
            $display("FAILURE display_controller: setup and runtime score char commands must not start together"); // display_controller.scala:L644
            $finish;
          end
        `endif
      `endif
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! blockStartCollision)); // display_controller.scala:L645
        `else
          if(!(! blockStartCollision)) begin
            $display("FAILURE display_controller: setup and runtime block commands must not start together"); // display_controller.scala:L645
            $finish;
          end
        `endif
      `endif
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! drawStartCollision)); // display_controller.scala:L646
        `else
          if(!(! drawStartCollision)) begin
            $display("FAILURE display_controller: char and block engines must not receive start in the same cycle"); // display_controller.scala:L646
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
        FETCH_ROW : begin
        end
        LOAD_ROW : begin
          runtime_renderer_rowBits <= runtime_renderer_rowValue;
        end
        DRAW_FIELD_BLOCK : begin
        end
        WAIT_FIELD_BLOCK_DONE : begin
          if(runtimeFieldBlockDone) begin
            if(temp_when) begin
              runtime_renderer_scoreX <= 9'h0d6;
            end else begin
              if(runtime_renderer_colCounter_willOverflowIfInc) begin
                runtime_renderer_fieldX <= 9'h03b;
                runtime_renderer_fieldY <= (runtime_renderer_fieldY + 8'h09);
              end else begin
                runtime_renderer_rowBits <= (runtime_renderer_rowBits <<< 1);
                runtime_renderer_fieldX <= (runtime_renderer_fieldX + 9'h009);
              end
            end
          end
        end
        DRAW_SCORE_DIGIT : begin
        end
        WAIT_SCORE_DIGIT_DONE : begin
          if(runtimeScoreCharDone) begin
            if(!runtime_renderer_scoreDigitCounter_willOverflowIfInc) begin
              runtime_renderer_scoreX <= (runtime_renderer_scoreX + 9'h00c);
            end
          end
        end
        COMPLETE : begin
        end
        default : begin
          if(temp_when_1) begin
            runtime_renderer_fieldX <= 9'h03b;
            runtime_renderer_fieldY <= 8'h14;
          end
        end
      endcase
      setup_renderer_fsm_stateReg <= setup_renderer_fsm_stateNext;
      case(setup_renderer_fsm_stateReg)
        CLEAN_SCREEN : begin
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
        DRAW_OPENING_TEXT : begin
        end
        WAIT_OPENING_TEXT_DONE : begin
          if(setupCharDone) begin
            if(!temp_when_2) begin
              setup_renderer_textX <= (setup_renderer_textX + 9'h02e);
            end
          end
        end
        WAIT_GAME_START : begin
          if(game_start) begin
            setup_renderer_gameIsRunning <= 1'b1;
          end
        end
        DRAW_STATIC_TEXT : begin
        end
        WAIT_STATIC_TEXT_DONE : begin
          if(setupCharDone) begin
            if(!temp_when_3) begin
              setup_renderer_textX <= (setup_renderer_textX + 9'h00c);
            end
          end
        end
        DRAW_WALL : begin
        end
        WAIT_WALL_DONE : begin
        end
        RUNNING : begin
        end
        WAIT_RUNTIME_IDLE : begin
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

module Bram2p_4x76800 (
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
  wire                clear_addr_willClear;
  reg        [16:0]   clear_addr_valueNext;
  reg        [16:0]   clear_addr_value;
  wire                clear_addr_willOverflowIfInc;
  wire                clear_addr_willOverflow;
  wire       [16:0]   wr_addr_1;
  wire       [3:0]    wr_data_1;
  wire                wr_en_1;
  reg                 rd_en_regNext;
  wire                external_write_during_clear;
  (* ram_style = "block" *) reg [3:0] memory [0:76799];

  assign temp_clear_addr_valueNext_1 = clear_addr_willIncrement;
  assign temp_clear_addr_valueNext = {16'd0, temp_clear_addr_valueNext_1};
  initial begin
    $readmemb("display_top.v_toplevel_frame_buffer_memory.bin",memory);
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

  assign clear_addr_willClear = 1'b0;
  assign clear_addr_willOverflowIfInc = (clear_addr_value == 17'h12bff);
  assign clear_addr_willOverflow = (clear_addr_willOverflowIfInc && clear_addr_willIncrement);
  always @(*) begin
    if(clear_addr_willOverflow) begin
      clear_addr_valueNext = 17'h0;
    end else begin
      clear_addr_valueNext = (clear_addr_value + temp_clear_addr_valueNext);
    end
    if(clear_addr_willClear) begin
      clear_addr_valueNext = 17'h0;
    end
  end

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

