/******************************************************************************
MIT License

Copyright (c) 2020 BH6BAO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

******************************************************************************/

//******    全局宏定义   *******//
`define RstEnable               1'b0            // 复位信号
`define RstDisable              1'b1
`define ZeroWord                32'h00000000    // 32位的数值0
`define WriteEnable             1'b1            
`define WriteDisable            1'b0    
`define ReadEnable              1'b1
`define ReadDisable             1'b0
`define AluOpBus                4:0             //译码阶段的输出 aluop_o 宽度
`define AluSelBus               2:0             //译码阶段的输出 alusel_o 宽度
`define InstValid               1'b1
`define InstInvalid             1'b0
`define True_v                  1'b1
`define False_v                 1'b0
`define BranchEnable            1'b1
`define BranchDisable           1'b0
`define ChipEnable              1'b1
`define ChipDisable             1'b0

//******    与具体指令相关的宏定义    ******//
`define INST_I_TYPE             7'b0010011      // I-type 指令
`define INST_ADDI               3'b000          // addi
`define INST_SLTI               3'b010          // slti
`define INST_SLTIU              3'b011          // sltiu
`define INST_XORI               3'b100          // xori
`define INST_ORI                3'b110          // ori 指令
`define INST_ANDI               3'b111          // andi
`define INST_SLLI               3'b001          // slli
`define INST_SRI                3'b101          // srli  // [30]bit = 0
//`define INST_SRAI             3'b101          // srai  // [30]bit = 1 需要根据 [31:25]来区分 srli 和 srai  其实就是 第 30 位

`define INST_R_TYPE             7'b0110011      // R-type inst
`define INST_ADD                3'b000          // add   // [30]bit = 0
//`define INST_SUB              3'b000          // sub   // [30]bit = 1 
`define INST_SLL                3'b001          // sll 
`define INST_SLT                3'b010          // slt
`define INST_SLTU               3'b011          // sltu
`define INST_XOR                3'b100          // xor
`define INST_SRL                3'b101          // srl   // [30]bit = 0
//`define INST_SRA              3'b101          // sra   // [30]bit = 1
`define INST_OR                 3'b110          // or
`define INST_AND                3'b111          // and

`define INST_B_TYPE             7'b1100011      // B-type inst
`define INST_BEQ                3'b000          // beq
`define INST_BNE                3'b001          // bne
`define INST_BLT                3'b100          // blt
`define INST_BGE                3'b101          // bge
`define INST_BLTU               3'b110          // bltu
`define INST_BGEU               3'b111          // bgeu

`define INST_JAL                7'b1101111      // J-type inst //jal
`define INST_JALR               7'b1100111      // jalr

`define INST_LUI                7'b0110111      // lui  U-type inst
`define INST_AUIPC              7'b0010111      // auipc

`define INST_L_TYPE             7'b0000011      // I-type Load inst 
`define INST_LB                 3'b000          // lb
`define INST_LH                 3'b001          // lh
`define INST_LW                 3'b010          // lw
`define INST_LBU                3'b100          // lbu
`define INST_LHU                3'b101          // lhu

`define INST_S_TYPE             7'b0100011      // S-type store inst
`define INST_SB                 3'b000          // sb
`define INST_SH                 3'b001          // sh
`define INST_SW                 3'b010          // sw

`define INST_F_TYPE             7'b0001111      // fence inst
`define INST_F                  3'b000          // fence
`define INST_FI                 3'b001          // fence.i

`define INST_CSR_TYPE           7'b1110011      // csr inst
`define INST_ECALL              3'b000          // ecall  [20]bit 为 0
`define INST_EBR                3'b000          // ebreak [20]bit 为 1
`define INST_CSRRW              3'b001          // csrrw
`define INST_CSRRS              3'b010          // csrrs
`define INST_CSRRC              3'b011          // csrrc
`define INST_CSRRWI             3'b101          // csrrwi
`define INST_CSRRSI             3'b110          // csrrsi
`define INST_CSRRCI             3'b111          // csrrci


//******    执行时对应的指令进行操作相关宏定义  *******//
//AluOp
`define EXE_NONE                5'b00000
`define EXE_ADD                 5'b00001
`define EXE_SUB                 5'b00010
`define EXE_AND                 5'b00011
`define EXE_OR                  5'b00100
`define EXE_XOR                 5'b00101 
`define EXE_SLL                 5'b00110
`define EXE_SRL                 5'b00111
`define EXE_SRA                 5'b01000

`define EXE_SLT                 5'b01001
`define EXE_SLTU                5'b01010 

`define EXE_LUI                 5'b01011 
 
`define EXE_BEQ                 5'b01100
`define EXE_BNE                 5'b01101
`define EXE_BLT                 5'b01110
`define EXE_BGE                 5'b01111
`define EXE_BLTU                5'b10000
`define EXE_BGEU                5'b10001
`define EXE_JAL                 5'b10010
`define EXE_JALR                5'b10011

`define EXE_LB                  5'b10100
`define EXE_LH                  5'b10101
`define EXE_LW                  5'b10110
`define EXE_LBU                 5'b10111
`define EXE_LHU                 5'b11000

`define EXE_SB                  5'b11001
`define EXE_SH                  5'b11010
`define EXE_SW                  5'b11011

//AluSel
`define EXE_RES_LOGIC           3'b001
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_ARITH           3'b011
`define EXE_RES_COMPARE         3'b100
`define EXE_RES_LOAD            3'b101
`define EXE_RES_STORE           3'b110
`define EXE_RES_BRANCH          3'b111

`define EXE_RES_NONE            3'b000


//******    与指令存储器 ROM 相关的宏定义    ******//
`define InstAddrBus             31:0            // rom 地址总线宽度
`define InstBus                 31:0            // rom 数据总线宽度
`define InstMemNum              65535           // rom 实际大小 64KB
`define InstMemNumLog2          16             // rom 实际使用地址线宽度

//******                RAM              *******//
`define DataAddrBus             31:0            // ram addr bus
`define DataBus                 31:0            // ram data bus
`define DataMemNum              65535           // ram 64k
`define DataMemNumLog2          16              // 
`define ByteWidth               7:0             // one Byte 8bit

//******    与通用寄存器 regfile 有关宏定义  ******//
`define RegAddrBus              4:0             // regfile 模块的地址线宽度
`define RegBus                  31:0            // regfile 模块的数据线宽度
`define RegWidth                32              // 通用寄存器宽度
`define DoubleRegWidth          64              
`define DoubleRegBus            63:0
`define RegNum                  32              // 通用寄存器的数量
`define RegNumLog2              5               // 寻址通用寄存器使用的地址位数
`define NOPRegAddr              5'b00000

