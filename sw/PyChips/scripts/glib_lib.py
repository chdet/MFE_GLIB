########################################
# library calls
########################################
from PyChipsUser import *
########################################



########################################
# define glib object
########################################
glibAddrTable = AddressTable("./glibAddrTable.dat")
f = open('./ipaddr.dat', 'r')
ipaddr = f.readline()
f.close()
glib = ChipsBusUdp(glibAddrTable, ipaddr, 50001)
########################################



########################################
def i2c(slave_addr, wr, reg_addr, wrdata, mem=0, m16b=0, debug=0, max_attempts=10):
########################################
	comm    = m16b*(2**25) + mem*(2**24) + wr*(2**23) + slave_addr *(2**16) + reg_addr *(2**8) + wrdata
	
	glib.write("i2c_command", comm) 				# strobe low
	glib.write("i2c_command", comm | 0x80000000) # strobe high
	
	status	 = "busy"
	attempts = 0
	rddata   = 0xff
	
	while (status == "busy" and attempts <= max_attempts):
		i2c_status = glib.read("i2c_reply_status")
		attempts = attempts +1
		#
		if (i2c_status==1):	
			status = "done"
			rddata = glib.read("i2c_reply_8b")
		elif 	(i2c_status==0):	
			status = "busy"
		else: 						
			status = "fail"	
		#
		if debug==1:
			if wr==1: print "-> slave",uInt8HexStr(slave_addr),"wrdata", uInt8HexStr(wrdata),status	
			if wr==0: print "-> slave",uInt8HexStr(slave_addr),"rddata", uInt8HexStr(rddata),status
		#
	
	return rddata
########################################