import os
import csv
import random
from PySide6.QtCore import QObject, Slot, Signal

class CSVQuizLoader(QObject):
    """Classe pour charger les questions de quiz à partir de fichiers CSV"""
    
    questionsLoaded = Signal(list)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.questions = []
    
    @Slot(str, int, result="QVariantList")
    def loadQuestions(self, subject, age):
        """Charge les questions depuis un fichier CSV"""
        # Chemin du dossier quizzes
        quizzes_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "quizzes")
        csv_filename = f"{subject}.csv"
        file_path = os.path.join(quizzes_dir, csv_filename)
        
        if not os.path.exists(file_path):
            print(f"Erreur: Le fichier {file_path} n'existe pas")
            return []
        
        try:
            questions = self._readCSVFile(file_path)
            
            if not questions:
                return []
            
            # Sélectionner 10 questions aléatoires
            if len(questions) > 10:
                questions = random.sample(questions, 10)
            
            self.questions = questions
            self.questionsLoaded.emit(self.questions)
            return self.questions
            
        except Exception as e:
            print(f"Erreur lors du chargement des questions: {e}")
            return []
    
    def _readCSVFile(self, file_path):
        """Lit un fichier CSV et extrait les questions"""
        questions = []
        
        try:
            with open(file_path, encoding="utf-8") as csvfile:
                reader = csv.reader(csvfile, delimiter=";", quotechar='"')
                next(reader)  # Ignorer l'en-tête
                
                for row_num, row in enumerate(reader, 1):
                    if len(row) < 6:  # Besoin d'au moins 6 colonnes
                        continue
                    
                    question_text = row[1].strip()  # Colonne B
                    correct_answer = row[2].strip()  # Colonne C
                    
                    if not question_text or not correct_answer:
                        continue
                    
                    # Récupérer les 4 choix depuis les colonnes D, E, F, G
                    choices = []
                    for idx in [3, 4, 5, 6]:
                        if idx < len(row) and row[idx].strip():
                            choices.append(row[idx].strip())
                    
                    if len(choices) < 2:
                        continue
                    
                    # Mélanger les choix
                    random.shuffle(choices)
                    
                    questions.append({
                        'id': str(row_num),
                        'question': question_text,
                        'answers': choices,
                        'correct': correct_answer,
                        'anecdote': ""
                    })
            
            return questions
            
        except Exception as e:
            print(f"Erreur lors de la lecture du fichier CSV: {e}")
            return []
    
