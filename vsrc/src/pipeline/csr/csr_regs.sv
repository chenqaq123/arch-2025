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
    input u1 exception,
    input u1 isEcall,
    input u1 isInstrMisalign,
    input u1 isMRET,
    input u64 pc,
    output u64 next_pc,
    
    // mcycle自增
    input logic mcycle_inc,
    
    // DifftestCSRState接口
    output mstatus_t mstatus_out,
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
    output satp_t satp_out,
    output u2 priviledgeMode_out
);

    // CSR寄存器定义
    u64 mtvec, mip, mie, mscratch;
    u64 mcause, mtval, mepc, mcycle;
    u64 mhartid;
    mstatus_t mstatus;
    satp_t satp;
    u2 priviledgeMode;

    u64 mtvec_nxt, mip_nxt, mie_nxt, mscratch_nxt;
    u64 mcause_nxt, mtval_nxt, mepc_nxt, mcycle_nxt;
    mstatus_t mstatus_nxt;
    satp_t satp_nxt;
    u2 priviledgeMode_nxt;

    // mhartid固定为0
    assign mhartid = '0;
    assign mhartid_out = {56'b0, mhartid[7:0]};

    // sstatus是mstatus的部分位
    assign sstatus_out = mstatus_nxt & SSTATUS_MASK;

    always_comb begin
        if (reset) begin
            mstatus_nxt = '0;
            mtvec_nxt = '0;
            mip_nxt = '0;
            mie_nxt = '0;
            mscratch_nxt = '0;
            mcause_nxt = '0;
            mtval_nxt = '0;
            mepc_nxt = '0;
            satp_nxt = '0;
            priviledgeMode_nxt = PRIV_M;
        end else if (isEcall) begin
            mepc_nxt = pc;
            mcause_nxt = MCAUSE_ECALL_U;
            mstatus_nxt.mpie = mstatus.mie;
            mstatus_nxt.mie = 0;
            mstatus_nxt.mpp = priviledgeMode;
            priviledgeMode_nxt = PRIV_M;
        end else if (isInstrMisalign) begin
            // TODO 
            mepc_nxt = pc;
            mcause_nxt = MCAUSE_INSTRUCTION_ADDRESS_MISALIGNED;
            mstatus_nxt.mpie = mstatus.mie;
            mstatus_nxt.mie = 0;
            mstatus_nxt.mpp = priviledgeMode;
            priviledgeMode_nxt = PRIV_M;
        end else if (isMRET) begin
            mstatus_nxt.mie = mstatus.mpie;
            mstatus_nxt.mpie = 1;
            priviledgeMode_nxt = mstatus.mpp;
            mstatus_nxt.mpp = 0;
            mstatus_nxt.xs = 0;
        end else if (csr_we & isCSRRC) begin
            unique case (csr_addr_write)
                CSR_MSTATUS: mstatus_nxt = (mstatus & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F & MSTATUS_MASK);
                CSR_MTVEC: mtvec_nxt = (mtvec & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F & MTVEC_MASK);
                CSR_MIP: mip_nxt = (mip & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F & MIP_MASK);
                CSR_MIE: mie_nxt = (mie & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MSCRATCH: mscratch_nxt = (mscratch & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MCAUSE: mcause_nxt = (mcause & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MTVAL: mtval_nxt = (mtval & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_MEPC: mepc_nxt = (mepc & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                CSR_SATP: satp_nxt = (satp & 64'hFFFFFFFFFFFFFFE0) | (csr_wdata & 64'h1F);
                default: ; // do nothing
            endcase
        end else if (csr_we) begin
            unique case (csr_addr_write)
                CSR_MSTATUS: mstatus_nxt = csr_wdata & MSTATUS_MASK;
                CSR_MTVEC: mtvec_nxt = csr_wdata & MTVEC_MASK;
                CSR_MIP: mip_nxt = csr_wdata & MIP_MASK;
                CSR_MIE: mie_nxt = csr_wdata;
                CSR_MSCRATCH: mscratch_nxt = csr_wdata;
                CSR_MCAUSE: mcause_nxt = csr_wdata;
                CSR_MTVAL: mtval_nxt = csr_wdata;
                CSR_MEPC: mepc_nxt = csr_wdata;
                CSR_SATP: satp_nxt = csr_wdata;
                default: ; // do nothing
            endcase
        end
    end

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
            priviledgeMode <= PRIV_M;
        end else begin
            mstatus <= mstatus_nxt;
            mtvec <= mtvec_nxt;
            mip <= mip_nxt;
            mie <= mie_nxt;
            mscratch <= mscratch_nxt;
            mcause <= mcause_nxt;
            mtval <= mtval_nxt;
            mepc <= mepc_nxt;
            satp <= satp_nxt;
            priviledgeMode <= priviledgeMode_nxt;
        end
    end

    // TODO  mcycle计数器逻辑
    always_ff @(posedge clk) begin
        if (reset) begin
            mcycle <= '0;
        end else if (csr_we && csr_addr_write == CSR_MCYCLE) begin
            mcycle <= csr_wdata;
        end else if (mcycle_inc) begin
            mcycle <= mcycle + 1;
        end
    end

    always_comb begin
        if (reset) begin
            next_pc = 0;
        end else if (isMRET) begin
            next_pc = mepc_nxt;
        end else if (exception) begin
            next_pc = mtvec_nxt;
        end else begin
            next_pc = 0;
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
    assign mstatus_out = mstatus_nxt;
    assign mtvec_out = mtvec_nxt;
    assign mepc_out = mepc_nxt;
    assign mcause_out = mcause_nxt;
    assign mip_out = mip_nxt;
    assign mie_out = mie_nxt;
    assign mscratch_out = mscratch_nxt;
    assign mcycle_out = mcycle_nxt;
    assign mtval_out = mtval_nxt;
    assign satp_out = satp_nxt;
    assign priviledgeMode_out = priviledgeMode_nxt;

endmodule

`endif