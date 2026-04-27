# Team Control 🚀

**Team Control** est une solution complète de gestion d'équipe et de suivi d'activités. Ce projet combine une application mobile moderne (Flutter) et une API backend robuste (PHP/MySQL).

## 🌟 Fonctionnalités

- 📱 **Interface Mobile Intuitive** : Développée avec Flutter pour une expérience fluide.
- 🔐 **Gestion des Utilisateurs** : Authentification sécurisée et gestion des profils.
- 📊 **Suivi des Activités** : Monitoring en temps réel des tâches et des membres.
- 🔔 **Notifications** : Système de notifications intégré pour rester informé.
- 📁 **Gestion de Documents** : Importation et partage d'images/fichiers.

## 🛠️ Stack Technique

- **Frontend** : [Flutter](https://flutter.dev) (Dart)
- **Backend** : PHP (API REST)
- **Base de données** : MySQL
- **Dépendances Clés** :
  - `http` : Pour les appels API.
  - `shared_preferences` : Stockage local des données.
  - `image_picker` : Sélection d'images.
  - `intl` : Internationalisation et formatage.

## 🚀 Installation

### 1. Configuration du Backend
1. Copiez le dossier `apis` sur votre serveur local (ex: WAMP/XAMPP).
2. Importez le fichier SQL `apis/arnos_tech_db.sql` dans votre base de données MySQL.
3. Configurez les accès dans `apis/api/config/database.php`.

### 2. Configuration du Mobile
1. Assurez-vous d'avoir Flutter installé.
2. Clonez le projet :
   ```bash
   git clone https://github.com/AliDev2205/teamcontrol.git
   ```
3. Installez les dépendances :
   ```bash
   flutter pub get
   ```
4. Lancez l'application :
   ```bash
   flutter run
   ```

## 📝 Auteur
Développé par **AliDev**.


