#include <stdio.h>
#include <math.h>

#define PI 3.14159265

int main(){
  int i;

  printf("SECTION \"Lookup Tables 2\", ROM0\n");

  printf("sine2:\n");
 
  for (i = 0; i < 256; i++)
   printf("  db %d\n", (int)( 16*(1+sin((i*PI)/32) )));   

  printf("cosine2:\n");

  for (i = 0; i < 256; i++)
   printf("  db %d\n", (int)( 16*(1+cos((i*PI)/32) )));   
   
  return 0;
}

