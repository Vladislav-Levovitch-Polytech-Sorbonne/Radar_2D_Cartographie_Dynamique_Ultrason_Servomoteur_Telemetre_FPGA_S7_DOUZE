/*
 * telemetre_sept_seg.c
 *
 *  Created on: 3 déc. 2024
 *      Author: vladi
 */
#include "system.h"
#include "io.h"
#include <stdio.h>
#include "altera_avalon_pio_regs.h"
#include "telemetre.h"
#include "unistd.h"  // Pour usleep

/* systeme.h
 * #define HEX3_HEX0_BASE 0xff200020
 * #define HEX5_HEX4_BASE 0xff200030
 * #define AVALON_TELEMETRE_BASE 0x4000000
 * SLIDER_SWITCHES_BASE
 *
 * */

unsigned int table_sept_seg[] =
{
    0x3F, // table_sept_seg[0] 0
    0x06, // table_sept_seg[1] 1
    0x5B, // table_sept_seg[2] 2
    0x4F, // table_sept_seg[3] 3
    0x66, // table_sept_seg[4] 4
    0x6D, // table_sept_seg[5] 5
    0x7D, // table_sept_seg[6] 6
    0x07, // table_sept_seg[7] 7
    0x7F, // table_sept_seg[8] 8
    0x6F, // table_sept_seg[9] 9
    0x79, // table_sept_seg[10] E
    0x30, // table_sept_seg[11] I
    0x3E, // table_sept_seg[12] V
    0x38, // table_sept_seg[13] L
    0x77, // table_sept_seg[14] A
    0x3F  // table_sept_seg[15] D
};

int main() {
	unsigned int distance = 0; // int_test

	// Stockage des donnees a afficher sur les 6 afficheurs Sept segments
	unsigned int Buffer_6_HEX[] =
	{
			table_sept_seg[0],
			table_sept_seg[1],
			table_sept_seg[2],
			table_sept_seg[3],
			table_sept_seg[4],
			table_sept_seg[5]
	};

    while (1)
    {
    	//distance = IORD_ALTERA_AVALON_TELEMETRE();
        //printf("Distance_obstacle = %d cm\n", distance);

    	//Remplissage de la table
    	// Unites
    	Buffer_6_HEX[5] = table_sept_seg[(distance/1)%10];
    	Buffer_6_HEX[4] = table_sept_seg[(distance/10)%10];
    	Buffer_6_HEX[3] = table_sept_seg[(distance/100)%10];

    	// Milliers
    	Buffer_6_HEX[2] = table_sept_seg[(distance/1000)%10];
    	Buffer_6_HEX[1] = table_sept_seg[(distance/10000)%10];
    	Buffer_6_HEX[0] = table_sept_seg[(distance/100000)%10];

    	IOWR_ALTERA_AVALON_HEX_3_2_1_0(( Buffer_6_HEX[2] << 8*3 ) | ( Buffer_6_HEX[3] << 8*2 ) | ( Buffer_6_HEX[4] << 8 ) | Buffer_6_HEX[5] );
    	IOWR_ALTERA_AVALON_HEX_5_4 (( Buffer_6_HEX[0] << 8) | Buffer_6_HEX[1] );

        usleep(200000); // Delay 1s ~300ooo

        // Simulation de MAJ distance
        distance +=3;
        if ( distance >= 370 ) { distance = 2;} //Reinit
    }
    return 0;
}
