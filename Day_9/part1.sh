#!/usr/bin/env bash

INPUT=$(cat $1)


function error() {
  echo $1
  exit 1
}

function box_area() {
  XI=$1
  YI=$2
  XJ=$3
  YJ=$4

  WIDTH=0
  HEIGHT=0
  if (( XI > XJ )); then
    WIDTH=$(( $XI - $XJ + 1))
  else
    WIDTH=$(( $XJ - $XI + 1))
  fi
  if (( YI > YJ )); then
    HEIGHT=$(( $YI - $YJ + 1 ))
  else
    HEIGHT=$(( $YJ - $YI + 1))
  fi
  echo $(( $WIDTH * $HEIGHT ))
}

declare -a X
declare -a Y
declare -a I
i=0
for LINE in $INPUT; do
  IFS="," read -ra COORD <<< "$LINE"
  X+=("${COORD[0]}")
  Y+=("${COORD[1]}")
  I+=("$i")
  i=$(($i + 1))
done
N_POINTS=$i

MAX_AREA=0
MAX_INDICES=(0 0)
for i in "${I[@]}"; do
  XI="${X[$i]}"
  YI="${Y[$i]}"
  PERC=$(( (i * 100) / N_POINTS ))
  echo "Progress: ${PERC}%"
  for j in "${I[@]}"; do
    XJ="${X[$j]}"
    YJ="${Y[$j]}"

    if (( j > i )); then break; fi
    if [ $XJ -eq $XI ]; then continue; fi
    if [ $YJ -eq $YI ]; then continue; fi

    AREA=$(box_area "$XI" "$YI" "$XJ" "$YJ")
    # echo "$XI,$YI -> $XJ,$YJ :: $AREA"
    if (( AREA > MAX_AREA )); then
      MAX_AREA=$AREA
      MAX_INDICES=($i $j)
    fi
  done
done

MAX_XI="${X[${MAX_INDICES[0]}]}"
MAX_YI="${Y[${MAX_INDICES[0]}]}"
MAX_XJ="${X[${MAX_INDICES[1]}]}"
MAX_YJ="${Y[${MAX_INDICES[1]}]}"
echo "$MAX_AREA"
