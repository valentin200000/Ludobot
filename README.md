Top — j’ai relu ton contenu : il couvre bien les essentiels (objectif, archi, structure, modules, données, install, exécution, IU, dépannage, dev).
Il manque juste **quelques petits plus “pro”** que je te propose en fin de doc (facultatifs) : tableau des **paramètres par défaut**, **journalisation**, **tests/CI**, **confidentialité & accès fichiers**.

Voici la **version mise en forme** (cohérente, compacte, prête à coller) :

---

# 🤖 LudoBot – Application interactive Qt/QML pour Raspberry Pi

Application éducative et d’assistance orientée seniors/visiteurs, combinant quiz, jeux mémoire, gestion d’informations résidents et utilitaires, avec une architecture propre basée sur le **pattern Façade**.

## 1) Objectifs & périmètre

* Interfaces **Résident** et **Visiteur** adaptées.
* **Quiz** thématiques (maths, géographie, culture G., etc.).
* **Jeux mémoire** (Memory, Simon, séquences couleurs).
* **Utilitaires** : activités, menus, plan, rappel, contacts/résidents/chambres.
* **Intégration robotique** (caméra, moteurs) encapsulée derrière une façade simple.

## 2) Architecture (Façade)

* **Classe** : `RobotFacade` (`main.py`)
* **Rôle** : exposer une API minimale à QML et masquer capteurs/caméra/moteurs/chargeurs.
* **Signaux** : `system_ready()`, `error_occurred(message: str)`, `user_interface_active()`
* **Méthode principale** : `start_robot_system()` — vérifications → suivi visage → centrage → (approche distance **simulée** si pas de translation) → réglage vertical → activation IU → surveillance sécurité (QTimer).
* **Méthodes internes** : `_verify_all_systems()`, `_find_and_track_user()`, `_center_on_user()`, `_approach_target_distance()` *(simulation)*, `_vertical_adjustment()`, `_activate_user_interface()`, `_start_safety_monitoring()`, `_emergency_stop()`.

**Atouts** : interface QML simple (`robotFacade`), encapsulation forte, évolutivité sans impacter l’IU.

## 3) Structure du projet

```
raspberry-software/
├── main.py
├── controllers/
│   ├── camera.py                # Détection visage, trames
│   ├── capteurs.py              # Infrarouge / ultrason, agrégats sécurité
│   ├── moteurs_horizontaux.py   # Rotation horizontale (centrage PD)
│   ├── moteurs_verticaux.py     # Inclinaison/centrage vertical
│   ├── parametres.py            # Réglages applicatifs
│   ├── volume.py                # Audio
│   ├── luminosite.py            # Luminosité écran
│   └── wifi.py                  # Contrôleur Wi-Fi (UI)
├── ui/
│   ├── main.qml                 # Entrée UI
│   ├── Style.qml                # Thème/styles
│   ├── assets/                  # icônes / polices / sons
│   └── *.qml                    # 42 vues
├── quizzes/                     # Données CSV (+ plan.jpg)
├── utils/
│   ├── fileio.cpp
│   └── fileio.h
├── activities_loader.py
├── chargeur_matieres.py
├── chargeur_quiz.py
├── contact_loader.py
├── gestionnaire_wifi.py         # WifiManager (backend nmcli)
├── menu_loader.py
├── resident_contact_loader.py
├── resident_room_loader.py
├── test_capteurs_complet.py
└── .gitignore / .venv/
```

## 4) Modules (vue d’ensemble)

### 4.1 Contrôleurs (`controllers/`)

* `camera.py` — capture 640×480, détection visage, signaux `face_detected`, `camera_frame_ready`, calcul centre visage.
* `capteurs.py` — lecture IR/US, `compter_presences_ir()`, `obstacle_proche(seuil)`, `status_securite()`, QTimer 200 ms, signaux de défaillance.
* `moteurs_horizontaux.py` — `ajuster_rotation_horizontale(face_center_x, img_width)`, PD (Kp/Kd), deadband horizontale, timeouts.
* `moteurs_verticaux.py` — `center_on_face_y(face_center_y, img_height)`, deadband verticale, auto-stop.
* `parametres.py` — `SettingsController` (réglages IU actuels).
* `volume.py` / `luminosite.py` — services transverses IU.
* `wifi.py` — `WifiController` (exposé à QML).

### 4.2 Gestion Wi-Fi système

* `gestionnaire_wifi.py` — `WifiManager` (backend `nmcli`, utilisé par `WifiController`). Désactivation automatique hors Linux.

### 4.3 Chargeurs de données

