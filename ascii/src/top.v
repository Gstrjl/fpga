module uart_ascii_top(
    input wire clk,
    input wire rst_n,
    input wire rx,
    output wire tx,
    output wire [5:0] led  // Tang Nano 9K 有6个LED
);
    wire baud_tick;
    wire [7:0] rx_data;
    wire rx_done;
    wire [23:0] ascii_dec;  // 修改为24位输出
    wire tx_done;
    
    reg [1:0] tx_state = 0;  // 增加发送状态机
    reg [7:0] tx_char;       // 当前发送的字符
    reg tx_start;            // 发送启动信号
    reg [5:0] led_reg = 6'b000000;  // LED寄存器，6位
    
    // Tang Nano 9K的LED是共阳极，需要低电平点亮
    assign led = ~led_reg;  // 取反输出
    
    baud_gen baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tick(baud_tick)
    );
    
    uart_rx rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .s_tick(baud_tick),
        .rx_done_tick(rx_done),
        .dout(rx_data)
    );
    
    // ASCII处理器模块实例化
    ascii_processor proc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .char_in(rx_data),
        .rx_done(rx_done),
        .ascii_dec(ascii_dec)  // 修改为24位输出
    );
    
    uart_tx tx_inst (
        .clk(clk),
        .reset(~rst_n),
        .tx_start(tx_start),    // 改为状态机控制
        .s_tick(baud_tick),
        .din(tx_char),          // 改为当前发送字符
        .tx_done_tick(tx_done),
        .tx(tx)
    );
    
    // LED更新逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_reg <= 6'b000000;  // 复位时全灭
        end else if (rx_done) begin
            led_reg <= rx_data[5:0];  // 只显示低6位
        end
    end
    
    // 新增状态机：分3次发送ASCII十进制值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state <= 0;
            tx_start <= 0;
            tx_char <= 0;
        end else begin
            case (tx_state)
                0: begin // 等待新数据
                    if (rx_done) begin
                        tx_char <= ascii_dec[23:16]; // 百位ASCII
                        tx_start <= 1;
                        tx_state <= 1;
                    end
                end
                1: begin // 发送百位
                    tx_start <= 0;
                    if (tx_done) begin
                        tx_char <= ascii_dec[15:8];  // 十位ASCII
                        tx_start <= 1;
                        tx_state <= 2;
                    end
                end
                2: begin // 发送十位
                    tx_start <= 0;
                    if (tx_done) begin
                        tx_char <= ascii_dec[7:0];   // 个位ASCII
                        tx_start <= 1;
                        tx_state <= 3;
                    end
                end
                3: begin // 发送个位
                    tx_start <= 0;
                    if (tx_done) begin
                        tx_state <= 0; // 完成，回到初始状态
                    end
                end
            endcase
        end
    end
endmodule