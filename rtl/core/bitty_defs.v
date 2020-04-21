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
`define AluOpBus                7:0             //译码阶段的输出 aluop_o 宽度
`define AluSelBus               2:0             //译码阶段的输出 alusel_o 宽度
`define InstValid               1'b0
`define InstInvalid             1'b1
`define True_v                  1'b1
`define False_v                 1'b0
`define ChipEnable              1'b1
`define ChipDisable             1'b0

//******    与具体指令相关的宏定义    ******//
`define INST_ORI                7'b0010011       //指令 ori 的指令码



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

