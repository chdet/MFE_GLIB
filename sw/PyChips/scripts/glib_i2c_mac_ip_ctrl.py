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
#print
#print "--=======================================--"
#print "  Opening GLIB with IP", ipaddr
#print "--=======================================--"
########################################
# i2c_settings        	0000000d    ffffffff     1     1
  # i2c_enable          0000000d    00000800     1     1
  # i2c_bus_select      0000000d    00000400     1     1
  # i2c_prescaler       0000000d    000003ff     1     1

# i2c_command         	0000000e    ffffffff     1     1
  # i2c_strobe 	  		0000000e    80000000     1     1 
  # i2c_mode16 	  		0000000e    02000000     1     1 
  # i2c_write 	  		0000000e    00800000     1     1 
  # i2c_slvaddr_7b  	0000000e    007f0000     1     1 
  # i2c_wrdata  		0000000e    000000ff     1     1 

#  i2c_reply			0000000f    ffffffff     1     0
	# i2c_reply_status  0000000f    0c000000     1     0
	# i2c_reply_8b		0000000f    000000ff     1     0
	# i2c_reply_16b		0000000f    0000ffff     1     0
########################################



load_mac_ip   = 3
load_mac_only = 1
load_ip_only  = 2
RegBuffer = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


mode = load_mac_only

IpMacAddrBuffer =  [0xf5,0x80,0x00,0x30,0xf1,0x00,0xff,192,168,0,163, mode ,0x00,0x00,0x00,0x00]

i2c_en    = 1
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)

i2c_str   = 1
i2c_m16   = 0
i2c_slv   = 0x7a
reg_addr  = 0x00

wren = 1
rden = 1


if (wren==1):
	for i in range(0,16):
	
		# set register address
		# ----------------------------------------
		i2c_ral   = 1
		i2c_wr    = 1 # do an i2c write transaction
		i2c_command_value = i2c_str*(2**31)+i2c_m16*(2**25)+i2c_ral*(2**24)+i2c_wr*(2**23)+i2c_slv*(2**16)+(reg_addr+i)*(2**8)+IpMacAddrBuffer[i] #(wdata+i)
		glib.write("i2c_command", i2c_command_value)
		reply = glib.read("i2c_reply")
		##########################################
		# check i2c transaction status
		##########################################
		status = glib.read("i2c_reply_status")
		#print uInt32HexStr(glib.read("i2c_reply"))
		if (status!=1): print ("i2c_error")
		##########################################
		sleep(0.025)

if (rden==1):
	for i in range(0,16):
	
		# set register address
		# ----------------------------------------
		i2c_wr     = 1 # do an i2c write transaction
		i2c_ral    = 0 
		i2c_command_value = i2c_str*(2**31)+i2c_m16*(2**25)+i2c_ral*(2**24)+i2c_ral   *(2**24)+i2c_wr*(2**23)+i2c_slv*(2**16)+(reg_addr+i)
		glib.write("i2c_command", i2c_command_value)
		reply = glib.read("i2c_reply") # this is used as delay
		reply = glib.read("i2c_reply") # this is used as delay
		reply = glib.read("i2c_reply") # this is used as delay
		reply = glib.read("i2c_reply") # this is used as delay
		reply = glib.read("i2c_reply") # this is used as delay
		reply = glib.read("i2c_reply")
		##########################################
		# check i2c transaction status
		##########################################
		status = glib.read("i2c_reply_status")
		#print uInt32HexStr(glib.read("i2c_reply"))
		if (status!=1): print ("i2c_error")
		##########################################
			
		# read register contents
		# ----------------------------------------
		i2c_wr     = 0 # do an i2c read transaction
		i2c_ral    = 0 
		i2c_command_value = i2c_str*(2**31)+i2c_m16*(2**25)+i2c_ral*(2**24)+i2c_wr*(2**23)+i2c_slv*(2**16)
		glib.write("i2c_command", i2c_command_value)
		RegBuffer[i] = glib.read("i2c_reply_8b")
		##########################################
		# check i2c transaction status
		##########################################
		status = glib.read("i2c_reply_status")
		#print uInt32HexStr(glib.read("i2c_reply"))
		if (status!=1): print ("i2c_error")
		##########################################	

#print uInt32HexListStr(RegBuffer)
#print uInt32HexListStr(AckBuffer)

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

	
	
sleep(0.25)

# clear strobes
reg_addr  = 0x0b
wdata	  = 0x00
# ----------------------------------------
# set register address
# ----------------------------------------
i2c_ral   = 1
i2c_wr    = 1 # do an i2c write transaction
i2c_command_value = i2c_str*(2**31)+i2c_m16*(2**25)+i2c_ral*(2**24)+i2c_wr*(2**23)+i2c_slv*(2**16)+reg_addr*(2**8)+wdata #(wdata+i)
glib.write("i2c_command", i2c_command_value)
reply = glib.read("i2c_reply")
##########################################
# check i2c transaction status
##########################################
status = glib.read("i2c_reply_status")
#print uInt32HexStr(glib.read("i2c_reply"))
if (status!=1): print ("i2c_error")
##########################################
sleep(0.025)

print "=> clear strobe(s)"
print

print
print "-> disabling i2c controller "
glib.write("i2c_settings", i2c_ctrl_disable)	
i2c_en    = 0
i2c_sel   = 0
i2c_presc = 500
i2c_settings_value = i2c_en*(2**15) + i2c_sel*(2**10) + i2c_presc
glib.write("i2c_settings", i2c_settings_value)
print
print "-> done"
print
print "--=======================================--"
print 
print
