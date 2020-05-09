    .section .text;
    .align  2;
    .globl _start;

_start:
    la sp, _sp
    li x26, 0x00
    li x27, 0x00

    call main

    li x26, 0x01

loop:
    j loop
