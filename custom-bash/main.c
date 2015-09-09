#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

int cd_command(char *command_line) {
  return (command_line[0] == 'c' && command_line[1] == 'd' && command_line[2] == ' ');
}

char *cmd[] = { "/bin/ls", "-1", NULL };
int main(int argc, char *argv[])
{
  char path[64];
  char *command_line;
  char *command_tokens[6];
  int comand_line_size = 64;
  int readed_chars, child_pid, command_response;

  command_line = malloc(64);
  printf("\n");
  while(1) {
    getcwd(path, 64);
    printf("[%s] ", path);

    readed_chars = getline(&command_line, (void *) &comand_line_size, stdin);
    command_line[readed_chars-1] = '\0';

    if (cd_command(command_line)) {
       command_response = chdir(command_line + 3);
    }
    else {
      if ((child_pid = fork()) == 0) {
        for(int i = 0; i < 6; i++) {
          command_tokens[i] = strsep(&command_line, " ");
        }

        if (execve(command_tokens[0], command_tokens, NULL)) {
          printf("Invalid command\n");
          return 0;
        }
      }
      else {
        wait(&child_pid);
      }
    }
  }

  printf("\n");
  return 0;
}
