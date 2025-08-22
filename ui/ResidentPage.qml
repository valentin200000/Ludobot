import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: residentPage
    title: qsTr("Page résident")
    // Propriété pour déterminer le mode d'application (lié au global root.appMode si dispo)
    property string appMode: typeof root !== 'undefined' && root.appMode ? root.appMode : "enfant"
    
    background: Rectangle { 
        color: Style.backgroundColor
    }

    // Navigation Header
    header: ToolBar {
        id: toolbar
        Material.foreground: "white"
        Material.background: Style.accentColor
        height: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            ToolButton {
                contentItem: Text {
                    text: "←" // Emoji flèche gauche
                    font.pixelSize: 28
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: stackView.pop()
                Layout.alignment: Qt.AlignLeft
            }

            Label {
                text: "Espace résident"
                font.pixelSize: 24
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }
            
            Item {
                // Spacer
                Layout.preferredWidth: 48
            }
        }
    }
    
    // Effet sonore pour le clic (simulé)
    Timer {
        id: clickSound
        interval: 5
        function play() {
            start()
        }
    }
    
    // Contenu principal
    Item {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        
        // ListView horizontal avec défilement pour organiser les cartes
        ListView {
            id: categoryListView
            anchors.centerIn: parent
            width: parent.width - 40
            height: 680 // Grand format pour meilleure visibilité
            orientation: ListView.Horizontal
            spacing: 30
            clip: true
            flickDeceleration: 1500
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            
            // Animation fluide pour le swipe
            highlightMoveDuration: 300
            highlightMoveVelocity: -1
            
            // Points indicateurs de pagination
            footer: Item {
                width: categoryListView.width // éviter boucle de liaison sur parent.width
                height: 50
                
                Row {
                    height: 20
                    spacing: 10
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Repeater {
                        model: 8 // Nombre de boutons
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: categoryListView.currentIndex === index ? "#2196F3" : "#DDDDDD"
                        }
                    }
                }
            }
            
            model: ListModel {
                ListElement { 
                    title: "Jeux" 
                    emoji: "🎮" 
                    color: "#FF9800"
                    bgColor: "#FFF3E0"
                    pageName: "JeuxMenuPage.qml"
                }
                ListElement { 
                    title: "Rappel" 
                    emoji: "⏰" 
                    color: "#E91E63"
                    bgColor: "#FCE4EC"
                    pageName: "RappelPage.qml"
                }
                ListElement { 
                    title: "Vision" 
                    emoji: "👁️" 
                    color: "#3F51B5"
                    bgColor: "#E8EAF6"
                    pageName: "VisionPage.qml"
                }
                ListElement { 
                    title: "Contact" 
                    emoji: "📞" 
                    color: "#009688"
                    bgColor: "#E0F2F1"
                    pageName: "ResidentContactPage.qml"
                }
                ListElement { 
                    title: "Activité" 
                    emoji: "🎭" 
                    color: "#673AB7"
                    bgColor: "#EDE7F6"
                    pageName: "ActivitiesPage.qml"
                }
                ListElement { 
                    title: "Menu" 
                    emoji: "🍽️" 
                    color: "#FFC107"
                    bgColor: "#FFF8E1"
                    pageName: "MenuPage.qml"
                }
                ListElement { 
                    title: "Musique" 
                    emoji: "🎵" 
                    color: "#8BC34A"
                    bgColor: "#F1F8E9"
                    pageName: "MusiquePage.qml"
                }
                ListElement { 
                    title: "Photos" 
                    emoji: "📷" 
                    color: "#2196F3"
                    bgColor: "#E3F2FD"
                    pageName: "PhotoPage.qml"
                }
                ListElement { 
                    title: "Bien-être" 
                    emoji: "🧘" 
                    color: "#9C27B0"
                    bgColor: "#F3E5F5"
                    pageName: "BienEtrePage.qml"
                }
            }
            
            // Délégué pour le ListView qui affiche chaque bouton
            delegate: Item {
                width: 560 // Large
                height: 680 // Haut
                
                // Carte bouton
                Rectangle {
                    id: cardBackground
                    anchors.fill: parent
                    anchors.margins: 10
                    radius: 15
                    color: "white"
                    
                    // Animation de l'échelle au clic
                    scale: 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    
                    // Barre de couleur en haut
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: model.color
                        radius: 15
                        anchors.top: parent.top
                        
                        // Pour garder les coins carrés en bas
                        Rectangle {
                            width: parent.width
                            height: parent.height / 2
                            color: parent.color
                            anchors.bottom: parent.bottom
                        }
                    }
                    
                    // Cercle pour l'emoji au centre
                    Rectangle {
                        width: 240
                        height: 240
                        radius: width/2
                        color: model.bgColor 
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.centerIn: parent
                        
                        // Emoji expressif
                        Text {
                            text: model.emoji
                            font.pixelSize: 120
                            color: model.color
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Bouton de lecture
                    Rectangle {
                        width: 80
                        height: 80
                        radius: width/2
                        color: "white"
                        border.width: 3
                        border.color: "black"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 100
                        
                        Text {
                            text: "▶"
                            font.pixelSize: 40
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Texte du bouton au milieu
                    Text {
                        id: titleText
                        text: model.title
                        font.pixelSize: 36
                        font.family: "Roboto"
                        width: parent.width - 40
                        height: 100
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 30
                    }
                    
                    // Zone cliquable
                    MouseArea {
                        anchors.fill: parent
                        
                        // Timer pour le délai de navigation
                        Timer {
                            id: navigationTimer
                            interval: 200
                            repeat: false
                            onTriggered: {
                                parent.parent.scale = 1.0
                                // Passer le mode d'application aux pages poussées
                                stackView.push(model.pageName, { "appMode": residentPage.appMode })
                            }
                        }
                        
                        onClicked: {
                            parent.scale = 0.95
                            clickSound.play()
                            navigationTimer.start()
                        }
                        
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.9
                        onExited: parent.opacity = 1.0
                    }
                }
            }
        }
    }
    
    // Fond décoratif simple
    Rectangle {
        anchors.fill: parent
        color: Style.backgroundColor
        opacity: 0.5
        z: -1
    }
}
