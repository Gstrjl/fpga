`timescale 10ns/1ns;
module top;

reg clk, rst_n;
reg d_ip, en_ip;
wire q_op;

d_flop flop_u (
   .clk(clk),
   .rst_n(rst_n),
   .d_ip(d_ip),
   .en_ip(en_ip),
   .q_op(q_op)
);

always #2 clk = ~clk;


initial begin // NON SYTNHESIZABLE LOGIC
   rst_n = 1;
   d_ip = 0;
   en_ip = 0;
   clk = 0;
   @(posedge clk);
   rst_n = 1'b0;
   @(posedge clk);
   @(posedge clk);
   rst_n = 1'b1;
   d_ip = 1'b1;
   @(posedge clk);
   en_ip = 1'b1;
   // block is out of reset!
   @(posedge clk);
   en_ip = 1'b0;
   d_ip = 1'b0;

   #50;
   $display("End of simulation!");
   $finish;

end

initial begin
   $dumpfile("example_tb.vcd");
   $dumpvars(0,top);
end

endmodule
