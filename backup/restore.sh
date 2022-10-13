#!/bin/bash
usage="$0 first-tape last-tape"
if [[ $# -ne 2 ]]; then echo $usage; exit; fi
# extract tar files from tape sets
export TAPE=/dev/nst0
curr=$1
last=$2
while [ $curr -le $last ]; do
  amtape part slot $curr
  mt rewind
  # read label
  dd if=$TAPE bs=32k of=hdr
  # tape# and date created
  cat hdr | head -1 | awk '{print $4, $6}' | read dt tp
  echo reading tape $tp from $dt
  mv hdr $tp.hdr
  # all parts of size 600G
  ex=0
  # while exit success
  while [ $ex -eq 0 ]; do
    # read part from header
    dd if=$TAPE bs=32K of=hdr count=1
    # AMANDA: SPLIT_FILE 20220907195712 acoustic-191 \
    # back0/project  part 1/-1  lev 0 comp N program /bin/tar
    cat hdr | head -1 | awk '{print $5 $7}' | read bk pt
    back=$(echo $bk | awk -F/ '{print $1}')
    part=$(printf '%02d' $(echo $pt | awk -F/ '{print $1}'))
    # read data
    mv hdr $back.hdr
    echo dd if=$TAPE bs=32K of=$back.$part
    dd if=$TAPE bs=32K of=$back.$part
    ex=$?
  done
  mt rewind
  curr=$((++curr))
done

