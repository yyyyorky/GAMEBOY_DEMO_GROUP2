#include <stdio.h>
#include <math.h>

#define PI 3.14159265

int main(){
  int i;

  printf("SECTION \"Lookup Tables\", ROM0\n");

  printf("sine:\n");
 
  for (i = 0; i < 256; i++)
   printf("  db %d\n", (int)( 63*(1+sin((i*PI)/128) )));   

  printf("cosine:\n");

  for (i = 0; i < 256; i++)
   printf("  db %d\n", (int)( 63*(1+cos((i*PI)/128) )));   
   
  return 0;
}

