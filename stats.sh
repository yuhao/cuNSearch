dumpstats() {
  cat $1 | grep "time Total time" | awk '{print $4}'
}

### R/K N-BODY ###
rk_nbody() {
  for k in 1 4 16 32 50 64 128
  do
    echo -n "k "$k" "
    dumpstats "nbody-9m-r32-k$k.out"
  done
  for r in 1 2 8 10 32 128
  do
    echo -n "r "$r" "
    dumpstats "nbody-9m-r$r-k50.out"
  done
}

### ALL EVAL ###
all_eval() {
  echo -n "kitti-120k "
  dumpstats "kitti-120k-r2-k50.out"
  echo -n "kitti-1m "
  dumpstats "kitti-1m-r2-k50.out"
  echo -n "kitti-6m "
  dumpstats "kitti-6m-r2-k50.out"
  echo -n "kitti-12m "
  dumpstats "kitti-12m-r2-k50.out"
  echo -n "kitti-25m "
  dumpstats "kitti-25m-r2-k50.out"
  
  echo -n "nbody-9m "
  dumpstats "nbody-9m-r32-k50.out"
  echo -n "nbody-10m "
  dumpstats "nbody-10m-r32-k50.out"
  
  echo -n "bunny "
  dumpstats "bunny-r0.05-k50.out"
  echo -n "dragon "
  dumpstats "dragon-r2-k50.out"
  echo -n "buddha "
  dumpstats "buddha-r0.05-k50.out"
}

### R/K KITTI ###
rk_kitti() {
  for k in 1 4 16 32 50 64 100 128 200
  do
    echo -n "k "$k" "
    dumpstats "kitti-6m-r2-k${k}.out"
  done
  for r in 0.01 0.1 2 16 50
  do
    echo -n "r "$r" "
    dumpstats "kitti-6m-r${r}-k50.out"
  done
}

### R/K GRAPHICS ###
rk_graphics() {
  for k in 1 4 16 32 50 64 128
  do
    echo -n "k "$k" "
    dumpstats "buddha-r0.05-k${k}.out"
  done
  for r in 0.001 0.005 0.01 0.05 0.1 0.2
  do
    echo -n "r "$r" "
    dumpstats "buddha-r${r}-k50.out"
  done
}

rk_kitti
rk_nbody
rk_graphics
exit
all_eval
