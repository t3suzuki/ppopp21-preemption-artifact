#!/bin/bash

cd $(dirname $0)

ABT_PATH=../opt/argobots
BOLT_PATH=../opt/bolt

RESULT_DIR=${RESULT_DIR:-${PWD}/results}

mkdir -p $RESULT_DIR

# Size of each tile (NB x NB)
NB=1000

# Lookahead depth for prioritizing the critical path; see the SLATE paper [Gates+ SC19] for details
LOOKAHEAD=8

# Outer parallelism (the number of threads in the outer parallel loop)
OUTER=8

# Inner parallelism (the number of threads spawned at each Intel MKL subroutine)
INNER=8

# The number of nested threads spawned at lookahead updates; see the SLATE paper [Gates+ SC19] for details
SYRK_THREADS=8

# The number of repeats
REPEAT=10

# The number of warmup runs (performance results are not shown during warmup runs)
WARMUP=2

# Problem sizes (the number of tiles: n x n)
SIZES=(8 12 16 20 24)

make clean
CCFLAGS="-DSYRK_NEST_TYPE=SYRK_TASK" make

for nt in ${SIZES[@]}; do
  echo "## ${nt}x${nt}: IOMP (flat)"
  OUT_FILE=${RESULT_DIR}/iomp_flat_nt_${nt}.out
  ERR_FILE=${RESULT_DIR}/iomp_flat_nt_${nt}.err
  OMP_PROC_BIND=1 NUM_THREADS_POTRF=$N_CORES LOOKAHEAD=$LOOKAHEAD NUM_THREADS_SYRK_BATCH=1 NUM_THREADS_SYRK_NEST=1 MKL_NUM_THREADS=1 OMP_NESTED=false MKL_DYNAMIC=false numactl --interleave=all ./app_omp $NB $nt $REPEAT $WARMUP 2> $ERR_FILE | tee $OUT_FILE
done

make clean
CCFLAGS="-DSYRK_NEST_TYPE=SYRK_NEST" make

