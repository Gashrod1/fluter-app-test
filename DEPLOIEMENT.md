# 📱 Doxa Motorisation Flutter App - Guide de Déploiement VPS

Application Flutter pour la gestion de dispositifs Doxa Motorisation, avec déploiement sur VPS.

## 📚 Table des matières

- [Aperçu](#aperçu)
- [Développement Local](#développement-local)
- [Déploiement sur VPS](#déploiement-sur-vps)
- [Guides de Déploiement](#guides-de-déploiement)
- [Architecture](#architecture)

## 🎯 Aperçu

Cette application Flutter permet de :
- Se connecter à l'API Doxa Motorisation
- Gérer des dispositifs connectés
- Envoyer des commandes aux dispositifs

## 💻 Développement Local

### Prérequis
- Flutter SDK 3.9.2+
- Dart 3.0+

### Installation

```powershell
# Cloner le projet (si depuis un repo)
git clone [VOTRE_REPO]
cd flutter_app_project

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run -d chrome  # Web
flutter run -d windows # Windows
```

### Build

```powershell
# Web
flutter build web --release

# Windows
flutter build windows --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🚀 Déploiement sur VPS

Votre application a été compilée avec succès en version web ! Les fichiers sont dans `build\web\`.

### Guides Disponibles

Nous avons créé des guides complets pour vous :

#### 📖 Guide Rapide (Recommandé pour démarrer)
👉 **[deploy/GUIDE_RAPIDE.md](deploy/GUIDE_RAPIDE.md)**
- Configuration VPS en 5 minutes
- Déploiement pas à pas
- Scripts PowerShell prêts à l'emploi

#### 📚 Guide Complet
👉 **[deploy/README.md](deploy/README.md)**
- Configuration détaillée
- Optimisations avancées
- Monitoring et maintenance
- Sécurité et SSL

#### 🐳 Guide Docker
👉 **[deploy/DOCKER.md](deploy/DOCKER.md)**
- Déploiement avec conteneurs
- Configuration Docker Compose
- Gestion et monitoring

#### 🔒 Guide HTTPS (Nouveau !)
👉 **[deploy/GUIDE_HTTPS.md](deploy/GUIDE_HTTPS.md)**
- Configuration SSL/TLS avec Let's Encrypt
- Sécurisation de votre domaine
- Certificats automatiques et gratuits
- Guide pour dev.flexitronic.fr

## 📂 Structure du Projet

```
flutter_app_project/
├── lib/
│   ├── main.dart           # Point d'entrée
│   ├── login_page.dart     # Page de connexion
│   ├── home_page.dart      # Page d'accueil
│   ├── api_service.dart    # Service API
│   └── models/
│       └── device.dart     # Modèle Device
├── deploy/
│   ├── GUIDE_RAPIDE.md         # 🎯 COMMENCEZ ICI !
│   ├── README.md               # Guide complet
│   ├── DOCKER.md               # Guide Docker
│   ├── nginx.conf              # Config Nginx
│   ├── setup-vps.sh            # Script setup VPS
│   ├── deploy.sh               # Script déploiement (Linux)
│   ├── deploy.ps1              # Script déploiement (Windows)
│   └── build-and-deploy.ps1    # Build + Deploy
├── build/
│   └── web/                    # ✅ Application compilée
├── Dockerfile                  # Configuration Docker
├── docker-compose.yml          # Docker Compose
└── pubspec.yaml               # Dépendances

```

## 🎬 Démarrage Rapide - VPS

### Option 1 : Déploiement Automatique (Windows avec PuTTY)

```powershell
# 1. Si PuTTY est installé, lancez directement :
.\deploy\build-and-deploy.ps1 -VpsIP "VOTRE_IP_VPS" -VpsUser "root"

# 2. C'est tout ! Votre app sera accessible sur http://VOTRE_IP_VPS
```

### Option 2 : Déploiement Manuel

1. **Configurez votre VPS** (une seule fois)
   - Consultez [deploy/GUIDE_RAPIDE.md](deploy/GUIDE_RAPIDE.md) section "Configuration du VPS"

2. **Copiez les fichiers**
   - Utilisez WinSCP ou FileZilla
   - Copiez `build\web\*` vers `/var/www/doxa-motorisation-app` sur le VPS

3. **Accédez à votre application**
   - Ouvrez `http://VOTRE_IP_VPS`

### Option 3 : Docker

```powershell
# Build de l'image
docker build -t doxa-motorisation-app .

# Lancement
docker run -d -p 80:80 --name doxa-motorisation-app doxa-motorisation-app:latest
```

## 🔧 Configuration

### Variables d'environnement

L'URL de l'API est définie dans `lib/api_service.dart` :
```dart
static const String baseUrl = 'https://airsend.cloud';
```

Pour la modifier pour votre propre API :
1. Éditez `lib/api_service.dart`
2. Changez la valeur de `baseUrl`
3. Rebuild l'application

## 🔒 Sécurité

- ✅ Utilisez HTTPS en production (Let's Encrypt)
- ✅ Configurez un firewall (ufw)
- ✅ Gardez votre VPS à jour
- ✅ Utilisez des clés SSH au lieu de mots de passe

## 📊 Monitoring

```bash
# Sur le VPS
# Logs Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Statut Nginx
systemctl status nginx

# Utilisation des ressources
htop
df -h
```

## 🐛 Dépannage

### L'application ne se charge pas
1. Vérifiez que Nginx est démarré : `systemctl status nginx`
2. Consultez les logs : `tail -f /var/log/nginx/error.log`
3. Vérifiez les permissions : `ls -la /var/www/doxa-motorisation-app`

### Erreur de build Flutter
```powershell
flutter clean
flutter pub get
flutter build web --release
```

### Problème de connexion SSH
- Vérifiez l'IP de votre VPS
- Assurez-vous que le port 22 est ouvert
- Vérifiez vos identifiants

## 📱 Plateformes Supportées

- ✅ Web (Production ready)
- ✅ Windows
- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS

## 🤝 Contribution

Ce projet est privé. Pour contribuer :
1. Créez une branche pour votre fonctionnalité
2. Committez vos changements
3. Créez une Pull Request

## 📄 Licence

Propriétaire - Tous droits réservés

## 📞 Support

Pour toute question sur le déploiement, consultez :
- [Guide Rapide](deploy/GUIDE_RAPIDE.md) - Démarrage rapide
- [Guide Complet](deploy/README.md) - Documentation complète
- [Guide Docker](deploy/DOCKER.md) - Déploiement Docker

---

## 🎉 Prochaines Étapes

1. **[Configurez votre VPS](deploy/GUIDE_RAPIDE.md)** - 5 minutes
2. **Déployez votre application** - 2 minutes
3. **Activez HTTPS** - 1 minute
4. **Profitez !** 🚀

**Votre application est déjà buildée et prête à être déployée dans `build\web\` !**
