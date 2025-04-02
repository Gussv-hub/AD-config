# Objectif : Renommer la machine et s'assurer qu'elle est en IP statique

# Import des modules nécessaires
Import-Module NetTCPIP

### Étape 1 : Renommage de la machine ###
$NewComputerName = "SRV-AD"
$CurrentComputerName = $env:COMPUTERNAME
$RebootRequired = $false

if ($CurrentComputerName -ne $NewComputerName) {
    Write-Host "Renommage du serveur de $CurrentComputerName vers $NewComputerName..."
    Rename-Computer -NewName $NewComputerName -Force
    $RebootRequired = $true
} else {
    Write-Host "Le nom de la machine est déjà correct ($CurrentComputerName)."
}

### Étape 2 : Vérification et configuration de l'IP ###
$Interface = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null }

if (-not $Interface.DNSServer -or -not $Interface.IPv4DefaultGateway) {
    Write-Host "Attention : La machine semble être en DHCP ou mal configurée."
    $StaticIP = Read-Host "Entrez l'adresse IP statique (ex: 192.168.1.10)"
    $Gateway = Read-Host "Entrez la passerelle (ex: 192.168.1.1)"
    $DNS = Read-Host "Entrez l'adresse du serveur DNS (ex: 192.168.1.1)"

    # Application des paramètres réseau
    New-NetIPAddress -InterfaceIndex $Interface.InterfaceIndex -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway
    Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses $DNS
    Write-Host "Configuration IP mise à jour avec succès."
    $RebootRequired = $true
} else {
    Write-Host "L'adresse IP est déjà statique. Aucune modification nécessaire."
}

### Étape 3 : Redémarrage si nécessaire ###
if ($RebootRequired) {
    Write-Host "Un redémarrage est nécessaire pour appliquer les changements. Redémarrage en cours..."
    Restart-Computer -Force
} else {
    Write-Host "Aucune modification nécessitant un redémarrage. Configuration terminée."
}
