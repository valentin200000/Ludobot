import os
import csv
from PySide6.QtCore import QObject, Slot, Signal

class ResidentRoomLoader(QObject):
    """Classe pour chercher les informations de chambre des résidents"""
    
    # Signal émis lorsqu'une chambre est trouvée
    roomFound = Signal(str, str, str, str)  # nom, batiment, etage, chambre
    
    def __init__(self, parent=None):
        super().__init__(parent)
        print("ResidentRoomLoader initialisé")
    
    @Slot(str, result=bool)
    def searchRoom(self, nom):
        """Recherche la chambre d'un résident par son nom"""
        try:
            # Chemin du fichier CSV des chambres
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "resident_rooms.csv")
            print(f"Recherche de la chambre pour {nom}")
            
            # Vérifier que le fichier existe
            if not os.path.exists(csv_path):
                print(f"Erreur: Le fichier {csv_path} n'existe pas")
                return False
            
            # Lire le fichier CSV
            with open(csv_path, encoding="utf-8") as csvfile:
                reader = csv.reader(csvfile, delimiter=',')
                next(reader)  # Ignorer l'en-tête
                
                # Rechercher le résident
                for row in reader:
                    if len(row) >= 4 and row[0].lower() == nom.lower():
                        print(f"Résident trouvé: {row[0]}, Bâtiment {row[1]}, Étage {row[2]}, Chambre {row[3]}")
                        # Émettre le signal avec les informations trouvées
                        self.roomFound.emit(row[0], row[1], row[2], row[3])
                        return True
            
            print(f"Aucun résident trouvé avec le nom: {nom}")
            return False
                
        except Exception as e:
            print(f"Erreur lors de la recherche du résident: {e}")
            return False
            
    @Slot()
    def openCSVEditor(self):
        """Ouvre le fichier CSV des chambres dans un éditeur externe"""
        try:
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "resident_rooms.csv")
            print(f"Ouverture du fichier {csv_path}")
            
            # Vérifier que le fichier existe
            if not os.path.exists(csv_path):
                print(f"Erreur: Le fichier {csv_path} n'existe pas")
                return
            
            # Ouvrir le fichier avec l'éditeur par défaut selon l'OS
            if os.name == 'nt':  # Windows
                os.startfile(csv_path)
            else:  # Linux/Mac
                import subprocess
                subprocess.run(['xdg-open', csv_path])  # Linux
                
        except Exception as e:
            print(f"Erreur lors de l'ouverture du fichier CSV: {e}")
            
    @Slot()
    def loadRooms(self):
        """Recharge la liste des chambres depuis le fichier CSV"""
        try:
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "resident_rooms.csv")
            print(f"Rechargement du fichier {csv_path}")
            
            # Vérifier que le fichier existe
            if not os.path.exists(csv_path):
                print(f"Erreur: Le fichier {csv_path} n'existe pas")
                return
            
            # Rien à faire de plus car les chambres sont rechargées à chaque recherche
            print("Fichier des chambres rechargé avec succès")
                
        except Exception as e:
            print(f"Erreur lors du rechargement du fichier CSV: {e}")
