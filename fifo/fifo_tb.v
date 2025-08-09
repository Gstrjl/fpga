`timescale 1ns / 1ps

module fifo_tb;

    // FIFO 参数
    parameter DW = 8;       // 数据宽度
    parameter DEPTH = 4;    // FIFO 深度

    // 输入信号
    reg clk;               
    reg rst_n;              
    reg wen;                
    reg ren;                
    reg [DW-1:0] data_in;  

    // 输出信号
    wire [DW-1:0] data_out;  
    wire empty;               
    wire full;                

    // 实例化 FIFO 模块
    fifo #(DW, DEPTH) dut (
        .clk(clk),          
        .rst_n(rst_n),      
        .wen(wen),          
        .ren(ren),          
        .data_in(data_in),  
        .data_out(data_out), 
        .empty(empty),      
        .full(full)          
    );

    // 时钟生成 (100 MHz)
    always begin
        #5 clk = ~clk;
    end

    // 写任务：封装写入操作和状态检查
    task write_task;
        input [DW-1:0] data;
        begin
            @(negedge clk) #1;   // 时钟下降沿后驱动信号
            wen = 1;
            data_in = data;
            @(posedge clk);      // 等待写入完成
            #1;
            wen = 0;
        end
    endtask

    // 读验证任务：封装读取操作和输出校验
    task read_verify;
        input [DW-1:0] expected;
        begin
            @(negedge clk) #1;
            ren = 1;
            @(posedge clk);     // 等待数据有效
            #1;
            if (data_out !== expected) begin
                $error("Read mismatch! Expected: %h, Got: %h at time %t", 
                       expected, data_out, $time);
            end
            ren = 0;
        end
    endtask

    // 主要测试序列
    initial begin
        // 初始化信号
        clk = 0;
        rst_n = 0;
        wen = 0;
        ren = 0;
        data_in = 8'b0;

        // 1. 测试复位状态
        #10;
        rst_n = 1;   // 释放复位
        #10;
        
        // 复位后应处于空状态
        if (!empty) $error("FIFO should be empty after reset at time %t", $time);
        if (full) $error("FIFO should not be full after reset at time %t", $time);
        
        // 2. 基础写入测试
        write_task(8'h01);
        write_task(8'h02);
        write_task(8'h03);
        write_task(8'h04);
        
        // 写入4个数据后应满
        if (!full) $error("FIFO should be full after 4 writes at time %t", $time);
        
        // 3. 满状态写入测试（应忽略）
        @(negedge clk) #1;
        wen = 1;
        data_in = 8'hFF;   // 无效写入尝试
        @(posedge clk) #1;
        wen = 0;
        if (data_out === 8'hFF) $error("Full write should be ignored!");
        
        // 4. 基础读取测试
        read_verify(8'h01);
        read_verify(8'h02);
        read_verify(8'h03);
        read_verify(8'h04);
        
        // 读空后应处于空状态
        if (!empty) $error("FIFO should be empty after reading all data at time %t", $time);
        
        // 5. 空状态读取测试（应忽略）
        @(negedge clk) #1;
        ren = 1;
        @(posedge clk) #1;
        ren = 0;
        if (data_out !== 8'hxx) $error("Empty read should output undefined!");
        
        // 6. 交替读写测试
        write_task(8'hAA);
        read_verify(8'hAA);
        write_task(8'hBB);
        read_verify(8'hBB);
        
        // 7. 同时读写测试
        fork
            begin
                write_task(8'h11);
                write_task(8'h22);
            end
            begin
                #15; // 延迟启动读取
                read_verify(8'h11);
                read_verify(8'h22);
            end
        join
        
        // 8. 边界情况：同时读写空FIFO
        @(negedge clk) #1;
        wen = 1;
        ren = 1;
        data_in = 8'hCC;
        @(posedge clk);
        #1;
        wen = 0;
        ren = 0;
        read_verify(8'hCC); // 验证写入的数据
        
        // 9. 边界情况：同时读写满FIFO
        // 先填充FIFO
        write_task(8'hF1);
        write_task(8'hF2);
        write_task(8'hF3);
        write_task(8'hF4);
        
        @(negedge clk) #1;
        wen = 1;
        ren = 1;
        data_in = 8'hDD;  // 应覆盖最早的数据
        @(posedge clk);
        #1;
        wen = 0;
        ren = 0;
        read_verify(8'hF2); // 第一个数据已被覆盖
        read_verify(8'hF3);
        read_verify(8'hF4);
        read_verify(8'hDD); // 新写入的数据
        
        // 10. 混合操作压力测试
        repeat(20) begin
            @(negedge clk) #1;
            wen = $random;
            ren = $random;
            data_in = $random;
        end
        wen = 0;
        ren = 0;
        
        // 清空FIFO
        while (!empty) begin
            @(negedge clk) #1;
            ren = 1;
            @(posedge clk) #1;
            ren = 0;
        end
        
        // 完成测试
        #100;
        $display("All tests completed successfully!");
        $finish;
    end

    // 波形记录
    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);
    end

    // 监控输出
    initial begin
        $monitor("Time %t: wr=%b rd=%b din=%h dout=%h empty=%b full=%b", 
                 $time, wen, ren, data_in, data_out, empty, full);
    end
    
endmodule















// `timescale 1ns / 1ps //how to choose timescale

