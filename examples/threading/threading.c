#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: DONE: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    
    
    struct thread_data* data = (struct thread_data*)thread_param;
    
    printf("sleeping before locking\n");
    // Sleep for wait_to_obtain_ms milliseconds
    usleep(data->wait_to_obtain_ms * 1000);

    printf("Obtaining mutex\n");
    // Obtain the mutex
    pthread_mutex_lock(data->mutex);

    printf("Holding mutex\n");
    // Hold the mutex for wait_to_release_ms milliseconds
    usleep(data->wait_to_release_ms * 1000);

    printf("Releasing mutex\n");
    // Release the mutex
    pthread_mutex_unlock(data->mutex);

    printf("Updating complete status\n");
    // Mark thread completion as successful
    data->thread_complete_success = true;

    // Return the thread data
    return(data);
    
 
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: DONE: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
     
     
     // Allocate memory for thread_data
     
    struct thread_data* thread_data = malloc(sizeof(struct thread_data));
    if (thread_data == NULL) {
        return false;  // Memory allocation failed
    }
     
     
     //Setup Mutex variable
     thread_data->mutex = mutex;
     // Set wait time 
     thread_data->wait_to_obtain_ms = wait_to_obtain_ms;
     thread_data->wait_to_release_ms = wait_to_release_ms;
     thread_data->thread_complete_success = false;
     
     
     //Crete a thread using threadfunc() as entry point
     int result = pthread_create(thread, NULL, threadfunc, thread_data);
    if (result != 0) {
        free(thread_data);
        return false;  // Failed to start the thread
    }
    
    // Thread started successfully 
    return true;
}

