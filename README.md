# bittyCore_RISC-V
This is a bitty CPU core of risc-v architecture, which is currently under development.

克隆项目并进入项目文件夹

```git
git clone https://github.com/strongwong/bittyCore_RISC-V.git
cd bittyCore_RISC-V
```

# Icarus Verilog Simulator

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
