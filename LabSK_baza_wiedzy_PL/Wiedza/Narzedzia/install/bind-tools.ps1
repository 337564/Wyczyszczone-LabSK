<#
.Synopsis
	Instalacja programów linii poleceń do serwisu DNS:
    arpaname delv dig host nslookup nsupdate
.Link
    https://www.isc.org/bind/
.Notes
	ato 2021
#>

#Requires -RunAsAdministrator

choco install  bind-toolsonly -y

ll C:\ProgramData\chocolatey\lib\bind-toolsonly\content
<#
Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-----        10.05.2019     06:51     6,92KB readme1st.txt
-----        11.05.2019     07:37    10,50KB arpaname.exe
-----        11.05.2019     07:36    38,00KB delv.exe
-----        11.05.2019     07:37   102,00KB dig.exe
-----        11.05.2019     07:37    80,50KB host.exe
-----        11.05.2019     07:37    84,50KB nslookup.exe
-----        11.05.2019     07:37    54,50KB nsupdate.exe

-----        11.05.2019     07:36     9,50KB bindevt.dll
-----        11.05.2019     07:36    60,50KB libbind9.dll
-----        11.05.2019     07:36     1,72MB libdns.dll
-----        26.06.2017     15:25     2,14MB libeay32.dll
-----        11.05.2019     07:36    41,00KB libirs.dll
-----        11.05.2019     07:35   303,00KB libisc.dll
-----        11.05.2019     07:36    34,00KB libisccc.dll
-----        11.05.2019     07:36   114,00KB libisccfg.dll
-----        05.02.2014     08:51     1,27MB libxml2.dll
#>
#EoF
