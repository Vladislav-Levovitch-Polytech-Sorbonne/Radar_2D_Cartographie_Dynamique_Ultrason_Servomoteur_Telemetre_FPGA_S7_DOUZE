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

/* systeme.h
 * #define HEX3_HEX0_BASE 0xff200020
 * #define HEX5_HEX4_BASE 0xff200030
 * #define AVALON_TELEMETRE_BASE 0x4000000
 * SLIDER_SWITCHES_BASE
 *
 * */

int main() {

    while (1) {
        uint32_t distance = IORD_ALTERA_AVALON_TELEMETRE();
        printf("Distance_obstacle = %lu cm\n", distance);

        usleep(500000); // 500ms
    }

    return 0;
}
