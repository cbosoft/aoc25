#!/usr/bin/env bash

INPUT=$(cat $1)
declare -A FIELD=()
declare -i FIELD_WIDTH=0
declare -i FIELD_HEIGHT=0

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
  #local I=$(( Y*FIELD_WIDTH + X ))
  local I="$X,$Y"
  # LEN="${#FIELD}"
  # BEFORE="${FIELD:0:$I}"
  # AFTER="${FIELD:$(( I + 1)):$(( LEN - I - 1))}"
  # FIELD="${BEFORE}${C}${AFTER}"
  FIELD[$I]="$C"
}

function getchar() {
  local X=$1
  local Y=$2
  local I="$X,$Y"
  local C="${FIELD[$I]}"
  if [ -z "$C" ]; then
    echo "."
  else
    echo $C
  fi
}

# function flood_fill() {
#   local X=$1
#   local Y=$2
# 
#   local CHAR="$(getchar $X $Y)"
#   if [ "$CHAR" != "@" ] && [ "$CHAR" != "#" ]; then
#     setchar $X $Y "@"
#     # FIELD[$(( Y*FIELD_WIDTH + X ))]="@"
#     for dx in -1 0 1; do
#       XI=$(( X + dx ))
#       for dy in -1 0 1; do
#         YI=$(( Y + dy ))
#         flood_fill $XI $YI
#       done
#     done
#   fi
# }

function is_outside() {
  local -i X=$1
  local -i Y=$2

  local -i left=0
  local -i right=0
  local -i above=0
  local -i below=0

  local C="."
  local PC="."
  for (( x = 0; x < (X + 1); x++ )); do
    C=$(getchar $x $Y)
    if [ "$C" = "#" ] && [ "$C" = "$PC" ]; then left=1; fi
    if [ "$C" = "#" ] && [ "$C" != "$PC" ]; then left+=1; fi
    PC=$C
  done

  PC="."
  for (( x = FIELD_WIDTH; x > (X - 1); x-- )); do
    C=$(getchar $x $Y)
    if [ "$C" = "#" ] && [ "$C" = "$PC" ]; then right=1; fi
    if [ "$C" = "#" ] && [ "$C" != "$PC" ]; then right+=1; fi
    PC=$C
  done

  PC="."
  for (( y = 0; y < (Y + 1); y++ )); do
    C=$(getchar $X $y)
    if [ "$C" = "#" ] && [ "$C" = "$PC" ]; then below=1; fi
    if [ "$C" = "#" ] && [ "$C" != "$PC" ]; then below+=1; fi
    PC=$C
  done

  PC="."
  for (( y = FIELD_HEIGHT; y > (Y - 1); y-- )); do
    C=$(getchar $X $y) 
    if [ "$C" = "#" ] && [ "$C" = "$PC" ]; then above=1; fi
    if [ "$C" = "#" ] && [ "$C" != "$PC" ]; then above+=1; fi
    PC=$C
  done

  local -i leftcheck=$(( left % 2 == 1 ))
  local -i rightcheck=$(( right % 2 == 1 ))
  local -i abovecheck=$(( above % 2 == 1 ))
  local -i belowcheck=$(( below % 2 == 1 ))
  
  local -i RV=1
  if [ "$leftcheck" -eq 0 ] || [ "$rightcheck" -eq 0 ] || [ "$abovecheck" -eq 0 ] || [ "$belowcheck" -eq 0 ]; then
    RV=0
  fi
  return $RV
}

function print_field() {
  if (( FIELD_WIDTH > 200 )) || (( FIELD_HEIGHT > 200 )); then
    echo "Field size too large to display."
    return
  fi

  echo "Field ${FIELD_WIDTH}x${FIELD_HEIGHT}:"
  for (( YI = 0; YI < FIELD_HEIGHT; YI += 1 )); do
    for (( XI = 0; XI < FIELD_WIDTH; XI += 1)); do
      local C=$(getchar $XI $YI)
      if [ -z "$C" ]; then C="."; fi
      printf '%s' "$C"
    done
    printf '\n'
  done
  printf '\n'
}

