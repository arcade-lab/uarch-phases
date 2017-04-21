/***************************************************************************/
/* File: sha_driver.c                                                      */
/* Mofidied: April 20, 2017 by Van Bui - ARCADE @ Columbia University      */
/* Changes: Modified I/O to run as baremetal and added tracing utility     */
/*          function                                                       */
/***************************************************************************/

/* NIST Secure Hash Algorithm */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "sha.h"
#include "process_log.c"

int main(int argc, char **argv)
{
    FILE *fin;
    SHA_INFO sha_info;
    volatile unsigned *activity = (unsigned *) 0xb000001c;

    unsigned cycles = 0;

    //reset statistics and start counting
    initlogger();
    resetlogger();

    sha_stream(&sha_info, fin);

    sha_print(&sha_info);

    //dump statistics
    stoplogger();

    return(0);
}
