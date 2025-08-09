//module counter (
//    input wire clk,
//    input wire rst_n,
//    input wire en,
//    output wire [3:0] count
//);
//    
//    reg [3:0] countlocal;
//    assign count = countlocal;

//    always @(posedge clk or negedge rst_n ) begin
//        if (!rst_n) begin
//            countlocal <= 0;
//        end
//        else  begin
//            if (en) begin
//                countlocal <= countlocal + 1 ;
//            end
//        end
//    end

//endmodule

/*
module counter(
    input wire clk,       
    input wire rst_n,     
    input wire en,        
    output reg [3:0] led 
);

    localparam W = 24;            // 计数器宽度
    reg [W-1:0] clock_counter;   // 用于分频的计数器

    // 控制流水灯效果
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  // 复位时计数器清零
            led <= 4'b0000;       // 所有 LED 熄灭
        end else if (en) begin
            clock_counter <= clock_counter + 1;  // 计数器递增
            // 当 clock_counter 的 MSB（最高位）发生变化时，更新 LED 状态
            if (clock_counter[W-1] == 1) begin
                // 这里可以使用位移或其他操作来控制 LED 的逐个点亮
                led <= {led[2:0], led[3]};  // 将 LED 向左移动，形成流水灯效果
            end
        end
    end

endmodule


module counter(
    input wire clk,       // 时钟信号
    input wire rst_n,     // 复位信号
    input wire en,        // 使能信号
    output reg [3:0] led // LED 输出
);

    localparam W = 24;            // 计数器宽度
    reg [W-1:0] clock_counter;   // 用于分频的计数器
    reg [1:0] led_counter;       // 用于控制流水灯变化的计数器

//     控制流水灯效果
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  // 复位时计数器清零
            led <= 4'b0001;       // 初始化第一个 LED 点亮
            led_counter <= 0;     // 初始化 LED 计数器
        end else if (en) begin
            clock_counter <= clock_counter + 1;  // 计数器递增

//             每 4 次 clock_counter 变化后，更新 led_counter
            if (clock_counter[W-1:0] == 0) begin
                led_counter <= led_counter + 1;  // 每次更新时 LED 向左移动
            end

//             控制 LED 位移效果
            case (led_counter)
                2'b00: led <= 4'b0001;  // 第 1 位亮
                2'b01: led <= 4'b0010;  // 第 2 位亮
                2'b10: led <= 4'b0100;  // 第 3 位亮
                2'b11: led <= 4'b1000;  // 第 4 位亮
                default: led <= 4'b0001; // 默认第 1 位亮
            endcase
        end
    end

endmodule


module counter(
    input wire clk,           
    input wire rst_n,         
    input wire en,            
    output reg [3:0] led      
);

    
    reg [3:0] counter_value;  

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_value <= 0;  // 复位时计数器清零
            led <= 4'b0000;       // 所有 LED 熄灭
        end else if (en) begin
            counter_value <= counter_value + 1;  // 计数器递增           
        end
    end


endmodule
*/

module counter(
    input wire clk,       
    input wire rst_n,     
    input wire en,        
    output reg [3:0] led 
);

    localparam W = 24;  
    reg [W-1:0] clock_counter;  

    //problem while using wire toggle

    reg toggle;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  // maybe use for loop
            led <= 4'b0000; 
            toggle <= 0;
        end 
        else 
        if (en) begin
            clock_counter <= clock_counter + 1;
            toggle <= clock_counter[W-1];  
            if (toggle) begin
                led <= ~clock_counter[W-1:W-5];  // 显示最高的 4 位
            end
        end
    end
   

endmodule


