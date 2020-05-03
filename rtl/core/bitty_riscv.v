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

    // rom
    input   wire[`RegBus]   rom_data_i,
    output  wire[`RegBus]   pc_addr_o,
    output  wire            pc_ce_o,

    // ram
    input   wire[`RegBus]   ram_data_i,
    output  wire[`RegBus]   ram_addr_o,
    output  wire[`RegBus]   ram_data_o,
    output  wire            ram_we_o,
    output  wire[3:0]       ram_sel_o,
    output  wire            ram_ce_o
);

    // 连接 IF/ID 模块与译码阶段 ID 模块的变量
    wire[`InstAddrBus]      pc_pc_o;
    wire[`InstAddrBus]      if_id_pc_o;
    wire[`InstBus]          if_id_inst_o;

    // 连接译码阶段 ID 模块输出与 ID/EX 模块的输入的变量
    wire[`InstAddrBus]      id_pc_o;
    wire[`InstBus]          id_inst_o;
    wire[`AluOpBus]         id_aluop_o;
    wire[`AluSelBus]        id_alusel_o;
    wire[`RegBus]           id_reg1_o;
    wire[`RegBus]           id_reg2_o;
    wire                    id_wreg_o;
    wire[`RegAddrBus]       id_wd_o;

    // 连接 ID/EX 模块输出与执行阶段 EX 模块的输入变量
    wire[`InstAddrBus]      ex_pc_i;
    wire[`InstBus]          ex_inst_i;
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

    wire[`AluOpBus]         ex_mem_aluop_o;
    wire[`DataAddrBus]      ex_addr_o;
    wire[`RegBus]           ex_mem_reg2_o;

    // ex to pc_reg
    wire                    ex_branch_flag_o;
    wire[`RegBus]           ex_branch_addr_o;

    // 连接 EX/MEM 模块的输出与访存阶段 MEM 模块的输入的变量
    wire                    mem_wreg_i;
    wire[`RegAddrBus]       mem_wd_i;
    wire[`RegBus]           mem_wdata_i;

    wire[`AluOpBus]         mem_aluop_i;
    wire[`DataAddrBus]      mem_mem_addr_i;
    wire[`RegBus]           mem_reg2_i;

    // 连接访存阶段 MEM 模块的输出与 MEM/WB 模块的输入变量
    wire                    mem_wreg_o;
    wire[`RegAddrBus]       mem_wd_o;
    wire[`RegBus]           mem_wdata_o;

    // 连接 MEM/WB 模块的输出与回写阶段输入变量
    wire                    wb_wreg_i;
    wire[`RegAddrBus]       wb_wd_i;
    wire[`RegBus]           wb_wdata_i;

    // 连接译码阶段 ID 模块与通用寄存器 Regfile 模块的变量
    wire                    id_reg1_read_o;
    wire                    id_reg2_read_o;
    wire[`RegAddrBus]       id_reg1_addr_o;
    wire[`RegAddrBus]       id_reg2_addr_o;
    wire[`RegBus]           reg1_data_o;
    wire[`RegBus]           reg2_data_o;

    // ctrl
    wire[2:0]               stall;    
    wire                    stallreq_from_id;

    // pc_reg 例化
    pc_reg  u_pc_reg(
        .clk(clk),
        .rst(rst),
        .branch_flag_i(ex_branch_flag_o),
        .branch_addr_i(ex_branch_addr_o),

        .stalled(stall),

        .pc_o(pc_pc_o),
        .ce_o(pc_ce_o)
    );

    assign  pc_addr_o  =  pc_pc_o;  // 指令存储器的输入地址就是 pc 的值

    // IF/ID 例化
    if_id   u_if_id(
        .clk(clk),
        .rst(rst),
        .pc_i(pc_pc_o),
        .inst_i(rom_data_i),
        .ex_branch_flag_i(ex_branch_flag_o),

        .stalled(stall),

        .pc_o(if_id_pc_o),
        .inst_o(if_id_inst_o)
    );

    // ID 例化
    id  u_id(
        .rst(rst),
        .pc_i(if_id_pc_o),
        .inst_i(if_id_inst_o),
        
        // regfile 模块的输入
        .reg1_data_i(reg1_data_o),
        .reg2_data_i(reg2_data_o),

        // from ex
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),
        .ex_branch_flag_i(ex_branch_flag_o),

        .ex_aluop_i(ex_mem_aluop_o),

        // from wd mem
        .mem_wreg_i(mem_wreg_o),
        .mem_wdata_i(mem_wdata_o),
        .mem_wd_i(mem_wd_o),

        // 送入 regfile 的信息
        .reg1_read_o(id_reg1_read_o),
        .reg2_read_o(id_reg2_read_o),
        .reg1_addr_o(id_reg1_addr_o),
        .reg2_addr_o(id_reg2_addr_o),

        .stallreq(stallreq_from_id),

        // 送到 ID/EX 的信息
        .pc_o(id_pc_o),
        .inst_o(id_inst_o),
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
        .we_i(wb_wreg_i),
        .waddr_i(wb_wd_i),
        .wdata_i(wb_wdata_i),

        .re1_i(id_reg1_read_o),
        .raddr1_i(id_reg1_addr_o),
        .rdata1_o(reg1_data_o),

        .re2_i(id_reg2_read_o),
        .raddr2_i(id_reg2_addr_o),
        .rdata2_o(reg2_data_o)
    );

    // ID/EX 例化
    id_ex   u_id_ex(
        .clk(clk),
        .rst(rst),

        // 从译码阶段 ID 模块来的信息
        .id_pc_i(id_pc_o),
        .id_inst_i(id_inst_o),
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),

        .ex_branch_flag_i(ex_branch_flag_o),

        .stalled(stall),

        // 传递到执行阶段 EX 模块的信息
        .ex_pc_o(ex_pc_i),
        .ex_inst_o(ex_inst_i),
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
        .ex_pc(ex_pc_i),
        .ex_inst(ex_inst_i),
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),

        // 输出到 ID/MEM 模块的信息
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),

        .ex_aluop_o(ex_mem_aluop_o),
        .ex_mem_addr_o(ex_addr_o),
        .ex_reg2_o(ex_mem_reg2_o),

        // ex to pc_reg
        .branch_flag_o(ex_branch_flag_o),
        .branch_addr_o(ex_branch_addr_o)
    );

    // EX/MEM 例化
    ex_mem  u_ex_mem(
        .clk(clk),
        .rst(rst),

        // 从执行阶段 EX 来的信息
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .ex_aluop_i(ex_mem_aluop_o),
        .ex_mem_addr_i(ex_addr_o),
        .ex_reg2_i(ex_mem_reg2_o),

        // 送到访存阶段的  MEM 信息
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),

        .mem_aluop(mem_aluop_i),
        .mem_mem_addr(mem_mem_addr_i),
        .mem_reg2(mem_reg2_i)
    );

    // MEM 例化
    mem u_mem(
        .rst(rst),

        // 来自 EX/MEM 模块的信息
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        .mem_aluop_i(mem_aluop_i),
        .mem_mem_addr_i(mem_mem_addr_i),
        .mem_reg2_i(mem_reg2_i),

        // 送到 MEM/WB 的信息
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),

        // from ram
        .mem_data_i(ram_data_i),
        
        // to ram
        .mem_addr_o(ram_addr_o),
        .mem_we_o(ram_we_o),
        .mem_sel_o(ram_sel_o),
        .mem_data_o(ram_data_o),
        .mem_ce_o(ram_ce_o)
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

    // ctrl 
    ctrl    u_ctrl(
        .rst(rst),
        .stallreq_from_id(stallreq_from_id),

        .stalled_o(stall)
    );

endmodule // bitty_riscv
