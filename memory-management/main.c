#include <stdlib.h>
#include <stdio.h>

#define EMPTY_SPACE -1

/******************************************************************************/
FILE * generate_memory_file(int size);
FILE * generate_virtual_memory_file(int size);

/******************************************************************************/
int main( int argc, char *argv[]) {
  char *tracefile_name;
  FILE *tracefile;
  int memory_size, virtual_memory_size;
  FILE *memory_file, *virtual_memory_file;

  tracefile_name = argv[1];
  tracefile = fopen( tracefile_name, "r");
  if( tracefile) {
    fscanf( tracefile, "%d %d", &memory_size, &virtual_memory_size);
  } else {
    return 1;
  }

  memory_file = generate_memory_file(memory_size);
  virtual_memory_file = generate_virtual_memory_file(virtual_memory_size);

  fclose(memory_file);
  fclose(virtual_memory_file);
  return 0;
}

/******************************************************************************/
FILE * generate_memory_file(int size) {
  FILE *file = fopen( "/tmp/ep2.mem", "wb");
  short byte = EMPTY_SPACE;
  int i;
  for( i = 0; i < size; i++) fwrite( &byte, 1, 1, file);
  return file;
}

FILE * generate_virtual_memory_file(int size) {
  FILE *file = fopen("/tmp/ep2.vir", "wb");
  short byte = EMPTY_SPACE;
  int i;
  for( i = 0; i < size; i++) fwrite( &byte, 1, 1, file);
  return file;
}
