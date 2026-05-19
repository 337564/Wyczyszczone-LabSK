# ipv6-privacy — dokumentacja

Skrypt `ipv6-privacy` wykrywa menedżera sieci, raportuje stan prywatności IPv6
i umożliwia włączanie/wyłączanie Privacy Extensions dla interfejsów sieciowych.

---

## Użycie

```
ipv6-privacy [-i dev] [-evx] [on|off|status|info]

  on      włącz IPv6 Privacy Extensions
  off     wyłącz IPv6 Privacy Extensions
  status  pokaż stan (domyślnie gdy brak argumentu)
  info    wyświetl dokumentację w terminalu
  -i dev  ogranicz działanie do podanego interfejsu
  -l      pokaż logi IPv6 dla interfejsu (wymaga -i)
  -e      wykonaj zmiany (domyślnie: suchy przebieg, tylko pokazuje co zrobiłby)
  -v      verbose — pokaż dodatkowe szczegóły
  -x      trace (set -x)
```

Przykład:
```sh
ipv6-privacy                    # status wszystkich interfejsów
ipv6-privacy -i eth1            # status tylko eth1
ipv6-privacy -e -i eth1 on     # włącz prywatność na eth1 (wykonaj)
ipv6-privacy -e on             # włącz na wszystkich interfejsach
```

---

## IPv6 Privacy Extensions — teoria

### Problem: adres EUI-64 ujawnia MAC

Standardowy adres IPv6 generowany metodą EUI-64 (RFC 4291) zawiera adres MAC
karty sieciowej w środku adresu IP:

```
MAC:    e8:40:f2:ec:58:38
EUI-64: fe80::ea40:f2ff:feec:5838
              ^^^^ ^^^^ ^^^^
              MAC z wstawionym FF:FE
```

Taki adres jest stały i globalnie unikalny — pozwala śledzić urządzenie
niezależnie od sieci, do której się podłącza.

### Dwa niezależne mechanizmy prywatności

IPv6 oferuje dwa mechanizmy, które działają niezależnie i można je łączyć:

#### 1. addr_gen_mode — sposób generowania adresu bazowego (RFC 7217)

Kontroluje jak tworzony jest stały adres interfejsu (link-local i SLAAC):

| Wartość | Nazwa           | Opis                                              |
|---------|-----------------|---------------------------------------------------|
| 0       | eui64           | Adres zawiera MAC — niebezpieczne                 |
| 1       | stable-privacy  | Losowy, ale stały per sieć, bez MAC — domyślne NM |
| 2       | random          | Losowy przy każdym starcie interfejsu             |

`stable-privacy` (RFC 7217) generuje adres na podstawie skrótu kryptograficznego
z (prefix sieci, interfejs, tajny klucz) — adres jest różny w każdej sieci,
ale stały w tej samej sieci. MAC nie jest nigdzie widoczny.

#### 2. use_tempaddr — rotujące adresy tymczasowe (RFC 4941)

Dodaje dodatkowe, rotujące adresy globalnego zasięgu obok adresu bazowego:

| Wartość | Opis                                                    |
|---------|---------------------------------------------------------|
| 0       | Brak adresów tymczasowych                               |
| 1       | Tymczasowe włączone, preferuj adres publiczny (stały)   |
| 2       | Tymczasowe włączone, preferuj tymczasowy ← zalecane     |

Adresy tymczasowe rotują co `temp_valid_lft` (domyślnie 7 dni).
Widoczne w `ip -6 addr` jako: `scope global temporary dynamic`

**Ważne:** `use_tempaddr` działa **tylko dla adresów globalnych** przydzielonych
przez SLAAC (z prefiksu z Router Advertisement). Adresy link-local (`fe80::/10`)
nie są rotowane, bo nigdy nie opuszczają lokalnego łącza.

### Połączone efekty

Oba mechanizmy można stosować jednocześnie:

