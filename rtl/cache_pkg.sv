`ifndef CACHE_PKG_SV
`define CACHE_PKG_SV

package cache_pkg;

    parameter L1_NUM = 2;

    typedef enum logic [2:0] {
        state_I = 'b000,
        state_M = 'b001,
        state_S = 'b010,
        state_E = 'b011,
        state_O = 'b100,
        state_I2S='b101,
        state_S2M='b110,
        state_I2M='b111
    } state_type;

    typedef enum logic [3:0] {
        Read  = 'b0000,
        ReadX = 'b0001,
        Upgr  = 'b0010,
        ReplyD= 'b0011,
        Reply = 'b0100,
        Inv   = 'b0101,
        Int   = 'b0110,
        Flush = 'b0111,
        InvAck= 'b1000,
        Ack   = 'b1001,
        Write = 'b1010
    } transaction_type;

    typedef enum logic [3:0] {
        toS = 'b0000,
        toE = 'b0001
    } state_change_type;

    typedef enum logic [3:0] {
        Start                 = 'b0000,
        Wait_ReplyD           = 'b0001,
        Wait_Reply            = 'b0010,
        Wait_SNP_Ack          = 'b0011,
        Wait_SNP_Flush        ='b0100,
        Wait_SNP_InvAck_ReplyD='b0101,
        Wait_SNP_InvAck_Reply = 'b0110,
        Wait_REQ_Ack          = 'b0111,
        Wait_Fetch            = 'b1000
    } state_m_type;

endpackage

`endif
