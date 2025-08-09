module ascii_processor(
    input clk,
    input rst_n,
    input [7:0] char_in,  // 8位二进制输入(0-255)
    input rx_done,
    output reg [23:0] ascii_dec  // 24位十进制ASCII输出
);

    // 定义中间寄存器变量（移至always块外部）
    reg [7:0] hundreds;
    reg [7:0] tens;
    reg [7:0] units;
    reg [7:0] remainder;

    // 二进制转十进制转换逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ascii_dec <= 24'd0;
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
            ascii_dec <= {8'd48 + hundreds, 8'd48 + tens, 8'd48 + units};
        end
    end
endmodule


//module ascii_processor(
//    input clk,
//    input rst_n,
//    input [7:0] char_in,
//    input rx_done,
//    output reg [15:0] ascii_hex
//);
//    function [7:0] bin2ascii;
//        input [3:0] bin;
//        case(bin)
//            4'h0: bin2ascii = "0";
//            4'h1: bin2ascii = "1";
//            4'h2: bin2ascii = "2";
//            4'h3: bin2ascii = "3";
//            4'h4: bin2ascii = "4";
//            4'h5: bin2ascii = "5";
//            4'h6: bin2ascii = "6";
//            4'h7: bin2ascii = "7";
//            4'h8: bin2ascii = "8";
//            4'h9: bin2ascii = "9";
//            4'hA: bin2ascii = "A";
//            4'hB: bin2ascii = "B";
//            4'hC: bin2ascii = "C";
//            4'hD: bin2ascii = "D";
//            4'hE: bin2ascii = "E";
//            4'hF: bin2ascii = "F";
//        endcase
//    endfunction

//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            ascii_hex <= 0;
//        end else if (rx_done) begin
//            ascii_hex[15:8] <= bin2ascii(char_in[7:4]);
//            ascii_hex[7:0] <= bin2ascii(char_in[3:0]);
//        end
//    end
//endmodule