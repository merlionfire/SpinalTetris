// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : kd_ps2
// Git hash  : f710c93e905c21d66fa86f775a08fb48d62f39ea

`timescale 1ns/1ps

module kd_ps2 (
  inout  wire          ps2_clk,
  inout  wire          data,
  output wire          rd_data_valid,
  output wire [7:0]    rd_data_payload,
  output wire          key_up_valid,
  output wire          key_down_valid,
  input  wire          reset,
  input  wire          clk
);
  localparam IDLE = 2'd0;
  localparam WAIT_BREAK = 2'd1;
  localparam WAIT_LAST = 2'd2;
  localparam DEFAULT_1 = 2'd3;

  wire                ps2_inst_ps2_tx_done;
  wire                ps2_inst_ps2_tx_ready;
  wire                ps2_inst_ps2_rddata_valid;
  wire       [7:0]    ps2_inst_ps2_rd_data;
  wire       [7:0]    ps2_inst_ps2_rd_ready;
  reg                 key_valid_up_valid;
  reg                 key_valid_down_valid;
  reg                 up_tick;
  reg                 down_tick;
  reg                 break_tick;
  reg                 other_tick;
  wire                up_key_is_up;
  wire                down_key_is_up;
  wire                rx_fsm_wantExit;
  reg                 rx_fsm_wantStart;
  wire                rx_fsm_wantKill;
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
    .clk              (clk                       ), //i
    .rst              (reset                     ), //i
    .ps2_clk          (ps2_clk                   ), //~
    .ps2_data         (data                      ), //~
    .ps2_wr_stb       (1'b0                      ), //i
    .ps2_wr_data      (8'h0                      ), //i
    .ps2_tx_done      (ps2_inst_ps2_tx_done      ), //o
    .ps2_tx_ready     (ps2_inst_ps2_tx_ready     ), //o
    .ps2_rddata_valid (ps2_inst_ps2_rddata_valid ), //o
    .ps2_rd_data      (ps2_inst_ps2_rd_data[7:0] ), //o
    .ps2_rd_ready     (ps2_inst_ps2_rd_ready[7:0])  //o
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

  assign key_up_valid = key_valid_up_valid;
  assign key_down_valid = key_valid_down_valid;
  assign rd_data_valid = ps2_inst_ps2_rddata_valid;
  assign rd_data_payload = ps2_inst_ps2_rd_data;
  assign up_key_is_up = (up_tick && key_valid_up_valid);
  assign down_key_is_up = (down_tick && key_valid_down_valid);
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
        if(other_tick) begin
          rx_fsm_stateNext = WAIT_BREAK;
        end
        if((up_key_is_up || down_key_is_up)) begin
          rx_fsm_stateNext = IDLE;
        end
      end
      DEFAULT_1 : begin
        rx_fsm_stateNext = IDLE;
      end
      default : begin
        if((up_tick || down_tick)) begin
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
  assign rx_fsm_onExit_IDLE = ((rx_fsm_stateNext != IDLE) && (rx_fsm_stateReg == IDLE));
  assign rx_fsm_onExit_WAIT_BREAK = ((rx_fsm_stateNext != WAIT_BREAK) && (rx_fsm_stateReg == WAIT_BREAK));
  assign rx_fsm_onExit_WAIT_LAST = ((rx_fsm_stateNext != WAIT_LAST) && (rx_fsm_stateReg == WAIT_LAST));
  assign rx_fsm_onExit_DEFAULT_1 = ((rx_fsm_stateNext != DEFAULT_1) && (rx_fsm_stateReg == DEFAULT_1));
  assign rx_fsm_onEntry_IDLE = ((rx_fsm_stateNext == IDLE) && (rx_fsm_stateReg != IDLE));
  assign rx_fsm_onEntry_WAIT_BREAK = ((rx_fsm_stateNext == WAIT_BREAK) && (rx_fsm_stateReg != WAIT_BREAK));
  assign rx_fsm_onEntry_WAIT_LAST = ((rx_fsm_stateNext == WAIT_LAST) && (rx_fsm_stateReg != WAIT_LAST));
  assign rx_fsm_onEntry_DEFAULT_1 = ((rx_fsm_stateNext == DEFAULT_1) && (rx_fsm_stateReg != DEFAULT_1));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      up_tick <= 1'b0;
      down_tick <= 1'b0;
      break_tick <= 1'b0;
      other_tick <= 1'b0;
      rx_fsm_stateReg <= IDLE;
    end else begin
      if(ps2_inst_ps2_rddata_valid) begin
        case(ps2_inst_ps2_rd_data)
          8'h1d : begin
            up_tick <= 1'b1;
          end
          8'h1b : begin
            down_tick <= 1'b1;
          end
          8'hf0 : begin
            break_tick <= 1'b1;
          end
          default : begin
            other_tick <= 1'b1;
          end
        endcase
      end
      rx_fsm_stateReg <= rx_fsm_stateNext;
    end
  end

  always @(posedge clk) begin
    case(rx_fsm_stateReg)
      WAIT_BREAK : begin
      end
      WAIT_LAST : begin
        if(up_key_is_up) begin
          key_valid_up_valid <= 1'b0;
        end
        if(down_key_is_up) begin
          key_valid_down_valid <= 1'b0;
        end
      end
      DEFAULT_1 : begin
      end
      default : begin
        if(up_tick) begin
          key_valid_up_valid <= 1'b1;
        end
        if(down_tick) begin
          key_valid_down_valid <= 1'b1;
        end
      end
    endcase
    if(rx_fsm_onEntry_IDLE) begin
      key_valid_up_valid <= 1'b0;
      key_valid_down_valid <= 1'b0;
    end
  end


endmodule
