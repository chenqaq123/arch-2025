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

/* Define pipeline structures here */

typedef enum logic [2:0] {
	NoSrc, FromImm, FromReg
} ALUSRCType;

typedef enum logic [2:0] {
	NoGen, Gen
} ImmGenType;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
} fetch_data_t;

typedef enum logic [5:0] { 
	UNKNOWN,
	ADDI, XORI, ORI, ANDI,
	ADD, SUB, XOR, OR, AND,
	ADDW, SUBW,
	ADDIW
} decode_op_t; 

typedef enum logic [4:0] {
	ALU_UNKNOWN,
	ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, 
	ALU_ADDW, ALU_SUBW,
	ALU_ADDIW
} alufunc_t;

typedef struct packed {
	decode_op_t op;
	alufunc_t alufunc;
	u1 regwrite;
	ALUSRCType alusrc;
	ImmGenType immGenType;
} control_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	word_t srca, srcb;
	control_t ctl;
	creg_addr_t dst; 
	u64 imm_64;
} decode_data_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	control_t ctl;
	creg_addr_t dst;
	u64 alu_out; 
} execute_data_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	control_t ctl;
	creg_addr_t dst;
	u64 alu_out;
} memory_data_t;


endpackage

`endif

