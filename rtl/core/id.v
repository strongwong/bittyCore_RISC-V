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

module id(
    input   wire                    rst,
    input   wire[`InstAddrBus]      pc_i,
    input   wire[`InstBus]          inst_i,

    // read regs form regfile
    input   wire[`RegBus]           reg1_data_i,
    input   wire[`RegBus]           reg2_data_i,

    // from ex
    input   wire                    ex_wreg_i,
    input   wire[`RegBus]           ex_wdata_i,
    input   wire[`RegAddrBus]       ex_wd_i,

    // from wd mem
    input   wire                    mem_wreg_i,
    input   wire[`RegBus]           mem_wdata_i,
    input   wire[`RegAddrBus]       mem_wd_i,

    // output to regfile
    output  reg                     reg1_read_o,
    output  reg                     reg2_read_o,
    output  reg[`RegAddrBus]        reg1_addr_o,
    output  reg[`RegAddrBus]        reg2_addr_o,

    // output execution
    output  reg[`AluOpBus]          aluop_o,
    output  reg[`AluSelBus]         alusel_o,
    output  reg[`RegBus]            reg1_o,
    output  reg[`RegBus]            reg2_o,
    output  reg[`RegAddrBus]        wd_o,
    output  reg                     wreg_o
);

    // 取得指令的指令码，功能码
    // 根据 RISC-V ISA 手册我们可以知道
    // [6:0] 为 opcode; [11:7] 为 rd; [14:12] 为 funct3; [19:15] 为 rs1; [24:20] 为 rs2; [31:25] 为 funct7;
    wire[6:0]   opcode  = inst_i[6:0];
    wire[4:0]   rd      = inst_i[11:7];
    wire[2:0]   funct3  = inst_i[14:12];
    wire[4:0]   rs1     = inst_i[19:15];
    wire[4:0]   rs2     = inst_i[24:20];
    wire[6:0]   funct7  = inst_i[31:25];

    // 保存指令执行需要的立即数
    reg[`RegBus]    imm;

    // 指示指令是否有效
    reg     instvalid;

    //*******   对指令译码    *******//
    always @ (*) begin
        if (rst == `RstEnable) begin
            aluop_o     <= `EXE_NONE;
            alusel_o    <= `EXE_RES_NONE;
            wd_o        <= `NOPRegAddr;
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstValid;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm         <= `ZeroWord;
        end else begin
            aluop_o     <= `EXE_NONE;
            alusel_o    <= `EXE_RES_NONE;
            wd_o        <= rd;
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstInvalid;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            reg1_addr_o <= rs1;
            reg2_addr_o <= rs2;
            imm         <= `ZeroWord;

            case (opcode)
                `INST_I_TYPE:   begin
                    case (funct3)
                        `INST_ORI:  begin                                       // 根据 opcode 和 funct3 判断 ori 指令
                            wreg_o      <= `WriteEnable;                        // ori 指令需要将结果写入目的寄存器
                            aluop_o     <= `EXE_OR;                             // 运算子类型是逻辑“或”运算
                            alusel_o    <= `EXE_RES_LOGIC;                      // 运算类型是逻辑运算
                            reg1_read_o <= `ReadEnable;                         // 读端口 1 读取寄存器
                            reg2_read_o <= `ReadDisable;                        // 不用读
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};   // 指令执行需要立即数
                            wd_o        <= rd;                                  // 目的寄存器地址
                            instvalid   <= `InstValid;                          // ori 指令有效指令
                        end 
                        default:  begin
                            instvalid   <= `InstInvalid;
                        end
                    endcase                   

                end 
                default: begin
                    instvalid   <= `InstInvalid;
                end
            endcase     // case op

        end     // if
    end // always


    // 给 reg1_o 赋值的过程增加了两种情况：
    // 1. 如果 Regfile 模块读端口 1 要读取的寄存器就是执行阶段要写的目的寄存器，那么直接把执行阶段的结果 ex_wdata_i 作为 reg1_o 的值
    // 2. 如果 Regfile 模块读端口 1 要读取的寄存器就是访存阶段要写的目的寄存器，那么直接把访存阶段的结果 mem_wdata_i 作为 reg1_o 的值

    // 确定运算的源操作数 1
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg1_o  <= `ZeroWord;
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o  <= ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o  <= mem_wdata_i;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o  <= reg1_data_i;         // regfile port 1 output data
        end else if (reg1_read_o == 1'b0) begin
            reg1_o  <= imm;                 // 立即数
        end else begin
            reg1_o  <= `ZeroWord;
        end
        
    end

    // 给 reg2_o 赋值的过程增加了两种情况：
    // 1. 如果 Regfile 模块读端口 2 要读取的寄存器就是执行阶段要写的目的寄存器，那么直接把执行阶段的结果 ex_wdata_i 作为 reg2_o 的值
    // 2. 如果 Regfile 模块读端口 2 要读取的寄存器就是访存阶段要写的目的寄存器，那么直接把访存阶段的结果 mem_wdata_i 作为 reg2_o 的值

    // 确定运算的源操作数 2
    always @ (*) begin
        if (rst == `RstEnable) begin
            reg2_o  <= `ZeroWord;
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o  <= ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o  <= mem_wdata_i;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o  <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o  <= imm;
        end else begin
            reg2_o  <= `ZeroWord;
        end
    end


endmodule // id

