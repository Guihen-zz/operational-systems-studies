#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
  char path[64];
  getcwd(path, 64);
  printf("\n[%s] ", path);
  printf("\n");
  return 0;
}
