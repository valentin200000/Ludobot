import subprocess
import re
import sys
import shutil
import os
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

class BrightnessController(QObject):
    """Contrôleur pour gérer la luminosité de l'écran et la synchroniser avec le système"""
    brightnessChanged = Signal(float)
    
    def __init__(self):
        super().__init__()
        self._brightness = 0.5  # Luminosité par défaut (50%)
        self._last_set_brightness = None  # Dernière valeur définie
        
        # Désactiver la gestion automatique de la luminosité de GNOME
        self._disable_auto_brightness()
        
        # Initialiser la luminosité une seule fois au démarrage
        self._brightness = self.get_system_brightness()
        
    def _disable_auto_brightness(self):
        """Désactive la gestion automatique de la luminosité dans GNOME"""
        try:
            # Désactiver l'ajustement automatique de la luminosité
            if shutil.which("gsettings"):
                # Désactiver l'ajustement automatique de la luminosité
                subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                               "ambient-enabled", "false"], 
                              stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                
                # Désactiver la réduction de luminosité lorsque inactif
                subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                               "idle-dim", "false"],
                              stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                
                # Désactiver l'ajustement automatique de la luminosité à la batterie
                subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                               "idle-brightness", "100"],
                              stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                
                print("Gestion automatique de la luminosité désactivée")
        except Exception as e:
            print(f"Erreur lors de la désactivation de la luminosité automatique: {e}")
    
    @Property(float, notify=brightnessChanged)
    def brightness(self):
        """Retourne la luminosité actuelle (0.0 à 1.0)"""
        return self._brightness
    
    @brightness.setter
    def brightness(self, value):
        """Définit la luminosité de l'écran"""
        # Limiter la valeur entre 0 et 1
        value = max(0.0, min(1.0, value))
        
        # Vérifier si la valeur a changé significativement (>1%)
        if self._last_set_brightness is None or abs(value - self._last_set_brightness) > 0.01:
            self._brightness = value
            self._last_set_brightness = value
            self.brightnessChanged.emit(value)
            self.set_system_brightness(value)
    
    # La méthode sync_with_system_brightness a été retirée pour éviter les changements automatiques
    
    @Slot(float)
    def set_brightness(self, value):
        """Définit la luminosité (0.0 à 1.0)"""
        self.brightness = value
    
    def get_system_brightness(self):
        """Récupère la luminosité système actuelle (0.0 à 1.0)"""
        try:
            if sys.platform.startswith("linux"):
                # Méthode 1: Utiliser brightnessctl qui est fiable et qui fonctionne sur Ubuntu
                if shutil.which("brightnessctl"):
                    try:
                        result = subprocess.check_output(["brightnessctl", "info"], text=True, stderr=subprocess.STDOUT)
                        # Extraire le pourcentage actuel (exemple de format: 'Current brightness: 17040 (71%)')
                        percent_match = re.search(r'\((\d+)%\)', result)
                        if percent_match:
                            brightness_percent = int(percent_match.group(1))
                            brightness_value = brightness_percent / 100.0
                            print(f"Luminosité actuelle détectée (brightnessctl): {brightness_percent}%")
                            return brightness_value
                    except Exception as e:
                        print(f"Erreur brightnessctl: {e}")
                
                # Méthode 2: Utiliser light
                if shutil.which("light"):
                    try:
                        result = subprocess.check_output(["light", "-G"], text=True).strip()
                        brightness_percent = float(result)
                        brightness_value = brightness_percent / 100.0
                        print(f"Luminosité actuelle détectée (light): {brightness_percent}%")
                        return brightness_value
                    except Exception as e:
                        print(f"Erreur light: {e}")
                
                # Méthode 3: Pour Raspberry Pi et la plupart des systèmes Linux, xrandr est couramment utilisé
                if shutil.which("xrandr"):
                    try:
                        # Obtenir le nom de l'écran actif
                        displays = subprocess.check_output(["xrandr", "--query"], text=True)
                        display_match = re.search(r'(\S+) connected', displays)
                        if display_match:
                            display_name = display_match.group(1)
                            
                            # Obtenir les propriétés de l'écran, y compris la luminosité
                            display_info = subprocess.check_output(["xrandr", "--verbose", "--current"], text=True)
                            
                            # Chercher la section de l'écran spécifique
                            display_section_pattern = f"{display_name}.*?Brightness: ([\d\.]+)"
                            brightness_match = re.search(display_section_pattern, display_info, re.DOTALL)
                            
                            if brightness_match:
                                brightness = float(brightness_match.group(1))
                                print(f"Luminosité actuelle détectée (xrandr): {brightness}")
                                return brightness
                            else:
                                # Si pas trouvé dans la section spécifique, chercher dans tout le texte
                                general_match = re.search(r'Brightness: ([\d\.]+)', display_info)
                                if general_match:
                                    brightness = float(general_match.group(1))
                                    print(f"Luminosité actuelle détectée (xrandr général): {brightness}")
                                    return brightness
                    except Exception as e:
                        print(f"Erreur xrandr: {e}")
                
                # Utiliser xbacklight pour Intel/Linux
                if shutil.which("xbacklight"):
                    try:
                        result = subprocess.check_output(["xbacklight", "-get"], text=True).strip()
                        if result:
                            return float(result) / 100.0
                    except Exception as e:
                        print(f"Erreur xbacklight: {e}")
                
                # Vérifier les fichiers sys pour les interfaces de luminosité
                brightness_paths = [
                    "/sys/class/backlight/*/brightness",
                    "/sys/class/backlight/*/actual_brightness",
                ]
                
                for path_pattern in brightness_paths:
                    try:
                        import glob
                        paths = glob.glob(path_pattern)
                        if paths:
                            # Prendre le premier périphérique trouvé
                            brightness_path = paths[0]
                            # Lire la luminosité actuelle
                            with open(brightness_path, 'r') as f:
                                current = float(f.read().strip())
                            
                            # Lire la luminosité maximale
                            max_path = os.path.join(os.path.dirname(brightness_path), "max_brightness")
                            if os.path.exists(max_path):
                                with open(max_path, 'r') as f:
                                    max_value = float(f.read().strip())
                                    if max_value > 0:
                                        return current / max_value
                    except Exception as e:
                        print(f"Erreur fichier sys: {e}")
                
                # Si aucune méthode ne fonctionne, retourner la valeur interne
                return self._brightness
                
            elif sys.platform.startswith("win"):
                # Sur Windows, la luminosité peut être obtenue via WMI
                try:
                    result = subprocess.check_output(
                        ["powershell", "(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightness).CurrentBrightness"],
                        text=True
                    ).strip()
                    if result and result.isdigit():
                        return int(result) / 100.0
                except Exception:
                    pass
            
            # Valeur par défaut si aucune méthode ne fonctionne
            return 0.5
            
        except Exception as e:
            print(f"Erreur lors de la récupération de la luminosité système: {e}")
            return 0.5
    
    def set_system_brightness(self, value):
        """Définit la luminosité système (0.0 à 1.0)"""
        brightness_percent = int(value * 100)
        
        try:
            success = False
            
            if sys.platform.startswith("linux"):
                # Méthode 1: Utiliser les outils utilisateur sans privilèges et enregistrer le paramètre
                if shutil.which("brightnessctl"):
                    try:
                        # brightnessctl est une commande utilisateur qui ne demande pas
                        # de mot de passe et qui fonctionne sur la plupart des distributions Linux
                        subprocess.run(["brightnessctl", "set", f"{brightness_percent}%"], check=True)
                        
                        # Essayer de sauvegarder le réglage de luminosité de manière permanente
                        if shutil.which("gsettings"):
                            # Désactiver temporairement l'ajustement automatique
                            subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                                           "ambient-enabled", "false"], 
                                          stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                            
                            # Définir la luminosité pour l'alimentation secteur (AC)
                            subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                                           "brightness-ac", str(brightness_percent)], 
                                          stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                            
                            # Définir la luminosité pour l'alimentation sur batterie
                            subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                                           "brightness-battery", str(brightness_percent)], 
                                          stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                            
                            # Définir la luminosité en mode faible consommation
                            subprocess.run(["gsettings", "set", "org.gnome.settings-daemon.plugins.power", 
                                           "brightness-dim-battery", str(brightness_percent)], 
                                          stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                            
                        success = True
                        print(f"Luminosité définie via brightnessctl: {brightness_percent}% et paramètres GNOME mis à jour")
                    except Exception as e:
                        print(f"Erreur brightnessctl: {e}")
                
                # Méthode 2: Utiliser light (outil utilisateur)
                if not success and shutil.which("light"):
                    try:
                        subprocess.run(["light", "-S", str(brightness_percent)], check=True)
                        success = True
                        print(f"Luminosité définie via light: {brightness_percent}%")
                    except Exception as e:
                        print(f"Erreur light: {e}")
                        
                # Méthode 3: Essayer l'outil GNOME spécifique
                if not success and shutil.which("gnome-brightness-helper"):
                    try:
                        subprocess.run(["gnome-brightness-helper", "--set", str(value)], check=True)
                        success = True
                        print(f"Luminosité définie via gnome-brightness-helper: {brightness_percent}%")
                    except Exception as e:
                        print(f"Erreur gnome-brightness-helper: {e}")
                
                # Méthode 4: Essayer d'utiliser brillo (ne nécessite pas de droits root)
                if not success and shutil.which("brillo"):
                    try:
                        subprocess.run(["brillo", "-S", str(brightness_percent)], check=True)
                        success = True
                        print(f"Luminosité définie via brillo: {brightness_percent}%")
                    except Exception as e:
                        print(f"Erreur brillo: {e}")
                
                # Méthode 2: Utiliser l'outil gdbus/dbus pour manipuler la luminosité via le shell Ubuntu
                if not success and shutil.which("gdbus"):
                    try:
                        # GNOME Shell utilise un service DBus pour contrôler la luminosité
                        subprocess.run([
                            "gdbus", "call", "--session", "--dest", "org.gnome.SettingsDaemon.Power",
                            "--object-path", "/org/gnome/SettingsDaemon/Power",
                            "--method", "org.gnome.SettingsDaemon.Power.Screen.SetPercentage", 
                            str(brightness_percent)
                        ], check=True)
                        success = True
                        print(f"Luminosité définie via gdbus Power: {brightness_percent}%")
                    except Exception as e:
                        print(f"Erreur gdbus Power: {e}")
                        
                        # Essayer une autre méthode de gdbus
                        try:
                            subprocess.run([
                                "gdbus", "call", "--session", "--dest", "org.gnome.SettingsDaemon.Color",
                                "--object-path", "/org/gnome/SettingsDaemon/Color",
                                "--method", "org.gnome.SettingsDaemon.Color.SetPercentage", 
                                str(brightness_percent)
                            ], check=True)
                            success = True
                            print(f"Luminosité définie via gdbus Color: {brightness_percent}%")
                        except Exception as e:
                            print(f"Erreur gdbus Color: {e}")
                
                # Méthode 3: Pour Raspberry Pi et la plupart des systèmes Linux
                if not success and shutil.which("xrandr"):
                    try:
                        # Obtenir le nom de l'écran
                        displays = subprocess.check_output(["xrandr", "--query"], text=True)
                        display_match = re.search(r'(\S+) connected', displays)
                        if display_match:
                            display_name = display_match.group(1)
                            subprocess.run(["xrandr", "--output", display_name, "--brightness", str(value)], check=True)
                            success = True
                            print(f"Luminosité définie avec xrandr: {value} ({brightness_percent}%)")
                    except Exception as e:
                        print(f"Erreur xrandr: {e}")
                
                # Utiliser xbacklight pour Intel/Linux
                if not success and shutil.which("xbacklight"):
                    try:
                        subprocess.run(["xbacklight", "-set", str(brightness_percent)], check=True)
                        success = True
                        print(f"Luminosité définie avec xbacklight: {brightness_percent}%")
                    except Exception as e:
                        print(f"Erreur xbacklight (2): {e}")
                
                # Écrire directement dans les fichiers système
                if not success:
                    brightness_paths = [
                        "/sys/class/backlight/*/brightness",
                    ]
                    
                    for path_pattern in brightness_paths:
                        try:
                            import glob
                            paths = glob.glob(path_pattern)
                            if paths:
                                # Prendre le premier périphérique trouvé
                                brightness_path = paths[0]
                                
                                # Lire la luminosité maximale
                                max_path = os.path.join(os.path.dirname(brightness_path), "max_brightness")
                                if os.path.exists(max_path):
                                    with open(max_path, 'r') as f:
                                        max_value = int(f.read().strip())
                                        
                                        # Calculer la nouvelle valeur de luminosité
                                        new_value = int(value * max_value)
                                        
                                        # Écrire la nouvelle valeur (peut nécessiter des privilèges root)
                                        with open(brightness_path, 'w') as f:
                                            f.write(str(new_value))
                                        
                                        success = True
                                        print(f"Luminosité définie via fichier sys: {new_value}/{max_value}")
                        except Exception as e:
                            print(f"Erreur fichier sys (2): {e}")
                
                # Si aucune méthode ne fonctionne avec les privilèges actuels, essayer avec sudo
                if not success and shutil.which("sudo"):
                    try:
                        # Essayer de trouver un fichier de luminosité accessible avec sudo
                        paths = glob.glob("/sys/class/backlight/*/brightness")
                        if paths:
                            brightness_path = paths[0]
                            max_path = os.path.join(os.path.dirname(brightness_path), "max_brightness")
                            
                            # Lire la luminosité maximale avec sudo
                            max_result = subprocess.check_output(["sudo", "cat", max_path], text=True).strip()
                            max_value = int(max_result)
                            
                            # Calculer la nouvelle valeur
                            new_value = int(value * max_value)
                            
                            # Écrire avec sudo (nécessite que l'utilisateur ait les privilèges sudo)
                            subprocess.run(["sudo", "sh", "-c", f"echo {new_value} > {brightness_path}"], check=True)
                            success = True
                            print(f"Luminosité définie via sudo: {new_value}/{max_value}")
                    except Exception as e:
                        print(f"Erreur sudo: {e}")
                
            elif sys.platform.startswith("win"):
                try:
                    # Sur Windows, on peut définir la luminosité via PowerShell
                    script = f"""
                    $brightness = {brightness_percent}
                    $myMonitor = Get-WmiObject -Namespace root\\wmi -Class WmiMonitorBrightnessMethods
                    $myMonitor.WmiSetBrightness(1, $brightness)
                    """
                    subprocess.run(["powershell", "-Command", script], check=True)
                    success = True
                    print(f"Luminosité définie sur Windows: {brightness_percent}%")
                except Exception as e:
                    print(f"Erreur Windows: {e}")
            
            if not success:
                print("Aucun utilitaire de contrôle de la luminosité système n'a fonctionné")
                
        except Exception as e:
            print(f"Erreur lors de la définition de la luminosité système: {e}")
