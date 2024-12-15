#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "unistd.h"
#include "stdio.h"
#include "io.h"
int value = 0;
int main()
{
  while (1)
  {
	  printf("Valeur actuelle : %d.%d�\n", value/10,value%10);
	  IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, value); // �criture en binaire
	  usleep(10000);
	  value = IORD (SLIDER_SWITCHES_BASE,0)<< 1;
	  if (value>1793)
	  {
		  value = 1793;
	  }
  }
  return 0;
}