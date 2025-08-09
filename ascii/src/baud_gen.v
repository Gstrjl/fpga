module baud_gen #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 19_200
)(
    input clk,
    input rst_n,
    output reg tick
);
    localparam DIVISOR = CLK_FREQ / (BAUD_RATE * 16);
    reg [15:0] counter;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            tick <= 0;
        end else if (counter == DIVISOR - 1) begin
            counter <= 0;
            tick <= 1;
        end else begin
            counter <= counter + 1;
            tick <= 0;
        end
    end
endmodule