for nt in ${SIZES[@]}; do
  echo "## ${nt}x${nt}: IOMP (nested)"
  OUT_FILE=${RESULT_DIR}/iomp_nt_${nt}.out
  ERR_FILE=${RESULT_DIR}/iomp_nt_${nt}.err
  KMP_BLOCKTIME=0 KMP_HOT_TEAMS_MAX_LEVEL=2 KMP_HOT_TEAMS_MODE=1 NUM_THREADS_POTRF=$OUTER LOOKAHEAD=$LOOKAHEAD NUM_THREADS_SYRK_BATCH=$SYRK_THREADS NUM_THREADS_SYRK_NEST=$SYRK_THREADS MKL_NUM_THREADS=$INNER OMP_NESTED=true MKL_DYNAMIC=false numactl --interleave=all ./app_omp $NB $nt $REPEAT $WARMUP 2> $ERR_FILE | tee $OUT_FILE

  echo "## ${nt}x${nt}: BOLT (preemptive, intvl = 1 ms)"
  OUT_FILE=${RESULT_DIR}/bolt_preemptive_intvl_1000_nt_${nt}.out
  ERR_FILE=${RESULT_DIR}/bolt_preemptive_intvl_1000_nt_${nt}.err
  KMP_ABT_WORK_STEAL_FREQ=4 KMP_ABT_FORK_CUTOFF=4 KMP_ABT_FORK_NUM_WAYS=4 ABT_SET_AFFINITY=1 KMP_BLOCKTIME=0 KMP_HOT_TEAMS_MAX_LEVEL=2 KMP_HOT_TEAMS_MODE=1 NUM_THREADS_POTRF=$OUTER LOOKAHEAD=$LOOKAHEAD NUM_THREADS_SYRK_BATCH=$SYRK_THREADS NUM_THREADS_SYRK_NEST=$SYRK_THREADS OMP_PROC_BIND=close,unset KMP_ABT_NUM_ESS=$N_CORES MKL_NUM_THREADS=$INNER ABT_THREAD_STACKSIZE=150000 ABT_MEM_MAX_NUM_STACKS=80 ABT_MEM_LP_ALLOC=malloc LD_PRELOAD=$(pwd)/libmklyield_skylake_sched.so:${LD_PRELOAD} LD_LIBRARY_PATH=${BOLT_PATH}/lib:${ABT_PATH}/lib:${LD_LIBRARY_PATH} MKL_DYNAMIC=false ABT_PREEMPTION_INTERVAL_USEC=1000 ABT_INITIAL_NUM_SUB_XSTREAMS=40 numactl --interleave=all ./app_omp $NB $nt $REPEAT $WARMUP 2> $ERR_FILE | tee $OUT_FILE

  echo "## ${nt}x${nt}: BOLT (preemptive, intvl = 10 ms)"
  OUT_FILE=${RESULT_DIR}/bolt_preemptive_intvl_10000_nt_${nt}.out
  ERR_FILE=${RESULT_DIR}/bolt_preemptive_intvl_10000_nt_${nt}.err
  KMP_ABT_WORK_STEAL_FREQ=4 KMP_ABT_FORK_CUTOFF=4 KMP_ABT_FORK_NUM_WAYS=4 ABT_SET_AFFINITY=1 KMP_BLOCKTIME=0 KMP_HOT_TEAMS_MAX_LEVEL=2 KMP_HOT_TEAMS_MODE=1 NUM_THREADS_POTRF=$OUTER LOOKAHEAD=$LOOKAHEAD NUM_THREADS_SYRK_BATCH=$SYRK_THREADS NUM_THREADS_SYRK_NEST=$SYRK_THREADS OMP_PROC_BIND=close,unset KMP_ABT_NUM_ESS=$N_CORES MKL_NUM_THREADS=$INNER ABT_THREAD_STACKSIZE=150000 ABT_MEM_MAX_NUM_STACKS=80 ABT_MEM_LP_ALLOC=malloc LD_PRELOAD=$(pwd)/libmklyield_skylake_sched.so:${LD_PRELOAD} LD_LIBRARY_PATH=${BOLT_PATH}/lib:${ABT_PATH}/lib:${LD_LIBRARY_PATH} MKL_DYNAMIC=false ABT_PREEMPTION_INTERVAL_USEC=10000 ABT_INITIAL_NUM_SUB_XSTREAMS=40 numactl --interleave=all ./app_omp $NB $nt $REPEAT $WARMUP 2> $ERR_FILE | tee $OUT_FILE

  echo "## ${nt}x${nt}: BOLT (nonpreemptive)"
  OUT_FILE=${RESULT_DIR}/bolt_nonpreemptive_nt_${nt}.out
  ERR_FILE=${RESULT_DIR}/bolt_nonpreemptive_nt_${nt}.err
  KMP_ABT_WORK_STEAL_FREQ=4 KMP_ABT_FORK_CUTOFF=4 KMP_ABT_FORK_NUM_WAYS=4 ABT_SET_AFFINITY=1 KMP_BLOCKTIME=0 KMP_HOT_TEAMS_MAX_LEVEL=2 KMP_HOT_TEAMS_MODE=1 NUM_THREADS_POTRF=$OUTER LOOKAHEAD=$LOOKAHEAD NUM_THREADS_SYRK_BATCH=$SYRK_THREADS NUM_THREADS_SYRK_NEST=$SYRK_THREADS OMP_PROC_BIND=close,unset KMP_ABT_NUM_ESS=$N_CORES MKL_NUM_THREADS=$INNER ABT_THREAD_STACKSIZE=150000 ABT_MEM_MAX_NUM_STACKS=80 ABT_MEM_LP_ALLOC=malloc LD_PRELOAD=$(pwd)/libmklyield_skylake.so:${LD_PRELOAD} LD_LIBRARY_PATH=${BOLT_PATH}/lib:${ABT_PATH}/lib:${LD_LIBRARY_PATH} MKL_DYNAMIC=false ABT_PREEMPTION_INTERVAL_USEC=1000000000 ABT_INITIAL_NUM_SUB_XSTREAMS=1 numactl --interleave=all ./app_omp $NB $nt $REPEAT $WARMUP 2> $ERR_FILE | tee $OUT_FILE
done
