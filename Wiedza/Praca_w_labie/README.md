# Praca w laboratorium i zdalnie

## Start lokalny na stacji LabSK

1. Poczekaj na ekran logowania, ale nie loguj się graficznie.
2. Przełącz się na konsolę tekstową: `Ctrl+Alt+F2`.
3. Zaloguj się jako `stud`.
4. Zaloguj się na volta przez SSH.
5. Skopiuj własne konto na stację, np. `copy-user -se`.
6. Wróć do konsoli graficznej: `Alt+F7`.
7. Zaloguj się na własne konto.
8. Zamontuj OneDrive, jeśli jest potrzebny.
9. Uruchom VS Code: `code labsk`.
10. Otwórz terminal wbudowany w VS Code.

## Praca zdalna

Polecenie `lab` albo komunikat po logowaniu na volta pokazuje, które stacje działają i jaki mają system. Na systemach z GNOME siećią zarządza zwykle NetworkManager (`nmcli`), a na systemach konsolowych `systemd-networkd` (`networkctl`).

Na stacji pracuj na własnym koncie. Po skopiowaniu konta z volta można często logować się bez `user@`, bo SSH użyje bieżącej nazwy użytkownika.

Z domu loguj się bezpośrednio do stacji przez ZeroTier ZET, a nie przez volta, jeżeli wykonujesz zadanie na stacji. ZeroTier jest wymagany, bo stacje laboratoryjne są w prywatnej sieći i nie muszą być osiągalne z publicznego Internetu.

## Alternatywne drogi dostępu

Dla stacji `sX` mogą istnieć nazwy:

- `sX` — sieć `10.146/16`,
- `sXl` — sieć `172.29/16`,
- `sXw` — Wi-Fi, jeśli działa.

Adres IPv6 link-local wymaga podania interfejsu, np. `%eno1`, ponieważ taki adres ma znaczenie tylko na konkretnym łączu.

## Reperacja sieći `10.146/16`

Usunięcie adresu `10.146/16` albo wyłączenie interfejsu `eth0` może zerwać SSH i dostęp do katalogów siećiowych w `$PATH`. Najpierw spróbuj dostać się przez alternatywny adres (`sXl`, Wi-Fi albo IPv6), a potem sprawdź stan:

```bash
ip -br -c link
ip -br -c address
```

Najprostsza naprawa przez przełączenie interfejsu:

```bash
sudo ip link set down dev eth0
sudo ip link set up dev eth0
```

Jeżeli potrzeba jawnie wywołać klienta DHCP:

```bash
sudo dhcpcd -T1 eth0
```

`-T1` uruchamia test jednorazowy, a nie zostawia dodatkowego demona DHCP w tle.

## Reperacja grafiki

Jeżeli nie działa logowanie graficzne:

1. Przełącz się na konsolę tekstową: `Ctrl+Alt+F2`.
2. Zaloguj się jako `stud`.
3. Na Arch Linux zrestartuj menedżera logowania:

```bash
sudo systemctl restart lightdm
```

Na Ubuntu sprawdź sesje:

```bash
loginctl
```

Zakończ błędną sesję inną niż bieżący terminal:

```bash
sudo loginctl terminate-session NUMER_SESJI
```
