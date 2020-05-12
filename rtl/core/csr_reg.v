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

module csr_reg(
    input   wire                clk,
    input   wire                rst,

    // write
    input   wire                we_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire[`RegBus]       wdata_i,

    // read
    input   wire[`RegAddrBus]   raddr_i,

    output  reg[`RegBus]        rdata_o
);

    reg[`RegBus]                csr_mstatus;
    reg[`RegBus]                csr_misa;
    reg[`RegBus]                csr_mie;
    reg[`RegBus]                csr_mtvec;
    reg[`RegBus]                csr_mscratch;
    reg[`RegBus]                csr_mepc;
    reg[`RegBus]                csr_mcause;
    reg[`RegBus]                csr_mtval;
    reg[`RegBus]                csr_mip;
    reg[`DoubleRegBus]          csr_mcycle;       // user
//    reg[`RegBus]                csr_mcycleh;
    reg[`RegBus]                csr_mhartid;


    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            csr_mcycle  <= {`ZeroWord, `ZeroWord};
        end else begin
            csr_mcycle  <= csr_mcycle + 1'b1;
        end
    end

    // write  regs
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            csr_mstatus     <= `ZeroWord;
            csr_misa        <= (`MISA_RV32 | `MISA_RVI);
            csr_mie         <= `ZeroWord;
            csr_mtvec       <= `ZeroWord;
            csr_mscratch    <= `ZeroWord;
            csr_mepc        <= `ZeroWord;
            csr_mcause      <= `ZeroWord;
            csr_mtval       <= `ZeroWord;
            csr_mip         <= `ZeroWord;
            csr_mhartid     <= `ZeroWord;
        end else begin
            if (we_i == `WriteEnable) begin
                case (waddr_i[11:0])
                    `CSR_MSTATUS: begin
                        csr_mstatus <= wdata_i & `CSR_MSTATUS_MASK;
                    end
                    `CSR_MIE: begin
                        csr_mie <= wdata_i ;
                    end
                    `CSR_MTVEC: begin
                        csr_mtvec <= wdata_i & `CSR_MTVEC_MASK;
                    end
                    `CSR_MSCRATCH: begin
                        csr_mscratch <= wdata_i & `CSR_MSCRATCH_MASK;
                    end
                    `CSR_MEPC: begin
                        csr_mepc    <= wdata_i & `CSR_MEPC_MASK;
                    end
                    `CSR_MCAUSE: begin
                        csr_mcause <= wdata_i & `CSR_MCAUSE_MASK;
                    end
                    `CSR_MTVAL: begin
                        csr_mtval <= wdata_i & `CSR_MTVAL_MASK;
                    end
                    `CSR_MIP: begin
                        csr_mip <= wdata_i;
                    end
                    default: begin
                        
                    end
                endcase
            end else begin
                
            end
        end
    end

    // read regs
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            rdata_o <= `ZeroWord;
        end else begin
            case (raddr_i[11:0])
                `CSR_MSTATUS: begin
                    rdata_o <= csr_mstatus & `CSR_MSTATUS_MASK;
                end 
                `CSR_MSCRATCH: begin
                    rdata_o <= csr_mscratch & `CSR_MSCRATCH_MASK;
                end
                `CSR_MEPC: begin
                    rdata_o <= csr_mepc & `CSR_MEPC_MASK;
                end
                `CSR_MTVEC: begin
                    rdata_o <= csr_mtvec & `CSR_MTVEC_MASK;
                end
                `CSR_MTVAL: begin
                    rdata_o <= csr_mtval & `CSR_MTVAL_MASK;
                end
                `CSR_MCAUSE: begin
                    rdata_o <= csr_mcause & `CSR_MCAUSE_MASK;
                end
                `CSR_MIP: begin
                    rdata_o <= csr_mip ;
                end
                `CSR_MIE: begin
                    rdata_o <= csr_mie;
                end
                `CSR_MCYCLE: begin
                    rdata_o <= csr_mcycle[31:0];
                end
                `CSR_MCYCLEH: begin
                    rdata_o <= csr_mcycle[63:32];
                end
                `CSR_MHARTID: begin
                    rdata_o <= csr_mhartid;
                end
                default: begin
                    rdata_o <= `ZeroWord;
                end
            endcase
        end
    end


endmodule // csr_reg
