# bittyCore_RISC-V

bittyCore is a 32-bit RISC-V core written in verilog language, supporting RV32I instruction set and 5-stage pipeline.

This core has completed the model joint simulation test and passed the RISC-V official RV32I isa instruction set test.

![bittyCore](https://s1.ax1x.com/2020/05/05/YFczdI.png)

**[中文](README_zh.md)**

Description of each directory in the project:

```bash
├─rtl           
│  ├─core       # bittyCore verilog source code
│  └─sim        # Simulation top-level files and directories
├─tests
│  └─example
│      └─simple # Simple test project code
└─tools         # Simulation script files and filelist under Windows and Linux
```

Clone the project and enter the project folder

```git
git clone https://github.com/strongwong/bittyCore_RISC-V.git
cd bittyCore_RISC-V
```

**If you have compiled a complete [toolchain for riscv](https://github.com/riscv/riscv-tools) 
Please skip the following commands.**
> ### build the toolchain on ubuntu 18:
> For well-known reasons, we provide a mirror of toolchain for a pure `rv32i` here。
>   - links：https://pan.baidu.com/s/160Iu03p4NvlcNUw18_msDQ  Extraction code：fv59 
> 
>   Make sure the mirror above is in the directory `/bittyCore_RISC-V`.Then the following commands will build the RISC-V GNU toolchain and libraries for a pure RV32I target, and install it in `/opt/riscv32i`:
> 
> ```bash
>   sudo mkdir -p /opt/riscv32i
>   sudo chown $USER /opt/riscv32i
>   sudo apt install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev git libexpat1-dev
>   sudo tar -zxvf riscv-gnu-toolchain-rv32i.tar.gz
>   sudo chown $USER riscv-gnu-toolchain-rv32i
>   cd riscv-gnu-toolchain-rv32i; mkdir build; cd build
>   ../configure --with-arch=rv32i --prefix=/opt/riscv32i
>   make -j$(nproc)
>```
>
> ### export PATH
> You can input the following at the end of profile use vi ~/.bashrc .
> ```bash
> export PATH="$PATH:/opt/riscv32i/bin"
> ```


# Icarus Verilog Simulator

Run the default simulation program.

## Linux

ubuntu:

install `iverilog`:

```bash
sudo apt update
sudo apt install iverilog
```

Run the default simulation script:

```bash
chmod +x ./tools/build.sh
./tools/build.sh
```

View the simulation waveform.
```bash
sudo apt install gtkwave
gtkwave ./rtl/sim/bitty_riscv_sopc_tb.vcd   # or gtkwave ./rtl/sim/bitty_riscv_sopc_tb.gtkw
```

If you want to run new simulation:
You can modify `"./tests/example/simple/main.c"` and then recompile.

```bash
cd ./tests/example/simple
make 
cd ../../../
./tools/build.sh
```

## Windows 

Install `iverilog` under windows, download link：[http://bleyer.org/icarus/](http://bleyer.org/icarus/)

Choose at installation **" Add executable folder(s) to the user PATH "**

![](https://s1.ax1x.com/2020/05/04/Y9OIVU.png)

Run the simulation script

```cmd
.\tools\build.bat
```

View the simulation waveform.
```cmd
gtkwave .\rtl\sim\bitty_riscv_sopc_tb.vcd     % or gtkwave .\rtl\sim\bitty_riscv_sopc_tb.gtkw %
```

# About

bittyCore is powered by [VeriMake](https://verimake.com/)
