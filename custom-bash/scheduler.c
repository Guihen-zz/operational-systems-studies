#define _GNU_SOURCE
#include <sys/sysinfo.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <sched.h>

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

void fcfs(ProcessDefinition *, int process_counter);

int main(int argc, char *argv[])
{
  int i;
  char *tracer_file_name;
  int scheduler_mode;
  char process_name[16];
  int t0, dt, deadline, priority, status;
  FILE *tracer_file;
  ProcessDefinition PDCollection[64];
  int pd_counter = 0;

  scheduler_mode = atoi(argv[1]);
  tracer_file_name = argv[2];
  tracer_file = fopen(tracer_file_name, "r");
  while (tracer_file)
  {
    status = fscanf(tracer_file, "%d %s %d %d %d",
      &t0, process_name, &dt, &deadline, &priority);
    if (status == EOF) break;

    PDCollection[pd_counter] = malloc(sizeof(PDCollection));
    PDCollection[pd_counter]->pname = malloc(32);
    strcpy(PDCollection[pd_counter]->pname, process_name);

    PDCollection[pd_counter]->t0 = t0;
    PDCollection[pd_counter]->dt = dt;
    PDCollection[pd_counter]->deadline = deadline;
    PDCollection[pd_counter]->priority = priority;
    pd_counter++;
  }
  fclose(tracer_file);

  for(i = 0; i < pd_counter; i++)
  {
    printf("%d %s %d %d %d\n", PDCollection[i]->t0, PDCollection[i]->pname, PDCollection[i]->dt, PDCollection[i]->deadline, PDCollection[i]->priority);
  }

  switch (scheduler_mode) {
    case FCFS:
      fcfs(PDCollection, pd_counter);
      break;
  }

  return 0;
}

void fcfs(ProcessDefinition *PDCollection, int pd_counter)
{
  struct timeval started_time, time_now;
  int started_threads_counter = 0;
  int cpu_cores, allocated_cpu_cores = 0;
  long elapsed_time;
  pthread_t *threads;
  cpu_set_t cpuset;
  int i;

  cpu_cores = sysconf(_SC_NPROCESSORS_ONLN);
  threads = malloc(sizeof(* threads) * pd_counter);
  gettimeofday(&started_time, NULL);
  while(started_threads_counter < pd_counter)
  {
    if(allocated_cpu_cores < cpu_cores)
    {
      gettimeofday(&time_now, NULL);
      elapsed_time = (time_now.tv_sec - started_time.tv_sec);
      if(elapsed_time >= PDCollection[started_threads_counter]->t0)
      {
        pthread_create(&threads[started_threads_counter], NULL, perform, PDCollection[started_threads_counter]);

        CPU_ZERO(&cpuset);
        CPU_SET(allocated_cpu_cores, &cpuset);
        pthread_setaffinity_np(threads[started_threads_counter], sizeof(cpu_set_t), &cpuset);

        started_threads_counter++;
        allocated_cpu_cores++;
      }
      else
      {
        usleep(100000);
      }

    }
  }

  for(i = 0; i < pd_counter; i++)
  {
    pthread_join(threads[i], NULL);
  }
}
