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

unsigned int equivalence_sept_seg[] =
{
    0x3F, // equivalence_sept_seg[0] 0
    0x06, // equivalence_sept_seg[1] 1
    0x5B, // equivalence_sept_seg[2] 2
    0x4F, // equivalence_sept_seg[3] 3
    0x66, // equivalence_sept_seg[4] 4
    0x6D, // equivalence_sept_seg[5] 5
    0x7D, // equivalence_sept_seg[6] 6
    0x07, // equivalence_sept_seg[7] 7
    0x7F, // equivalence_sept_seg[8] 8
    0x6F, // equivalence_sept_seg[9] 9
    0x79, // equivalence_sept_seg[10] E
    0x30, // equivalence_sept_seg[11] I
    0x3E, // equivalence_sept_seg[12] V
    0x38, // equivalence_sept_seg[13] L
    0x77, // equivalence_sept_seg[14] A
    0x3F  // equivalence_sept_seg[15] D
};

int main() {

    //unsigned int Ei_Vlad[] = {equivalence_sept_seg[15], equivalence_sept_seg[14], equivalence_sept_seg[13], equivalence_sept_seg[12], equivalence_sept_seg[11]|0x80, equivalence_sept_seg[10]};

	unsigned int Buffer_6_HEX[] = {equivalence_sept_seg[6], equivalence_sept_seg[7], equivalence_sept_seg[8], equivalence_sept_seg[9], equivalence_sept_seg[1], equivalence_sept_seg[0]};
    while (1) {
        IOWR_ALTERA_AVALON_PIO_DATA(HEX3_HEX0_BASE,
            ( Buffer_6_HEX[2] << 8*3 ) | ( Buffer_6_HEX[3] << 8*2 ) | (Buffer_6_HEX[4] << 8) | Buffer_6_HEX[5]);

        IOWR_ALTERA_AVALON_PIO_DATA(HEX5_HEX4_BASE,
            ( Buffer_6_HEX[0] << 8) | Buffer_6_HEX[1] );

        usleep(500000);
    }

    /*while (1) {
        int distance = IORD_ALTERA_AVALON_TELEMETRE();
        printf("Distance_obstacle = %d cm\n", distance);

        usleep(500000); // 500ms
    */

    return 0;
}
