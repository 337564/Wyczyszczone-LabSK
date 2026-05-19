<#
.Synopsis
    Instalacja programów testowania wydajności łącza
.Description
    Który lepszy ?
.Example
    iperf -s                    # serwer
    iperf -c <adres serwera>    # klient
.Link
    https://iperf.fr/
    https://github.com/esnet/iperf
.Link 
    https://sourceforge.net/projects/iperf2/
.Notes
    ato 2021
#>
#Requires -RunAsAdministrator

#choco search iperf
#choco info iperf3
#choco info iperf2                      # starsza wersja

choco install iperf3 iperf2 -y

iperf2 -v
#iperf version 2.0.14a (29 Jan 2019) pthreads
iperf3 -v
#iperf 3.1.3

#iperf3 -h
#EoF