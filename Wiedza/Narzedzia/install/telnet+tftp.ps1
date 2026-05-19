<#
.Synopsis 
    Instalacja klienta telnet i tftp
.Notes 
    ato 2023
#>
Get-WindowsOptionalFeature -Online -FeatureName telnet*
<#
FeatureName      : TelnetClient
DisplayName      : Klient Telnet
Description      : Pozwala na zdalne łączenie się z innymi komputerami.
RestartRequired  : Possible
State            : Disabled
CustomProperties : 
                   ServerComponent\Description : Klient Telnet łączy się z serwerem zdalnym Telnet i uruchamia na nim aplikacje za pomocą protok
                   ołu Telnet.
                   ServerComponent\DisplayName : Klient Telnet
                   ServerComponent\Id : 44
                   ServerComponent\Type : Feature
                   ServerComponent\UniqueName : Telnet-Client
                   ServerComponent\Version\Major : 10
                   ServerComponent\Version\Minor : 0
                   ServerComponent\Deploys\Update\Name : TelnetClient
#>
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient
<#
Path          : 
Online        : True
RestartNeeded : False #>
Get-WindowsOptionalFeature -Online -FeatureName tftp*          
<#
FeatureName      : TFTP
DisplayName      : Klient TFTP
Description      : Prześlij pliki, używając protokołu TFTP (Trivial File Transfer Protocol)
RestartRequired  : Possible
State            : Disabled
CustomProperties : 
                   ServerComponent\Description : Klient protokołu TFTP (Trivial File Transfer Protocol) służy do odczytywania i zapisywania plik 
                   ów na zdalnym serwerze TFTP. Protokół TFTP jest używany głównie przez urządzenia i systemy osadzone, które pobierają z serwer 
                   a TFTP oprogramowanie układowe, informacje konfiguracyjne lub obrazy systemu podczas procesu rozruchu.
                   ServerComponent\DisplayName : Klient TFTP
                   ServerComponent\Id : 58
                   ServerComponent\Type : Feature
                   ServerComponent\UniqueName : TFTP-Client
                   ServerComponent\Deploys\Update\Name : TFTP #>
Enable-WindowsOptionalFeature -Online -FeatureName tftp
<#
Path          : 
Online        : True
RestartNeeded : False #>
telnet -h
<#
telnet [-a][-e znak_kontrolny][-f plik_dziennika][-l użytkownik][-t terminal]
       [host [port]]
 -a      Dokonuje próby autologowania. Działa jak opcja -l, ale
         używa nazwy obecnie zalogowanego użytkownika.
 -e      Znak kontrolny przenoszący do monitu klienta usługi telnet.
 -f      Nazwa pliku dla rejestrowania strony klienta.
 -l      Określa nazwę użytkownika do zalogowania w systemie zdalnym.
         Wymaga, aby system zdalny obsługiwał opcję TELNET ENVIRON.
 -t      Określa typ terminalu.
         Obsługiwane typy terminalu: tylko vt100, vt52, ansi i vtnt.
 host    Określa nazwę hosta lub adres IP komputera zdalnego, z którym ma
         nastąpić połączenie.
 port    Określa numer portu lub nazwę usługi. #>
tftp -h  
<#
Transfers files to and from a remote computer running the TFTP service.
TFTP [-i] host [GET | PUT] source [destination]
  -i              Specifies binary image transfer mode (also called
                  octet). In binary image mode the file is moved
                  literally, byte by byte. Use this mode when
                  transferring binary files.
  host            Specifies the local or remote host.
  GET             Transfers the file destination on the remote host to
                  the file source on the local host.
  PUT             Transfers the file source on the local host to
                  the file destination on the remote host.
  source          Specifies the file to transfer.
  destination     Specifies where to transfer the file. #>
return
#EoF