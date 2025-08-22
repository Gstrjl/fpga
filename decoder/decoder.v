module decoder(
    input wire [31:0] instruction,

    //extract
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,

    //control sig
    output wire we, //for reg file
    output wire [2:0] alu_op,

    
);

    //R type
    
    wire [6:0] opcode;
    wire [4:0] rd_local;
    wire [2:0] funct3;
    wire [4:0] rs1_local;
    wire [4:0] rs2_local;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd_local = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1_local = instruction[19:15];
    assign rs2_local = instruction[24:20];
    assign funct7 = instruction[31:25];
    // wire [6:0] opcode     = instruction[6:0];
    // wire [4:0] rd_local   = instruction[11:7];
    // wire [2:0] funct3     = instruction[14:12];
    // wire [4:0] rs1_local  = instruction[19:15];
    // wire [4:0] rs2_local  = instruction[24:20];
    // wire [6:0] funct7     = instruction[31:25];

    // recognize add instruction
    // for ADD:opcode=0110011, funct3=000, funct7=0000000 
    
    wire is_add;
    assign is_add = (opcode == 7'b0110011) && 
                    (funct3 == 3'b000) && 
                    (funct7 == 7'b0000000);

    //connect local to global
    assign rs1 = rs1_local;
    assign rs2 = rs2_local;
    assign rd = rd_local;

    //signal gen
    assign we = is_add;
    assign alu_op = is_add ? 3'b000 : 3b'111;

endmodule