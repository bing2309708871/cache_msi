//test file
`timescale 1 ns/1 ps

module tb
    import cache_pkg::*;
();



    logic clock;
    logic reset_n;

    cache_if vif(clock,reset_n);


    always #5 clock <= ~clock;

    cache_top top(
        .clock  (vif.clk),
        .reset_n (vif.rst_n),
        .req_i(vif.req_i),
        .req_i_valid(vif.req_i_valid),
        .req_o_ready(vif.req_o_ready)
        );
    
    initial begin
        clock <= 1'b0;
        reset_n <= 1'b0;
        repeat(2) @(posedge clock);
        reset_n <= 1'b1;
    
    end
endmodule
