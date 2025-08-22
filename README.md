# 🤖 LudoBot - Application Interactive pour Raspberry Pi

Une application Qt6/QML complète pour Raspberry Pi offrant des quiz éducatifs, jeux de mémoire, gestion des contacts et bien plus encore.

## 🎯 Fonctionnalités

### 🧠 Quiz Éducatifs
- **Mathématiques** - Calculs et logique adaptés par âge
- **Sciences** - Découverte du monde scientifique
- **Histoire** - Événements et personnages historiques
- **Géographie** - Pays, capitales et continents
- **Français** - Vocabulaire et grammaire
- **Culture Générale** - Connaissances diverses

### 🎮 Jeux de Mémoire
- **Memory Cards** - Jeu de paires classique
- **Simon Says** - Répétition de séquences
- **Color Sequence** - Mémorisation de couleurs

### 👥 Gestion des Contacts
- **Contacts Résidents** - Base de données des résidents
- **Contacts Externes** - Carnet d'adresses
- **Gestion des Chambres** - Attribution et suivi

### 📅 Fonctionnalités Utilitaires
- **Activités** - Planning des événements
- **Menus** - Gestion des repas
- **Rappels** - Médicaments et rendez-vous
- **Plans** - Navigation dans les bâtiments

### ⚙️ Configuration
- **WiFi** - Gestion des connexions réseau
- **Volume** - Contrôle audio
- **Luminosité** - Réglage de l'écran
- **Paramètres** - Personnalisation de l'interface

## 📋 Prérequis

- **Python 3.8+**
- **PySide6 6.4.0+**
- **Raspberry Pi OS** (ou compatible Linux)

## 🚀 Installation

### 1. Cloner le projet
```bash
git clone <repository-url>
cd raspberry-software
```

### 2. Créer l'environnement virtuel
```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# ou
.venv\Scripts\activate     # Windows
```

### 3. Installer les dépendances
```bash
pip install -r requirements.txt
```

## 📁 Structure du Projet

```
raspberry-software/
├── main.py                 # Point d'entrée principal
├── requirements.txt        # Dépendances Python
├── controllers/           # Contrôleurs système
│   ├── luminosite.py      # Gestion luminosité
│   ├── parametres.py      # Configuration
│   ├── volume.py          # Contrôle audio
│   └── wifi.py            # Gestion WiFi
├── ui/                    # Interface QML
│   ├── main.qml           # Interface principale
│   ├── Style.qml          # Thème et styles
│   ├── assets/            # Ressources (icônes, sons)
│   └── *.qml              # Pages de l'application
├── quizzes/               # Données CSV
│   ├── maths.csv          # Questions mathématiques
│   ├── science.csv        # Questions sciences
│   ├── activities.csv     # Planning activités
│   ├── menu.csv           # Menus des repas
│   └── *.csv              # Autres données
├── utils/                 # Utilitaires C++
│   ├── fileio.cpp         # Gestion fichiers
│   └── fileio.h           # Headers
└── .venv/                 # Environnement virtuel
```

## 🎮 Utilisation

### Lancement de l'application
```bash
# Activer l'environnement virtuel
source .venv/bin/activate

# Lancer l'application
python main.py
```

### Modes d'utilisation
- **Mode Résident** - Interface simplifiée pour les résidents
- **Mode Visiteur** - Informations et navigation
- **Mode Parent** - Contrôle parental et configuration
- **Mode Formation** - Outils éducatifs avancés

## 📊 Format des Fichiers CSV

### Quiz (colonnes B-G utilisées)
```csv
id;question;réponse_correcte;choix1;choix2;choix3;choix4;difficulté;anecdote
1;Combien font 2+2?;4;3;4;5;6;facile;Addition simple
```

### Activités
```csv
Date;Heure;Activité;Description;Lieu
2024-01-15;14:00;Atelier cuisine;Préparation de cookies;Cuisine
```

### Menus
```csv
Jour;Heure;Type;Plat
Lundi;12:00;Déjeuner;Salade César
```

## 🔧 Configuration

### Variables d'environnement
```bash
export QT_QUICK_CONTROLS_STYLE=Material
```

### Paramètres système
- **Résolution** : Optimisé pour écrans tactiles 1024x768+
- **Audio** : Support ALSA/PulseAudio
- **Réseau** : WiFi avec interface graphique

## 🎨 Personnalisation

### Thème
Modifiez `ui/Style.qml` pour personnaliser :
- Couleurs principales
- Tailles de police
- Espacements
- Animations

### Ajout de quiz
1. Créer un fichier CSV dans `quizzes/`
2. Ajouter le mapping dans `chargeur_matieres.py`
3. Créer une page QML correspondante

## 🐛 Dépannage

### Problèmes courants
- **Import PySide6 échoue** : Vérifier l'installation dans le venv
- **Fichiers CSV non trouvés** : Vérifier les chemins relatifs
- **Interface ne s'affiche pas** : Vérifier les permissions d'affichage

### Logs de debug
Les erreurs sont affichées dans la console. Pour plus de détails :
```bash
python main.py 2>&1 | tee app.log
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## 📝 Licence

Ce projet est sous licence [MIT](LICENSE).

## 👥 Auteurs

- **Développeur Principal** - Interface et logique applicative
- **Designer UX** - Expérience utilisateur adaptée aux seniors

## 🙏 Remerciements

- Communauté Qt/QML pour la documentation
- Équipes de test pour les retours utilisateurs
- Contributeurs open source
