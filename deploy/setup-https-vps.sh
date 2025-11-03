#!/bin/bash

# Script de configuration HTTPS pour VPS
# Pour dev.flexitronic.fr

set -e

echo "🔒 Configuration HTTPS pour dev.flexitronic.fr"
echo "=============================================="

# Variables (à modifier selon vos besoins)
DOMAIN="dev.flexitronic.fr"
EMAIL="votre-email@example.com"  # MODIFIEZ CETTE VALEUR
APP_DIR="$HOME/doxa-motorisation-app"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier que le script est exécuté sur le VPS
if [ -z "$SSH_CONNECTION" ] && [ -z "$SSH_CLIENT" ]; then
    log_warn "Ce script doit être exécuté sur votre VPS distant."
fi

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé. Installez Docker d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé. Installez Docker Compose d'abord."
    exit 1
fi

log_info "Docker et Docker Compose sont installés ✓"

# Vérifier le DNS
log_info "Vérification de la configuration DNS pour $DOMAIN..."
DNS_IP=$(dig +short $DOMAIN | tail -n1)
SERVER_IP=$(curl -s ifconfig.me)

if [ "$DNS_IP" != "$SERVER_IP" ]; then
    log_warn "Le DNS ne pointe pas vers ce serveur!"
    log_warn "DNS pointe vers: $DNS_IP"
    log_warn "IP du serveur: $SERVER_IP"
    read -p "Voulez-vous continuer quand même ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    log_info "DNS correctement configuré ✓"
fi

# Créer les répertoires nécessaires
log_info "Création des répertoires..."
mkdir -p $APP_DIR/certbot/conf
mkdir -p $APP_DIR/certbot/www
log_info "Répertoires créés ✓"

# Vérifier que les fichiers de l'application sont présents
if [ ! -f "$APP_DIR/Dockerfile" ]; then
    log_error "Les fichiers de l'application ne sont pas présents dans $APP_DIR"
    log_error "Transférez d'abord les fichiers depuis votre ordinateur local."
    exit 1
fi

if [ ! -f "$APP_DIR/docker-compose-https.yml" ]; then
    log_error "Le fichier docker-compose-https.yml est manquant."
    exit 1
fi

log_info "Fichiers de l'application présents ✓"

# Vérifier le firewall
log_info "Vérification des ports 80 et 443..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    log_info "Firewall configuré ✓"
fi

# Arrêter les conteneurs existants
log_info "Arrêt des conteneurs existants..."
cd $APP_DIR
docker-compose down 2>/dev/null || true
docker-compose -f docker-compose-https.yml down 2>/dev/null || true

# Construire et démarrer l'application (sans SSL pour le moment)
log_info "Démarrage temporaire de l'application pour la validation Let's Encrypt..."
docker-compose -f docker-compose-https.yml up -d doxa-motorisation-app

# Attendre que Nginx démarre
sleep 5

# Obtenir le certificat SSL
log_info "Obtention du certificat SSL de Let's Encrypt..."
docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  -d $DOMAIN \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  --force-renewal

if [ $? -ne 0 ]; then
    log_error "Échec de l'obtention du certificat SSL."
    log_error "Vérifiez que:"
    log_error "  1. Le DNS pointe vers ce serveur"
    log_error "  2. Les ports 80 et 443 sont ouverts"
    log_error "  3. Aucun autre service n'utilise ces ports"
    exit 1
fi

log_info "Certificat SSL obtenu avec succès ✓"

# Redémarrer avec la configuration HTTPS complète
log_info "Redémarrage avec HTTPS activé..."
docker-compose -f docker-compose-https.yml down
docker-compose -f docker-compose-https.yml up -d

# Attendre que les services démarrent
sleep 5

# Vérifier que les conteneurs sont en cours d'exécution
log_info "Vérification des conteneurs..."
docker-compose -f docker-compose-https.yml ps

# Test de connectivité
log_info "Test de connectivité..."
sleep 2

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN)
if [ "$HTTP_STATUS" -eq 301 ] || [ "$HTTP_STATUS" -eq 302 ]; then
    log_info "Redirection HTTP → HTTPS fonctionne ✓"
else
    log_warn "La redirection HTTP ne semble pas fonctionner (Status: $HTTP_STATUS)"
fi

HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
if [ "$HTTPS_STATUS" -eq 200 ]; then
    log_info "HTTPS fonctionne ✓"
else
    log_warn "HTTPS ne répond pas correctement (Status: $HTTPS_STATUS)"
fi

echo ""
echo "=============================================="
echo -e "${GREEN}✅ Configuration HTTPS terminée !${NC}"
echo "=============================================="
echo ""
echo "🌐 Votre site est accessible à :"
echo "   https://$DOMAIN"
echo ""
echo "📋 Commandes utiles :"
echo "   - Voir les logs : docker-compose -f docker-compose-https.yml logs -f"
echo "   - Redémarrer : docker-compose -f docker-compose-https.yml restart"
echo "   - Arrêter : docker-compose -f docker-compose-https.yml down"
echo ""
echo "🔄 Le certificat sera renouvelé automatiquement."
echo ""
