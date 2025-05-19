`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"

`include "src/pipeline/fetch/fetch.sv"
`include "src/pipeline/fetch/IF_ID_reg.sv"
`include "src/pipeline/fetch/pc_mux.sv"
`include "src/pipeline/fetch/pc.sv"

`include "src/pipeline/decode/ctl_mux.sv"
`include "src/pipeline/decode/decode.sv"
`include "src/pipeline/decode/decoder.sv"
`include "src/pipeline/decode/ID_EX_reg.sv"
`include "src/pipeline/decode/imm_gen.sv"

`include "src/pipeline/execute/alu.sv"
`include "src/pipeline/execute/EX_MEM_reg.sv"
`include "src/pipeline/execute/execute.sv"
`include "src/pipeline/execute/rd2_imm_mux.sv"

`include "src/pipeline/memory/mem_wb_reg.sv"
`include "src/pipeline/memory/memory.sv"
`include "src/pipeline/memory/branch_checker.sv"

`include "src/pipeline/writeback/wb_mux.sv"

`include "src/pipeline/regfile/regfile.sv"

`include "src/pipeline/csr/csr_regs.sv"

`include "src/pipeline/unit/forwarding_unit.sv"
`include "src/pipeline/unit/hazard_detection_unit.sv"
`include "src/pipeline/unit/rd_forwarding_mux.sv"
`endif

