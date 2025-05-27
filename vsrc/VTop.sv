`ifndef __VTOP_SV
`define __VTOP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "src/core.sv"
`include "util/IBusToCBus.sv"
`include "util/DBusToCBus.sv"
`include "util/CBusArbiter.sv"

`endif
module VTop 
	import common::*;(
	input logic clk, reset,

	output cbus_req_t  oreq,
	input  cbus_resp_t oresp,
	input logic trint, swint, exint
);

    ibus_req_t  ireq;
    ibus_resp_t iresp;
    dbus_req_t  dreq;
    dbus_resp_t dresp;
    cbus_req_t  icreq,  dcreq;
    cbus_resp_t icresp, dcresp;

    u4 satp_mode;
    u44 satp_ppn;
    u2 priviledgeMode;

    core core(
      .clk(clk), .reset, .ireq, .iresp, .dreq, .dresp, .trint, .swint, .exint, .satp_mode, .satp_ppn, .priviledgeMode
    );
    IBusToCBus icvt(.*);

    DBusToCBus dcvt(.*);

    CBusArbiter mux(
        .clk(clk), .reset,
        .ireqs({icreq, dcreq}),
        .iresps({icresp, dcresp}),
        .oreq,
        .oresp,
        .satp_ppn(satp_ppn),
        .satp_mode(satp_mode),
        .priviledgeMode(priviledgeMode)
    );

	always_ff @(posedge clk) begin
		if (~reset) begin
			// $display("icreq %x, %x", icreq.valid, icreq.addr);
			// if (oreq.valid || dcreq.addr == 64'h40600004) $display("dcreq %x, %x, oreq %x, %x, dcresp %x", dcreq.addr, dcreq.valid, oreq.valid, oreq.addr, dcresp.ready);
		end
	end
	

endmodule



`endif