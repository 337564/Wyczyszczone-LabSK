#!/bin/sh
# Przyklad studenta:

USR=stud  UID=1000  NAZ="Jasio Student"
GRU=stud  GID=400

groupmod -g $GID $USR		# Grupa stud na volcie ma inny id - trzeba go zmienic

useradd -u $UID -g $GID -c "$NAZ" -d  /home/$GRU/$USR -s /bin/zsh  $USR

#install -d -o $USR -g $GRU /home/$GRU/$USR

passwd $USR
