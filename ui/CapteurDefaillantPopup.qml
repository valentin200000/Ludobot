import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: capteurDefaillantPopup
    
    property var capteursDefaillants: []
    
    width: 400
    height: 300
    anchors.centerIn: parent
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        color: "#FFEBEE"
        border.color: "#F44336"
        border.width: 2
        radius: 10
        
        // Animation de pulsation pour attirer l'attention
        SequentialAnimation on opacity {
            running: capteurDefaillantPopup.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.8; duration: 1000 }
            NumberAnimation { to: 1.0; duration: 1000 }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Titre d'alerte
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "⚠️"
                font.pixelSize: 32
                color: "#F44336"
            }
            
            Text {
                text: "ALERTE CAPTEURS"
                font.pixelSize: 20
                font.bold: true
                color: "#F44336"
                Layout.fillWidth: true
            }
        }
        
        // Message principal
        Text {
            text: "Les capteurs suivants ne répondent pas :"
            font.pixelSize: 16
            font.bold: true
            color: "#333"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        
        // Liste des capteurs défaillants
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: listeCapteurs
                model: capteurDefaillantPopup.capteursDefaillants
                
                delegate: Rectangle {
                    width: listeCapteurs.width
                    height: 40
                    color: index % 2 === 0 ? "#FFCDD2" : "#FFEBEE"
                    radius: 5
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            text: "❌"
                            font.pixelSize: 16
                        }
                        
                        Text {
                            text: getCapteurDescription(modelData)
                            font.pixelSize: 14
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: getCapteurGPIO(modelData)
                            font.pixelSize: 12
                            color: "#666"
                        }
                    }
                }
            }
        }
        
        // Boutons d'action
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Button {
                text: "🔄 Réessayer"
                Layout.fillWidth: true
                onClicked: {
                    capteursController.reset_capteurs_defaillants()
                    capteursController.lire_tous_capteurs()
                    capteurDefaillantPopup.close()
                }
                Material.background: "#FF9800"
            }
            
            Button {
                text: "🛠️ Diagnostics"
                Layout.fillWidth: true
                onClicked: {
                    // Ouvrir la page de test des capteurs
                    stackView.push("CapteurTestPage.qml")
                    capteurDefaillantPopup.close()
                }
                Material.background: "#2196F3"
            }
            
            Button {
                text: "❌ Ignorer"
                Layout.fillWidth: true
                onClicked: {
                    capteurDefaillantPopup.close()
                }
                Material.background: "#9E9E9E"
            }
        }
    }
    
    // Fonctions utilitaires
    function getCapteurDescription(capteurId) {
        if (capteurId.startsWith("IR_")) {
            var position = capteurId.substring(3)
            return "Capteur Infrarouge " + position.toUpperCase()
        } else if (capteurId.startsWith("US_")) {
            var position = capteurId.substring(3)
            return "Capteur Ultrason " + position.toUpperCase()
        }
        return capteurId
    }
    
    function getCapteurGPIO(capteurId) {
        var gpioMap = {
            "IR_gauche": "GPIO 16",
            "IR_centre": "GPIO 21", 
            "IR_droite": "GPIO 20",
            "US_arriere": "GPIO 4/17",
            "US_droite": "GPIO 6/5",
            "US_centre": "GPIO 26/19",
            "US_gauche": "GPIO 25/18"
        }
        return gpioMap[capteurId] || "GPIO ?"
    }
    
    function afficherAlerte(capteurs) {
        capteursDefaillants = capteurs
        open()
    }
    
    // Connexions aux signaux du contrôleur
    Connections {
        target: capteursController
        
        function onCapteur_defaillant(capteurId) {
            // Ajouter le capteur à la liste s'il n'y est pas déjà
            var capteurs = capteursController.get_capteurs_defaillants()
            if (capteurs.length > 0) {
                capteurDefaillantPopup.afficherAlerte(capteurs)
            }
        }
    }
    
    // Animation d'ouverture
    enter: Transition {
        NumberAnimation {
            property: "scale"
            from: 0.5
            to: 1.0
            duration: 300
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 300
        }
    }
    
    // Animation de fermeture
    exit: Transition {
        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.5
            duration: 200
        }
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 200
        }
    }
}
