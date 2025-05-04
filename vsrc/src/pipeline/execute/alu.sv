`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input u64 rd1, rd2,
	input alufunc_t ALUOP,
	output u64 ALU_out
);
	u64 result;
	u32 result_32;
	always_comb begin
		result_32 = '0;
		result = '0;  // 添加默认值
		ALU_out = '0;
		unique case(ALUOP)
            // ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, 
			ALU_ADD: begin
				ALU_out = rd1 + rd2;
			end
            ALU_SUB: begin
				ALU_out = rd1 - rd2;
			end
            ALU_AND: begin
				ALU_out = rd1 & rd2;
			end
            ALU_OR: begin
				ALU_out = rd1 | rd2;
			end
			ALU_XOR: begin
				ALU_out = rd1 ^ rd2;
			end
			// ALU_S_LESS, ALU_U_LESS
			ALU_S_LESS: begin
				ALU_out = { {63{1'b0}}, {$signed(rd1) < $signed(rd2)}};
			end
			ALU_U_LESS: begin
				ALU_out = { {63{1'b0}}, {rd1 < rd2}};
			end
			// ALU_L_SL, ALU_L_SR, ALU_A_SR
			ALU_L_SL: begin
				ALU_out = rd1 << rd2[5:0];
			end
			ALU_L_SR: begin
				ALU_out = rd1 >> rd2[5:0]; //逻辑右移
			end
			ALU_A_SR: begin
				ALU_out = ($signed(rd1)) >>> rd2[5:0]; //算术右移
			end
            // ALU_ADDW, ALU_SUBW, ALU_L_SLW, ALU_L_SRW, ALU_A_SRW
			ALU_ADDW: begin
				result = rd1 + rd2;
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			ALU_SUBW: begin
				result = rd1 - rd2;
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			ALU_L_SLW: begin //sllw
				result_32 = rd1[31:0] << rd2[4:0];
				ALU_out = {{32{result_32[31]}}, result_32[31:0]};
			end
			ALU_L_SRW: begin //srlw
				result_32 = rd1[31:0] >> rd2[4:0];
				ALU_out = {{32{result_32[31]}}, result_32[31:0]};
			end
			ALU_A_SRW: begin //sraw
				result_32 = ($signed(rd1[31:0])) >>> rd2[4:0];
				ALU_out = {{32{result_32[31]}}, result_32[31:0]};
			end
			// ALU_ADDIW, ALU_L_SLIW, ALU_L_SRIW, ALU_A_SRIW
			ALU_ADDIW: begin 
				result = rd1 + rd2;
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			ALU_L_SLIW: begin
				result = rd1 << rd2[5:0];
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			ALU_L_SRIW: begin //srliw
				result_32 = rd1[31:0] >> rd2[5:0];
				ALU_out = {{32{result_32[31]}}, result_32[31:0]};
			end
			ALU_A_SRIW: begin //sraiw 先截断再右移
				result_32 = ($signed(rd1[31:0])) >>> rd2[5:0];
				ALU_out = {{32{result_32[31]}}, result_32[31:0]};
			end
			// ALU_B
			ALU_B: begin
				ALU_out = '0;
			end
			// ALU_LINK
			ALU_LINK: begin
				ALU_out = rd2;
			end
			ALU_RS1_ADD_0: begin
				ALU_out = rd1;
			end
			default: begin
				ALU_out = '0;
			end
		endcase
	end
	
endmodule

`endif
