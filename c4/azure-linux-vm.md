# Azure Linux VM — Instrukcja dla studentów

Instrukcja opisuje jak utworzyć i używać osobistej maszyny wirtualnej Linux w chmurze Azure
na zajęciach laboratoryjnych. Korzystamy z konta **Azure for Students** (100 USD kredytu,
bez karty kredytowej).

Każdy student otrzymuje własną maszynę ze stałą nazwą DNS. Maszyna jest tworzona od nowa
na początku każdych zajęć i usuwana po ich zakończeniu — koszt między sesjami to tylko
opłata za adres IP (~3,65 USD/mc), bez kosztów dysku.

---

## Wymagania wstępne

### 1. Konto Azure for Students

Zarejestruj się na <https://azure.microsoft.com/pl-pl/free/students/> używając uczelnianego
adresu e-mail. Otrzymujesz 100 USD kredytu ważnego przez 12 miesięcy.

Dokumentacja programu: <https://learn.microsoft.com/pl-pl/azure/education-hub/azure-dev-tools-teaching/azure-students-program>

### 2. Azure CLI (`az`)

Dokumentacja instalacji: <https://learn.microsoft.com/pl-pl/cli/azure/install-azure-cli-linux>

Instalacja na Arch Linux:
```bash
sudo pacman -S azure-cli
```

Instalacja na Ubuntu:
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Weryfikacja:
```bash
az version
```

### 3. Klucz SSH

Sprawdź czy już posiadasz klucz:
```bash
ls ~/.ssh/id_ed25519.pub
```

Jeśli nie, wygeneruj:
```bash
ssh-keygen -t ed25519
```

Dokumentacja: <https://learn.microsoft.com/pl-pl/azure/virtual-machines/linux/create-ssh-keys-detailed>

### 4. Skrypty laboratoryjne

Skopiuj skrypty dostarczone przez prowadzącego do `~/bin/` i nadaj uprawnienia do wykonywania:
```bash
mkdir -p ~/bin
cp az-register vm-create vm-create-ubuntu ~/bin/
chmod +x ~/bin/az-register ~/bin/vm-create ~/bin/vm-create-ubuntu
```

Upewnij się, że `~/bin` jest w PATH (dodaj do `~/.bashrc` lub `~/.zshrc`):
```bash
export PATH="$HOME/bin:$PATH"
```

---

## Logowanie do Azure

```bash
az login                    # otwiera przeglądarkę (sesja graficzna)
az login --use-device-code  # wklej kod na microsoft.com/devicelogin (sesja SSH)
```

Dokumentacja: <https://learn.microsoft.com/pl-pl/cli/azure/authenticate-azure-cli-interactively>

Weryfikacja — powinno pojawić się **Azure for Students** jako nazwa subskrypcji:
```bash
az account show
```

---

## Jednorazowa rejestracja

Uruchom raz, aby zarezerwować stałą nazwę DNS:
```bash
az-register
```

Tworzy:
- Grupę zasobów `LabSK`
- Stały publiczny adres IP z DNS: `<twoja-nazwa>.polandcentral.cloudapp.azure.com`

Skrypt jest idempotentny — bezpieczne do ponownego uruchomienia, pomija istniejące zasoby.

---

## Tworzenie maszyny wirtualnej Arch Linux

Uruchom na początku każdych zajęć, aby uzyskać świeżą maszynę:
```bash
vm-create
```

Skrypt tworzy maszynę, wyświetla komendę SSH, po czym ją zatrzymuje.
Uruchom maszynę gdy jesteś gotowy do pracy:
```bash
az vm start --name arch
ssh <twoja-nazwa>@<twoja-nazwa>.polandcentral.cloudapp.azure.com
```

Po pierwszym logowaniu zaktualizuj system:
```bash
sudo pacman -Syu
```

Dokumentacja: <https://learn.microsoft.com/pl-pl/azure/virtual-machines/linux/quick-create-cli>

