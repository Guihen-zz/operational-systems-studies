#include <stdlib.h>
#include <stdio.h>

int main( int argc, char *argv[]) {
  char *tracefile_name;
  FILE *tracefile;
  int memory_size, virtual_memory_size;
  FILE *memory_file, *virtual_memory_file;
  int i;
  short c = -1;

  tracefile_name = argv[1];
  tracefile = fopen( tracefile_name, "r");
  if( tracefile) {
    fscanf( tracefile, "%d %d", &memory_size, &virtual_memory_size);
  } else {
    return 1;
  }

  memory_file = fopen( "/tmp/ep2.mem", "wb");
  for( i = 0; i < memory_size; i++) {
    fwrite( &c, 1, 1, memory_file);
  }
  fclose(memory_file);

  virtual_memory_file = fopen("/tmp/ep2.vir", "wb");
  for( i = 0; i < virtual_memory_size; i++) {
    fwrite( &c, 1, 1, virtual_memory_file);
  }
  fclose(virtual_memory_file);

  return 0;
}
