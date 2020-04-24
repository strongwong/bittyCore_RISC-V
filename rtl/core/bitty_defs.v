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
`define AluOpBus                3:0             //译码阶段的输出 aluop_o 宽度
`define AluSelBus               2:0             //译码阶段的输出 alusel_o 宽度
`define InstValid               1'b1
`define InstInvalid             1'b0
`define True_v                  1'b1
`define False_v                 1'b0
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


//******    执行时对应的指令进行操作相关宏定义  *******//
//AluOp
`define EXE_NONE                4'b0000
`define EXE_ADD                 4'b0001
`define EXE_SUB                 4'b0010
`define EXE_AND                 4'b0011
`define EXE_OR                  4'b0100
`define EXE_XOR                 4'b0101 
`define EXE_SLL                 4'b0110
`define EXE_SRL                 4'b0111
`define EXE_SRA                 4'b1000

`define EXE_SLT                 4'b1001
`define EXE_SLTU                4'b1010 

 

//AluSel
`define EXE_RES_LOGIC           3'b001
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_ARITH           3'b011
`define EXE_RES_COMPARE         3'b100

`define EXE_RES_NONE            3'b000


//******    与指令存储器 ROM 相关的宏定义    ******//
`define InstAddrBus             31:0            // rom 地址总线宽度
`define InstBus                 31:0            // rom 数据总线宽度
`define InstMemNum              131071          // rom 实际大小 128KB
`define InstMemNumLog2          17              // rom 实际使用地址线宽度

//******    与通用寄存器 regfile 有关宏定义  ******//
`define RegAddrBus              4:0             // regfile 模块的地址线宽度
`define RegBus                  31:0            // regfile 模块的数据线宽度
`define RegWidth                32              // 通用寄存器宽度
`define DoubleRegWidth          64              
`define DoubleRegBus            63:0
`define RegNum                  32              // 通用寄存器的数量
`define RegNumLog2              5               // 寻址通用寄存器使用的地址位数
`define NOPRegAddr              5'b00000

