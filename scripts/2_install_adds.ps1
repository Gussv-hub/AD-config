# Objectif : Installer AD DS et promouvoir le serveur en contrôleur de domaine

# Import du module AD
Import-Module ServerManager

# Définition des paramètres
$DomainName = "gussv.lan"
$NetBiosName = "GUSSV"
$SafeModePassword = ConvertTo-SecureString "Admin!123456" -AsPlainText -Force

# Fichier de log
$LogFile = "C:\temp\ADDS-Install.log"
if (!(Test-Path "C:\temp")) { New-Item -ItemType Directory -Path "C:\temp" }
Start-Transcript -Path $LogFile -Append

### Étape 1 : Installation du rôle AD DS ###
Write-Host "Installation du rôle Active Directory Domain Services (AD DS)..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

### Étape 2 : Promotion en contrôleur de domaine ###
Write-Host "Promotion du serveur en contrôleur de domaine pour la forêt $DomainName..."
try {
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBiosName `
        -ForestMode Win2022 `
        -DomainMode Win2022 `
        -InstallDNS `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -LogPath "C:\Windows\NTDS" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -SafeModeAdministratorPassword $SafeModePassword `
        -Confirm:$false `
        -Force
}
catch {
    Write-Host "Erreur lors de la promotion du contrôleur de domaine : $_"
    $_ | Out-File -Append $LogFile
}

Write-Host "Vérifie le fichier de log : $LogFile"
Stop-Transcript