function gen_map() {
  FIELD_WIDTH=0
  FIELD_HEIGHT=0
  local -i LAST_I=0
  local -i XI=0
  local -i XJ=0
  local -i YI=0
  local -i YJ=0
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

  for i in "${I[@]}"; do
    XI="${X[$i]}"
    YI="${Y[$i]}"
    setchar $XI $YI "#"
    j=$(( i + 1 ))
    if (( j > LAST_I )); then j=0; fi

    XJ="${X[$j]}"
    YJ="${Y[$j]}"

    XL=XI; XU=XJ
    YL=YI; YU=YJ
    if (( XI > XJ )); then XL=XJ; XU=XI; fi
    if (( YI > YJ )); then YL=YJ; YU=YI; fi

    local -i DX=$(( XU - XL ))
    local -i DY=$(( YU - YL ))

    if (( DX > 0 )); then
      for (( dx = 1; dx < DX; dx += 1 )); do
        setchar $(( XL + dx )) $YI "#"
      done
    else
      for (( dy = 1; dy < DY; dy += 1 )); do
        setchar $XI $(( YL + dy )) "#"
      done
    fi
  done
  echo "Edges done."
  print_field
}


declare -a X=()
declare -a Y=()
declare -a I=()

function main() {
  local -i XI=0
  local -i YI=0
  local -i XJ=0
  local -i YJ=0
  local -i i=0
  local -i j=0
  for LINE in $INPUT; do
    IFS="," read -ra COORD <<< "$LINE"
    X+=("${COORD[0]}")
    Y+=("${COORD[1]}")
    I+=($i)
    i+=1
  done
  local -i N_POINTS=$i
  
  gen_map
  
  local -i MAX_AREA=0
  local -a MAX_INDICES=(0 0)
  local -i PERC=0
  local -i PPERC=-1
  for i in "${I[@]}"; do
    XI="${X[$i]}"
    YI="${Y[$i]}"
    PERC=$(( (i * 10000) / (N_POINTS - 1) ))
    if (( PERC > PPERC )); then
      P1=$(( PERC / 100 ))
      P2=$(( PERC % 100 ))
      echo "Progress: ${P1}.${P2}% $(date +%H:%M:%S)"
      PPERC=$PERC
    fi
    for j in "${I[@]}"; do
      XJ="${X[$j]}"
      YJ="${Y[$j]}"
  
      if (( j > (i - 1) )); then break; fi
      if [ $XJ -eq $XI ]; then continue; fi
      if [ $YJ -eq $YI ]; then continue; fi

      # point IJ bad?
      # if [ "${FIELD[$(( YJ * FIELD_WIDTH + XI ))]}" == "." ]; then continue; fi
      if is_outside $XI $YJ; then continue; fi
  
      # point JI bad?
      # if [ "${FIELD[$(( YI * FIELD_WIDTH + XJ ))]}" == "." ]; then continue; fi
      if is_outside $XJ $YI; then continue; fi
  
      AREA=$(box_area "$XI" "$YI" "$XJ" "$YJ")
      # echo "$XI,$YI -> $XJ,$YJ :: $AREA"
      if (( AREA > MAX_AREA )); then
        MAX_AREA=$AREA
        MAX_INDICES=($i $j)
      fi
    done
  done
  
  local -i MAX_XI="${X[${MAX_INDICES[0]}]}"
  local -i MAX_YI="${Y[${MAX_INDICES[0]}]}"
  local -i MAX_XJ="${X[${MAX_INDICES[1]}]}"
  local -i MAX_YJ="${Y[${MAX_INDICES[1]}]}"
  echo "$MAX_AREA: ($MAX_XI,$MAX_YI) -> ($MAX_XJ,$MAX_YJ)"
}

main
