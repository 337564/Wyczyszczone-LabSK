# c2 — interfejsy, model OSI i adresacja

## Cel ćwiczenia

Ćwiczenie dotyczy identyfikacji interfejsów siećiowych oraz adresacji na warstwie 2 i 3 modelu OSI. Najważniejsze jest umieć odczytać rzeczywisty stan sieći komputera, narysować go i wyjaśnić, skąd biorą się widoczne adresy.

Zakres:

- model OSI jako język porządkowania pojęć,
- interfejsy fizyczne i logiczne,
- adres MAC i adresy warstwy 2,
- IPv4, IPv6, maski, prefiksy i CIDR,
- adresy punktowe, rozgłoszeniowe i grupowe,
- analiza sieći domowej oraz sieći LabSK.

## Model OSI w tym ćwiczeniu

W praktyce laboratoryjnej najczęściej używane są trzy dolne warstwy:

1. **Warstwa fizyczna** — medium i sygnał: kabel, światłowód, Wi-Fi, karta siećiowa.
2. **Warstwa łącza danych** — lokalna komunikacja w jednym segmencie L2; typowe adresy to MAC.
3. **Warstwa siećiowa** — komunikacja między siećiami; typowe adresy to IPv4 i IPv6.

Model OSI nie jest „instrukcją implementacji”, tylko mapą pojęć. Pomaga odpowiedzieć, czy problem dotyczy kabla/karty, adresu MAC/ARP, adresu IP, trasowania, portu TCP/UDP czy usługi aplikacyjnej.

## Interfejs fizyczny i logiczny

Interfejs fizyczny jest powiązany ze sprzętem, np. Ethernet albo Wi-Fi. Interfejs logiczny może być tworzony programowo, np. `lo`, interfejs VPN, bridge, VLAN, tun/tap albo interfejs maszyny wirtualnej.

Przydatne polecenia:

```bash
ip -br link
ip -br address
ip route
etstat -rn        # starsze systemy
```

Windows:

```powershell
Get-NetAdapter
Get-NetIPConfiguration
Get-NetIPAddress
Get-NetRoute
```

Interfejs `lo` albo `lo0` to pętla zwrotna. Pozwala procesom na tej samej maszynie komunikować się przez stos siećiowy bez używania karty fizycznej. Typowy adres IPv4 pętli zwrotnej to `127.0.0.1/8`, a IPv6 to `::1/128`.

## Adresy warstwy 2

Adres MAC jest zwykle zapisywany jako 6 bajtów, np. `00:1e:8c:f2:6e:c5`. W Ethernetcie pakiet zawiera adres MAC źródłowy i docelowy. Adres MAC można programowo zmienić, co bywa użyteczne przy testach, prywatności lub naprawie konfiguracji, ale dwa takie same adresy MAC w jednej sieći LAN powodują konflikty.

Typy adresów warstwy 2:

- **unicast** — jeden konkretny interfejs,
- **broadcast** — wszyscy w danym segmencie L2,
- **multicast** — grupa odbiorców.

## Adresy warstwy 3: IPv4 i IPv6

IPv4 ma 32 bity i jest zwykle zapisywany jako `a.b.c.d`, np. `10.146.225.1`. IPv6 ma 128 bitów i zapis szesnastkowy, np. `fe80::21e:8cff:fef2:6ec5`.

CIDR zapisuje adres i długość prefiksu, np. `10.146.225.1/16`. Dla IPv4 adres sieći i adres rozgłoszeniowy są zarezerwowane, dlatego w typowej podsieći liczba adresów hostów jest o dwa mniejsza niż liczba wszystkich kombinacji. Przykład: `/24` ma 256 adresów, ale zwykle 254 adresy hostów.

Prywatne pule IPv4:

- `10.0.0.0/8`,
- `172.16.0.0/12`,
- `192.168.0.0/16`.

Adresy link-local:

- IPv4: `169.254.0.0/16`,
- IPv6: `fe80::/10`.

Adres IPv6 link-local wymaga czasem podania interfejsu, np. `fe80::...%eth0`, ponieważ ten sam prefiks występuje lokalnie na wielu interfejsach.

## Co zbadać w sieći domowej

Dla interfejsu, przez który komputer łączy się z Internetem, ustal:

- nazwę i typ interfejsu,
- adres MAC,
- adres IPv4, maskę/prefiks i adres sieći,
- bramę domyślną,
- adresy IPv6,
- serwery DNS,
- czy adres IPv4 jest prywatny, czy globalny.

Minimalny zestaw poleceń w Linuksie:

```bash
ip -br link
ip -br address
ip route
resolvectl status 2>/dev/null || cat /etc/resolv.conf
```

## Zadanie praktyczne z materiałów

Przykładowe zadanie wymagało napisania prostego polecenia `ip4`, które z dowolnego katalogu pokaże stan sieći na wskazanej stacji:

```bash
ip4 s3
```

Sens zadania: połączyć SSH, skryptowanie i odczyt adresów warstwy 2 oraz 3. Skrypt powinien być nieinteraktywny, krótki i odporny na uruchomienie z innego katalogu.

## Pliki w tym katalogu

- `schematy/` — zachowane diagramy i grafiki potrzebne do zrozumienia topologii.
- `zadania/` — bieżące wejściówki i zadania.
- `linki.md` — linki źródłowe dotyczące adresacji i warstw.
