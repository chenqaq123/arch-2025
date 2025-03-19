`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */

parameter opcode_I = 7'b0010011;
	parameter F3_addi = 3'b000;
	parameter F3_xori = 3'b100;
	parameter F3_ori = 3'b110;
	parameter F3_andi = 3'b111;

parameter opcode_R = 7'b0110011;
	parameter F3_add_OR_sub = 3'b000;
		parameter F7_add = 7'b0000000;
		parameter F7_sub = 7'b0100000;
	parameter F3_xor = 3'b100;
	parameter F3_or = 3'b110;
	parameter F3_and = 3'b111;

parameter opcode_I_IW = 7'b0011011;
	parameter F3_addiw = 3'b000;

parameter opcode_R_W = 7'b0111011;
	parameter F3_addw_OR_subw = 3'b000;
		parameter F7_addw = 7'b0000000;
		parameter F7_subw = 7'b0100000;

// load指令
parameter opcode_I_load = 7'b0000011;
	parameter F3_lb = 3'b000;
	parameter F3_lh = 3'b001;
	parameter F3_lw = 3'b010;
	parameter F3_ld = 3'b011;
	parameter F3_lbu = 3'b100;
	parameter F3_lhu = 3'b101;
	parameter F3_lwu = 3'b110;

// store指令
parameter opcode_S = 7'b0100011;
	parameter F3_sb = 3'b000;
	parameter F3_sh = 3'b001;
	parameter F3_sw = 3'b010;
	parameter F3_sd = 3'b011;

// lui指令
parameter opcode_U_lui = 7'b0110111;

/* Define pipeline structures here */

typedef enum logic [2:0] {
	NoSrc, FromImm, FromReg
} ALUSRCType;

typedef enum logic [2:0] {
	NoGen, Gen_1, Gen_2, Gen_3, Gen_4, Gen_5 
} ImmGenType;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	logic valid;
} fetch_data_t;

// typedef enum logic [5:0] { 
// 	UNKNOWN,
// 	ADDI, XORI, ORI, ANDI,
// 	ADD, SUB, XOR, OR, AND,
// 	ADDW, SUBW,
// 	ADDIW
// } decode_op_t; 

typedef enum logic [4:0] {
	ALU_UNKNOWN,
	ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, 
	ALU_ADDW, ALU_SUBW,
	ALU_ADDIW,
	ALU_LINK
} alufunc_t;

// 访存大小
typedef enum logic [2:0] {
	MSize_zero, MSize_8bits, MSize_16bits, MSize_32bits, MSize_64bits
} MemSizeType;

//write back的数据截断、拓展的类型，WB_7_sext代表先截断再拓展
typedef enum logic [3:0] {
	WBNoHandle, WB_7, WB_15, WB_31, WB_63, WB_7_sext, WB_15_sext, WB_31_sext
} WBType;

typedef struct packed {
	// decode_op_t op;
	// ID阶段
	ALUSRCType alusrc;
	ImmGenType immGenType;
	// Mem阶段
	u1 MemRead;
	u1 MemWrite;
	MemSizeType MemSize;
	// EX阶段
	alufunc_t alufunc;
	// WB阶段
	u1 regwrite;
	u1 MemToReg;
	WBType wbType;
} control_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	word_t srca, srcb;
	control_t ctl;
	creg_addr_t dst; 
	u64 imm_64;
	logic valid;
} decode_data_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	control_t ctl;
	creg_addr_t dst;
	u64 alu_out; 
	logic valid;
} execute_data_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	control_t ctl;
	creg_addr_t dst;
	u64 alu_out;
	logic valid;
} memory_data_t;


endpackage

`endif

