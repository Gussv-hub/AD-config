# Objectif : Créer des OUs et importer des utilisateurs depuis des fichiers CSV

# Import du module Active Directory
Import-Module ActiveDirectory

### Étape 1 : Définition des OUs ###
$OUUsers = "OU=Utilisateurs,DC=gussv,DC=lan"
$OUAdmins = "OU=Administrateurs,DC=gussv,DC=lan"

# Création des OUs si elles n'existent pas déjà
if (-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OUUsers} -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Utilisateurs" -Path "DC=gussv,DC=lan" -ProtectedFromAccidentalDeletion $false
    Write-Host "OU Utilisateurs créée."
}

if (-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OUAdmins} -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Administrateurs" -Path "DC=gussv,DC=lan" -ProtectedFromAccidentalDeletion $false
    Write-Host "OU Administrateurs créée."
}

### Étape 2 : Importation des utilisateurs ###
Function Import-Users {
    param (
        [string]$CSVPath,
        [string]$OU
    )
    
    if (Test-Path $CSVPath) {
        $Users = Import-Csv $CSVPath
        foreach ($User in $Users) {
            $SamAccountName = $User.SamAccountName
            if (-not (Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue)) {
                New-ADUser -Name "$($User.first_name) $($User.last_name)" `
                    -GivenName $User.first_name `
                    -Surname $User.last_name `
                    -SamAccountName $SamAccountName `
                    -UserPrincipalName "$SamAccountName@gussv.lan" `
                    -Path $OU `
                    -AccountPassword (ConvertTo-SecureString $User.password -AsPlainText -Force) `
                    -Enabled $true
                Write-Host "Utilisateur $SamAccountName créé."
            } else {
                Write-Host "L'utilisateur $SamAccountName existe déjà."
            }
        }
    } else {
        Write-Host "Le fichier $CSVPath est introuvable."
    }
}

# Importation des utilisateurs depuis les fichiers CSV
Import-Users -CSVPath ".\data\users_mock.csv" -OU $OUUsers
Import-Users -CSVPath ".\data\admins_mock.csv" -OU $OUAdmins

Write-Host "Configuration de l'AD terminée."