#!/bin/bash
file=restore.tar
first=14
last=20
#
export TAPE=/dev/nst0
currdir=$PWD
curr=$first
while [ $curr -le $last ]; do
  amtape part slot $curr
  mt rewind
  # read label
  tp=$(dd if=$TAPE bs=32k | head -1 | awk '{print $6}')
  echo $tp
  out=$file.$tp
  mkdir $tp
  cd $tp
  # all parts of size 600G
  ex=0
  while [ $ex -eq 0 ]; do
    # read part from header
    dd if=$TAPE bs=32K of=hdr.$out count=1
    pt=$(cat hdr.$out | head -1 | awk -F " |/" '{print $9}')
    part=$(printf '%02d' $pt)
    # read data
    echo dd if=$TAPE bs=32K of=$out.$part
    dd if=$TAPE bs=32K of=$out.$part
    ex=$?
  done
  mt rewind
  cd $currdir
  curr=$((++curr))
done

