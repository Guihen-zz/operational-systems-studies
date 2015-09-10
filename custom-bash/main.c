#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>

int cd_command(char *command_line) {
  return (command_line[0] == 'c' && command_line[1] == 'd' && command_line[2] == ' ');
}

char *cmd[] = { "/bin/ls", "-1", NULL };
int main(int argc, char *argv[])
{
  char path[64];
  char *command_line, *read;
  char *command_tokens[6];
  int comand_line_size = 64;
  int readed_chars, child_pid, command_response;

  command_line = malloc(64);
  printf("\n");
  while(1) {
    getcwd(path, 64);
    sprintf(command_line, "[%s] ", path);

    read = readline(command_line);
    add_history(read);

    if (cd_command(read)) {
       command_response = chdir(read + 3);
    }
    else {
      if ((child_pid = fork()) == 0) {
        for(int i = 0; i < 6; i++) {
          command_tokens[i] = strsep(&read, " ");
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
