// Created by fizzgen version 5.20 on 2020:01:12 at 06:33:20 (www.fizzim.com)

module TCP (
  output logic ACK_o,
  output logic FIN_o,
  output logic RST_o,
  output logic SYN_o,
  input ACK_i,
  input FIN_i,
  input RST_i,
  input SYN_i,
  input a_opn,
  input clk,
  input cls,
  input p_opn,
  input rst_n,
  input send_data,
  input timo_strb
);

  // state bits
  enum {
    CLOSED_BIT,
    CLOSE_WAIT_BIT,
    CLOSING_BIT,
    ESTABLISHED_BIT,
    FIN_WAIT_1_BIT,
    FIN_WAIT_2_BIT,
    LAST_ACK_BIT,
    LISTEN_BIT,
    SYN_RCVD_BIT,
    SYN_SENT_BIT,
    TIME_WAIT_BIT
  } index;

  enum logic [10:0] {
    CLOSED      = 11'b1<<CLOSED_BIT,
    CLOSE_WAIT  = 11'b1<<CLOSE_WAIT_BIT,
    CLOSING     = 11'b1<<CLOSING_BIT,
    ESTABLISHED = 11'b1<<ESTABLISHED_BIT,
    FIN_WAIT_1  = 11'b1<<FIN_WAIT_1_BIT,
    FIN_WAIT_2  = 11'b1<<FIN_WAIT_2_BIT,
    LAST_ACK    = 11'b1<<LAST_ACK_BIT,
    LISTEN      = 11'b1<<LISTEN_BIT,
    SYN_RCVD    = 11'b1<<SYN_RCVD_BIT,
    SYN_SENT    = 11'b1<<SYN_SENT_BIT,
    TIME_WAIT   = 11'b1<<TIME_WAIT_BIT,
    XXX = 'x
  } state, nextstate;


  // comb always block
  always_comb begin
    nextstate = XXX; // default to x because default_state_is_x is set
    ACK_o = 0; // default
    FIN_o = 0; // default
    RST_o = 0; // default
    SYN_o = 0; // default
    unique case (1'b1)
      state[CLOSED_BIT] : begin
        if              (a_opn) begin
                                                       nextstate = SYN_SENT;
                                                       SYN_o = 1;
        end
        else if                (p_opn)                 nextstate = LISTEN;
        else                                           nextstate = CLOSED;
      end
      state[CLOSE_WAIT_BIT]: begin
        if                     (cls) begin
                                                       nextstate = LAST_ACK;
                                                       FIN_o = 1;
        end
      end
      state[CLOSING_BIT]: if   (ACK_i)                 nextstate = TIME_WAIT;
      state[ESTABLISHED_BIT]: begin
        unique if              (cls) begin
                                                       nextstate = FIN_WAIT_1;
                                                       FIN_o = 1;
        end
        else if                (FIN_i) begin
                                                       nextstate = CLOSE_WAIT;
                                                       ACK_o = 1;
        end
        else if                (RST_i)                 nextstate = LISTEN;
        else if                (ACK_i)                 nextstate = ESTABLISHED;
      end
      state[FIN_WAIT_1_BIT]: begin
        if                     (FIN_i && ACK_i) begin
                                                       nextstate = TIME_WAIT;
                                                       ACK_o = 1;
        end
        else if                (FIN_i) begin
                                                       nextstate = CLOSING;
                                                       ACK_o = 1;
        end
        else if                (ACK_i)                 nextstate = FIN_WAIT_2;
      end
      state[FIN_WAIT_2_BIT]: begin
        if                     (FIN_i) begin
                                                       nextstate = TIME_WAIT;
                                                       ACK_o = 1;
        end
      end
      state[LAST_ACK_BIT]: if  (ACK_i || timo_strb)    nextstate = CLOSED;
      state[LISTEN_BIT] : begin
        unique if              (cls)                   nextstate = CLOSED;
        else if                (send_data) begin
                                                       nextstate = SYN_SENT;
                                                       SYN_o = 1;
        end
        else if                (SYN_i) begin
                                                       nextstate = SYN_RCVD;
                                                       SYN_o = 1;
                                                       ACK_o = 1;
        end
      end
      state[SYN_RCVD_BIT]: begin
        unique if              (cls) begin
                                                       nextstate = FIN_WAIT_1;
                                                       FIN_o = 1;
        end
        else if                (timo_strb) begin
                                                       nextstate = CLOSED;
                                                       RST_o = 1;
        end
        else if                (ACK_i)                 nextstate = ESTABLISHED;
        else if                (RST_i)                 nextstate = LISTEN;
      end
      state[SYN_SENT_BIT]: begin
        if                     (cls || timo_strb)      nextstate = CLOSED;
        else if                (SYN_i && ACK_i) begin
                                                       nextstate = ESTABLISHED;
                                                       ACK_o = 1;
        end
        else if                (SYN_i) begin
                                                       nextstate = SYN_RCVD;
                                                       ACK_o = 1;
                                                       SYN_o = 1;
        end
      end
      state[TIME_WAIT_BIT]: if (timo_strb)             nextstate = CLOSED;
    endcase
  end

  // sequential always block
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= CLOSED;
    else
      state <= nextstate;
  end
endmodule
