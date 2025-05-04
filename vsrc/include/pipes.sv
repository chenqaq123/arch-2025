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
	
	// 条件置位
	parameter F3_slti = 3'b010;
	parameter F3_sltiu = 3'b011;

	// 移位 
	parameter F3_slli = 3'b001;
	parameter F3_srli_OR_srai = 3'b101;
		parameter F7_srli = 7'b0000000;
		parameter F7_srai = 7'b0100000;

parameter opcode_R = 7'b0110011;
	parameter F3_add_OR_sub = 3'b000;
		parameter F7_add = 7'b0000000;
		parameter F7_sub = 7'b0100000;
	parameter F3_xor = 3'b100;
	parameter F3_or = 3'b110;
	parameter F3_and = 3'b111;

	parameter F3_sll = 3'b001;
	parameter F3_slt = 3'b010;
	parameter F3_sltu = 3'b011;

	parameter F3_srl_OR_sra = 3'b101;
		parameter F7_srl = 7'b0000000;
		parameter F7_sra = 7'b0100000;

parameter opcode_I_IW = 7'b0011011;
	parameter F3_addiw = 3'b000;

	parameter F3_slliw = 3'b001;
	parameter F3_srliw_OR_sraiw = 3'b101;
		parameter F7_srliw = 7'b0000000;
		parameter F7_sraiw = 7'b0100000;

parameter opcode_R_W = 7'b0111011;
	parameter F3_addw_OR_subw = 3'b000;
		parameter F7_addw = 7'b0000000;
		parameter F7_subw = 7'b0100000;

	parameter F3_sllw = 3'b001;
	parameter F3_srlw_OR_sraw = 3'b101;
		parameter F7_srlw = 7'b0000000;
		parameter F7_sraw = 7'b0100000;

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

parameter opcode_U_auipc = 7'b0010111;

//J类型 无条件跳转并链接
parameter opcode_J_jalr = 7'b1100111;
parameter opcode_J_jal = 7'b1101111;

// B类型 条件跳转指令
parameter opcode_B = 7'b1100011;
	parameter F3_beq = 3'b000;
	parameter F3_bne = 3'b001;
	parameter F3_blt = 3'b100;
	parameter F3_bge = 3'b101;
	parameter F3_bltu = 3'b110;
	parameter F3_bgeu = 3'b111;

parameter opcode_I_CSR = 7'b1110011;
	parameter F3_csrrw = 3'b001;
	parameter F3_csrrs = 3'b010;
	parameter F3_csrrc = 3'b011;
	parameter F3_csrrwi = 3'b101;
	parameter F3_csrrsi = 3'b110;
	parameter F3_csrrci = 3'b111;

/* Define pipeline structures here */

typedef enum logic [2:0] {
	NoSrc, FromImm, FromShamt, FromReg, FromPcAddImm, FromPcAdd4, FromCSR
} ALUSRCType;

typedef enum logic [2:0] {
	NoGen, Gen_1, Gen_2, Gen_3, Gen_4, Gen_5, Gen_CSR
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
	ALU_S_LESS, ALU_U_LESS,
	ALU_L_SL, ALU_L_SR, ALU_A_SR,
	ALU_ADDW, ALU_SUBW, ALU_L_SLW, ALU_L_SRW, ALU_A_SRW,
	ALU_ADDIW, ALU_L_SLIW, ALU_L_SRIW, ALU_A_SRIW,
	ALU_B,
	ALU_LINK,
	ALU_RS1_ADD_0,
	ALU_CSRRC
} alufunc_t;

// 访存大小
typedef enum logic [2:0] {
	MSize_zero, MSize_8bits, MSize_16bits, MSize_32bits, MSize_64bits
} MemSizeType;

//write back的数据截断、拓展的类型，WB_7_sext代表先截断再拓展
typedef enum logic [3:0] {
	WBNoHandle, WB_7, WB_15, WB_31, WB_63, WB_7_sext, WB_15_sext, WB_31_sext
} WBType;

//分支指令类型
typedef enum logic [3:0] {
	NoBranch, Branch_eq, Branch_ne, Branch_less_s, Branch_less_u, Branch_ge_s, Branch_ge_u, Branch_jal, Branch_jalr
} BranchType;

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
	BranchType branchType;
	// CSR相关
	u1 ReadCSR;
	u1 WriteCSR;
	u1 isCSR;
	u1 CSR_FROM_zimm;
} control_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	creg_addr_t rs1;
	creg_addr_t rs2;
	word_t srca, srcb;
	control_t ctl;
	creg_addr_t dst; 
	u64 imm_64;
	logic valid;
	csr_addr_t csr;
	u64 csr_rdata;
} decode_data_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	control_t ctl;
	creg_addr_t dst;
	u64 alu_out; 
	logic valid;
	u64 MemWriteData;
	u64 rd1;
	u64 rd2;
	u64 imm_64;
	csr_addr_t csr;
	u64 csr_rdata;
} execute_data_t;

typedef struct packed {
	u64 pc;
	u32 raw_instr;
	control_t ctl;
	creg_addr_t dst;
	u64 alu_out;
	logic valid;
	u64 MemReadData;	// 从memory中读取的数据
	logic skip;
	csr_addr_t csr;
	u64 csr_rdata;
} memory_data_t;

typedef enum logic [1:0] {
	NoNewPC, PC_From_jalr, PC_From_add4, PC_From_add_imm
} PCSelectType;

typedef struct packed {
	logic flush;
	PCSelectType pcSelect;
} branch_data_t;

typedef struct packed {
    logic PCWrite;           // PC是否更新，0表示暂停PC
    logic IF_ID_Write;       // IF/ID流水线寄存器是否写入，0表示插入气泡
    logic stall_control_sign;// 控制信号是否有效，0表示插入NOP指令
} hazard_control_t;

typedef enum logic [1:0] {
    NO_FORWARDING,      // 不需要转发，使用原始数据
    FROM_ID_EX_ID,      // 数据来自ID/EX流水线寄存器或寄存器堆
    FROM_WB,            // 数据来自写回阶段（WB），即前两条指令的结果
    FROM_ALU_OUT        // 数据来自ALU输出，即前一条指令的结果
} forwarding_control;

typedef enum logic [1:0] {
    NO_RS1_RS2,    // 不使用任何源寄存器
    ONLY_RS1,      // 只使用rs1源寄存器
    BOTH_RS1_RS2   // 同时使用rs1和rs2源寄存器
} reg_use_type;

endpackage

`endif

