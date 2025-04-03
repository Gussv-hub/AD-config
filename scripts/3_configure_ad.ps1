# Objectif : Créer des OUs et importer des utilisateurs depuis des fichiers CSV

# Vérifie si le module Active Directory est installé
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Le module Active Directory n'est pas installé. Veuillez l'installer avant d'exécuter ce script." -ForegroundColor Red
    exit
}

# Définition du chemin du domaine gussv.lan
$domainDN = "DC=gussv,DC=lan"

# Liste des OUs à créer
$ouList = @("Utilisateurs", "Administrateur")

foreach ($ou in $ouList) {
    $ouPath = "OU=$ou,$domainDN"
    
    # Vérifie si l'OU existe déjà
    if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue) {
        Write-Host "L'OU '$ou' existe déjà." -ForegroundColor Yellow
    } else {
        # Création de l'OU
        New-ADOrganizationalUnit -Name $ou -Path $domainDN -ProtectedFromAccidentalDeletion $true
        Write-Host "L'OU '$ou' a été créée avec succès." -ForegroundColor Green
    }
}

# Définir les chemins des OUs
$domainDN = "DC=gussv,DC=lan"
$ouUsers = "OU=Utilisateurs,$domainDN"
$ouAdmins = "OU=Administrateur,$domainDN"

# Fonction pour ajouter un utilisateur
function Add-UserToOU {
    param (
        [string]$lastName,
        [string]$firstName,
        [string]$password,
        [string]$ou
    )

    # Crée le nom d'utilisateur (nom principal) au format "username@gussv.lan"
    $username = "$lastName$firstName" # Exemple: "DoeJohn"
    $userPrincipalName = "$username@gussv.lan"

    try {
        # Crée l'utilisateur dans l'OU spécifiée
        New-ADUser -SamAccountName $username `
                   -UserPrincipalName $userPrincipalName `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -Name "$firstName $lastName" `
                   -DisplayName "$firstName $lastName" `
                   -Path $ou `
                   -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -PasswordNeverExpires $false

        Write-Host "Utilisateur '$username' ajouté avec succès dans '$ou'." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors de l'ajout de l'utilisateur '$username': $_" -ForegroundColor Red
    }
}

# Ajouter les utilisateurs de users_mock.csv dans l'OU Utilisateurs
$usersMockPath = ".\data\users_mock.csv"
$usersMock = Import-Csv $usersMockPath

foreach ($user in $usersMock) {
    Add-UserToOU -firstName $user.first_name `
                 -lastName $user.last_name `
                 -password $user.password `
                 -ou $ouUsers
}

# Ajouter les utilisateurs de admin_mock.csv dans l'OU Administrateur
$adminMockPath = ".\data\admins_mock.csv"
$adminMock = Import-Csv $adminMockPath

foreach ($admin in $adminMock) {
    Add-UserToOU -firstName $admin.first_name `
                 -lastName $admin.last_name `
                 -password $admin.password `
                 -ou $ouAdmins
}