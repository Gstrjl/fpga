module reg_file(
    input wire clk,
    input wire rst_n,

    //rs1 read1
    input wire [4:0] read_addr1, //32 5bits
    output wire [31:0] read_data1,

    //rs2 read2
    input wire [4:0] read_addr2,
    output wire [31;0] read_data1,

    //rd write
    input wire we,
    input wire [4:0] read_addr,
    input wire [31:0] write _data

);

    reg [31:0] registers [0:31];//1.32bits 2.32 regs

    //ini to 0
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        //write
        end else begin 
            if (we && write_addr != 5'b0) begin
                registers[write_addr] <= write_data;
            end
        end
    end

    //read 
    //condition ? value_if_true : value_if_false;
    assign read_data1 = (read_addr1 == 5'b0) ? 32'b0 :registers[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? 32'b0 : registers[read_addr2];
endmodule