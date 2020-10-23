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
    input   wire                    ex_branch_flag_i,
// load 相关
    input   wire[`AluOpBus]         ex_aluop_i,

    // from wd mem
    input   wire                    mem_wreg_i,
    input   wire[`RegBus]           mem_wdata_i,
    input   wire[`RegAddrBus]       mem_wd_i,

    // from csr
    input   wire[`RegBus]           csr_reg_data_i,

    // to csr reg
    output  reg[`DataAddrBus]       csr_reg_addr_o,

    // output to regfile
    output  reg                     reg1_read_o,
    output  reg                     reg2_read_o,
    output  reg[`RegAddrBus]        reg1_addr_o,
    output  reg[`RegAddrBus]        reg2_addr_o,

    // output execution
    output  wire                    stallreq,
    output  reg[`InstAddrBus]       pc_o,
    output  reg[`InstBus]           inst_o,
    output  reg[`AluOpBus]          aluop_o,
    output  reg[`AluSelBus]         alusel_o,
    output  reg[`RegBus]            reg1_o,
    output  reg[`RegBus]            reg2_o,
    output  reg[`RegAddrBus]        wd_o,
    output  reg                     wreg_o,
    output  reg                     wcsr_reg_o,
    output  reg[`RegBus]            csr_reg_o,
    output  reg[`DataAddrBus]       wd_csr_reg_o
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
    reg[`RegBus]    imm_1;
    reg[`RegBus]    imm_2;

    // 指示指令是否有效
    reg     instvalid;

    // load 相关
    reg     reg1_loadralate;
    reg     reg2_loadralate;
    wire    pre_inst_is_load;
    assign  stallreq = reg1_loadralate | reg2_loadralate;
    assign pre_inst_is_load = ( (ex_aluop_i == `EXE_LB) ||
                                (ex_aluop_i == `EXE_LH) ||
                                (ex_aluop_i == `EXE_LW) ||
                                (ex_aluop_i == `EXE_LBU)||
                                (ex_aluop_i == `EXE_LHU)||
                                (ex_aluop_i == `EXE_SB) ||
                                (ex_aluop_i == `EXE_SH) ||
                                (ex_aluop_i == `EXE_SW)) ? 1'b1 : 1'b0;



    //*******   对指令译码    *******//
    always @ (*) begin
        if (rst == `RstEnable) begin
            aluop_o         <= `EXE_NONE;
            alusel_o        <= `EXE_RES_NONE;
            wd_o            <= `NOPRegAddr;
            wreg_o          <= `WriteDisable;
            instvalid       <= `InstValid;
            reg1_read_o     <= `ReadDisable;
            reg2_read_o     <= `ReadDisable;
            reg1_addr_o     <= `NOPRegAddr;
            reg2_addr_o     <= `NOPRegAddr;
            imm_1           <= `ZeroWord;
            imm_2           <= `ZeroWord;
            inst_o          <= `ZeroWord;
            csr_reg_addr_o  <= `ZeroWord;
            csr_reg_o       <= `ZeroWord;
            wd_csr_reg_o    <= `ZeroWord;
            wcsr_reg_o      <= `WriteDisable;
        end else if (ex_branch_flag_i == `BranchEnable && inst_i != `INST_NONE) begin
            aluop_o         <= `EXE_NONE;
            alusel_o        <= `EXE_RES_NONE;
            wreg_o          <= `WriteDisable;
            instvalid       <= `InstValid;
            reg1_read_o     <= `ReadDisable;
            reg2_read_o     <= `ReadDisable;
            imm_1           <= `ZeroWord;
            imm_2           <= `ZeroWord;
        end else begin
            aluop_o         <= `EXE_NONE;
            alusel_o        <= `EXE_RES_NONE;
            wd_o            <= rd;
            wreg_o          <= `WriteDisable;
            instvalid       <= `InstInvalid;
            reg1_read_o     <= `ReadDisable;
            reg2_read_o     <= `ReadDisable;
            reg1_addr_o     <= rs1;
            reg2_addr_o     <= rs2;
            imm_1           <= `ZeroWord;
            imm_2           <= `ZeroWord;
            inst_o          <= inst_i;
            pc_o            <= pc_i;
            wcsr_reg_o      <= `WriteDisable;
            csr_reg_o       <= csr_reg_data_i;
            wd_csr_reg_o    <= `ZeroWord;
            csr_reg_addr_o  <= `ZeroWord;

            case (opcode)
                `INST_LUI   : begin     // lui
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_LUI;
                    alusel_o    <= `EXE_RES_SHIFT;
                    imm_2       <= {inst_i[31:12], 12'b0};
                    wd_o        <= rd;
                    instvalid   <= `InstValid;
                end
                `INST_AUIPC : begin     // auipc
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_ADD;
                    alusel_o    <= `EXE_RES_ARITH;
                    imm_1       <= pc_i;
                    imm_2       <= {inst_i[31:12], 12'b0};
                    wd_o        <= rd;
                    instvalid   <= `InstValid;
                end

                `INST_B_TYPE: begin
                    case (funct3)
                        `INST_BEQ: begin        // beq
                            aluop_o     <= `EXE_BEQ;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        `INST_BNE: begin        // bne
                            aluop_o     <= `EXE_BNE;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        `INST_BLT: begin        // blt
                            aluop_o     <= `EXE_BLT;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        `INST_BGE: begin        // bge
                            aluop_o     <= `EXE_BGE;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        `INST_BLTU: begin       // bltu
                            aluop_o     <= `EXE_BLTU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        `INST_BGEU: begin       // bgeu
                            aluop_o     <= `EXE_BGEU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        default: begin
                            instvalid   <= `InstValid;
                        end 
                    endcase
                end

                `INST_JAL:  begin       // jal
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_JAL;
                    alusel_o    <= `EXE_RES_BRANCH;
                    wd_o        <= rd;
                    instvalid   <= `InstValid;
                end

                `INST_JALR: begin       // jalr
                    wreg_o      <= `WriteEnable;
                    aluop_o     <= `EXE_JALR;
                    alusel_o    <= `EXE_RES_BRANCH;
                    reg1_read_o <= `ReadEnable;
                    reg2_read_o <= `ReadDisable;
                    wd_o        <= rd;
                    instvalid   <= `InstValid;
                end

                `INST_L_TYPE:   begin
                    case (funct3)
                        `INST_LB: begin         // lb
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_LB;   
                            alusel_o    <= `EXE_RES_LOAD; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadDisable;  
                            wd_o        <= rd; 
                            instvalid   <= `InstValid;
                        end 
                        `INST_LH: begin         // lh
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_LH;   
                            alusel_o    <= `EXE_RES_LOAD; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadDisable;  
                            wd_o        <= rd; 
                            instvalid   <= `InstValid;
                        end
                        `INST_LW: begin         // lw
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_LW;   
                            alusel_o    <= `EXE_RES_LOAD; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadDisable;  
                            wd_o        <= rd; 
                            instvalid   <= `InstValid;
                        end
                        `INST_LBU: begin        // lbu
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_LBU;   
                            alusel_o    <= `EXE_RES_LOAD; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadDisable;  
                            wd_o        <= rd; 
                            instvalid   <= `InstValid;
                        end
                        `INST_LHU: begin        // lhu
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_LHU;   
                            alusel_o    <= `EXE_RES_LOAD; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadDisable;  
                            wd_o        <= rd; 
                            instvalid   <= `InstValid;
                        end

                        default: begin
                            instvalid   <= `InstInvalid;
                        end 
                    endcase
                end

                `INST_S_TYPE: begin
                    case (funct3)
                        `INST_SB: begin         // sb
                            wreg_o      <= `WriteDisable; 
                            aluop_o     <= `EXE_SB;   
                            alusel_o    <= `EXE_RES_STORE; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable;  
                            instvalid   <= `InstValid;
                        end
                        `INST_SH: begin         // sh
                            wreg_o      <= `WriteDisable; 
                            aluop_o     <= `EXE_SH;   
                            alusel_o    <= `EXE_RES_STORE; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable;  
                            instvalid   <= `InstValid;
                        end
                        `INST_SW: begin         // sw
                            wreg_o      <= `WriteDisable; 
                            aluop_o     <= `EXE_SW;   
                            alusel_o    <= `EXE_RES_STORE; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable;  
                            instvalid   <= `InstValid;
                        end
                        default: begin
                            instvalid   <=  `InstInvalid;
                        end
                    endcase
                end

                `INST_I_TYPE:   begin
                    case (funct3)
                        `INST_ADDI: begin       // addi
                            wreg_o      <= `WriteEnable;                      
                            aluop_o     <= `EXE_ADD;                           
                            alusel_o    <= `EXE_RES_ARITH;                    
                            reg1_read_o <= `ReadEnable;                         
                            reg2_read_o <= `ReadDisable;                       
                            imm_2       <= {{20{inst_i[31]}}, inst_i[31:20]}; 
                            wd_o        <= rd;                                  
                            instvalid   <= `InstValid;                          
                        end
                        `INST_SLTI: begin       // slti
                            wreg_o      <= `WriteEnable;                      
                            aluop_o     <= `EXE_SLT;                           
                            alusel_o    <= `EXE_RES_COMPARE;                    
                            reg1_read_o <= `ReadEnable;                         
                            reg2_read_o <= `ReadDisable;                       
                            imm_2       <= {{20{inst_i[31]}}, inst_i[31:20]}; 
                            wd_o        <= rd;                                  
                            instvalid   <= `InstValid; 
                        end
                        `INST_SLTIU: begin      // sltiu
                            wreg_o      <= `WriteEnable;                      
                            aluop_o     <= `EXE_SLTU;                           
                            alusel_o    <= `EXE_RES_COMPARE;                    
                            reg1_read_o <= `ReadEnable;                         
                            reg2_read_o <= `ReadDisable;                       
                            imm_2       <= {{20{inst_i[31]}}, inst_i[31:20]}; 
                            wd_o        <= rd;                                  
                            instvalid   <= `InstValid;
                        end
                        `INST_XORI: begin       // xori
                            wreg_o      <= `WriteEnable;                      
                            aluop_o     <= `EXE_XOR;                           
                            alusel_o    <= `EXE_RES_LOGIC;                    
                            reg1_read_o <= `ReadEnable;                         
                            reg2_read_o <= `ReadDisable;                       
                            imm_2       <= {{20{inst_i[31]}}, inst_i[31:20]}; 
                            wd_o        <= rd;                                  
                            instvalid   <= `InstValid;
                        end
                        `INST_ORI:  begin       // ori                          // 根据 opcode 和 funct3 判断 ori 指令
                            wreg_o      <= `WriteEnable;                        // ori 指令需要将结果写入目的寄存器
                            aluop_o     <= `EXE_OR;                             // 运算子类型是逻辑“或”运算
                            alusel_o    <= `EXE_RES_LOGIC;                      // 运算类型是逻辑运算
                            reg1_read_o <= `ReadEnable;                         // 读端口 1 读取寄存器
                            reg2_read_o <= `ReadDisable;                        // 不用读
                            imm_2       <= {{20{inst_i[31]}}, inst_i[31:20]};   // 指令执行需要立即数,有符号扩展
                            wd_o        <= rd;                                  // 目的寄存器地址
                            instvalid   <= `InstValid;                          // ori 指令有效指令
                        end 
                        `INST_ANDI: begin       // andi
                            wreg_o      <= `WriteEnable;                      
                            aluop_o     <= `EXE_AND;                           
                            alusel_o    <= `EXE_RES_LOGIC;                    
                            reg1_read_o <= `ReadEnable;                         
                            reg2_read_o <= `ReadDisable;                       
                            imm_2       <= {{20{inst_i[31]}}, inst_i[31:20]}; 
                            wd_o        <= rd;                                  
                            instvalid   <= `InstValid;
                        end
                        `INST_SLLI: begin       // slli
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_SLL;   
                            alusel_o    <= `EXE_RES_SHIFT; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadDisable;    
                            imm_2       <= {27'b0, inst_i[24:20]}; 
                            wd_o        <= rd;                 
                            instvalid   <= `InstValid;
                        end
                        `INST_SRI: begin       // srli , srai
                            wreg_o      <= `WriteEnable;
                            if (inst_i[30] == 1'b0) begin
                                aluop_o     <= `EXE_SRL; 
                            end else begin
                                aluop_o     <= `EXE_SRA;
                            end                      
                            alusel_o    <= `EXE_RES_SHIFT;                    
                            reg1_read_o <= `ReadEnable;                         
                            reg2_read_o <= `ReadDisable;                       
                            imm_2       <= {27'b0, inst_i[24:20]}; 
                            wd_o        <= rd;                                  
                            instvalid   <= `InstValid;
                        end
                        default:  begin
                            instvalid   <= `InstInvalid;
                        end
                    endcase 
                end 
                
                `INST_R_TYPE: begin
                    case (funct3)
                        `INST_ADD: begin        // add , sub
                            wreg_o      <= `WriteEnable;
                            if (inst_i[30] == 1'b0) begin
                                aluop_o     <= `EXE_ADD; 
                            end else begin
                                aluop_o     <= `EXE_SUB;
                            end                      
                            alusel_o    <= `EXE_RES_ARITH; 
                            reg1_read_o <= `ReadEnable; 
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end 
                        `INST_SLL: begin        // sll
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_SLL;   
                            alusel_o    <= `EXE_RES_SHIFT; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable; 
                            instvalid   <= `InstValid;
                        end
                        `INST_SLT: begin        // slt
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_SLT;   
                            alusel_o    <= `EXE_RES_COMPARE; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable;                   
                            instvalid   <= `InstValid;
                        end
                        `INST_SLTU: begin       // sltu
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_SLTU;   
                            alusel_o    <= `EXE_RES_COMPARE; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable; 
                            instvalid   <= `InstValid;
                        end
                        `INST_XOR : begin       // xor
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_XOR;   
                            alusel_o    <= `EXE_RES_LOGIC; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable; 
                            instvalid   <= `InstValid;
                        end
                        `INST_SRL : begin       // srl ,sra 
                            if (inst_i[30] == 1'b0) begin
                                aluop_o     <= `EXE_SRL; 
                            end else begin
                                aluop_o     <= `EXE_SRA;
                            end                      
                            wreg_o      <= `WriteEnable;
                            alusel_o    <= `EXE_RES_SHIFT; 
                            reg1_read_o <= `ReadEnable; 
                            reg2_read_o <= `ReadEnable;
                            instvalid   <= `InstValid;
                        end
                        `INST_OR : begin        // or
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_OR;   
                            alusel_o    <= `EXE_RES_LOGIC; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable; 
                            instvalid   <= `InstValid;
                        end
                        `INST_AND: begin        // and
                            wreg_o      <= `WriteEnable; 
                            aluop_o     <= `EXE_AND;   
                            alusel_o    <= `EXE_RES_LOGIC; 
                            reg1_read_o <= `ReadEnable;  
                            reg2_read_o <= `ReadEnable; 
                            instvalid   <= `InstValid;
                        end
                        default: begin
                            wreg_o      <= `WriteDisable;
                            wd_o        <= `NOPRegAddr;
                            reg1_addr_o <= `NOPRegAddr;
                            reg2_addr_o <= `NOPRegAddr;
                            instvalid   <= `InstInvalid;
                        end
                    endcase
                end
                `INST_F_TYPE: begin             // fence
                    wreg_o      <= `WriteDisable;
                    wd_o        <= `NOPRegAddr;
                    reg1_addr_o <= `NOPRegAddr;
                    reg2_addr_o <= `NOPRegAddr;
                end
                
                `INST_CSR_TYPE: begin
                    case (funct3) 
                        `INST_CSRRW: begin
                            aluop_o         <= `EXE_CSRRW;
                            alusel_o        <= `EXE_RES_CSR;
                            wreg_o          <= `WriteEnable;
                            wd_o            <= rd;
                            reg1_read_o     <= `ReadEnable;
                            reg2_read_o     <= `ReadDisable;
                            wcsr_reg_o      <= `WriteEnable;
                            csr_reg_addr_o  <= {20'h0, inst_i[31:20]};
                            wd_csr_reg_o    <= {20'h0, inst_i[31:20]};
                            instvalid   <= `InstValid;
                        end
                        `INST_CSRRS: begin
                            aluop_o         <= `EXE_CSRRS;
                            alusel_o        <= `EXE_RES_CSR;
                            wreg_o          <= `WriteEnable;
                            wd_o            <= rd;
                            reg1_read_o     <= `ReadEnable;
                            reg2_read_o     <= `ReadDisable;
                            wcsr_reg_o      <= `WriteEnable;
                            csr_reg_addr_o  <= {20'h0, inst_i[31:20]};
                            wd_csr_reg_o    <= {20'h0, inst_i[31:20]};
                            instvalid   <= `InstValid;
                        end
                        `INST_CSRRC: begin
                            aluop_o         <= `EXE_CSRRC;
                            alusel_o        <= `EXE_RES_CSR;
                            wreg_o          <= `WriteEnable;
                            wd_o            <= rd;
                            reg1_read_o     <= `ReadEnable;
                            reg2_read_o     <= `ReadDisable;
                            wcsr_reg_o      <= `WriteEnable;
                            csr_reg_addr_o  <= {20'h0, inst_i[31:20]};
                            wd_csr_reg_o    <= {20'h0, inst_i[31:20]};
                            instvalid   <= `InstValid;
                        end
                        `INST_CSRRWI: begin
                            aluop_o         <= `EXE_CSRRW;
                            alusel_o        <= `EXE_RES_CSR;
                            wreg_o          <= `WriteEnable;
                            wd_o            <= rd;
                            reg1_read_o     <= `ReadDisable;
                            reg2_read_o     <= `ReadDisable;
                            wcsr_reg_o      <= `WriteEnable;
                            csr_reg_addr_o  <= {20'h0, inst_i[31:20]};
                            wd_csr_reg_o    <= {20'h0, inst_i[31:20]};
                            imm_1           <= {27'h0, inst_i[19:15]};
                            instvalid   <= `InstValid;
                        end
                        `INST_CSRRSI: begin
                            aluop_o         <= `EXE_CSRRS;
                            alusel_o        <= `EXE_RES_CSR;
                            wreg_o          <= `WriteEnable;
                            wd_o            <= rd;
                            reg1_read_o     <= `ReadDisable;
                            reg2_read_o     <= `ReadDisable;
                            wcsr_reg_o      <= `WriteEnable;
                            csr_reg_addr_o  <= {20'h0, inst_i[31:20]};
                            wd_csr_reg_o    <= {20'h0, inst_i[31:20]};
                            imm_1           <= {27'h0, inst_i[19:15]};
                            instvalid   <= `InstValid;
                        end
                        `INST_CSRRCI: begin
                            aluop_o         <= `EXE_CSRRC;
                            alusel_o        <= `EXE_RES_CSR;
                            wreg_o          <= `WriteEnable;
                            wd_o            <= rd;
                            reg1_read_o     <= `ReadDisable;
                            reg2_read_o     <= `ReadDisable;
                            wcsr_reg_o      <= `WriteEnable;
                            csr_reg_addr_o  <= {20'h0, inst_i[31:20]};
                            wd_csr_reg_o    <= {20'h0, inst_i[31:20]};
                            imm_1           <= {27'h0, inst_i[19:15]};
                            instvalid   <= `InstValid;
                        end
                        default: begin
                            wreg_o          <= `WriteDisable;
                            wcsr_reg_o      <= `WriteDisable;
                            wd_o            <= `NOPRegAddr;
                            csr_reg_addr_o  <= `ZeroWord;
                            wd_csr_reg_o    <= `ZeroWord;
                            reg1_addr_o     <= `NOPRegAddr;
                            reg2_addr_o     <= `NOPRegAddr;
                        end
                    endcase     // case csr funct3
                end

                default: begin
                    wreg_o      <= `WriteDisable;
                    wd_o        <= `NOPRegAddr;
                    reg1_addr_o <= `NOPRegAddr;
                    reg2_addr_o <= `NOPRegAddr;
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
            reg1_loadralate <= `NoStop;
        if (rst == `RstEnable) begin
            reg1_o  <= `ZeroWord;
        end else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1) begin
            reg1_loadralate <= `Stop;          
        end else if ((reg1_read_o == 1'b1) && (reg1_addr_o == 5'b00000)) begin
            reg1_o  <= `ZeroWord;
        end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
            reg1_o  <= ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
            reg1_o  <= mem_wdata_i;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o  <= reg1_data_i;         // regfile port 1 output data
        end else if (reg1_read_o == 1'b0) begin
            reg1_o  <= imm_1;                 // 立即数
        end else begin
            reg1_o  <= `ZeroWord;
        end
        
    end

    // 给 reg2_o 赋值的过程增加了两种情况：
    // 1. 如果 Regfile 模块读端口 2 要读取的寄存器就是执行阶段要写的目的寄存器，那么直接把执行阶段的结果 ex_wdata_i 作为 reg2_o 的值
    // 2. 如果 Regfile 模块读端口 2 要读取的寄存器就是访存阶段要写的目的寄存器，那么直接把访存阶段的结果 mem_wdata_i 作为 reg2_o 的值

    // 确定运算的源操作数 2
    always @ (*) begin
        reg2_loadralate <= `NoStop;
        if (rst == `RstEnable) begin
            reg2_o  <= `ZeroWord;
        end else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1) begin
            reg2_loadralate <= `Stop;  
        end else if ((reg2_read_o == 1'b1) && (reg2_addr_o == 5'b00000)) begin
            reg2_o  <= `ZeroWord;
        end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
            reg2_o  <= ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
            reg2_o  <= mem_wdata_i;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o  <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o  <= imm_2;
        end else begin
            reg2_o  <= `ZeroWord;
        end
    end


endmodule // id