---

## Tworzenie maszyny wirtualnej Ubuntu 26.04

```bash
vm-create-ubuntu
az vm start --name ubu
ssh <twoja-nazwa>@<twoja-nazwa>-ubu.polandcentral.cloudapp.azure.com
```

---

## Koniec zajęć — usunięcie maszyny

Po zakończeniu pracy zawsze usuń maszynę. Adres IP i nazwa DNS są zachowane na następne zajęcia.

```bash
az vm delete --name arch --yes   # Arch Linux
az vm delete --name ubu --yes    # Ubuntu
```

> **Uwaga:** `az vm deallocate` pozostawia dysk i nalicza opłaty (~1,54 USD/mc).
> Używaj `az vm delete`, aby uniknąć kosztów dysku między sesjami.

Dokumentacja: <https://learn.microsoft.com/pl-pl/cli/azure/vm#az-vm-delete>

---

## Sprawdzenie stanu maszyny

```bash
az vm list --output table
```

---

## Koszty

| Zasób | Między zajęciami | Maszyna działa |
|-------|-----------------|----------------|
| Publiczny adres IP | ~3,65 USD/mc | ~3,65 USD/mc |
| Dysk OS | 0 USD | 0 USD |
| Obliczenia (B1ms) | 0 USD | ~0,024 USD/godz |

**Łącznie między zajęciami: ~3,65 USD/mc** — zdecydowanie w granicach kredytu rocznego 100 USD.
Trzy godziny laboratoriów kosztują ~0,07 USD obliczeń.

Kalkulator cen Azure: <https://azure.microsoft.com/pl-pl/pricing/calculator/>

Sprawdź pozostały kredyt (dostępne tylko w portalu, nie przez `az` CLI):
<https://portal.azure.com/#view/Microsoft_Azure_Education/EducationMenuBlade/~/overview>

---

## Rozwiązywanie problemów

| Problem | Rozwiązanie |
|---------|-------------|
| `az: command not found` | Zainstaluj Azure CLI — patrz pkt. 2 |
| `id_ed25519.pub: No such file` | Uruchom `ssh-keygen -t ed25519` |
| `Resource group LabSK not found` | Uruchom `az-register` |
| `Public IP not found` | Uruchom `az-register` |
| Nazwa DNS jest zajęta | Zmień `DNS_NAME` w skrypcie `az-register` na unikalną wartość, np. `jkowalski2` |
| Odmowa połączenia / timeout | VM może się jeszcze uruchamiać — poczekaj 30s i spróbuj ponownie |
| Brak kredytów | Sprawdź saldo w portalu (link powyżej) |

---

## Przydatne linki

| Temat | Link |
|-------|------|
| Azure for Students — rejestracja | <https://azure.microsoft.com/pl-pl/free/students/> |
| Azure CLI — instalacja | <https://learn.microsoft.com/pl-pl/cli/azure/install-azure-cli-linux> |
| Azure CLI — dokumentacja az vm | <https://learn.microsoft.com/pl-pl/cli/azure/vm> |
| Klucze SSH w Azure | <https://learn.microsoft.com/pl-pl/azure/virtual-machines/linux/create-ssh-keys-detailed> |
| Maszyny wirtualne Linux — szybki start | <https://learn.microsoft.com/pl-pl/azure/virtual-machines/linux/quick-create-cli> |
| Rozmiary VM serii B (burstable) | <https://learn.microsoft.com/pl-pl/azure/virtual-machines/bsv2-series> |
| Kalkulator cen Azure | <https://azure.microsoft.com/pl-pl/pricing/calculator/> |
| Azure Education Hub | <https://learn.microsoft.com/pl-pl/azure/education-hub/> |
| Saldo kredytu (portal) | <https://portal.azure.com/#view/Microsoft_Azure_Education/EducationMenuBlade/~/overview> |
| Portal Azure | <https://portal.azure.com> |
