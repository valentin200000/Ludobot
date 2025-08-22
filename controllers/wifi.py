import platform
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

# Importer notre gestionnaire WiFi avec son nouveau nom
from gestionnaire_wifi import WifiManager

class WifiController(QObject):
    """Contrôleur WiFi pour l'application LudoBot"""
    networksChanged = Signal()
    connectionStatusChanged = Signal(str)
    
    def __init__(self):
        super().__init__()
        # Créer une instance de notre gestionnaire WiFi
        self._wifi_manager = WifiManager()
        
        # Connecter les signaux du gestionnaire WiFi à nos signaux
        self._wifi_manager.networksChanged.connect(self.networksChanged)
        self._wifi_manager.connectionStatusChanged.connect(self.connectionStatusChanged)
    
    @Property(list, notify=networksChanged)
    def networks(self):
        """Retourne la liste des réseaux WiFi disponibles"""
        return self._wifi_manager.networks
    
    @Slot(result=str)
    def currentNetwork(self):
        """Retourne le nom du réseau WiFi actuellement connecté"""
        return self._wifi_manager.currentNetwork()
    
    @Slot()
    def scan_networks(self):
        """Lance un scan des réseaux WiFi disponibles"""
        self._wifi_manager.scan_networks()
    
    @Slot(str, str, str)
    def addNetwork(self, ssid, password, security_type):
        """Ajoute (ou connecte) un réseau WiFi manuellement.

        Args:
            ssid (str): Nom du réseau.
            password (str): Mot de passe.
            security_type (str): Type de sécurité ("WPA/WPA2", "WEP", "Aucune").
        """
        self._wifi_manager.connect_to_network(ssid, password, security_type)
    
    @Slot(str, str)
    def connect_to_network(self, ssid, password):
        """Surcharge pour QML à 2 arguments (réseaux ouverts ou mot de passe connu)."""
        self.connect_to_network_full(ssid, password, "")
    
    @Slot(str, str, int)
    def connect_to_network_full(self, ssid, password, security_type=0):
        """Se connecte à un réseau WiFi
        
        Args:
            ssid (str): Nom du réseau WiFi
            password (str): Mot de passe du réseau WiFi
            security_type (int, optional): Type de sécurité. Par défaut à 0.
        """
        if isinstance(security_type, str) and security_type:
            self._wifi_manager.connect_to_network(ssid, password, security_type)
        else:
            # Appel classique (réseau ouvert ou déjà détecté)
            self._wifi_manager.connect_to_network(ssid, password)
            
    @Slot()
    def disconnect_network(self):
        """Déconnecte le réseau WiFi actuel"""
        self._wifi_manager.disconnect_network()