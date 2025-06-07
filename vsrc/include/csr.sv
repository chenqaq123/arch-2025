`ifndef CSR_SV
`define CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package csr_pkg;
  import common::*;

  parameter u12 CSR_MHARTID = 12'hf14;
  parameter u12 CSR_MIE = 12'h304;
  parameter u12 CSR_MIP = 12'h344;
  parameter u12 CSR_MTVEC = 12'h305;
  parameter u12 CSR_MSTATUS = 12'h300;
  parameter u12 CSR_MSCRATCH = 12'h340;
  parameter u12 CSR_MEPC = 12'h341;
  parameter u12 CSR_SATP = 12'h180;
  parameter u12 CSR_MCAUSE = 12'h342;
  parameter u12 CSR_MCYCLE = 12'hb00;
  parameter u12 CSR_MTVAL = 12'h343;
  parameter u12 CSR_PMPADDR0 = 12'h3b0;
  parameter u12 CSR_PMPCFG0 = 12'h3a0;
  parameter u12 CSR_MEDELEG = 12'h302;
  parameter u12 CSR_MIDELEG = 12'h303;
  parameter u12 CSR_STVEC = 12'h105;
  parameter u12 CSR_SSTATUS = 12'h100;
  parameter u12 CSR_SSCRATCH = 12'h140;
  parameter u12 CSR_SEPC = 12'h141;
  parameter u12 CSR_SCAUSE = 12'h142;
  parameter u12 CSR_STVAL = 12'h143;
  parameter u12 CSR_SIE = 12'h104;
  parameter u12 CSR_SIP = 12'h144;

  parameter u64 MSTATUS_MASK = 64'h7e79bb;
  parameter u64 SSTATUS_MASK = 64'h800000030001e000;
  parameter u64 MIP_MASK = 64'h333;
  parameter u64 MTVEC_MASK = ~(64'h2);
  parameter u64 MEDELEG_MASK = 64'h0;
  parameter u64 MIDELEG_MASK = 64'h0;

  typedef struct packed {
    u1 sd;
    logic [MXLEN-2-36:0] wpri1;
    u2 sxl;
    u2 uxl;
    u9 wpri2;
    u1 tsr;
    u1 tw;
    u1 tvm;
    u1 mxr;
    u1 sum;
    u1 mprv;
    u2 xs;
    u2 fs;
    u2 mpp;
    u2 wpri3;
    u1 spp;
    u1 mpie;
    u1 wpri4;
    u1 spie;
    u1 upie;
    u1 mie;
    u1 wpri5;
    u1 sie;
    u1 uie;
  } mstatus_t;

  typedef struct packed {
    u4  mode;
    u16 asid;
    u44 ppn;
  } satp_t;

  // Exception cause codes
  parameter u64 MCAUSE_INSTRUCTION_ADDRESS_MISALIGNED = 64'h0;
  parameter u64 MCAUSE_INSTRUCTION_ACCESS_FAULT = 64'h1;
  parameter u64 MCAUSE_ILLEGAL_INSTRUCTION = 64'h2;
  parameter u64 MCAUSE_BREAKPOINT = 64'h3;
  parameter u64 MCAUSE_LOAD_ADDRESS_MISALIGNED = 64'h4;
  parameter u64 MCAUSE_LOAD_ACCESS_FAULT = 64'h5;
  parameter u64 MCAUSE_STORE_AMO_ADDRESS_MISALIGNED = 64'h6;
  parameter u64 MCAUSE_STORE_AMO_ACCESS_FAULT = 64'h7;
  parameter u64 MCAUSE_ECALL_U  = 64'h8;
  parameter u64 MCAUSE_ECALL_S  = 64'h9;
  parameter u64 MCAUSE_ECALL_M  = 64'hb;
  parameter u64 MCAUSE_INSTRUCTION_PAGE_FAULT = 64'hc;
  parameter u64 MCAUSE_LOAD_PAGE_FAULT = 64'hd;
  parameter u64 MCAUSE_INTERRUPT_MASK = 64'h8000000000000000;

  // Interrupt cause codes
  parameter u64 MCAUSE_SOFTWARE_INTERRUPT = 64'h3;
  parameter u64 MCAUSE_TIMER_INTERRUPT = 64'h7;
  parameter u64 MCAUSE_EXTERNAL_INTERRUPT = 64'hb;

  // Interrupt mie position
  parameter u6 MSIP = 3;
  parameter u6 MTIP = 7;
  parameter u6 MEIP = 11;

  parameter u2 PRIV_U = 2'b00;
  parameter u2 PRIV_M = 2'b11;

endpackage

`endif
