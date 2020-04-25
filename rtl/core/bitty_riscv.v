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

module bitty_riscv(
    input   wire            clk,
    input   wire            rst,

    input   wire[`RegBus]   rom_data_i,
    output  wire[`RegBus]   rom_addr_o,
    output  wire            rom_ce_o
);

    // 连接 IF/ID 模块与译码阶段 ID 模块的变量
    wire[`InstAddrBus]      pc;
    wire[`InstAddrBus]      id_pc_i;
    wire[`InstBus]          id_inst_i;

    // 连接译码阶段 ID 模块输出与 ID/EX 模块的输入的变量
    wire[`AluOpBus]         id_aluop_o;
    wire[`AluSelBus]        id_alusel_o;
    wire[`RegBus]           id_reg1_o;
    wire[`RegBus]           id_reg2_o;
    wire                    id_wreg_o;
    wire[`RegAddrBus]       id_wd_o;

    // 连接 ID/EX 模块输出与执行阶段 EX 模块的输入变量
    wire[`AluOpBus]         ex_aluop_i;
    wire[`AluSelBus]        ex_alusel_i;
    wire[`RegBus]           ex_reg1_i;
    wire[`RegBus]           ex_reg2_i;
    wire                    ex_wreg_i;
    wire[`RegAddrBus]       ex_wd_i;

    // 连接执行阶段 EX 模块的输出与 EX/MEM 模块的输入变量
    wire                    ex_wreg_o;
    wire[`RegAddrBus]       ex_wd_o;
    wire[`RegBus]           ex_wdata_o;

    // 连接 EX/MEM 模块的输出与访存阶段 MEM 模块的输入的变量
    wire                    mem_wreg_i;
    wire[`RegAddrBus]       mem_wd_i;
    wire[`RegBus]           mem_wdata_i;

    // 连接访存阶段 MEM 模块的输出与 MEM/WB 模块的输入变量
    wire                    mem_wreg_o;
    wire[`RegAddrBus]       mem_wd_o;
    wire[`RegBus]           mem_wdata_o;

    // 连接 MEM/WB 模块的输出与回写阶段输入变量
    wire                    wb_wreg_i;
    wire[`RegAddrBus]       wb_wd_i;
    wire[`RegBus]           wb_wdata_i;

    // 连接译码阶段 ID 模块与通用寄存器 Regfile 模块的变量
    wire                    reg1_read;
    wire                    reg2_read;
    wire[`RegBus]           reg1_data;
    wire[`RegBus]           reg2_data;
    wire[`RegAddrBus]       reg1_addr;
    wire[`RegAddrBus]       reg2_addr;

    // pc_reg 例化
    pc_reg  u_pc_reg(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .ce(rom_ce_o)
    );

    assign  rom_addr_o  =  pc;  // 指令存储器的输入地址就是 pc 的值

    // IF/ID 例化
    if_id   u_if_id(
        .clk(clk),
        .rst(rst),
        .if_pc(pc),
        .if_inst(rom_data_i),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );

    // ID 例化
    id  u_id(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        
        // regfile 模块的输入
        .reg1_data_i(reg1_data),
        .reg2_data_i(reg2_data),

        // from ex
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),

        // from wd mem
        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o),

        // 送入 regfile 的信息
        .reg1_read_o(reg1_read),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg2_addr_o(reg2_addr),

        // 送到 ID/EX 的信息
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o)
    );

    // 通用寄存器 regfile 例化
    regsfile u_regsfile(
        .clk(clk),
        .rst(rst),
        .we(wb_wreg_i),
        .waddr(wb_wd_i),
        .wdata(wb_wdata_i),
        .re1(reg1_read),
        .raddr1(reg1_addr),
        .rdata1(reg1_data),

        .re2(reg2_read),
        .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );

    // ID/EX 例化
    id_ex   u_id_ex(
        .clk(clk),
        .rst(rst),

        // 从译码阶段 ID 模块来的信息
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),

        // 传递到执行阶段 EX 模块的信息
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i)
    );

    // EX 模块例化
    ex  u_ex(
        .rst(rst),

        // 从 ID/EX 模块来的信息
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),

        // 输出到 ID/MEM 模块的信息
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o)
    );

    // EX/MEM 例化
    ex_mem  u_ex_mem(
        .clk(clk),
        .rst(rst),

        // 从执行阶段 EX 来的信息
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        // 送到访存阶段的  MEM 信息
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i)
    );

    // MEM 例化
    mem u_mem(
        .rst(rst),

        // 来自 EX/MEM 模块的信息
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        // 送到 MEM/WB 的信息
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o)
    );

    // MEM/WB 例化
    mem_wb  u_mem_wb(
        .clk(clk),
        .rst(rst),

        // 来自访存阶段 MEM 信息
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        // 送到回写阶段的信息 to id/regsfile
        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)
    );

endmodule // bitty_riscv
