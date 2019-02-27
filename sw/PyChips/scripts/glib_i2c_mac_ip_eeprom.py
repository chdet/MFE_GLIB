from PyChipsUser import *
from time import sleep
from glib_lib import *
glibAddrTable = AddressTable("./glibAddrTable.dat")

load_nothing  = 0
load_mac_ip   = 3
load_mac_only = 1
load_ip_only  = 2
RegBuffer = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
RdxBuffer = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


mode = load_mac_only
IpMacAddrBuffer =  [0xf5,0x08,0x00,0x30,0xf1,0x00,0x1e,192,168,0,111,mode,0x00,0x00,0x00,0x00]

i2c_en    = 1
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)


i2c_str   = 1
i2c_m16   = 0
i2c_slv   = 0x56
reg_addr  = 0x00


wr     = 1
rd     = 0
unused = 0x00
reg    = 0x00

wren = 0
if wren==1:
	print
	for i in range(0,16):
		#  (slvaddr,r/w, regaddr, wrdata,             m, 16b, debug)
		i2c(i2c_slv, wr, reg+i  , IpMacAddrBuffer[i], 1,   0, 1)

rden = 1
if rden==1:
	print
	for i in range(0,16):
		#                 (slvaddr,r/w, regaddr, wrdata, m,16b, debug)
		RdxBuffer[i] = i2c(i2c_slv, wr, unused , reg+i,  0,  0, 0)
		RegBuffer[i] = i2c(i2c_slv, rd, unused , unused, 0,  0, 1)

print uInt32HexListStr(RegBuffer)

mac_addr = ':'.join([uInt8HexStr(RegBuffer[1]),uInt8HexStr(RegBuffer[2]),uInt8HexStr(RegBuffer[3]),uInt8HexStr(RegBuffer[4]),uInt8HexStr(RegBuffer[5]),uInt8HexStr(RegBuffer[6])])	
ip_addr  = '.'.join([str(RegBuffer[7]), str(RegBuffer[8]), str(RegBuffer[9]), str(RegBuffer[10])])	

if (mode==load_mac_ip): 
	print
	print 
	print "--================================--"
	print 
	print "-> set MAC addr to:", mac_addr
	print 
	print "-> set IP  addr to:", ip_addr
	print 
	print "--================================--"
	print

if (mode==load_mac_only): 
	print
	print 
	print "--================================--"
	print 
	print "-> set MAC addr to:", mac_addr
	print 
	print "--================================--"
	print

if (mode==load_ip_only): 
	print
	print 
	print "--================================--"
	print 
	print "-> set MAC addr to:", mac_addr
	print 
	print "--================================--"
	print

#print
#print "-> disabling i2c controller "
#glib.write("i2c_settings", i2c_ctrl_disable)	

i2c_en    = 0
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)

#print
#print "-> done"
#print
#print "--=======================================--"
#print 
#print
