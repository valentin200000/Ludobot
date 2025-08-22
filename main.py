import sys
import os
import csv
import random
import time
from pathlib import Path
from PySide6.QtCore import QObject, Slot, QUrl, Property, Signal, QTimer
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, QmlElement, QmlSingleton
# Utiliser les contrôleurs avec des noms simples
from controllers.parametres import SettingsController
from controllers.wifi import WifiController
from controllers.volume import VolumeController
from controllers.luminosite import BrightnessController
from controllers.capteurs import CapteursController
from controllers.camera import CameraController
from controllers.moteurs_horizontaux import MoteursHorizontauxController
from controllers.moteurs_verticaux import MoteursVerticauxController
# Suppression du RobotManager - main.py gère tout
from gestionnaire_wifi import WifiManager
from chargeur_quiz import CSVQuizLoader
from chargeur_matieres import SubjectLoader
from contact_loader import ContactLoader
from resident_contact_loader import ResidentContactLoader
from resident_room_loader import ResidentRoomLoader
from activities_loader import ActivitiesLoader  # Chargeur pour les activités
from menu_loader import MenuLoader  # Chargeur pour les menus

# Classe pour lire le fichier CSV directement
class CSVReaderSingleton(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        print("CSVReaderSingleton initialisé")
    
    @Slot(str, int, int, result=str)
    def readCellValue(self, filename, row, col):
        """Lit la valeur d'une cellule dans un fichier CSV"""
        try:
            # Chemin du dossier quizzes
            quizzes_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes")
            file_path = os.path.join(quizzes_dir, filename)
            
            print(f"Lecture du fichier CSV: {file_path}")
            print(f"Recherche de la valeur à la position [{row}][{col}]")
            
            # Vérifier que le fichier existe
            if not os.path.exists(file_path):
                print(f"Erreur: Le fichier {file_path} n'existe pas")
                return f"Fichier non trouvé: {filename}"
            
            # Lire le fichier CSV
            with open(file_path, encoding="ISO-8859-1") as csvfile:
                reader = csv.reader(csvfile, delimiter=";", quotechar="'")
                rows = list(reader)
                
                if row < len(rows) and col < len(rows[row]):
                    value = rows[row][col]
                    print(f"Valeur trouvée: {value}")
                    return value
                else:
                    return "Index hors limites"
                
        except Exception as e:
            print(f"Erreur lors de la lecture du fichier CSV: {e}")
            return f"Erreur: {str(e)}"
    
    @Slot(str, int, result="QVariantList")
    def loadQuestions(self, filename, age):
        """Charge les questions et réponses depuis un fichier CSV en fonction de l'âge"""
        try:
            # Chemin du dossier quizzes
            quizzes_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes")
            file_path = os.path.join(quizzes_dir, filename)
            
            print(f"Chargement des questions depuis {file_path} pour l'âge {age}")
            
            # Vérifier que le fichier existe
            if not os.path.exists(file_path):
                print(f"Erreur: Le fichier {file_path} n'existe pas")
                return []
            
            # Utiliser directement les colonnes B, C, D, E, F, G pour toutes les questions
            # B (indice 1) pour les questions
            # C (indice 2) pour les bonnes réponses
            # D, E, F, G (indices 3, 4, 5, 6) pour les propositions de réponses
            question_index = 1  # Colonne B
            answer_index = 2    # Colonne C
            choices_indices = [3, 4, 5, 6]  # Colonnes D, E, F, G
            
            print(f"Indices utilisés pour l'âge {age}:")
            print(f"  - question_index: {question_index}")
            print(f"  - answer_index: {answer_index}")
            print(f"  - choices_indices: {choices_indices}")
            
            questions = []
            
            # Lire le fichier CSV
            with open(file_path, encoding="ISO-8859-1") as csvfile:
                reader = csv.reader(csvfile, delimiter=";", quotechar="'")
                next(reader)  # Ignorer l'en-tête
                
                for row_num, item in enumerate(reader, 1):
                    if len(item) <= max(question_index, answer_index):
                        print(f"Ligne {row_num} ignorée car pas assez de colonnes: {len(item)}")
                        continue
                    
                    # Vérifier que la question et la réponse ne sont pas vides
                    if not item[question_index] or not item[answer_index]:
                        print(f"Ligne {row_num} ignorée car question ou réponse vide")
                        continue
                    
                    # Récupérer les choix non vides
                    choices = []
                    for idx in choices_indices:
                        if idx < len(item) and item[idx]:
                            choices.append(item[idx])
                    
                    # S'assurer que la réponse correcte est dans les choix
                    correct_answer = item[answer_index]
                    if correct_answer not in choices:
                        choices.insert(0, correct_answer)
                    
                    # S'assurer qu'il y a au moins 2 choix
                    while len(choices) < 2:
                        choices.append(f"Option {len(choices)+1}")
                    
                    # Mélanger les réponses pour plus de difficulté
                    import random
                    random.shuffle(choices)
                    
                    q = {
                        'id': str(row_num),
                        'question': item[question_index],
                        'answers': choices,
                        'correct': correct_answer,
                        'anecdote': ""
                    }
                    questions.append(q)
                    print(f"Question ajoutée: {q['question']}")
                    print(f"  - Réponse correcte: {q['correct']}")
                    print(f"  - Options: {q['answers']}")
            
            # Sélectionner 10 questions aléatoires (ou toutes si moins de 10)
            if len(questions) > 10:
                import random
                questions = random.sample(questions, 10)
                print(f"Sélection de 10 questions aléatoires parmi {len(questions)} disponibles")
            
            print(f"Nombre de questions chargées: {len(questions)}")
            return questions
                
        except Exception as e:
            print(f"Erreur lors du chargement des questions: {e}")
            return []

# Pattern Façade - Interface simplifiée pour le système robotique
class RobotFacade(QObject):
    """Façade qui masque la complexité des interactions entre contrôleurs"""
    
    # Signaux simplifiés pour l'interface
    system_ready = Signal()
    error_occurred = Signal(str)
    user_interface_active = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Initialiser tous les contrôleurs (complexité masquée)
        self._init_controllers()
        
        # État interne simplifié
        self._system_active = False
        self._safety_timer = None
    
    def _init_controllers(self):
        """Initialise tous les contrôleurs - complexité masquée de l'utilisateur"""
        # Contrôleurs de données
        self._csv_reader = CSVReaderSingleton()
        self._csv_quiz_loader = CSVQuizLoader()
        self._subject_loader = SubjectLoader()
        self._contact_loader = ContactLoader()
        self._resident_contact_loader = ResidentContactLoader()
        self._resident_room_loader = ResidentRoomLoader()
        self._activities_loader = ActivitiesLoader()
        self._menu_loader = MenuLoader()
        
        # Contrôleurs système
        self._settings_controller = SettingsController()
        self._wifi_controller = WifiController()
        self._volume_controller = VolumeController()
        self._brightness_controller = BrightnessController()
        
        # Contrôleurs robotiques
        self._capteurs_controller = CapteursController()
        self._camera_controller = CameraController()
        self._moteurs_horizontaux_controller = MoteursHorizontauxController()
        # Contrôleurs manquants pour étapes 9-11 (simulation)
        self._moteurs_translation_controller = None  # À implémenter
        self._moteurs_verticaux_controller = MoteursVerticauxController()    # Contrôleur vérin vertical
        
        print("Façade robotique initialisée")
    
    @Slot()
    def start_robot_system(self):
        """Interface simplifiée pour démarrer le robot complet"""
        print("Démarrage du système robotique")
        
        if self._verify_all_systems():
            if self._find_and_track_user():
                if self._approach_target_distance():
                    if self._vertical_adjustment():
                        self._activate_user_interface()
                        self._start_safety_monitoring()
                        self.system_ready.emit()
                        print("🎯 Cycle complet des 14 étapes terminé avec succès")
                    else:
                        self.error_occurred.emit("Échec réglage vertical")
                else:
                    self.error_occurred.emit("Échec approche distance cible")
            else:
                self.error_occurred.emit("Impossible de détecter l'utilisateur")
        else:
            self.error_occurred.emit("Vérification système échouée")
    
    def _verify_all_systems(self):
        """Vérifie tous les systèmes - complexité masquée"""
        print("Vérification des systèmes...")
        
        # Vérification capteurs
        sensors_ok = (self._capteurs_controller.lire_capteurs_infrarouge() and 
                     self._capteurs_controller.lire_capteurs_ultrason())
        
        # Vérification caméra
        camera_ok = self._camera_controller._init_camera()
        
        # Vérification stabilité
        stability_ok = self._capteurs_controller.compter_presences_ir() >= 2
        
        if not sensors_ok:
            print("Erreur capteurs détectée")
            return False
        
        if not camera_ok:
            print("Erreur caméra détectée")
            return False
            
        if not stability_ok:
            print("Robot instable - reposer le robot")
            return False
        
        print("Tous les systèmes fonctionnels")
        return True
    
    def _find_and_track_user(self):
        """Trouve et suit l'utilisateur - interface simplifiée"""
        print("Recherche et suivi utilisateur...")
        
        # Recherche de visage avec rotation automatique
        attempts = 0
        max_attempts = 5
        
        while attempts < max_attempts:
            if self._camera_controller._detect_face():
                print("Visage détecté")
                break
            
            print(f"Tentative {attempts + 1}: Rotation de recherche")
            self._moteurs_horizontaux_controller.tourner_gauche()
            time.sleep(2)
            self._moteurs_horizontaux_controller.arreter_moteurs()
            attempts += 1
        
        if attempts >= max_attempts:
            print("Aucun utilisateur détecté après recherche")
            return False
        
        # Centrage automatique
        return self._center_on_user()
    
    def _center_on_user(self):
        """Centre le robot sur l'utilisateur - complexité masquée"""
        print("Centrage sur l'utilisateur...")
        
        # Récupération des données visuelles
        face_data = self._camera_controller._process_face_detection()
        if not face_data or not self._camera_controller._validate_face_data():
            print("Données visuelles invalides")
            return False
        
        # Centrage horizontal automatique
        face_x = getattr(self._camera_controller, '_face_x', 320)
        
        if face_x < 280:  # Visage à gauche
            print("Correction vers la droite")
            self._moteurs_horizontaux_controller.tourner_droite()
            time.sleep(0.5)
            self._moteurs_horizontaux_controller.arreter_moteurs()
        elif face_x > 360:  # Visage à droite
            print("Correction vers la gauche")
            self._moteurs_horizontaux_controller.tourner_gauche()
            time.sleep(0.5)
            self._moteurs_horizontaux_controller.arreter_moteurs()
        
        print("Centrage terminé")
        return True
    
    def _approach_target_distance(self):
        """Étapes 9-10: Approche à distance cible (50cm) + positionnement précis"""
        print("Étapes 9-10: Approche à distance cible...")
        
        # Simulation de l'approche (à remplacer par vrais contrôleurs)
        if self._moteurs_translation_controller is None:
            print("⚠️ Simulation étape 9: Approche à 50cm (moteurs translation non implémentés)")
            # Logique simulée d'approche
            target_distance = 50  # cm
            current_distance = getattr(self._camera_controller, '_face_distance', 100)
            
            print(f"Distance actuelle: {current_distance}cm, cible: {target_distance}cm")
            
            # Vérification obstacles avec capteurs ultrason
            if self._capteurs_controller.obstacle_proche():
                print("Obstacle détecté - Arrêt sécuritaire")
                return False
            
            # Simulation déplacement vers cible
            print("Simulation: Déplacement vers distance cible...")
            time.sleep(1)  # Simulation temporelle
            
            print("Étape 10: Positionnement précis terminé")
            return True
        else:
            # Code réel avec contrôleurs (à implémenter)
            # return self._moteurs_translation_controller.approach_distance(50)
            pass
    
    def _vertical_adjustment(self):
        """Étape 11: Réglage vertical (pont en H + vérin électrique)"""
        print("Étape 11: Réglage vertical...")
        
        # Utilisation réelle du contrôleur vérin vertical s'il est disponible
        if self._moteurs_verticaux_controller is not None:
            # Récupération position Y du visage
            face_y = getattr(self._camera_controller, '_face_y', 240)
            img_h = 480  # Caméra configurée en 640x480
            print(f"Réglage vertical: face_y={face_y}, img_h={img_h}")
            # Ajustement discret vers le centre
            self._moteurs_verticaux_controller.center_on_face_y(face_y, img_h)
            # Laisser le temps au step d'opérer
            time.sleep(0.3)
            self._moteurs_verticaux_controller.arreter()
            print("Centrage vertical terminé")
            return True
        
        # Fallback si non disponible
        print("⚠️ Contrôleur vérin vertical indisponible - étape simulée")
        return True
    
    def _activate_user_interface(self):
        """Étape 13: Interface utilisateur active"""
        print("Étape 13: Activation de l'interface utilisateur")
        self.user_interface_active.emit()
        print("Étape 14: Système prêt - Interface utilisateur active")
    
    def _start_safety_monitoring(self):
        """Étape 12: Activation des fonctions permanentes + surveillance sécuritaire"""
        print("Étape 12: Activation des fonctions permanentes")
        print("Démarrage surveillance sécuritaire continue")
        self._system_active = True
        self._safety_timer = QTimer()
        self._safety_timer.timeout.connect(self._check_safety)
        self._safety_timer.start(100)  # Vérification toutes les 100ms
    
    def _check_safety(self):
        """Surveillance sécuritaire continue - complexité masquée"""
        if not self._system_active:
            return
        
        # Vérification stabilité robot
        nb_capteurs = self._capteurs_controller.compter_presences_ir()
        if nb_capteurs < 2:
            print("ARRÊT D'URGENCE - Robot instable")
            self._emergency_stop()
            self.error_occurred.emit("Reposer le robot pour continuer")
    
    def _emergency_stop(self):
        """Arrêt d'urgence - interface simplifiée"""
        self._moteurs_horizontaux_controller.arreter_moteurs()
        self._system_active = False
        if self._safety_timer:
            self._safety_timer.stop()
        print("Arrêt d'urgence activé")
    
    # Propriétés exposées pour QML (interface simplifiée)
    @Property(QObject, constant=True)
    def settings(self):
        return self._settings_controller
    
    @Property(QObject, constant=True)
    def wifi(self):
        return self._wifi_controller
    
    @Property(QObject, constant=True)
    def volume(self):
        return self._volume_controller
    
    @Property(QObject, constant=True)
    def brightness(self):
        return self._brightness_controller
    
    @Property(QObject, constant=True)
    def csv_reader(self):
        return self._csv_reader
    
    @Property(QObject, constant=True)
    def quiz_loader(self):
        return self._csv_quiz_loader
    
    @Property(QObject, constant=True)
    def contact_loader(self):
        return self._contact_loader
    
    @Property(QObject, constant=True)
    def resident_contact_loader(self):
        return self._resident_contact_loader
    
    @Property(QObject, constant=True)
    def activities_loader(self):
        return self._activities_loader
    
    @Property(QObject, constant=True)
    def menu_loader(self):
        return self._menu_loader

def main():
    app = QGuiApplication(sys.argv)
    
    # Set application name and organization
    app.setApplicationName("LudoBot")
    app.setOrganizationName("LudoBot")
    app.setOrganizationDomain("ludobot.org")
    
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    
    # Créer la façade robotique (Pattern Façade)
    robot_facade = RobotFacade()
    
    engine = QQmlApplicationEngine()
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file = os.path.join(current_dir, "ui/main.qml")
    
    # Exposer uniquement la façade - interface simplifiée
    engine.rootContext().setContextProperty("robotFacade", robot_facade)
    # Accès aux contrôleurs via la façade (encapsulation)
    engine.rootContext().setContextProperty("settingsController", robot_facade.settings)
    engine.rootContext().setContextProperty("wifiController", robot_facade.wifi)
    engine.rootContext().setContextProperty("volumeController", robot_facade.volume)
    engine.rootContext().setContextProperty("brightnessController", robot_facade.brightness)
    engine.rootContext().setContextProperty("csvReader", robot_facade.csv_reader)
    engine.rootContext().setContextProperty("csvQuizLoader", robot_facade.quiz_loader)
    engine.rootContext().setContextProperty("contactLoader", robot_facade.contact_loader)
    engine.rootContext().setContextProperty("residentContactLoader", robot_facade.resident_contact_loader)
    engine.rootContext().setContextProperty("activitiesLoader", robot_facade.activities_loader)
    engine.rootContext().setContextProperty("menuLoader", robot_facade.menu_loader)
    
    engine.load(QUrl.fromLocalFile(qml_file))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())