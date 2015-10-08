#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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
  char *name;
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
  int i, j;
  struct access_request access_request;
  size_t len = 0;
  ssize_t read;
  char *line = malloc(128);

  tracefile_name = argv[1];
  tracefile = fopen( tracefile_name, "r");
  if( tracefile) {
    read = getline(&line, &len, tracefile);
    sscanf( line, "%d %d", &memory_size, &virtual_memory_size);
  } else {
    return 1;
  }

  memory_file = generate_memory_file(memory_size);
  virtual_memory_file = generate_virtual_memory_file(virtual_memory_size);
  experiment = generate_experiment(tracefile);

  for(j = 0; j < experiment->trials_counter; j++) {
    printf("%f %s %f %d\n",
      experiment->trials[j]->t0,
      experiment->trials[j]->name,
      experiment->trials[j]->tf,
      experiment->trials[j]->b);

    for(i = 0; experiment->trials[j]->access_requests_counter > i; i++) {
      printf("%f %d ", experiment->trials[j]->access_requests[i].t, experiment->trials[j]->access_requests[i].p);
    }
    printf("\n");
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
  int access_requests_counter, trials_counter, pi;
  float ti;
  int end_of_file = 0;
  char *line = malloc(128);
  size_t len = 0;
  ssize_t read;
  char *token;
  char  *str;
  float f;
  int i;

  experiment->trials = malloc(sizeof(ProcessDefinition)* MAX_PROCESS_SIZE);
  trials_counter = 0;
  while( (read = getline(&line, &len, tracefile)) > 0) {
    process_definition = malloc( sizeof( *process_definition));

    token = strsep(&line, " ");
    sscanf(token, "%f", &f);
    process_definition->t0 = f;

    process_definition->name = strsep(&line, " ");

    token = strsep(&line, " ");
    sscanf(token, "%f", &f);
    process_definition->tf = f;

    token = strsep(&line, " ");
    sscanf(token, "%d", &i);
    process_definition->b = i;

    access_requests_counter = 0;
    while(line != NULL) {
      token = strsep(&line, " ");
      sscanf(token, "%f", &ti);

      token = strsep(&line, " ");
      sscanf(token, "%d", &pi);

      process_definition->access_requests[access_requests_counter].t = ti;
      process_definition->access_requests[access_requests_counter].p = pi;
      access_requests_counter++;
    }

    process_definition->access_requests_counter = access_requests_counter;
    experiment->trials[trials_counter] = process_definition;
    trials_counter++;
  }

  experiment->trials_counter = trials_counter;
  return experiment;
}
