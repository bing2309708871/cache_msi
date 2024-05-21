module l1_cache
    import cache_pkg::*;
#(parameter ID = 0)
(
    input clock,
    input reset_n,

    input logic [3:0] req_up,
    input logic req_up_valid,
    output logic req_up_ready,

    output logic [3:0] req_down,
    output logic req_down_valid,
    input logic req_down_ready,

    input logic [3:0] reply_down,
    input logic reply_down_valid,
    output logic reply_down_ready,

    input logic [3:0] snoop_down,
    input logic snoop_down_valid,
    output logic snoop_down_ready,

    output logic [3:0] s_reply_down,
    output logic s_reply_down_valid,
    input logic s_reply_down_ready
    );

    state_m_type state_m;
    state_type state;
    transaction_type trans;

    logic req_fifo_full;
    logic req_fifo_empty;
    logic req_fifo_push;
    logic req_fifo_pop;
    logic [3:0]req_out;

    logic snoop_fifo_full;
    logic snoop_fifo_empty;
    logic snoop_fifo_push;
    logic snoop_fifo_pop;
    logic [3:0]snoop_out;

    logic [1:0] arbiter;

    assign req_fifo_push = req_up_valid && req_up_ready;
    assign req_fifo_pop  = state_m == Start && ~req_fifo_empty && arbiter[1];


    assign snoop_fifo_push = snoop_down_valid && snoop_down_ready;
    assign snoop_fifo_pop  = ~snoop_fifo_empty && arbiter[0];

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            req_up_ready <= 1'b0;
            snoop_down_ready <= 1'b0;
        end else begin
            req_up_ready <= ~req_fifo_full;
            snoop_down_ready <= ~snoop_fifo_full;
        end
    end

    assign arbiter = ~snoop_fifo_empty ? 2'b01 : (~req_fifo_empty ? 2'b10 : 2'b00);

    fifo #(.DATA_WIDTH(4))
    fifo_req(
        .clk_i(clock),
        .rst_ni(reset_n),
        .flush_i(1'b0),
        .testmode_i(1'b0),
        .full_o(req_fifo_full),
        .empty_o(req_fifo_empty),
        .data_i(req_up),
        .push_i(req_fifo_push),
        .data_o(req_out),
        .pop_i(req_fifo_pop)
    );

    fifo #(.DATA_WIDTH(4))
    fifo_snoop(
        .clk_i(clock),
        .rst_ni(reset_n),
        .flush_i(1'b0),
        .testmode_i(1'b0),
        .full_o(snoop_fifo_full),
        .empty_o(snoop_fifo_empty),
        .data_i(snoop_down),
        .push_i(snoop_fifo_push),
        .data_o(snoop_out),
        .pop_i(snoop_fifo_pop)
    );


    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            snoop_down_ready <= 1'b1;
        end else if (snoop_fifo_pop) begin
            if (snoop_out == Int) begin
                state <= state_S;
                state_m <= Start;
                s_reply_down_valid <= 1'b1;
                s_reply_down <= Flush;
                $display("L1[%1d] recive snoop from l2",ID);
            end else if (snoop_out == Inv) begin
                if (state == state_E || state == state_M) begin
                    s_reply_down <= Flush;
                    s_reply_down_valid <= 1'b1;
                end else if(state == state_S) begin
                    s_reply_down <= InvAck;
                    s_reply_down_valid <= 1'b1;
                end
            end
        end
    end





    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            state_m <= Start;
            state <= state_I;
            //req_up_ready <= 1;
            req_down <= 'b0;
            req_down_valid <= 1'b0;
            reply_down_ready <= 1'b1;
            snoop_down_ready <= 1'b1;
            s_reply_down <= 'b0;
            s_reply_down_valid <= 1'b0;
        end else begin
            case (state_m)
                Start:begin
                    //req_up_ready <= 1'b1;
                    s_reply_down_valid <= 1'b0;
                    if (req_fifo_pop) begin // get a request
                        //req_up_ready <= 1'b0;
                        if (req_out == Read) begin
                            $display("L1[%1d] recive Read from core",ID);
                            if (state == state_S || state == state_E || state == state_M) begin
                                $display("L1[%1d] hit and send data to core",ID);
                            end else begin
                                $display("L1[%1d] send Read to L2",ID);
                                req_down <= Read;
                                req_down_valid <= 1'b1;
                                state_m <= Wait_ReplyD;
                                state <= state_I2S;
                            end
                        end else if (req_out == Write) begin
                            $display("L1[%1d] recive Write from core",ID);
                            if (state == state_E || state == state_M) begin
                                $display("L1[%1d] hit and send data to core",ID);
                            end else if (state == state_S) begin
                                $display("L1[%1d] send Upgr to L2",ID);
                                req_down <= Upgr;
                                req_down_valid <= 1'b1;
                                state_m <= Wait_Reply;
                                state <= state_S2M;
                            end else if (state == state_I) begin
                                $display("L1[%1d] send ReadX to L2",ID);
                                req_down <= ReadX;
                                req_down_valid <= 1'b1;
                                state_m <= Wait_ReplyD;
                                state <= state_I2M;
                            end

                        end
                    end 
                end
                Wait_ReplyD: begin
                    req_down_valid <= 1'b0;
                    if (reply_down_valid && reply_down_ready) begin
                        $display("L1[%1d] recive data from L2",ID);
                        s_reply_down_valid <= 1'b1;
                        $display("L1[%1d] send Ack to L2",ID);
                        $display("Back to start\n\n");
                        if (reply_down == toS) begin
                            state <= state_S;
                        end else if (reply_down == toE) begin
                            state <= state_E;
                        end
                        state_m <= Start;
                    end
                end
                Wait_Reply:begin
                    req_down_valid <= 1'b0;
                    if (reply_down_valid && reply_down_ready) begin
                        $display("L1[%1d] recive reply from L2",ID);
                        s_reply_down_valid <= 1'b1;
                        $display("L1[%1d] send Ack to L2",ID);
                        $display("Back to start\n\n");
                        state_m <= Start;
                        state <= state_M;
                    end
                end
            endcase
        end
    end
    
endmodule


