// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : seven_bag_rng
// Git hash  : f3f46e1ae9170eb6a213ce0b3ec7f8de4ccf798e

`timescale 1ns/1ps

module seven_bag_rng (
  input  wire          io_enable,
  output reg           io_shape_valid,
  output wire [2:0]    io_shape_payload,
  input  wire          clk,
  input  wire          reset
);
  localparam IDLE = 3'd0;
  localparam CHECK = 3'd1;
  localparam OUTPUT_1 = 3'd2;
  localparam DONE = 3'd3;
  localparam SHIFT = 3'd4;
  localparam ELEMENT = 3'd5;

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
        if(existedOrInvalid) begin
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
  always @(posedge clk or posedge reset) begin
    if(reset) begin
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
        DONE : begin
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
        SHIFT : begin
        end
        ELEMENT : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
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
