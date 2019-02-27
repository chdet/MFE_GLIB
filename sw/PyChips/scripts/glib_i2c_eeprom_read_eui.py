from PyChipsUser import *
from glib_lib import *
glibAddrTable = AddressTable("./glibAddrTable.dat")


########################################
# IP address
########################################
f = open('./ipaddr.dat', 'r')
ipaddr = f.readline()
f.close()
glib = ChipsBusUdp(glibAddrTable, ipaddr, 50001)
########################################

i2c_eeprom_reg_address  = [0xFA,0xFB,0xFC,0xFD,0xFE,0xFF] # see 24AA025E48 manual
RegBuffer = [0,0,0,0,0,0]
RdxBuffer = [0,0,0,0,0,0]

i2c_en    = 1
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)

i2c_str   = 1
i2c_m16   = 0
i2c_slv   = 0x56

wr = 1
rd = 0
unused = 0x00
reg = 0xfa

for i in range(0,6):
	#                 (slvaddr,r/w, regaddr, wrdata, m,16, debug)
	RdxBuffer[i] = i2c(0x56   , wr, unused , reg+i )
	RegBuffer[i] = i2c(0x56   , rd, unused , unused)

print
print "-> hardware ID :",uInt8HexStr(RegBuffer[0]),uInt8HexStr(RegBuffer[1]),uInt8HexStr(RegBuffer[2]),uInt8HexStr(RegBuffer[3]),uInt8HexStr(RegBuffer[4]),uInt8HexStr(RegBuffer[5])	

#print "-> disabling i2c controller "
#glib.write("i2c_settings", i2c_ctrl_disable)	

i2c_en    = 0
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)