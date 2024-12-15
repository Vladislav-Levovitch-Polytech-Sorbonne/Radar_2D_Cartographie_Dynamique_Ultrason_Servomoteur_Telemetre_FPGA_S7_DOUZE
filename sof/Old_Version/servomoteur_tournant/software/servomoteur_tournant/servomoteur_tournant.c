/*
 * servomotor.c
 *
 *  Created on: 1 dec. 2024
 *      Author: vladi
 */

/*
 * servomotor.c
 *
 *  Created on: 5 dec. 2024
 *      Author: vladi
 */

 /*
 * servomotor.c
 *
 *  Created on: 8 dec. 2024
 *      Author: vladi
 */

/*
 * servomoteur.c
 *
 *  Created on: 8 dec. 2024
 *      Author: vladi
 */

/*
 * telemetre_sept_seg.c
 *
 *  Created on: 3 dec. 2024
 *      Author: vladi
 */

#include "system.h"
#include "io.h"
#include <stdio.h>
#include "altera_avalon_pio_regs.h"
#include "servomoteur_tournant.h"
#include "unistd.h" // Pour usleep

#define NB_PRELEVEMENTS 32   // Nombre de prelevements pour la moyenne
#define SEUIL_ABERRANT 250  // Seuil pour detecter une valeur aberrante

unsigned int table_sept_seg[] =
{
    0x3F, // 0
    0x06, // 1
    0x5B, // 2
    0x4F, // 3
    0x66, // 4
    0x6D, // 5
    0x7D, // 6
    0x07, // 7
    0x7F, // 8
    0x6F, // 9
    0x79, // E
    0x30, // I
    0x3E, // V
    0x38, // L
    0x77, // A
    0x3F  // D
};

// Pre calcul des puissances de 10 pour eviter les multiplications repetees
unsigned int puissance_10[] = {1, 10, 100, 1000, 10000, 100000};

void update_display(unsigned int* Buffer_6_HEX)
{
    IOWR_ALTERA_AVALON_HEX_3_2_1_0(
        (Buffer_6_HEX[2] << 24) | (Buffer_6_HEX[3] << 16) |
        (Buffer_6_HEX[4] << 8) | Buffer_6_HEX[5]);
    IOWR_ALTERA_AVALON_HEX_5_4((Buffer_6_HEX[0] << 8) | Buffer_6_HEX[1]);
}

// Animation d'initialisation
void init_affichage()
{
    unsigned int Buffer_6_HEX[] =
    {
        table_sept_seg[10], // E
        table_sept_seg[11], // I
        table_sept_seg[12], // V
        table_sept_seg[13], // L
        table_sept_seg[14], // A
        table_sept_seg[15]  // D
    };

    update_display(Buffer_6_HEX);
    usleep(1000000); // Delay 1 seconde

    for (int i = 0; i < 7; i++)
    {
        if (i < 6)
        {
            Buffer_6_HEX[i] |= (1 << 7); // Allumer le point decimal
        }
        else
        {
            for (int j = 0; j < 6; j++)
            {
                Buffer_6_HEX[j] &= ~(1 << 7); // eteindre le point decimal
            }
        }
        update_display(Buffer_6_HEX);
        usleep(60000); // Pause
    }
}

int main()
{
    unsigned int distance = 0;                    // Distance brute mesuree
    unsigned int moyenne_distance = 0;            // Moyenne des distances
    unsigned int Buffer_6_HEX[6] = {0};           // Buffer pour l affichage
    unsigned int somme_distance = 0;              // Somme des distances valides
    unsigned int nb_valeurs_valides = 0;          // Nombre de valeurs valides
    unsigned int nb_valeurs_aberrantes = 0;       // Compteur de valeurs aberrantes
    unsigned int angle = 0;                       // Angle reel
    unsigned int data_angle = 0;                  // Valeur pour le servomoteur
    unsigned int flip_angle = 0;                  // Alternance pour le balayage

    // Initialisation de l affichage
    init_affichage();

    while (1)
    {
        somme_distance = 0;
        nb_valeurs_valides = 0;
        nb_valeurs_aberrantes = 0;

        // Lecture des distances
        for (int i = 0; i < NB_PRELEVEMENTS; i++)
        {
            distance = (IORD_ALTERA_AVALON_TELEMETRE() & 0b1111111111);

            if (distance > SEUIL_ABERRANT)
            {
                nb_valeurs_aberrantes++;
            }
            else
            {
                somme_distance += distance;
                nb_valeurs_valides++;
            }

            usleep(1000);
        }

        // Calcul de la distance moyenne
        if (nb_valeurs_aberrantes > NB_PRELEVEMENTS / 5 || nb_valeurs_valides == 0)
        {
            moyenne_distance = 0;
        }
        else
        {
            moyenne_distance = somme_distance / (3 * nb_valeurs_valides) + 1;
        }

        // Mise a jour de l affichage
        for (int i = 0; i < 3; i++)
        {
            Buffer_6_HEX[5 - i] = table_sept_seg[(moyenne_distance / puissance_10[i]) % 10];
        }

        // Limiter l angle � 180
        if (angle > 180)
        {
            angle = 180; // Forcer l angle � 180 si depassement
        }

        Buffer_6_HEX[2] = 0x63; // Caractere "�" pour l affichage
        Buffer_6_HEX[1] = table_sept_seg[(angle / puissance_10[0]) % 10];
        Buffer_6_HEX[0] = table_sept_seg[(angle / puissance_10[1]) % 10];
        update_display (Buffer_6_HEX);

        // Mise a jour de la position du servomoteur
        data_angle += (flip_angle == 0) ? 8 : 9;
        flip_angle = 1 - flip_angle; // Alterner entre 8 et 9 car il faudrait augmenter de 8,55 pour chaque nouveau degres

        IOWR_ALTERA_AVALON_SERVOMOTEUR(data_angle);
        usleep(1000);

        if (data_angle > 1530)
        {
            data_angle = 0;
            angle = 0;
            IOWR_ALTERA_AVALON_SERVOMOTEUR(data_angle);
            usleep(1000000); // Temps de retour du servomoteur
        }
        printf("Angle = %d    Distance moyenne = %d cm\n",angle, moyenne_distance);
        angle++;
    }
    return 0;
}