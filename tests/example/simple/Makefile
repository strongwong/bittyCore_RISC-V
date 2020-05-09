ifndef CROSS_COMPILE
CROSS_COMPILE = riscv32-unknown-elf-
endif

RISCV_ARCH := rv32i
RISCV_ABI := ilp32

GCC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

export CROSS_COMPILE

CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles --std=gnu99 


# *************************************
# Rules of Compilation
# *************************************

all: sim simple.dump


simple.elf:
	$(GCC) $(CFLAGS) start.S main.c -Tlink.ld -o $@  

simple.bin: simple.elf
	$(OBJCOPY) -O binary $< $@

lo.mif: simple.bin
	rom2mif simple.bin hi.mif mh.mif ml.mif lo.mif

simple.dump: simple.elf
	$(OBJDUMP) --disassemble-all $< > $@

simple.hex: simple.elf
	$(OBJCOPY) -O verilog $< $@

inst_rom.data: simple.bin
#	rom2mif $< hi.mif mh.mif ml.mif lo.mif
	hexdump -e '"%08x\n"' -v $< > $@

sim: inst_rom.data
	./split_data.py
	cp -rf *.data  ../../../rtl/sim 

clean:
	rm -f simple.elf simple.hex simple.bin  simple.dump *.mif *.data *.o




