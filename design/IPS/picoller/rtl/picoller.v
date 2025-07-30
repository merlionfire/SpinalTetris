// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : picoller
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

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
  input  wire          clk,
  input  wire          reset
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
  wire                blocks_out_toFlow_valid;
  wire       [3:0]    blocks_out_toFlow_payload_x;
  wire       [4:0]    blocks_out_toFlow_payload_y;
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
    .clk                            (clk                                               ), //i
    .reset                          (reset                                             )  //i
  );
  collision_checker collision_checker_1 (
    .block_in_valid                 (blocks_out_toFlow_valid                           ), //i
    .block_in_payload_x             (blocks_out_toFlow_payload_x[3:0]                  ), //i
    .block_in_payload_y             (blocks_out_toFlow_payload_y[4:0]                  ), //i
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
    .clk                            (clk                                               ), //i
    .reset                          (reset                                             )  //i
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
  assign blocks_out_toFlow_valid = piece_checker_1_blocks_out_valid;
  assign blocks_out_toFlow_payload_x = piece_checker_1_blocks_out_payload_x;
  assign blocks_out_toFlow_payload_y = piece_checker_1_blocks_out_payload_y;
  assign collision_checker_1_block_wr_en = (update && block_set);
  assign block_pos_valid = collision_checker_1_block_pos_valid;
  assign block_pos_payload_x = collision_checker_1_block_pos_payload_x;
  assign block_pos_payload_y = collision_checker_1_block_pos_payload_y;

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
  input  wire          clk,
  input  wire          reset
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
  always @(posedge clk or posedge reset) begin
    if(reset) begin
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
  input  wire          clk,
  input  wire          reset
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
  always @(posedge clk or posedge reset) begin
    if(reset) begin
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
        L : begin
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
        default : begin
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

  always @(posedge clk) begin
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
