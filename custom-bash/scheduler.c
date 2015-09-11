#include <stdio.h>
#include <stdlib.h>

typedef struct process_definition{
  int t0;
  int dt;
  int deadline;
  int priority;
  char *pname;
} * ProcessDefinition;

int main(int argc, char *argv[])
{
  char *tracer_file_name;
  char process_name[16];
  int t0, dt, deadline, priority, status;
  FILE *tracer_file;
  ProcessDefinition PDCollection[64];
  int PDcounter = 0;

  tracer_file_name = argv[1];
  tracer_file = fopen(tracer_file_name, "r");
  while (tracer_file)
  {
    status = fscanf(tracer_file, "%d %s %d %d %d",
      &t0, process_name, &dt, &deadline, &priority);
    if (status == EOF) break;

    PDCollection[PDcounter] = malloc(sizeof(PDCollection));
    PDCollection[PDcounter]->t0 = t0;
    PDCollection[PDcounter]->pname = process_name;
    PDCollection[PDcounter]->dt = dt;
    PDCollection[PDcounter]->deadline = deadline;
    PDCollection[PDcounter]->priority = priority;
    PDcounter++;
  }

  printf("%d %s %d %d %d\n", PDCollection[0]->t0, PDCollection[0]->pname, PDCollection[0]->dt, PDCollection[0]->deadline, PDCollection[0]->priority);
  printf("%d %s %d %d %d\n", PDCollection[1]->t0, PDCollection[1]->pname, PDCollection[1]->dt, PDCollection[1]->deadline, PDCollection[1]->priority);
  fclose(tracer_file);

  return 0;
}
