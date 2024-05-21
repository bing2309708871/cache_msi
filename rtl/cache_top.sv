//test file
`timescale 1 ns/1 ps

module cache_top
    import cache_pkg::*;
(
input logic clock,
input logic reset_n,
input logic [L1_NUM-1:0][3:0] req_i,
input logic [L1_NUM-1:0]    req_i_valid,
output logic    [L1_NUM-1:0]    req_o_ready


);



logic [3:0] req_l1l2[2];
logic req_valid_l1l2[2];
logic req_ready_l1l2[2];

logic [3:0] reply_l1l2[2];
logic reply_valid_l1l2[2];
logic reply_ready_l1l2[2];

logic [3:0] snoop_l1l2[2];
logic snoop_valid_l1l2[2];
logic snoop_ready_l1l2[2];

logic [3:0] s_reply_l1l2[2];
logic s_reply_valid_l1l2[2];
logic s_reply_ready_l1l2[2];



l1_cache 
#(.ID(0))
l1_cache_dut0(
    .clock(clock),
    .reset_n(reset_n),
    .req_up(req_i[0]),
    .req_up_valid(req_i_valid[0]),
    .req_up_ready(req_o_ready[0]),

    .req_down(req_l1l2[0]),
    .req_down_valid(req_valid_l1l2[0]),
    .req_down_ready(req_ready_l1l2[0]),

    .reply_down(reply_l1l2[0]),
    .reply_down_valid(reply_valid_l1l2[0]),
    .reply_down_ready(reply_ready_l1l2[0]),

    .snoop_down(snoop_l1l2[0]),
    .snoop_down_valid(snoop_valid_l1l2[0]),
    .snoop_down_ready(snoop_ready_l1l2[0]),

    .s_reply_down(s_reply_l1l2[0]),
    .s_reply_down_valid(s_reply_valid_l1l2[0]),
    .s_reply_down_ready(s_reply_ready_l1l2[0])
);

l1_cache 
#(.ID(1))
l1_cache_dut1(
    .clock(clock),
    .reset_n(reset_n),
    .req_up(req_i[1]),
    .req_up_valid(req_i_valid[1]),
    .req_up_ready(req_o_ready[1]),

    .req_down(req_l1l2[1]),
    .req_down_valid(req_valid_l1l2[1]),
    .req_down_ready(req_ready_l1l2[1]),

    .reply_down(reply_l1l2[1]),
    .reply_down_valid(reply_valid_l1l2[1]),
    .reply_down_ready(reply_ready_l1l2[1]),

    .snoop_down(snoop_l1l2[1]),
    .snoop_down_valid(snoop_valid_l1l2[1]),
    .snoop_down_ready(snoop_ready_l1l2[1]),


    .s_reply_down(s_reply_l1l2[1]),
    .s_reply_down_valid(s_reply_valid_l1l2[1]),
    .s_reply_down_ready(s_reply_ready_l1l2[1])
);

l2_cache l2_cache_dut(
    .clock(clock),
    .reset_n(reset_n),

    .req_up(req_l1l2),
    .req_up_valid(req_valid_l1l2),
    .req_up_ready(req_ready_l1l2),

    .reply_up(reply_l1l2),
    .reply_up_valid(reply_valid_l1l2),
    .reply_up_ready(reply_ready_l1l2),

    .snoop_up(snoop_l1l2),
    .snoop_up_valid(snoop_valid_l1l2),
    .snoop_up_ready(snoop_ready_l1l2),

    .s_reply_up(s_reply_l1l2),
    .s_reply_up_valid(s_reply_valid_l1l2),
    .s_reply_up_ready(s_reply_ready_l1l2)

);
endmodule
