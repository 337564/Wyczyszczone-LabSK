ato@c2 ~ % claude
 ▐▛███▜▌   Claude Code v2.1.108
▝▜█████▛▘  Sonnet 4.6 · Claude Pro
  ▘▘ ▝▝    /home/ato

● mDNS vs LLMNR — porównanie

Czym są?

┌─────────────────────┬───────────────────────────────┬──────────────────────────────────────┐
│        Cecha        │             mDNS              │                LLMNR                 │
├─────────────────────┼───────────────────────────────┼──────────────────────────────────────┤
│ Pełna nazwa         │ Multicast DNS                 │ Link-Local Multicast Name Resolution │
├─────────────────────┼───────────────────────────────┼──────────────────────────────────────┤
│ RFC                 │ RFC 6762                      │ RFC 4795                             │
├─────────────────────┼───────────────────────────────┼──────────────────────────────────────┤
│ Twórca              │ Apple / IETF                  │ Microsoft                            │
├─────────────────────┼───────────────────────────────┼──────────────────────────────────────┤
│ Główne zastosowanie │ Zeroconf/Bonjour (Apple, IoT) │ Windows peer-to-peer                 │
└─────────────────────┴───────────────────────────────┴──────────────────────────────────────┘

Jak działają?
-------------

mDNS
- Wysyła zapytania DNS na adres multicast 224.0.0.251 (IPv4) lub ff02::fb (IPv6)
- Port UDP 5353
- Urządzenia same ogłaszają swoje nazwy z domeną .local
- Każde urządzenie odpowiada bezpośrednio, bez centralnego serwera

LLMNR
- Wysyła zapytania na 224.0.0.252 (IPv4) lub ff02::1:3 (IPv6)
- Port UDP/TCP 5355
- Obsługuje dowolne nazwy (nie tylko .local)
- Fallback po nieudanym DNS i NetBIOS

Kluczowe różnice
----------------

┌──────────────────┬────────────────────────────────┬─────────────────┐
│                  │              mDNS              │      LLMNR      │
├──────────────────┼────────────────────────────────┼─────────────────┤
│ Domyślna domena  │ .local                         │ dowolna         │
├──────────────────┼────────────────────────────────┼─────────────────┤
│ Systemy          │ Linux, macOS, Windows 10+, IoT │ głównie Windows │
├──────────────────┼────────────────────────────────┼─────────────────┤
│ Scope            │ Link-local                     │ Link-local      │
├──────────────────┼────────────────────────────────┼─────────────────┤
│ Integracja z DNS │ Tak (podzbiór DNS)             │ Nie do końca    │
├──────────────────┼────────────────────────────────┼─────────────────┤
│ Bezpieczeństwo   │ Lepsze (DNSSEC możliwy)        │ Słabsze         │
└──────────────────┴────────────────────────────────┴─────────────────┘

Bezpieczeństwo
--------------

Oba protokoły są podatne na poisoning (zatruwanie odpowiedzi) — atakujący w tej samej sieci może odpowiedzieć na zapytanie
fałszywym adresem IP. To podstawa narzędzi jak Responder.

LLMNR jest uznawany za bardziej ryzykowny:
- Microsoft sam rekomenduje jego wyłączenie w środowiskach korporacyjnych (GPO: Computer Configuration → Administrative Templates
→ Network → DNS Client → Turn off multicast name resolution)
- Jest domyślnie włączony w Windows i często wykorzystywany w atakach NTLM relay

mDNS jest bezpieczniejszy przez węższy zakres zastosowań i brak obsługi NTLM.

Kiedy używać?
-------------

┌──────────────────────────────┬──────────────────────────┐
│          Scenariusz          │          Wybór           │
├──────────────────────────────┼──────────────────────────┤
│ Urządzenia IoT / smart home  │ mDNS                     │
├──────────────────────────────┼──────────────────────────┤
│ Sieć Apple / Bonjour         │ mDNS                     │
├──────────────────────────────┼──────────────────────────┤
│ Stara sieć Windows workgroup │ LLMNR (legacy)           │
├──────────────────────────────┼──────────────────────────┤
│ Nowa sieć korporacyjna       │ Żadne — użyj pełnego DNS │
└──────────────────────────────┴──────────────────────────┘

