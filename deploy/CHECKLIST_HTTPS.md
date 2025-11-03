# ✅ Checklist Configuration HTTPS pour dev.flexitronic.fr

Cochez chaque étape au fur et à mesure :

## 📋 Avant de Commencer

- [ ] J'ai accès à mon VPS via SSH
- [ ] Je connais l'IP de mon VPS : `_________________`
- [ ] Docker est installé sur mon VPS
- [ ] J'ai accès à la configuration DNS de mon domaine
- [ ] J'ai une adresse email valide : `_________________`

---

## 🌐 Configuration DNS (Chez votre registrar)

- [ ] Je me suis connecté à mon compte chez le registrar (OVH, Gandi, etc.)
- [ ] J'ai créé un enregistrement DNS de type **A** :
  ```
  Type : A
  Nom : dev
  Valeur : [IP de mon VPS]
  TTL : 3600
  ```
- [ ] J'ai attendu 5-10 minutes pour la propagation DNS
- [ ] J'ai vérifié avec `nslookup dev.flexitronic.fr` sur mon PC
- [ ] Le DNS pointe bien vers l'IP de mon VPS

---

## 🔧 Configuration VPS (Sur le serveur distant)

### Firewall
- [ ] Port 22 (SSH) ouvert : `sudo ufw allow 22/tcp`
- [ ] Port 80 (HTTP) ouvert : `sudo ufw allow 80/tcp`
- [ ] Port 443 (HTTPS) ouvert : `sudo ufw allow 443/tcp`
- [ ] Firewall activé : `sudo ufw enable`

### Docker
- [ ] Docker installé : `docker --version`
- [ ] Docker Compose installé : `docker-compose --version`
- [ ] Docker fonctionne : `docker ps`

---

## 📦 Transfert des Fichiers

### Option A : Script Automatique
- [ ] J'ai modifié `deploy\deploy-https.ps1` avec mes informations (VPS_USER, VPS_IP)
- [ ] J'ai exécuté le script : `.\deploy\deploy-https.ps1`
- [ ] Les fichiers ont été transférés avec succès

### Option B : Transfert Manuel
- [ ] J'ai transféré tous les fichiers avec WinSCP/FileZilla/SCP
- [ ] Les fichiers sont dans `~/doxa-motorisation-app` sur le VPS

---

## 🔐 Configuration SSL (Sur le VPS)

- [ ] Je me suis connecté au VPS : `ssh user@ip`
- [ ] Je suis dans le bon répertoire : `cd ~/doxa-motorisation-app`
- [ ] J'ai édité `deploy/setup-https-vps.sh` pour mettre mon email
- [ ] J'ai rendu le script exécutable : `chmod +x deploy/setup-https-vps.sh`
- [ ] J'ai exécuté le script : `./deploy/setup-https-vps.sh`
- [ ] Le certificat SSL a été obtenu avec succès
- [ ] Les conteneurs Docker sont lancés : `docker-compose -f docker-compose-https.yml ps`

---

## ✨ Tests Finaux

- [ ] Je peux accéder à http://dev.flexitronic.fr
- [ ] Je suis automatiquement redirigé vers https://dev.flexitronic.fr
- [ ] Le cadenas 🔒 apparaît dans la barre d'adresse
- [ ] Le certificat est valide (clic sur le cadenas → certificat valide)
- [ ] L'application Flutter se charge correctement
- [ ] Je peux me connecter à l'application

---

## 🎯 Vérifications de Sécurité

- [ ] Test SSL Labs : https://www.ssllabs.com/ssltest/analyze.html?d=dev.flexitronic.fr
  - Note obtenue : `___` (devrait être A ou A+)
- [ ] Headers de sécurité présents (F12 → Network → voir les headers)
  - [ ] Strict-Transport-Security
  - [ ] X-Frame-Options
  - [ ] X-Content-Type-Options
  - [ ] X-XSS-Protection

---

## 📝 Informations à Conserver

```
Domaine : dev.flexitronic.fr
IP VPS : _________________
Utilisateur SSH : _________________
Email Let's Encrypt : _________________
Date d'installation : _________________
Date d'expiration certificat : _________________ (dans 90 jours)
```

---

## 🔄 Maintenance Future

### Commandes à retenir :

```bash
# Voir les logs
docker-compose -f docker-compose-https.yml logs -f

# Redémarrer
docker-compose -f docker-compose-https.yml restart

# Arrêter
docker-compose -f docker-compose-https.yml down

# Démarrer
docker-compose -f docker-compose-https.yml up -d

# Renouveler le certificat manuellement (si besoin)
docker-compose -f docker-compose-https.yml exec certbot certbot renew
docker-compose -f docker-compose-https.yml restart doxa-motorisation-app
```

### Tâches récurrentes :
- [ ] Vérifier les logs chaque semaine
- [ ] Mettre à jour Docker : `sudo apt update && sudo apt upgrade`
- [ ] Vérifier l'expiration du certificat (renouvelé automatiquement)

---

## 🆘 En Cas de Problème

1. **Consulter les logs** :
   ```bash
   docker-compose -f docker-compose-https.yml logs -f
   ```

2. **Vérifier les conteneurs** :
   ```bash
   docker-compose -f docker-compose-https.yml ps
   ```

3. **Redémarrer** :
   ```bash
   docker-compose -f docker-compose-https.yml restart
   ```

4. **Consulter les guides** :
   - `deploy/HTTPS_RESUME.md` - Résumé rapide
   - `deploy/GUIDE_HTTPS.md` - Guide complet

---

## ✅ Statut Final

- [ ] ✨ **HTTPS CONFIGURÉ ET FONCTIONNEL !**
- [ ] 🎉 Application accessible sur https://dev.flexitronic.fr
- [ ] 🔒 Certificat SSL valide
- [ ] 🔄 Renouvellement automatique configuré

**Date de finalisation : _________________**

**Bravo ! Votre application est maintenant sécurisée ! 🚀**
