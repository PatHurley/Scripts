#!/bin/bash

VERSION=02.21.24

# --- Functions ---------------------------------------------------------------

USAGE(){
printf "Usage: $(basename $0) [OPTIONS]... [ARGUMENTS]...
Takes a binary, decimal, or hexadecimal value and translates it to
the other 2 numbering systems.

OPTIONS
  -b,  --bin     translate input string from binary
  -d,  --dec     translate input string from decimal
  -h,  --hex     translate input string from hexadecimal

       --help    display this help and exit
       --version output version information and exit

i.e.
\$ ./$(basename $0) --dec 123
dec 123
bin 01111011
hex 7B

\$ ./$(basename $0) -d 123 -b 101000001 -h FFF
dec 123
bin 1111011
hex 7B

dec 321
bin 101000001
hex 141

dec 4095
bin 111111111111
hex FFF\n\n"
}

toBin() {
  local value=$1
  local type="$2"

  case "$type" in
    bin )
      echo $value
    ;;
    dec )
      while [ $value -gt 0 ]; do
        local remainder=$(( $value % 2 ))
        local binary="$remainder$binary"
        local value=$(( $value / 2 ))
      done

      echo $binary
    ;;
    hex )
      local -A hex_to_bin=(
        [0]=0000 [1]=0001 [2]=0010 [3]=0011 [4]=0100 [5]=0101 [6]=0110 [7]=0111
        [8]=1000 [9]=1001 [A]=1010 [B]=1011 [C]=1100 [D]=1101 [E]=1110 [F]=1111
        )

      for ((i = 0; i < ${#value}; i++)); do
        local binary+="${hex_to_bin[${value:i:1}]}"
      done
      # Remove leading zeros
      local binary=$(echo $binary | sed 's/^0*//')

      echo $binary
    ;;
  esac
}

toDec() {
  local value=$1
  local type="$2"

  case "$type" in
    bin )
      local decimal=0
      local position=1

      for (( i=${#value}-1; i>=0; i-- )); do
        local bit=${value:i:1}
        [[ "$bit" -eq 1 ]] && (( decimal += position ))
        (( position *= 2 ))
      done

      echo $decimal
    ;;
    dec )
      echo $value
    ;;
    hex )
      #local decimal=$(toDec $(toBin $value "hex") "bin")
      local decimal=0
      local -A hex_to_dec=( [A]=10 [B]=11 [C]=12 [D]=13 [E]=14 [F]=15 )

      for (( i=0; i<${#value}; i++ )); do
          local digit="${value:i:1}"
          decimal=$(( decimal * 16 ))
          case $digit in
              [0-9])    decimal=$(( decimal + digit )) ;;
              [A-F]) decimal=$(( decimal + ${hex_to_dec[${value:i:1}]} )) ;;
          esac
      done

      echo $decimal
    ;;
  esac
}

toHex() {
  local value=$1
  local type="$2"

  case "$type" in
    bin )
      local -A bin_to_hex=(
        [0000]=0 [0001]=1 [0010]=2 [0011]=3 [0100]=4 [0101]=5 [0110]=6 [0111]=7
        [1000]=8 [1001]=9 [1010]=A [1011]=B [1100]=C [1101]=D [1110]=E [1111]=F
        )

      # Pad the binary number to make its length a multiple of 4
      local remainder=$((${#value} % 4))
      if [[ $remainder -ne 0 ]]; then
        local padding=$((4 - $remainder))
        local zeros=$(printf "%0.s0" $(seq 1 $padding))
        local padded_binary=$(printf "${zeros}${value}")
      else
        local padded_binary=$value
      fi

      for (( i=0; i<${#padded_binary}; i+=4 )); do
        local chunk=${padded_binary:$i:4}
        local hexadecimal="$hexadecimal${bin_to_hex[$chunk]}"
      done

      echo $hexadecimal
    ;;
    dec )
      #local hexadecimal=$(toHex $(toBin $value "dec") "bin")
      while [[ $value -gt 0 ]]; do
          local remainder=$((value % 16))
          if [[ $remainder -lt 10 ]]; then
              hexadecimal="${remainder}${hexadecimal}"
          else
              case $remainder in
                  10) hexadecimal="A${hexadecimal}" ;;
                  11) hexadecimal="B${hexadecimal}" ;;
                  12) hexadecimal="C${hexadecimal}" ;;
                  13) hexadecimal="D${hexadecimal}" ;;
                  14) hexadecimal="E${hexadecimal}" ;;
                  15) hexadecimal="F${hexadecimal}" ;;
              esac
          fi
          value=$((value / 16))
      done

      echo $hexadecimal
    ;;
    hex )
      echo $value
    ;;
  esac
}

# --- Arguments processing ----------------------------------------------------

if [ -z $1 ]; then
	printf "ERROR: Not enough arguments, please provide a number type and a value to be translated.\n\n"
	USAGE; exit 1
fi

# --- Options processing ------------------------------------------------------

while [[ "$1" =~ ^-.* ]]; do
  case $1 in
    -b | --bin) shift
      [[ ! $1 =~ ^[01]+$ ]] && printf "$1 is not binary.\n\n" && shift && continue
      bin=$1
      dec=$(toDec $1 "bin")
      hex=$(toHex $1 "bin")
      printf "dec ${dec}\nbin ${bin}\nhex ${hex}\n\n"
    ;;
    -d | --dec) shift
      [[ ! $1 =~ ^[0-9]+$ ]] && printf "$1 is not decimal.\n\n" && shift && continue
      bin=$(toBin $1 "dec")
      dec=$1
      hex=$(toHex $1 "dec")
      printf "dec ${dec}\nbin ${bin}\nhex ${hex}\n\n"
    ;;
    -h | --hex) shift
      [[ ! $1 =~ ^[0-9a-fA-F]+$ ]] && printf "$1 is not hexadecimal.\n\n" && shift && continue
      hex_cap=$(echo "${1^^}")
      bin=$(toBin $hex_cap "hex")
      dec=$(toDec $hex_cap "hex")
      hex=$hex_cap
      printf "dec ${dec}\nbin ${bin}\nhex ${hex}\n\n"
    ;;

    --help ) shift
      USAGE
    ;;
    --version ) shift
      printf "Script Version:\t$VERSION\n"
    ;;
    *)
      printf "\n [!] Invalid option: $1\n\n"
      USAGE; exit 1
    ;;
  esac; shift
done