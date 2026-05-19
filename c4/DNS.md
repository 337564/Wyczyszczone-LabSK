# DNS, mDNS, LLMNR i rozwiązywanie nazw w Linuksie

**ato 2026**

---

## 1. DNS — Domain Name System

Tradycyjne, hierarchiczne rozwiązywanie nazw oparte na serwerach (RFC 1034/1035).

### Jak działa

```
Klient                Resolver rekurencyjny      Serwery autorytatywne
  |                         |                            |
  |-- "co to jest s1?" ---->|                            |
  |                         |-- serwery root ----------->|
  |                         |-- TLD (.pl) ------------->|
  |                         |-- DNS zet.pw.edu.pl ------>|
  |<-- 10.146.225.1 --------|                            |
```

- Port **53** UDP/TCP
- Zasięg globalny — trasowany przez internet
- Wymaga skonfigurowanego serwera DNS (`/etc/resolv.conf`)
- Hierarchia: root → TLD → strefa autorytatywna

### Kluczowe pliki

| Plik | Przeznaczenie |
|------|---------------|
| `/etc/resolv.conf` | adres(y) serwera DNS, domena przeszukiwań |
| `/etc/hosts` | statyczne lokalne wpisy |
| `/etc/nsswitch.conf` | kolejność rozwiązywania nazw (DNS, mDNS, pliki, ...) |

---

## 2. mDNS — Multicast DNS

Rozwiązywanie nazw bez serwera DNS — konfiguracja zerowa (RFC 6762, pochodzenie: Apple/Bonjour).

### Jak działa

```
Host A                              Lokalna sieć L2
  |                                       |
  |-- multicast "kto to printer.local?" ->| (224.0.0.251:5353)
  |                                       |
  |<-- "To ja, printer.local: 192.168.1.5"| (odpowiedź wprost od drukarki)
```

- Port **5353** UDP
- Multicast: `224.0.0.251` (IPv4), `ff02::fb` (IPv6)
- Zasięg: **tylko link-local** — TTL=1, nie trasowany poza jeden segment L2
- Standardowa domena: wyłącznie **`.local`** (RFC 6762)
- Zerowa konfiguracja — nie wymaga administratora ani serwera

### Zastosowania

- Drukarki, NAS, urządzenia IoT ogłaszające swoją obecność w sieci LAN
- Małe sieci bez serwera DNS
- `ping printer.local` działa bez żadnej konfiguracji

### mDNS kontra DNS

| Właściwość | DNS | mDNS |
|------------|-----|------|
| Serwer | wymagany | brak |
| Zasięg | globalny | link-local |
| Port | 53 | 5353 |
| Transport | unicast | multicast |
| Nazwy | dowolne | `.local` (standard RFC) |
| Konfiguracja | ręczna | zerowa |

---

## 3. LLMNR — Link-Local Multicast Name Resolution

Protokół Microsoftu (RFC 4795), przyjęty przez systemd. Zaprojektowany specjalnie
do rozwiązywania **krótkich jednoczłonowych nazw hostów** (bez sufiksu domeny)
w sieci lokalnej.

### Jak działa

```
Host s1                             Lokalna sieć L2
  |                                       |
  |-- multicast "kto to e1?" ------------>| (224.0.0.252:5355)
  |                                       |
  |<-- "To ja, e1: 10.146.213.51" --------| (odpowiedź od e1)
```

- Port **5355** UDP
- Multicast: `224.0.0.252` (IPv4), `ff02::1:3` (IPv6)
- Zasięg: **tylko link-local**
- Nazwy: krótkie hosty (`e1`, `s1`, `drukarka`) — **bez `.local`**

### mDNS kontra LLMNR

| Właściwość | mDNS | LLMNR |
|------------|------|-------|
| Standard | RFC 6762 | RFC 4795 |
| Pochodzenie | Apple | Microsoft |
| Adres multicast | `224.0.0.251` | `224.0.0.252` |
| Port | 5353 | 5355 |
| Nazwy | `.local` | krótkie jednoczłonowe |
| Stosowany przez | macOS, avahi, systemd | Windows, systemd |

---

## 4. avahi

