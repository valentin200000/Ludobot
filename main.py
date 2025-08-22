import sys
import os
import csv
import random
from pathlib import Path
from PySide6.QtCore import QObject, Slot, QUrl, Property, Signal
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine, QmlElement, QmlSingleton
# Utiliser les contrôleurs avec des noms simples
from controllers.parametres import SettingsController
from controllers.wifi import WifiController
from controllers.volume import VolumeController
from controllers.luminosite import BrightnessController
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

def main():
    app = QGuiApplication(sys.argv)
    
    # Set application name and organization
    app.setApplicationName("LudoBot")
    app.setOrganizationName("LudoBot")
    app.setOrganizationDomain("ludobot.org")
    
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    
    # Créer l'instance du lecteur CSV et l'exposer au contexte QML
    csv_reader = CSVReaderSingleton()
    settings_controller = SettingsController()
    wifi_controller = WifiController()  # Utiliser le contrôleur WiFi du dossier controllers
    volume_controller = VolumeController()  # Créer l'instance du contrôleur de volume
    brightness_controller = BrightnessController()  # Créer l'instance du contrôleur de luminosité
    csv_quiz_loader = CSVQuizLoader()  # Créer l'instance du nouveau chargeur CSV
    subject_loader = SubjectLoader()  # Créer l'instance du chargeur de matières
    contact_loader = ContactLoader()
    resident_contact_loader = ResidentContactLoader()
    resident_room_loader = ResidentRoomLoader()
    activities_loader = ActivitiesLoader()
    menu_loader = MenuLoader()
    
    engine = QQmlApplicationEngine()
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file = os.path.join(current_dir, "ui/main.qml")
    
    engine.rootContext().setContextProperty("settingsController", settings_controller)
    engine.rootContext().setContextProperty("wifiController", wifi_controller)
    engine.rootContext().setContextProperty("volumeController", volume_controller)  # Exposer le contrôleur de volume
    engine.rootContext().setContextProperty("brightnessController", brightness_controller)  # Exposer le contrôleur de luminosité
    engine.rootContext().setContextProperty("csvReader", csv_reader)
    engine.rootContext().setContextProperty("csvQuizLoader", csv_quiz_loader)  # Exposer le nouveau chargeur CSV
    engine.rootContext().setContextProperty("subjectLoader", subject_loader)  # Exposer le chargeur de matières
    engine.rootContext().setContextProperty("contactLoader", contact_loader)
    engine.rootContext().setContextProperty("residentContactLoader", resident_contact_loader)
    engine.rootContext().setContextProperty("residentRoomLoader", resident_room_loader)
    engine.rootContext().setContextProperty("activitiesLoader", activities_loader)  # Exposer le chargeur d'activités
    engine.rootContext().setContextProperty("menuLoader", menu_loader)  # Exposer le chargeur de menus
    
    engine.load(QUrl.fromLocalFile(qml_file))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())