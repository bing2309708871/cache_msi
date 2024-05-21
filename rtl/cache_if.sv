import cache_pkg::*;
interface cache_if(input logic clk,input logic rst_n);

    logic   [L1_NUM-1:0][3:0]   req_i;
    logic   [L1_NUM-1:0]        req_i_valid;
    logic   [L1_NUM-1:0]        req_o_ready;

endinterface
