/*
 * ekeying.c
 *
 * Created: 10/04/2015 13:02:51
 *  Author: jumendez
 */ 
#include "../../../../../../mmc_v2/Release_1/MMC/avrlibdefs.h"
#include "../../../../../../mmc_v2/Release_1/MMC/avrlibdefs.h"

#include "../../../../../../mmc_v2/Release_1/MMC/ekeying.h"

void ekeying_init(){
	//Point to point connectivity
		//set_channel_init(0, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(1, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(2, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(3, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(4, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(5, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(6, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(7, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(8, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(9, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(10, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(11, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(12, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(13, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(14, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(15, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
		//set_channel_init(16, PORT_ACTIVE);	//set_channel_init(<channel_id>,<state>);
}

u08 port_ekeying_enable(u08 id){	
	//Return values:
	//	SUCCESS: in case of success
	//	FAILED: in case of error
	//	NI: (not implemented) in case of the state port could not be changed
	
	switch(id){
		case 0:	break; //link id 0
		case 1: break; //link id 1
		case 2: break; //link id 1
		case 3: break; //link id 1
		case 4: break; //link id 1
		case 5: break; //link id 1
		case 6: break; //link id 1
		case 7: break; //link id 1
		case 8: break; //link id 1
		case 9: break; //link id 1
		case 10: break; //link id 1
		case 11: break; //link id 1
		case 12: break; //link id 1
		case 13: break; //link id 1
		case 14: break; //link id 1
		case 15: break; //link id 1
		case 16: break; //link id 1
	}
	
	return NI;
}

u08 port_ekeying_disable(u08 id){
	//Return values:
	//	SUCCESS: in case of success
	//	FAILED: in case of error
	//	NI: (not implemented) in case of the state port could not be changed
	
	switch(id){
		case 0:	break; //link id 0
		case 1: break; //link id 1
		case 2: break; //link id 1
		case 3: break; //link id 1
		case 4: break; //link id 1
		case 5: break; //link id 1
		case 6: break; //link id 1
		case 7: break; //link id 1
		case 8: break; //link id 1
		case 9: break; //link id 1
		case 10: break; //link id 1
		case 11: break; //link id 1
		case 12: break; //link id 1
		case 13: break; //link id 1
		case 14: break; //link id 1
		case 15: break; //link id 1
		case 16: break; //link id 1
	}
	
	return NI;
}