# c4 — DNS, mDNS, LLMNR, NBNS, trasowanie i Azure VM

## Cel ćwiczenia

Ćwiczenie dotyczy dwóch dużych tematów: rozwiązywania nazw oraz trasowania. Dodatkowo zawiera instrukcję utworzenia osobistej maszyny Linux w Azure.

Zakres:

- DNS, mDNS, LLMNR i NBNS,
- algorytm rozwiązywania nazw w Windows i Linuksie,
- diagnostyka przez `host`, `dig`, `nslookup`, `resolvectl`, `getent`, `tshark`,
- tablica tras i algorytm wyboru trasy,
- włączanie przekazywania pakietów,
- podstawowe tworzenie VM w Azure.

## Rozwiązywanie nazw

### DNS

DNS to hierarchiczny system zamiany nazw na adresy. Najczęściej używa portu 53 UDP/TCP. W Linuksie konfiguracja jest widoczna m.in. w:

- `/etc/resolv.conf`,
- `/etc/hosts`,
- `/etc/nsswitch.conf`,
- `resolvectl status` przy `systemd-resolved`.

Polecenia diagnostyczne:

```bash
host s1.zet.pw.edu.pl
dig s1.zet.pw.edu.pl
nslookup s1.zet.pw.edu.pl
getent hosts s1
resolvectl query s1
```

### mDNS

mDNS działa lokalnie w segmencie L2 i używa multicastu `224.0.0.251:5353` dla IPv4 oraz `ff02::fb` dla IPv6. Standardowo dotyczy nazw `.local`, np. `drukarka.local`. Nie wymaga centralnego serwera DNS.

### LLMNR

LLMNR to mechanizm link-local, typowo dla krótkich nazw jednoczłonowych, np. `s1`. Używa `224.0.0.252:5355` i `ff02::1:3`. W praktyce może konkurować z DNS i powodować mylące wyniki, szczególnie gdy szybciej zwraca adres IPv6 link-local.

### NBNS

NBNS/NetBIOS Name Service to starszy mechanizm rozwiązywania nazw Windows. W nowych konfiguracjach zwykle lepiej polegać na DNS, a NBNS traktować jako źródło zgodności wstecznej.

### Monitorowanie zapytań nazw

```bash
tshark -Y 'dns || llmnr || mdns || nbns' -i zet
```

## Bezpieczny wybór mDNS w Linuksie

Jeśli sieć ma normalny DNS dla hostów laboratoryjnych, mDNS nie powinien przejmować zwykłych krótkich nazw. Bezpieczny wariant NSS to `mdns4_minimal`, bo ogranicza mDNS do `.local` i tylko do IPv4. Dzięki temu zapytanie `e1` może przejść dalej do DNS, a `e1.local` zostanie obsłużone przez mDNS.

## Trasowanie

Tablica tras mówi, gdzie wysłać pakiet o danym adresie docelowym. System wybiera najbardziej szczegółową pasującą trasę, czyli najdłuższy prefiks. Dopiero gdy brakuje trasy szczegółowej, używana jest trasa domyślna.

Polecenia:

```bash
ip route
ip -6 route
ip route get 8.8.8.8
traceroute 8.8.8.8
tracepath 8.8.8.8
```

Windows:

```powershell
Get-NetRoute
Test-NetConnection 8.8.8.8
tracert 8.8.8.8
```

## Przekazywanie pakietów

Na zwykłym komputerze przekazywanie pakietów jest standardowo wyłączone, ponieważ host końcowy nie powinien przypadkowo działać jak router. Włączenie routingu bez świadomej konfiguracji może utworzyć niekontrolowaną ścieżkę między siećiami i utrudnić diagnostykę albo bezpieczeństwo.

Linux:

```bash
sysctl net.ipv4.ip_forward
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

Windows:

```powershell
Get-NetIPInterface -AddressFamily IPv4 | Sort IfIndex | ft IfIndex,IfAlias,ConnectionState,Forwarding
Set-NetIPInterface -InterfaceAlias "Ethernet" -Forwarding Enabled
```

## Azure Linux VM

Instrukcja [azure-linux-vm.md](azure-linux-vm.md) opisuje proces:

1. założenia Azure for Students,
2. instalacji `az`,
3. przygotowania klucza SSH,
4. jednorazowej rejestracji zasobów,
5. utworzenia i usunięcia VM,
6. kontroli kosztów.

Najważniejsza zasada kosztowa: po zajęciach usuwać maszynę (`az vm delete`), a zostawiać tylko stały adres IP/DNS, jeżeli taki jest wymagany przez skrypty.

## Pliki w tym katalogu

- [DNS.md](DNS.md) — pełniejsza notatka o DNS, mDNS, LLMNR i `systemd-resolved`.
- [azure-linux-vm.md](azure-linux-vm.md) — instrukcja maszyny Linux w Azure.
- `schematy/trasowanie.drawio` — diagram trasowania.
- `materialy/` — zrzuty i przykłady diagnostyczne.
