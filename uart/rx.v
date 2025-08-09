module uart_rx #(
    parameter DBIT = 8,        // 数据位宽
    parameter SB_TICK = 16     // 停止位计数周期
)(
    input wire clk,            // 时钟信号
    input wire rst_n,          // 复位信号
    input wire rx,             // 接收数据线
    input wire s_tick,         // 每个时钟周期的时钟脉冲
    output wire rx_done_tick,   // 数据接收完成标志
    output wire [7:0] dout     // 接收到的数据
);
    reg

    // 定义状态 better using one hot
    localparam IDLE = 2'b00, 
               START = 2'b01, 
               DATA = 2'b10, 
               STOP = 2'b11;

    // 信号声明
    reg [1:0] state_reg, state_next;  // 状态寄存器和下一个状态
    reg [3:0] s_reg, s_next;          // 状态计数器
    reg [2:0] n_reg, n_next;          // 数据位计数器
    reg [7:0] b_reg, b_next;          // 数据寄存器
 always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  
            led <= 4'b0000;       
            toggle <= 0;  // 复位时，toggle 也为 0
        end else if (en) begin
            clock_counter <= clock_counter + 1;  
            toggle <= clock_counter[W-1];  // 计算 toggle 信号
        end
    end

    // 当 toggle 信号为 1 时，更新 led
    always @(posedge clk) begin
        if (toggle) begin
            led <= clock_counter[W-1:W-4];  // 显示最高的 4 位
        end
    end always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  
            led <= 4'b0000;       
            toggle <= 0;  // 复位时，toggle 也为 0
        end else if (en) begin
            clock_counter <= clock_counter + 1;  
            toggle <= clock_counter[W-1];  // 计算 toggle 信号
        end
    end

    // 当 toggle 信号为 1 时，更新 led
    always @(posedge clk) begin
        if (toggle) begin
            led <= clock_counter[W-1:W-4];  // 显示最高的 4 位
        end
    end
    // 时序逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;   always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  
            led <= 4'b0000;       
            toggle <= 0;  // 复位时，toggle 也为 0
        end else if (en) begin
            clock_counter <= clock_counter + 1;  
            toggle <= clock_counter[W-1];  // 计算 toggle 信号
        end
    end

    // 当 toggle 信号为 1 时，更新 led
    always @(posedge clk) begin
        if (toggle) begin
            led <= clock_counter[W-1:W-4];  // 显示最高的 4 位
        end
    end
            led <= 4'b0000;        always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_counter <= 0;  
            led <= 4'b0000;       
            toggle <= 0;  // 复位时，toggle 也为 0
        end else if (en) begin
            clock_counter <= clock_counter + 1;  
            toggle <= clock_counter[W-1];  // 计算 toggle 信号
        end
    end

    // 当 toggle 信号为 1 时，更新 led
    always @(posedge clk) begin
        if (toggle) begin
            led <= clock_counter[W-1:W-4];  // 显示最高的 4 位
        end
    end
            toggle <= 0;  // 复位时，toggle 也为 0
        end else if (en) begin
            clock_counter <= clock_counter + 1;  
            toggle <= clock_counter[W-1];  // 计算 toggle 信号
        end
    end

    // 当 toggle 信号为 1 时，更新 led
    always @(posedge clk) begin
        if (toggle) begin
            led <= clock_counter[W-1:W-4];  // 显示最高的 4 位
        end
    end
            clock_counter <= 0;  
            led <= 4'b0000;       
            toggle <= 0;  // 复位时，toggle 也为 0
        end else if (en) begin
            clock_counter <= clock_counter + 1;  
            toggle <= clock_counter[W-1];  // 计算 toggle 信号
        end
    end

    // 当 toggle 信号为 1 时，更新 led
    always @(posedge clk) begin
        if (toggle) begin
            led <= clock_counter[W-1:W-4];  // 显示最高的 4 位
        end
    end
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end

    // 状态机逻辑
    always @* begin
        state_next = state_reg;
        rx_done_tick = 0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;

        case (state_reg)
            IDLE: begin
                if (!rx) begin  // 如果接收到起始位（低电平）
                    state_next = START;
                    s_next = 0;
                end
            end

            START: begin
                if (s_tick) begin
                    if (s_reg == 7) begin
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {rx, b_reg[7:1]};  // 将接收到的数据移位
                        if (n_reg == (DBIT - 1)) begin
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            STOP: begin
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = IDLE;
                        rx_done_tick = 1;  // 数据接收完成
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

        endcase
    end

    // 输出接收到的数据
    assign dout = b_reg;

endmodule
