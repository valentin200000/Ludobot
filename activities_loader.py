import os
import csv
import subprocess
from PySide6.QtCore import QObject, Signal, Slot

class ActivitiesLoader(QObject):
    """Classe pour charger les activités depuis un fichier CSV"""
    
    # Signal émis lorsque les activités sont chargées
    activitiesLoaded = Signal(list)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        print("ActivitiesLoader initialisé")
    
    @Slot(str, result=list)
    def loadActivities(self, day):
        """Charge les activités pour un jour donné depuis le fichier CSV"""
        try:
            # Chemin du fichier CSV des activités
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "activities.csv")
            print(f"Chargement des activités depuis {csv_path} pour {day}")
            
            # Vérifier que le fichier existe
            if not os.path.exists(csv_path):
                print(f"Erreur: Le fichier {csv_path} n'existe pas")
                return []
            
            # Lire le fichier CSV
            activities = []
            with open(csv_path, encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                
                for row in reader:
                    if row["Jour"].lower() == day.lower():
                        activity = {
                            "heure": row["Heure"],
                            "activite": row["Activité"],
                            "lieu": row["Lieu"]
                        }
                        activities.append(activity)
                        print(f"Activité ajoutée: {row['Heure']}, {row['Activité']}, {row['Lieu']}")
            
            # Trier par heure
            activities.sort(key=lambda x: x["heure"])
            print(f"Nombre total d'activités chargées pour {day}: {len(activities)}")
            
            # Émettre le signal avec les activités chargées
            self.activitiesLoaded.emit(activities)
            
            return activities
                
        except Exception as e:
            print(f"Erreur lors du chargement des activités: {e}")
            return []
    
    @Slot()
    def openCSVEditor(self):
        """Ouvre le fichier CSV des activités dans un éditeur externe"""
        try:
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "activities.csv")
            print(f"Ouverture du fichier CSV: {csv_path}")
            
            # Vérifier si on est sur Linux (probablement Raspberry Pi)
            if os.name == 'posix':
                # Essayer d'ouvrir avec xdg-open (Linux)
                subprocess.Popen(["xdg-open", csv_path])
            else:
                # Fallback pour d'autres systèmes
                os.startfile(csv_path)
                
            return True
        except Exception as e:
            print(f"Erreur lors de l'ouverture du fichier CSV: {e}")
            return False
