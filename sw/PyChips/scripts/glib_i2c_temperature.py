from PyChipsUser import *
from time import *
from glib_lib import *

glibAddrTable = AddressTable("./glibAddrTable.dat")

f = open('./ipaddr.dat', 'r')
ipaddr = f.readline()
f.close()
glib = ChipsBusUdp(glibAddrTable, ipaddr, 50001)
print
print "--=======================================--"
print "  Opening GLIB with IP", ipaddr
print "--=======================================--"


#######
debug=0
#######


i2c_ctrl_disable = 0x00000000 
i2c_ctrl_enable  = 0x000081f4

fpga_temp_sensor_slave_addr  = 0x2A
front_temp_sensor_slave_addr = 0x1A
rear_temp_sensor_slave_addr  = 0x4E

fpga_temp_sensor_reg_addr    = 0x01 # remote temperature register
front_temp_sensor_reg_addr   = 0x00 # local  temperature register
rear_temp_sensor_reg_addr    = 0x00 # local  temperature register

slave_addr  = [fpga_temp_sensor_slave_addr, front_temp_sensor_slave_addr, rear_temp_sensor_slave_addr]
wrdata      = [fpga_temp_sensor_reg_addr,   front_temp_sensor_reg_addr,   rear_temp_sensor_reg_addr] 
rddata      = [0,0,0]
status      = ["xxxx","yyyy","zzzz","aaaa","bbbb","cccc"]

###################################################
# enable i2c
###################################################
print
print "-> enabling i2c controller  "
glib.write("i2c_settings", i2c_ctrl_enable)



###################################################
# read sensors
###################################################
for i in range (0,3):

	wr = 1
	i2c(slave_addr, wr, unused, wrdata[i])
	wr = 0
	rddata[i] = i2c(slave_addr, wr, unused, unused)
###################################################



###################################################
# print data out
###################################################
location    = ["fpga ", "front", "rear "]
temperature_value = ["positive", "positive", "positive"]
print
print "--=============--"
print "-> Temperatures"
print "--=============--"
for i in range (0,3):
	# temperature value is signed 8-bit 
	if (rddata[i]<128): 
		temperature = rddata[i]
	else: 
		temperature = rddata[i]-256
		temperature_value = "negative" 
	#
	print "->", location[i],temperature,"deg C"
print "--=============--"
if status!=["done","done","done","done","done","done"]: 
	print "-> ERROR: transaction(s) failed"
elif temperature_value!=["positive", "positive", "positive"]: 
	print "-> ERROR: temperature(s) out of range"
else:
	print "-> DONE"
print "--=============--"
###################################################



###################################################
# disable i2c
###################################################
print
print "-> disabling i2c controller "
glib.write("i2c_settings", i2c_ctrl_disable)
print
print "--=======================================--"
print 
print
