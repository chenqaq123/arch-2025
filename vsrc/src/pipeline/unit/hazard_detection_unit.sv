`ifndef __HAZARD_DETECTION_UNIT_SV
`define __HAZARD_DETECTION_UNIT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module hazard_detection_unit 
    import common::*;
    import pipes::*;(
    // 寄存器使用类型，表示当前指令如何使用源寄存器
    input reg_use_type regUseType,      // NO_RS1_RS2, ONLY_RS1, BOTH_RS1_RS2

    // load指令检测相关信号
    input logic ID_EX_MemRead,          // ID/EX阶段的指令是否为load指令
    input creg_addr_t ID_EX_rw,         // ID/EX阶段的目标寄存器地址
    input creg_addr_t ID_rs1,           // ID阶段指令的源寄存器1地址
    input creg_addr_t ID_rs2,           // ID阶段指令的源寄存器2地址

    // 输出的冒险控制信号
    output hazard_control_t hazard_ctl   // 包含PCWrite, IF_ID_Write, stall_control_sign
);
    always_comb begin
        if(ID_EX_MemRead && regUseType != NO_RS1_RS2) begin
            if (regUseType==ONLY_RS1 && ID_EX_rw == ID_rs1) begin
                hazard_ctl.stall_control_sign = 1;  // 控制信号置为零
                hazard_ctl.PCWrite = 0;             // 禁止PC寄存器写入
                hazard_ctl.IF_ID_Write = 0;         // 禁止IF/ID寄存器写入
            end else if (regUseType==BOTH_RS1_RS2 && (ID_EX_rw == ID_rs1 || ID_EX_rw == ID_rs2)) begin
                hazard_ctl.stall_control_sign = 1;  // 控制信号置为零
                hazard_ctl.PCWrite = 0;             // 禁止PC寄存器写入
                hazard_ctl.IF_ID_Write = 0;         // 禁止IF/ID寄存器写入
            end else begin
                //不需要stall
                hazard_ctl.stall_control_sign = 0;
                hazard_ctl.PCWrite = 1;
                hazard_ctl.IF_ID_Write = 1;
            end
        end else begin
            // 不需要stall
            hazard_ctl.stall_control_sign = 0;
            hazard_ctl.PCWrite = 1;
            hazard_ctl.IF_ID_Write = 1;  
        end
    end
endmodule

`endif