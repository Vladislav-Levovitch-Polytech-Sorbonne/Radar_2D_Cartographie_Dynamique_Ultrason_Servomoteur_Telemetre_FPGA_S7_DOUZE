/*
 * UART_Neopixel_Telemetre_Servomoteur_Parametrable.c
 *
 *  Created on: 27 d�c. 2024
 *      Author: vladi
 */

/*
 * UART_Test_0.c
 *
 * Created on: 26 d�c. 2024
 *      Author: vladi
 *
 * Vlad 2024.12.26 et gtp debug et com
 */

/*
 * neopixel_radar.c
 *
 *  Created on: 22 d�c. 2024
 *      Author: vladi
 */

/*
 * neopixel_alone.c
 *
 *  Created on: 21 d�c. 2024
 *      Author: vladi
 */

/*
 * neopixel.c
 *
 *  Created on: 17 d�c. 2024
 *      Author: vladi
 */

/*
 * turning_telemetre_clk_fixed.c
 *
 *  Created on: 15 d�c. 2024
 *      Author: vladi
 */

/*
 * servomotor.c
 *
 *  Created on: 13 dec. 2024
 *      Author: vladi
 */

/*
 * servomotor.c
 *
 *  Created on: 11 dec. 2024
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

#include <stdio.h>
#include "system.h"
#include "io.h"
#include "unistd.h"
#include "UART_Neopixel_Telemetre_Servomoteur.h"
#include "altera_avalon_pio_regs.h"

#define NB_PRELEVEMENTS 32   // Nombre de prelevements pour la moyenne
#define SEUIL_ABERRANT  250  // Seuil pour detecter une valeur aberrante
#define ANGLE_MAX  		180  // Angle Maximal accepte par le module Servomoteur
#define ANGLE_MIN  		0	 // Angle Minimal de consigne pour le module Servomoteur

int delay = 1000;
int angle_min = ANGLE_MIN;
int angle_max = ANGLE_MAX;
int angle = 0;
int vitesse = 5;

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

void send_ascii(int ascii_char)
{
    IOWR_ALTERA_AVALON_UART_Tx_ASCii(ascii_char);
    IOWR_ALTERA_AVALON_UART_Load(1);
    usleep(delay);
    IOWR_ALTERA_AVALON_UART_Load(0);
}

void envoi_terminal_externe(const char *word, int angle, int distance)
{
    char buffer[100];
    snprintf(buffer, sizeof(buffer), "%s Angle=%d deg [%d ; %d]  +  Speed_mod=%d  +  Dist_moy=%d cm", word, angle, angle_min, angle_max, vitesse, distance); //GPT -ed

    for (int i = 0; buffer[i] != '\0'; i++)
    {
        send_ascii(buffer[i]);
    }
    usleep(1000);
    send_ascii(0x0D);
}

int RD_Ascii()
{
    IOWR_ALTERA_AVALON_UART_Load(0);
    usleep(1000);
    return IORD_ALTERA_AVALON_UART_Rx_ASCii();
}

void traitement_donnees_distance(unsigned int *distance,unsigned int *moyenne_distance,unsigned int *Buffer_6_HEX,unsigned int *somme_distance,unsigned int *nb_valeurs_valides,unsigned int *nb_valeurs_aberrantes )
{
    *somme_distance = 0;
    *nb_valeurs_valides = 0;
    *nb_valeurs_aberrantes = 0;

    // Lecture des distances
    for (int i = 0; i < NB_PRELEVEMENTS; i++)
    {
        *distance = IORD_ALTERA_AVALON_TELEMETRE();
        if (*distance > SEUIL_ABERRANT)
        {
            (*nb_valeurs_aberrantes)++;
        }
        else
        {
            *somme_distance += *distance;
            (*nb_valeurs_valides)++;
        }
        usleep(1000);
    }

    // Calcul de la distance moyenne
    if (*nb_valeurs_aberrantes > NB_PRELEVEMENTS / 5 || *nb_valeurs_valides == 0)
    {
        *moyenne_distance = 0;
    }
    else
    {
        *moyenne_distance = *somme_distance / *nb_valeurs_valides;
    }
}

void Maj_donnees_UART()
{
    int received_char = RD_Ascii();		// Lecture instruction a la volee

    // Maj Vitesse
    if (received_char >= '0' && received_char <= '9')
    {
        vitesse = received_char - '0';
        if (vitesse < 0) vitesse = 0;
        if (vitesse > 9) vitesse = 9;
    }

    // Maj Angle_min
    else if (received_char >= 'a' && received_char <= 'z')
    {
    	angle_min = (received_char - 'a') * 10;
    }
    // Maj Angle_max
    else if (received_char >= 'A' && received_char <= 'Z')
    {
    	angle_max = (received_char - 'A') * 10;
    }

    if (angle_max > ANGLE_MAX)
        {
    		angle_max  = ANGLE_MAX;
        }

    if (angle_min > ANGLE_MAX)
            {
        		angle_min  = ANGLE_MAX;
            }

    //Check up borne
    if (angle_min > angle_max)
    {
        int temp  = angle_min;
        angle_min = angle_max;
        angle_max = temp;
    }
}

int main()
{
	// Pause de demarrage
	IOWR_ALTERA_AVALON_NEOPIXEL(angle);
	IOWR_ALTERA_AVALON_SERVOMOTEUR(angle);
	usleep(1800000);
	unsigned int distance = 0;                    // Distance brute mesuree
	unsigned int moyenne_distance = 0;            // Moyenne des distances
	unsigned int Buffer_6_HEX[6] = {0};           // Buffer pour l affichage
	unsigned int somme_distance = 0;              // Somme des distances valides
	unsigned int nb_valeurs_valides = 0;          // Nombre de valeurs valides
	unsigned int nb_valeurs_aberrantes = 0;       // Compteur de valeurs aberrantes

	// Initialisation de l affichage
	init_affichage();

    const char *word = "Radar_Vlad";

    while (1)
    {
    	// Reset pour les calculs de ditstance
    	somme_distance = 0;
	    nb_valeurs_valides = 0;
	    nb_valeurs_aberrantes = 0;

	    // Lecture des distances
	    traitement_donnees_distance(&distance, &moyenne_distance, Buffer_6_HEX, &somme_distance, &nb_valeurs_valides, &nb_valeurs_aberrantes);

	    // Mise a jour de l affichage
	    for (int i = 0; i < 3; i++)
	    {
	  	    Buffer_6_HEX[5 - i] = table_sept_seg[(moyenne_distance / puissance_10[i]) % 10];
	    }

	 // MAJ donnees UART
	    // MAJ UART
        Maj_donnees_UART();
        envoi_terminal_externe(word, angle, moyenne_distance);

        float progression = 0;
        if (angle_max != angle_min)
        {
            progression = ((float)(angle - angle_min) / (angle_max - angle_min)) * 100; // Calcul de la progression en pourcentage
        }
        else
        {
            progression = 0; // Eviter la division par zero
        }

        printf("Valeur Angulaire = %d.0� --> [ %d ; %d ] \t Progression = %.1f%%  Nb_NeoPixel_Led = %d \tDistance Moyenne Telemetre = %d cm\n", angle, angle_min,angle_max, progression, (int)(progression / 100 * 12), moyenne_distance);

        IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, angle * 10);
        IOWR_ALTERA_AVALON_NEOPIXEL((int)(progression / 100 * 12)); // Assurez-vous que la valeur ne d�passe pas 12
        usleep(15000 + (15000 * (8-vitesse)));
        if (angle < angle_max && angle >= angle_min)
            {
                angle ++;
                // MAJ Afficheur 7 seg
				Buffer_6_HEX[2] = 0x63; // Caractere "�" pour l affichage
				Buffer_6_HEX[1] = table_sept_seg[(angle / puissance_10[0]) % 10];
				Buffer_6_HEX[0] = table_sept_seg[(angle / puissance_10[1]) % 10];
				update_display (Buffer_6_HEX);
            }
        else
            {
        		// Elements manuels
				IOWR_ALTERA_AVALON_NEOPIXEL(12); // 100% Retour depot
        		usleep(140000);
		        printf("Valeur Angulaire = %d.0� --> [ %d ; %d ] \t Progression = %.1f%%  Nb_NeoPixel_Led = %d \tDistance Moyenne Telemetre = %d cm\n", angle, angle_min,angle_max, progression, (int)(progression / 100 * 12), moyenne_distance);
				angle = angle_min;
				IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, ((angle_min+angle_max)/2) * 10);
				usleep(140000);
				IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, angle_min * 10);
				usleep(140000);
				IOWR_ALTERA_AVALON_NEOPIXEL(0);
            }
    }
    return 0;
}




