/*
 * sensors.c
 *
 * Created: 27/03/2015 12:37:17
 *  Author: jumendez
 */ 
#include <avr/io.h>

#include "../../../../../../mmc_v2/Release_1/MMC/sdr.h"
#include "../../../../../../mmc_v2/Release_1/MMC/a2d.h"
#include "../../../../../../mmc_v2/Release_1/MMC/i2csw.h"
#include "../../../../../../mmc_v2/Release_1/MMC/iodeclaration.h"

#include "../../../../../../mmc_v2/Release_1/MMC/avrlibdefs.h"
#include "../../../../../../mmc_v2/Release_1/MMC/avrlibtypes.h"

#include "../../../../../../mmc_v2/Release_1/MMC/ekeying.h"

#include "sensors.h"


u08 tempSensorRead(u08 sensor) // local user function
{
	u08 stemp;     //sensor temperature
	
	if(sensor==TEMPERATURE_SENSOR1) {GET_I2C_VAL(0x2A, 0x01, ZERO_LEN, 1, &stemp);}
	if(sensor==TEMPERATURE_SENSOR2) {GET_I2C_VAL(0x1A, 0x00, ZERO_LEN, 1, &stemp);}
	if(sensor==TEMPERATURE_SENSOR3) {GET_I2C_VAL(0x4E, 0x00, ZERO_LEN, 1, &stemp);}
	return stemp;
}

/** Sensor initialization */
void sensor_init_user(){
	// LM82 doesnt need init
}

/** Sensor are polled (Every 100 ms) */
void sensor_monitoring_user()
{ 
	set_sensor_value(TEMPERATURE_SENSOR1,tempSensorRead(TEMPERATURE_SENSOR1));
	set_sensor_value(TEMPERATURE_SENSOR2,tempSensorRead(TEMPERATURE_SENSOR2));
	set_sensor_value(TEMPERATURE_SENSOR3,tempSensorRead(TEMPERATURE_SENSOR3));
}