# RAPORT CZYSZCZENIA

## Zakres prac

Przetworzono archiwum `labsk.tar.gz` zawierające 1630 plików i 171 katalogów. Wykryto 73 pliki PDF oraz 282 grup duplikatów binarnie identycznych obejmujących łącznie 731 plików.

Wynikowa baza ma 346 plików i uproszczony układ: `c1`–`c6`, `Wiedza`, `Moze_potrzebne` oraz ten raport.

## Co usunięto i dlaczego

Usunięto lub nie przeniesiono do czystej bazy:

- pliki systemowe i techniczne: `.DS_Store`, `Thumbs.db`, `__MACOSX`, skróty `.lnk`, pliki `.msrcIncident`, pliki `.dtmp`, `.bak`, `.bkp`, tymczasowe i autosave;
- artefakty budowania LaTeX i podobne: `.aux`, `.log`, `.dvi`, `.toc`, `synctex`, częściowo wygenerowane PDF-y, jeżeli istniał sensowniejszy plik źródłowy albo aktualny odpowiednik;
- cache i pobrane assety stron WWW, zwłaszcza minifikowane `.js`/`.css` z dokumentacji Tailscale/ZeroTier, jeśli nie wnosiły wiedzy dydaktycznej;
- `grep.exe` i skróty programów, bo są binariami/skrótami instalacyjnymi, a nie materiałem do nauki;
- stare roczniki `old/19`–`old/24`, gdy były duplikatami aktualnych materiałów lub miały aktualny odpowiednik;
- `c1.zip`, ponieważ zawierał kopię katalogu `c1`.

## Jak pogrupowano materiały

- `c1` — materiały o terminalu, SSH, kluczach, pracy lokalnej/zdalnej i podstawach Uniksa.
- `c2` — materiały o modelu OSI, interfejsach, MAC, IPv4/IPv6, CIDR i analizie sieci.
- `c3` — DHCP, ARP, ICMP, IPv6 oraz zrzuty ruchu; zachowano pliki `.pcap`/`.pcapng` jako dane ćwiczeniowe.
- `c4` — DNS, mDNS, LLMNR, NBNS, trasowanie, przekazywanie pakietów i instrukcja Azure Linux VM.
- `c5` — VPS, chmura, sieć ADM, ZeroTier/Tailscale i automatyzacja skryptami.
- `c6` — zapory, Docker/Incus, usługi w chmurze i podłączanie serwera do sieci wirtualnej.
- `Wiedza` — wykłady, ściągi, praca w labie, Wireshark, IPv6, sprawozdania, skrypty i książki.
- `Moze_potrzebne` — projekty indywidualne, materiały anglojęzyczne/akademickie z Berkeley, dokumenty Office oraz pliki o niepewnym przypisaniu.

## Pliki scalone do README

Scalono i przepisano do spójnych notatek:

- `c1/Cel-ćwiczenia.txt`, `c1/Plan-pracy.txt`, `c1/Pytania*.txt`, `c1/Unix-podstawy.txt`, `Praca-lokalna.txt`, `Praca-zdalna.txt`, `Reperacja-sieci.txt`, `Reperacja-grafiki.txt` → `c1/README.md` i `Wiedza/Praca_w_labie/README.md`.
- `c2/Cel-ćwiczenia.txt`, `c2/Pytania.txt`, `c2/c2-zadanie.txt` oraz wybrane diagramy z `old/25/c2` → `c2/README.md`.
- `c3/Cel-ćwiczenia.txt`, `c3/Pytania.txt`, skrypty `arp-zrzut`, `dhcp-zrzut` i materiały DHCP → `c3/README.md` z zachowaniem skryptów i zrzutów.
- `c4/Cel-ćwiczenia.txt`, `c4/DNS.md`, `c4/Przekazywanie-Linux.txt`, `c4/mDNS*.txt`, `c4/vm-student.md` → `c4/README.md`, `c4/DNS.md`, `c4/azure-linux-vm.md`.
- `c5/Cel-ćwiczenia.txt`, `c5/zadanie.txt`, `c5/google-cloud-doc.txt` → `c5/README.md` oraz `c5/materialy/google-cloud.md`.
- `c6/Cel-ćwiczenia.txt` i wybrane aktualne/stare materiały `old/25/c6` → `c6/README.md` i `c6/materialy/`.
- Linki `.url`/`.webloc` scalono do plików `linki.md` w odpowiednich katalogach.
- `Egzamin/Przyładowe-pytania.pdf` przepisano do `Wiedza/Egzamin/README.md` i zachowano oryginalny PDF.

