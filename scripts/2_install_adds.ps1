# Objectif : Installer AD DS et promouvoir le serveur en contrôleur de domaine

# Import du module AD
Import-Module ServerManager

### Étape 1 : Installation du rôle AD DS ###
Write-Host "Installation du rôle Active Directory Domain Services (AD DS)..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

### Étape 2 : Configuration du contrôleur de domaine ###
$DomainName = "gussv.lan"
$NetBiosName = "GUSSV"
$SafeModePassword = ConvertTo-SecureString "Tech$123456" -AsPlainText -Force #Amélioration : demander a l'ustilisateur de taper le mot de passe pour la sécurité

Write-Host "Promotion du serveur en contrôleur de domaine pour la forêt $DomainName..."
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

Write-Host "Installation et promotion terminées. Un redémarrage est nécessaire."
Restart-Computer -Force