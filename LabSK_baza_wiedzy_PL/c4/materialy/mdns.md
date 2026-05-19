● mDNS = Multicast DNS (RFC 6762, Apple/Bonjour origin)

  Core idea: DNS without a DNS server — zero-configuration name resolution on a local link.

  How it works:
  Host A wants to resolve "printer.local"
    → sends UDP multicast to 224.0.0.251:5353
    → "printer.local" hears its name
    → replies directly to Host A with its IP
    → no server involved

  Key properties:
  - Scope: link-local only (single L2 segment, TTL=1, not routed)
  - Port: 5353 UDP
  - Multicast: 224.0.0.251 (IPv4), ff02::fb (IPv6)
  - Names: traditionally .local domain only
  - Zero configuration — no admin needed

  What it solves:
  - Printers, NAS, IoT devices announcing themselves
  - Small networks with no DNS server
  - ping printer.local works without any configuration

  Warning!:
  - systemd-resolved extends mDNS beyond .local to short hostnames (e1, s1) via LLMNR
  - some hosts can advertise themselfs via mDNS with link-local IPv6 address
  - getaddrinfo gets the IPv6 answer first (mDNS faster than DNS)
  - [!UNAVAIL=return] in nsswitch.conf stops the chain → DNS never consulted
  - ARP is IPv4-only → IPv6 address → arping/tcpdump fail

  mDNS vs DNS comparison:

  ┌───────────┬──────────┬───────────────────┐
  │           │   DNS    │       mDNS        │
  ├───────────┼──────────┼───────────────────┤
  │ Server    │ required │ none              │
  ├───────────┼──────────┼───────────────────┤
  │ Scope     │ global   │ link-local        │
  ├───────────┼──────────┼───────────────────┤
  │ Port      │ 53       │ 5353              │
  ├───────────┼──────────┼───────────────────┤
  │ Transport │ unicast  │ multicast         │
  ├───────────┼──────────┼───────────────────┤
  │ Names     │ any      │ .local (standard) │
  ├───────────┼──────────┼───────────────────┤
  │ Config    │ manual   │ zero-config       │
  └───────────┴──────────┴───────────────────┘

  If all hosts in LAN are already in DNS → mDNS is purely noise, creating races with DNS for names it should never have handled.

❯ Is working onlu with .local suffix ?

● RFC 6762 standard: yes, .local only.

  But in practice it depends on the implementation:

  ┌───────────────────────┬───────────────────────────────────────────────────────────────┐
  │    Implementation     │                             Scope                             │
  ├───────────────────────┼───────────────────────────────────────────────────────────────┤
  │ RFC 6762 (standard)   │ .local only                                                   │
  ├───────────────────────┼───────────────────────────────────────────────────────────────┤
  │ avahi                 │ .local only                                                   │
  ├───────────────────────┼───────────────────────────────────────────────────────────────┤
  │ mdns4_minimal         │ .local only — the "minimal" means this restriction            │
  ├───────────────────────┼───────────────────────────────────────────────────────────────┤
  │ mdns4 (non-minimal)   │ any hostname — intercepts all queries                         │
  ├───────────────────────┼───────────────────────────────────────────────────────────────┤
  │ systemd-resolved mDNS │ .local + short single-label names (e1, s1)                    │
  ├───────────────────────┼───────────────────────────────────────────────────────────────┤
  │ LLMNR                 │ short single-label names only (no domain) — designed for this │
  └───────────────────────┴───────────────────────────────────────────────────────────────┘

  That's exactly why mdns4_minimal is the safe choice:
  - e1 → no .local suffix → NOTFOUND → chain continues → DNS ✓
  - e1.local → has .local → avahi resolves via mDNS ✓

  And why systemd-resolved caused your problems — it goes beyond the standard and handles short names like e1 via LLMNR/mDNS, returning whatever it finds first (the IPv6 link-local
  address), blocking DNS from being consulted.

  The "minimal" in mdns4_minimal is specifically the protection against this — it enforces the RFC-correct behavior of mDNS being .local-only.
