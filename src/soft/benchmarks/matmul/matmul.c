/*****************************************************************************/
/* File: matmul.c                                                            */
/* Author: Van Bui - ARCADE @ Columbia University                            */
/* Changes: Standard matrix multiplication. Modified I/O to run as baremetal */
/*          and added tracing utility function                               */
/*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#define ROWSIZE 10
#define COLSIZE 10

void matmul(int row, int col, int m1[ROWSIZE][COLSIZE], int m2[ROWSIZE][COLSIZE],int mult[ROWSIZE][COLSIZE]);
int check(int res[ROWSIZE][COLSIZE], int ans[ROWSIZE][COLSIZE]);
void printmatrix(int m1[ROWSIZE][COLSIZE],int row,int col, char name[]);

#include "process_log.c"

int main(int argc, char **argv)
{
  int errors = 0;

  printf("Matrix Matrix Multiply\n");

  //unsigned cycles = 0;
  
  initlogger();
  resetlogger();
  
  //load data
  #include "matmuldat10x10.c"
  
  matmul(ROWSIZE,COLSIZE,m1,m2,res);

  errors = check(res,ans);

  printf("Errors: %d\n", errors);

  //dump statistics                                                            
  stoplogger();
  
  return 0;
}

void matmul(int row, int col, int m1[ROWSIZE][COLSIZE], int m2[ROWSIZE][COLSIZE], int res[ROWSIZE][COLSIZE])
{
  int i,j,k;

  for(i=0;i<row;i++)
    {
      for(j=0;j<col;j++)
        {
          for(k=0;k<row;k++)
            {
              *(res[i]+j)+=((((*(m1[i]+k))*(*(m2[k]+j)))));
            }
        }
    }
}

int check(int res[ROWSIZE][COLSIZE], int ans[ROWSIZE][COLSIZE])
{
  int error=0;
  int i,j;

  for (i=0; i < ROWSIZE; i++)
    for (j=0; j < COLSIZE; j++)
      if (res[i][j] != ans[i][j])
	error+=1;

  return error;
}

void printmatrix(int m1[ROWSIZE][COLSIZE],int row,int col,char name[])
{
  int i,j;

  printf("%s:\n",name);

  for(i=0;i<ROWSIZE;i++){
    for (j=0;j<COLSIZE;j++)
      printf("%d   ",m1[i][j]);
    printf("\n");
  }

  printf("\n\n");

}