// module fifo_tb;

//     // FIFO 参数
//     parameter DW = 8;       // 数据宽度
//     parameter DEPTH = 4;    // FIFO 深度

//     // 输入信号
//     reg clk;               
//     reg rst_n;              
//     reg wen;                
//     reg ren;                
//     reg [DW-1:0] data_in;  

//     // 输出信号
//     wire [DW-1:0] data_out;  
//     wire empty;               
//     wire full;                

//     // 实例化（FIFO 模块）
//     fifo #(DW, DEPTH) dut (
//         .clk(clk),          
//         .rst_n(rst_n),      
//         .wen(wen),          
//         .ren(ren),          
//         .data_in(data_in),  
//         .data_out(data_out), 
//         .empty(empty),      
//         .full(full)          
//     );

//     // 时钟生成
//     always begin
//         #5 clk = ~clk;  // 100 MHz
//     end

//     // 测试刺激过程
// /*    initial begin
//         // 初始化信号
//         clk = 0;
//         rst_n = 0;
//         wen = 0;
//         ren = 0;
//         data_in = 8'b0;

//         // 复位
//         #10;
//         rst_n = 1;
        
//         // 写入数据
//         #10;
//         wen = 1; data_in = 8'b00000001;  // 写入 1
//         #10;
//         wen = 0;

//         #10;
//         wen = 1; data_in = 8'b00000010;  // 写入 2
//         #10;
//         wen = 0;

//         #10;
//         wen = 1; data_in = 8'b00000011;  // 写入 3
//         #10;
//         wen = 0;

//         #10;
//         wen = 1; data_in = 8'b00000100;  // 写入 4
//         #10;
//         wen = 0;

//         // 读数据
//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;

//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;

//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;

//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;

//         // 完成测试
//         #10;
//         $finish;
//     end
// */
//     initial begin
//         // 初始化信号
//         clk = 0;
//         rst_n = 0;
//         wen = 0;
//         ren = 0;
//         data_in = 8'b0;

//         // 复位
//         #10;
//         rst_n = 1;  // 激活复位信号

//         // 写入数据
//         #10;
//         wen = 1; data_in = 8'b00000001;  // 写入 1
//         #10;
//         wen = 0;  // 结束写入

//         #10;
//         wen = 1; data_in = 8'b00000010;  // 写入 2
//         #10;
//         wen = 0;  // 结束写入

//         #10;
//         wen = 1; data_in = 8'b00000011;  // 写入 3
//         #10;
//         wen = 0;  // 结束写入

//         #10;
//         wen = 1; data_in = 8'b00000100;  // 写入 4
//         #10;
//         wen = 0;  // 结束写入

//         // 读取数据
//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;  // 结束读

//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;  // 结束读

//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;  // 结束读

//         #10;
//         ren = 1;  // 读数据
//         #10;
//         ren = 0;  // 结束读

//         // 完成测试
//         #10;
//         $finish;
//     end

//     initial begin
//         $dumpfile("fifo_tb.vcd");   // 生成一个名为 fifo_tb.vcd 的波形文件
//         $dumpvars(0, fifo_tb);      // 记录 fifo_tb 模块的所有信号
//     end

//     // 观察输出
//     initial begin
//         $monitor("At time %t, data_in = %h, data_out = %h, empty = %b, full = %b", 
//                  $time, data_in, data_out, empty, full);
//     end
    
// endmodule


// //seperate read and write, read write happens in the same clk cycle
