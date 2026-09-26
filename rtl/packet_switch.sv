module packet_switch #(parameter PORTS=4, WIDTH=32) (
 input logic clk, rst_n,
 input logic [PORTS-1:0] in_valid, input logic [PORTS-1:0][WIDTH-1:0] in_data, input logic [PORTS-1:0][$clog2(PORTS)-1:0] in_dst, output logic [PORTS-1:0] in_ready,
 output logic [PORTS-1:0] out_valid, output logic [PORTS-1:0][WIDTH-1:0] out_data, input logic [PORTS-1:0] out_ready);
 integer i,j; logic [PORTS-1:0] grant;
 always_comb begin
   in_ready='0; out_valid='0; out_data='0; grant='0;
   for (j=0;j<PORTS;j++) begin
     for (i=0;i<PORTS;i++) begin
       if (!grant[j] && in_valid[i] && in_dst[i]==j[$clog2(PORTS)-1:0]) begin
         out_valid[j]=1'b1; out_data[j]=in_data[i]; in_ready[i]=out_ready[j]; grant[j]=1'b1;
       end
     end
   end
 end
endmodule
