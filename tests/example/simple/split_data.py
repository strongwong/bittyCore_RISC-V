#!/usr/bin/python3
# -*- coding: UTF-8 -*-

inst_rom = open("inst_rom.data", "r")

inst_data0 = open("inst_data0.data", "w+")
inst_data1 = open("inst_data1.data", "w+")
inst_data2 = open("inst_data2.data", "w+")
inst_data3 = open("inst_data3.data", "w+")

for line in inst_rom:
	inst_data3.write(str(line[0:2]) + '\n')
	inst_data2.write(str(line[2:4]) + '\n')
	inst_data1.write(str(line[4:6]) + '\n')
	inst_data0.write(str(line[6:8]) + '\n')

inst_rom.close()
inst_data0.close()
inst_data1.close()
inst_data2.close()
inst_data3.close()

