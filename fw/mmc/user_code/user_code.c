//*****************************************************************************
// File Name    : user_code.c
//
// Author		: Markus Joos (markus.joos@cern.ch)
// Modified by	: Julian Mendez <julian.mendez@cern.ch>
//
// Description	: Implementation of use commands:
//					-	OEM function: mandatory
//					-	Controller specific function: optionnal, enabled with 
//						ENABLE_CONTROLLER_SPECIFIC in user_code.h
//*****************************************************************************

// Header file

#include <avr/io.h>
#include "../../../../../../mmc_v2/Release_1/MMC/i2csw.h"

#include "../../../../../../mmc_v2/Release_1/MMC/ipmi_if.h"	//Used for error code definitions
#include "../../../../../../mmc_v2/Release_1/MMC/payload.h"	//Used for user main function (payload activation/deactivation)

#include "config.h"

/** User main function */
u08 user_main(u08 addr){
	
	
	/*	
		manage_payload() function check the handle switch status and execute POWER_ON_SEQ on assertion
		and POWER_OFF_SEQ on de-assertion.
	*/
	while(1)
		manage_payload();	
	
	return 0x01;
}

/** IPMI OEM commands */
	u08 ipmi_oem_user(u08 command, u08 *iana, u08 *user_data, u08 data_size, u08 *buf, u08 *error)
	{
		//Note: You must not return more than 25 bytes

		//Check if this OEM command is supported by us.
		//The originator of the OEM command (see table 5.1 in the IPMI 1.5 spec will send a 3-byte IANA ID
		//If we recognise this ID we respond to the command. Otherwise we return an error code
		//The completion codes can be found in http://download.intel.com/design/servers/ipmi/IPMIv1_5rev1_1.pdf Table 5-2

		u08 oem_reply_size ;
	
		*error = IPMI_CC_OK;
	
		if (iana[0] != IPMI_MSG_MANU_ID_MSB || iana[1] != IPMI_MSG_MANU_ID_B2 || iana[2] != IPMI_MSG_MANU_ID_LSB)
		{
			*error = IPMI_CC_PARAM_OUT_OF_RANGE;
			return(0);             //Not for us
		}

		//===== RawI2cSend =======//
		if ((command==0x33) && (data_size>5) && (data_size<22))	// min_size =  6: 5-byte header +  1-byte payload
		{														// max_size = 21: 5-byte header + 16-byte payload
			u08  slave_addr    =   user_data[0] & 0x7f; // 7-bit slave_addr
			u08  sub_addr_size =   user_data[1];
			u16  sub_addr      =  (user_data[2] << 8) + user_data[3];
			u08  wrBuffer_size =   user_data[4] ; // number of bytes to write
			u08 *wrBuffer      = &(user_data[5]); // define a pointer (address) and initialize it with the address of the 5th element of the array user_data
		
			DDRE  = 0x80; PORTE = 0x80; // i2c bridge enable pin -> 1 (connect mmc/fpga i2c buses)
			SEND_I2C_VAL(slave_addr, sub_addr, sub_addr_size, wrBuffer_size, wrBuffer);
			DDRE  = 0x80; PORTE = 0x00;  // i2c bridge enable pin -> 0 (disconnect mmc/fpga i2c buses)
		
			oem_reply_size  = 3;	// default reply = 3-byte IANA number
		}

		//===== RawI2cReceive ====//
		else if ((command==0x34) && (data_size==5)) // 5-byte header only
		{
			u08  slave_addr    =   user_data[0] & 0x7f; // 7-bit slave_addr
			u08  sub_addr_size =   user_data[1];
			u16  sub_addr      =  (user_data[2] << 8) + user_data[3];
			u08  rdBuffer_size =   user_data[4] ; // number of bytes to read
			u08  rdBuffer[25];
			u08 *baseAddr = &rdBuffer[0]; // baseAddr is the address of the u08 type rbBuffer[0]

			DDRE  = 0x80; PORTE = 0x80; // i2c bridge enable pin -> 1 (connect mmc/fpga i2c buses)
			GET_I2C_VAL(slave_addr, sub_addr, sub_addr_size, rdBuffer_size, baseAddr);
			DDRE  = 0x80; PORTE = 0x00; // i2c bridge enable pin -> 0 (disconnect mmc/fpga i2c buses)
		
			oem_reply_size  = 3+rdBuffer_size;	// 3-byte IANA number + bytes read
		
			for (int i=0; i<rdBuffer_size;i++) {buf[i+3]=rdBuffer[i];} // read request reply
		}

		//===== else =======//
		else
		{
			*error = IPMI_CC_INV_CMD;
			return(0);	// default reply = 1-byte completion code + 3-byte IANA number
		}
	
		//=== OEM reply ===//
		buf[0] = IPMI_MSG_MANU_ID_MSB;   //We have to return our IANA ID as the first 3 bytes of the reply
		buf[1] = IPMI_MSG_MANU_ID_B2;
		buf[2] = IPMI_MSG_MANU_ID_LSB;
		// + buf[4:] for read requests only
	
		return(oem_reply_size);  //3 because we are returning 3 bytes.
	}

	
/** IPMI Controller Specific commands */
	/*
	u08 ipmi_controller_specific(u08 cmd, u08 *data, u08 data_len, u08 *buf, u08 *err){
		u08 rsp_length = 0;
	
		*error = IPMI_CC_OK;
	
		switch(command){
			case FRU_PROM_REVISION_CMD:	
				// ipmi_prom_version_change(user_data[0]);
				rsp_length = 0;
				break;
			
			case JTAG_CTRL_SET_CMD:	
				// ipmi_jtag_ctrl(rqs.data[0]);
				rsp_length = 0;
				break;
			
			case FPGA_JTAG_PLR_CMD:	
				// ipmi_fpga_jtag_plr_set(rqs.data[0]);
				rsp_length = 0;
				break;
			
			default:
				*error = IPMI_CC_INV_CMD;
		}
	
		return rsp_length;
	}
	*/