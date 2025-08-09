`timescale 10ns/10ps

module top;
    reg clk , rst_n , en ;
    wire [3:0] count;


counter dut(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .count(count)
);

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    en = 0;
    rst_n = 1;
    @(posedge clk);
    en = 1;
    rst_n = 0;
    @(posedge clk);
    en = 1;
    rst_n = 1;
    #500;
    $display("end of simulation");
    $finish;

end

initial begin
    $dumpfile("top_tb.vcd");   // 生成一个名为 top_tb.vcd 的波形文件
    $dumpvars(0, top);         // 记录 top 模块的所有信号
end

initial begin
    $monitor("Time = %0t, count = %d", $time, count);
end

endmodule