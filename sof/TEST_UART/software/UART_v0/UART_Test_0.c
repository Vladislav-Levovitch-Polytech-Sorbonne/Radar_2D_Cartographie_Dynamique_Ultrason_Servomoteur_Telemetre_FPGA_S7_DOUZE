/*
 * Vlad 2024.12.26 et gtp debug et com
 *
 */

#include <stdio.h>
#include "system.h"
#include "io.h"
#include "unistd.h"

#define UART_BASE 0x4000000

int delay = 1000;
int angle_min = 0;
int angle_max = 180;
int angle = 0;
int vitesse = 5;

void send_ascii(int ascii_char)
{
    IOWR_32DIRECT(UART_BASE, 0x4, ascii_char);
    IOWR_32DIRECT(UART_BASE, 0x0, 1);
    usleep(delay);
    IOWR_32DIRECT(UART_BASE, 0x0, 0);
}

void send_word_with_count(const char *word, int angle)
{
    char buffer[100];
    snprintf(buffer, sizeof(buffer), "%s %d�   [%d ; %d]  Vitesse: %d", word, angle, angle_min, angle_max, vitesse);

    for (int i = 0; buffer[i] != '\0'; i++)
    {
        send_ascii(buffer[i]);
    }
    usleep(1000);
    send_ascii(0x0D);
}

int RD_Ascii()
{
    IOWR_32DIRECT(UART_BASE, 0x0, 0);
    usleep(1000);
    return IORD_32DIRECT(UART_BASE, 0x8);
}

void Maj_Affichage()
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
    const char *word = "VLADIslav";

    while (1)
    {
        Maj_Affichage();
        send_word_with_count(word, angle);
        usleep(10000 + (40000 * (10-vitesse)));
        if (angle < angle_max)
            {
                angle ++;
            }
        else
            {
                angle = angle_min;
            }
    }
    return 0;
}

