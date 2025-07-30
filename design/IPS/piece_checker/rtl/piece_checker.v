// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : piece_checker
// Git hash  : 1966d2c2753e3d447f4de5f4d933de13c0cb6e6b

`timescale 1ns/1ps

module piece_checker (
  input  wire          piece_in_valid,
  output reg           piece_in_ready,
  input  wire [1:0]    piece_in_payload_orign_x,
  input  wire [2:0]    piece_in_payload_orign_y,
  input  wire [2:0]    piece_in_payload_type,
  input  wire [1:0]    piece_in_payload_rot,
  output wire          blocks_out_valid,
  input  wire          blocks_out_ready,
  output wire [1:0]    blocks_out_payload_x,
  output wire [2:0]    blocks_out_payload_y,
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
  wire       [2:0]    temp_test_blk_pos_y;
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
  wire       [1:0]    piece_payload_orign_x;
  wire       [2:0]    piece_payload_orign_y;
  wire       [2:0]    piece_payload_type;
  wire       [1:0]    piece_payload_rot;
  reg                 piece_in_rValid;
  wire                piece_in_fire;
  reg        [1:0]    piece_in_rData_orign_x;
  reg        [2:0]    piece_in_rData_orign_y;
  reg        [2:0]    piece_in_rData_type;
  reg        [1:0]    piece_in_rData_rot;
  wire                blk_offset_valid;
  wire                blk_offset_ready;
  wire       [1:0]    blk_offset_payload_x;
  wire       [1:0]    blk_offset_payload_y;
  wire                piece_stage_valid;
  wire                piece_stage_ready;
  wire       [1:0]    piece_stage_payload_orign_x;
  wire       [2:0]    piece_stage_payload_orign_y;
  wire       [2:0]    piece_stage_payload_type;
  wire       [1:0]    piece_stage_payload_rot;
  reg                 piece_rValid;
  reg        [1:0]    piece_rData_orign_x;
  reg        [2:0]    piece_rData_orign_y;
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
  wire       [1:0]    test_blk_pos_x;
  wire       [2:0]    test_blk_pos_y;
  wire                blk_offset_translated_valid;
  reg                 blk_offset_translated_ready;
  wire       [1:0]    blk_offset_translated_payload_x;
  wire       [2:0]    blk_offset_translated_payload_y;
  wire                blk_offset_translated_m2sPipe_valid;
  wire                blk_offset_translated_m2sPipe_ready;
  wire       [1:0]    blk_offset_translated_m2sPipe_payload_x;
  wire       [2:0]    blk_offset_translated_m2sPipe_payload_y;
  reg                 blk_offset_translated_rValid;
  reg        [1:0]    blk_offset_translated_rData_x;
  reg        [2:0]    blk_offset_translated_rData_y;
  `ifndef SYNTHESIS
  reg [7:0] piece_in_payload_type_string;
  reg [7:0] piece_payload_type_string;
  reg [7:0] piece_in_rData_type_string;
  reg [7:0] piece_stage_payload_type_string;
  reg [7:0] piece_rData_type_string;
  `endif


  assign temp_temp_blk_offset_payload_x_1_1 = temp_blk_offset_payload_x;
  assign temp_temp_blk_offset_payload_x_1 = {1'd0, temp_temp_blk_offset_payload_x_1_1};
  assign temp_test_blk_pos_y = {1'd0, blk_offset_payload_y};
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
  assign test_blk_pos_x = (piece_payload_orign_x + blk_offset_payload_x);
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
        default : begin
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
