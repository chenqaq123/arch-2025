`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"

`include "src/pipeline/fetch/fetch.sv"
`include "src/pipeline/fetch/IF_ID_reg.sv"
`include "src/pipeline/fetch/pc_mux.sv"
`include "src/pipeline/fetch/pc.sv"

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

`include "src/pipeline/writeback/wb_mux.sv"

`include "src/pipeline/regfile/regfile.sv"
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
	logic stallM;
	logic valid;
	logic if_id_write;

	// IF阶段
	u1 stallpc, flush;
	u64 pcplus4, pc_nxt, IF_pc;
	u32 raw_instr;
	logic pc_write;

	assign pcplus4 = IF_pc + 4;

	pc_mux pc_mux(
		.pcplus4,
		.pc_nxt
	);

	assign stallpc = ireq.valid && ~iresp.data_ok;
	assign if_id_write = ~stallpc & ~stallM;
	assign pc_write = ~stallpc & ~stallM;
	assign valid = if_id_write;

	pc pc(
		.clk, .reset,
		.pc_write,
		.pc_nxt,
		.pc(IF_pc)
	);

	assign ireq.valid = 1'b1;
	assign ireq.addr = IF_pc;
	assign raw_instr = iresp.data;

	fetch fetch(
		.pc(IF_pc),
		.raw_instr(raw_instr),
		.valid,
		.dataF_nxt(dataF_nxt)
	);

	if_id_reg if_id_reg(
		.clk, .reset,
		.stallpc,
		.stallM,
		.if_id_write,
		.dataF_nxt,
		.dataF
	);

	// ID阶段
	control_t ctl;
	creg_addr_t ra1, ra2;
	u64 rd1, rd2;
	u64 imm_64;

	assign ra1 = dataF.raw_instr[19:15];
	assign ra2 = dataF.raw_instr[24:20];

	decoder decoder(
		.raw_instr(dataF.raw_instr),
		.ctl(ctl)
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

	imm_gen imm_gen(
		.raw_instr(dataF.raw_instr),
		.immGenType(ctl.immGenType),
		.imm_64
	);

	decode decode (
		.clk, .reset,
		.dataF,
		.ctl,

		.rd1,
		.rd2,
		.imm_64,

		.dataD_nxt(dataD_nxt)
	);

	id_ex_reg id_ex_reg(
		.clk, .reset,
		.stall(stallM),
		.dataD_nxt,
		.dataD
	);

	// EX阶段
	u64 alu_out;
	u64 ope2;

	rd2_imm_mux rd2_imm_mux(
		.rd2_from_register(dataD.srcb),
		.imm_64(dataD.imm_64),
		.ALUSRC(dataD.ctl.alusrc),
		.rd2(ope2)
	);

	alu alu(
		.rd1(dataD.srca),
		.rd2(ope2),
		.ALUOP(dataD.ctl.alufunc),
		.ALU_out(alu_out)
	);

	execute execute(
		.dataD,
		.alu_out,
		.dataE_nxt(dataE_nxt)
	);

	ex_mem_reg ex_mem_reg(
		.clk, .reset,
		.stall(stallM),
		.dataE_nxt,
		.dataE
	);

	// MEM阶段
	memory memory(
		.dataE,
		.dreq(dreq),
		.stallM(stallM),
		.dresp(dresp),
		.dataM_nxt(dataM_nxt)
	);

	mem_wb_reg mem_wb_reg(
		.clk, .reset,
		.dataM_nxt,
		.dataM
	);

	// WB阶段
	wb_mux wb_mux(
		.ALU_out(dataM.alu_out),
		.wd(write_data)
	);




`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (dataM.valid),
		.pc                 (dataM.pc),
		.instr              (dataM.raw_instr),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataM.ctl.regwrite),
		.wdest              ({3'b0, dataM.dst}),
		.wdata              (write_data)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
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
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0 /* mstatus & 64'h800000030001e000 */),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif