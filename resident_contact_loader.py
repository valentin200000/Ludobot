import os
import csv
import subprocess
from PySide6.QtCore import QObject, Slot, Signal, Property

class ResidentContactLoader(QObject):
    """Classe pour charger les contacts des résidents depuis un fichier CSV"""
    
    # Signal émis lorsque les contacts sont chargés
    contactsLoaded = Signal(list)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        print("ResidentContactLoader initialisé")
    
    @Slot(result=list)
    def loadContacts(self):
        """Charge tous les contacts depuis le fichier CSV"""
        try:
            # Chemin du fichier CSV des contacts
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "resident_contacts.csv")
            print(f"Chargement des contacts résidents depuis {csv_path}")
            
            # Vérifier que le fichier existe
            if not os.path.exists(csv_path):
                print(f"Erreur: Le fichier {csv_path} n'existe pas")
                return []
            
            # Lire le fichier CSV
            contacts = []
            with open(csv_path, encoding="utf-8") as csvfile:
                reader = csv.reader(csvfile, delimiter=',')
                next(reader)  # Ignorer l'en-tête
                
                for row in reader:
                    if len(row) >= 4:
                        contact = {
                            "service": row[0],
                            "profession": row[1],
                            "nom": row[2],
                            "telephone": row[3]
                        }
                        contacts.append(contact)
                        print(f"Contact résident ajouté: {row[0]}, {row[1]}, {row[2]}, {row[3]}")
            
            print(f"Nombre total de contacts résidents chargés: {len(contacts)}")
            
            # Émettre le signal avec les contacts chargés
            self.contactsLoaded.emit(contacts)
            
            return contacts
                
        except Exception as e:
            print(f"Erreur lors du chargement des contacts résidents: {e}")
            return []
    
    @Slot()
    def openCSVEditor(self):
        """Ouvre le fichier CSV des contacts dans un éditeur externe"""
        try:
            csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes", "resident_contacts.csv")
            print(f"Ouverture du fichier CSV des résidents: {csv_path}")
            
            # Vérifier si on est sur Linux (probablement Raspberry Pi)
            if os.name == 'posix':
                # Essayer d'ouvrir avec xdg-open (Linux)
                subprocess.Popen(["xdg-open", csv_path])
            else:
                # Fallback pour d'autres systèmes
                os.startfile(csv_path)
                
            return True
        except Exception as e:
            print(f"Erreur lors de l'ouverture du fichier CSV des résidents: {e}")
            return False
