// toggle
//module top(
//    input wire clk,
//    input wire rst_n,
//    output wire [3:0] led
//);
//    assign led = 4'b1111;
//    localparam W = 24;
//    reg [W-1:0] clock_counter;
//    
//    wire pulse;
//    assign pulse = clock_counter[W-1]; //toggle

//    always @ (posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            clock_counter <= 0;
//        end
//        else begin
//            clock_counter <= clock_counter + 1;
//        end
//    end

//    assign led = pulse ? 4'b1111 : 4'b0000;
//endmodule

//1. 0 lighted
//2. rt_n 

// connect to counter
module top(
    input wire clk,
    input wire rst_n,
    output wire [3:0] led
);
//    reg [3:0] ledlocal;
    wire [3:0] count;
    wire c_en;

//.底层（顶层）
    counter counterlocal(
        .clk(clk),
        .en(c_en),
        .rst_n(rst_n),
//        .count(count)
//        .led(ledlocal)
        .led(led)
    );



    assign c_en = 1;

//    assign led = ledlocal;

//    assign led = count;
endmodule
        