#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <sys/time.h>
#include <unistd.h>


#define EMPTY_SPACE 255
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
  char pid;
} *ProcessDefinition;

typedef struct experiment {
  ProcessDefinition *trials;
  int trials_counter;
} * Experiment;

struct memory_usage {
  char status; /* 0: empty, 1: assigned */
  char pid;
  int begin;
  int size;
  struct memory_usage * next;
  struct memory_usage * prev;
};

/******************************************************************************/
struct memory_usage * MEMORY_USAGE;
struct memory_usage * VIRTUAL_MEMORY_USAGE;

/******************************************************************************/
FILE * generate_memory_file(int size);
FILE * generate_virtual_memory_file(int size);
Experiment generate_experiment(FILE *);
void * perform( void *);
void memory_request(ProcessDefinition, struct access_request);
void memory_assign_block(ProcessDefinition);
struct memory_usage * memory_swap(int block_size);

/******************************************************************************/
int main( int argc, char *argv[]) {
  char *tracefile_name;
  FILE *tracefile, *memory_file, *virtual_memory_file;
  int memory_size, virtual_memory_size;
  Experiment experiment;
  int i, j;
  struct access_request access_request;
  size_t len = 0;
  ssize_t read;
  pthread_t *threads;
  char *line = malloc(128);
  char c;
  struct memory_usage *memory_usage_cursor;

  tracefile_name = argv[1];
  tracefile = fopen( tracefile_name, "r");
  if( tracefile) {
    read = getline(&line, &len, tracefile);
    sscanf( line, "%d %d", &memory_size, &virtual_memory_size);
  } else {
    return 1;
  }

  memory_file = generate_memory_file(memory_size);
  fclose(memory_file);
  virtual_memory_file = generate_virtual_memory_file(virtual_memory_size);
  fclose(virtual_memory_file);

  MEMORY_USAGE = malloc(sizeof(* MEMORY_USAGE));
  MEMORY_USAGE->status = 0;
  MEMORY_USAGE->begin = 0;
  MEMORY_USAGE->size = memory_size;
  MEMORY_USAGE->next = NULL;
  MEMORY_USAGE->prev = NULL;

  VIRTUAL_MEMORY_USAGE = malloc(sizeof(* VIRTUAL_MEMORY_USAGE));
  VIRTUAL_MEMORY_USAGE->status = 0;
  VIRTUAL_MEMORY_USAGE->begin = 0;
  VIRTUAL_MEMORY_USAGE->size = virtual_memory_size;
  VIRTUAL_MEMORY_USAGE->next = NULL;
  VIRTUAL_MEMORY_USAGE->prev = NULL;

  experiment = generate_experiment(tracefile);

  threads = malloc(sizeof(* threads) * experiment->trials_counter);
  for(j = 0; j < experiment->trials_counter; j++) {
    pthread_create(&threads[j], NULL, perform, experiment->trials[j]);
  }

  for(j = 0; j < experiment->trials_counter; j++) {
    pthread_join(threads[j], NULL);
  }

  memory_file = fopen("/tmp/ep2.mem", "rb");
  while(fscanf(memory_file, "%c", &c) != EOF) {
    printf("%hhd", c);
  }
  printf("\n");
  fclose(memory_file);

  memory_file = fopen("/tmp/ep2.vir", "rb");
  while(fscanf(memory_file, "%c", &c) != EOF) {
    printf("%hhd", c);
  }
  printf("\n");
  fclose(memory_file);

  for(  memory_usage_cursor = MEMORY_USAGE; memory_usage_cursor != NULL;
        memory_usage_cursor = memory_usage_cursor->next) {
    printf("[%d, %d] : %d -> ", memory_usage_cursor->begin, memory_usage_cursor->begin + memory_usage_cursor->size, memory_usage_cursor->status);
  }
  printf("\n");

  for(  memory_usage_cursor = VIRTUAL_MEMORY_USAGE; memory_usage_cursor != NULL;
        memory_usage_cursor = memory_usage_cursor->next) {
    printf("[%d, %d] : %d -> ", memory_usage_cursor->begin, memory_usage_cursor->begin + memory_usage_cursor->size, memory_usage_cursor->status);
  }
  printf("\n");

  return 0;
}

/******************************************************************************/
FILE * generate_memory_file(int size) {
  FILE *file = fopen( "/tmp/ep2.mem", "w");
  short byte = EMPTY_SPACE;
  int i;
  for( i = 0; i < size; i++) fwrite( &byte, 1, 1, file);
  return file;
}

