/*
 * sensors.h
 *
 * Created: 26/03/2015 22:22:20
 *  Author: jumendez
 */ 


#ifndef SENSORS_H_
#define SENSORS_H_

/** Sensors ID */

	// Hot swap sensor already defined as (Id: 0)
	// 12V sensor      already defined as (Id: 1)
	#define TEMPERATURE_SENSOR1	2
	#define TEMPERATURE_SENSOR2 3
	#define TEMPERATURE_SENSOR3 4


/** SDR repository */
	
	#define AMC0_RECORD                     /* LM82 IC7*/		                              \
	{																						  \
		0x00,								/*(Record ID: Filled by init)					*/\
		0x00,								/*(Record ID: Filled by init)					*/\
		0x51,								/*(SDR Version: 51h)							*/\
		0x01,								/*(Record type: 01h - full sensor)				*/\
		0x00,								/*(Record length: Filled by init)				*/\
		0x00,								/*(Sensor owner ID: Filled by init)				*/\
		0x00,								/*(Sensor owner LUN: 00h)						*/\
		TEMPERATURE_SENSOR1,				/*(Sensor number)								*/\
		0xc1,								/*(Entity ID: C1h - AMC)						*/\
		0x00,								/*(Entity Instance)								*/\
		0x7F,								/*(Sensor Initialization)						*/\
		0xFC,								/*(Sensor capabilities)							*/\
		TEMPERATURE,						/*(Sensor type)									*/\
		0x01,								/*(Event/Reading type code)						*/\
		0xFF,								/*(Assertion event mask (LSB))					*/\
		0x7F,								/*(Assertion event mask (MSB))					*/\
		0xFF,								/*(Deassertion event mask (LSB))				*/\
		0x7F,								/*(Deassertion event mask (MSB))				*/\
		0x00,								/*(Settable / Readable threshold mask (LSB))	*/\
		0x00,								/*(Settable / Readable threshold mask (MSB))	*/\
		0x80,								/*(Sensor unit: 80h - 2's complement (signed))	*/\
		0x01,								/*(Sensor unit 2 - Base unit)					*/\
		0x00,								/*(Sensor unit 3 - Modifier unit)				*/\
		0x00,								/*(Linearization: 00h - Linear)					*/\
		0x01,								/*(M)											*/\
		0x01,								/*(M, Tolerance)								*/\
		0x00,								/*(B)											*/\
		0x25,								/*(B, Accuracy)									*/\
		0x88,								/*(Accuracy, Accuracy exp)						*/\
		0x00,								/*(R exp, B exp)								*/\
		0x07,								/*(Analog characteristic flag)					*/\
		25,									/*(Normal reading)								*/\
		50,									/*(Normal max)									*/\
		20,									/*(Normal min)									*/\
		0x7F,								/*(Maximum reading)								*/\
		0x80,								/*(Minimum reading)								*/\
		85,									/*(Upper non-recoverable threshold)				*/\
		75,									/*(Upper critical threshold)					*/\
		65,									/*(Upper non-critical threshold)				*/\
		-20,								/*(Lower non-recoverable threshold)				*/\
		-10,								/*(Lower critical threshold)					*/\
		0,									/*(Lower non critical threshold)				*/\
		0x02,								/*(Positive-going hysteresis)					*/\
		0x02,								/*(Negative-going hysteresis)					*/\
		0x00,								/*(reserved: 00h)								*/\
		0x00,								/*(reserved: 00h)								*/\
		0x00,								/*(reserved for OEM use)						*/\
		0xC8,								/*(ID string type/length)						*/\
		'T','e','m','p','F', 'P', 'G', 'A'  /*(ID String)			                        */\
	}
	
	#define AMC1_RECORD		                /* LM82 IC12*/                                    \		
	{																						  \
		0x00,								/*(Record ID: Filled by init)					*/\
		0x00,								/*(Record ID: Filled by init)					*/\
		0x51,								/*(SDR Version: 51h)							*/\
		0x01,								/*(Record type: 01h - full sensor)				*/\
		0x00,								/*(Record length: Filled by init)				*/\
		0x00,								/*(Sensor owner ID: Filled by init)				*/\
		0x00,								/*(Sensor owner LUN: 00h)						*/\
		TEMPERATURE_SENSOR2,				/*(Sensor number)								*/\
		0xc1,								/*(Entity ID: C1h - AMC)						*/\
		0x00,								/*(Entity Instance)								*/\
		0x7F,								/*(Sensor Initialization)						*/\
		0xFC,								/*(Sensor capabilities)							*/\
		TEMPERATURE,						/*(Sensor type)									*/\
		0x01,								/*(Event/Reading type code)						*/\
		0xFF,								/*(Assertion event mask (LSB))					*/\
		0x7F,								/*(Assertion event mask (MSB))					*/\
		0xFF,								/*(Deassertion event mask (LSB))				*/\
		0x7F,								/*(Deassertion event mask (MSB))				*/\
		0x00,								/*(Settable / Readable threshold mask (LSB))	*/\
		0x00,								/*(Settable / Readable threshold mask (MSB))	*/\
		0x80,								/*(Sensor unit: 80h - 2's complement (signed))	*/\
		0x01,								/*(Sensor unit 2 - Base unit)					*/\
		0x00,								/*(Sensor unit 3 - Modifier unit)				*/\
		0x00,								/*(Linearization: 00h - Linear)					*/\
		0x01,								/*(M)											*/\
		0x01,								/*(M, Tolerance)								*/\
		0x00,								/*(B)											*/\
		0x25,								/*(B, Accuracy)									*/\
		0x88,								/*(Accuracy, Accuracy exp)						*/\
		0x00,								/*(R exp, B exp)								*/\
		0x07,								/*(Analog characteristic flag)					*/\
		25,									/*(Normal reading)								*/\
		50,									/*(Normal max)									*/\
		20,									/*(Normal min)									*/\
		0x7F,								/*(Maximum reading)								*/\
		0x80,								/*(Minimum reading)								*/\
		85,									/*(Upper non-recoverable threshold)				*/\
		75,									/*(Upper critical threshold)					*/\
		65,									/*(Upper non-critical threshold)				*/\
		-20,								/*(Lower non-recoverable threshold)				*/\
		-10,								/*(Lower critical threshold)					*/\
		0,									/*(Lower non critical threshold)				*/\
		0x02,								/*(Positive-going hysteresis)					*/\
		0x02,								/*(Negative-going hysteresis)					*/\
		0x00,								/*(reserved: 00h)								*/\
		0x00,								/*(reserved: 00h)								*/\
		0x00,								/*(reserved for OEM use)						*/\
		0xC9,								/*(ID string type/length)						*/\
		'T','e','m','p','F', 'r', 'o', 'n', 't'   /*(ID String)		                        */\
	}
	
	#define AMC2_RECORD                     /* LM82 IC19*/	                                  \
	{																						  \
		0x00,								/*(Record ID: Filled by init)					*/\
		0x00,								/*(Record ID: Filled by init)					*/\
		0x51,								/*(SDR Version: 51h)							*/\
		0x01,								/*(Record type: 01h - full sensor)				*/\
		0x00,								/*(Record length: Filled by init)				*/\
		0x00,								/*(Sensor owner ID: Filled by init)				*/\
		0x00,								/*(Sensor owner LUN: 00h)						*/\
		TEMPERATURE_SENSOR3,				/*(Sensor number)								*/\
		0xc1,								/*(Entity ID: C1h - AMC)						*/\
		0x00,								/*(Entity Instance)								*/\
		0x7F,								/*(Sensor Initialization)						*/\
		0xFC,								/*(Sensor capabilities)							*/\
		TEMPERATURE,						/*(Sensor type)									*/\
		0x01,								/*(Event/Reading type code)						*/\
		0xFF,								/*(Assertion event mask (LSB))					*/\
		0x7F,								/*(Assertion event mask (MSB))					*/\
		0xFF,								/*(Deassertion event mask (LSB))				*/\
		0x7F,								/*(Deassertion event mask (MSB))				*/\
		0x00,								/*(Settable / Readable threshold mask (LSB))	*/\
		0x00,								/*(Settable / Readable threshold mask (MSB))	*/\
		0x80,								/*(Sensor unit: 80h - 2's complement (signed))	*/\
		0x01,								/*(Sensor unit 2 - Base unit)					*/\
		0x00,								/*(Sensor unit 3 - Modifier unit)				*/\
		0x00,								/*(Linearization: 00h - Linear)					*/\
		0x01,								/*(M)											*/\
		0x01,								/*(M, Tolerance)								*/\
		0x00,								/*(B)											*/\
		0x25,								/*(B, Accuracy)									*/\
		0x88,								/*(Accuracy, Accuracy exp)						*/\
		0x00,								/*(R exp, B exp)								*/\
		0x07,								/*(Analog characteristic flag)					*/\
		25,									/*(Normal reading)								*/\
		50,									/*(Normal max)									*/\
		20,									/*(Normal min)									*/\
		0x7F,								/*(Maximum reading)								*/\
		0x80,								/*(Minimum reading)								*/\
		85,									/*(Upper non-recoverable threshold)				*/\
		75,									/*(Upper critical threshold)					*/\
		65,									/*(Upper non-critical threshold)				*/\
		-20,								/*(Lower non-recoverable threshold)				*/\
		-10,								/*(Lower critical threshold)					*/\
		0,									/*(Lower non critical threshold)				*/\
		0x02,								/*(Positive-going hysteresis)					*/\
		0x02,								/*(Negative-going hysteresis)					*/\
		0x00,								/*(reserved: 00h)								*/\
		0x00,								/*(reserved: 00h)								*/\
		0x00,								/*(reserved for OEM use)						*/\
		0xC8,								/*(ID string type/length)						*/\
		'T','e','m','p','R', 'e', 'a', 'r'  /*(ID String)			                        */\
	}
		
#endif /* SENSORS_H_ */