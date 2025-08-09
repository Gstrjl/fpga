// 1.memory 2.enable 3.read pointer 4. write pointer 5. full flag 6.empty flag

// function 
//     1.read 2.write 3.indicates empty/full
// module fifo #(DW = 8, DEPTH = 4)(
//     input wire clk,
//     input wire rst_n,
//     input wire ren,
//     input wire wen,
//     input wire [DW-1:0] data_in,
//     output wire [DW-1:0] data_out,
//     output wire empty,
//     output wire full
// );
//     reg [DW-1:0] fifo_mem; 
//     reg [DW-1:0] data_outlcl;
//     reg fulllcl;
//     reg emptylcl;
//     assign empty = emptylcl;
//     assign full = fulllcl;
//     assign data_out = data_outlcl

// endmodule
module fifo #(parameter DW = 8, DEPTH = 4)(
    input wire clk,                    
    input wire rst_n,                   
    input wire ren,                     
    input wire wen,                    
    input wire [DW-1:0] data_in,        
    output wire [DW-1:0] data_out,      
    output wire empty,                  
    output wire full                    
);
    // FIFO 存储单元数组，大小为 DEPTH，宽度为 DW 位
    reg [DW-1:0] fifo_mem [DEPTH-1:0];  
    
    // 临时寄存器
    reg [DW-1:0] data_outlcl;
    reg emptylcl, fulllcl;
    
    // 写指针和读指针
    reg [$clog2(DEPTH):0] write_ptr, read_ptr; // write--next available address        read--
    //problem: repeated full and empty
    
    // 信号赋值
    assign empty = emptylcl;
    assign full = fulllcl;
    assign data_out = data_outlcl;
    
    // 读写
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0 ; i < DEPTH ; i ++ ) begin
                fifo_mem[i] = {DW{1'b0}};
            end
            data_outlcl <= 0;
            fulllcl <= 0;
            emptylcl <= 1;
        end
        else begin
            // write
            if (wen && !fulllcl) begin
                fifo_mem[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
            end
            //read
            if (ren && !emptylcl) begin
                data_outlcl <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
            end
            //empty/full
            if (write_ptr == read_ptr) begin 
                emptylcl <= 1;
            end
            //how to judge full, read write ptr are independent (write=4 read=2)
            if (read_ptr - 1 == write_ptr) begin
                fulllcl <= 1;
        end
    end
    end
endmodule
