/*
 * neopixel.h
 *
 *  Created on: 17 déc. 2024
 *      Author: vladi
 */

/*
 * turning_telemeter_clk_fixed.h
 *
 *  Created on: 15 déc. 2024
 *      Author: vladi
 */

/*
 * servomoteur_tournant.h
 *
 *  Created on: 13 déc. 2024
 *      Author: vladi
 */

/*
 * telemetre.h
 *
 *  Created on: 3 déc. 2024
 *      Author: vladi
 */

#ifndef __ALTERA_AVALON_TELEMETRE_SERVOMOTEUR_NEOPIXEL__
#define __ALTERA_AVALON_TELEMETRE_SERVOMOTEUR_NEOPIXEL__

#include <io.h>

// Neopixel
#define IOWR_ALTERA_AVALON_NEOPIXEL(data)    	IOWR_8DIRECT(AVALON_NEOPIXEL_0_BASE, 0, data)

// Telemetre
#define IORD_ALTERA_AVALON_TELEMETRE()          IORD(AVALON_TELEMETRE_BASE, 0) & 0b1111111111

// Servomoteur
#define IOWR_ALTERA_AVALON_SERVOMOTEUR(data)    IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, data)

// LEDR
#define IORD_ALTERA_AVALON_LEDR()          		IORD(LEDS_BASE, 0)
#define IOWR_ALTERA_AVALON_LEDR(data)      		IOWR(LEDS_BASE, 0, data)

// BP
#define IORD_ALTERA_AVALON_BP()          		IORD(PUSHBUTTONS_BASE, 0)

// HEX_3_2_1_0
#define IORD_ALTERA_AVALON_HEX_3_2_1_0()        IORD(HEX3_HEX0_BASE, 0)
#define IOWR_ALTERA_AVALON_HEX_3_2_1_0(data)    IOWR(HEX3_HEX0_BASE, 0, data)

// HEX5_HEX4_BASE
#define IORD_ALTERA_AVALON_HEX_5_4()          	IORD(HEX5_HEX4_BASE, 0)
#define IOWR_ALTERA_AVALON_HEX_5_4(data)   		IOWR(HEX5_HEX4_BASE, 0, data)

// SLIDER_SWITCHES_BASE
#define IORD_ALTERA_AVALON_SWITCHES()      		IORD(SLIDER_SWITCHES_BASE, 0)

#endif /* __ALTERA_AVALON_TELEMETRE_SERVOMOTEUR_NEOPIXEL__ */











