`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/pipeline/decode/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input fetch_data_t dataF,
    input control_t ctl,
    input u64 imm_64,

    input u64 rd1, rd2,
    input u64 wb_data,
    input forwarding_control forwardingAA, forwardingBB,

    input logic stall,
    
    output decode_data_t dataD_nxt
);

    u64 ID_rd1, ID_rd2;
    rd_forwarding_mux rd1_forwarding_mux(
        .ID_rd(rd1),
        .WB(wb_data),
        .ALU_out('hcccc),
        .forwarding(forwardingAA),
        .rd(ID_rd1)
    );

    rd_forwarding_mux rd2_forwarding_mux(
        .ID_rd(rd2),
        .WB(wb_data),
        .ALU_out('hcccc),
        .forwarding(forwardingBB),
        .rd(ID_rd2)
    );

    assign dataD_nxt.pc = dataF.pc;
    assign dataD_nxt.raw_instr = dataF.raw_instr;
    
    assign dataD_nxt.ctl = ctl;
    assign dataD_nxt.dst = dataF.raw_instr[11:7];

    assign dataD_nxt.srca = ID_rd1;
    assign dataD_nxt.srcb = ID_rd2;
    assign dataD_nxt.imm_64 = imm_64;
    assign dataD_nxt.rs1 = dataF.raw_instr[19:15];
	assign dataD_nxt.rs2 = dataF.raw_instr[24:20];

    assign dataD_nxt.valid = dataF.valid & ~stall;
    assign dataD_nxt.csr = dataF.raw_instr[31:20];
endmodule


`endif
