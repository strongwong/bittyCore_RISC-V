# bittyCore_RISC-V

bittyCore 是采用 Verilog 语言编写的 32 位 RISC-V 内核，支持 RV32I 指令集和 5 级流水线。

bittyCore 已完成模型联合仿真测试，并通过了 RISC-V 官方 RV32I ISA 指令集测试。

**[English](README.md)**

项目目录说明:

```bash
├─rtl           
│  ├─core       # bittyCore verilog 源码
│  └─sim        # 仿真顶层文件及目录
└─tools         # Windows 和 Linux 下的仿真脚本文件以及 filelist
```


克隆项目并进入项目文件夹

```git
git clone https://github.com/strongwong/bittyCore_RISC-V.git
cd bittyCore_RISC-V
```

# 使用 Icarus Verilog Simulator 仿真

## Windows

在 windows 下安装 iverilog， 下载地址：[http://bleyer.org/icarus/](http://bleyer.org/icarus/)

安装时选择将执行文件夹添加到环境变量

![](https://s1.ax1x.com/2020/05/04/Y9OIVU.png)

执行仿真脚本

```cmd
.\tools\build.bat
```

## Linux

ubuntu:

安装 iverilog

```bash
sudo apt update
sudo apt install iverilog
```

执行仿真脚本

```bash
chmod +x ./tools/build.sh
./tools/build.sh
```

# About

bittyCore is powered by [VeriMake](https://verimake.com/)
