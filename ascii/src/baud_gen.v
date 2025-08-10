module baud_gen #(
    parameter CLK_FREQ = 27_000_000,  // Tang Nano 9K 使用27MHz时钟
    parameter BAUD_RATE = 19200     // 常用波特率，您也可以改为19200
)(
    input wire clk,
    input wire rst_n,
    output wire tick  // 改为wire
);
    localparam DIVISOR = CLK_FREQ / (BAUD_RATE * 16);
    
    // 内部寄存器
    reg tick_reg;
    reg [15:0] counter;
    
    // 将内部寄存器连接到输出线
    assign tick = tick_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            tick_reg <= 0;
        end else if (counter == DIVISOR - 1) begin
            counter <= 0;
            tick_reg <= 1;
        end else begin
            counter <= counter + 1;
            tick_reg <= 0;
        end
    end
endmodule