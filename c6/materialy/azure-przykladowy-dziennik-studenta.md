Marcin Warda (p10)

wardakm@s3 ~ % ssh testvm-wardakm.northeurope.cloudapp.azure.com
wardakm@testvm-wardakm.northeurope.cloudapp.azure.com's password:
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1064-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Mon Jun 10 09:56:16 UTC 2024

  System load:  0.0               Processes:             180
  Usage of /:   7.4% of 28.89GB   Users logged in:       1
  Memory usage: 4%                IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

New release '22.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Mon Jun 10 09:03:05 2024 from 194.29.146.22

wardakm@testvm:~$ sudo zerotier listnetworks
200 listnetworks <nwid> <name> <mac> <status> <type> <dev> <ZT assigned ips>
200 listnetworks ebe7fbd445c277b3 ZET b2:e2:65:78:f3:96 OK PRIVATE zth6rdti7w 172.27.27.212/16

$ ip -br -c l
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             00:0d:3a:69:56:21 <BROADCAST,MULTICAST,UP,LOWER_UP>
lxdbr0           DOWN           00:16:3e:e4:9d:6f <NO-CARRIER,BROADCAST,MULTICAST,UP>
zth6rdti7w       UNKNOWN        b2:e2:65:78:f3:96 <BROADCAST,MULTICAST,UP,LOWER_UP>
docker0          UP             02:42:ac:79:b9:3a <BROADCAST,MULTICAST,UP,LOWER_UP>
veth2a39d89@if10 UP             b6:3e:c4:d9:64:bb <BROADCAST,MULTICAST,UP,LOWER_UP>
veth5e23e0f@if14 UP             b2:a5:2f:35:12:e8 <BROADCAST,MULTICAST,UP,LOWER_UP>

$ ip -br -c a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.0.4/24 fe80::20d:3aff:fe69:5621/64
lxdbr0           DOWN           10.177.166.1/24 fd42:a4e1:f73e:c4c::1/64
zth6rdti7w       UNKNOWN        172.27.27.212/16 fe80::b0e2:65ff:fe78:f396/64
docker0          UP             172.17.0.1/16 fe80::42:acff:fe79:b93a/64
veth2a39d89@if10 UP             fe80::b43e:c4ff:fed9:64bb/64
veth5e23e0f@if14 UP             fe80::b0a5:2fff:fe35:12e8/64

$ ip -br -c r
default via 10.0.0.1 dev eth0 proto dhcp src 10.0.0.4 metric 100
10.0.0.0/24 dev eth0 proto kernel scope link src 10.0.0.4
10.40.0.0/16 via 172.27.213.22 dev zth6rdti7w proto static metric 5000
10.42.0.0/16 via 172.27.213.22 dev zth6rdti7w proto static metric 5000
10.146.0.0/16 via 172.27.213.22 dev zth6rdti7w proto static metric 5000
10.177.166.0/24 dev lxdbr0 proto kernel scope link src 10.177.166.1 linkdown
168.63.129.16 via 10.0.0.1 dev eth0 proto dhcp src 10.0.0.4 metric 100
169.254.169.254 via 10.0.0.1 dev eth0 proto dhcp src 10.0.0.4 metric 100
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
172.27.0.0/16 dev zth6rdti7w proto kernel scope link src 172.27.27.212

$ ip -br -c r | column -t
default          via  10.0.0.1       dev    eth0        proto  dhcp    src     10.0.0.4       metric    100
10.0.0.0/24      dev  eth0           proto  kernel      scope  link    src     10.0.0.4
10.40.0.0/16     via  172.27.213.22  dev    zth6rdti7w  proto  static  metric  5000
10.42.0.0/16     via  172.27.213.22  dev    zth6rdti7w  proto  static  metric  5000
10.146.0.0/16    via  172.27.213.22  dev    zth6rdti7w  proto  static  metric  5000
10.177.166.0/24  dev  lxdbr0         proto  kernel      scope  link    src     10.177.166.1   linkdown
168.63.129.16    via  10.0.0.1       dev    eth0        proto  dhcp    src     10.0.0.4       metric    100
169.254.169.254  via  10.0.0.1       dev    eth0        proto  dhcp    src     10.0.0.4       metric    100
172.17.0.0/16    dev  docker0        proto  kernel      scope  link    src     172.17.0.1
172.27.0.0/16    dev  zth6rdti7w     proto  kernel      scope  link    src     172.27.27.212

$ ip -br -c -6 a
lo               UNKNOWN        ::1/128
eth0             UP             fe80::20d:3aff:fe69:5621/64
lxdbr0           DOWN           fd42:a4e1:f73e:c4c::1/64
zth6rdti7w       UNKNOWN        fe80::b0e2:65ff:fe78:f396/64
docker0          UP             fe80::42:acff:fe79:b93a/64
veth2a39d89@if10 UP             fe80::b43e:c4ff:fed9:64bb/64
veth5e23e0f@if14 UP             fe80::b0a5:2fff:fe35:12e8/64

$ ip -br -c -6 r | column -t
::1                      dev  lo           proto  kernel  metric  256  pref      medium
fd42:a4e1:f73e:c4c::/64  dev  lxdbr0       proto  kernel  metric  256  linkdown  pref    medium
fe80::/64                dev  eth0         proto  kernel  metric  256  pref      medium
fe80::/64                dev  zth6rdti7w   proto  kernel  metric  256  pref      medium
fe80::/64                dev  docker0      proto  kernel  metric  256  pref      medium
fe80::/64                dev  veth2a39d89  proto  kernel  metric  256  pref      medium
fe80::/64                dev  veth5e23e0f  proto  kernel  metric  256  pref      medium

$ sudo docker ps -a
CONTAINER ID   IMAGE           COMMAND              CREATED          STATUS          PORTS                                   NAMES
b59efe4cf641   httpd           "httpd-foreground"   16 minutes ago   Up 16 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp       test-webserver
3e93d36a0b6b   ubuntu:latest   "/bin/bash"          24 minutes ago   Up 24 minutes   0.0.0.0:2222->22/tcp, :::2222->22/tcp   testdocker