Standardowy demon mDNS/DNS-SD w Linuksie. Ściśle implementuje RFC 6762.

### Składniki

| Składnik | Pakiet | Przeznaczenie |
|----------|--------|---------------|
| `avahi-daemon` | `avahi` | demon mDNS, zajmuje port 5353 |
| `libnss_mdns*.so` | `nss-mdns` | wtyczka NSS do integracji z `getaddrinfo()` |
| `avahi-browse` | `avahi` | wykrywanie usług w sieci LAN |
| `avahi-resolve` | `avahi` | rozwiązywanie nazw/adresów przez avahi |

### Moduły NSS z pakietu nss-mdns

`nss-mdns` dostarcza kilka wariantów:

| Moduł | Zasięg | Rekordy |
|-------|--------|---------|
| `mdns` | wszystkie nazwy | A + AAAA |
| `mdns_minimal` | tylko `.local` | A + AAAA |
| `mdns4` | wszystkie nazwy | tylko A (IPv4) |
| **`mdns4_minimal`** | **tylko `.local`** | **tylko A (IPv4)** |
| `mdns6` | wszystkie nazwy | tylko AAAA |
| `mdns6_minimal` | tylko `.local` | tylko AAAA |

**`mdns4_minimal` to zalecany wybór** — ogranicza mDNS dokładnie do tego,
co przewiduje RFC 6762 (`.local`, tylko IPv4), nie ingerując w zwykły DNS
dla pozostałych nazw.

### Zależności

```
nss-mdns  ──wymaga──>  avahi-daemon (uruchomiony)
avahi     ──opcjonalnie──>  nss-mdns (integracja z getaddrinfo())
```

avahi działa bez nss-mdns (demon działa, wykrywanie usług działa),
ale `getaddrinfo("host.local")` / `getent hosts host.local` NIE użyje
avahi bez zainstalowanego nss-mdns.

---

## 5. systemd-resolved

Zunifikowany demon rozwiązywania nazw — obsługuje DNS, mDNS i LLMNR w jednej usłudze.

### Architektura

```
Aplikacje
    |
    | getaddrinfo() / getent hosts
    v
 nsswitch.conf  -->  resolve  -->  systemd-resolved (127.0.0.53:53)
                                         |
                              +----------+----------+
                              |          |          |
                            DNS        mDNS       LLMNR
                       (per-interfejs) (5353)    (5355)
```

- Uruchamia **stub resolver** pod adresem `127.0.0.53:53`
- `/etc/resolv.conf` wskazuje na `127.0.0.53` (tryb stub)
- Konfiguracja DNS per interfejs (różne serwery DNS dla różnych połączeń)
- Konfigurowany przez `/etc/systemd/resolved.conf` i konfigurację sieci
- Zarządzany poleceniem `resolvectl`

### Kluczowa konfiguracja (`/etc/systemd/resolved.conf`)

```ini
[Resolve]
MulticastDNS=yes   # włącz/wyłącz mDNS (domyślnie: yes)
LLMNR=yes          # włącz/wyłącz LLMNR (domyślnie: yes)
DNS=               # globalne serwery DNS
Cache=yes          # pamięć podręczna DNS
```

### Sterowanie w czasie działania (per interfejs)

```sh
resolvectl mdns  eth0 no    # wyłącz mDNS na eth0
resolvectl llmnr eth0 no    # wyłącz LLMNR na eth0
resolvectl flush-caches     # wyczyść pamięć podręczną DNS/mDNS/LLMNR
resolvectl status           # pokaż bieżącą konfigurację
```

### Konflikt portu 5353 z avahi

Zarówno systemd-resolved (z włączonym mDNS) jak i avahi-daemon chcą portu 5353.
**Nie mogą jednocześnie obsługiwać mDNS.**

Rozwiązanie: przy użyciu avahi wyłącz mDNS w systemd-resolved:
```ini
# /etc/systemd/resolved.conf
[Resolve]
MulticastDNS=no
```

---

## 6. systemd-resolved kontra avahi

