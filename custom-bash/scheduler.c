#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  char *tracer_file_name;
  char process_name[16];
  int t0, dt, deadline, priority, status;
  void *tracer_content;
  FILE *tracer_file;

  tracer_file_name = argv[1];
  tracer_file = fopen(tracer_file_name, "r");
  while (tracer_file)
  {
    status = fscanf(tracer_file, "%d %s %d %d %d",
      &t0, process_name, &dt, &deadline, &priority);
    if (status == EOF) break;

    printf("%d %s %d %d %d\n", t0, process_name, dt, deadline, priority);
  }
  fclose(tracer_file);

  return 0;
}
