# c6 — zapora, kontenery, usługi w chmurze i sieć wirtualna

## Cel ćwiczenia

Ćwiczenie dotyczy złożenia kilku elementów w działającą usługę: zapory, kontenera albo maszyny wirtualnej, usługi sieciowej oraz prywatnej sieci dostępowej.

Zakres:

- podstawowa konfiguracja zapory w Windows i Unix/Linux,
- uruchomienie kontenera OCI w Dockerze albo Incusie,
- wystawienie prostej usługi, np. WWW,
- podłączenie serwera w chmurze do ZeroTier/Tailscale,
- sprawdzenie dostępności usługi i tras.

## Zapora

Zapora powinna przepuszczać tylko ruch potrzebny do zadania. Dla usługi WWW typowe porty to:

- TCP 80 — HTTP,
- TCP 443 — HTTPS,
- TCP 22 — SSH, jeżeli administracja ma być bezpośrednia.

Na Linuksie nowoczesnym narzędziem jest `nftables`:

```bash
sudo nft list ruleset
sudo systemctl status nftables
```

Na Windows sprawdzaj reguły zapory i profile sieciowe:

```powershell
Get-NetFirewallRule
Get-NetConnectionProfile
```

## Kontenery i VM

Maszyna wirtualna emuluje cały system operacyjny z własnym jądrem. Kontener współdzieli jądro gospodarza, ale izoluje procesy, system plików i sieć. VM jest cięższa, ale daje silniejszą separację systemu. Kontener jest lżejszy i wygodny do szybkiego uruchamiania usług.

Przykładowa usługa WWW w Dockerze:

```bash
docker run --rm -p 8080:80 nginx
curl http://localhost:8080/
```

W Incusie można uruchamiać kontenery systemowe albo obrazy OCI, zależnie od konfiguracji hosta.

## Podłączenie chmury do sieci prywatnej

Serwer w chmurze może mieć publiczny adres tylko do administracji i jednocześnie adres prywatny w ZeroTier/Tailscale. Dzięki temu usługi laboratoryjne nie muszą być wystawione publicznie.

Minimalna kontrola po podłączeniu:

```bash
ip -br address
ip route
zerotier-cli listnetworks 2>/dev/null || true
tailscale status 2>/dev/null || true
```

## Przykładowy dziennik Azure

W katalogu [materialy/](materialy/) zachowano przykładowy dziennik studenta z maszyny Ubuntu w Azure. Jest przydatny jako wzorzec tego, jakie informacje pokazać w sprawozdaniu: adresy interfejsów, trasy, sieci ZeroTier, Docker/Incus i testy dostępności.

## Pliki w tym katalogu

- [materialy/azure-przykladowy-dziennik-studenta.md](materialy/azure-przykladowy-dziennik-studenta.md) — przykład przebiegu pracy.
- `materialy/docker.md`, `materialy/azure.md`, `materialy/nftables.md` — notatki z poprzednich wersji ćwiczenia, zachowane jako przydatne materiały.
- [linki.md](linki.md) — odnośniki do Incus, Azure CLI i `nftables`.
