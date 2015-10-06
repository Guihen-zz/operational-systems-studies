#include <stdlib.h>
#include <stdio.h>

int main( int argc, char *argv[]) {
  char *tracefile_name;
  FILE *tracefile;
  int memory_size, virtual_memory_size;

  tracefile_name = argv[1];
  tracefile = fopen( tracefile_name, "r");
  if( tracefile) {
    fscanf(tracefile, "%d %d", &memory_size, &virtual_memory_size);
  } else {
    return 1;
  }

  printf("%d %d", memory_size, virtual_memory_size);

  return 0;
}
