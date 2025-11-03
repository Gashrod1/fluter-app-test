# 📁 Dossier Deploy - Index des Guides

Bienvenue dans le dossier de déploiement ! Voici tous les guides disponibles pour déployer votre application Flutter.

## 🎯 Vous Voulez Sécuriser avec HTTPS ? (Nouveau !)

### Pour dev.flexitronic.fr

**🚀 Démarrage Rapide :**
1. **[HTTPS_RESUME.md](HTTPS_RESUME.md)** - Lisez-moi en premier ! (5 min)
2. **[CHECKLIST_HTTPS.md](CHECKLIST_HTTPS.md)** - Cochez au fur et à mesure
3. **[GUIDE_HTTPS.md](GUIDE_HTTPS.md)** - Guide complet et détaillé

**📦 Fichiers de Configuration :**
- `nginx-https.conf` - Configuration Nginx avec SSL/TLS
- `docker-compose-https.yml` - Docker Compose avec support HTTPS
- `setup-https-vps.sh` - Script automatique pour VPS (Linux)
- `deploy-https.ps1` - Script de déploiement (Windows)

**✨ Résultat :** Site accessible sur https://dev.flexitronic.fr avec certificat SSL gratuit !

---

## 📚 Guides de Déploiement Standard

### Déploiement HTTP Simple

Si vous voulez juste déployer sans HTTPS d'abord :

- **[GUIDE_RAPIDE.md](GUIDE_RAPIDE.md)** - Déploiement rapide en HTTP
- **[DOCKER.md](DOCKER.md)** - Déploiement avec Docker
- `nginx-docker.conf` - Configuration Nginx basique
- `setup-vps.sh` - Script de configuration VPS
- `deploy.sh` - Script de déploiement (Linux)
- `deploy.ps1` - Script de déploiement (Windows)

---

## 🗺️ Quel Guide Choisir ?

### Vous Voulez HTTPS (Recommandé pour Production)
→ Suivez les guides HTTPS ci-dessus ⬆️

### Vous Voulez Juste Tester Rapidement
→ [GUIDE_RAPIDE.md](GUIDE_RAPIDE.md)

### Vous Préférez Docker
→ [DOCKER.md](DOCKER.md) puis passez à HTTPS avec les guides HTTPS

### Vous Avez Déjà HTTP et Voulez Ajouter HTTPS
→ [GUIDE_HTTPS.md](GUIDE_HTTPS.md) - Section "Migration depuis HTTP"

---

## 📖 Structure des Fichiers

```
deploy/
├── 📄 INDEX.md                    ← Vous êtes ici !
│
├── 🔒 GUIDES HTTPS (Nouveau !)
│   ├── HTTPS_RESUME.md            → Résumé rapide HTTPS
│   ├── CHECKLIST_HTTPS.md         → Checklist étape par étape
│   ├── GUIDE_HTTPS.md             → Guide complet HTTPS
│   ├── nginx-https.conf           → Config Nginx SSL
│   ├── setup-https-vps.sh         → Script auto VPS (Linux)
│   └── deploy-https.ps1           → Script déploiement (Windows)
│
├── 📚 GUIDES STANDARD
│   ├── GUIDE_RAPIDE.md            → Démarrage rapide
│   ├── DOCKER.md                  → Guide Docker
│   ├── nginx-docker.conf          → Config Nginx basique
│   ├── setup-vps.sh               → Script VPS
│   ├── deploy.sh                  → Script déploiement (Linux)
│   └── deploy.ps1                 → Script déploiement (Windows)
│
└── 📋 AUTRES
    └── README.md                  → Documentation générale
```

---

## 🚀 Démarrage Rapide HTTPS

### En 3 Étapes :

1. **Configurer le DNS**
   ```
   Type : A
   Nom : dev
   Domaine : flexitronic.fr
   Valeur : [IP de votre VPS]
   ```

2. **Exécuter le script de déploiement (Windows)**
   ```powershell
   # Éditez d'abord le script avec vos informations
   notepad deploy-https.ps1
   
   # Puis exécutez
   .\deploy-https.ps1
   ```

3. **Sur votre VPS**
   ```bash
   cd ~/doxa-motorisation-app
   chmod +x deploy/setup-https-vps.sh
   ./deploy/setup-https-vps.sh
   ```

**C'est tout !** 🎉 Votre site est sur https://dev.flexitronic.fr

---

## 💡 Conseils

### Pour les Débutants
1. Commencez par **[HTTPS_RESUME.md](HTTPS_RESUME.md)**
2. Suivez la **[CHECKLIST_HTTPS.md](CHECKLIST_HTTPS.md)**
3. Consultez **[GUIDE_HTTPS.md](GUIDE_HTTPS.md)** si vous bloquez

### Pour les Experts
- Utilisez directement `docker-compose-https.yml`
- Adaptez `nginx-https.conf` selon vos besoins
- Consultez les scripts pour l'automatisation

---

## 🆘 Besoin d'Aide ?

### Problèmes DNS
```powershell
# Vérifier que le DNS fonctionne
nslookup dev.flexitronic.fr
```

### Problèmes de Connexion VPS
```bash
# Tester la connexion
ssh -v user@ip

# Vérifier les ports
sudo ufw status
```

### Problèmes Docker
```bash
# Voir les conteneurs
docker ps -a

# Voir les logs
docker-compose -f docker-compose-https.yml logs -f
```

---

## 📞 Support

Pour toute question :
1. Consultez d'abord les guides correspondants
2. Vérifiez les logs : `docker-compose logs -f`
3. Relisez la section dépannage du guide

---

## 🎉 Bon Déploiement !

N'oubliez pas : HTTPS est essentiel pour la sécurité de votre application en production !

**Bonne chance ! 🚀**
