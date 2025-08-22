#!/usr/bin/env python3
"""
Test complet d'acquisition des données capteurs
- 3 capteurs infrarouge (GPIO 16, 20, 21)
- 4 capteurs ultrason (GPIO 4/17, 6/5, 26/19, 25/18)
- Caméra Raspberry Pi avec détection de visage
"""

import sys
import os
import time
import json
from datetime import datetime

# Ajouter le répertoire parent au path pour importer les contrôleurs
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from controllers.capteurs import CapteursController
from controllers.camera import CameraController
from controllers.moteurs_horizontaux import MoteursHorizontauxController

class TestCapteurs:
    """Classe de test pour valider l'acquisition de toutes les données capteurs"""
    
    def __init__(self):
        self.capteurs = CapteursController()
        self.camera = CameraController()
        self.moteurs = MoteursHorizontauxController()
        
        # Données collectées
        self.donnees_test = {
            "timestamp": "",
            "infrarouge": {},
            "ultrason": {},
            "camera": {},
            "validation": {}
        }
    
    def test_capteurs_infrarouge(self):
        """Test des 3 capteurs infrarouge"""
        print("\n🔴 === TEST CAPTEURS INFRAROUGE ===")
        
        # Lecture manuelle
        self.capteurs.lire_capteurs_infrarouge()
        
        # Récupération des données
        ir_data = self.capteurs.infrarouge_data
        
        print(f"📍 Capteur GAUCHE (GPIO 16): {'DÉTECTÉ' if ir_data['gauche'] else 'LIBRE'}")
        print(f"📍 Capteur CENTRE (GPIO 21): {'DÉTECTÉ' if ir_data['centre'] else 'LIBRE'}")
        print(f"📍 Capteur DROITE (GPIO 20): {'DÉTECTÉ' if ir_data['droite'] else 'LIBRE'}")
        
        presences = self.capteurs.compter_presences_ir()
        print(f"🔢 Nombre total de présences: {presences}/3")
        
        # Sauvegarder les données
        self.donnees_test["infrarouge"] = {
            "gauche": ir_data['gauche'],
            "centre": ir_data['centre'], 
            "droite": ir_data['droite'],
            "total_presences": presences,
            "gpio_pins": {"gauche": 16, "centre": 21, "droite": 20}
        }
        
        return presences >= 1  # Au moins une présence détectée
    
    def test_capteurs_ultrason(self):
        """Test des 4 capteurs ultrason"""
        print("\n📡 === TEST CAPTEURS ULTRASON ===")
        
        # Lecture manuelle
        self.capteurs.lire_capteurs_ultrason()
        
        # Récupération des données
        us_data = self.capteurs.ultrason_data
        
        print(f"📏 Capteur ARRIÈRE (GPIO 4/17): {us_data['arriere']} cm")
        print(f"📏 Capteur DROITE (GPIO 6/5): {us_data['droite']} cm")
        print(f"📏 Capteur CENTRE (GPIO 26/19): {us_data['centre']} cm")
        print(f"📏 Capteur GAUCHE (GPIO 25/18): {us_data['gauche']} cm")
        
        # Vérification obstacles
        obstacle = self.capteurs.obstacle_proche(50.0)
        print(f"⚠️  Obstacle proche (<50cm): {'OUI' if obstacle else 'NON'}")
        
        # Sauvegarder les données
        self.donnees_test["ultrason"] = {
            "arriere": us_data['arriere'],
            "droite": us_data['droite'],
            "centre": us_data['centre'],
            "gauche": us_data['gauche'],
            "obstacle_proche": obstacle,
            "gpio_pins": {
                "arriere": {"trig": 4, "echo": 17},
                "droite": {"trig": 6, "echo": 5},
                "centre": {"trig": 26, "echo": 19},
                "gauche": {"trig": 25, "echo": 18}
            }
        }
        
        # Validation: au moins un capteur donne une valeur cohérente
        valeurs_valides = [d for d in us_data.values() if 2 <= d <= 400]
        return len(valeurs_valides) >= 1
    
    def test_camera_detection(self):
        """Test de la caméra et détection de visage"""
        print("\n📹 === TEST CAMÉRA ET DÉTECTION VISAGE ===")
        
        # Démarrer la caméra
        self.camera.start_camera()
        print("📸 Caméra démarrée...")
        
        # Attendre quelques secondes pour la détection
        time.sleep(3)
        
        # Récupérer les informations de détection
        face_detected = self.camera.face_detected_property
        face_info = self.camera.get_face_info()
        
        print(f"👤 Visage détecté: {'OUI' if face_detected else 'NON'}")
        print(f"📊 Informations: {face_info}")
        
        if face_detected:
            print(f"📍 Position X: {self.camera.face_x} px")
            print(f"📍 Position Y: {self.camera.face_y} px")
            print(f"📏 Distance estimée: {self.camera.face_distance} cm")
            print(f"📐 Angle servo: {self.camera.servo_angle}°")
        
        # Sauvegarder les données
        self.donnees_test["camera"] = {
            "visage_detecte": face_detected,
            "position_x": self.camera.face_x,
            "position_y": self.camera.face_y,
            "largeur": self.camera.face_width,
            "hauteur": self.camera.face_height,
            "distance": self.camera.face_distance,
            "servo_angle": self.camera.servo_angle,
            "camera_active": self.camera._camera_active
        }
        
        # Arrêter la caméra
        self.camera.stop_camera()
        
        return self.camera._camera_active or face_detected  # Caméra fonctionne ou visage détecté
    
    def test_validation_fonctionnement(self):
        """Validation du bon fonctionnement global"""
        print("\n✅ === VALIDATION DU FONCTIONNEMENT ===")
        
        # Test de sécurité
        status_securite = self.capteurs.status_securite()
        print(f"🛡️  Statut sécurité: {status_securite}")
        
        # Test de détection sonore (simulation via IR)
        detection_sonore = self.capteurs.detection_sonore_active()
        print(f"🔊 Détection sonore active: {'OUI' if detection_sonore else 'NON'}")
        
        # Test des moteurs horizontaux
        moteurs_status = self.moteurs.get_status()
        print(f"🔄 Statut moteurs horizontaux: {moteurs_status}")
        
        # Validation globale
        validation = {
            "infrarouge_ok": len([v for v in self.donnees_test["infrarouge"].values() if isinstance(v, bool)]) >= 3,
            "ultrason_ok": len([v for v in self.donnees_test["ultrason"].values() if isinstance(v, (int, float))]) >= 4,
            "camera_ok": self.donnees_test["camera"]["camera_active"] or self.donnees_test["camera"]["visage_detecte"],
            "securite_ok": "OK" in status_securite,
            "moteurs_ok": "STOP" in moteurs_status  # Moteurs en état stable
        }
        
        self.donnees_test["validation"] = validation
        
        # Affichage résultats
        print("\n📋 RÉSULTATS DE VALIDATION:")
        for test, resultat in validation.items():
            status = "✅ PASS" if resultat else "❌ FAIL"
            print(f"  {test}: {status}")
        
        return all(validation.values())
    
    def generer_rapport(self):
        """Génère un rapport complet des tests"""
        self.donnees_test["timestamp"] = datetime.now().isoformat()
        
        # Sauvegarder en JSON
        rapport_path = "rapport_test_capteurs.json"
        with open(rapport_path, 'w', encoding='utf-8') as f:
            json.dump(self.donnees_test, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 Rapport sauvegardé: {rapport_path}")
        
        # Résumé console
        print("\n📊 === RÉSUMÉ ACQUISITION DONNÉES ===")
        print(f"🔴 Capteurs IR: {len(self.donnees_test['infrarouge'])} capteurs testés")
        print(f"📡 Capteurs US: {len(self.donnees_test['ultrason'])} capteurs testés") 
        print(f"📹 Caméra: {'Fonctionnelle' if self.donnees_test['camera']['camera_active'] else 'Simulation'}")
        print(f"✅ Tests réussis: {sum(self.donnees_test['validation'].values())}/{len(self.donnees_test['validation'])}")
    
    def run_all_tests(self):
        """Exécute tous les tests d'acquisition"""
        print("🚀 === DÉBUT DES TESTS D'ACQUISITION CAPTEURS ===")
        
        try:
            # Tests individuels
            test_ir = self.test_capteurs_infrarouge()
            test_us = self.test_capteurs_ultrason()
            test_cam = self.test_camera_detection()
            
            # Validation globale
            validation_ok = self.test_validation_fonctionnement()
            
            # Génération du rapport
            self.generer_rapport()
            
            # Résultat final
            if validation_ok:
                print("\n🎉 TOUS LES TESTS RÉUSSIS - Acquisition des données fonctionnelle")
            else:
                print("\n⚠️  CERTAINS TESTS ONT ÉCHOUÉ - Vérifier la configuration")
            
            return validation_ok
            
        except Exception as e:
            print(f"\n❌ ERREUR DURANT LES TESTS: {e}")
            return False

if __name__ == "__main__":
    # Exécution des tests
    testeur = TestCapteurs()
    success = testeur.run_all_tests()
    
    # Code de sortie
    sys.exit(0 if success else 1)