| addr_gen_mode  | use_tempaddr | Efekt                                            |
|----------------|--------------|--------------------------------------------------|
| eui64          | 0            | MAC widoczny w adresie, brak rotacji — najgorzej |
| eui64          | 2            | MAC widoczny w adresie bazowym, globalne rotują  |
| stable-privacy | 0            | MAC ukryty, adres stały per sieć                 |
| stable-privacy | 2            | MAC ukryty + rotacja globalna — najlepiej        |

---

## SLAAC — Stateless Address Autoconfiguration

SLAAC (RFC 4862) to mechanizm samoczynnego przydzielania globalnych adresów IPv6
bez serwera DHCP.

Gdy w sieci jest router IPv6, wysyła on periodycznie **Router Advertisements (RA)**
z prefiksem sieci (np. `2001:db8:abcd:1::/64`). Host łączy ten prefiks ze swoim
interfejsowym identyfikatorem (IID) i tworzy globalny adres:

```
Prefiks z RA:   2001:db8:abcd:0001:: /64
IID (EUI-64):                ::ea40:f2ff:feec:5838
Wynik:          2001:db8:abcd:0001:ea40:f2ff:feec:5838
```

Gdy **nie ma routera IPv6** w sieci (brak RA), host przydziela sobie tylko adres
link-local (`fe80::/10`), który generuje samodzielnie bez żadnego RA.
Adres link-local nigdy nie wychodzi poza lokalne łącze.

**Konsekwencja dla prywatności:** `use_tempaddr=2` (rotacja adresów tymczasowych)
nie ma widocznego efektu w sieciach bez routera IPv6 — nie ma globalnego prefiksu,
więc nie ma co rotować. Sysctl `use_tempaddr=2` jest ustawiony i zadziała gdy
do sieci zostanie dodany router IPv6 (prefiks dotrze przez RA).

---

## Źródło prawdy zależy od menedżera sieci

To jest kluczowa różnica między NetworkManager a systemd-networkd:

```
┌──────────────────────┬────────────────────────┬─────────────────────────┐
│ Manager              │ addr_gen_mode          │ use_tempaddr            │
├──────────────────────┼────────────────────────┼─────────────────────────┤
│ systemd-networkd     │ kernel sysctl          │ kernel sysctl           │
│ NetworkManager       │ nmcli ipv6.addr-gen-   │ nmcli ipv6.ip6-privacy  │
│                      │   mode  (nie sysctl!)  │   + sysctl              │
└──────────────────────┴────────────────────────┴─────────────────────────┘
```

**NetworkManager zarządza adresami samodzielnie.** Kernel sysctl `addr_gen_mode`
może pokazywać `1` (stable-privacy), podczas gdy NM faktycznie generuje adresy
EUI-64 — ponieważ NM ignoruje ten sysctl i używa własnej konfiguracji.
Wartość miarodajna dla NM: `nmcli -g ipv6.addr-gen-mode connection show <conn>`.

NM ustawia `use_tempaddr` przez sysctl, ale **dopiero po odebraniu RA**.
W sieciach bez routera IPv6 sysctl może nigdy nie zostać ustawiony przez NM —
dlatego skrypt ustawia go bezpośrednio przez `sysctl -w`.

### Relacja: konfiguracja → menedżer → sysctl → jądro

```
plik konfiguracyjny
  → menedżer (NM lub networkd) przy starcie interfejsu
    → sysctl net.ipv6.conf.<iface>.use_tempaddr
      → jądro generuje (lub nie) tymczasowe adresy
```

Hierarchia sysctl dla `use_tempaddr`:
- `net.ipv6.conf.default.use_tempaddr` — szablon kopiowany do nowego interfejsu
- `net.ipv6.conf.all.use_tempaddr` — **nie** jest globalnym nadpisaniem
  (w przeciwieństwie do `forwarding`); liczy się wartość per-interfejs
- `net.ipv6.conf.<iface>.use_tempaddr` — rzeczywisty stan runtime interfejsu

---

## Pliki konfiguracyjne

### systemd-networkd

```
/etc/systemd/networkd.conf.d/ipv6-privacy-extensions.conf
```
```ini
[Network]
IPv6PrivacyExtensions=yes
```
Wartości: `yes` | `no` | `kernel` (zostaw sysctl bez zmian)

