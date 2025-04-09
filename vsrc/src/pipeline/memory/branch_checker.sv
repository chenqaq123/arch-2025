`ifndef __BRANCH_CHECKER_SV
`define __BRANCH_CHECKER_SV

`ifdef VERILATOR
`include "src/include/common.sv"
`include "src/include/pipes.sv"
`else

`endif

module branch_checker
    import common::*;
    import pipes::*;(
    input u64 rd1, rd2,
    input u64 imm_64,
    input BranchType branchType,
    output branch_data_t branch_ctl
);
    always_comb begin
        u1 shouldBranch;
        u1 unEqual;

        branch_ctl.flush = '0;
        branch_ctl.pcSelect = PC_From_add4;

        unique case (branchType) 
            NoBranch: begin
                shouldBranch = '0;
            end
            Branch_eq: begin:
                unEqual = '0;
                for (int i = 0; i < 64; i++) begin
                    unEqual = unEqual | (rd1[i] ^ rd2[i]);
                end
                shouldBranch = ~unEqual;
                branch_ctl.pcSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_eq: begin:
                unEqual = '0;
                for (int i = 0; i < 64; i++) begin
                    unEqual = unEqual | (rd1[i] ^ rd2[i]);
                end
                shouldBranch = unEqual;
                branch_ctl.pcSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_less_s: begin
                shouldBranch = $signed(rd1) < $signed(rd2);
                branch_ctl.PCSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_less_u: begin
                shouldBranch = rd1 < rd2;
                branch_ctl.PCSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_ge_s: begin
                shouldBranch = ~($signed(rd1) < $signed(rd2));
                branch_ctl.PCSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_ge_u: begin
                shouldBranch = ~(rd1 < rd2);
                branch_ctl.PCSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_jal: begin
                shouldBranch = '1;
                branch_ctl.PCSelect = shouldBranch ? PC_From_add_imm : PC_From_add4;
            end
            Branch_jalr: begin
                shouldBranch = '1;
                branch_ctl.PCSelect = PC_From_jalr;
            end
            default: begin
                shouldBranch = '0;
            end
        endcase
        branch_ctl.flush = shouldBranch;
    end
endmodule

`endif