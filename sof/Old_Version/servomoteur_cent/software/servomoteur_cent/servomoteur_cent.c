/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "unistd.h"
#include "stdio.h"
#include "io.h"
//#define AVALON_SERVOMOTEUR_BASE 0x04000000
int value = 0;
int main()
{
  usleep(100000);
  while (1)
  {
	  //int value = IORD(0x04000000, 0);
	  printf("Valeur actuelle : %d\n", value);
	  value += 10;
	  //IOWR(0x04000000, 0, 0b0000000111000010); // Écriture en binaire
	  IOWR_16DIRECT(AVALON_SERVOMOTEUR_BASE, 0, value); // Écriture en binaire
	  usleep(10000);
	  if (value>1800)value = 0;
  }
  return 0;
}
