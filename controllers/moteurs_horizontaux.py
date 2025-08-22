import time
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

try:
    import RPi.GPIO as GPIO
    GPIO_AVAILABLE = True
except ImportError:
    GPIO_AVAILABLE = False
    print("RPi.GPIO non disponible - Mode simulation moteurs horizontaux")

class MoteursHorizontauxController(QObject):
    """Contrôleur pour les moteurs de rotation horizontale avec pont en H"""
    
    # Signaux
    rotation_changed = Signal()
    moteurs_state_changed = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Configuration GPIO du pont en H (selon votre mapping)
        self.PONT_H_PINS = {
            'int1': 27,    # GPIO 27 - Int 1 pont h
            'int2': 22,    # GPIO 22 - Int 2 pont h  
            'int3': 23,    # GPIO 23 - Int 3 pont h
            'int4': 24,    # GPIO 24 - Int 4 pont h
            'ena': 13,     # GPIO 13 - Ena pont h (PWM moteur A)
            'enb': 12      # GPIO 12 - Enb pont h (PWM moteur B)
        }
        
        # Paramètres de contrôle
        self.PWM_FREQUENCY = 1000  # 1kHz pour PWM
        self.MAX_SPEED = 100       # Vitesse maximum (%)
        self.MIN_SPEED = 30        # Vitesse minimum pour démarrer
        self.CENTER_TOLERANCE = 15 # Tolérance de centrage (pixels)
        
        # Paramètres du contrôleur PD pour rotation horizontale
        self.Kp_horizontal = 0.8   # Gain proportionnel horizontal
        self.Kd_horizontal = 0.1   # Gain dérivé horizontal
        self.cx = 1.5              # Facteur d'amplification horizontal
        
        # Variables d'état
        self._moteurs_actifs = False
        self._direction_rotation = "STOP"  # "GAUCHE", "DROITE", "STOP"
        self._vitesse_actuelle = 0
        self._last_error_x = 0.0
        self._last_adjustment_time = 0
        
        # PWM objects
        self._pwm_ena = None
        self._pwm_enb = None
        
        # Timer pour arrêt automatique
        self._stop_timer = QTimer()
        self._stop_timer.setSingleShot(True)
        self._stop_timer.timeout.connect(self._auto_stop)
        
        # Initialiser GPIO
        if GPIO_AVAILABLE:
            self._init_gpio()
    
    def _init_gpio(self):
        """Initialise la configuration GPIO du pont en H"""
        try:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            
            # Configuration des pins de direction (OUTPUT)
            for pin_name, pin_num in self.PONT_H_PINS.items():
                if pin_name in ['int1', 'int2', 'int3', 'int4']:
                    GPIO.setup(pin_num, GPIO.OUT)
                    GPIO.output(pin_num, GPIO.LOW)
                elif pin_name in ['ena', 'enb']:
                    GPIO.setup(pin_num, GPIO.OUT)
            
            # Initialiser PWM pour contrôle de vitesse
            self._pwm_ena = GPIO.PWM(self.PONT_H_PINS['ena'], self.PWM_FREQUENCY)
            self._pwm_enb = GPIO.PWM(self.PONT_H_PINS['enb'], self.PWM_FREQUENCY)
            
            self._pwm_ena.start(0)  # Démarrer à 0%
            self._pwm_enb.start(0)
            
            print("GPIO moteurs horizontaux initialisé")
            
        except Exception as e:
            print(f"Erreur initialisation GPIO moteurs: {e}")
    
    @Property(bool, notify=moteurs_state_changed)
    def moteurs_actifs(self):
        """Indique si les moteurs sont actifs"""
        return self._moteurs_actifs
    
    @Property(str, notify=rotation_changed)
    def direction_rotation(self):
        """Direction actuelle de rotation"""
        return self._direction_rotation
    
    @Property(int, notify=rotation_changed)
    def vitesse_actuelle(self):
        """Vitesse actuelle des moteurs (0-100%)"""
        return self._vitesse_actuelle
    
    def _set_moteur_direction(self, direction, vitesse=50):
        """Configure la direction et vitesse des moteurs
        
        Args:
            direction (str): "GAUCHE", "DROITE", "STOP"
            vitesse (int): Vitesse 0-100%
        """
        if not GPIO_AVAILABLE:
            # Mode simulation
            self._direction_rotation = direction
            self._vitesse_actuelle = vitesse if direction != "STOP" else 0
            self._moteurs_actifs = direction != "STOP"
            self.rotation_changed.emit()
            self.moteurs_state_changed.emit()
            print(f"SIMULATION: Moteurs {direction} à {vitesse}%")
            return
        
        try:
            # Limiter la vitesse
            vitesse = max(0, min(100, vitesse))
            
            if direction == "STOP":
                # Arrêter tous les moteurs
                GPIO.output(self.PONT_H_PINS['int1'], GPIO.LOW)
                GPIO.output(self.PONT_H_PINS['int2'], GPIO.LOW)
                GPIO.output(self.PONT_H_PINS['int3'], GPIO.LOW)
                GPIO.output(self.PONT_H_PINS['int4'], GPIO.LOW)
                self._pwm_ena.ChangeDutyCycle(0)
                self._pwm_enb.ChangeDutyCycle(0)
                self._moteurs_actifs = False
                self._vitesse_actuelle = 0
                
            elif direction == "GAUCHE":
                # Rotation vers la gauche
                # Moteur A: sens horaire, Moteur B: sens anti-horaire
                GPIO.output(self.PONT_H_PINS['int1'], GPIO.HIGH)
                GPIO.output(self.PONT_H_PINS['int2'], GPIO.LOW)
                GPIO.output(self.PONT_H_PINS['int3'], GPIO.LOW)
                GPIO.output(self.PONT_H_PINS['int4'], GPIO.HIGH)
                self._pwm_ena.ChangeDutyCycle(vitesse)
                self._pwm_enb.ChangeDutyCycle(vitesse)
                self._moteurs_actifs = True
                self._vitesse_actuelle = vitesse
                
            elif direction == "DROITE":
                # Rotation vers la droite
                # Moteur A: sens anti-horaire, Moteur B: sens horaire
                GPIO.output(self.PONT_H_PINS['int1'], GPIO.LOW)
                GPIO.output(self.PONT_H_PINS['int2'], GPIO.HIGH)
                GPIO.output(self.PONT_H_PINS['int3'], GPIO.HIGH)
                GPIO.output(self.PONT_H_PINS['int4'], GPIO.LOW)
                self._pwm_ena.ChangeDutyCycle(vitesse)
                self._pwm_enb.ChangeDutyCycle(vitesse)
                self._moteurs_actifs = True
                self._vitesse_actuelle = vitesse
            
            self._direction_rotation = direction
            self.rotation_changed.emit()
            self.moteurs_state_changed.emit()
            
        except Exception as e:
            print(f"Erreur contrôle moteurs: {e}")
    
    @Slot(int, int)
    def ajuster_rotation_horizontale(self, face_center_x, img_width):
        """Ajuste la rotation horizontale pour centrer le visage
        
        Args:
            face_center_x (int): Position X du centre du visage
            img_width (int): Largeur de l'image
        """
        img_center_x = img_width // 2
        horizontal_offset = face_center_x - img_center_x
        
        current_time = time.time()
        time_since_last_adjustment = current_time - self._last_adjustment_time
        
        # Zone de tolérance au centre
        if abs(horizontal_offset) <= self.CENTER_TOLERANCE:
            self._set_moteur_direction("STOP")
            return
        
        # Calculer l'ajustement nécessaire
        normalised_adjustment = horizontal_offset / img_width
        adjustment_magnitude = abs(round(normalised_adjustment, 3))
        
        # Contrôle temporel (éviter les ajustements trop fréquents)
        if adjustment_magnitude > 0.01 and time_since_last_adjustment >= 0.1:
            
            # Direction de l'ajustement
            if horizontal_offset > 0:
                direction = "DROITE"  # Visage à droite -> tourner à droite
            else:
                direction = "GAUCHE"  # Visage à gauche -> tourner à gauche
            
            # Contrôleur PD pour vitesse fluide
            adj_Kp = self.cx * self.Kp_horizontal * adjustment_magnitude
            adj_Kd = self.cx * self.Kd_horizontal * (adjustment_magnitude - self._last_error_x)
            total_adjustment = adj_Kp + adj_Kd
            
            # Calculer la vitesse (30-80% selon l'écart)
            vitesse = int(self.MIN_SPEED + (total_adjustment * 50))
            vitesse = max(self.MIN_SPEED, min(80, vitesse))
            
            # Appliquer la rotation
            self._set_moteur_direction(direction, vitesse)
            
            # Programmer un arrêt automatique après 0.5s
            self._stop_timer.start(500)
            
            self._last_adjustment_time = current_time
            self._last_error_x = adjustment_magnitude
            
            print(f"Rotation {direction} à {vitesse}% (offset: {horizontal_offset}px)")
    
    @Slot()
    def _auto_stop(self):
        """Arrêt automatique des moteurs"""
        self._set_moteur_direction("STOP")
    
    @Slot(str, int)
    def rotation_manuelle(self, direction, vitesse=50):
        """Contrôle manuel de la rotation
        
        Args:
            direction (str): "GAUCHE", "DROITE", "STOP"
            vitesse (int): Vitesse 0-100%
        """
        self._set_moteur_direction(direction, vitesse)
        
        # Arrêt automatique après 2 secondes pour sécurité
        if direction != "STOP":
            self._stop_timer.start(2000)
    
    @Slot()
    def arreter_moteurs(self):
        """Arrête immédiatement tous les moteurs"""
        self._stop_timer.stop()
        self._set_moteur_direction("STOP")
    
    @Slot(result=str)
    def get_status(self):
        """Retourne le statut des moteurs"""
        return f"Direction: {self._direction_rotation}, Vitesse: {self._vitesse_actuelle}%, Actifs: {self._moteurs_actifs}"
    
    def __del__(self):
        """Nettoyage GPIO à la destruction"""
        self.arreter_moteurs()
        if GPIO_AVAILABLE:
            try:
                if self._pwm_ena:
                    self._pwm_ena.stop()
                if self._pwm_enb:
                    self._pwm_enb.stop()
                GPIO.cleanup()
            except:
                pass
