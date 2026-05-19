<#
.Synopsis
    Generacja maszyny wirtualnej
.Description
    Generacja maszyny wirtualnej w VirtualBox
.Notes
    Jakub Matłacz matlaczj
#>

$DIR = "C:\tmp\iso"                             # kat z obrazami iso

#$FILE = "freebsd-mfs-14.0-CURRENT-amd64.iso"    # nazwa pliku iso
$FILE = "alpine-virt-3.13.5-x86_64.iso"
#$VM = "FreeBSD$1"                               # nazwa maszyny + arg
$VM = "Linux Alpine$1"                 
$ISO = "$DIR\$FILE"                             # lokacja iso u hosta
#$OSTYPE = "FreeBSD_64"
$OSTYPE = "Linux 2.6 / 3.x / 4.x (64-bit)"

$RAM = 2048                                     # ile mb ramu
$NCPU = 2                                       # ile rdzeni

$VBM = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage"

function find-host-interface {
  $a = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix 0.0.0.0/0 |
  Select-Object -First 1 | Get-NetAdapter
  return $a.ifDesc
}

# START

& $VBM unregistervm $VM --delete        	# usuń starą maszynę o tej samej nazwie co będzie nowa

& $VBM createvm --name $VM --ostype $OSTYPE --register 
& $VBM modifyvm $VM --memory $RAM --cpus $NCPU --vram 16 --acpi on --hpet on --ioapic on

& $VBM storagectl $VM --add ide --name IDE
& $VBM storageattach $VM --storagectl IDE --port 0 --type dvddrive --medium $ISO --device 0 --tempeject on

$Typ = "virtio"                                 # Optymalny jeśli gość ma sterownik
$I = 1                                          # Numer interfejsu
$H = find-host-interface                        # Interfejs gospodarza podłączony do LAN
& $VBM modifyvm $VM --nictype$I $Typ --nic$I bridged --bridgeadapter$I $H --nicbootprio$I 2

$I++
$NetName = 'VLAN'                               # dafault: intnet
& $VBM modifyvm $VM --nictype$I $Typ --nic$I intnet 
& $VBM modifyvm $VM --intnet$I $NetName
& $VBM modifyvm $VM --nicpromisc$I allow-vms

& $VBM modifyvm $VM --boot1 dvd                 # z CD (skąd podnosimy system)
& $VBM modifyvm $VM --graphicscontroller vmsvga

& $VBM startvm $VM #-type headless

write-host "wystartuj maszynę poleceniem:" -ForegroundColor Green
write-host "$VBM startvm $VM -type headless"

#EoF
