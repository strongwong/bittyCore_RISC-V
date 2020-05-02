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

module bitty_riscv_sopc(
    input   wire        clk,
    input   wire        rst
);

    // 连接指令存储器
    wire[`InstAddrBus]  inst_addr_o;
    wire[`InstBus]      inst_rom_o;
    wire                core_ce_o;

    // risc-v ram
    wire                mem_ce_i;
    wire                mem_we_i;
    wire[`DataAddrBus]  mem_addr_i;
    wire[`DataBus]      mem_data_i;
    wire[`DataBus]      mem_data_o;
    wire[3:0]           mem_sel_i;

    // 例化处理器 bitty risc-v
    bitty_riscv    u_bitty_riscv(
        .clk(clk),
        .rst(rst),
        .rom_data_i(inst_rom_o),
        .pc_addr_o(inst_addr_o),
        .pc_ce_o(core_ce_o),

        .ram_data_i(mem_data_o),
        .ram_addr_o(mem_addr_i),
        .ram_data_o(mem_data_i),
        .ram_we_o(mem_we_i),
        .ram_sel_o(mem_sel_i),
        .ram_ce_o(mem_ce_i)
    );

    // 例化指令存储器 ROM
    inst_rom    u_inst_rom(
        .ce_i(core_ce_o),
        .addr_i(inst_addr_o),
        .inst_o(inst_rom_o)
    );

    // ram data
    data_ram    u_data_ram(
        .clk(clk),
        .ce(mem_ce_i),
        .we(mem_we_i),
        .addr(mem_addr_i),
        .sel(mem_sel_i),
        .data_i(mem_data_i),

        .data_o(mem_data_o)
    );

endmodule // bitty_riscv_sopc
