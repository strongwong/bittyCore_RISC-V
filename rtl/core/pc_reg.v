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

module pc_reg(
    input       wire                clk,
    input       wire                rst,

    input       wire                branch_flag_i,
    input       wire[`RegBus]       branch_addr_i,
    input       wire[2:0]           stalled,

    output      reg[`InstAddrBus]   pc_o,
    output      reg                 ce_o 
);

    always  @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce_o    <= `ReadDisable;                // 复位时，读指令使能无效
        end else begin
            ce_o    <= `ReadEnable;
        end
    end

    always  @ (posedge clk) begin
        if (ce_o == `ReadDisable) begin
            pc_o    <=  `ZeroWord;
        end else if (stalled[0] == `NoStop) begin
            if (branch_flag_i == `BranchEnable) begin
                pc_o    <= branch_addr_i;
            end else begin
                pc_o    <= pc_o + 4'h4;
            end
        end
    end

endmodule // pc_reg
