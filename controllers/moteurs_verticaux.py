import time
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

try:
    import RPi.GPIO as GPIO
    GPIO_AVAILABLE = True
except ImportError:
    GPIO_AVAILABLE = False
    print("RPi.GPIO non disponible - Mode simulation moteurs verticaux")

class MoteursVerticauxController(QObject):
    """Contrôleur pour l'inclinaison verticale de l'écran (vérin/moteur)

    Pilotage via pont en H (2 directions) + PWM. Fallback simulation si GPIO indisponible.
    """

    stateChanged = Signal()
    positionChanged = Signal()
    limitReached = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        # Mapping GPIO (à adapter selon le câblage réel)
        self.PINS = {
            'int1': 5,    # Direction A
            'int2': 6,    # Direction B
            'ena': 13,    # PWM enable
        }

        self.PWM_FREQUENCY = 1000
        self.MIN_SPEED = 35
        self.MAX_SPEED = 90

        # Variables d'état
        self._en_mouvement = False
        self._direction = "STOP"  # MONTE | DESCEND | STOP
        self._vitesse = 0

        # Mesure de position optionnelle (si capteur dispo). Par défaut: inconnu
        self._position = -1

        # Timer d'arrêt auto sécurité
        self._auto_stop_timer = QTimer()
        self._auto_stop_timer.setSingleShot(True)
        self._auto_stop_timer.timeout.connect(self.arreter)

        self._pwm_ena = None

        if GPIO_AVAILABLE:
            self._init_gpio()

    def _init_gpio(self):
        try:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            # Pins directions
            GPIO.setup(self.PINS['int1'], GPIO.OUT)
            GPIO.setup(self.PINS['int2'], GPIO.OUT)
            GPIO.output(self.PINS['int1'], GPIO.LOW)
            GPIO.output(self.PINS['int2'], GPIO.LOW)
            # PWM
            GPIO.setup(self.PINS['ena'], GPIO.OUT)
            self._pwm_ena = GPIO.PWM(self.PINS['ena'], self.PWM_FREQUENCY)
            self._pwm_ena.start(0)
            print("GPIO moteurs verticaux initialisé")
        except Exception as e:
            print(f"Erreur init GPIO moteurs verticaux: {e}")

    @Property(bool, notify=stateChanged)
    def enMouvement(self):
        return self._en_mouvement

    @Property(str, notify=stateChanged)
    def direction(self):
        return self._direction

    @Property(int, notify=stateChanged)
    def vitesse(self):
        return self._vitesse

    @Property(int, notify=positionChanged)
    def position(self):
        return self._position

    def _apply(self, direction: str, vitesse: int):
        # Clamp vitesse
        vitesse = max(0, min(100, vitesse))
        if not GPIO_AVAILABLE:
            self._direction = direction
            self._vitesse = 0 if direction == "STOP" else vitesse
            self._en_mouvement = direction != "STOP"
            print(f"SIMULATION: Vertical {direction} à {vitesse}%")
            self.stateChanged.emit()
            return
        try:
            if direction == "STOP":
                GPIO.output(self.PINS['int1'], GPIO.LOW)
                GPIO.output(self.PINS['int2'], GPIO.LOW)
                if self._pwm_ena:
                    self._pwm_ena.ChangeDutyCycle(0)
                self._en_mouvement = False
                self._vitesse = 0
            elif direction == "MONTE":
                GPIO.output(self.PINS['int1'], GPIO.HIGH)
                GPIO.output(self.PINS['int2'], GPIO.LOW)
                if self._pwm_ena:
                    self._pwm_ena.ChangeDutyCycle(vitesse)
                self._en_mouvement = True
                self._vitesse = vitesse
            elif direction == "DESCEND":
                GPIO.output(self.PINS['int1'], GPIO.LOW)
                GPIO.output(self.PINS['int2'], GPIO.HIGH)
                if self._pwm_ena:
                    self._pwm_ena.ChangeDutyCycle(vitesse)
                self._en_mouvement = True
                self._vitesse = vitesse
            self._direction = direction
            self.stateChanged.emit()
        except Exception as e:
            print(f"Erreur contrôle moteurs verticaux: {e}")

    @Slot(int)
    def monter(self, vitesse=60):
        vitesse = max(self.MIN_SPEED, min(self.MAX_SPEED, vitesse))
        self._apply("MONTE", vitesse)
        # sécurité: s'arrêter après 2s si pas de fins de course
        self._auto_stop_timer.start(2000)

    @Slot(int)
    def descendre(self, vitesse=60):
        vitesse = max(self.MIN_SPEED, min(self.MAX_SPEED, vitesse))
        self._apply("DESCEND", vitesse)
        self._auto_stop_timer.start(2000)

    @Slot()
    def arreter(self):
        self._auto_stop_timer.stop()
        self._apply("STOP", 0)

    @Slot()
    def centrer(self):
        """Centrage approximatif si position inconnue: séquence basique (descend puis monte court)."""
        # Séquence simple, à adapter si capteurs de position
        self.descendre(50)
        time.sleep(0.5)
        self.arreter()
        time.sleep(0.2)
        self.monter(50)
        time.sleep(0.5)
        self.arreter()

    @Slot(int, int)
    def center_on_face_y(self, face_center_y: int, img_height: int):
        """Ajuste l'inclinaison pour rapprocher le visage du centre vertical.
        Utilise un contrôle proportionnel simple basé sur l'écart vertical.
        """
        img_center_y = img_height // 2
        offset = face_center_y - img_center_y
        tolerance = 12
        if abs(offset) <= tolerance:
            self.arreter()
            return
        # vitesse proportionnelle à l'écart
        magnitude = min(1.0, abs(offset) / img_height)
        vitesse = int(self.MIN_SPEED + magnitude * (self.MAX_SPEED - self.MIN_SPEED))
        if offset > 0:
            # visage trop bas -> descendre l'écran
            self.descendre(vitesse)
        else:
            # visage trop haut -> monter l'écran
            self.monter(vitesse)
        # arrêt automatique court pour step discret
        self._auto_stop_timer.start(250)

    def __del__(self):
        try:
            self.arreter()
            if GPIO_AVAILABLE:
                if self._pwm_ena:
                    self._pwm_ena.stop()
                GPIO.cleanup()
        except Exception:
            pass
