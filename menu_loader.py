import csv
import os
from PySide6.QtCore import QObject, Signal, Slot

class MenuLoader(QObject):
    """Classe pour charger les menus depuis le fichier CSV"""
    
    # Signal émis quand les menus sont chargés
    menusLoaded = Signal(list)
    
    def __init__(self):
        super().__init__()
        self.menus = []
    
    @Slot(str, result=list)
    def loadMenus(self, day):
        """Charge les menus pour un jour donné depuis le fichier CSV"""
        try:
            # Chemin vers le fichier CSV des menus
            script_dir = os.path.dirname(os.path.abspath(__file__))
            csv_file = os.path.join(script_dir, "quizzes", "menu.csv")
            
            
            if not os.path.exists(csv_file):
                print(f"ERREUR: Le fichier {csv_file} n'existe pas")
                return []
            
            menus_du_jour = []
            
            with open(csv_file, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file, delimiter=';')
                
                for row in reader:
                    if row['Jour'].strip().lower() == day.lower():
                        menu = {
                            'jour': row['Jour'].strip(),
                            'heure': row['Heure'].strip(),
                            'type': row['Type'].strip(),
                            'plat': row['Plat'].strip()
                        }
                        menus_du_jour.append(menu)
            
            
            # Émettre le signal avec les menus chargés
            self.menusLoaded.emit(menus_du_jour)
            
            return menus_du_jour
            
        except Exception as e:
            print(f"ERREUR MenuLoader - Erreur lors du chargement des menus: {e}")
            return []
    
    @Slot()
    def openCSVEditor(self):
        """Ouvre l'éditeur de fichier CSV pour les menus"""
        try:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            csv_file = os.path.join(script_dir, "quizzes", "menu.csv")
            
            # Ouvrir le fichier avec l'éditeur par défaut du système
            import subprocess
            import platform
            
            if platform.system() == "Windows":
                os.startfile(csv_file)
            elif platform.system() == "Darwin":  # macOS
                subprocess.run(["open", csv_file])
            else:  # Linux
                subprocess.run(["xdg-open", csv_file])
                
            
        except Exception as e:
            print(f"ERREUR MenuLoader - Impossible d'ouvrir l'éditeur: {e}")
