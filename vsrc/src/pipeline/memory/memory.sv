`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "src/pipeline/memory/readdata.sv"
`include "src/pipeline/memory/writedata.sv"
`else

`endif


module memory
	import common::*;
	import pipes::*;(
    input execute_data_t dataE,
    input dbus_req_t dreq,

    output logic stallM,
    output dbus_resp_t dresp,
    output memory_data_t dataM_nxt
);

    msize_t msize;
    strobe_t strobe;
    logic mem_unsigned;
    u64 wd;
    u64 _rd;
    u64 rd;

    always_comb begin :  
        unique case (dataE.ctl.MemSize)
            MSize_zero: begin
            end
            MSize_8bits: begin
                msize = MSIZE1;
            end
            MSize_16bits: begin
                msize = MSIZE2;
            end
            MSize_32bits: begin
                msize = MSIZE4;
            end
            MSize_64bits: begin
                msize = MSIZE8;
            end
            default: begin
            end
        endcase 
        unique case (dataE.ctl.wbType) 
            WBNoHandle: begin
                mem_unsigned = '1;
            end
            WB_7: begin //lbu
                mem_unsigned = '1;
            end
            WB_15: begin //lhu
                mem_unsigned = '1;
            end
            WB_31: begin //lwu
                mem_unsigned = '1;
            end
            WB_63: begin //ld
                mem_unsigned = '0;
            end
            WB_7_sext: begin //lb
                mem_unsigned = '0;
            end
            WB_15_sext: begin //lh
                mem_unsigned = '0;
            end
            WB_31_sext: begin //lw
                mem_unsigned = '0;
            end
            default: begin
                mem_unsigned = '1;
            end
        endcase

        dreq.valid = 1'b0;
        if (dataE.ctl.MemWrite) begin
            dreq.valid = 1'b1;
            dreq.addr = dataE.alu_out;
            dreq.size = msize;
            dreq.strobe = strobe;
            dreq.data = wd;
        end
        if (dataE.ctl.MemRead) begin
            dreq.valid = 1'b1;
            dreq.addr = dataE.alu_out;
            dreq.size = dataE.msize;
            dreq.strobe = '0;
            _rd = dresp.data;
        end
    end

    readdata readdata(
        ._rd(_rd),
        .addr(dataE.alu_out[2:0]),
        .msize(msize),
        .mem_unsigned(mem_unsigned),
        .rd(rd)
    );

    writedata writedata(
        .addr(dataE.alu_out[2:0]),
        ._wd(dataE.MemWriteData),
        .msize(msize),
        .wd(wd),
        .strobe(strobe)
    );

    assign dataM_nxt.pc = dataE.pc;
    assign dataM_nxt.raw_instr = dataE.raw_instr;

    assign dataM_nxt.ctl = dataE.ctl;
    assign dataM_nxt.dst = dataE.dst;
    assign dataM_nxt.alu_out = dataE.alu_out;

    assign dataM_nxt.valid = dataE.valid & ~stallM & (dataE.ctl.ALUOP != ALU_UNKNOW);

    assign stallM = dreq.valid && ~dresp.data_ok;
    // TODO

endmodule

`endif