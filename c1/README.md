# c1 — terminal, Unix, SSH i przygotowanie środowiska

## Cel ćwiczenia

Ćwiczenie służy do opanowania pracy w terminalu w Windows i Unix/Linux, przygotowania narzędzi laboratoryjnych oraz zrozumienia podstaw SSH i kryptografii używanej przy logowaniu zdalnym.

Po tym ćwiczeniu student powinien umieć:

- pracować w PowerShellu i powłoce Uniksa,
- używać podstawowych poleceń systemowych,
- wygenerować klucze SSH i skopiować klucz publiczny na serwer,
- rozróżniać klucz prywatny, klucz publiczny, klucz hosta i hasło,
- zalogować się na `volt.zet` oraz stację laboratoryjną,
- zainstalować podstawowe narzędzia: PowerShell 7, Windows Terminal, VS Code, draw.io, Wireshark, VirtualBox/Hyper-V/qemu.

## Minimalny plan pracy

1. Sprawdź, czy w Windows działa klient OpenSSH:

```powershell
ls C:\Windows\System32\OpenSSH\
```

2. Zaloguj się na `volt.zet`:

```bash
ssh login@volt.zet
```

3. Zmień hasło na volcie:

```bash
passwd
```

Hasło powinno mieć co najmniej 8 znaków i zawierać małą literę, wielką literę, cyfrę oraz znak specjalny.

4. Wygeneruj klucz SSH na własnym komputerze:

```bash
ssh-keygen -t ed25519
```

5. Skopiuj klucz publiczny na volta:

```bash
cat ~/.ssh/id_ed25519.pub | ssh login@volt.zet 'mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
```

W PowerShellu odpowiednik używa `$HOME`:

```powershell
cat "$HOME\.ssh\id_ed25519.pub" | ssh login@volt.zet 'mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
```

6. Sprawdź logowanie bez hasła:

```bash
ssh login@volt.zet
```

7. Przejrzyj podstawowe polecenia Uniksa z sekcji niżej i sprawdź ich dokumentację przez `man` albo `tldr`.

## SSH — najważniejsze pojęcia

### Klucz prywatny i publiczny

Klucz prywatny zostaje na komputerze użytkownika i nie powinien być kopiowany na cudze maszyny. Klucz publiczny można udostępniać. Serwer sprawdza, czy klient potrafi udowodnić posiadanie klucza prywatnego odpowiadającego kluczowi publicznemu wpisanemu w `~/.ssh/authorized_keys`.

Jeżeli zgubisz klucz publiczny, zwykle możesz go odtworzyć z klucza prywatnego:

```bash
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
```

Jeżeli zgubisz klucz prywatny, wygeneruj nową parę kluczy i usuń stary klucz publiczny z miejsc, gdzie został dopuszczony.

### Klucz hosta

Serwer SSH też ma własne klucze, zwykle w `/etc/ssh/ssh_host_*`. Służą do uwierzytelnienia maszyny. Przy pierwszym połączeniu klient zapisuje odcisk klucza hosta w `~/.ssh/known_hosts`. Jeśli klucz hosta nagle się zmieni, klient ostrzega, bo może to oznaczać reinstalację serwera, zmianę konfiguracji albo atak typu man-in-the-middle.

### Pliki konfiguracyjne

- konfiguracja klienta użytkownika: `~/.ssh/config`,
- znane klucze hostów: `~/.ssh/known_hosts`,
- dopuszczone klucze publiczne na serwerze: `~/.ssh/authorized_keys`,
- konfiguracja klienta globalnie: zwykle `/etc/ssh/ssh_config`,
- konfiguracja serwera: zwykle `/etc/ssh/sshd_config`.

### Tunel SSH

Tunel SSH przekierowuje port lokalny albo zdalny przez zaszyfrowane połączenie SSH. Używa się go np. do bezpiecznego dostępu do usługi działającej tylko w sieći wewnętrznej.

Przykład lokalnego tunelu:

```bash
ssh -L 8080:localhost:80 login@serwer
```

Po tym `localhost:8080` na komputerze klienta prowadzi do `localhost:80` widzianego z serwera.

## Podstawy Uniksa do opanowania

### Powłoka i edycja poleceń

- `Ctrl+C` — przerwanie programu,
- `Ctrl+D` — koniec wejścia / wylogowanie z pustej linii,
- `Ctrl+Z` — zatrzymanie procesu i przeniesienie do zadań,
- `Ctrl+L` — wyczyszczenie ekranu,
- `Ctrl+A`, `Ctrl+E` — początek i koniec linii,
- `Tab` — dopełnianie nazw.

### Pliki i katalogi

```bash
pwd        # aktualny katalog
ls -la     # lista plików z ukrytymi i uprawnieniami
cd         # przejście do katalogu domowego
mkdir x    # utworzenie katalogu
rmdir x    # usunięcie pustego katalogu
touch a    # utworzenie pustego pliku albo zmiana czasu modyfikacji
cp a b     # kopiowanie
mv a b     # przeniesienie/zmiana nazwy
rm a       # usunięcie pliku
ln -s a b  # link symboliczny
chmod      # zmiana uprawnień
```

### Procesy i zadania

```bash
ps aux
pgrep nazwa
pkill nazwa
top
jobs
fg
nohup polecenie &
```

### Redyrekcja i potoki

```bash
polecenie > plik       # stdout do pliku, nadpisanie
polecenie >> plik      # stdout do pliku, dopisanie
polecenie 2> bledy.log # stderr do pliku
polecenie | grep wzor  # potok
```

### Serwisy i dzienniki

Linux:

```bash
systemctl status sshd
journalctl -u sshd
```

FreeBSD:

```bash
service sshd status
dmesg
```

## Praca lokalna i zdalna na stacjach LabSK

W laboratorium najczęściej pracuje się na własnym koncie skopiowanym z volta na stację `sX`. Po skopiowaniu konta można logować się bez prefiksu `user@`, jeśli nazwa użytkownika lokalnie jest taka sama jak na komputerze, z którego uruchamiasz `ssh`. SSH przy braku jawnego loginu używa bieżącej nazwy użytkownika.

Z domu należy logować się bezpośrednio do stacji, a nie przez volta, jeżeli zadanie dotyczy stacji. Wymaga to działającej sieći ZeroTier ZET, ponieważ stacje laboratoryjne nie są zwykle bezpośrednio osiągalne z publicznego Internetu. ZeroTier tworzy prywatną sieć wirtualną, w której komputer domowy i stacja są w tej samej logicznej sieći.

Przy problemach ze stacją użyj alternatywnych nazw i adresów:

- `sX` — podstawowy interfejs w sieći `10.146/16`,
- `sXl` — drugi interfejs w sieći `172.29/16`,
- `sXw` — Wi-Fi, jeżeli zostało skonfigurowane,
- adres IPv6 link-local — wymaga dopisania strefy, np. `%eno1`, bo taki adres jest poprawny tylko na konkretnym interfejsie.

## Pliki w tym katalogu

- `skrypty/` — przykłady skryptów z oryginalnych materiałów.
- `zadania/` — zachowane zadania i wejściówki, zduplikowane wersje historyczne usunięto.
- [linki.md](linki.md) — zebrane odnośniki źródłowe.