FILE * generate_virtual_memory_file(int size) {
  FILE *file = fopen("/tmp/ep2.vir", "wb");
  char byte = EMPTY_SPACE;

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
  char pid = 1;

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
    process_definition->pid = pid++;
    memory_assign_block(process_definition);
    experiment->trials[trials_counter] = process_definition;
    trials_counter++;
  }

  experiment->trials_counter = trials_counter;
  return experiment;
}

void * perform(void *argument)
{
  ProcessDefinition pd = argument;
  struct timeval start, now;
  long elapsed_time = 0;
  int access_request_index = 0;

  gettimeofday(&start, NULL);
  usleep(pd->t0 * 1000);
  printf("starting %s\n", pd->name);

  while (elapsed_time < pd->tf)
  {
    gettimeofday(&now, NULL);
    elapsed_time = (now.tv_sec - start.tv_sec);

    if(pd->access_requests[access_request_index].t <= elapsed_time) {
      memory_request(pd, pd->access_requests[access_request_index]);
      access_request_index++;
    }
  }

  printf("%s time: %ld\n", pd->name, elapsed_time);
  return NULL;
}

void memory_request(ProcessDefinition pd, struct access_request ar) {
  FILE * memory_file;
  struct memory_usage * memory_usage_cursor;

  for(  memory_usage_cursor = MEMORY_USAGE;
        memory_usage_cursor != NULL && memory_usage_cursor->pid == pd->pid;
        memory_usage_cursor = memory_usage_cursor->next);

  if( memory_usage_cursor != NULL) {
    memory_file = fopen("/tmp/ep2.mem", "r+b");
    fseek(memory_file, memory_usage_cursor->begin + ar.p, SEEK_SET);
    fwrite(&pd->pid, 1, 1, memory_file);
    fclose(memory_file);
  }
  // else get from virtual memory
}

void memory_assign_block(ProcessDefinition pd) {
  struct memory_usage * memory_usage_cursor, * aux;
  FILE * memory_file;
  int i;

  for(  memory_usage_cursor = MEMORY_USAGE; memory_usage_cursor != NULL;
        memory_usage_cursor = memory_usage_cursor->next) {

    if( memory_usage_cursor->status == 0 &&
        memory_usage_cursor->size > pd->b) {
      break;
    }
  }

  // if memory_usage_cursor == NULL: use virtual memory
  if( memory_usage_cursor == NULL) {
    memory_usage_cursor = memory_swap(pd->b);
  }
  aux = malloc(sizeof(* aux));

  aux->begin = memory_usage_cursor->begin + pd->b;
  aux->size = memory_usage_cursor->size - pd->b;
  aux->status = 0;
  aux->next = memory_usage_cursor->next;
  aux->prev = memory_usage_cursor;

  memory_usage_cursor->next = aux;
  memory_usage_cursor->size = pd->b;
  memory_usage_cursor->status = 1;
  memory_usage_cursor->pid = pd->pid;

  memory_file = fopen("/tmp/ep2.mem", "r+b");
  for( i = memory_usage_cursor->begin; i < memory_usage_cursor->begin + memory_usage_cursor->size; i++) {
    fseek(memory_file, i, SEEK_SET);
    fwrite(&pd->pid, 1, 1, memory_file);
  }
  fclose(memory_file);
}

struct memory_usage * memory_swap(int block_size) {
  struct memory_usage * memory_usage_cursor, * virtual_memory_cursor, *aux, *current;
  int swapped_size;

  for(  memory_usage_cursor = MEMORY_USAGE, swapped_size = 0;
        swapped_size < block_size; memory_usage_cursor = current) {
    for(  virtual_memory_cursor = VIRTUAL_MEMORY_USAGE;
          virtual_memory_cursor->status == 1;
          virtual_memory_cursor = virtual_memory_cursor->next);

    printf("%d\n", swapped_size);
    fflush(stdout);
    current = memory_usage_cursor->next;
    aux = memory_usage_cursor->prev;
    if(aux != NULL) {
      aux->size = aux->size + memory_usage_cursor->size;
      aux->next = memory_usage_cursor->next;
    }
    if(memory_usage_cursor->next != NULL) {
      memory_usage_cursor->next->prev = aux;
    }

    aux = virtual_memory_cursor->prev;

    if(aux != NULL) {
      aux->next = memory_usage_cursor;
    }

    memory_usage_cursor->prev = aux;
    memory_usage_cursor->next = virtual_memory_cursor;
    virtual_memory_cursor->prev = memory_usage_cursor;
    memory_usage_cursor->begin = virtual_memory_cursor->begin;
    virtual_memory_cursor->begin = memory_usage_cursor->begin + memory_usage_cursor->size;
    virtual_memory_cursor->size = virtual_memory_cursor->size - memory_usage_cursor->size;

    swapped_size += memory_usage_cursor->size;
  }

  return MEMORY_USAGE;
}
