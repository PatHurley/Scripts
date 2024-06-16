#!/bin/bash
specials='!@#$%^&*()_+-={}[]|:;<>,.?'

#---Parameters---#
l=8  #Total length of the password
sc=2 #Number of special characters

#---Arguments---#
while [[ "$1" =~ ^-.* ]]; do
  case $1 in
    -l | --length)
      l=$2; shift 2
    ;;
    -s | --special_chars)
      sc=$2; shift 2
    ;;
  esac;
done

#---Main---#
nc=$(($l - $sc))
[ $nc -lt 0  ] && echo "[!] Number of special characters is greater then password length." && exit 1
[ $nc -gt $l ] && echo "[!] Number of normal characters is greater then password length."  && exit 1

sc=$(echo "$specials" | fold -w1 | shuf | tr -d '\n' | head -c${sc})
nc=$(openssl rand -base64 $l | tr -dc 'A-Za-z0-9' | head -c${nc})

pw=$(echo "$sc$nc" | fold -w1 | shuf | tr -d '\n')

echo "Password: $pw"
#read -p "Press [Enter] to continue..." && reset
