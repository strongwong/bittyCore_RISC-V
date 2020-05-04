@echo off
set OUTPUT_PATH=.\rtl\sim
set OUTPUT_FILE=out.vvp
set TOP_MODULE=bitty_riscv_sopc_tb
set FILELIST=.\tools\filelist


iverilog -o %OUTPUT_PATH%\%OUTPUT_FILE% -DIVERILOG -s %TOP_MODULE% -f %FILELIST%

vvp %OUTPUT_PATH%\%OUTPUT_FILE%