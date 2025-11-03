# Script PowerShell pour déployer l'application avec HTTPS
# Pour dev.flexitronic.fr

# ===== CONFIGURATION - MODIFIEZ CES VALEURS =====
$VPS_USER = "votre_utilisateur"        # Votre nom d'utilisateur SSH
$VPS_IP = "123.456.789.012"            # L'IP de votre VPS
$DOMAIN = "dev.flexitronic.fr"
$LOCAL_PATH = "c:\Users\cutes\Documents\altern\fluter-app-test"
$REMOTE_PATH = "~/doxa-motorisation-app"
# ================================================

Write-Host "🚀 Déploiement HTTPS pour $DOMAIN" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

# Fonction pour afficher les messages colorés
function Write-Info {
    param([string]$message)
    Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$message)
    Write-Host "[✓] $message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$message)
    Write-Host "[!] $message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$message)
    Write-Host "[✗] $message" -ForegroundColor Red
}

# Vérifier que les valeurs ont été modifiées
if ($VPS_USER -eq "votre_utilisateur" -or $VPS_IP -eq "123.456.789.012") {
    Write-Error "Veuillez modifier les variables VPS_USER et VPS_IP dans le script !"
    Write-Host ""
    Write-Host "Éditez les lignes 5-6 du script avec vos vraies valeurs :" -ForegroundColor Yellow
    Write-Host "  VPS_USER = votre nom d'utilisateur SSH" -ForegroundColor Yellow
    Write-Host "  VPS_IP = l'adresse IP de votre VPS" -ForegroundColor Yellow
    exit 1
}

# Vérifier que le chemin local existe
if (-not (Test-Path $LOCAL_PATH)) {
    Write-Error "Le chemin local n'existe pas : $LOCAL_PATH"
    exit 1
}

Write-Info "Configuration :"
Write-Host "  - Utilisateur VPS : $VPS_USER" -ForegroundColor Gray
Write-Host "  - IP VPS : $VPS_IP" -ForegroundColor Gray
Write-Host "  - Domaine : $DOMAIN" -ForegroundColor Gray
Write-Host "  - Chemin local : $LOCAL_PATH" -ForegroundColor Gray
Write-Host ""

# Étape 1 : Vérifier la connexion SSH
Write-Info "Vérification de la connexion SSH..."
$testSSH = ssh -o ConnectTimeout=5 -o BatchMode=yes ${VPS_USER}@${VPS_IP} "echo OK" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Impossible de se connecter au VPS automatiquement."
    Write-Host "Vous devrez peut-être entrer votre mot de passe SSH." -ForegroundColor Yellow
} else {
    Write-Success "Connexion SSH OK"
}
Write-Host ""

# Étape 2 : Vérifier le DNS
Write-Info "Vérification de la configuration DNS..."
try {
    $dnsResult = Resolve-DnsName $DOMAIN -Type A -ErrorAction Stop
    $dnsIP = $dnsResult[0].IPAddress
    Write-Success "DNS configuré : $DOMAIN → $dnsIP"
    
    if ($dnsIP -ne $VPS_IP) {
        Write-Warning "Le DNS pointe vers $dnsIP mais votre VPS est à $VPS_IP"
        Write-Warning "Assurez-vous que c'est correct avant de continuer."
        $continue = Read-Host "Continuer quand même ? (o/N)"
        if ($continue -ne "o" -and $continue -ne "O") {
            exit 0
        }
    }
} catch {
    Write-Warning "Impossible de résoudre le DNS pour $DOMAIN"
    Write-Warning "Assurez-vous d'avoir configuré un enregistrement A dans votre DNS."
}
Write-Host ""

# Étape 3 : Build Flutter Web
Write-Info "Build de l'application Flutter..."
Set-Location $LOCAL_PATH
$buildResult = flutter build web --release 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Success "Build Flutter réussi"
} else {
    Write-Error "Échec du build Flutter"
    Write-Host $buildResult
    exit 1
}
Write-Host ""

# Étape 4 : Créer le répertoire sur le VPS
Write-Info "Création du répertoire sur le VPS..."
ssh ${VPS_USER}@${VPS_IP} "mkdir -p $REMOTE_PATH"
Write-Success "Répertoire créé"
Write-Host ""

# Étape 5 : Transférer les fichiers
Write-Info "Transfert des fichiers vers le VPS..."
Write-Host "Cela peut prendre quelques minutes..." -ForegroundColor Gray

# Liste des fichiers et dossiers à transférer
$itemsToTransfer = @(
    "build\web\*"
    "deploy\*"
    "Dockerfile"
    "docker-compose-https.yml"
    "pubspec.yaml"
    "lib\*"
    "android\*"
    "ios\*"
    "web\*"
)

foreach ($item in $itemsToTransfer) {
    $fullPath = Join-Path $LOCAL_PATH $item
    if (Test-Path $fullPath) {
        $itemName = Split-Path $item -Leaf
        Write-Host "  → Transfert de $itemName..." -ForegroundColor Gray
        
        # Créer le sous-répertoire si nécessaire
        $itemDir = Split-Path $item -Parent
        if ($itemDir) {
            ssh ${VPS_USER}@${VPS_IP} "mkdir -p $REMOTE_PATH/$itemDir" 2>$null
        }
        
        # Transférer
        scp -r $fullPath ${VPS_USER}@${VPS_IP}:$REMOTE_PATH/$itemDir/ 2>&1 | Out-Null
    }
}

Write-Success "Fichiers transférés"
Write-Host ""

# Étape 6 : Afficher les instructions pour le VPS
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "✅ Fichiers transférés avec succès !" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes sur le VPS :" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Connectez-vous à votre VPS :" -ForegroundColor Yellow
Write-Host "   ssh ${VPS_USER}@${VPS_IP}" -ForegroundColor White
Write-Host ""
Write-Host "2. Allez dans le répertoire de l'application :" -ForegroundColor Yellow
Write-Host "   cd $REMOTE_PATH" -ForegroundColor White
Write-Host ""
Write-Host "3. Exécutez le script de configuration HTTPS :" -ForegroundColor Yellow
Write-Host "   chmod +x deploy/setup-https-vps.sh" -ForegroundColor White
Write-Host "   ./deploy/setup-https-vps.sh" -ForegroundColor White
Write-Host ""
Write-Host "   OU suivez le guide manuel :" -ForegroundColor Yellow
Write-Host "   cat deploy/GUIDE_HTTPS.md" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

# Option pour se connecter automatiquement au VPS
$connect = Read-Host "Voulez-vous vous connecter au VPS maintenant ? (o/N)"
if ($connect -eq "o" -or $connect -eq "O") {
    Write-Host ""
    Write-Info "Connexion au VPS..."
    Write-Host "Une fois connecté, exécutez : cd $REMOTE_PATH && chmod +x deploy/setup-https-vps.sh && ./deploy/setup-https-vps.sh" -ForegroundColor Yellow
    Write-Host ""
    ssh ${VPS_USER}@${VPS_IP}
}

Write-Host ""
Write-Host "✨ Script terminé !" -ForegroundColor Green
