import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: cameraTrackingPage
    title: "Tracking Caméra"
    
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            
            ToolButton {
                text: "← Retour"
                onClicked: stackView.pop()
            }
            
            Label {
                text: "📹 Tracking Caméra & Servo"
                font.pixelSize: 24
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Switch {
                id: autoTrackingSwitch
                text: "Auto"
                checked: false
                onCheckedChanged: {
                    if (checked) {
                        robotManager.force_start_tracking()
                    } else {
                        robotManager.force_stop_tracking()
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
            
            // Statut du robot
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 10
                color: {
                    var state = robotManager.robot_state
                    if (state === "SECURITY_STOP") return "#FFEBEE"
                    if (state === "TRACKING") return "#E8F5E9"
                    if (state === "LISTENING") return "#FFF8E1"
                    return "#F5F5F5"
                }
                border.color: {
                    var state = robotManager.robot_state
                    if (state === "SECURITY_STOP") return "#C62828"
                    if (state === "TRACKING") return "#2E7D32"
                    if (state === "LISTENING") return "#F9A825"
                    return "#9E9E9E"
                }
                border.width: 2
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        text: "🤖 ÉTAT DU ROBOT"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: {
                            var state = robotManager.robot_state
                            switch(state) {
                                case "IDLE": return "🟢 EN ATTENTE"
                                case "LISTENING": return "🟡 ÉCOUTE ACTIVE"
                                case "TRACKING": return "🔵 TRACKING ACTIF"
                                case "SECURITY_STOP": return "🔴 ARRÊT SÉCURITÉ"
                                default: return state
                            }
                        }
                        font.pixelSize: 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        color: {
                            var state = robotManager.robot_state
                            if (state === "SECURITY_STOP") return "#C62828"
                            if (state === "TRACKING") return "#2E7D32"
                            if (state === "LISTENING") return "#F57C00"
                            return "#666"
                        }
                    }
                }
            }
            
            // Affichage de la caméra
            GroupBox {
                title: "📹 Vue Caméra"
                Layout.fillWidth: true
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                    
                    // Zone d'affichage de l'image
                    Rectangle {
                        Layout.fillWidth: true
                        height: 300
                        color: "#000"
                        border.color: "#666"
                        border.width: 1
                        radius: 5
                        
                        Image {
                            id: cameraImage
                            anchors.fill: parent
                            anchors.margins: 2
                            fillMode: Image.PreserveAspectFit
                            
                            // Connecter au signal de la caméra
                            Connections {
                                target: cameraController
                                function onCamera_frame_ready(frame) {
                                    // Note: En réalité, il faudrait convertir QImage en source d'image
                                    // Pour la démo, on affiche un placeholder
                                }
                            }
                        }
                        
                        // Placeholder si pas d'image
                        Text {
                            anchors.centerIn: parent
                            text: cameraController._camera_active ? "📹 Flux caméra actif" : "📹 Caméra inactive"
                            color: "#999"
                            font.pixelSize: 16
                            visible: !cameraImage.source
                        }
                        
                        // Overlay d'informations de tracking
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 10
                            width: trackingInfo.width + 20
                            height: trackingInfo.height + 10
                            color: "#80000000"
                            radius: 5
                            visible: cameraController.face_detected_property
                            
                            Text {
                                id: trackingInfo
                                anchors.centerIn: parent
                                text: "🎯 Visage détecté\nPos: (" + cameraController.face_x + ", " + cameraController.face_y + ")\nDistance: " + cameraController.face_distance + " cm"
                                color: "#00FF00"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                    
                    // Informations de détection
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 10
                        
                        Text { text: "Visage détecté:"; font.bold: true }
                        Rectangle {
                            width: 80
                            height: 25
                            radius: 12
                            color: cameraController.face_detected_property ? "#4CAF50" : "#F44336"
                            Text {
                                anchors.centerIn: parent
                                text: cameraController.face_detected_property ? "OUI" : "NON"
                                color: "white"
                                font.bold: true
                                font.pixelSize: 12
                            }
                        }
                        
                        Text { text: "Position X:"; font.bold: true }
                        Text { text: cameraController.face_x + " px"; color: "#666" }
                        
                        Text { text: "Position Y:"; font.bold: true }
                        Text { text: cameraController.face_y + " px"; color: "#666" }
                        
                        Text { text: "Distance:"; font.bold: true }
                        Text { text: cameraController.face_distance + " cm"; color: "#666" }
                    }
                }
            }
            
            // Contrôle des moteurs horizontaux
            GroupBox {
                title: "↔️ Rotation Horizontale (Pont en H)"
                Layout.fillWidth: true
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                    
                    // Statut des moteurs
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        radius: 5
                        color: moteursHorizontauxController.moteurs_actifs ? "#E8F5E9" : "#F5F5F5"
                        border.color: moteursHorizontauxController.moteurs_actifs ? "#4CAF50" : "#9E9E9E"
                        border.width: 1
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 15
                            
                            Text {
                                text: "Direction:"
                                font.bold: true
                            }
                            
                            Text {
                                text: moteursHorizontauxController.direction_rotation
                                font.bold: true
                                color: {
                                    var dir = moteursHorizontauxController.direction_rotation
                                    if (dir === "STOP") return "#666"
                                    return "#1976D2"
                                }
                            }
                            
                            Text {
                                text: "Vitesse:"
                                font.bold: true
                            }
                            
                            Text {
                                text: moteursHorizontauxController.vitesse_actuelle + "%"
                                font.bold: true
                                color: "#1976D2"
                            }
                        }
                    }
                    
                    // Contrôles manuels
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Button {
                            text: "⬅️ Gauche"
                            Layout.fillWidth: true
                            onClicked: moteursHorizontauxController.rotation_manuelle("GAUCHE", 50)
                            enabled: !robotManager.tracking_active
                        }
                        
                        Button {
                            text: "⏹️ Stop"
                            Layout.fillWidth: true
                            onClicked: moteursHorizontauxController.arreter_moteurs()
                        }
                        
                        Button {
                            text: "➡️ Droite"
                            Layout.fillWidth: true
                            onClicked: moteursHorizontauxController.rotation_manuelle("DROITE", 50)
                            enabled: !robotManager.tracking_active
                        }
                    }
                }
            }
            
            // Contrôle du servo
            GroupBox {
                title: "🔧 Contrôle Servo Moteur (Vertical)"
                Layout.fillWidth: true
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                    
                    // Affichage angle actuel
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        radius: 5
                        color: "#E3F2FD"
                        border.color: "#1976D2"
                        border.width: 1
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Text {
                                text: "Angle actuel:"
                                font.bold: true
                                font.pixelSize: 16
                            }
                            
                            Text {
                                text: Math.round(cameraController.servo_angle * 10) / 10 + "°"
                                font.bold: true
                                font.pixelSize: 20
                                color: "#1976D2"
                            }
                        }
                    }
                    
                    // Slider de contrôle manuel
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text { text: "-90°"; font.bold: true }
                        
                        Slider {
                            id: servoSlider
                            Layout.fillWidth: true
                            from: -90
                            to: 90
                            value: cameraController.servo_angle
                            stepSize: 1
                            
                            onValueChanged: {
                                if (!robotManager.tracking_active) {
                                    cameraController.set_servo_angle(value)
                                }
                            }
                            
                            // Mettre à jour le slider quand l'angle change
                            Connections {
                                target: cameraController
                                function onServo_angle_changed() {
                                    servoSlider.value = cameraController.servo_angle
                                }
                            }
                        }
                        
                        Text { text: "+90°"; font.bold: true }
                    }
                    
                    // Boutons de contrôle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Button {
                            text: "⬆️ Haut"
                            Layout.fillWidth: true
                            onClicked: cameraController.set_servo_angle(cameraController.servo_angle - 10)
                            enabled: !robotManager.tracking_active
                        }
                        
                        Button {
                            text: "🎯 Centre"
                            Layout.fillWidth: true
                            onClicked: cameraController.center_servo()
                        }
                        
                        Button {
                            text: "⬇️ Bas"
                            Layout.fillWidth: true
                            onClicked: cameraController.set_servo_angle(cameraController.servo_angle + 10)
                            enabled: !robotManager.tracking_active
                        }
                    }
                }
            }
            
            // Boutons de contrôle principal
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Button {
                    text: "▶️ Démarrer Caméra"
                    Layout.fillWidth: true
                    onClicked: cameraController.start_camera()
                    enabled: !cameraController._camera_active
                }
                
                Button {
                    text: "⏹️ Arrêter Caméra"
                    Layout.fillWidth: true
                    onClicked: cameraController.stop_camera()
                    enabled: cameraController._camera_active
                }
                
                Button {
                    text: "🔄 Reset Robot"
                    Layout.fillWidth: true
                    onClicked: robotManager.reset_robot()
                }
                
                Button {
                    text: "🚨 Urgence"
                    Layout.fillWidth: true
                    onClicked: robotManager.emergency_stop()
                    Material.background: "#F44336"
                }
            }
            
            // Informations détaillées
            GroupBox {
                title: "📊 Informations Détaillées"
                Layout.fillWidth: true
                
                ScrollView {
                    anchors.fill: parent
                    height: 150
                    
                    Text {
                        text: robotManager.get_robot_status()
                        font.family: "Courier"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }
}
