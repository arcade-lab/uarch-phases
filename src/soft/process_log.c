/****************************************************************************/
/*  This file is part of a signal tracing utility for the LEON3 processor   */
/*  Copyright (C) 2017, ARCADE Lab @ Columbia University                    */
/*                                                                          */
/*  This program is free software: you can redistribute it and/or modify    */
/*  it under the terms of the GNU General Public License as published by    */
/*  the Free Software Foundation, either version 3 of the License, or       */
/*  (at your option) any later version.                                     */
/*                                                                          */
/*  This program is distributed in the hope that it will be useful,         */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of          */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           */
/*  GNU General Public License for more details.                            */
/*                                                                          */  
/*  You should have received a copy of the GNU General Public License       */
/*  along with this program. If not, see <http://www.gnu.org/licenses/>.    */
/*                                                                          */
/****************************************************************************/
/*  File:        process_log.vhd                                            */
/*  Author:      Van Bui - ARCADE @ Columbia University                     */
/*  Description: Data logger interface                                      */
/****************************************************************************/

#include <string.h>
#include <unistd.h>

#define VENDOR_SLD 0xEB
#define SLD_FFT2D  0x05
#define RATETRACE_IRQ 5

#define RATETRACE

#define true 1
#define false 0

#ifndef W_SIZE
#define W_SIZE 2
#endif

#ifndef STAGE
#define STAGE 83
#endif

typedef struct {
  int counter;
  unsigned pstate[7];
} PipeState;

typedef struct {
  PipeState *array;
  int used;
  int size;
} Array;

typedef struct {
  unsigned id;
  int count;
} StateCounter;

#define MAX_LOG_SIZE 100000000
#define MAX_STATES 1000000
//#define MAX_LOG_SIZE 10

void count_uniq();
void gentrace();
void initlogger();
void resetlogger();
void stoplogger();
unsigned getcycles();

volatile static rtirq = 0;
volatile static totsamples = 0;
#ifdef RATETRACE
volatile static unsigned allsamples[MAX_LOG_SIZE];
#endif
volatile static sampleindex = 0;
volatile unsigned  done = 0;

void resetlogger()
{
  volatile unsigned *iomem0  = (unsigned *) 0xb0000000;

  *iomem0 = 0xffffffff;

}

void stoplogger()
{
  volatile unsigned *iomem1  = (unsigned *) 0xb0000004;

  done = 1;  
  *iomem1 = 0xffffffff; 
}

unsigned getcycles()
{
  volatile unsigned *iomem0  = (unsigned *) 0xb0000000;
  
  unsigned cycles = *iomem0;

  return cycles;
}

struct DataItem {
  int data;
  unsigned key;
};

struct DataItem * * hashArray;
struct DataItem * dummyItem;
struct DataItem * item;
int uniqstates=0;

int hashCode(unsigned key){
  return key % MAX_STATES;
}

struct DataItem * search(unsigned key) {

  //get hash
  int hashIndex = hashCode(key);

  //move in array until an empty
  while(hashArray[hashIndex] != NULL) {
    if (hashArray[hashIndex]->key == key)
      return hashArray[hashIndex];
    //go to next cell
    ++hashIndex;
    //wrap around the table
    hashIndex %= MAX_STATES;
  }
  return NULL;
}

void insert(unsigned key, int data){
  struct DataItem *item = (struct DataItem*) malloc(sizeof(struct DataItem));
  item->data = data;
  item->key = key;
  
  //get the hash
  int hashIndex = hashCode(key);

  //move in array until an empty or deleted cell
  while(hashArray[hashIndex] != NULL && hashArray[hashIndex]->key != -1) {
    //go to next cell
    ++hashIndex;

    //wrap around the table
    hashIndex %= MAX_STATES;
  }

  hashArray[hashIndex] = item;

}

void count_uniq()
{
  int i;
  int countstates=0;
  unsigned lastval = allsamples[0];

  uniqstates = totsamples;

  printf("Number of samples: %u\n", totsamples);

  hashArray = (struct DataItem * *)malloc(uniqstates * sizeof(struct DataItem *));

  for (i = 0; i < uniqstates; i++){
    hashArray[i] = (struct DataItem *) malloc(sizeof(struct DataItem));
    hashArray[i] = NULL;
  }

  for (i = 1; i < totsamples; i++){
    unsigned val = allsamples[i];
    if (val != lastval){
      item = search(lastval);

      if (item == NULL) {
	insert(lastval,countstates);
	countstates++;
      } 
    }
    lastval = val;
  }

  printf("Number of irqs: %u \n", rtirq);
  printf("number of unique states: %d\n", countstates);

}

void gentrace()
{
  int i,j;
  int samples;
  int found;
  unsigned lastval = allsamples[0];
  int counter=0;
  int countuniq = 0;

  printf("Number of samples: %u\n", totsamples);
  printf("Number of irqs: %u \n", rtirq);
  printf("START "); 

  hashArray = (struct DataItem * *)malloc(MAX_STATES * sizeof(struct DataItem *));

  for (i = 0; i < MAX_STATES; i++){
    hashArray[i] = (struct DataItem *) malloc(sizeof(struct DataItem));
    hashArray[i] = NULL;
  }

  for (i=0; i < totsamples; i++) {
      unsigned val = allsamples[i];
      item = search(val);
      if (item == NULL){
	insert(val,counter);
	printf("%x ", counter);
	counter++;
      }
      else
	printf("%x ", item->data);
  }

  printf("dict ");

  for (i=0; i < MAX_STATES; i++){
    if (hashArray[i] != NULL){
      printf("%x %08x ", hashArray[i]->data, hashArray[i]->key); 
      countuniq++;
    }
  }

  printf("DONE\n");
  printf("Unique states: %d\n", countuniq);
}

ratetrace_irqhandler(int irq)
{
  unsigned samples;
  volatile unsigned *iomem0  = (unsigned *) 0xb0000000;
  int i;
  unsigned long adx;
  unsigned endindex;

  adx = 1;

  samples = *iomem0;
  totsamples+=samples;
  rtirq+=1;
  
#ifdef RATETRACE
  endindex = samples+sampleindex;

  for (i = sampleindex; i < endindex; i++) {
    volatile unsigned *current_address = iomem0+adx;
    unsigned val = *current_address;
    allsamples[i] = val;
    adx+=1;
  }

  sampleindex = endindex;
#endif

  if (done==1)
    gentrace();
  else
    resetlogger();
}


void initlogger()
{
  unsigned *irq_mask = (unsigned *) 0x80000240;
  int i;

  /* Unmask timer 0 IRQ - Default value is 8 */
  *irq_mask = 1 << RATETRACE_IRQ;

  catch_interrupt(ratetrace_irqhandler, RATETRACE_IRQ);

#ifdef RATETRACE
  for (i=0; i < MAX_LOG_SIZE; i++)
    allsamples[i] = 0;
#endif
}

