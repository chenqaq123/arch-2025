`ifndef CSR_REGS_SV
`define CSR_REGS_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/csr.sv"
`endif


module csr_regs
    import common::*;
    import pipes::*;
    import csr_pkg::*;(
    input logic clk, reset,
    
    // CSR访问接口
    input csr_addr_t csr_addr_read,
    input csr_addr_t csr_addr_write,
    input u64 csr_wdata,
    input logic csr_we,
    output u64 csr_rdata,
    input u1 isCSRRC,
    
    // mcycle自增
    input logic mcycle_inc,
    
    // DifftestCSRState接口
    output u64 mstatus_out,
    output u64 mtvec_out,
    output u64 mepc_out,
    output u64 mcause_out,
    output u64 mip_out,
    output u64 mie_out,
    output u64 mscratch_out,
    output u64 mcycle_out,
    output u64 mhartid_out,
    output u64 sstatus_out,
    output u64 mtval_out,
    output u64 satp_out
);

    // CSR寄存器定义
    u64 mstatus, mtvec, mip, mie, mscratch;
    u64 mcause, mtval, mepc, mcycle;
    u64 mhartid, satp;

    // mhartid固定为0
    assign mhartid = '0;
    assign mhartid_out = {56'b0, mhartid[7:0]};

    // sstatus是mstatus的部分位
    assign sstatus_out = mstatus & SSTATUS_MASK;

    // mcycle计数器逻辑
    always_ff @(posedge clk) begin
        if (reset) begin
            mcycle <= '0;
        end else if (csr_we && csr_addr_write == CSR_MCYCLE) begin
            mcycle <= csr_wdata;
        end else if (mcycle_inc) begin
            mcycle <= mcycle + 1;
        end
    end

    // CSR读写逻辑
    always_ff @(posedge clk) begin
        if (reset) begin
            mstatus <= '0;
            mtvec <= '0;
            mip <= '0;
            mie <= '0;
            mscratch <= '0;
            mcause <= '0;
            mtval <= '0;
            mepc <= '0;
            satp <= '0;
        end else if (csr_we & isCSRRC) begin
            unique case (csr_addr_write)
                CSR_MSTATUS: mstatus <= (mstatus & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F & MSTATUS_MASK);
                CSR_MTVEC: mtvec <= (mtvec & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F & MTVEC_MASK);
                CSR_MIP: mip <= (mip & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F & MIP_MASK);
                CSR_MIE: mie <= (mie & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MSCRATCH: mscratch <= (mscratch & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MCAUSE: mcause <= (mcause & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MTVAL: mtval <= (mtval & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MEPC: mepc <= (mepc & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_SATP: satp <= (satp & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                default: ; // do nothing
            endcase
        end else if (csr_we) begin
            unique case (csr_addr_write)
                CSR_MSTATUS: mstatus <= csr_wdata & MSTATUS_MASK;
                CSR_MTVEC: mtvec <= csr_wdata & MTVEC_MASK;
                CSR_MIP: mip <= csr_wdata & MIP_MASK;
                CSR_MIE: mie <= csr_wdata;
                CSR_MSCRATCH: mscratch <= csr_wdata;
                CSR_MCAUSE: mcause <= csr_wdata;
                CSR_MTVAL: mtval <= csr_wdata;
                CSR_MEPC: mepc <= csr_wdata;
                CSR_SATP: satp <= csr_wdata;
                default: ; // do nothing
            endcase
        end
    end

    // CSR读取逻辑
    always_comb begin
        unique case (csr_addr_read)
            CSR_MSTATUS: csr_rdata = mstatus;
            CSR_MTVEC: csr_rdata = mtvec;
            CSR_MIP: csr_rdata = mip;
            CSR_MIE: csr_rdata = mie;
            CSR_MSCRATCH: csr_rdata = mscratch;
            CSR_MCAUSE: csr_rdata = mcause;
            CSR_MTVAL: csr_rdata = mtval;
            CSR_MEPC: csr_rdata = mepc;
            CSR_MCYCLE: csr_rdata = mcycle;
            CSR_MHARTID: csr_rdata = mhartid;
            CSR_SATP: csr_rdata = satp;
            default: csr_rdata = '0;
        endcase
    end

    // Difftest接口输出
    assign mstatus_out = mstatus;
    assign mtvec_out = mtvec;
    assign mepc_out = mepc;
    assign mcause_out = mcause;
    assign mip_out = mip;
    assign mie_out = mie;
    assign mscratch_out = mscratch;
    assign mcycle_out = mcycle;
    assign mtval_out = mtval;
    assign satp_out = satp;

endmodule

`endif