/***************************************************************************/
/* File: qsort_small.c                                                     */
/* Mofidied: April 20, 2017 by Van Bui - ARCADE @ Columbia University      */
/* Changes: Modified I/O to run as baremetal and added tracing utility     */
/*          function                                                       */
/***************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define UNLIMIT
#define MAXARRAY 60000 /* this number, if too large, will cause a seg. fault!! */

struct myStringStruct {
  char qstring[128];
};

#include "process_log.c"

int compare(const void *elem1, const void *elem2)
{
  int result;
  
  result = strcmp((*((struct myStringStruct *)elem1)).qstring, (*((struct myStringStruct *)elem2)).qstring);

  return (result < 0) ? 1 : ((result == 0) ? 0 : -1);
}


int
main(int argc, char *argv[]) {
  struct myStringStruct array[MAXARRAY];
  FILE *fp;
  int i,count=0;
  unsigned cycles = 0;

#include "qsdat.c"
  
  count=8000;

  printf("\nSorting %d elements.\n\n",count);

  //reset statistics and start counting
  initlogger();
  resetlogger();

  qsort(array,count,sizeof(struct myStringStruct),compare);

  //dump statistics
  stoplogger();

  return 0;
}
