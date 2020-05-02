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

module regsfile(
    input   wire        clk,
    input   wire        rst,

    // write port 回写
    input   wire                we_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire[`RegBus]       wdata_i,

    // read port 1
    input   wire                re1_i,
    input   wire[`RegAddrBus]   raddr1_i,
    output  reg[`RegBus]        rdata1_o,

    // read port 2
    input   wire                re2_i,
    input   wire[`RegAddrBus]   raddr2_i,
    output  reg[`RegBus]        rdata2_o
);

    // 定义 32 个 32 位寄存器
    reg[`RegBus]    regs[0:`RegNum-1];

    // write 
    always @ (posedge clk)  begin
        if (rst == `RstDisable) begin
            if ((we_i == `WriteEnable) && (waddr_i != `RegNumLog2'h0)) begin
                regs[waddr_i] <= wdata_i;
            end 
        end
    end

    // read port 1
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata1_o    <= `ZeroWord;
        end else if (raddr1_i == `RegNumLog2'h0) begin
            rdata1_o    <= `ZeroWord;
        end else if ((raddr1_i == waddr_i) && (we_i == `WriteEnable) && (re1_i == `ReadEnable)) begin
            rdata1_o    <= wdata_i;
        end else if (re1_i == `ReadEnable) begin
            rdata1_o    <= regs[raddr1_i];
        end else begin
            rdata1_o    <= `ZeroWord;
        end
    end

    // read port 2
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata2_o    <= `ZeroWord;
        end else if (raddr2_i == `RegNumLog2'h0) begin
            rdata2_o    <= `ZeroWord;
        end else if ((raddr2_i == waddr_i) && (we_i == `WriteEnable) && (re2_i == `ReadEnable)) begin
            rdata2_o    <= wdata_i;
        end else if (re2_i == `ReadEnable) begin
            rdata2_o    <= regs[raddr2_i];
        end else begin
            rdata2_o    <= `ZeroWord;
        end
    end

endmodule // regsfile
