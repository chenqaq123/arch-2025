`ifndef __CBUSARBITER_SV
`define __CBUSARBITER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "mmu/mmu.sv"
`else

`endif
/**
 * this implementation is not efficient, since
 * it adds one cycle lantency to all requests.
 */

module CBusArbiter
	import common::*;#(
    parameter int NUM_INPUTS = 2,  // NOTE: NUM_INPUTS >= 1

    localparam int MAX_INDEX = NUM_INPUTS - 1
) (
    input logic clk, reset,

    input  cbus_req_t  [MAX_INDEX:0] ireqs,
    output cbus_resp_t [MAX_INDEX:0] iresps,
    output cbus_req_t  oreq,
    input  cbus_resp_t oresp,

    input u44 satp_ppn,
    input u4 satp_mode,
    input u2 priviledgeMode
);
    logic busy;
    int index, select;
    cbus_req_t saved_req, selected_req;
    logic mmu_resp_valid;
    logic mmu_stall;
    u64 translated_addr;
    
    typedef enum logic [2:0] {
        S_IDLE,         
        S_MMU_TRANS,    
        S_MMU_MEM_REQ,  
        S_MEM_REQ,      
        S_DONE          
    } state_t;
    
    state_t state, next_state;
    
    mmu mmu(
        .clk(clk),
        .reset(reset),
        
        .req_valid(state == S_IDLE && selected_req.valid),
        .req_vaddr(selected_req.addr),
        
        .resp_valid(mmu_resp_valid),
        .resp_paddr(translated_addr),
        
        .satp_mode(satp_mode), 
        .satp_ppn(satp_ppn), 
        .priviledgeMode(priviledgeMode), 
        
        .creq(mmu_creq),
        .cresp(mmu_cresp)
    );
    
    // 内存请求多路复用
    cbus_req_t mmu_creq;
    cbus_resp_t mmu_cresp;
    
    // 输出请求多路复用
    always_comb begin
        if (state == S_MMU_MEM_REQ) begin
            // MMU页表访问请求
            oreq = mmu_creq;
        end else if (state == S_MEM_REQ) begin
            // 正常内存请求（使用转换后的地址）
            oreq = ireqs[index];
            oreq.addr = translated_addr;
        end else begin
            oreq = '0;
        end
    end
    
    // 响应多路复用
    always_comb begin
        mmu_cresp = '0;
        iresps = '0;
        
        if (state == S_MMU_MEM_REQ) begin
            mmu_cresp = oresp;
        end else if (state == S_MEM_REQ) begin
            for (int i = 0; i < NUM_INPUTS; i++) begin
                if (index == i)
                    iresps[i] = oresp;
            end
        end
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            busy <= 1'b0;
        end else begin
            state <= next_state;
            
            case (state)
                S_IDLE: begin
                    if (selected_req.valid) begin
                        index <= select;
                        busy <= 1'b1;
                    end
                end
                
                S_DONE: begin
                    busy <= 1'b0;
                end

                default: begin
                    // do nothing
                end
            endcase
        end
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            S_IDLE: begin
                if (selected_req.valid)
                    next_state = S_MMU_TRANS;
            end
            
            S_MMU_TRANS: begin
                if (mmu_resp_valid)
                    next_state = S_MEM_REQ;
                else if (mmu_creq.valid)
                    next_state = S_MMU_MEM_REQ;
            end
            
            S_MMU_MEM_REQ: begin
                if (oresp.last)
                    next_state = S_MMU_TRANS;
            end
            
            S_MEM_REQ: begin
                if (oresp.last)
                    next_state = S_DONE;
            end
            
            S_DONE: begin
                next_state = S_IDLE;
            end

            default: begin
                // do nothing
            end
        endcase
    end
    
    always_comb begin
        select = 0;
        
        for (int i = 0; i < NUM_INPUTS; i++) begin
            if (ireqs[i].valid) begin
                select = i;
                break;
            end
        end
    end

    assign selected_req = ireqs[select];
    
    `UNUSED_OK({saved_req});
endmodule



`endif