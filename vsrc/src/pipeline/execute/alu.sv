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
	always_comb begin
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
            // ALU_ADDW, ALU_SUBW, ALU_ADDIW
			ALU_ADDW: begin
				result = rd1 + rd2;
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			ALU_SUBW: begin
				result = rd1 - rd2;
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			ALU_ADDIW: begin 
				result = rd1 + rd2;
				ALU_out = {{32{result[31]}}, result[31:0]};
			end
			default: begin
				ALU_out = '0;
			end
		endcase
	end
	
endmodule

`endif
