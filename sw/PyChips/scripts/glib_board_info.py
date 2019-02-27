from PyChipsUser import *
glibAddrTable = AddressTable("./glibAddrTable.dat")
import os

########################################
# IP address
########################################
f = open('./ipaddr.dat', 'r')
ipaddr = f.readline()
f.close()
glib = ChipsBusUdp(glibAddrTable, ipaddr, 50001)
print
print "--=======================================--"
print "  Opening GLIB with IP", ipaddr
print "--=======================================--"
print
########################################
chipsLog.setLevel(logging.DEBUG)    # Verbose logging (see packets being sent and received)
print
print "--=======================================--"
print "-> BOARD INFORMATION"
print "--=======================================--"
print
brd_char 	= ['w','x','y','z']
brd_char[0] = chr(glib.read("board_id_char1"))
brd_char[1] = chr(glib.read("board_id_char2"))
brd_char[2] = chr(glib.read("board_id_char3"))
brd_char[3] = chr(glib.read("board_id_char4"))

print
board_id = ''.join([brd_char[0],brd_char[1],brd_char[2],brd_char[3]])	
print "-> board type  :", board_id




sys_char 	= ['w','x','y','z']
sys_char[0] = chr(glib.read("sys_id_char1"))
sys_char[1] = chr(glib.read("sys_id_char2"))
sys_char[2] = chr(glib.read("sys_id_char3"))
sys_char[3] = chr(glib.read("sys_id_char4"))

print
sys_id = ''.join([sys_char[0],sys_char[1],sys_char[2],sys_char[3]])	
print "-> system type :", sys_id

ver_major = glib.read("ver_major")
ver_minor = glib.read("ver_minor")
ver_build = glib.read("ver_build")
print
ver = '.'.join([str(ver_major),str(ver_minor),str(ver_build)])	
print "-> version nbr :", ver

yyyy  = 2000+glib.read("firmware_yy")
mm  = glib.read("firmware_mm")
dd  = glib.read("firmware_dd")

print
date = '/'.join([str(dd),str(mm),str(yyyy)])	
print "-> sys fw date :", date


mac    = ['00','00','00','00','00','00']
mac[5] = uInt8HexStr(glib.read("mac_b1"))
mac[4] = uInt8HexStr(glib.read("mac_b2"))
mac[3] = uInt8HexStr(glib.read("mac_b3"))
mac[2] = uInt8HexStr(glib.read("mac_b4"))
mac[1] = uInt8HexStr(glib.read("mac_b5"))
mac[0] = uInt8HexStr(glib.read("mac_b6"))
mac_addr = ':'.join([mac[5],mac[4],mac[3],mac[2],mac[1],mac[0]])	

sn     = ['00','00','00','00','00','00']
sn[5] = uInt8HexStr(glib.read("hw_id_b1"))
sn[4] = uInt8HexStr(glib.read("hw_id_b2"))
sn[3] = uInt8HexStr(glib.read("hw_id_b3"))
sn[2] = uInt8HexStr(glib.read("hw_id_b4"))
sn[1] = uInt8HexStr(glib.read("hw_id_b5"))
sn[0] = uInt8HexStr(glib.read("hw_id_b6"))
hw_id = '-'.join([sn[5],sn[4],sn[3],sn[2],sn[1],sn[0]])	


          
#####################################################################
os.system('glib_i2c_mac_ip_status.py')
#####################################################################
print
print
print "-> -----------------"
print "-> BOARD STATUS     "
print "-> -----------------"
print "-> sfp1 absent       :", glib.read("glib_sfp1_mod_abs")
print "-> sfp1 rxlos        :", glib.read("glib_sfp1_rxlos")
print "-> sfp1 txfault      :", glib.read("glib_sfp1_txfault")
print "-> sfp2 absent       :", glib.read("glib_sfp2_mod_abs")
print "-> sfp2 rxlos        :", glib.read("glib_sfp2_rxlos")
print "-> sfp2 txfault      :", glib.read("glib_sfp2_txfault")
print "-> sfp3 absent       :", glib.read("glib_sfp3_mod_abs")
print "-> sfp3 rxlos        :", glib.read("glib_sfp3_rxlos")
print "-> sfp3 txfault      :", glib.read("glib_sfp3_txfault")
print "-> sfp4 absent       :", glib.read("glib_sfp4_mod_abs")
print "-> sfp4 rxlos        :", glib.read("glib_sfp4_rxlos")
print "-> sfp4 txfault      :", glib.read("glib_sfp4_txfault")
print "-> ethphy interrupt  :", glib.read("gbe_int")
print "-> fmc1 presence     :", glib.read("fmc1_present")
print "-> fmc2 presence     :", glib.read("fmc2_present")
print "-> fpga reset state  :", glib.read("fpga_reset")
print "-> cdce locked       :", glib.read("cdce_lock")
print "-> cdce locked       :", glib.read("cdce_lock")

amc_slot = glib.read("v6_cpld") & 0x0f

print "-> cpld bus state    :", uInt8HexStr(glib.read("v6_cpld"))
if ((amc_slot>0) and (amc_slot<13)): 
	print "-> amc slot #        :", amc_slot
else:	
	print "-> amc slot #        :",amc_slot,"[not in crate]"

print "-> mac address (ipb) :", mac_addr
print "-> serial nbr  (ipb) :", hw_id   

print
print "--=======================================--"
print