| Funkcja | systemd-resolved | avahi |
|---------|-----------------|-------|
| DNS | TAK (pełny, per interfejs) | nie |
| mDNS | TAK (wbudowany) | TAK (dedykowany) |
| LLMNR | TAK (wbudowany) | nie |
| Wykrywanie usług DNS-SD | nie | TAK |
| Integracja NSS | moduł `resolve` | moduły `nss-mdns` |
| Kontrola zasięgu w nsswitch | brak (wszystko albo nic) | per moduł (`mdns4_minimal`) |
| Obsługa krótkich nazw | mDNS + LLMNR dla dowolnej nazwy | tylko `.local` (minimal) |
| Port 5353 | zajmuje go gdy mDNS włączony | zajmuje go gdy uruchomiony |

**Kluczowa różnica:** moduł NSS `resolve` systemd-resolved to czarna skrzynka —
DNS + mDNS + LLMNR razem, bez możliwości ograniczenia mDNS tylko do `.local`
z poziomu nsswitch.conf. Moduł `mdns4_minimal` avahi daje precyzyjną, zgodną
z RFC kontrolę.

---

## 7. nsswitch.conf — kolejność rozwiązywania nazw

`/etc/nsswitch.conf` kontroluje kolejność metod rozwiązywania nazw.
Kluczowy jest wiersz `hosts:`.

### Składnia

```
hosts: źródło1 [AKCJA] źródło2 [AKCJA] źródło3 ...
```

Akcje wyzwalane na podstawie statusu wyniku:

| Akcja | Znaczenie |
|-------|-----------|
| `[NOTFOUND=return]` | zatrzymaj jeśli nazwa nie znaleziona (normalna porażka) |
| `[!UNAVAIL=return]` | zatrzymaj jeśli usługa zwróciła **cokolwiek** (także błędną odpowiedź) |
| `[SUCCESS=continue]` | kontynuuj nawet po sukcesie |

### Źródła

| Źródło | Dostarczane przez | Co robi |
|--------|-------------------|---------|
| `files` | glibc | czyta `/etc/hosts` |
| `dns` | glibc | odpytuje DNS bezpośrednio |
| `resolve` | systemd | systemd-resolved (DNS+mDNS+LLMNR) |
| `mdns4_minimal` | nss-mdns/avahi | mDNS, IPv4, tylko `.local` |
| `mdns4` | nss-mdns/avahi | mDNS, IPv4, dowolna nazwa |
| `myhostname` | systemd | rozwiązuje nazwę lokalnego hosta |
| `mymachines` | systemd | rozwiązuje kontenery systemd-nspawn |

---

## 8. Rozwiązywanie nazw w różnych dystrybucjach

### Ubuntu Server
```
hosts: files dns
```
- Najprostsze: `/etc/hosts`, potem DNS
- Bez mDNS, bez LLMNR — w pełni przewidywalne, bezpieczne dla skryptów

### Ubuntu Desktop (uruchomiony avahi)
```
hosts: files mdns4_minimal [NOTFOUND=return] dns
```
- avahi obsługuje nazwy `.local`, tylko IPv4
- DNS dla wszystkiego innego — czyste rozdzielenie, bez wyścigów
- **Wymaga:** avahi + nss-mdns

### Arch Linux — domyślny (bez avahi)
```
hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
```
- systemd-resolved obsługuje wszystko (DNS + mDNS + LLMNR)
- `[!UNAVAIL=return]` zatrzymuje łańcuch przy jakiejkolwiek odpowiedzi — nawet błędnym IPv6
- **Problematyczne** w sieciach z hostami obsługującymi mDNS

### Arch Linux — GNOME (uruchomiony avahi)
```
hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns wins
```
- avahi jako pierwsze (ale pełne A+AAAA — bez ograniczenia do IPv4)
- systemd-resolved jako fallback (mDNS może być nadal aktywny → ryzyko konfliktu)

### Fedora (uruchomiony avahi)
```
hosts: files myhostname resolve [!UNAVAIL=return] dns
```
- `/etc/hosts` jako pierwsze (bezpieczniejsze niż domyślny Arch)
- Ten sam problem z `[!UNAVAIL=return]` i systemd-resolved

---

## 9. Nasz problem — analiza źródłowa

