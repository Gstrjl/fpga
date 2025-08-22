module alu (
    input wire [31:0] read_data1,          // reg file 1
    input wire [31:0] read_data2,          // reg file 2
    input wire [2:0] alu_op, // decoder
    output wire [31:0] result     
);

    
    reg [31:0] result_local;
    
    
    always @(*) begin
        case (alu_control)
            3'b000: result_local = a + b;   // add
            
            default: result_local = 32'b0;  
        endcase
    end
    
    // connect
    assign result = result_local;

endmodule