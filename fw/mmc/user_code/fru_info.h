#ifndef FRU_INFO_H
#define FRU_INFO_H

#include "../../../../../../mmc_v2/Release_1/MMC/fru.h"
#include "../../../../../../mmc_v2/Release_1/MMC/languages.h"

/*********************************************
 * Common defines
 *********************************************/
#define LANG_CODE		ENGLISH
#define FRU_FILE_ID		"CoreFRU"	//Allows knowing the source of the FRU present in the memory

#define BOARD_INFO_AREA_ENABLE
#define PRODUCT_INFO_AREA_ENABLE
#define MULTIRECORD_AREA_ENABLE

/*********************************************
 * Board information area
 *********************************************/
#define BOARD_MANUFACTURER		"CERN"
#define	BOARD_NAME				"AMC GLIB v3"
#define BOARD_SN				"000000000000"
#define BOARD_PN				"407"
 
/*********************************************
 * Product information area
 *********************************************/
#define PRODUCT_MANUFACTURER	"CERN"
#define PRODUCT_NAME			"AMC GLIB devkit"
#define PRODUCT_PN				"w/ MMC 2015"
#define PRODUCT_VERSION			"FW:1.51/150615"
#define PRODUCT_SN				"000000000000"
#define PRODUCT_ASSET_TAG		""
 
/*********************************************
 * AMC: Point to point connectivity record
 *********************************************/
/*
#define POINT_TO_POINT_OEM_GUID_CNT				1
#define POINT_TO_POINT_OEM_GUID_LIST			\
	OEM_GUID(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)

#define AMC_POINT_TO_POINT_RECORD_CNT		5
#define AMC_POINT_TO_POINT_RECORD_LIST																		\
	GENERIC_POINT_TO_POINT_RECORD(0, PORT(0), ETHERNET, BASE_1G_BX, EXACT_MATCHES)							\
	GENERIC_POINT_TO_POINT_RECORD(1, PORT(4), PCIE, GEN1_NO_SSC, MATCHES_10)								\
	GENERIC_POINT_TO_POINT_RECORD(2, PORT(5), PCIE, GEN1_NO_SSC, MATCHES_10)								\
	GENERIC_POINT_TO_POINT_RECORD(3, PORT(6), PCIE, GEN1_NO_SSC, MATCHES_10)								\
	GENERIC_POINT_TO_POINT_RECORD(4, PORT(7), PCIE, GEN1_NO_SSC, MATCHES_10)		
*/

/**********************************************
 * PICMG: Module current record
 **********************************************/
#define MODULE_CURRENT_RECORD		 current_in_ma(3000)	//	current_in_ma(max_current_in_mA)
	
#endif