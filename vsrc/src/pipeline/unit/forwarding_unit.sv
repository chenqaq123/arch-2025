`ifndef __FORWARDING_UNIT_SV
`define __FORWARDING_UNIT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module forwarding_unit
    import common::*;
    import pipes::*;(
    // 寄存器地址
    input creg_addr_t EX_MEM_rw,   // EX/MEM 阶段的写寄存器地址
    input creg_addr_t MEM_WB_rw,   // MEM/WB 阶段的写寄存器地址
    input creg_addr_t ID_EX_rs1,   // ID/EX 阶段的源寄存器1地址
    input creg_addr_t ID_EX_rs2,   // ID/EX 阶段的源寄存器2地址
    input creg_addr_t ID_rs1,      // ID 阶段的源寄存器1地址
    input creg_addr_t ID_rs2,      // ID 阶段的源寄存器2地址

    // 控制信号
    input logic EX_MEM_valid,      // EX/MEM 阶段指令是否有效
    input logic MEM_WB_valid,      // MEM/WB 阶段指令是否有效
    input u1 EX_MEM_RegWrite,      // EX/MEM 阶段是否写寄存器
    input u1 MEM_WB_RegWrite,      // MEM/WB 阶段是否写寄存器

    output forwarding_control forwardingA,   // 源操作数1的转发控制
    output forwarding_control forwardingB,   // 源操作数2的转发控制
    output forwarding_control forwardingAA,  // ID阶段源操作数1的转发控制
    output forwarding_control forwardingBB  // ID阶段源操作数2的转发控制
);
    logic should_forward_A_with_last_instr, should_forward_B_with_last_instr;
    always_comb begin
        forwardingA = FROM_ID_EX_ID;
        forwardingB = FROM_ID_EX_ID;
        forwardingAA = FROM_ID_EX_ID;
        forwardingBB = FROM_ID_EX_ID;

        if (EX_MEM_RegWrite && EX_MEM_rw != 0 && EX_MEM_valid) begin
            // 从EX_MEM寄存器转发到ID_EX寄存器
            if (EX_MEM_rw == ID_EX_rs1) begin
                forwardingA = FROM_ALU_OUT;
                should_forward_A_with_last_instr = 1;
            end else begin
                should_forward_A_with_last_instr = 0;
            end
            if (EX_MEM_rw == ID_EX_rs2) begin
                forwardingA = FROM_ALU_OUT;
                should_forward_B_with_last_instr = 1;
            end else begin
                should_forward_B_with_last_instr = 0;
            end
        end else begin
            should_forward_A_with_last_instr = 0;
            should_forward_B_with_last_instr = 0;
        end

        if (MEM_WB_RegWrite && EX_MEM_rw != 0) begin
            // 从MEM_WB寄存器转发到ID阶段
            if (MEM_WB_rw == ID_rs1) begin
                forwardingAA = FROM_WB;
            end
            if (MEM_WB_rw == ID_rs2) begin
                forwardingBB = FROM_WB;
            end
            // 从MEM_WB寄存器转发到ID_EX寄存器
            if (MEM_WB_rw == ID_EX_rs1 && should_forward_A_with_last_instr == 0) begin
                forwardingA = FROM_WB;
            end
            if (MEM_WB_rw == ID_EX_rs2 && should_forward_B_with_last_instr == 0) begin
                forwardingB = FROM_WB;
            end
        end
    end
    
endmodule

`endif