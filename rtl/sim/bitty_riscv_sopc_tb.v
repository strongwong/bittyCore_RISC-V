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

    wire[31:0]  x3  =  u_bitty_riscv_sopc.u_bitty_riscv.u_regsfile.regs[3];
    wire[31:0]  x26 =  u_bitty_riscv_sopc.u_bitty_riscv.u_regsfile.regs[26];
    wire[31:0]  x27 =  u_bitty_riscv_sopc.u_bitty_riscv.u_regsfile.regs[27];

    // 最初时刻，复位信号有效，在第 195ns，复位信号无效，最小 SOPC 开始运行
    // 运行 1000ns 后，暂停仿真
    initial begin
        rst = 1'b0;
        #195    rst = 1'b1;
        $display("--------- test running --------");

        wait(x26 == 32'h1);     // 测试结束
        #100
        if (x27 == 32'h1) begin     // 27bit 为 1 就 ok
            $display("********** ######### ***********");
            $display("********** test pass ***********");
            $display("********** ######### ***********");
        end else begin
            $display("********** ######### ***********");
            $display("********** test fail ***********");
            $display("********** ######### ***********");
            $display("test fail inst = %2d", x3);       // 第多少条指令出错
        end
        $stop;
    end

    initial begin
        #100000
        $display("#####--Time out--#####");
        $stop;
    end

    // 例化最小 sopc
    bitty_riscv_sopc   u_bitty_riscv_sopc(
        .clk(CLOCK_50),
        .rst(rst)
    );

endmodule // bitty_riscv_sopc_tb