### Środowisko

```
s1: eth0=10.146.225.1/16 (metric 90)   eth1=172.29.225.1/16 (metric 100)
e1: eth0=172.29.213.51/16 (metric 90)  eth1=10.146.213.51/16 (metric 100)

DNS:  e1 → 10.146.213.51  (eth1 hosta e1, ta sama sieć /16 co eth0 hosta s1)
mDNS: e1 ogłasza fe80::... (link-local IPv6) i 172.29.213.51 (IPv4 eth0)
```

Obie maszyny są podłączone do dwóch podsieci. DNS i mDNS zwracają różne adresy.

### Skrypt

`labsk/c3/arp-zrzut` demonstruje protokół ARP za pomocą `tcpdump` i `arping`
z argumentem będącym nazwą hosta. Potrzebuje poprawnego adresu IPv4, aby:
1. Ustawić filtr BPF tcpdump: `tcpdump arp host <IP>`
2. Wysłać arping do właściwego celu: `arping -I eth0 <IP>`

### Łańcuch awarii

```
Skrypt: arping -I eth0 e1
        tcpdump -i eth0 arp host e1

  getaddrinfo("e1")   [wywołany przez arping i tcpdump]
    |
    v nsswitch: resolve [!UNAVAIL=return]
    |
    v systemd-resolved — mDNS włączony na eth0
    |
    +-- zapytanie mDNS na eth0 (224.0.0.251:5353)
    |     e1 odpowiada: fe80::21e:4fff:fed6:4ed8  (link-local IPv6)
    |     mDNS szybszy niż DNS → wygrywa wyścig
    |
    v [!UNAVAIL=return] — zatrzymuje się tutaj, DNS nigdy nie jest pytany
    |
    zwraca: fe80::21e:4fff:fed6:4ed8

  arping -I eth0 fe80::21e:4fff:fed6:4ed8
    → ARP to protokół tylko IPv4 — arping nie może wysłać ARP dla IPv6
    → cicha porażka, 5-sekundowy timeout, żaden ARP nie wysłany

  tcpdump -i eth0 arp host fe80::21e:4fff:fed6:4ed8
    → filtr BPF dla IPv6 w pakietach ARP (IPv4) → nic nie pasuje
    → przechwytuje tylko przypadkowy ruch ARP na eth0

  Wynik: skrypt przechwytuje spontaniczny ARP hosta e1 szukającego s1
         (wyzwalany wygaśnięciem pamięci podręcznej ARP przez keepalive SSH, ~co 5s)
         → niedeterministyczne wyjście, przechwycony zły kierunek ARP
```

### Wszystkie objawy wyjaśnione

| Objaw | Przyczyna |
|-------|-----------|
| `getent hosts e1` → IPv6 czasami | wyścig: mDNS szybszy niż DNS |
| `getent hosts e1` → zawsze IPv6 (po 1. razie) | systemd-resolved zapisuje w cache odpowiedź mDNS |
| `getent ahostsv4 e1` → `172.29.213.51` | rekord IPv4 mDNS = eth0 hosta e1 (zła podsieć) |
| `host e1` → zawsze `10.146.213.51` | `host` używa czystego DNS, pomija nsswitch |
| Po wyłączeniu mDNS: nadal IPv6 | LLMNR też aktywny, ten sam problem na porcie 5355 |
| 5-sekundowy timeout arping | zły IP → brak hosta pod tym adresem → timeout |
| tcpdump przechwytuje zły kierunek | spontaniczny ARP e1→s1, nie arping s1→e1 |
| skrypt działa z adresem IP | brak rozwiązywania nazw → poprawne IPv4 użyte |
| skrypt działa z s7, nie z e1 | zależy czy cel odpowiada na arping |

---

## 10. Rozwiązanie

### Kolejność ma znaczenie — port 5353

```
systemd-resolved (mDNS) i avahi-daemon oba chcą portu 5353.
Trzeba zwolnić port PRZED uruchomieniem avahi.
```

### Krok 1 — Wyłącz mDNS w systemd-resolved

```sh
echo 'MulticastDNS=no' >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved
```