module core 
	import common::*;
	import pipes::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */
	fetch_data_t dataF, dataF_nxt;
	decode_data_t dataD, dataD_nxt;
	execute_data_t dataE, dataE_nxt;
	memory_data_t dataM, dataM_nxt;
	u64 write_data;
	logic valid;
	logic if_id_write;
	u64 pc_add_imm_mem;
	u64 pc_jalr_mem;
	forwarding_control forwardingA, forwardingB;
	forwarding_control forwardingAA, forwardingBB;

	u64 alu_out;

	// TODO 处理两个结构体
	branch_data_t branch_ctl;
	hazard_control_t hazard_ctl;
	logic stallM, flushM;

	// IF阶段
	u1 stallpc, flush;
	u64 pcplus4, pc_nxt, IF_pc;
	u32 raw_instr;
	logic pc_write;

	assign pcplus4 = IF_pc + 4;

	pc_mux pc_mux(
		.pcplus4,
		.pc_add_imm(pc_add_imm_mem),
		.pc_jalr(pc_jalr_mem),
		.pcSelect(branch_ctl.pcSelect),
		.pc_nxt,
		.CSR_flush(dataD.ctl.isCSR),
        .csr_pc_plus_4(dataD.pc + 4)
	);

	assign stallpc = ireq.valid && ~iresp.data_ok;
	// assign if_id_write = ~stallpc & ~stallM;
	assign valid = hazard_ctl.IF_ID_Write & ~stallM;

	assign pc_write = hazard_ctl.PCWrite & ~stallpc & ~stallM;
	logic pc_store;
	assign pc_store = branch_ctl.flush | dataD.ctl.isCSR;

	pc pc(
		.clk, .reset,
		.pc_write,
		.pc_store,
		.pc_nxt,
		.pc(IF_pc)
	);

	assign ireq.valid = 1'b1;
	assign ireq.addr = IF_pc;
	assign raw_instr = iresp.data_ok ? iresp.data : 0;

	fetch fetch(
		.pc(IF_pc),
		.raw_instr(raw_instr),
		.valid,
		.dataF_nxt(dataF_nxt)
	);

	if_id_reg if_id_reg(
		.clk, .reset,
		.branch_ctl_flush(branch_ctl.flush | dataD.ctl.isCSR),
		.stallpc,
		.stallM,
		.if_id_write(hazard_ctl.IF_ID_Write),
		.dataF_nxt,
		.dataF
	);

	// ID阶段
	control_t ctl_nxt, ctl;
	creg_addr_t ra1, ra2;
	u64 rd1, rd2;
	u64 imm_64;
	reg_use_type regUseType;
	u64 csr_rdata;

	assign ra1 = dataF.raw_instr[19:15];
	assign ra2 = dataF.raw_instr[24:20];

	decoder decoder(
		.raw_instr(dataF.raw_instr),
		.regUseType(regUseType),
		.ctl(ctl_nxt)
	);

	ctl_mux ctl_mux(
		.ctl_nxt(ctl_nxt),
		.stall_control_sign(hazard_ctl.stall_control_sign),
		.ctl(ctl)
	);

	hazard_detection_unit hazard_detection_unit(
		.regUseType(regUseType),      

		// load指令检测相关信号
		.ID_EX_MemRead(dataD.ctl.MemRead),          
		.ID_EX_rw(dataD.dst),         
		.ID_rs1(ra1),           
		.ID_rs2(ra2),           
		// 输出的冒险控制信号
		.hazard_ctl(hazard_ctl)
	);

	regfile regfile(
		.clk, .reset,
		.ra1,
		.ra2,
		.rd1,
		.rd2,
		.wvalid(dataM.ctl.regwrite),
		.wa(dataM.dst),
		.wd(write_data)
	);

	u64 mstatus_out;
    u64 mtvec_out;
    u64 mepc_out;
    u64 mcause_out;
    u64 mip_out;
    u64 mie_out;
    u64 mscratch_out;
    u64 mcycle_out;
    u64 mhartid_out;
    u64 sstatus_out;
	u64 mtval_out;
	u64 satp_out;
	csr_regs csr_regs(
		.clk, .reset,
		.csr_addr_read(dataF.raw_instr[31:20]),
		.csr_addr_write(dataD.raw_instr[31:20]),
		.csr_wdata(alu_out),
		.csr_we(dataD.ctl.isCSR),
		.csr_rdata(csr_rdata),
		.isCSRRC(dataD.ctl.isCSRRC),

		.mcycle_inc(1'b1),

		.mstatus_out,
		.mtvec_out,
		.mepc_out,
		.mcause_out,
		.mip_out,
		.mie_out,
		.mscratch_out,
		.mcycle_out,
		.mhartid_out,
		.sstatus_out,
		.mtval_out,
		.satp_out
	);

	imm_gen imm_gen(
		.raw_instr(dataF.raw_instr),
		.immGenType(ctl.immGenType),
		.imm_64
	);

	decode decode (
		.clk, .reset,
		.dataF,
		.ctl,
		.imm_64,
		.csr_rdata,

		.rd1,
		.rd2,
		.wb_data(write_data),
		.forwardingAA,
		.forwardingBB,
		.stall(hazard_ctl.stall_control_sign),

		.dataD_nxt(dataD_nxt)
	);

	id_ex_reg id_ex_reg(
		.clk, .reset,
		.stall(stallM),
		.flush(branch_ctl.flush),
		.dataD_nxt,
		.dataD
	);

	// EX阶段
	u64 pc_add_4_ex;
	u64 pc_add_imm_ex;
	assign pc_add_4_ex = dataD.pc + 4;
	assign pc_add_imm_ex = dataD.pc + dataD.imm_64;

	forwarding_unit forwarding_unit(
		.EX_MEM_rw(dataE.dst),   // EX/MEM 阶段的写寄存器地址
		.MEM_WB_rw(dataM.dst),   // MEM/WB 阶段的写寄存器地址
		.ID_EX_rs1(dataD.rs1),   // ID/EX 阶段的源寄存器1地址
		.ID_EX_rs2(dataD.rs2),   // ID/EX 阶段的源寄存器2地址
		.ID_rs1(ra1),      // ID 阶段的源寄存器1地址
		.ID_rs2(ra2),      // ID 阶段的源寄存器2地址

		// 控制信号
		.EX_MEM_valid(dataE.valid),      // EX/MEM 阶段指令是否有效
		.MEM_WB_valid(dataM.valid),      // MEM/WB 阶段指令是否有效
		.EX_MEM_RegWrite(dataE.ctl.regwrite),      // EX/MEM 阶段是否写寄存器
		.MEM_WB_RegWrite(dataM.ctl.regwrite),      // MEM/WB 阶段是否写寄存器

		.forwardingA(forwardingA),   // 源操作数1的转发控制
		.forwardingB(forwardingB),   // 源操作数2的转发控制
		.forwardingAA(forwardingAA),  // ID阶段源操作数1的转发控制
		.forwardingBB(forwardingBB)  // ID阶段源操作数2的转发控制
	);

	u64 rd2_from_register;
	u64 EX_rd1, EX_rd2;

	rd_forwarding_mux rd1_forwarding_mux(
		.ID_rd(dataD.srca),
		.WB(write_data),
		.ALU_out(dataE.alu_out),
    	.forwarding(forwardingA),
    	.rd(EX_rd1)
	);

	rd_forwarding_mux rd2_forwarding_mux(
		.ID_rd(dataD.srcb),
		.WB(write_data),
		.ALU_out(dataE.alu_out),
    	.forwarding(forwardingB),
    	.rd(rd2_from_register)
	);

	rd2_imm_mux rd2_imm_mux(
		.rd2_from_register(rd2_from_register),
		.imm_64(dataD.imm_64),
		.pc_add_4(pc_add_4_ex),
		.pc_add_imm(pc_add_imm_ex),
		.shamt(dataD.raw_instr[25:20]),
		.ALUSRC(dataD.ctl.alusrc),
		.csr_rdata(dataD.csr_rdata),
		.rd2(EX_rd2)
	);

	alu alu(
		.rd1(dataD.srca),
		.rd2(EX_rd2),
		.ALUOP(dataD.ctl.alufunc),
		.ALU_out(alu_out)
	);

	execute execute(
		.dataD,
		.alu_out,
		.ope2(EX_rd2),
		.dataE_nxt(dataE_nxt)
	);

	ex_mem_reg ex_mem_reg(
		.clk, .reset,
		.flush(branch_ctl.flush),
		.stall(stallM),
		.dataE_nxt,
		.dataE
	);

	// MEM阶段
	assign pc_add_imm_mem = dataE.pc + dataE.imm_64;
	assign pc_jalr_mem = (dataE.rd1 + dataE.imm_64) & ~1;
	branch_checker branch_checker(
		.rd1(dataE.rd1),
		.rd2(dataE.rd2),
		.imm_64(dataE.imm_64),
		.branchType(dataE.ctl.branchType),
		.branch_ctl(branch_ctl)
	);

	memory memory(
		.dataE,
		.dreq(dreq),
		.stallM(stallM),
		.flushM,
		.dresp(dresp),
		.dataM_nxt(dataM_nxt)
	);

	mem_wb_reg mem_wb_reg(
		.clk, .reset,
		.flushM,
		.dataM_nxt,
		.dataM
	);

	// WB阶段
	wb_mux wb_mux(
		.ALU_out(dataM.alu_out),
		.MemReadData(dataM.MemReadData),
		.MemToReg(dataM.ctl.MemToReg),
		.isCSR(dataM.ctl.isCSR),
		.csr_rdata(dataM.csr_rdata),
		.wd(write_data)
	);




`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (mhartid_out[7:0]),
		.index              (0),
		.valid              (dataM.valid),
		.pc                 (dataM.pc),
		.instr              (dataM.raw_instr),
		.skip               (dataM.skip),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataM.ctl.regwrite),
		.wdest              ({3'b0, dataM.dst}),
		.wdata              (write_data)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (mhartid_out[7:0]),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);

    DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (mhartid_out[7:0]),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (mhartid_out[7:0]),
		.priviledgeMode     (3),
		.mstatus            (mstatus_out),
		.sstatus            (sstatus_out /* mstatus & SSTATUS_MASK */),
		.mepc               (mepc_out),
		.sepc               (0),
		.mtval              (mtval_out),
		.stval              (0),
		.mtvec              (mtvec_out),
		.stvec              (0),
		.mcause             (mcause_out),
		.scause             (0),
		.satp               (satp_out),
		.mip                (mip_out),
		.mie                (mie_out),
		.mscratch           (mscratch_out),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif