# 🔒 Configuration HTTPS - Résumé Rapide

## 📦 Fichiers créés pour vous

J'ai créé tous les fichiers nécessaires pour sécuriser votre site **dev.flexitronic.fr** avec HTTPS :

```
deploy/
├── 📄 GUIDE_HTTPS.md           → Guide complet étape par étape
├── 📄 nginx-https.conf         → Configuration Nginx avec SSL
├── 📄 setup-https-vps.sh       → Script automatique pour VPS (Linux)
└── 📄 deploy-https.ps1         → Script de déploiement (Windows)

📄 docker-compose-https.yml     → Configuration Docker avec HTTPS
```

## 🚀 Comment procéder (2 méthodes)

### ✨ Méthode 1 : Script Automatique (Recommandé)

**Sur votre PC Windows :**

1. **Modifiez le script** `deploy\deploy-https.ps1` :
   - Ligne 5 : Remplacez `"votre_utilisateur"` par votre nom d'utilisateur SSH
   - Ligne 6 : Remplacez `"123.456.789.012"` par l'IP de votre VPS

2. **Exécutez le script** depuis PowerShell :
   ```powershell
   cd c:\Users\cutes\Documents\altern\fluter-app-test
   .\deploy\deploy-https.ps1
   ```

3. **Sur votre VPS** (le script vous y connectera) :
   ```bash
   cd ~/doxa-motorisation-app
   chmod +x deploy/setup-https-vps.sh
   
   # IMPORTANT : Avant d'exécuter, éditez le fichier pour mettre votre email
   nano deploy/setup-https-vps.sh
   # Changez la ligne : EMAIL="votre-email@example.com"
   
   ./deploy/setup-https-vps.sh
   ```

4. **C'est fini !** Votre site est maintenant accessible sur :
   - 🌐 https://dev.flexitronic.fr

---

### 📖 Méthode 2 : Manuel (Si vous préférez tout contrôler)

Suivez le guide complet : **[deploy/GUIDE_HTTPS.md](GUIDE_HTTPS.md)**

---

## ✅ Prérequis IMPORTANTS

Avant de commencer, vérifiez que :

1. **DNS configuré** : dev.flexitronic.fr doit pointer vers l'IP de votre VPS
   
   Chez votre registrar de domaine (OVH, Gandi, etc.), créez :
   ```
   Type : A
   Nom : dev
   Valeur : [IP_DE_VOTRE_VPS]
   TTL : 3600
   ```

2. **Ports ouverts** sur votre VPS :
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   ```

3. **Docker installé** sur votre VPS :
   ```bash
   docker --version
   docker-compose --version
   ```

4. **Email valide** pour Let's Encrypt (requis pour les notifications de certificat)

---

## 🧪 Vérifier que le DNS fonctionne

**Sur votre PC Windows :**
```powershell
nslookup dev.flexitronic.fr
```

Vous devriez voir l'IP de votre VPS. Si ce n'est pas le cas, attendez quelques minutes (propagation DNS).

---

## 📋 Résumé des Commandes VPS

Une fois les fichiers transférés sur votre VPS :

```bash
# 1. Aller dans le répertoire
cd ~/doxa-motorisation-app

# 2. Créer les répertoires nécessaires
mkdir -p certbot/conf certbot/www

# 3. Obtenir le certificat SSL (remplacez l'email)
docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  -d dev.flexitronic.fr \
  --email VOTRE-EMAIL@example.com \
  --agree-tos \
  --no-eff-email

# 4. Démarrer avec HTTPS
docker-compose -f docker-compose-https.yml up -d

# 5. Vérifier que ça fonctionne
docker-compose -f docker-compose-https.yml ps
docker-compose -f docker-compose-https.yml logs -f
```

---

## 🎯 Après le Déploiement

Votre site sera accessible :
- ✅ https://dev.flexitronic.fr (sécurisé)
- ↗️ http://dev.flexitronic.fr (redirige automatiquement vers HTTPS)

Le certificat SSL :
- 🔄 Se renouvelle automatiquement tous les 90 jours
- 🆓 Gratuit (Let's Encrypt)
- 🔒 Niveau A+ de sécurité

---

## 🆘 Problèmes Courants

### ❌ "Connection refused"
```bash
# Vérifiez que Docker tourne
docker ps

# Redémarrez si nécessaire
docker-compose -f docker-compose-https.yml restart
```

### ❌ "Certificate not found"
Le certificat n'a pas été créé. Vérifiez :
1. Le DNS pointe vers votre VPS
2. Les ports 80 et 443 sont ouverts
3. Réessayez la commande certbot

### ❌ "Rate limit exceeded"
Let's Encrypt a une limite. Attendez 1 heure et réessayez.

---

## 📞 Besoin d'Aide ?

1. **Guide complet** : Lisez [deploy/GUIDE_HTTPS.md](GUIDE_HTTPS.md)
2. **Logs** : `docker-compose -f docker-compose-https.yml logs -f`
3. **Status** : `docker-compose -f docker-compose-https.yml ps`

---

## 🎉 Félicitations !

Une fois configuré, votre application Flutter sera :
- ✅ Sécurisée avec HTTPS
- ✅ Accessible sur votre domaine personnalisé
- ✅ Protégée avec des headers de sécurité modernes
- ✅ Optimisée pour les performances

**Bonne chance ! 🚀**
