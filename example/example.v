module d_flop ( // port declarations
   input wire clk,
   input wire rst_n,

   input wire d_ip,
   input wire en_ip,
   output wire q_op
);

reg q;

always @ (posedge clk or negedge rst_n) begin
   if (~rst_n) begin
      q <= 1'b0;
   end else begin
      if (en_ip) begin
         q <= d_ip;
      end
   end
end

assign q_op = q;

endmodule
