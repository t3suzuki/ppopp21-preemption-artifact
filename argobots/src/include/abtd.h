/* -*- Mode: C; c-basic-offset:4 ; indent-tabs-mode:nil ; -*- */
/*
 * See COPYRIGHT in top-level directory.
 */

#ifndef ABTD_H_INCLUDED
#define ABTD_H_INCLUDED

#define __USE_GNU
#include <pthread.h>
#include "abtd_ucontext.h"

/* Atomic Functions */
#include "abtd_atomic.h"

/* Data Types */
typedef pthread_t           ABTD_xstream_context;
typedef pthread_mutex_t     ABTD_xstream_mutex;
#ifdef HAVE_PTHREAD_BARRIER_INIT
typedef pthread_barrier_t   ABTD_xstream_barrier;
#else
typedef void *              ABTD_xstream_barrier;
#endif
typedef abt_ucontext_t      ABTD_thread_context;
typedef timer_t             ABTD_signal_timer;

/* ES Storage Qualifier */
#define ABTD_XSTREAM_LOCAL  __thread

/* Environment */
void ABTD_env_init(ABTI_global *p_global);

/* ES Context */
int ABTD_xstream_context_create(void *(*f_xstream)(void *), void *p_arg,
                                ABTD_xstream_context *p_ctx);
int ABTD_xstream_context_free(ABTD_xstream_context *p_ctx);
int ABTD_xstream_context_join(ABTD_xstream_context ctx);
int ABTD_xstream_context_exit(void);
int ABTD_xstream_context_self(ABTD_xstream_context *p_ctx);

/* ES Affinity */
void ABTD_affinity_init(void);
void ABTD_affinity_finalize(void);
int ABTD_affinity_set(ABTD_xstream_context ctx, int rank);
int ABTD_affinity_set_cpuset(ABTD_xstream_context ctx, int cpuset_size,
                             int *p_cpuset);
int ABTD_affinity_get_cpuset(ABTD_xstream_context ctx, int cpuset_size,
                             int *p_cpuset, int *p_num_cpus);

/* Signal */
int ABTD_signal_timer_set_handler(void (*handler)(int));
int ABTD_signal_change_num_es_set_handler();
int ABTD_signal_timer_create(ABTD_signal_timer *timer);
int ABTD_signal_timer_settime(uint64_t freq_nsec, ABTD_signal_timer timer);
int ABTD_signal_timer_settime_abs(uint64_t offset_nsec, uint64_t intvl_nsec,
                                  ABTD_signal_timer timer);
int ABTD_signal_timer_stop(ABTD_signal_timer timer);
int ABTD_signal_timer_delete(ABTD_signal_timer timer);
int ABTD_signal_timer_kill(ABTD_xstream_context ctx);
int ABTD_signal_timer_block(void);
int ABTD_signal_timer_unblock(void);
int ABTD_signal_change_num_es_block(void);
int ABTD_signal_sleep(void (*callback_fn)(void *), void *p_arg);
int ABTD_signal_wakeup(ABTD_xstream_context ctx);
int ABTD_futex_sleep(int *p_sleep_flag,
                     void (*callback_fn)(void *), void *p_arg);
int ABTD_futex_wakeup(int *p_sleep_flag);

#include "abtd_stream.h"

/* ULT Context */
#include "abtd_thread.h"
void ABTD_thread_exit(ABTI_thread *p_thread);
void ABTD_thread_cancel(ABTI_thread *p_thread);

#if defined(ABT_CONFIG_USE_CLOCK_GETTIME)
#include <time.h>
typedef struct timespec ABTD_time;

#elif defined(ABT_CONFIG_USE_MACH_ABSOLUTE_TIME)
#include <mach/mach_time.h>
typedef uint64_t ABTD_time;

#elif defined(ABT_CONFIG_USE_GETTIMEOFDAY)
#include <sys/time.h>
typedef struct timeval ABTD_time;

#endif

void   ABTD_time_init(void);
int    ABTD_time_get(ABTD_time *p_time);
double ABTD_time_read_sec(ABTD_time *p_time);

#endif /* ABTD_H_INCLUDED */
