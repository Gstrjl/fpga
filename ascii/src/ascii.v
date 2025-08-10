module ascii_processor(
    input wire clk,
    input wire rst_n,
    input wire [7:0] char_in,  // 8位二进制输入(0-255)
    input wire rx_done,
    output wire [23:0] ascii_dec  // 24位十进制ASCII输出 - 改为wire
);

    // 内部寄存器用于存储输出值
    reg [23:0] ascii_dec_reg;
    
    // 定义中间寄存器变量（移至always块外部）
    reg [7:0] hundreds;
    reg [7:0] tens;
    reg [7:0] units;
    reg [7:0] remainder;

    // 将内部寄存器连接到输出线
    assign ascii_dec = ascii_dec_reg;

    // 二进制转十进制转换逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ascii_dec_reg <= 24'd0;
        end else if (rx_done) begin
            // 计算百位(0-2)
            if (char_in >= 200)
                hundreds <= 2;
            else if (char_in >= 100)
                hundreds <= 1;
            else
                hundreds <= 0;
            
            // 计算剩余值(0-99)
            remainder = char_in - (hundreds * 100);
            
            // 计算十位和个位(0-9)
            tens <= remainder / 10;
            units <= remainder % 10;
            
            // 转换为ASCII（数字0-9的ASCII码=48+数值）
            ascii_dec_reg <= {8'd48 + hundreds, 8'd48 + tens, 8'd48 + units};
        end
    end
endmodule