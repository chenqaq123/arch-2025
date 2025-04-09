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
    output u64 pc_nxt
    
);

    always_comb begin
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



endmodule


`endif

