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

module ex_mem(
    input   wire        clk,
    input   wire        rst,

    // 来自执行阶段的信息
    input   wire[`RegAddrBus]       ex_wd,
    input   wire                    ex_wreg,
    input   wire[`RegBus]           ex_wdata,

    input   wire[`AluOpBus]         ex_aluop_i,
    input   wire[`DataAddrBus]      ex_mem_addr_i,
    input   wire[`RegBus]           ex_reg2_i,

    // 送到访存阶段的信息
    output  reg[`RegAddrBus]        mem_wd,
    output  reg                     mem_wreg,
    output  reg[`RegBus]            mem_wdata,

    output  reg[`AluOpBus]          mem_aluop,
    output  reg[`DataAddrBus]       mem_mem_addr,
    output  reg[`RegBus]            mem_reg2
);

    always  @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd      <= `NOPRegAddr;
            mem_wreg    <= `WriteDisable;
            mem_wdata   <= `ZeroWord;
            mem_aluop   <= `EXE_NONE;
            mem_mem_addr<= `ZeroWord;
            mem_reg2    <= `ZeroWord;
        end else begin
            mem_wd      <= ex_wd;
            mem_wreg    <= ex_wreg;
            mem_wdata   <= ex_wdata;
            mem_aluop   <= ex_aluop_i;
            mem_mem_addr<= ex_mem_addr_i;
            mem_reg2    <= ex_reg2_i;
        end
    end
    
endmodule // ex_mem
