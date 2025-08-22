import subprocess
import re
import time
import platform
import os
import shutil
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

class WifiManager(QObject):
    """
    Gestionnaire WiFi simple et robuste qui utilise directement les commandes système
    pour gérer les connexions WiFi sur Linux en utilisant NetworkManager (nmcli).
    """
    networksChanged = Signal()
    connectionStatusChanged = Signal(str)
    
    def __init__(self):
        super().__init__()
        self._networks = []
        self._current_network = ""
        self._timer = QTimer()

        # Activer les scans uniquement si nmcli est disponible (Linux)
        if self._can_use_nmcli():
            self._timer.timeout.connect(self.scan_networks)
            self._timer.start(5000)  # Scan toutes les 5 secondes
            # Scan initial
            self.scan_networks()
        else:
            # Environnements non supportés (ex: Windows/Mac sans nmcli)
            print("WiFi: nmcli indisponible sur cette plateforme — fonctionnalités WiFi désactivées.")
    
    @Property(list, notify=networksChanged)
    def networks(self):
        return self._networks
    
    def is_wifi_enabled(self):
        """Vérifie si le WiFi est activé"""
        if not self._can_use_nmcli():
            return False
        try:
            result = subprocess.check_output(["nmcli", "-t", "-f", "DEVICE,STATE", "device"],
                                            text=True, universal_newlines=True)
            # Chercher un périphérique WiFi actif
            for line in result.splitlines():
                parts = line.split(":")
                if len(parts) >= 2 and "wifi" in parts[0]:
                    return parts[1] != "unavailable" and parts[1] != "unmanaged"
            return False
        except Exception:
            return False
    
    @Slot(result=bool)
    def isWifiEnabled(self):
        return self.is_wifi_enabled()
    
    @Slot(result=str)
    def currentNetwork(self):
        if not self._can_use_nmcli():
            return "Non connecté"
        try:
            result = subprocess.check_output(["nmcli", "-t", "-f", "ACTIVE,SSID", "device", "wifi"],
                                            text=True, universal_newlines=True)
            for line in result.splitlines():
                parts = line.split(":")
                if len(parts) >= 2 and parts[0] == "yes":
                    ssid = parts[1]
                    if ssid:
                        self._current_network = ssid
                        return ssid
            return "Non connecté"
        except Exception as e:
            print(f"Erreur lors de la récupération du réseau actuel: {e}")
            return "Non connecté"
    
    @Slot()
    def scan_networks(self):
        if not self._can_use_nmcli():
            # Pas de scan sur plateformes non supportées
            return
        try:
            # Récupérer le réseau actuel
            current = self.currentNetwork()

            # Récupérer la liste des réseaux disponibles en utilisant nmcli
            result = subprocess.check_output(["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "device", "wifi", "list"],
                                            text=True, universal_newlines=True)

            networks = []

            # Traiter chaque ligne du résultat
            for line in result.splitlines():
                parts = line.split(":")
                if len(parts) >= 4:
                    ssid = parts[0]

                    # Ne pas ajouter les réseaux sans SSID ou ceux déjà dans la liste
                    if not ssid or ssid in [n["ssid"] for n in networks]:
                        continue

                    try:
                        signal_percent = int(parts[1])
                        # Convertir le pourcentage en niveau (0-4)
                        signal = min(4, signal_percent // 20)
                    except ValueError:
                        signal = 0

                    security = "Open"
                    if parts[2] and parts[2] != "--":
                        security = parts[2]

                    connected = parts[3] == "yes"

                    networks.append({
                        "ssid": ssid,
                        "security": security,
                        "signal": signal,
                        "connected": connected
                    })

            # Trier les réseaux par force de signal (décroissant)
            networks.sort(key=lambda x: x["signal"], reverse=True)

            # Mettre à jour la liste des réseaux si elle a changé
            if networks != self._networks:
                self._networks = networks
                self.networksChanged.emit()

        except Exception as e:
            print(f"Erreur lors du scan des réseaux: {e}")
    
    @Slot(str, str, str)
    def connect_to_network(self, ssid, password, security_type=None):
        """
        Se connecte à un réseau WiFi en utilisant directement les commandes Linux.
        
        Args:
            ssid (str): Nom du réseau WiFi
            password (str): Mot de passe du réseau WiFi
            security_type (str, optional): Type de sécurité (WPA/WPA2, WEP, Aucune). Si None, détecté automatiquement.
        """
        if not self._can_use_nmcli():
            self.connectionStatusChanged.emit("Fonctionnalité WiFi indisponible sur cette plateforme")
            return
        try:
            self.connectionStatusChanged.emit(f"Tentative de connexion à {ssid}...")
            print(f"Tentative de connexion au réseau: {ssid}")
            
            # Vérifier si le réseau est déjà connu (a déjà une connexion enregistrée)
            known_connections = subprocess.check_output(["nmcli", "-t", "-f", "NAME", "connection", "show"], 
                                                      text=True, universal_newlines=True)
            is_known = any(conn.strip() == ssid for conn in known_connections.splitlines())
            
            if is_known:
                # Si le réseau est connu, on se connecte à lui
                print(f"Connexion à un réseau connu: {ssid}")
                result = subprocess.run(["nmcli", "connection", "up", ssid], 
                                      capture_output=True, text=True, check=False)
                
                if result.returncode == 0:
                    print(f"Connexion réussie à {ssid}")
                    self.connectionStatusChanged.emit(f"Connexion réussie à {ssid}")
                else:
                    print(f"Échec de la connexion: {result.stderr}")
                    self.connectionStatusChanged.emit(f"Échec de la connexion à {ssid}")
            else:
                # Déterminer si le réseau est ouvert ou sécurisé
                is_open = False
                for network in self._networks:
                    if network["ssid"] == ssid:
                        is_open = network["security"] == "Open"
                        break
                
                # Pour un réseau ouvert
                if is_open:
                    print(f"Connexion à un réseau ouvert: {ssid}")
                    result = subprocess.run(["nmcli", "device", "wifi", "connect", ssid], 
                                          capture_output=True, text=True, check=False)
                else:
                    # Pour un réseau sécurisé
                    print(f"Connexion à un réseau sécurisé: {ssid}")
                    result = subprocess.run(["nmcli", "device", "wifi", "connect", ssid, "password", password], 
                                          capture_output=True, text=True, check=False)
                
                if result.returncode == 0:
                    print(f"Connexion réussie à {ssid}")
                    self.connectionStatusChanged.emit(f"Connexion réussie à {ssid}")
                else:
                    print(f"Échec de la connexion: {result.stderr}")
                    self.connectionStatusChanged.emit(f"Échec de la connexion à {ssid}")
            
            # Attendre un moment puis rafraîchir la liste des réseaux
            time.sleep(2)
            self.scan_networks()
            
        except Exception as e:
            print(f"Erreur globale lors de la connexion: {e}")
            self.connectionStatusChanged.emit(f"Erreur: {str(e)}")
    
    @Slot()
    def disconnect_network(self):
        """Déconnecte le réseau WiFi actuel"""
        if not self._can_use_nmcli():
            self.connectionStatusChanged.emit("Fonctionnalité WiFi indisponible sur cette plateforme")
            return
        try:
            self.connectionStatusChanged.emit("Déconnexion du réseau WiFi...")
            print("Déconnexion du réseau WiFi...")
            
            # Obtenir le réseau actuel
            current = self.currentNetwork()
            if current != "Non connecté":
                # D'abord obtenir le nom de l'interface WiFi
                try:
                    # Obtenir la liste des interfaces réseau
                    devices = subprocess.check_output(["nmcli", "-t", "-f", "DEVICE,TYPE", "device"], 
                                                     text=True, universal_newlines=True)
                    
                    # Chercher l'interface WiFi
                    wifi_interface = None
                    for line in devices.splitlines():
                        parts = line.split(":")
                        if len(parts) >= 2 and parts[1] == "wifi":
                            wifi_interface = parts[0]
                            break
                    
                    if wifi_interface:
                        print(f"Interface WiFi trouvée: {wifi_interface}")
                        # Déconnecter l'interface spécifique
                        result = subprocess.run(["nmcli", "device", "disconnect", wifi_interface], 
                                              capture_output=True, text=True, check=False)
                        
                        if result.returncode == 0:
                            print("Déconnexion réussie")
                            self.connectionStatusChanged.emit("Déconnexion réussie")
                        else:
                            print(f"Échec de la déconnexion: {result.stderr}")
                            self.connectionStatusChanged.emit(f"Échec de la déconnexion: {result.stderr}")
                    else:
                        # Méthode alternative: déconnecter en utilisant le nom du réseau
                        print("Interface WiFi non trouvée, tentative de déconnexion par SSID")
                        result = subprocess.run(["nmcli", "connection", "down", current], 
                                              capture_output=True, text=True, check=False)
                        
                        if result.returncode == 0:
                            print("Déconnexion réussie via le nom du réseau")
                            self.connectionStatusChanged.emit("Déconnexion réussie")
                        else:
                            print(f"Échec de la déconnexion via le nom du réseau: {result.stderr}")
                            self.connectionStatusChanged.emit(f"Échec de la déconnexion: Dispositif WiFi non trouvé")
                            
                except Exception as e:
                    print(f"Erreur lors de la détermination de l'interface WiFi: {e}")
                    self.connectionStatusChanged.emit(f"Erreur: {str(e)}")
            else:
                print("Déjà déconnecté")
                self.connectionStatusChanged.emit("Déjà déconnecté")
                
            # Attendre un moment puis rafraîchir la liste des réseaux
            time.sleep(1)
            self.scan_networks()
            
        except Exception as e:
            print(f"Erreur lors de la déconnexion: {e}")
            self.connectionStatusChanged.emit(f"Erreur lors de la déconnexion: {e}")

    def _can_use_nmcli(self) -> bool:
        """Retourne True si nous sommes sur Linux et que nmcli est disponible."""
        return platform.system() == "Linux" and shutil.which("nmcli") is not None
    
    def _check_connection_status(self):
        """Vérifie l'état de la connexion et met à jour le statut"""
        current = self.currentNetwork()
        if current != "Non connecté":
            success_msg = f"Connecté à {current}"
            self.connectionStatusChanged.emit(success_msg)
            print(success_msg)
        else:
            error_msg = "Échec de connexion"
            self.connectionStatusChanged.emit(error_msg)
            print(error_msg)
        
        # Mettre à jour la liste des réseaux
        self.scan_networks()
