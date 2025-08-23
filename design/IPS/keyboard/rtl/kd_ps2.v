// Generator : SpinalHDL dev    git head : b81cafe88f26d2deab44d860435c5aad3ed2bc8e
// Component : kd_ps2
// Git hash  : c572500bbab7331f4642c6de3008dc5facd9b05b

`timescale 1ns/1ps

module kd_ps2 (
  inout  wire          ps2_clk,
  inout  wire          ps2_data,
  output wire          rd_data_valid,
  output wire [7:0]    rd_data_payload,
  output reg  [3:0]    keys_valid,
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
    .clk              (clk                      ), //i
    .rst              (reset                    ), //i
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

  assign break_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'hf0));
  assign rd_data_valid = ps2_inst_ps2_rddata_valid;
  assign rd_data_payload = ps2_inst_ps2_rd_data;
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
  end

  assign down_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1b));
  assign down_tick_2nd = (down_tick && down_valid);
  assign left_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h1c));
  assign left_tick_2nd = (left_tick && left_valid);
  assign right_tick = (ps2_inst_ps2_rddata_valid && (ps2_inst_ps2_rd_data == 8'h23));
  assign right_tick_2nd = (right_tick && right_valid);
  assign is_key_received = (|{right_tick,{left_tick,{down_tick,up_tick}}});
  assign is_key_2nd_recevied = (|{right_tick_2nd,{left_tick_2nd,{down_tick_2nd,up_tick_2nd}}});
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
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      up_valid <= 1'b0;
      down_valid <= 1'b0;
      left_valid <= 1'b0;
      right_valid <= 1'b0;
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
      rx_fsm_stateReg <= rx_fsm_stateNext;
    end
  end


endmodule
