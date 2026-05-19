# Narzędzia i skrypty

Zachowano skrypty PowerShell i shell, które zawierają wiedzę proceduralną albo mogą być użyteczne w laboratoriach. Usunięto pliki wykonywalne, skróty Windows i logi instalacyjne bez wartości dydaktycznej.

Najczęstsze grupy:

- instalacja narzędzi: [install/](install/),
- DHCP i adresacja: [`Enable-DHCP.ps1`](Enable-DHCP.ps1), [`Get-DHCP.ps1`](Get-DHCP.ps1), [`IPv4-zakres.ps1`](IPv4-zakres.ps1), [`ip-zakres`](ip-zakres),
- SSH: [`ssh-copy-id.ps1`](ssh-copy-id.ps1), [`ssh-keyexport.ps1`](ssh-keyexport.ps1), [`install/ssh-server.ps1`](install/ssh-server.ps1),
- Wireshark/tshark: [`tshark-DHCP.ps1`](tshark-DHCP.ps1), [`tshark-NR.ps1`](tshark-NR.ps1),
- ZeroTier/Tailscale: [`zerotier-join.ps1`](zerotier-join.ps1), [`tailscale-join.ps1`](tailscale-join.ps1),
- VirtualBox: [`vbmk.ps1`](vbmk.ps1), [`vbmk-freebsd`](vbmk-freebsd), [`vb-alp`](vb-alp).

Przed uruchomieniem dowolnego skryptu przeczytaj go. Część skryptów zakłada konkretne środowisko LabSK.
