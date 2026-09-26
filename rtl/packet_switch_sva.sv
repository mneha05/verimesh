module packet_switch_sva #(parameter PORTS=4, WIDTH=32)(input logic clk,rst_n,input logic [PORTS-1:0] in_valid,input logic [PORTS-1:0] in_ready,input logic [PORTS-1:0] out_valid,input logic [PORTS-1:0] out_ready);
 genvar p; generate for(p=0;p<PORTS;p++) begin
   property hold_valid; @(posedge clk) disable iff(!rst_n) out_valid[p] && !out_ready[p] |=> out_valid[p]; endproperty
   assert property(hold_valid) else $error("out_valid dropped under backpressure port %0d",p);
 end endgenerate
endmodule
