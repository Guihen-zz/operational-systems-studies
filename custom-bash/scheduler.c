#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#define FCFS 1

typedef struct process_definition{
  int t0;
  int dt;
  int deadline;
  int priority;
  char *pname;
} * ProcessDefinition;

void *perform(void *argument)
{
  ProcessDefinition pd = argument;
  struct timeval start, end;
  long secs_used = 0;
  while (secs_used < pd->dt)
  {
    printf("%s\n", pd->pname);
    gettimeofday(&start, NULL);
    usleep(1000000);
    gettimeofday(&end, NULL);
    secs_used += (end.tv_sec - start.tv_sec);
  }

  printf("time: %ld\n", secs_used);
  return NULL;
}

int main(int argc, char *argv[])
{
  char *tracer_file_name;
  int scheduler_mode;
  char process_name[16];
  int t0, dt, deadline, priority, status;
  FILE *tracer_file;
  ProcessDefinition PDCollection[64];
  int PDcounter = 0, started_threads_counter = 0;
  struct timeval started_time, time_now;
  long elapsed_time;
  pthread_t *threads;

  scheduler_mode = atoi(argv[1]);
  tracer_file_name = argv[2];
  tracer_file = fopen(tracer_file_name, "r");
  while (tracer_file)
  {
    status = fscanf(tracer_file, "%d %s %d %d %d",
      &t0, process_name, &dt, &deadline, &priority);
    if (status == EOF) break;

    PDCollection[PDcounter] = malloc(sizeof(PDCollection));
    PDCollection[PDcounter]->pname = malloc(32);
    strcpy(PDCollection[PDcounter]->pname, process_name);

    PDCollection[PDcounter]->t0 = t0;
    PDCollection[PDcounter]->dt = dt;
    PDCollection[PDcounter]->deadline = deadline;
    PDCollection[PDcounter]->priority = priority;
    PDcounter++;
  }
  fclose(tracer_file);

  for(int i = 0; i < PDcounter; i++)
  {
    printf("%d %s %d %d %d\n", PDCollection[i]->t0, PDCollection[i]->pname, PDCollection[i]->dt, PDCollection[i]->deadline, PDCollection[i]->priority);
  }

  threads = malloc(sizeof(* threads) * PDcounter);
  gettimeofday(&started_time, NULL);
  while(started_threads_counter < PDcounter)
  {
    gettimeofday(&time_now, NULL);
    elapsed_time = (time_now.tv_sec - started_time.tv_sec);
    if(elapsed_time >= PDCollection[started_threads_counter]->t0)
    {
      pthread_create(&threads[started_threads_counter], NULL, perform, PDCollection[started_threads_counter]);
      started_threads_counter++;
    }
    else
    {
      usleep(100000);
    }

    switch (scheduler_mode) {
      case FCFS:
        // DO NOTHING
        break;
    }

  }

  for(int i = 0; i < PDcounter; i++)
  {
    pthread_join(threads[i], NULL);
  }

  return 0;
}
