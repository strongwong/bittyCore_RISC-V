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

`timescale  1ns/1ps

module  bitty_riscv_sopc_tb();

    reg     CLOCK_50;
    reg     rst;
    
    // 每隔 10ns CLOCK_50 信号翻转一次，所以周期是 20ns, 对应 50MHz
    initial begin
        CLOCK_50    = 1'b0;
        forever #10 CLOCK_50    = ~CLOCK_50;
    end 

    // 最初时刻，复位信号有效，在第 195ns，复位信号无效，最小 SOPC 开始运行
    // 运行 1000ns 后，暂停仿真
    initial begin
        rst = 1'b0;
        #195    rst = 1'b1;
        #1000   $stop;
    end

    // 例化最小 sopc
    bitty_riscv_sopc   u_bitty_riscv_sopc(
        .clk(CLOCK_50),
        .rst(rst)
    );

endmodule // bitty_riscv_sopc_tb
