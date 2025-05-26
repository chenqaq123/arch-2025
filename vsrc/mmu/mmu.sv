`ifndef MMU_SV
`define MMU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "include/csr.sv"
`endif

module mmu 
    import common::*;
    import pipes::*;
    import csr_pkg::*;#(
    parameter LEVELS       = 3
) (
    input  logic                 clk,
    input  logic                 reset,
    // request from pipeline
    input  logic                 req_valid,
    input  logic        [63:0]   req_vaddr,
    // response to pipeline
    output logic                 resp_valid,
    output logic        [63:0]   resp_paddr,
    // CSR interface: satp
    input  u44          satp_ppn,
    input  u4           satp_mode,
    input  u2           priviledgeMode,
    // memory bus
    output cbus_req_t     creq,
    input  cbus_resp_t    cresp
);

    typedef enum logic [2:0] {
        S_IDLE,
        S_REQ,
        S_WAIT,
        S_CHECK,
        S_DONE
    } state_t;

    state_t state, next_state;

    u64 vaddr_r;

    logic req_ready;

    u9 vpn  [LEVELS-1:0];
    u12 page_offset;
    assign page_offset = vaddr_r[11:0];
    u2 lvl, next_lvl;

    u44 base_ppn, next_base_ppn;
    u54 pte, next_pte;
    cbus_req_t next_creq;

    assign req_ready = (state == S_IDLE);
    assign resp_valid = (state == S_DONE);

    always_ff @(posedge clk) begin
        if (req_ready && req_valid) begin
            vaddr_r <= req_vaddr;
            vpn[2] <= req_vaddr[38:30]; 
            vpn[1] <= req_vaddr[29:21]; 
            vpn[0] <= req_vaddr[20:12]; 
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            base_ppn <= '0;
            pte <= '0;
            creq <= '0;
            lvl   <= '0;
        end else begin
            state <= next_state;
            base_ppn <= next_base_ppn;
            pte <= next_pte;
            creq <= next_creq;
            lvl <= next_lvl;
            if (state == S_IDLE)
                lvl <= LEVELS-1;
        end
    end

    always_comb begin
        if  (satp_mode == 4'b0000 | priviledgeMode == 3) begin
            resp_paddr = req_vaddr;
        end else begin
            resp_paddr = { {8{1'b0}}, pte[53:10], page_offset };
        end
    end

    always_comb begin
        next_state = state;
        next_base_ppn = base_ppn;
        next_pte = pte;
        next_creq = creq;
        next_lvl = lvl;
        case (state)
            S_IDLE: begin
                if (req_valid) begin
                    if (satp_mode == 4'b0000 | priviledgeMode == 3) begin
                        // bare mode: bypass
                        next_state = S_DONE;
                    end else begin
                        next_base_ppn = satp_ppn;
                        next_state = S_REQ;
                    end
                end
            end

            S_REQ: begin
                // 发起请求
                next_creq.valid    = 1'b1;
                next_creq.addr     = { 8'b0, base_ppn, vpn[lvl], 3'b0 };
                // next_creq.addr     = 64'h000000008000E010;
                next_creq.size     = MSIZE8; 
                next_creq.is_write = 0;
                next_creq.len      =  MLEN1;
	            next_creq.burst = AXI_BURST_FIXED;
                next_state = S_WAIT;
            end

            S_WAIT: begin
                if (cresp.last) begin
                    next_pte = cresp.data[53:0];
                    next_state = S_CHECK;
                    next_creq = 0;
                end
            end

            S_CHECK: begin
                next_base_ppn = next_pte[53:10];
                if (pte[3:1] == 3'b000 & lvl > 0) begin
                    next_state = S_REQ;
                end else begin
                    next_state = S_DONE;
                end
                next_lvl = lvl - 1;
            end

            S_DONE: begin
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

endmodule

`endif
