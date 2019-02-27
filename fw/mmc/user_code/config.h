/*
 * config.h
 *
 * Created: 19/03/2015 18:20:14
 *  Author: jumendez
 */ 


#ifndef CONFIG_H_
#define CONFIG_H_

#include "../../../../../../mmc_v2/Release_1/MMC/iodeclaration.h"
#include "../../../../../../mmc_v2/Release_1/MMC/led.h"
#include "../../../../../../mmc_v2/Release_1/MMC/ipmi_if.h"

/** Product information */
	#define IPMI_MSG_MANU_ID_LSB 0x60   //NOTE: Manufacturer identification is handled by http://www.iana.org/assignments/enterprise-numbers
	#define IPMI_MSG_MANU_ID_B2  0x00	//CERN IANA ID = 0x000060
	#define IPMI_MSG_MANU_ID_MSB 0x00

	#define IPMI_MSG_PROD_ID_LSB 0x35
	#define IPMI_MSG_PROD_ID_MSB 0x12

	#define MMC_FW_REL_MAJ       1                  // major firmware release version ( < 128 )
	#define MMC_FW_REL_MIN       0                  // minor firmware release version ( < 256 )

	#define FRU_NAME			"GLIB"

/** User GPIO initialization */
	//#define GPIO0_DIR		OUTPUT
	//#define GPIO1_DIR		OUTPUT
	//#define GPIO2_DIR		OUTPUT
	//#define GPIO3_DIR		OUTPUT
	//#define GPIO4_DIR		OUTPUT
	//#define GPIO5_DIR		OUTPUT
	//#define GPIO6_DIR		OUTPUT
	//#define GPIO7_DIR		OUTPUT
	//#define GPIO8_DIR		OUTPUT
	//#define GPIO9_DIR		OUTPUT
	//#define GPIO10_DIR	OUTPUT
	//#define GPIO11_DIR	OUTPUT
	//#define GPIO12_DIR	OUTPUT

/** User ADC initialization */
	//#define ENABLE_ADC1
	//#define ENABLE_ADC2
	//#define ENABLE_ADC3
	//#define ENABLE_ADC4
	//#define ENABLE_ADC5
	//#define ENABLE_ADC6
	//#define ENABLE_ADC7

/** OEM & Controller specific commands */
	#define ENABLE_OEM
	//#define ENABLE_CONTROLLER_SPECIFIC
		
/** PAYLOAD CONFIGURATION */
	/** Define power on sequence (Mandatory) */
	#define POWER_ON_SEQ												\
		SET_PAYLOAD_SIGNAL(LOCAL_DCDC_ENABLE)							\
		SET_PAYLOAD_SIGNAL(LOCAL_REG_ENABLE)							\
		CUSTOM_C(  \
			u08 amc_slot = (((get_address() - 0x70) >> 1)) & 0x0f;	\
			PORTA = amc_slot << 2 ; /* forwards the amc_slot to the FPGA through the CPLD (RTM[3:0]) */ \
			DDRA  = 0x3C; /* PA[5:2], (RTM lines) set as outputs */ \
			/*Port E: UUUUGGNN */ \
			DDRE  = 0x80; /* PE7 -> i2c bridge enable pin -> set as output */ \
			PORTE = 0x00; /* PE7 -> i2c bridge enable pin -> 0 (disconnect mmc/fpga i2c buses) */ \
		)							
	
	/** Define power OFF sequence (Mandatory)	*/
	#define POWER_OFF_SEQ												\
		CLEAR_PAYLOAD_SIGNAL(LOCAL_DCDC_ENABLE)							\

	/** Define reboot sequence (Optional) */
	#define REBOOT_SEQ													\
		CLEAR_PAYLOAD_SIGNAL(LOCAL_DCDC_ENABLE)							\
		DELAY(500)														\
		SET_PAYLOAD_SIGNAL(LOCAL_DCDC_ENABLE)							\
	
	/** Define warm reset sequence (Optional) */
		//#define WARM_RESET_SEQ			...

	/** Define cold reset sequence (Optional) */
		//#define COLD_RESET_SEQ					...


/** LED CONFIGURATION */
	/*
	#define AMC_USER_LED_CNT	1
	#define AMC_USER_LED_LIST									\
		{														\
			{	(LED ID 3 - must be removed)					\
				io_type: MMC_PORT,								\
				port:MMCPORT_E,									\
				pin:PE6,										\
				color: RED,										\
				init: INACTIVE,									\
				active: LOW,									\
				inactive: HIGH									\
			}													\
		}
	*/
		
/** CUSTOM ADDRESSES FOR BENCHTOP */
	#define CUSTOM_ADDR_LIST									\
		ADDR(0xF0, UNCONNECTED, UNCONNECTED, UNCONNECTED)
	
#endif /* CONFIG_H_ */