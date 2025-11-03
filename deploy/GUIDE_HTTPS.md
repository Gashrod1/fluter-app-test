# 🔒 Guide de Configuration HTTPS pour dev.flexitronic.fr

Ce guide vous explique comment sécuriser votre application Flutter Web avec HTTPS sur votre VPS distant.

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :
- ✅ Un VPS avec Docker et Docker Compose installés
- ✅ Un nom de domaine : **dev.flexitronic.fr**
- ✅ Le domaine doit pointer vers l'IP de votre VPS (enregistrement DNS A)
- ✅ Les ports 80 et 443 ouverts sur votre firewall

## 🔍 Étape 1 : Vérifier la Configuration DNS

Sur votre ordinateur local, vérifiez que le domaine pointe vers votre VPS :

```powershell
nslookup dev.flexitronic.fr
```

Vous devriez voir l'IP de votre VPS. Si ce n'est pas le cas, configurez votre DNS :

### Configuration DNS chez votre registrar :
```
Type: A
Nom: dev
Valeur: [IP_DE_VOTRE_VPS]
TTL: 3600
```

Attendez quelques minutes que la propagation DNS se fasse.

## 📦 Étape 2 : Préparer les Fichiers sur votre Ordinateur Local

Les fichiers suivants ont été créés dans votre projet :
- `docker-compose-https.yml` : Configuration Docker avec support HTTPS
- `deploy/nginx-https.conf` : Configuration Nginx avec SSL
- `deploy/GUIDE_HTTPS.md` : Ce guide

## 🚀 Étape 3 : Déployer sur le VPS

### A. Se connecter au VPS

```powershell
ssh votre_utilisateur@IP_DE_VOTRE_VPS
```

### B. Créer le répertoire du projet (si pas déjà fait)

```bash
mkdir -p ~/doxa-motorisation-app
cd ~/doxa-motorisation-app
```

### C. Transférer les fichiers depuis votre ordinateur local

Ouvrez un **nouveau terminal PowerShell** sur votre ordinateur local et exécutez :

```powershell
# Remplacez ces valeurs
$VPS_USER = "votre_utilisateur"
$VPS_IP = "IP_DE_VOTRE_VPS"
$LOCAL_PATH = "c:\Users\cutes\Documents\altern\fluter-app-test"

# Transférer tous les fichiers nécessaires
scp -r "$LOCAL_PATH\*" ${VPS_USER}@${VPS_IP}:~/doxa-motorisation-app/
```

Ou utilisez WinSCP / FileZilla pour transférer les fichiers graphiquement.

## 🔐 Étape 4 : Obtenir le Certificat SSL (sur le VPS)

Retournez dans votre terminal SSH connecté au VPS :

```bash
cd ~/doxa-motorisation-app

# Créer les répertoires pour Certbot
mkdir -p certbot/conf certbot/www

# Démarrer temporairement Nginx pour la vérification Let's Encrypt
docker-compose -f docker-compose-https.yml up -d doxa-motorisation-app

# Obtenir le certificat SSL
docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  -d dev.flexitronic.fr \
  --email votre-email@example.com \
  --agree-tos \
  --no-eff-email
```

**Remplacez `votre-email@example.com` par votre véritable email.**

### Si vous obtenez une erreur :

1. Vérifiez que le DNS pointe bien vers votre VPS
2. Vérifiez que les ports 80 et 443 sont ouverts :
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

## 🔄 Étape 5 : Redémarrer avec HTTPS

Une fois le certificat obtenu :

```bash
cd ~/doxa-motorisation-app

# Arrêter les conteneurs actuels
docker-compose down

# Démarrer avec la configuration HTTPS complète
docker-compose -f docker-compose-https.yml up -d

# Vérifier que tout fonctionne
docker-compose -f docker-compose-https.yml ps
docker-compose -f docker-compose-https.yml logs -f
```

## ✅ Étape 6 : Tester votre Site

Ouvrez votre navigateur et accédez à :
- 🌐 http://dev.flexitronic.fr → devrait rediriger vers HTTPS
- 🔒 https://dev.flexitronic.fr → votre application sécurisée !

Vérifiez le certificat SSL :
1. Cliquez sur le cadenas dans la barre d'adresse
2. Vous devriez voir "Connexion sécurisée"
3. Le certificat doit être valide et émis par Let's Encrypt

## 🔄 Renouvellement Automatique

Le conteneur Certbot est configuré pour renouveler automatiquement le certificat tous les 12 heures.

Pour forcer un renouvellement manuel :

```bash
docker-compose -f docker-compose-https.yml exec certbot certbot renew
docker-compose -f docker-compose-https.yml restart doxa-motorisation-app
```

## 🛠️ Maintenance et Dépannage

### Voir les logs

```bash
# Logs de l'application
docker-compose -f docker-compose-https.yml logs -f doxa-motorisation-app

# Logs de Certbot
docker-compose -f docker-compose-https.yml logs certbot
```

### Redémarrer l'application

```bash
docker-compose -f docker-compose-https.yml restart doxa-motorisation-app
```

### Vérifier les certificats

```bash
ls -la certbot/conf/live/dev.flexitronic.fr/
```

Vous devriez voir :
- `fullchain.pem`
- `privkey.pem`
- `chain.pem`
- `cert.pem`

### Problèmes courants

#### 1. Erreur "Connection refused" lors de l'accès au site

```bash
# Vérifier que les conteneurs fonctionnent
docker ps

# Vérifier les ports
sudo netstat -tlnp | grep -E ':(80|443)'
```

#### 2. Erreur "Certificate not found"

Le certificat n'a pas été généré correctement. Répétez l'étape 4.

#### 3. "Mixed content" warnings

Vérifiez que votre API backend utilise aussi HTTPS, ou ajustez la Content-Security-Policy.

## 🔄 Mise à jour de l'Application

Quand vous modifiez votre code Flutter :

```bash
# Sur votre ordinateur local, rebuilder
flutter build web --release

# Transférer vers le VPS
scp -r build/web/* ${VPS_USER}@${VPS_IP}:~/doxa-motorisation-app/build/web/

# Sur le VPS, rebuilder et redémarrer
cd ~/doxa-motorisation-app
docker-compose -f docker-compose-https.yml up -d --build
```

## 📊 Test de Performance SSL

Testez la qualité de votre configuration SSL :
- 🔗 https://www.ssllabs.com/ssltest/analyze.html?d=dev.flexitronic.fr

Vous devriez obtenir une note A ou A+.

## 🎯 Résumé des Commandes Importantes

```bash
# Démarrer
docker-compose -f docker-compose-https.yml up -d

# Arrêter
docker-compose -f docker-compose-https.yml down

# Voir les logs
docker-compose -f docker-compose-https.yml logs -f

# Redémarrer
docker-compose -f docker-compose-https.yml restart

# Renouveler le certificat manuellement
docker-compose -f docker-compose-https.yml exec certbot certbot renew
docker-compose -f docker-compose-https.yml restart doxa-motorisation-app
```

## 🆘 Besoin d'Aide ?

Si vous rencontrez des problèmes :

1. Vérifiez les logs : `docker-compose -f docker-compose-https.yml logs -f`
2. Vérifiez la configuration DNS : `nslookup dev.flexitronic.fr`
3. Vérifiez le firewall : `sudo ufw status`
4. Testez le port 80 : `curl -I http://dev.flexitronic.fr`
5. Testez le port 443 : `curl -I https://dev.flexitronic.fr`

---

## 🎉 Félicitations !

Votre application Flutter est maintenant sécurisée avec HTTPS ! 🔒✨
