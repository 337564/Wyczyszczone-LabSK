# IPv6

Ten katalog zawiera ogólne materiały o IPv6, w tym FAQ, adresy ULA i prywatność adresów.

Najważniejsze pojęcia do ćwiczeń:

- IPv6 ma 128 bitów.
- `::1/128` to pętla zwrotna.
- `fe80::/10` to adresy link-local, ważne tylko na lokalnym łączu.
- Adres link-local w poleceniu może wymagać strefy/interfejsu, np. `%eth0`.
- ULA (`fc00::/7`, w praktyce często `fd00::/8`) służy do adresacji lokalnej nieprzeznaczonej do routingu globalnego.
- Privacy Extensions zmieniają sposób generowania adresów, aby ograniczyć śledzenie hosta po stałym identyfikatorze interfejsu.
