# c5 — VPS, chmura i prywatna sieć administracyjna

## Cel ćwiczenia

Ćwiczenie skupia się na skryptowej konfiguracji serwera w chmurze albo serwera lokalnego. W praktyce chodzi o umiejętność automatycznego utworzenia VPS, skonfigurowania dostępu SSH, podłączenia go do prywatnej sieći administracyjnej i uruchomienia prostej usługi.

Zakres:

- utworzenie VPS w chmurze,
- konfiguracja użytkownika, powłoki i `~/bin`,
- instalacja narzędzi pomocniczych,
- podłączenie do ZeroTier, Tailscale albo podobnej sieći prywatnej,
- konfiguracja nazw i adresów,
- uruchomienie usługi, np. WWW, SMB lub NFS.

## Wymagany efekt zadania

Zadanie przewiduje napisanie czterech prostych skryptów w `/bin/sh`:

1. `gen-vps` — tworzy nowy minimalny serwer VPS z publicznym adresem IP i nazwą DNS.
2. `config-vps` — wykonuje podstawową konfigurację konta i narzędzi na VPS.
3. `install-adm` — instaluje klienta sieći administracyjnej na stacji i VPS.
4. `config-adm` — dołącza stację, VPS i opcjonalny laptop do prywatnej sieći ADM.

Skrypty mają być maksymalnie proste, automatyczne i nie powinny wymagać interakcji.

## Minimalna koncepcja działania

`gen-vps` powinien zapisać DNS serwera do pliku, np.:

```bash
printf '%s\n' "$DNS" > ~/.vps
ssh "$(cat ~/.vps)"
```

`config-vps` może wykonać typowe kroki:

```bash
mkdir -p ~/bin
printf '%s\n' 'ip -br "$@"' > ~/bin/ipb
chmod +x ~/bin/ipb
```

Jeżeli te same polecenia działają lokalnie i na VPS, można użyć przekierowania przez SSH:

```bash
ssh vps < ./install-adm
ssh vps < ./config-adm
```

## Nazwy w sieći ADM

W materiałach pojawia się konwencja:

- `vps` — publiczny adres serwera,
- `vps.adm` — adres serwera w sieći prywatnej,
- `sX.adm` — stacja laboratoryjna w sieći prywatnej,
- `lap.adm` — laptop, jeśli jest dołączony.

Po wykonaniu skryptów powinny działać m.in.:

```bash
ping -c1 vps
ssh vps ipb
ssh vps ping -c1 sX.adm
ping -c1 vps.adm
ssh vps.adm ipb
ping -c1 lap.adm
```

## ZeroTier czy Tailscale

Oba narzędzia tworzą sieć nakładkową między hostami. Wybór zależy od wymagań zadania i konta użytkownika. W notatkach laboratoryjnych najczęściej pojawia się ZeroTier/Tailscale jako prywatna sieć administracyjna, która łączy laptop, stację i VPS bez wystawiania prywatnych usług bezpośrednio do Internetu.

## Google Cloud CLI jako odpowiednik Azure CLI

Dla Google Cloud odpowiednikiem `az` jest `gcloud` z Google Cloud CLI:

```bash
sudo pacman -S google-cloud-cli
gcloud auth login
gcloud config set project TWOJ_PROJECT_ID
gcloud compute instances list
```

## Pliki w tym katalogu

- `schematy/ADM.drawio` — schemat sieći administracyjnej.
- `zadania/` — zachowane wersje zadania z grup.
- `materialy/google-cloud.md` — analogie `az` ↔ `gcloud`.
