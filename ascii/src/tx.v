module uart_tx 
#( 
    parameter DBIT = 8,           // 数据位宽
    parameter SB_TICK = 16        // 停止位的时钟周期数
)(
    input wire clk,               // 时钟信号
    input wire reset,             // 复位信号
    input wire tx_start,          // 发送启动信号
    input wire s_tick,            // 时钟周期计数器
    input wire [7:0] din,         // 输入数据（待发送的字节）
    output reg tx_done_tick,      // 数据发送完成标志
    output wire tx                // 串口数据输出
);

    // 状态定义
    localparam IDLE  = 2'b00, 
               START = 2'b01, 
               DATA  = 2'b10, 
               STOP  = 2'b11;

    // 信号声明
    reg [1:0] state_reg, state_next;     // 当前状态和下一个状态
    reg [3:0] s_reg, s_next;             // 状态计数器，用于计时
    reg [2:0] n_reg, n_next;             // 数据位计数器
    reg [7:0] b_reg, b_next;             // 数据寄存器
    reg tx_reg, tx_next;                 // 串口输出寄存器（发送数据）

    // 状态和数据寄存器的更新
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;  // 默认空闲时 tx 为高电平
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    // 状态机的下一个状态逻辑与功能单元
    always @(*) begin
        state_next = state_reg;
        tx_done_tick = 0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg; // 默认值

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1; // 空闲时，tx 为高电平
                if (tx_start) begin
                    state_next = START;
                    s_next = 0;
                    b_next = din; // 将输入数据加载到 b_reg 中
                end
            end

            START: begin
                tx_next = 1'b0; // 发送起始位（低电平）
                if (s_tick) begin
                    if (s_reg == 15) begin
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0]; // 发送数据位
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1; // 数据右移，发送下一个数据位
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
                tx_next = 1'b1; // 发送停止位（高电平）
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next = IDLE;
                        tx_done_tick = 1'b1; // 数据发送完成标志
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            default: begin
                state_next = IDLE;
            end
        endcase
    end

    // 输出 tx 信号
    assign tx = tx_reg;

endmodule
