LabSK  - c5 - gr. poniedziałek 12 NP
Zadanie za 3p, czas do 14:45

Zadanie wykonujemy na swojej stacji sX pracując na niej zdalnie (np. VSC).
Zadanie polega na napisaniu 4 minimalnych skrytów w /bin/sh
które wygenerują server VPS w chmurze z publicznym adresem IP i nazwą DNS
i podłączą go jak na schemacie ~/labsk/c5/ADM.drawio
Rekwizytem zadania jast posiadanie prywatnej sieci ZeroTier lub Tailscale
o nazwie ADM którą trzeba założyć na serwerze producenta i nadać jej adres i maskę.
Jeżeli posiadamy laptop to podpinamy go do tej sieci.

Skrypty:

1. gen-vps (generacja serwera)
   - Generuje *nowy* minimalny serwer Archlinux VPS w chmurze ze stałym adresem
     DNS = "$USER.domena-dostawcy" na który logujemy się poleceniem "ssh DNS"
   - Zapisze adres DNS tego serwera do pliku ~/.vps tak aby działało polecenie:
     ssh $(cat ~/.vps)
   - Skonfiguruje DNS na stacji tak aby były mapowania nazw na adresy IP:
     vps     na adres publiczny serwera VPS

2. config-vps  (konfiguracja serwera VPS)
   - ustawi zsh jako interpreter poleceń użytkownika gdy jest inny
   - założy katalog ~/bin i doda go *trwale* do ścieżki
   - doda skrypt ~/bin/ipb który zawiera 'ip -br $*'
   - odblokuje zaporę gdy ta blokuje ping-a (icmp echo)
     tak aby mozżna było robić piong z i do serwera

Można używać wszystkich skryptów które są dostępne na stacji -
np. az/{install,register,vm-archlinux}  (wszystkie: az/*)
Można używać dowolnych narzędzi AI ale nie można korzystać z pomocy osób.
Skrypty muszą być maksymalnie proste - minimalna liczba linii i znaków !
