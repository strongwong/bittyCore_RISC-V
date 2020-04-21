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

`include "bitty_defs.v"

module ex(
    input   wire            rst,

    // 译码阶段送到执行阶段的信息
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_i,
    input   wire[`RegBus]       reg2_i,
    input   wire[`RegAddrBus]   wd_i,
    input   wire                wreg_i,

    // 执行结果
    output  reg[`RegAddrBus]    wd_o,
    output  reg                 wreg_o,
    output  reg[`RegBus]        wdata_o
);

    // 保存逻辑运算的结果
    reg[`RegBus]    logicout;

    // 1. 根据 aluop_i 指示的运算子类型进行运算，这里只有逻辑 “或”运算
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout    <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR: begin
                    logicout    <= reg1_i | reg2_i;
                end 
                default:   begin
                    logicout    <= `ZeroWord;
                end
            endcase
        end // if
    end // always

    // 2. 根据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果
    always @ (*) begin
        wd_o    <= wd_i;    // wd_o 等于 wd_i, 要写的目的寄存器地址
        wreg_o  <= wreg_i;  // wreg_o 等于 wreg_i,表示是否要写目的寄存器
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;    // wdata_o 中存放运算结果
            end 
            default:    begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end

endmodule // ex