Po zmianie: `networkctl reload`

### NetworkManager

```
/etc/NetworkManager/conf.d/ipv6-privacy.conf
```
```ini
[connection]
ipv6.ip6-privacy=2
```
Wartości: `-1` (default) | `0` (off) | `1` (prefer-public) | `2` (prefer-temp)

Per-połączenie przez nmcli:
```sh
nmcli connection modify <conn> ipv6.ip6-privacy 2
nmcli connection modify <conn> ipv6.addr-gen-mode stable-privacy
nmcli connection up <conn>
```

---

## Weryfikacja — wyniki testów na s4/eth1 (NetworkManager)

Polecenie: `nmcli conn mod <conn> <args> && nmcli conn up <conn>`

```
┌───────────────────────────────────────────────────────┬─────────────────────────┬───────────────────────────────────┬───────────────────────────┬─────────────┐
│ <args>                                                │ Mode                    │ Verdict skryptu                   │ Adres (link-local)        │ MAC widoczny│
├───────────────────────────────────────────────────────┼─────────────────────────┼───────────────────────────────────┼───────────────────────────┼─────────────┤
│ ipv6.addr-gen-mode eui64           ipv6.ip6-privacy 0 │ eui64 + priv=0          │ MAC EXPOSED, no temp              │ fe80::ea40:f2ff:feec:5838 │ tak         │
│ ipv6.addr-gen-mode eui64           ipv6.ip6-privacy 2 │ eui64 + priv=2          │ EUI-64 + temp (SLAAC only)        │ fe80::ea40:f2ff:feec:5838 │ tak         │
│ ipv6.addr-gen-mode stable-privacy  ipv6.ip6-privacy 0 │ stable-privacy + priv=0 │ MAC hidden, no temp               │ fe80::6919:2f3b:a83e:c09c │ nie         │
│ ipv6.addr-gen-mode stable-privacy  ipv6.ip6-privacy 2 │ stable-privacy + priv=2 │ MAC hidden + temp  ← full privacy │ fe80::6919:2f3b:a83e:c09c │ nie         │
└───────────────────────────────────────────────────────┴─────────────────────────┴───────────────────────────────────┴───────────────────────────┴─────────────┘
```

**Uwaga:** `ip6-privacy=2` (adresy tymczasowe) robi widoczną różnicę tylko dla
globalnych adresów SLAAC. Ta sieć nie ma routera IPv6, więc widoczne są tylko
adresy link-local. Sysctl `use_tempaddr=2` jest ustawiony i zadziała gdy pojawi
się globalny prefiks z RA.

---

## Diagnostyka

```sh
# Stan adresów IPv6
ip -6 addr show dev eth1

# Sysctl runtime
sysctl net.ipv6.conf.eth1.use_tempaddr
sysctl net.ipv6.conf.eth1.addr_gen_mode

# NM — konfiguracja połączenia
nmcli connection show LAN | grep ipv6

# networkd
networkctl status eth1

# Logi
ipv6-privacy -i eth1 -l
journalctl -u NetworkManager -b | grep -i 'ipv6\|privacy\|tempaddr'
```

---

## Linki

- RFC 4941 — Privacy Extensions for Stateless Address Autoconfiguration  
  <https://www.rfc-editor.org/rfc/rfc4941>
- RFC 7217 — Semantically Opaque IIDs (stable-privacy)  
  <https://www.rfc-editor.org/rfc/rfc7217>
- RFC 4862 — SLAAC  
  <https://www.rfc-editor.org/rfc/rfc4862>
- ArchWiki IPv6 Privacy extensions  
  <https://wiki.archlinux.org/title/IPv6#Privacy_extensions>
- NetworkManager settings — ipv6.ip6-privacy  
  <https://networkmanager.dev/docs/api/latest/nm-settings-nmcli.html>
- systemd.network — IPv6PrivacyExtensions  
  <https://www.freedesktop.org/software/systemd/man/systemd.network.html>
