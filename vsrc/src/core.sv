`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "src/pipeline/regfile/regfile.sv"
`include "src/pipeline/fetch/fetch.sv"
`include "src/pipeline/fetch/IF_ID_reg.sv"
`include "src/pipeline/fetch/pc_mux.sv"
`include "src/pipeline/fetch/pc.sv"
`include "src/pipeline/decode/decode.sv"
`endif

module core import common::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */

	// IF阶段
	u1 stallpc, flush;
	u64 pcplus4, pc_nxt, IF_pc;
	u64 raw_instr;
	fetch_data_t dataF, dataF_nxt;

	assign pcplus4 = IF_pc + 4;

	pc_mux pc_mux(
		.pcplus4,
		.pc_nxt
	);

	assign stallpc = ireq.valid && ~iresp.data_ok;
	pc pc(
		.clk, .reset,
		.stallpc,
		.pc_nxt,
		.pc(IF_pc)
	);

	assign ireq.valid = 1'b1;
	assign ireq.addr = IF_pc;
	assign raw_instr = iresp.data;

	fetch fetch(
		.clk, .reset,
		.raw_instr(raw_instr),
		.dataF_nxt(dataF_nxt)
	);

	if_id_reg if_id_reg(
		.clk, .reset,
		.dataF_nxt,
		.dataF
	);

	// ID阶段
	control_t ctl;
	decode_data_t dataD, dataD_nxt;
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
		.wvalid(),
		.wa(),
		.wd()
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

		.dataD_nxt(dataD_nxt),
	);

	id_ex_reg id_ex_reg(
		.clk, .reset,
		.dataD_nxt,
		.dataD
	);

	// EX阶段
	execute_data_t dataE, dataE_nxt;
	u64 alu_out;

	execute execute(
		.clk, .reset,
		.dataD,
		.dataE_nxt(dataE_nxt),
		.alu_out(alu_out)
	);

	ex_mem_reg ex_mem_reg(
		.clk, .reset,
		.dataE_nxt,
		.dataE
	);

	// MEM阶段
	memory_data_t dataM, dataM_nxt;













	
	
	regfile regfile(
		.clk, .reset,
		.ra1,
		.ra2,
		.rd1,
		.rd2,
		.wvalid(),
		.wa(),
		.wd()
	);




`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (1'b1),
		.pc                 (PCINIT),
		.instr              (0),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (0),
		.wdest              (0),
		.wdata              (0)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (0),
		.gpr_1              (0),
		.gpr_2              (0),
		.gpr_3              (0),
		.gpr_4              (0),
		.gpr_5              (0),
		.gpr_6              (0),
		.gpr_7              (0),
		.gpr_8              (0),
		.gpr_9              (0),
		.gpr_10             (0),
		.gpr_11             (0),
		.gpr_12             (0),
		.gpr_13             (0),
		.gpr_14             (0),
		.gpr_15             (0),
		.gpr_16             (0),
		.gpr_17             (0),
		.gpr_18             (0),
		.gpr_19             (0),
		.gpr_20             (0),
		.gpr_21             (0),
		.gpr_22             (0),
		.gpr_23             (0),
		.gpr_24             (0),
		.gpr_25             (0),
		.gpr_26             (0),
		.gpr_27             (0),
		.gpr_28             (0),
		.gpr_29             (0),
		.gpr_30             (0),
		.gpr_31             (0)
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
		.sstatus            (0 /* mstatus & SSTATUS_MASK */),
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