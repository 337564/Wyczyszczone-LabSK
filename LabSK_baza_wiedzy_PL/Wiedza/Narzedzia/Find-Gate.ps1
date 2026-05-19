<#
.Synopsis
    Znalezienie interfejsu bramki do Internetu (nazwa interfejsu)
.Description
    Skrypt znajduje nazwę interfejsu sieciowego
    ktróry jest standardową bramką do Internetu
.Example
    Get-NetGate
.Notes Lista interfejsów:
    Get-NetAdapter -Physical | Format-Table -AutoSize
.Notes
    ato 2021
#>

# Interfejsy "bramka":
$bramka = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix 0.0.0.0/0 |
    Sort-Object RouteMetric #| Select-Object -First 1
   #Sort-Object -Property RouteMetric -Top 1    # Dlaczego nie działa ?

# Bramka standardowa:
$b = Get-NetAdapter -InterfaceIndex $bramka[0].ifIndex

$b | Format-Table -AutoSize InterfaceDescription, MacAddress, LinkSpeed

#$bramka | Format-Table -AutoSize

#EoF
