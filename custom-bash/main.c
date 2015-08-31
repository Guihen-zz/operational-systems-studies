#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
  char path[64];
  int cmdlinesize = 64;
  char *cmdline;

  getcwd(path, 64);
  cmdline = malloc(64);
  while(1) {
    printf("\n[%s] ", path);
    getline(&cmdline, (void *) &cmdlinesize, stdin);
    printf("%s", cmdline);
  }

  printf("\n");
  return 0;
}
