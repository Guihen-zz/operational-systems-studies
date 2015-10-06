#include <stdlib.h>
#include <stdio.h>

#define EMPTY_SPACE -1
#define PROCESS_NAME_MAX_LENGHT 16
#define MAX_PROCESS_SIZE 32
#define MAX_ACCESS_REQUEST 16
struct access_request {
  float t;
  int p;
};

typedef struct process_definition {
  float t0;
  float tf;
  char name[PROCESS_NAME_MAX_LENGHT];
  int b;
  struct access_request access_requests[MAX_ACCESS_REQUEST];
  int access_requests_counter;
} *ProcessDefinition;

typedef struct experiment {
  ProcessDefinition *trials;
  int trials_counter;
} * Experiment;

/******************************************************************************/
FILE * generate_memory_file(int size);
FILE * generate_virtual_memory_file(int size);
Experiment generate_experiment(FILE *);

/******************************************************************************/
int main( int argc, char *argv[]) {
  char *tracefile_name;
  FILE *tracefile;
  int memory_size, virtual_memory_size;
  FILE *memory_file, *virtual_memory_file;
  Experiment experiment;
  int i;
  struct access_request access_request;

  tracefile_name = argv[1];
  tracefile = fopen( tracefile_name, "r");
  if( tracefile) {
    fscanf( tracefile, "%d %d", &memory_size, &virtual_memory_size);
  } else {
    return 1;
  }

  memory_file = generate_memory_file(memory_size);
  virtual_memory_file = generate_virtual_memory_file(virtual_memory_size);
  experiment = generate_experiment(tracefile);

  printf("%f %s %f %d\n",
    experiment->trials[0]->t0,
    experiment->trials[0]->name,
    experiment->trials[0]->tf,
    experiment->trials[0]->b);

  for(i = 0; experiment->trials[0]->access_requests_counter > i; i++) {
    printf("%f %d\n", experiment->trials[0]->access_requests[i].t, experiment->trials[0]->access_requests[i].p);
  }

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

Experiment generate_experiment(FILE *tracefile) {
  Experiment experiment = malloc(sizeof(*experiment));
  ProcessDefinition process_definition;
  int access_requests_counter, pi;
  float ti;

  experiment->trials = malloc(sizeof(*experiment->trials)* MAX_PROCESS_SIZE);
  process_definition = malloc(sizeof(*process_definition));
  fscanf(tracefile, "%f %s %f %d",
    &process_definition->t0,
    process_definition->name,
    &process_definition->tf,
    &process_definition->b);

  access_requests_counter = 0;
  while(1) {
    if( fscanf(tracefile, "%f", &ti) == EOF || ti == '\n') break;

    fscanf(tracefile, "%d", &pi);
    process_definition->access_requests[access_requests_counter].t = ti;
    process_definition->access_requests[access_requests_counter].p = pi;
    access_requests_counter++;
  }

  process_definition->access_requests_counter = access_requests_counter;
  experiment->trials[0] = process_definition;
  experiment->trials_counter = 0;
  return experiment;
}
