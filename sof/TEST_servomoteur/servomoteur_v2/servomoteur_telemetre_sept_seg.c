/*
 * servomoteur.c
 *
 *  Created on: 8 déc. 2024
 *      Author: vladi
 */

#include "system.h"
#include "io.h"
#include <stdio.h>
#include "altera_avalon_pio_regs.h"
#include "servomoteur_telemetre.h"
#include "unistd.h"  // Pour usleep

#define NB_PRELEVEMENTS 32   // Nombre de prelevements pour la moyenne
#define SEUIL_ABERRANT 1000 // Seuil pour detecter une valeur aberrante

/* systeme.h
 * #define HEX3_HEX0_BASE 0xff200020
 * #define HEX5_HEX4_BASE 0xff200030
 * #define AVALON_TELEMETRE_BASE 0x4000000
 * SLIDER_SWITCHES_BASE
 * IORD_ALTERA_AVALON_SWITCHES(
 * IOWR_ALTERA_AVALON_SERVOMOTEUR(data)
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

// Pour eviter de faire des Multiplications voir pire des puissances
unsigned int puissance_10 [] = {1, 10, 100, 	1000, 10000, 100000};

void update_display(unsigned int* Buffer_6_HEX)
{
    IOWR_ALTERA_AVALON_HEX_3_2_1_0((Buffer_6_HEX[2] << 8*3) | (Buffer_6_HEX[3] << 8*2) | (Buffer_6_HEX[4] << 8) | Buffer_6_HEX[5]);
    IOWR_ALTERA_AVALON_HEX_5_4((Buffer_6_HEX[0] << 8) | Buffer_6_HEX[1]);
}

// Affichage decoratif en allumage
void init_Affichage ()
{
	// Stockage des donnees a afficher sur les 6 afficheurs Sept segments
	unsigned int Buffer_6_HEX[] =
	{
			table_sept_seg[10],
			table_sept_seg[11],
			table_sept_seg[12],
			table_sept_seg[13],
			table_sept_seg[14],
			table_sept_seg[15]
	};

	update_display(Buffer_6_HEX);
	usleep(1000000); // Delay 1s ~300ooo

	for ( int i = 0; i<7; i++)
	{
		if (i<6) {Buffer_6_HEX[i] |= (1<<7);}
		else
		{
			for ( int j = 0; j<6; j++)
			{
				Buffer_6_HEX[j] &= (1<<7);
			}
		}
		update_display(Buffer_6_HEX);
		usleep(60000); // Delay 1s ~300ooo
	}
}

int main() {
    while (1) {
        // Test avec 90°
        IOWR(AVALON_SERVOMOTEUR_BASE, 0, "0000001110000100");
    }
    return 0;
}
