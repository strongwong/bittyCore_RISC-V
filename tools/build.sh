#!/bin/bash

export OUTPUT_PATH=./rtl/sim
export OUTPUT_FILE=out.vvp
export TOP_MODULE=bitty_riscv_sopc_tb
export FILELIST=./tools/filelist


iverilog -o $OUTPUT_PATH/$OUTPUT_FILE -DIVERILOG -s $TOP_MODULE -f $FILELIST

vvp $OUTPUT_PATH/$OUTPUT_FILE