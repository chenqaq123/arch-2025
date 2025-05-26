`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pc_mux 
    import common::*;
    import pipes::*;(

    input u64 pcplus4,
    input u64 pc_add_imm, 
    input u64 pc_jalr,
    input PCSelectType pcSelect,
    output u64 pc_nxt,
    
    input u1 CSR_flush,
    input u64 csr_pc_plus_4,
    input u1 isEcall,
    input u1 isMRET,
    input u64 csr_next_pc
);

    always_comb begin
        if (isEcall==1 | isMRET==1) begin
            pc_nxt = csr_next_pc;
        end else if (CSR_flush == 1) begin
            pc_nxt = csr_pc_plus_4;
        end else begin
            unique case (pcSelect)
                NoNewPC: begin
                    pc_nxt = pcplus4;
                end
                PC_From_add4: begin
                    pc_nxt = pcplus4;
                end    
                PC_From_add_imm: begin
                    pc_nxt = pc_add_imm;
                end
                PC_From_jalr: begin
                    pc_nxt = pc_jalr;
                end
                default: begin
                    pc_nxt = pcplus4;
                end
            endcase
        end
    end



endmodule


`endif

