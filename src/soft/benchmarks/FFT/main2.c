/***************************************************************************/
/* File: main2.c                                                           */
/* Mofidied: April 20, 2017 by Van Bui - ARCADE @ Columbia University      */
/* Changes: Modified I/O to run as baremetal and added tracing utility     */
/*          function calls                                                 */  
/***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "process_log.c"

int main(int argc, char *argv[]) {
	unsigned MAXSIZE;
	unsigned MAXWAVES;
	unsigned i,j;
	float *RealIn;
	float *ImagIn;
	float *RealOut;
	float *ImagOut;
	float *coeff;
	float *amp;
	int invfft=0;

	unsigned cycles = 0;

	initlogger();
	resetlogger();
	
	invfft=1;
	MAXSIZE=8192;
	MAXWAVES=4;
	
 srand(1);

 RealIn=(float*)malloc(sizeof(float)*MAXSIZE);
 ImagIn=(float*)malloc(sizeof(float)*MAXSIZE);
 RealOut=(float*)malloc(sizeof(float)*MAXSIZE);
 ImagOut=(float*)malloc(sizeof(float)*MAXSIZE);
 coeff=(float*)malloc(sizeof(float)*MAXWAVES);
 amp=(float*)malloc(sizeof(float)*MAXWAVES);

 /* Makes MAXWAVES waves of random amplitude and period */
	for(i=0;i<MAXWAVES;i++) 
	{
		coeff[i] = rand()%1000;
		amp[i] = rand()%1000;
	}
 for(i=0;i<MAXSIZE;i++) 
 {
   /*   RealIn[i]=rand();*/
	 RealIn[i]=0;
	 for(j=0;j<MAXWAVES;j++) 
	 {
		 /* randomly select sin or cos */
		 if (rand()%2)
		 {
		 		RealIn[i]+=coeff[j]*cos(amp[j]*i);
			}
		 else
		 {
		 	RealIn[i]+=coeff[j]*sin(amp[j]*i);
		 }
  	 ImagIn[i]=0;
	 }
 }

 fft_float (MAXSIZE,invfft,RealIn,ImagIn,RealOut,ImagOut);

 //dump statistics
 stoplogger();

 printf("RealOut:\n");
 printf("ImagOut:\n");

 free(RealIn);
 free(ImagIn);
 free(RealOut);
 free(ImagOut);
 free(coeff);
 free(amp);
 exit(0);


}
