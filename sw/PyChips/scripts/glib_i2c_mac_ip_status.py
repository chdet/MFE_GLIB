from PyChipsUser import *
from time import sleep
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

RdxBuffer = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
RegBuffer = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

i2c_en    = 1
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)


wr = 1
rd = 0
unused = 0x00
reg = 0x00

for i in range(0,16):
	#                 (slvaddr,r/w, regaddr, wrdata, m,16, debug)
	RdxBuffer[i] = i2c(0x7e   , wr, unused , reg+i )
	RegBuffer[i] = i2c(0x7e   , rd, unused , unused)
	
	
	
mac_addr = ':'.join([uInt8HexStr(RegBuffer[1]),uInt8HexStr(RegBuffer[2]),uInt8HexStr(RegBuffer[3]),uInt8HexStr(RegBuffer[4]),uInt8HexStr(RegBuffer[5]),uInt8HexStr(RegBuffer[6])])	
ip_addr  = '.'.join([str(RegBuffer[7]), str(RegBuffer[8]), str(RegBuffer[9]), str(RegBuffer[10])])	

mac_from_eep = RegBuffer[13] & 0x01
ip_from_eep  =(RegBuffer[13] & 0x02)/2
mac_from_slv = RegBuffer[14] & 0x01
ip_from_slv  =(RegBuffer[14] & 0x02)/2
mac_from_usr = RegBuffer[15] & 0x01
ip_from_usr  =(RegBuffer[15] & 0x02)/2
print
print "-> MAC address :", mac_addr
print
print "-> IP  address :", ip_addr
print
print "-> MAC from eep:", mac_from_eep
print "-> MAC from slv:", mac_from_slv
print "-> MAC from usr:", mac_from_usr
print "-> IP  from eep:", ip_from_eep
print "-> IP  from slv:", ip_from_slv
print "-> IP  from usr:", ip_from_usr

#print "-> disabling i2c controller "
#glib.write("i2c_settings", i2c_ctrl_disable)	

i2c_en    = 0
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)