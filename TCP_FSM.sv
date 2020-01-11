// Created by fizzgen version 5.20 on 2020:01:11 at 19:48:58 (www.fizzim.com)

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
  enum logic [7:0] {
    CLOSED      = 8'b00000000, // extra=0000 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    CLOSE_WAIT  = 8'b00010000, // extra=0001 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    CLOSING     = 8'b00100000, // extra=0010 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    ESTABLISHED = 8'b00110000, // extra=0011 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    FIN_WAIT_1  = 8'b01000000, // extra=0100 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    FIN_WAIT_2  = 8'b01010000, // extra=0101 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    LAST_ACK    = 8'b01100000, // extra=0110 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    LISTEN      = 8'b01110000, // extra=0111 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    SYN_RCVD    = 8'b10000000, // extra=1000 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    SYN_SENT    = 8'b10010000, // extra=1001 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    TIME_WAIT   = 8'b10100000, // extra=1010 SYN_o=0 RST_o=0 FIN_o=0 ACK_o=0 
    XXX = 'x
  } state, nextstate;


  // comb always block
  always_comb begin
    nextstate = XXX; // default to x because default_state_is_x is set
    case (state)
      CLOSED     : if      (a_opn)               nextstate = SYN_SENT;
                   else if (p_opn)               nextstate = LISTEN;
                   else                          nextstate = CLOSED;
      CLOSE_WAIT : if      (cls)                 nextstate = LAST_ACK;
      CLOSING    : if      (ACK_i)               nextstate = TIME_WAIT;
      ESTABLISHED: if      (cls)                 nextstate = FIN_WAIT_1;
                   else if (FIN_i)               nextstate = CLOSE_WAIT;
                   else if (RST_i)               nextstate = LISTEN;
                   else if (ACK_i)               nextstate = ESTABLISHED;
      FIN_WAIT_1 : if      (FIN_i && ACK_i)      nextstate = TIME_WAIT;
                   else if (FIN_i)               nextstate = CLOSING;
                   else if (ACK_i)               nextstate = FIN_WAIT_2;
      FIN_WAIT_2 : if      (FIN_i)               nextstate = TIME_WAIT;
      LAST_ACK   : if      (ACK_i || timo_strb)  nextstate = CLOSED;
      LISTEN     : if      (send_data)           nextstate = SYN_SENT;
                   else if (SYN_i)               nextstate = SYN_RCVD;
                   else if (cls)                 nextstate = CLOSED;
      SYN_RCVD   : if      (cls)                 nextstate = FIN_WAIT_1;
                   else if (timo_strb)           nextstate = CLOSED;
                   else if (ACK_i)               nextstate = ESTABLISHED;
                   else if (RST_i)               nextstate = LISTEN;
      SYN_SENT   : if      (cls || timo_strb)    nextstate = CLOSED;
                   else if (SYN_i && ACK_i)      nextstate = ESTABLISHED;
                   else if (SYN_i)               nextstate = SYN_RCVD;
      TIME_WAIT  : if      (timo_strb)           nextstate = CLOSED;
    endcase
  end

  // Assign reg'd outputs to state bits
  assign ACK_o = state[0];
  assign FIN_o = state[1];
  assign RST_o = state[2];
  assign SYN_o = state[3];

  // sequential always block
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= CLOSED;
    else
      state <= nextstate;
  end
endmodule