### Krok 2 — Zainstaluj avahi + nss-mdns

```sh
pacman -S avahi nss-mdns
```

Uwaga: `nss-mdns` jest **opcjonalną** zależnością avahi w Arch.
Samo zainstalowanie avahi NIE wystarczy do integracji z `getaddrinfo()`.

### Krok 3 — Uruchom avahi-daemon

```sh
systemctl enable --now avahi-daemon
```

Port 5353 jest teraz wolny — avahi go zajmuje i poprawnie obsługuje `.local`.

### Krok 4 — Zaktualizuj nsswitch.conf

```
# Przed:
hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns

# Po:
hosts: mymachines mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
```

Restart nie jest potrzebny — nsswitch.conf jest czytany przy każdym wywołaniu `getaddrinfo()`.

Nowy łańcuch rozwiązywania:
```
getent hosts e1
  → mdns4_minimal: "e1" — brak sufiksu .local → NOTFOUND → kontynuuj
  → resolve: mDNS wyłączony → czysty DNS → 10.146.213.51 ✓

getent hosts e1.local
  → mdns4_minimal: .local → avahi rozwiązuje przez mDNS → 10.146.213.51 ✓
```

### Krok 5 — Wyczyść pamięć podręczną

```sh
resolvectl flush-caches
```

Usuwa przeterminowane odpowiedzi mDNS/LLMNR z pamięci podręcznej systemd-resolved.

### Krok 6 — Napraw skrypt

Nawet po naprawieniu systemu skrypty powinny rozwiązywać adresy IP explicite:

```sh
# Zawodne — zależne od nsswitch/mDNS/LLMNR i wyścigów:
IP=$(getent hosts $M | awk '{print $1}')          # może zwrócić IPv6
IP=$(getent ahostsv4 $M | awk 'NR==1{print $1}')  # mDNS IPv4, może być zła podsieć

# Niezawodne — tylko DNS, całkowicie pomija nsswitch:
IP=$(dig +short A $M | head -1)
IP=$(host -t A $M | awk '/has address/{print $NF; exit}')
```

### Skrypt automatyzujący

```sh
#!/bin/sh
# Przełącz mDNS z systemd-resolved na avahi w Arch Linux
# ato 2026

[ "$USER" = 'root' ] && E= || E=echo

$E pacman -Syu avahi nss-mdns

# 1. Najpierw zwolnij port 5353
file=/etc/systemd/resolved.conf
grep -q '^MulticastDNS=no' $file || echo 'MulticastDNS=no' | $E tee -a $file
$E systemctl restart systemd-resolved

# 2. Uruchom avahi (port 5353 teraz wolny)
$E systemctl enable --now avahi-daemon

# 3. Dodaj mdns4_minimal do nsswitch.conf
file=/etc/nsswitch.conf
grep -q mdns4_minimal $file ||
$E sed -i-o '/^hosts:/s/:.*/: mymachines mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns/' $file

# 4. Wyczyść pamięć podręczną
$E resolvectl flush-caches

# 5. Test
getent hosts "${1:-e1}"
```

---

## 11. Podsumowanie

```
Protokół  Port   Transport  Zasięg      Nazwy            Implementuje
────────  ─────  ─────────  ──────────  ───────────────  ──────────────
DNS       53     unicast    globalny    dowolne          bind, unbound,
                                                         systemd-resolved
mDNS      5353   multicast  link-local  .local (RFC)     avahi,
                                                         systemd-resolved
LLMNR     5355   multicast  link-local  krótkie          systemd-resolved,
                                        jednoczłonowe    Windows
```

**Zalecana konfiguracja dla maszyn laboratoryjnych/serwerowych (wszystkie hosty w DNS):**

1. mDNS i LLMNR nie wnoszą wartości gdy wszystkie hosty są w DNS
2. Wyłącz oba w systemd-resolved — lub użyj avahi z `mdns4_minimal`
3. Z avahi: `mdns4_minimal [NOTFOUND=return]` przed `resolve` w nsswitch.conf
4. Skrypty: zawsze używaj `dig +short A` lub `host -t A` dla deterministycznego
   rozwiązywania tylko przez DNS
