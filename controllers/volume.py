import subprocess
import re
import sys
import shutil
import os
import time
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

class VolumeController(QObject):
    """Contrôleur pour gérer le volume de l'application et le synchroniser avec le volume système"""
    volumeChanged = Signal(float)
    
    def __init__(self):
        super().__init__()
        self._volume = 0.5  # Volume par défaut (50%)
        
        # Nous désactivons la synchronisation automatique car elle cause des problèmes
        # self._timer = QTimer()
        # self._timer.timeout.connect(self.sync_with_system_volume)
        # self._timer.start(2000)  # Vérifier toutes les 2 secondes
        
        # Synchronisation initiale (une seule fois au démarrage)
        self.sync_with_system_volume_once()
    
    @Property(float, notify=volumeChanged)
    def volume(self):
        """Retourne le volume actuel (0.0 à 1.0)"""
        return self._volume
    
    @volume.setter
    def volume(self, value):
        """Définit le volume de l'application et du système"""
        # Limiter la valeur entre 0 et 1
        value = max(0.0, min(1.0, value))
        
        if value != self._volume:
            self._volume = value
            self.volumeChanged.emit(value)
            self._last_manual_set_time = time.time()  # Marquer l'heure du dernier réglage manuel
            self.set_system_volume(value)
    
    @Slot()
    def sync_with_system_volume(self):
        """Synchronise le volume de l'application avec le volume système"""
        try:
            # Désactiver temporairement la synchronisation pendant 5 secondes après un réglage manuel
            if hasattr(self, '_last_manual_set_time') and (time.time() - self._last_manual_set_time < 5):
                return
                
            # Récupérer le volume système actuel
            system_volume = self.get_system_volume()
            
            # Mettre à jour le volume de l'application si nécessaire
            if abs(system_volume - self._volume) > 0.01:  # Tolérance de 1%
                self._volume = system_volume
                self.volumeChanged.emit(system_volume)
        except Exception as e:
            print(f"Erreur lors de la synchronisation du volume: {e}")
            
    @Slot()
    def sync_with_system_volume_once(self):
        """Effectue une seule synchronisation initiale avec le volume système"""
        try:
            # Récupérer le volume système actuel
            system_volume = self.get_system_volume()
            
            # Mettre à jour le volume de l'application
            self._volume = system_volume
            self.volumeChanged.emit(system_volume)
            
            # Définir le dernier temps de réglage pour éviter les conflits
            self._last_manual_set_time = time.time()
            
            print(f"Volume initial synchronisé à {int(system_volume * 100)}%")
        except Exception as e:
            print(f"Erreur lors de la synchronisation initiale du volume: {e}")
            # En cas d'échec, utiliser la valeur par défaut
    
    @Slot(float)
    def set_volume(self, value):
        """Définit le volume (0.0 à 1.0)"""
        self.volume = value
    
    def get_system_volume(self):
        """Récupère le volume système actuel (0.0 à 1.0)"""
        try:
            if sys.platform.startswith("linux"):
                # Directement utiliser amixer (ALSA) qui fonctionne sur ce système
                if shutil.which("amixer"):
                    try:
                        result = subprocess.check_output(["amixer", "get", "Master"], text=True)
                        # Chercher la ligne avec le volume, ex: [50%]
                        matches = re.findall(r'\[(\d+)%\]', result)
                        if matches:
                            # Prend le dernier volume trouvé (celui de Master)
                            # Diviser par 100 pour obtenir une valeur entre 0 et 1
                            # Pour la correspondance avec l'échelle doublée en sortie
                            return min(int(matches[-1]) / 100.0, 1.0)
                    except Exception as e:
                        print(f"Erreur amixer: {e}")
                
                # Si amixer n'est pas disponible, essayer pactl (PulseAudio)
                elif shutil.which("pactl"):
                    try:
                        result = subprocess.check_output(["pactl", "list", "sinks"], text=True)
                        # Chercher la ligne avec le volume, ex: Volume: front-left: 65536 / 100% / 0.00 dB,   front-right: 65536 / 100% / 0.00 dB
                        matches = re.findall(r'(\d+)%', result)
                        if matches:
                            # Volume en pourcentage (0-100%) converti en valeur entre 0 et 1
                            # Diviser par 100 pour obtenir une valeur entre 0 et 1
                            return min(int(matches[0]) / 100.0, 1.0)
                    except Exception as e:
                        print(f"Erreur pactl: {e}")
                
                # Essayer pacmd en dernier recours
                elif shutil.which("pacmd"):
                    try:
                        result = subprocess.check_output(["pacmd", "list-sinks"], text=True)
                        # Chercher les lignes avec le volume, ex: volume: front-left: 65536 / 100% / 0.00 dB,   front-right: 65536 / 100% / 0.00 dB
                        matches = re.findall(r'(\d+)%', result)
                        if matches:
                            # Prend le premier volume trouvé en pourcentage
                            # Diviser par 100 pour obtenir une valeur entre 0 et 1
                            return min(int(matches[0]) / 100.0, 1.0)
                    except Exception as e:
                        print(f"Erreur pacmd: {e}")
                        
                # Essayer gsettings uniquement en dernier recours car ne fonctionne pas sur ce système
                elif shutil.which("gsettings"):
                    try:
                        # Obtenir le volume via gsettings
                        result = subprocess.check_output(
                            ["gsettings", "get", "org.gnome.desktop.sound", "volume-sound"], 
                            text=True, stderr=subprocess.DEVNULL
                        ).strip()
                        # Le résultat est une valeur décimale entre 0 et 1
                        if result:
                            try:
                                return float(result)
                            except ValueError:
                                pass
                    except Exception:
                        # Ne pas afficher les erreurs gsettings qui sont attendues sur ce système
                        pass
                    
            elif sys.platform.startswith("win"):
                try:
                    volume_info = subprocess.check_output(
                        ["wmic", "sounddev", "get", "volume"],
                        text=True,
                        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0)
                    )
                    lines = volume_info.strip().split('\n')
                    if len(lines) > 1:
                        try:
                            volume = int(lines[1].strip())
                            return volume / 100.0
                        except ValueError:
                            pass
                except Exception:
                    pass
                
            # Valeur par défaut si aucune méthode ne fonctionne
            return 0.5
            
        except Exception as e:
            print(f"Erreur lors de la récupération du volume système: {e}")
            return 0.5
    
    def set_system_volume(self, value):
        """Définit le volume système (0.0 à 1.0)"""
        try:
            # Doubler l'échelle pour que 1.0 atteigne réellement 100% du volume système
            volume_percent = int(min(value * 200, 100))
            if sys.platform.startswith("linux"):
                success = False
                
                # Essayer d'utiliser gsettings pour Ubuntu/GNOME
                if shutil.which("gsettings"):
                    try:
                        # Vérifier si la clé existe
                        check = subprocess.check_output(
                            ["gsettings", "list-keys", "org.gnome.desktop.sound"],
                            text=True
                        )
                        if "volume-sound" in check:
                            # Définir le volume via gsettings (valeur entre 0 et 1)
                            # Doubler l'échelle pour que 1.0 atteigne réellement 100% du volume système
                            # gsettings accepte des valeurs entre 0 et 1, donc limiter à 1.0
                            subprocess.run(
                                ["gsettings", "set", "org.gnome.desktop.sound", "volume-sound", str(min(value * 2, 1.0))],
                                check=True
                            )
                            success = True
                            print(f"Volume défini avec gsettings: {value}")
                    except Exception as e:
                        print(f"Erreur lors de l'utilisation de gsettings: {e}")
                
                # Si gsettings a échoué, essayer d'utiliser les commandes de contrôle du volume du bureau
                if not success and shutil.which("gdbus"):
                    try:
                        # Utiliser gdbus pour interagir avec le contrôle du volume
                        # Doubler l'échelle pour que 1.0 atteigne réellement 100% du volume système
                        subprocess.run([
                            "gdbus", "call", "--session", "--dest", "org.gnome.SettingsDaemon.Sound",
                            "--object-path", "/org/gnome/SettingsDaemon/Sound",
                            "--method", "org.gnome.SettingsDaemon.Sound.SetVolume", str(int(min(value * 200, 100)))
                        ], check=True)
                        success = True
                        print(f"Volume défini avec gdbus: {volume_percent}%")
                    except Exception as e:
                        print(f"Erreur lors de l'utilisation de gdbus: {e}")
                
                # Utiliser amixer en dernier recours
                if not success and shutil.which("amixer"):
                    subprocess.run(["amixer", "set", "Master", f"{volume_percent}%"], check=True)
                    success = True
                    print(f"Volume défini avec amixer: {volume_percent}%")
                
                # Si amixer n'est pas disponible, essayer pactl
                elif not success and shutil.which("pactl"):
                    subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"{volume_percent}%"], check=True)
                    success = True
                    print(f"Volume défini avec pactl: {volume_percent}%")
                
                # Dernière tentative avec pacmd
                elif not success and shutil.which("pacmd"):
                    # Trouver le sink par défaut
                    try:
                        sinks = subprocess.check_output(["pacmd", "list-sinks"], text=True)
                        default_sink_match = re.search(r'\* index: (\d+)', sinks)
                        if default_sink_match:
                            sink_index = default_sink_match.group(1)
                            # Doubler l'échelle pour que 1.0 atteigne réellement 100% du volume système
                            # pacmd utilise une échelle de 0 à 65535
                            subprocess.run(["pacmd", "set-sink-volume", sink_index, str(int(min(value * 2, 1.0) * 65535))], check=True)
                            success = True
                            print(f"Volume défini avec pacmd: {volume_percent}%")
                    except Exception as e:
                        print(f"Erreur lors de l'utilisation de pacmd: {e}")
                
                if not success:
                    print("Aucun utilitaire de contrôle du volume système n'a fonctionné")
                    
            elif sys.platform.startswith("win"):
                try:
                    subprocess.run(
                        ["nircmd", "setsysvolume", str(volume_percent * 655)],
                        check=True,
                        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0)
                    )
                except FileNotFoundError:
                    subprocess.run(
                        ["wmic", "sounddev", "where", "Status='OK'", "call", "SetDefaultVolume", str(volume_percent)],
                        check=True,
                        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0)
                    )
            else:
                print("OS non supporté pour le contrôle du volume système")
        except Exception as e:
            print(f"Erreur lors de la définition du volume système: {e}")
