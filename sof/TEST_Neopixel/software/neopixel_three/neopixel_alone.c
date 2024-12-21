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
#include "neopixel.h"
#include "unistd.h" // Pour usleep
int value = 30;
int main()
{
  while (1)
  {
	  printf("Valeur actuelle : %d\n", value);
	  IOWR_ALTERA_AVALON_NEOPIXEL(value); // �criture en binaire
	  usleep(200000);
	  value ++;
	  if (value>12)
	  {
		  value = 0;
	  }
  }
  return 0;
}






