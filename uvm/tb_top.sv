`timescale 1ns/1ps
import uvm_pkg::*; `include "uvm_macros.svh"
`include "switch_if.sv" `include "switch_item.sv" `include "switch_sequence.sv" `include "switch_driver.sv" `include "switch_monitor.sv" `include "switch_scoreboard.sv" `include "switch_coverage.sv" `include "switch_env.sv" `include "switch_test.sv"
module tb_top;
  logic clk=0;
  always #5 clk=~clk;

  switch_if sif(clk);

  packet_switch dut(
    .clk(clk),.rst_n(sif.rst_n),
    .in_valid(sif.in_valid),.in_data(sif.in_data),.in_dst(sif.in_dst),.in_ready(sif.in_ready),
    .out_valid(sif.out_valid),.out_data(sif.out_data),.out_ready(sif.out_ready)
  );

  packet_switch_sva assertions(
    .clk(clk),.rst_n(sif.rst_n),
    .in_valid(sif.in_valid),.in_ready(sif.in_ready),
    .out_valid(sif.out_valid),.out_ready(sif.out_ready)
  );

  initial begin
    sif.rst_n=0;
    sif.out_ready='1;
    repeat(5) @(posedge clk);
    sif.rst_n=1;
    uvm_config_db#(virtual switch_if)::set(null,"*","vif",sif);
    run_test();
  end
endmodule
