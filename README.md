# 🏠 Contrôle Volets Électriques

Application Flutter pour contrôler des volets électriques à distance via une API REST.

## 📋 Description

Cette application mobile permet de contrôler vos volets électriques depuis votre smartphone. Elle se connecte à une API REST pour authentifier l'utilisateur et envoyer des commandes (ouvrir, fermer, stop) aux différents dispositifs de volets électriques.

## ✨ Fonctionnalités

- 🔐 **Authentification sécurisée** : Connexion avec IP locale et mot de passe
- 📱 **Interface intuitive** : Design simple et efficace
- 🎛️ **Contrôle des volets** :
  - Ouvrir les volets (UP)
  - Fermer les volets (DOWN)
  - Arrêter le mouvement (STOP)
- 🔄 **Multi-dispositifs** : Gestion de plusieurs volets avec sélection
- 🔁 **Actualisation** : Rafraîchissement de la liste des dispositifs
- 📡 **API REST** : Communication via HTTP avec gestion des sessions

## 🛠️ Technologies utilisées

- **Flutter** : Framework de développement mobile
- **Dart** : Langage de programmation
- **HTTP Package** : Communication avec l'API REST
- **Material Design 3** : Interface utilisateur moderne

## 📦 Prérequis

- Flutter SDK (version 3.9.2 ou supérieure)
- Dart SDK
- Un éditeur de code (VS Code, Android Studio, etc.)
- Un émulateur ou un appareil physique pour tester l'application

## 🚀 Installation

1. **Cloner le repository**
```bash
git clone https://github.com/Gashrod1/fluter-app-test.git
cd flutter_app_project
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Lancer l'application**
```bash
flutter run
```

## 🔌 Configuration de l'API

L'application communique avec une API REST qui doit exposer les endpoints suivants :

### Authentification
```
GET /interface/login
Query Parameters:
  - localip: string (IP locale pour la connexion)
  - password: string (mot de passe en clair)
Response: Cookie de session
```

### Récupération des dispositifs
```
GET /device
Headers:
  - Cookie: session
Response: Liste des dispositifs
```

### Envoi de commandes
```
GET /device/{deviceId}/command/{action}
Path Parameters:
  - deviceId: ID du dispositif
  - action: Code de l'action (0-6)
Headers:
  - Cookie: session
```

### Actions disponibles
- `0` : OFF
- `1` : ON
- `2` : PROG
- `3` : STOP
- `4` : DOWN (Fermer)
- `5` : UP (Ouvrir)
- `6` : TOGGLE

## 📱 Utilisation

1. **Connexion**
   - Entrez l'URL de votre API (ex: `http://192.168.1.100:8080`)
   - Saisissez votre IP locale
   - Entrez votre mot de passe
   - Appuyez sur "Se connecter"

2. **Contrôle des volets**
   - Sélectionnez un dispositif (si vous en avez plusieurs)
   - Utilisez les boutons pour contrôler vos volets :
     - **Ouvrir** : Monte les volets
     - **Fermer** : Descend les volets
     - **Stop** : Arrête le mouvement

3. **Déconnexion**
   - Cliquez sur l'icône de déconnexion en haut à droite

## 📂 Structure du projet

```
lib/
├── main.dart           # Point d'entrée et interfaces UI
└── api_service.dart    # Service de communication API
```

### Fichiers principaux

- **`main.dart`** : Contient les widgets de l'application (LoginPage, MyHomePage)
- **`api_service.dart`** : Gère l'authentification et les requêtes API

## 🔧 Développement

### Architecture

L'application suit une architecture simple :
- **UI Layer** : Widgets Flutter pour l'interface utilisateur
- **Service Layer** : ApiService pour la communication avec l'API
- **Model Layer** : Classes Device et DeviceAction

### Ajouter de nouvelles fonctionnalités

Pour ajouter une nouvelle action :
1. Ajoutez l'action dans l'enum `DeviceAction` dans `api_service.dart`
2. Créez un nouveau bouton dans `MyHomePage` qui appelle `_sendCommand()`

## 🐛 Dépannage

### Problème de connexion
- Vérifiez que l'URL de l'API est correcte
- Assurez-vous que votre appareil est sur le même réseau que l'API
- Vérifiez vos identifiants de connexion

### Erreur 401
- Votre session a expiré, reconnectez-vous

### Aucun dispositif trouvé
- Vérifiez que votre API retourne bien des dispositifs
- Actualisez la liste avec le bouton refresh

## 📄 Licence

Ce projet est sous licence MIT.

## 👤 Auteur

Développé par Gashrod1

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📞 Support

Pour toute question ou problème, ouvrez une issue sur GitHub.
