import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: capteurTestPage
    title: "Test des Capteurs"
    
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            
            ToolButton {
                text: "← Retour"
                onClicked: stackView.pop()
            }
            
            Label {
                text: "🔍 Test des Capteurs"
                font.pixelSize: 24
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Switch {
                id: surveillanceSwitch
                text: "Auto"
                checked: true
                onCheckedChanged: {
                    if (checked) {
                        capteursController.demarrer_surveillance()
                    } else {
                        capteursController.arreter_surveillance()
                    }
                }
            }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Statut de sécurité global
            Rectangle {
                Layout.fillWidth: true
                height: 80
                radius: 10
                color: {
                    var status = capteursController.status_securite()
                    if (status.includes("DANGER")) return "#FFEBEE"
                    if (status.includes("ATTENTION")) return "#FFF8E1"
                    return "#E8F5E9"
                }
                border.color: {
                    var status = capteursController.status_securite()
                    if (status.includes("DANGER")) return "#C62828"
                    if (status.includes("ATTENTION")) return "#F9A825"
                    return "#2E7D32"
                }
                border.width: 2
                
                ColumnLayout {
                    anchors.centerIn: parent
                    
                    Text {
                        text: "🛡️ STATUT SÉCURITÉ"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: capteursController.status_securite()
                        font.pixelSize: 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        color: {
                            var status = capteursController.status_securite()
                            if (status.includes("DANGER")) return "#C62828"
                            if (status.includes("ATTENTION")) return "#F57C00"
                            return "#2E7D32"
                        }
                    }
                }
            }
            
            // Section Capteurs Infrarouge
            GroupBox {
                title: "🔴 Capteurs Infrarouge (Détection de présence)"
                Layout.fillWidth: true
                
                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    columnSpacing: 20
                    rowSpacing: 15
                    
                    // En-têtes
                    Text { text: "Position"; font.bold: true }
                    Text { text: "GPIO"; font.bold: true }
                    Text { text: "Statut"; font.bold: true }
                    
                    // Capteur Gauche
                    Text { text: "👈 Gauche" }
                    Text { text: "GPIO 16"; color: "#666" }
                    Rectangle {
                        width: 100
                        height: 30
                        radius: 15
                        color: capteursController.infrarouge_data.gauche ? "#4CAF50" : "#F44336"
                        
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.infrarouge_data.gauche ? "DÉTECTÉ" : "LIBRE"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    
                    // Capteur Centre
                    Text { text: "⬆️ Centre" }
                    Text { text: "GPIO 21"; color: "#666" }
                    Rectangle {
                        width: 100
                        height: 30
                        radius: 15
                        color: capteursController.infrarouge_data.centre ? "#4CAF50" : "#F44336"
                        
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.infrarouge_data.centre ? "DÉTECTÉ" : "LIBRE"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    
                    // Capteur Droite
                    Text { text: "👉 Droite" }
                    Text { text: "GPIO 20"; color: "#666" }
                    Rectangle {
                        width: 100
                        height: 30
                        radius: 15
                        color: capteursController.infrarouge_data.droite ? "#4CAF50" : "#F44336"
                        
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.infrarouge_data.droite ? "DÉTECTÉ" : "LIBRE"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                }
                
                // Compteur de présences
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 10
                    width: 150
                    height: 40
                    radius: 20
                    color: capteursController.compter_presences_ir() >= 3 ? "#4CAF50" : "#FF9800"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Présences: " + capteursController.compter_presences_ir() + "/3"
                        color: "white"
                        font.bold: true
                    }
                }
            }
            
            // Section Capteurs Ultrason
            GroupBox {
                title: "📡 Capteurs Ultrason (Distance en cm)"
                Layout.fillWidth: true
                
                GridLayout {
                    anchors.fill: parent
                    columns: 4
                    columnSpacing: 20
                    rowSpacing: 15
                    
                    // En-têtes
                    Text { text: "Position"; font.bold: true }
                    Text { text: "GPIO (Trig/Echo)"; font.bold: true }
                    Text { text: "Distance"; font.bold: true }
                    Text { text: "Statut"; font.bold: true }
                    
                    // Capteur Arrière
                    Text { text: "⬇️ Arrière" }
                    Text { text: "GPIO 4/17"; color: "#666" }
                    Text { 
                        text: capteursController.ultrason_data.arriere + " cm"
                        font.bold: true
                        color: capteursController.ultrason_data.arriere < 50 ? "#F44336" : "#4CAF50"
                    }
                    Rectangle {
                        width: 80
                        height: 25
                        radius: 12
                        color: capteursController.ultrason_data.arriere < 50 ? "#F44336" : "#4CAF50"
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.ultrason_data.arriere < 50 ? "PROCHE" : "OK"
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    
                    // Capteur Droite
                    Text { text: "👉 Droite" }
                    Text { text: "GPIO 6/5"; color: "#666" }
                    Text { 
                        text: capteursController.ultrason_data.droite + " cm"
                        font.bold: true
                        color: capteursController.ultrason_data.droite < 50 ? "#F44336" : "#4CAF50"
                    }
                    Rectangle {
                        width: 80
                        height: 25
                        radius: 12
                        color: capteursController.ultrason_data.droite < 50 ? "#F44336" : "#4CAF50"
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.ultrason_data.droite < 50 ? "PROCHE" : "OK"
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    
                    // Capteur Centre
                    Text { text: "⬆️ Centre" }
                    Text { text: "GPIO 26/19"; color: "#666" }
                    Text { 
                        text: capteursController.ultrason_data.centre + " cm"
                        font.bold: true
                        color: capteursController.ultrason_data.centre < 50 ? "#F44336" : "#4CAF50"
                    }
                    Rectangle {
                        width: 80
                        height: 25
                        radius: 12
                        color: capteursController.ultrason_data.centre < 50 ? "#F44336" : "#4CAF50"
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.ultrason_data.centre < 50 ? "PROCHE" : "OK"
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    
                    // Capteur Gauche
                    Text { text: "👈 Gauche" }
                    Text { text: "GPIO 25/18"; color: "#666" }
                    Text { 
                        text: capteursController.ultrason_data.gauche + " cm"
                        font.bold: true
                        color: capteursController.ultrason_data.gauche < 50 ? "#F44336" : "#4CAF50"
                    }
                    Rectangle {
                        width: 80
                        height: 25
                        radius: 12
                        color: capteursController.ultrason_data.gauche < 50 ? "#F44336" : "#4CAF50"
                        Text {
                            anchors.centerIn: parent
                            text: capteursController.ultrason_data.gauche < 50 ? "PROCHE" : "OK"
                            color: "white"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }
            
            // Boutons de contrôle
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Button {
                    text: "🔄 Lecture Manuelle"
                    Layout.fillWidth: true
                    onClicked: capteursController.lire_tous_capteurs()
                    enabled: !surveillanceSwitch.checked
                }
                
                Button {
                    text: "📊 Logs Détaillés"
                    Layout.fillWidth: true
                    onClicked: {
                        console.log("=== ÉTAT DES CAPTEURS ===")
                        console.log("IR Gauche (GPIO 16):", capteursController.infrarouge_data.gauche)
                        console.log("IR Centre (GPIO 21):", capteursController.infrarouge_data.centre)
                        console.log("IR Droite (GPIO 20):", capteursController.infrarouge_data.droite)
                        console.log("US Arrière (GPIO 4/17):", capteursController.ultrason_data.arriere, "cm")
                        console.log("US Droite (GPIO 6/5):", capteursController.ultrason_data.droite, "cm")
                        console.log("US Centre (GPIO 26/19):", capteursController.ultrason_data.centre, "cm")
                        console.log("US Gauche (GPIO 25/18):", capteursController.ultrason_data.gauche, "cm")
                        console.log("Statut sécurité:", capteursController.status_securite())
                    }
                }
            }
        }
    }
}
