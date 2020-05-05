# bittyCore_RISC-V

bittyCore is a 32-bit RISC-V core written in verilog language, supporting RV32I instruction set and 5-stage pipeline.

This core has completed the model joint simulation test and passed the RISC-V official RV32I isa instruction set test.

**[中文](README_zh.md)**

Description of each directory in the project:

```bash
├─rtl           
│  ├─core       # bittyCore verilog source code
│  └─sim        # Simulation top-level files and directories
└─tools         # Simulation script files and filelist under Windows and Linux
```

Clone the project and enter the project folder

```git
git clone https://github.com/strongwong/bittyCore_RISC-V.git
cd bittyCore_RISC-V
```

# Icarus Verilog Simulator

Run the default simulation program.

## Windows 

Install `iverilog` under windows, download link：[http://bleyer.org/icarus/](http://bleyer.org/icarus/)

Choose at installation **" Add executable folder(s) to the user PATH "**

![](https://s1.ax1x.com/2020/05/04/Y9OIVU.png)

Run the simulation script

```cmd
.\tools\build.bat
```

## Linux

ubuntu:

install `iverilog`:

```bash
sudo apt update
sudo apt install iverilog
```

Run the simulation script:

```bash
chmod +x ./tools/build.sh
./tools/build.sh
```

# About

bittyCore is powered by [VeriMake](https://verimake.com/)
