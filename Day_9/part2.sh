#!/usr/bin/env bash

INPUT=$(cat $1)
FIELD=""
FIELD_WIDTH=0

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

function setchar() {
  local X=$1
  local Y=$2
  local C=$3
  I=$(( Y*FIELD_WIDTH + X ))
  LEN="${#FIELD}"
  BEFORE="${FIELD:0:$I}"
  AFTER="${FIELD:$(( I + 1)):$(( LEN - I - 1))}"
  FIELD="${BEFORE}${C}${AFTER}"
}

function setchar() {
  local X=$1
  local Y=$2
  local I=$(( Y*FIELD_WIDTH + X ))
  local C="${FIELD:I:1}"
  echo $C
}

function flood_fill() {
  local X=$1
  local Y=$2

  local CHAR="$(getchar $X $Y)"
  if [ "$CHAR" = "@" ]; then
    return
  elif [ "$CHAR" = "#" ]; then
    return
  else
    setchar $X $Y "@"
    # FIELD[$(( Y*FIELD_WIDTH + X ))]="@"
    for dx in -1 0 1; do
      XI=$(( X + dx ))
      for dy in -1 0 1; do
        YI=$(( Y + dy ))
        flood_fill $XI $YI
      done
    done
  fi

}

function gen_map() {
  echo "gen map"
  # walk from LB to UB of array $V
  # check if segment LB:UB is inside or outside
  I=$1
  X=$2
  Y=$3
  FIELD_WIDTH=0
  FIELD_HEIGHT=0
  FIELD=""
  LAST_I=0
  for i in "${I[@]}"; do
    XI="${X[$i]}"
    YI="${Y[$i]}"
    if (( XI > FIELD_WIDTH )); then FIELD_WIDTH=$XI; fi
    if (( YI > FIELD_HEIGHT )); then FIELD_HEIGHT=$YI; fi
    LAST_I=$i
  done
  FIELD_WIDTH=$(( FIELD_WIDTH + 2 ))
  FIELD_HEIGHT=$(( FIELD_HEIGHT + 2 ))

  echo "Field size ${FIELD_WIDTH}x${FIELD_HEIGHT}"
  # local AREA=$(( FIELD_WIDTH * FIELD_HEIGHT ))
  
  for (( YI = 0; YI < FIELD_HEIGHT; YI += 1)); do
    # for (( XI = 0; XI < FIELD_WIDTH; XI += 1 )); do
    #   FIELD="${FIELD}."
    # done
    PERC=$(( (YI * 100) / FIELD_HEIGHT ))
    echo "Progress ${PERC}%"
    ROW=$(eval printf '.%.0s' {1..$FIELD_WIDTH})
    FIELD="${FIELD}${ROW}"
  done

  echo "Field size ${FIELD_WIDTH}x${FIELD_HEIGHT} initialised"

  for i in "${I[@]}"; do
    XI="${X[$i]}"
    YI="${Y[$i]}"
    # FIELD[$(( YI*FIELD_WIDTH + XI ))]='#'
    setchar $X $Y "#"
    j=$(( i + 1 ))
    if (( j > LAST_I )); then j=0; fi

    XJ="${X[$j]}"
    YJ="${Y[$j]}"

    XL=XI; XU=XJ
    YL=YI; YU=YJ
    if (( XI > XJ )); then XL=XJ; XU=XI; fi
    if (( YI > YJ )); then YL=YJ; YU=YI; fi

    DX=$(( XU - XL ))
    DY=$(( YU - YL ))

    if (( DX > 0 )); then
      for (( dx = 1; dx < DX; dx += 1 )); do
        #FIELD[$(( YI*FIELD_WIDTH + XL + dx ))]='#'
        setchar $YI $(( XL + dx )) "#"
      done
    else
      for (( dy = 1; dy < DY; dy += 1 )); do
        #FIELD[$(( (YL + dy)*FIELD_WIDTH + XI ))]='#'
        setchar $(( YL + dy)) $XI "#"
      done
    fi
  done
  echo "Edges done. Filling in..."

  flood_fill $(( ${X[0]} + 1 )) $(( ${Y[0]} + 1))
  echo "Filled."

  # for (( YI = 0; YI < FIELD_HEIGHT; YI += 1 )); do
  #   for (( XI = 0; XI < FIELD_WIDTH; XI += 1)); do
  #     printf '%s' "${FIELD[$(( YI*FIELD_WIDTH + XI ))]}"
  #   done
  #   printf '\n'
  # done
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

gen_map $I $X $Y

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

    # point IJ bad?
    if [ "${FIELD[$(( YJ * FIELD_WIDTH + XI ))]}" == "." ]; then continue; fi

    # point JI baad?
    if [ "${FIELD[$(( YI * FIELD_WIDTH + XJ ))]}" == "." ]; then continue; fi

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
echo "$MAX_AREA: ($MAX_XI,$MAX_YI) -> ($MAX_XJ,$MAX_YJ)"