* `chargeur_quiz.py` (`CSVQuizLoader`) — lecture CSV colonnes B→G, échantillonnage 10 questions.
* `chargeur_matieres.py` — mappage matières.
* `activities_loader.py`, `menu_loader.py` — activités/menus.
* `contact_loader.py`, `resident_contact_loader.py`, `resident_room_loader.py` — contacts/résidents/chambres.
* `CSVReaderSingleton` — accès commun CSV.

### 4.4 Interface QML (`ui/`)

* Entrée : `ui/main.qml` (plein écran, `Style.qml`).
* Accès façade : `robotFacade` (contexte injecté par `main.py`).
* Pages : Accueil, **Visiteur** (11 catégories, 4 verrouillées), **Résident** (9 catégories), Quiz (ex. `MathsQuizPage.qml`), Jeux (`MemoryCardsPage.qml`, `SimonSaysPage.qml`, `ColorSequencePage.qml`), Utilitaires (`ActivitiesPage.qml`, `MenuPage.qml`, `PlanPage.qml`, `ContactPage.qml`, `ResidentRoomPage.qml`, `ResidentContactPage.qml`, `WifiPage.qml`, `SettingsPage.qml`).

## 5) Données & formats

### 5.1 Quiz CSV

* Délimiteur `;` (UTF-8 recommandé). Colonnes B→G :
  **B** `question` · **C** `reponse_correcte` · **D/E/F/G** `choix`.

```csv
id;question;reponse_correcte;choix1;choix2;choix3;choix4;difficulte;anecdote
1;Combien font 2+2?;4;3;4;5;6;facile;Addition simple
```

### 5.2 Dossiers

* `quizzes/` — 13 CSV + `plan.jpg`.
* `ui/assets/` — icônes/polices/sons.

## 6) Installation

### 6.1 Prérequis

* Python 3.8+ ; Raspberry Pi OS (ou Linux).
* Optionnel robotique : PiCamera2, gpiozero/pigpio.
* Wi-Fi système : `nmcli` côté OS.

### 6.2 Environnement & dépendances

```bash
python -m venv .venv
# Linux/Mac
source .venv/bin/activate
# Windows
.venv\Scripts\activate
pip install -U PySide6 opencv-python numpy
# Optionnel (Raspberry Pi) :
pip install gpiozero picamera2
```

## 7) Exécution

```bash
python main.py
```

* Windows/macOS : Wi-Fi système désactivé automatiquement (info console).
* Caméra absente : **mode simulation** (visage simulé) activé.

## 8) Navigation (IU)

* Accueil → `SeniorHomePage`.
* Mode **Visiteur** → `VisiteurPage.qml` (11 catégories).
* Mode **Résident** → `ResidentPage.qml` (9 catégories).
* Bouton **JOUER** → `PlayPage.qml` (âge global).
* Ex. appel QML :

```qml
Button {
  text: "Démarrer robot"
  onClicked: robotFacade.start_robot_system()
}
```

## 9) Dépannage (FAQ)

* **PySide6 introuvable** : activer venv + `pip install PySide6`.
* **Wi-Fi inactif** : vérifier Linux + `nmcli`.
* **CSV non lus** : vérifier chemin/encodage/délimiteur `;`.
* **Caméra absente** : le mode simulation s’active (message console).

## 10) Développement

* Styles : `ui/Style.qml`.
* Ajouter un quiz : créer `quizzes/<matiere>.csv` (B→G), mapper dans `chargeur_matieres.py`, réutiliser `GenericQuizPage.qml` ou vue dédiée.
* Extension robotique : implémenter moteurs **translation** et brancher `RobotFacade._approach_target_distance()`.

## 11) Licence & crédits

* **Licence** : MIT
* **Crédits** : communauté Qt/QML, test utilisateurs, contributeurs.

---

### ✅ Couverture : c’est bon

* Objectifs/périmètre ✔️
* Architecture & façade ✔️
* Structure projet ✔️
* Modules & IU ✔️
* Données & formats ✔️
* Install, run, navigation, dépannage, dev, licence ✔️

### 🔧 (Optionnel) Petits plus “pro”

* **Paramètres par défaut** (tableau rapide) : deadbands, cibles (x/y), temps QTimer, tailles échantillon quiz, etc.
* **Journalisation** : préciser que `print()` est utilisé (ou basculer vers `logging`).
* **Tests/CI** : mention courte `pytest` + scénario de test (`test_capteurs_complet.py`).
* **Données & confidentialité** : où sont lus/écrits les CSV, accès en lecture seule, pas de données sensibles persistées.

Si tu veux, je peux ajouter **un mini tableau des paramètres par défaut** (vision/moteurs/IU) et une **section “Logs & Tests”** en 6 lignes pour finaliser la touche pro.
