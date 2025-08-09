module counter (
    input wire clk,
    input wire rst_n,
    input wire en,
    output wire [3:0] count
);
    
    reg [3:0] countlocal;
    assign count = countlocal;

    always @(posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            countlocal <= 0;
        end
        else  begin
            if (en) begin
                countlocal <= countlocal + 1 ;
            end
        end
    end

endmodule