## Niepewne decyzje klasyfikacyjne

- Materiały z `old/25` wykorzystano selektywnie, bo były najbliższe aktualnym materiałom i często uzupełniały brakujące schematy albo notatki. Starsze roczniki traktowano jako mniej wiarygodne źródło bieżącego przebiegu laboratoriów.
- Część materiałów o NAT, Wi-Fi i mostkach pojawiała się w różnych rocznikach pod różnymi numerami ćwiczeń. Zamiast przypisywać je agresywnie do jednego `cX`, materiały ogólne przeniesiono do `Wiedza`, a mniej pewne do `Moze_potrzebne`.
- Projekty indywidualne i obce materiały akademickie są potencjalnie przydatne, ale nie są rdzeniem bieżących laboratoriów, więc trafiły do `Moze_potrzebne`.

## Zastąpione niejasne pytania i placeholdery

Zastąpiono lub dopisano wyjaśnienia tam, gdzie w materiałach były same pytania typu „dlaczego?” bez odpowiedzi:

- `Praca-zdalna.txt`: wyjaśniono, dlaczego po skopiowaniu konta można logować się bez `user@` — SSH używa bieżącej nazwy użytkownika.
- `Praca-zdalna.txt`: wyjaśniono, dlaczego z domu potrzebny jest ZeroTier ZET — stacje są w prywatnej sieci i wymagają sieci nakładkowej.
- `c4/Przekazywanie-Linux.txt`: dopisano wyjaśnienie, dlaczego przekazywanie pakietów jest domyślnie wyłączone — host końcowy nie powinien przypadkowo stać się routerem.

Nie próbowano odpowiadać na każdą listę pytań kontrolnych jak na gotowy klucz egzaminacyjny; tam, gdzie pytania były normalnym materiałem do nauki, zachowano je albo przekształcono w notatkę pojęciową.

## PDF-y i ich przetwarzanie

Dla PDF-ów uruchomiono `pdfinfo` w celu sprawdzenia liczby stron oraz `pdftotext` do oceny warstwy tekstowej. Wybrane PDF-y instrukcyjne i schematowe dodatkowo renderowano do obrazów przez narzędzie z pakietu PDF i sprawdzano wizualnie, m.in. `c4/vm-student.pdf`, `Egzamin/Przyładowe-pytania.pdf`, ściągi Wireshark/tcpdump, `Wykład/IPv6.pdf` i `Wykład/9 Media transmisyjne.pdf`.

PDF-y, których nie przepisano w całości:

- `Wykład/Książki/Computer-Networking.pdf` — 856 stron, długi podręcznik referencyjny.
- `Wykład/Książki/TCPIP-Illustrated.pdf` — 1059 stron, długi podręcznik referencyjny; ekstrakcja tekstu miejscami wyglądała na uszkodzoną kodowaniem.
- `old/19/docker-projektowanie-i-wdrazanie.pdf` — 223 strony, długi materiał referencyjny o Dockerze.
- PDF-y z Berkeley CS168 i prezentacje `.pptx` — przydatne jako materiały dodatkowe, ale anglojęzyczne i spoza głównego polskiego toku laboratoriów; przeniesione do `Moze_potrzebne`.
- `old/25/c2/sprawozdanie-przyklad/local.pdf`, `vol.pdf`, `wielo.pdf` — `pdftotext` praktycznie nie wydobył tekstu; zachowano lepsze odpowiedniki SVG/PDF w materiałach lub odnotowano jako diagramy.

Pełny techniczny wykaz PDF-ów znajduje się w `Wiedza/PDF_PRZEGLAD.md`.

## Pliki nieprzetworzone w pełni

Nie przerabiano w pełni bardzo dużych podręczników, zewnętrznych wykładów anglojęzycznych, plików Office z Berkeley oraz starych roczników, jeśli nie były konieczne do aktualnej bazy. Zostały zachowane w `Wiedza/Ksiazki` albo `Moze_potrzebne`, jeśli mogły mieć wartość informacyjną.
