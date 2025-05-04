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
    output dbus_req_t dreq,

    output logic stallM,
    output logic flushM,
    input dbus_resp_t dresp,
    output memory_data_t dataM_nxt
);

    msize_t msize;
    strobe_t strobe;
    logic mem_unsigned;
    u64 wd;
    u64 _rd;
    u64 rd;
    logic skip;

    // 先计算 msize
    always_comb begin
        msize = MSIZE1;  // 默认值
        if (dataE.ctl.MemWrite || dataE.ctl.MemRead) begin
            unique case (dataE.ctl.MemSize)
                MSize_zero: msize = MSIZE1;
                MSize_8bits: msize = MSIZE1;
                MSize_16bits: msize = MSIZE2;
                MSize_32bits: msize = MSIZE4;
                MSize_64bits: msize = MSIZE8;
                default: msize = MSIZE1;
            endcase
        end
    end

    // 分离 mem_unsigned 的计算
    always_comb begin
        mem_unsigned = '1;  // 默认值
        unique case (dataE.ctl.wbType)
            WBNoHandle, WB_7, WB_15, WB_31: mem_unsigned = '1;
            WB_63, WB_7_sext, WB_15_sext, WB_31_sext: mem_unsigned = '0;
            default: mem_unsigned = '1;
        endcase
    end

    // 分离 dreq 和 _rd 的计算
    always_comb begin
        // 默认值
        dreq.valid = 1'b0;
        dreq.addr = '0;
        dreq.size = msize;
        dreq.strobe = '0;
        dreq.data = '0;
        _rd = '0;

        if (dataE.ctl.MemWrite) begin
            dreq.valid = 1'b1;
            dreq.addr = dataE.alu_out;
            dreq.size = msize;
            dreq.strobe = strobe;
            dreq.data = wd;
        end else if (dataE.ctl.MemRead) begin
            dreq.valid = 1'b1;
            dreq.addr = dataE.alu_out;
            dreq.size = msize;
            dreq.strobe = '0;
            _rd = dresp.data;
        end
        skip = dreq.valid && !(dreq.addr[31]);
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

    assign dataM_nxt.valid = dataE.valid & ~stallM & (dataE.ctl.alufunc != ALU_UNKNOWN);
    assign dataM_nxt.MemReadData = rd;
    assign dataM_nxt.skip = skip;

    // TODO
    assign stallM = dreq.valid && ~dresp.data_ok;
    assign flushM = dreq.valid && ~dresp.data_ok;

    assign dataM_nxt.csr = dataE.csr;
    assign dataM_nxt.csr_rdata = dataE.csr_rdata;
endmodule

`endif