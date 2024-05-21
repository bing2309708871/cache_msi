module l2_cache
    import cache_pkg::*;
(
    input logic clock,
    input logic reset_n,

    input logic [3:0] req_up[2],
    input logic req_up_valid[2],
    output logic req_up_ready[2],

    output logic [3:0] reply_up[2],
    output logic reply_up_valid[2],
    input logic reply_up_ready[2],

    output logic [3:0] snoop_up[2],
    output logic snoop_up_valid[2],
    input logic snoop_up_ready[2],

    input logic [3:0] s_reply_up[2],
    input logic s_reply_up_valid[2],
    output logic s_reply_up_ready[2]
);

    state_type state;
    state_m_type state_m;

    logic [1:0] req_en;
    logic [1:0] s_reply_en;
    logic [1:0] req_oh;
    logic [1:0] s_reply_oh;

    logic [1:0] l1_valid;
    logic [1:0] source_req;

    genvar i;
    generate
    for(i=0;i<2;i++)begin
        assign req_en[i] = req_up_valid[i] & req_up_ready[i];
        assign s_reply_en[i] = s_reply_up_valid[i] & s_reply_up_ready[i];
    end
    endgenerate
    
    assign req_oh = req_en == 2'b01 ? 0 : (req_en == 2'b10 ? 1 :0);
    assign s_reply_oh = s_reply_en == 2'b01 ? 0 : (s_reply_en == 2'b10 ? 1 : 0 );


    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            state_m <= Start;
            state <= state_I;
            req_up_ready[0] <= 1'b1;
            reply_up[0] <= 'b0;
            reply_up_valid[0] <= 1'b0;
            snoop_up[0] <= 'b0;
            snoop_up_valid[1] <= 1'b0;
            s_reply_up_ready[0] <= 1'b1;
            req_up_ready[1] <= 1'b1;
            reply_up[1] <= 'b0;
            reply_up_valid[1] <= 1'b0;
            snoop_up[1] <= 'b0;
            snoop_up_valid[1] <= 1'b0;

            s_reply_up_ready[1] <= 1'b1;
            l1_valid <= 2'b0;
            source_req <= 2'b0;
        end else begin
            case (state_m)
                Start:begin
                    req_up_ready[req_oh] <= 1'b1;
                    if (req_en[req_oh]) begin
                        if (req_up[req_oh] == Read) begin
                            $display("L2 recive read from l1[%1d]",req_oh);
                            if (state == state_I)begin
                                $display("L2 send read to memory");
                                $display("L2 get data from memory");
                                l1_valid[req_oh] <= 1'b1;
                                state <= state_E;
                                state_m <= Wait_REQ_Ack;
                                reply_up_valid[req_oh] <= 1'b1;
                                reply_up[req_oh] <= toE;
                            end else if (state == state_E || state == state_M) begin
                                $display("L2 send snoop to L1[%1d]",l1_valid);
                                if(l1_valid[0] == 1'b1) begin
                                    snoop_up_valid[0] <= 1'b1;
                                    snoop_up[0] <= Int;
                                end
                                if(l1_valid[1] == 1'b1) begin
                                    snoop_up_valid[1] <= 1'b1;
                                    snoop_up[1] <= Int;
                                end
                                state_m <= Wait_SNP_Flush;
                                source_req <= req_oh;
                            end

                        end else if (req_up[req_oh] == Upgr) begin
                            $display("L2 send snoop to L1[%1d]",l1_valid);
                                if(l1_valid[0] == 1'b1 && source_req != 0) begin
                                    snoop_up_valid[0] <= 1'b1;
                                    snoop_up[0] <= Inv;
                                end
                                if(l1_valid[1] == 1'b1 && source_req != 1) begin
                                    snoop_up[1] <= Inv;
                                    snoop_up_valid[1] <= 1'b1;
                                end
                                state_m <= Wait_SNP_InvAck_Reply;
                                source_req <= req_oh;

                        end else if (req_up[req_oh] == ReadX) begin
                            if (state == state_I) begin
                                $display("L2 send read to memory");
                                $display("L2 get data from memory");
                                l1_valid[req_oh] <= 1'b1;
                                state <= state_E;
                                state_m <= Wait_REQ_Ack;
                                reply_up_valid[req_oh] <= 1'b1;
                            end else begin
                                $display("L2 send snoop to L1[%1d]",l1_valid);
                                if(l1_valid[0] == 1'b1 && source_req != 0) begin
                                    snoop_up_valid[0] <= 1'b1;
                                    snoop_up[0] <= Inv;
                                end
                                if(l1_valid[1] == 1'b1 && source_req != 1) begin
                                    snoop_up[1] <= Inv;
                                    snoop_up_valid[1] <= 1'b1;
                                end
                                state_m <= Wait_SNP_InvAck_Reply;
                                source_req <= req_oh;
                            end
                        end
                    end
                end
                Wait_REQ_Ack:begin
                    reply_up_valid[req_oh] <= 1'b0;
                    if(s_reply_en[s_reply_oh]) begin
                        $display("L2 recive ack from L1 [%1d]",s_reply_oh);
                        state_m <= Start;
                    end
                end
                Wait_SNP_Flush:begin
                    if(l1_valid[0] == 1'b1)
                        snoop_up_valid[0] <= 1'b0;
                    if(l1_valid[1] == 1'b1)
                        snoop_up_valid[1] <= 1'b0;
                    if(s_reply_en[s_reply_oh]) begin
                        $display("L2 recive Flush from L1 [%1d]",s_reply_oh);
                        reply_up_valid[source_req] <= 1'b1;
                        $display("L2 trans data to L1[%1d]",source_req);
                        l1_valid[source_req] <= 1'b1;
                        state_m <= Wait_REQ_Ack;
                    end
                    
                end
                Wait_SNP_InvAck_Reply:begin
                    if(l1_valid[0] == 1'b1 && source_req != 0)
                        snoop_up_valid[0] <= 1'b0;
                    if(l1_valid[1] == 1'b1 && source_req != 1)
                        snoop_up_valid[1] <= 1'b0;
                    if(s_reply_en[s_reply_oh]) begin
                        $display("L2 recive Inv from L1 [%1d]",s_reply_oh);
                        reply_up_valid[source_req] <= 1'b1;
                        $display("L2 trans data to L1[%1d]",source_req);
                        l1_valid[source_req] <= 1'b1;
                        state_m <= Wait_REQ_Ack;
                    end
                end
            endcase
        end
    end






endmodule
