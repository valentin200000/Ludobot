import time
import threading
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
try:
    import RPi.GPIO as GPIO
    GPIO_AVAILABLE = True
except ImportError:
    GPIO_AVAILABLE = False
    print("RPi.GPIO non disponible - Mode simulation activé")

class CapteursController(QObject):
    """Contrôleur pour les capteurs infrarouge et ultrason du robot"""
    
    # Signaux pour notifier les changements
    infrarouge_changed = Signal()
    ultrason_changed = Signal()
    capteurs_data_changed = Signal()
    capteur_defaillant = Signal(str)  # Signal émis quand un capteur ne répond pas
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Configuration GPIO des capteurs infrarouge
        self.IR_PINS = {
            'gauche': 16,
            'centre': 21, 
            'droite': 20
        }
        
        # Configuration GPIO des capteurs ultrason (trig/echo)
        self.ULTRASON_PINS = {
            'arriere': {'trig': 4, 'echo': 17},
            'droite': {'trig': 6, 'echo': 5},
            'centre': {'trig': 26, 'echo': 19},
            'gauche': {'trig': 25, 'echo': 18}
        }
        
        # Données des capteurs
        self._infrarouge_data = {
            'gauche': False,
            'centre': False,
            'droite': False
        }
        
        self._ultrason_data = {
            'arriere': 0.0,
            'droite': 0.0,
            'centre': 0.0,
            'gauche': 0.0
        }
        
        # Suivi des capteurs défaillants
        self._capteurs_defaillants = []
        self._derniere_lecture_ir = {}
        self._derniere_lecture_us = {}
        self._timeout_capteur = 5.0  # 5 secondes sans réponse = défaillant
        
        # Timer pour lecture périodique
        self._timer = QTimer()
        self._timer.timeout.connect(self.lire_tous_capteurs)
        
        # Initialiser GPIO si disponible
        if GPIO_AVAILABLE:
            self._init_gpio()
        
        # Démarrer la lecture automatique (toutes les 200ms)
        self._timer.start(200)
    
    def _init_gpio(self):
        """Initialise la configuration GPIO"""
        try:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            
            # Configuration des capteurs infrarouge (INPUT avec pull-up)
            for pin in self.IR_PINS.values():
                GPIO.setup(pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            
            # Configuration des capteurs ultrason
            for capteur in self.ULTRASON_PINS.values():
                GPIO.setup(capteur['trig'], GPIO.OUT)
                GPIO.setup(capteur['echo'], GPIO.IN)
                # Initialiser trig à LOW
                GPIO.output(capteur['trig'], False)
            
            print("GPIO initialisé avec succès")
            
        except Exception as e:
            print(f"Erreur lors de l'initialisation GPIO: {e}")
    
    @Property('QVariantMap', notify=infrarouge_changed)
    def infrarouge_data(self):
        """Retourne les données des capteurs infrarouge"""
        return self._infrarouge_data
    
    @Property('QVariantMap', notify=ultrason_changed)
    def ultrason_data(self):
        """Retourne les données des capteurs ultrason"""
        return self._ultrason_data
    
    @Slot()
    def lire_tous_capteurs(self):
        """Lit tous les capteurs et met à jour les données"""
        self.lire_capteurs_infrarouge()
        self.lire_capteurs_ultrason()
        self.capteurs_data_changed.emit()
    
    @Slot()
    def lire_capteurs_infrarouge(self):
        """Lit les 3 capteurs infrarouge"""
        current_time = time.time()
        capteurs_ok = []
        
        if not GPIO_AVAILABLE:
            # Mode simulation
            import random
            for position in self._infrarouge_data.keys():
                self._infrarouge_data[position] = random.choice([True, False])
                self._derniere_lecture_ir[position] = current_time
                capteurs_ok.append(position)
        else:
            try:
                for position, pin in self.IR_PINS.items():
                    try:
                        # Les capteurs IR retournent LOW quand un objet est détecté
                        self._infrarouge_data[position] = not GPIO.input(pin)
                        self._derniere_lecture_ir[position] = current_time
                        capteurs_ok.append(position)
                    except Exception as e:
                        print(f"Erreur lecture capteur IR {position} (GPIO {pin}): {e}")
                        self._marquer_capteur_defaillant(f"IR_{position}")
            except Exception as e:
                print(f"Erreur lecture capteurs IR: {e}")
        
        # Vérifier les timeouts
        self._verifier_timeout_ir(current_time, capteurs_ok)
        self.infrarouge_changed.emit()
    
    @Slot()
    def lire_capteurs_ultrason(self):
        """Lit les 4 capteurs ultrason"""
        current_time = time.time()
        capteurs_ok = []
        
        if not GPIO_AVAILABLE:
            # Mode simulation
            import random
            for position in self._ultrason_data.keys():
                self._ultrason_data[position] = round(random.uniform(10.0, 200.0), 1)
                self._derniere_lecture_us[position] = current_time
                capteurs_ok.append(position)
        else:
            for position, pins in self.ULTRASON_PINS.items():
                try:
                    distance = self._mesurer_distance(pins['trig'], pins['echo'])
                    if distance < 999.0:  # Valeur valide
                        self._ultrason_data[position] = distance
                        self._derniere_lecture_us[position] = current_time
                        capteurs_ok.append(position)
                    else:
                        print(f"Capteur ultrason {position} timeout/erreur")
                        self._marquer_capteur_defaillant(f"US_{position}")
                except Exception as e:
                    print(f"Erreur capteur ultrason {position}: {e}")
                    self._marquer_capteur_defaillant(f"US_{position}")
        
        # Vérifier les timeouts
        self._verifier_timeout_us(current_time, capteurs_ok)
        self.ultrason_changed.emit()
    
    def _mesurer_distance(self, trig_pin, echo_pin):
        """Mesure la distance avec un capteur ultrason HC-SR04"""
        try:
            # Envoyer une impulsion de 10µs sur TRIG
            GPIO.output(trig_pin, True)
            time.sleep(0.00001)  # 10µs
            GPIO.output(trig_pin, False)
            
            # Mesurer le temps de l'écho
            timeout = time.time() + 0.1  # Timeout de 100ms
            
            # Attendre le début de l'impulsion ECHO
            while GPIO.input(echo_pin) == 0:
                pulse_start = time.time()
                if pulse_start > timeout:
                    return 999.9  # Timeout
            
            # Attendre la fin de l'impulsion ECHO
            while GPIO.input(echo_pin) == 1:
                pulse_end = time.time()
                if pulse_end > timeout:
                    return 999.9  # Timeout
            
            # Calculer la distance
            pulse_duration = pulse_end - pulse_start
            distance = pulse_duration * 17150  # Vitesse du son / 2
            distance = round(distance, 1)
            
            # Limiter la plage de mesure (2cm à 400cm)
            if distance < 2:
                distance = 2.0
            elif distance > 400:
                distance = 400.0
                
            return distance
            
        except Exception as e:
            print(f"Erreur mesure ultrason (trig:{trig_pin}, echo:{echo_pin}): {e}")
            return 999.9
    
    @Slot(result=int)
    def compter_presences_ir(self):
        """Compte le nombre de présences détectées par les capteurs IR"""
        return sum(1 for detected in self._infrarouge_data.values() if detected)
    
    @Slot(result=bool)
    def obstacle_proche(self, seuil=50.0):
        """Vérifie si un obstacle est détecté à moins de 'seuil' cm"""
        return any(distance < seuil for distance in self._ultrason_data.values() if distance < 999)
    
    @Slot(result=str)
    def status_securite(self):
        """Retourne le statut de sécurité global"""
        presences = self.compter_presences_ir()
        obstacle = self.obstacle_proche(50.0)
        
        if presences < 3:
            return "DANGER: Moins de 3 présences détectées"
        elif obstacle:
            return "ATTENTION: Obstacle proche détecté"
        else:
            return "SECURITE: OK"
    
    @Slot()
    def demarrer_surveillance(self):
        """Démarre la surveillance continue des capteurs"""
        if not self._timer.isActive():
            self._timer.start(200)
            print("Surveillance des capteurs démarrée")
    
    @Slot()
    def arreter_surveillance(self):
        """Arrête la surveillance des capteurs"""
        if self._timer.isActive():
            self._timer.stop()
            print("Surveillance des capteurs arrêtée")
    
    @Slot(result=bool)
    def detection_sonore_active(self):
        """Vérifie si au moins un capteur infrarouge détecte une présence (simulation détection sonore)"""
        return any(self._infrarouge_data.values())
    
    @Signal
    def son_detecte(self):
        """Signal émis quand un son/mouvement est détecté"""
        pass
    
    def _marquer_capteur_defaillant(self, capteur_id):
        """Marque un capteur comme défaillant"""
        if capteur_id not in self._capteurs_defaillants:
            self._capteurs_defaillants.append(capteur_id)
            self.capteur_defaillant.emit(capteur_id)
            print(f"⚠️ Capteur défaillant détecté: {capteur_id}")
    
    def _verifier_timeout_ir(self, current_time, capteurs_ok):
        """Vérifie les timeouts des capteurs infrarouge"""
        for position in self.IR_PINS.keys():
            if position not in capteurs_ok:
                last_time = self._derniere_lecture_ir.get(position, 0)
                if current_time - last_time > self._timeout_capteur:
                    self._marquer_capteur_defaillant(f"IR_{position}")
    
    def _verifier_timeout_us(self, current_time, capteurs_ok):
        """Vérifie les timeouts des capteurs ultrason"""
        for position in self.ULTRASON_PINS.keys():
            if position not in capteurs_ok:
                last_time = self._derniere_lecture_us.get(position, 0)
                if current_time - last_time > self._timeout_capteur:
                    self._marquer_capteur_defaillant(f"US_{position}")
    
    @Slot(result='QVariantList')
    def get_capteurs_defaillants(self):
        """Retourne la liste des capteurs défaillants"""
        return self._capteurs_defaillants
    
    @Slot()
    def reset_capteurs_defaillants(self):
        """Remet à zéro la liste des capteurs défaillants"""
        self._capteurs_defaillants.clear()
        print("Liste des capteurs défaillants remise à zéro")
    
    def __del__(self):
        """Nettoyage GPIO à la destruction"""
        if GPIO_AVAILABLE:
            try:
                GPIO.cleanup()
            except:
                pass
