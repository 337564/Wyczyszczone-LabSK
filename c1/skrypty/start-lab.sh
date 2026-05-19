#!/bin/sh
# Przykladowa Inincjalizacja stacji
# ato@2025

# id	 # uid=1001(stud) gid=400(stud) groups=400(stud)

set -x					# Debug - sledzenie skryptu

# Moje konto na volcie:
USR=stud UID=1001
NAZ='Jasio Student'
HOME=/home/stud/$USR
GRU=stud  GID=400			# Moja grupa na volcie

set -e

mkdir bin

sudo groupmod -g $GID $GRP		# grupa stud na volcie ma inny id - trzeba go zmienic

sudo useradd -u $UID -g $GRU -c "$NAZ" -d  $HOME -s /bin/zsh  $USR

sudo install -d -o $USR -g $GRU $HOME	# Potrzebne ?

sudo passwd $USR

exit
