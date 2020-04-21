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

module inst_rom(
    input   wire                ce,
    input   wire[`InstAddrBus]  addr,
    output  reg[`InstBus]       inst 
);

    // 定义一个数组，大小是 InstMemNum ,元素宽度是 InstBus
    reg[`InstBus]   inst_mem[0:`InstMemNum-1];

    // 使用文件 inst_rom.data 初始化指令存储器
    initial $readmemh("inst_rom.data", inst_mem);

    // 当复位信号无效时，依据输入的地址，给出指令存储器 ROM 中对应的元素
    always  @ (*) begin
        if (ce == `ReadDisable) begin
            inst    <= `ZeroWord;
        end else begin
            inst    <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule // inst_rom
