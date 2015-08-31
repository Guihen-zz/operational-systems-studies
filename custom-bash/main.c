#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
  char path[64];
  char *cmdline;
  int cmdlinesize = 64;
  int readedchars, childpid;

  getcwd(path, 64);
  cmdline = malloc(64);
  printf("\n");
  while(1) {
    printf("[%s] ", path);

    readedchars = getline(&cmdline, (void *) &cmdlinesize, stdin);
    cmdline[readedchars-1] = '\0';

    if ((childpid = fork()) == 0) {
      execve(cmdline, argv, 0);
    }
    else {
      wait(&childpid);
    }
  }

  printf("\n");
  return 0;
}
