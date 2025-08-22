import cv2
import time
import threading
import numpy as np
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from PySide6.QtGui import QImage, QPixmap

try:
    from picamera2 import Picamera2
    PICAMERA_AVAILABLE = True
except ImportError:
    PICAMERA_AVAILABLE = False
    print("Picamera2 non disponible - Mode simulation activé")

try:
    from gpiozero import AngularServo
    from gpiozero.pins.pigpio import PiGPIOFactory
    SERVO_AVAILABLE = True
except ImportError:
    SERVO_AVAILABLE = False
    print("gpiozero non disponible - Servo en mode simulation")

class CameraController(QObject):
    """Contrôleur pour la caméra et détection de visage avec servo moteur"""
    
    # Signaux
    face_detected = Signal(bool)  # Visage détecté ou non
    face_position_changed = Signal()  # Position du visage changée
    servo_angle_changed = Signal()  # Angle servo changé
    camera_frame_ready = Signal('QVariant')  # Nouvelle frame disponible
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Configuration caméra
        self._camera = None
        self._camera_active = False
        self._frame = None
        self._face_cascade = None
        
        # Configuration servo moteur
        self.SERVO_PIN = 11
        self.SERVO_CENTER_ANGLE = 0
        self.SERVO_MIN_ANGLE = -90
        self.SERVO_MAX_ANGLE = 90
        self._servo = None
        self._current_servo_angle = self.SERVO_CENTER_ANGLE
        
        # Paramètres du contrôleur PD
        self.Kp = 1.6  # Gain proportionnel
        self.Kd = 0.2  # Gain dérivé
        self.cy = 2    # Facteur d'amplification
        self.FACE_DETECTION_DELAY = 0.025
        self.CENTER_TOLERANCE = 10
        
        # Variables de tracking
        self._face_detected = False
        self._face_x = 0
        self._face_y = 0
        self._face_width = 0
        self._face_height = 0
        self._face_distance = 0.0
        self._face_detection_start_time = None
        self._face_detected_duration = 0
        self._last_error_y = 0.0
        self._last_adjustment_time = 0
        
        # Timer pour capture continue
        self._capture_timer = QTimer()
        self._capture_timer.timeout.connect(self._capture_and_process)
        
        # Initialiser les composants
        self._init_camera()
        self._init_face_detection()
        self._init_servo()
    
    def _init_camera(self):
        """Initialise la caméra Raspberry Pi"""
        if PICAMERA_AVAILABLE:
            try:
                self._camera = Picamera2()
                config = self._camera.create_video_configuration(main={"size": (640, 480)})
                self._camera.configure(config)
                print("Caméra Raspberry Pi initialisée")
            except Exception as e:
                print(f"Erreur initialisation caméra: {e}")
                self._camera = None
        else:
            print("Mode simulation caméra activé")
    
    def _init_face_detection(self):
        """Initialise la détection de visage OpenCV"""
        try:
            # Charger le classificateur de visage
            cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
            self._face_cascade = cv2.CascadeClassifier(cascade_path)
            print("Détection de visage initialisée")
        except Exception as e:
            print(f"Erreur initialisation détection visage: {e}")
    
    def _init_servo(self):
        """Initialise le servo moteur"""
        if SERVO_AVAILABLE:
            try:
                pigpio_factory = PiGPIOFactory()
                self._servo = AngularServo(self.SERVO_PIN, pin_factory=pigpio_factory)
                self._servo.angle = self.SERVO_CENTER_ANGLE
                time.sleep(1)
                print("Servo moteur initialisé")
            except Exception as e:
                print(f"Erreur initialisation servo: {e}")
                self._servo = None
        else:
            print("Mode simulation servo activé")
    
    @Property(bool, notify=face_detected)
    def face_detected_property(self):
        """Propriété indiquant si un visage est détecté"""
        return self._face_detected
    
    @Property(int, notify=face_position_changed)
    def face_x(self):
        return self._face_x
    
    @Property(int, notify=face_position_changed)
    def face_y(self):
        return self._face_y
    
    @Property(int, notify=face_position_changed)
    def face_width(self):
        return self._face_width
    
    @Property(int, notify=face_position_changed)
    def face_height(self):
        return self._face_height
    
    @Property(float, notify=face_position_changed)
    def face_distance(self):
        return self._face_distance
    
    @Property(float, notify=servo_angle_changed)
    def servo_angle(self):
        return self._current_servo_angle
    
    @Slot()
    def start_camera(self):
        """Démarre la caméra et la détection"""
        if self._camera and not self._camera_active:
            try:
                self._camera.start()
                self._camera_active = True
                self._capture_timer.start(50)  # 20 FPS
                print("Caméra démarrée")
            except Exception as e:
                print(f"Erreur démarrage caméra: {e}")
        elif not PICAMERA_AVAILABLE:
            # Mode simulation
            self._camera_active = True
            self._capture_timer.start(100)  # 10 FPS en simulation
            print("Caméra simulation démarrée")
    
    @Slot()
    def stop_camera(self):
        """Arrête la caméra"""
        if self._camera and self._camera_active:
            try:
                self._camera.stop()
                self._camera_active = False
                self._capture_timer.stop()
                print("Caméra arrêtée")
            except Exception as e:
                print(f"Erreur arrêt caméra: {e}")
        elif not PICAMERA_AVAILABLE and self._camera_active:
            self._camera_active = False
            self._capture_timer.stop()
            print("Caméra simulation arrêtée")
    
    def _capture_and_process(self):
        """Capture une frame et traite la détection de visage"""
        if not self._camera_active:
            return
        
        try:
            if PICAMERA_AVAILABLE and self._camera:
                # Capture réelle
                frame = self._camera.capture_array()
                image = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                image = cv2.rotate(image, cv2.ROTATE_180)
            else:
                # Mode simulation - créer une image de test
                image = np.zeros((480, 640, 3), dtype=np.uint8)
                # Simuler un visage au centre
                cv2.rectangle(image, (270, 190), (370, 290), (0, 255, 0), 2)
                cv2.putText(image, "SIMULATION", (250, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
            
            # Détection de visage
            self._process_face_detection(image)
            
            # Convertir pour Qt et émettre le signal
            self._emit_frame(image)
            
        except Exception as e:
            print(f"Erreur capture/traitement: {e}")
    
    def _process_face_detection(self, image):
        """Traite la détection de visage et contrôle le servo"""
        if self._face_cascade is None:
            return
        
        # Convertir en niveaux de gris pour la détection
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = self._face_cascade.detectMultiScale(gray, 1.3, 5)
        
        current_time = time.time()
        face_detected_this_frame = len(faces) > 0
        
        if face_detected_this_frame:
            # Visage détecté
            if self._face_detection_start_time is None:
                self._face_detection_start_time = current_time
            
            self._face_detected_duration = current_time - self._face_detection_start_time
            
            # Trouver le plus grand visage
            biggest_face = max(faces, key=lambda face: face[2] * face[3])
            x, y, width, height = biggest_face
            
            # Mettre à jour les propriétés
            self._face_x = int(x)
            self._face_y = int(y)
            self._face_width = int(width)
            self._face_height = int(height)
            
            # Calculer la distance approximative (basée sur la largeur du visage)
            # Formule approximative: distance = (largeur_visage_réelle * focale) / largeur_pixels
            # Assumons une largeur de visage moyenne de 16cm et une focale approximative
            if width > 0:
                self._face_distance = round((16.0 * 500) / width, 1)  # Distance en cm
            
            # Calculer le centre du visage
            face_center_x = x + width // 2
            face_center_y = y + height // 2
            
            # Contrôle du servo après délai
            if self._face_detected_duration >= self.FACE_DETECTION_DELAY:
                # ÉTAPE 1: Rotation horizontale AVANT rotation verticale
                self._control_horizontal_rotation(image, face_center_x)
                # ÉTAPE 2: Rotation verticale (servo)
                self._control_servo(image, face_center_y)
            
            # Dessiner le rectangle de tracking
            cv2.rectangle(image, (x, y), (x + width, y + height), (0, 255, 0), 3)
            cv2.circle(image, (face_center_x, face_center_y), 5, (0, 255, 255), -1)
            
            if not self._face_detected:
                self._face_detected = True
                self.face_detected.emit(True)
                self.face_position_changed.emit()
        else:
            # Aucun visage détecté
            if self._face_detected:
                self._face_detected = False
                self.face_detected.emit(False)
            
            self._face_detection_start_time = None
            self._face_detected_duration = 0
        
        # Ligne de référence au centre
        img_height, img_width = image.shape[:2]
        cv2.line(image, (0, img_height//2), (img_width, img_height//2), (128, 128, 128), 1)
    
    def _control_servo(self, image, face_center_y):
        """Contrôle le servo moteur pour centrer le visage verticalement"""
        img_height = image.shape[0]
        img_center_y = img_height // 2
        
        # Calculer l'écart vertical
        vertical_offset = face_center_y - img_center_y
        
        current_time = time.time()
        time_since_last_adjustment = current_time - self._last_adjustment_time
        
        # Zone de tolérance au centre
        if abs(vertical_offset) <= self.CENTER_TOLERANCE:
            return  # Visage centré
        
        # Calculer l'ajustement
        normalised_adjustment = vertical_offset / img_height
        adjustment_magnitude = abs(round(normalised_adjustment, 3))
        
        if adjustment_magnitude > 0.01 and time_since_last_adjustment >= 0.025:
            # Direction de l'ajustement
            adjustment_direction = 1 if normalised_adjustment > 0 else -1
            
            # Contrôleur PD
            adj_Kp = self.cy * self.Kp * adjustment_direction * adjustment_magnitude
            adj_Kd = self.cy * self.Kd * adjustment_direction * (adjustment_magnitude - self._last_error_y)
            total_adjustment = adj_Kp + adj_Kd
            
            # Calculer le nouvel angle
            new_servo_angle = self._current_servo_angle + total_adjustment
            
            # Limiter dans les bornes
            new_servo_angle = max(self.SERVO_MIN_ANGLE, min(self.SERVO_MAX_ANGLE, new_servo_angle))
            
            # Appliquer au servo
            if SERVO_AVAILABLE and self._servo:
                try:
                    self._servo.angle = new_servo_angle
                except Exception as e:
                    print(f"Erreur servo: {e}")
            
            self._current_servo_angle = new_servo_angle
            self._last_adjustment_time = current_time
            self._last_error_y = adjustment_magnitude
            
            self.servo_angle_changed.emit()
    
    def _control_horizontal_rotation(self, image, face_center_x):
        """Contrôle la rotation horizontale pour centrer le visage (appelé avant servo vertical)"""
        img_width = image.shape[1]
        
        # Émettre signal pour rotation horizontale si contrôleur disponible
        if hasattr(self, '_moteurs_horizontaux'):
            self._moteurs_horizontaux.ajuster_rotation_horizontale(face_center_x, img_width)
    
    def _emit_frame(self, image):
        """Convertit et émet la frame pour Qt"""
        try:
            # Convertir BGR vers RGB
            rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            h, w, ch = rgb_image.shape
            bytes_per_line = ch * w
            
            # Créer QImage
            qt_image = QImage(rgb_image.data, w, h, bytes_per_line, QImage.Format_RGB888)
            
            # Émettre le signal avec l'image
            self.camera_frame_ready.emit(qt_image)
            
        except Exception as e:
            print(f"Erreur conversion image: {e}")
    
    @Slot(float)
    def set_servo_angle(self, angle):
        """Définit manuellement l'angle du servo"""
        angle = max(self.SERVO_MIN_ANGLE, min(self.SERVO_MAX_ANGLE, angle))
        
        if SERVO_AVAILABLE and self._servo:
            try:
                self._servo.angle = angle
            except Exception as e:
                print(f"Erreur servo manuel: {e}")
        
        self._current_servo_angle = angle
        self.servo_angle_changed.emit()
    
    @Slot()
    def center_servo(self):
        """Centre le servo moteur"""
        self.set_servo_angle(self.SERVO_CENTER_ANGLE)
    
    @Slot(result=str)
    def get_face_info(self):
        """Retourne les informations du visage détecté"""
        if self._face_detected:
            return f"Position: ({self._face_x}, {self._face_y}), Taille: {self._face_width}x{self._face_height}, Distance: {self._face_distance}cm"
        return "Aucun visage détecté"
    
    def __del__(self):
        """Nettoyage à la destruction"""
        self.stop_camera()
        if self._camera:
            try:
                self._camera.close()
            except:
                pass
