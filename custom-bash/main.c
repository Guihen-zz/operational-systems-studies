#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
  char path[64];
  char *command_line;
  int comand_line_size = 64;
  int readed_chars, child_pid;

  command_line = malloc(64);
  printf("\n");
  while(1) {
    getcwd(path, 64);
    printf("[%s] ", path);

    readed_chars = getline(&command_line, (void *) &comand_line_size, stdin);
    command_line[readed_chars-1] = '\0';

    if ((child_pid = fork()) == 0) {
      execve(command_line, argv, 0);
      return 0;
    }
    else {
      wait(&child_pid);
    }
  }

  printf("\n");
  return 0;
}
