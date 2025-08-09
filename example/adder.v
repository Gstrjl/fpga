module adder (
    input [3:0] a,  // 4 位输入 a
    input [3:0] b,  // 4 位输入 b
    output [4:0] sum // 5 位输出 sum（包含进位）
);
    // reg 类型不需要在这里声明，使用 wire 会更合适

    assign sum = a + b; // 用 assign 来进行加法计算

endmodule
