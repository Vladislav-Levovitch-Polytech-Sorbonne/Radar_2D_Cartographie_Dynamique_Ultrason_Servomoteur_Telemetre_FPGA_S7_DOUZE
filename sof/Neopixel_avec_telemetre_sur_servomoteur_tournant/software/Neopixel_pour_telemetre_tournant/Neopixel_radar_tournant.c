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

#include "system.h"
#include "io.h"
#include <stdio.h>
#include "altera_avalon_pio_regs.h"
#include "neopixel_radar.h"
#include "unistd.h" // Pour usleep
#define NB_PRELEVEMENTS 32   // Nombre de prelevements pour la moyenne
#define SEUIL_ABERRANT 250  // Seuil pour detecter une valeur aberrante

int degres = 0;
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
  // Pause de demarrage
  IOWR_ALTERA_AVALON_NEOPIXEL(degres/150);
  IOWR_ALTERA_AVALON_SERVOMOTEUR(degres);
  usleep(2400000);
  unsigned int distance = 0;                    // Distance brute mesuree
  unsigned int moyenne_distance = 0;            // Moyenne des distances
  unsigned int Buffer_6_HEX[6] = {0};           // Buffer pour l affichage
  unsigned int somme_distance = 0;              // Somme des distances valides
  unsigned int nb_valeurs_valides = 0;          // Nombre de valeurs valides
  unsigned int nb_valeurs_aberrantes = 0;       // Compteur de valeurs aberrantes

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
		  distance = IORD_ALTERA_AVALON_TELEMETRE();

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
		  moyenne_distance = somme_distance /  nb_valeurs_valides;
	  }

	  // Mise a jour de l affichage
	  for (int i = 0; i < 3; i++)
	  {
		  Buffer_6_HEX[5 - i] = table_sept_seg[(moyenne_distance / puissance_10[i]) % 10];
	  }

	  printf("Valeur Angulaire = %d.%d�\tTranche de Progression = %.1f%%  \tDistance Moyenne Telemetre = %d\n", degres/10,degres%10, (degres/150*8.34), moyenne_distance);
	  IOWR_ALTERA_AVALON_SERVOMOTEUR(degres); // �criture en binaire
	  IOWR_ALTERA_AVALON_NEOPIXEL(degres/150);
	  usleep(80000);
	  degres += 10;
	  Buffer_6_HEX[2] = 0x63; // Caractere "�" pour l affichage
	  Buffer_6_HEX[1] = table_sept_seg[(degres / puissance_10[1]) % 10];
	  Buffer_6_HEX[0] = table_sept_seg[(degres / puissance_10[2]) % 10];
	  update_display (Buffer_6_HEX);

	  // Plafonnement de securite et gestion a part du retour
	  if (degres>1793)
	  {
		degres = 1800;
		IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, 1793);
		IOWR_ALTERA_AVALON_NEOPIXEL(degres/150);
		printf("Valeur Angulaire = %d.%d�\tTranche de Progression = %.1f%%  \tDistance Moyenne Telemetre = %d\n", degres/10,degres%10, 100.0, moyenne_distance);
		usleep(140000);
		degres = 0;
		IOWR_ALTERA_AVALON_NEOPIXEL(degres);
		usleep(220000);

	  }

  }
  return 0;
}





