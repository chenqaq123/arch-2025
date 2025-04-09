`ifndef __RD_FORWARDING_MUX_SV
`define __RD_FORWARDING_MUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module rd_forwarding_mux
    import common::*;
    import pipes::*;(
    input u64 ID_rd, WB, ALU_out,
    input forwarding_control forwarding,
    output u64 rd
);
     always_comb begin
        unique case (forwarding)
            FROM_ID_EX_ID: begin
                rd = ID_rd;
            end
            FROM_WB: begin
                rd = WB;
            end
            FROM_ALU_OUT: begin
                rd = ALU_out;
            end
            default: begin
                rd = rd;
            end
        endcase
    end
endmodule

`endif