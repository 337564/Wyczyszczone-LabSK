# Konversja IPv4 (a.b.c.d) - implemntacja inet_ntoa i inet_aton
# man inet_aton
# ato 2019-2021

inet_aton() { # arg   # Zamiana a.b.c.d na liczbę binarną
  local n a i
  a=$1
  n=0
  for i in 1 2 3 4 ; do
    n=$((n << 8 | ${a%%.*}))
    a=${a#*.}
  done
  echo $n
}

inet_ntoa() { # arg   # Zamiana liczby binarnej na notację kropkową a.b.c.d
  local n a i
  n=$1
  for i in 1 2 3 4 ; do
    a=$((n & 255)).$a
    n=$((n >> 8))
  done
  echo ${a%.}
}
# test:
#i=${1:-234.182.20.104} ; echo $i ; n=$(inet_aton $i) ; echo $n ; echo $(inet_ntoa $n)
