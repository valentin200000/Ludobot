import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

import "."

Page {
    id: memoryGamesMenuPage
    
    // Propriété pour déterminer le mode d'application
    property string appMode: typeof root !== 'undefined' && root.appMode ? root.appMode : "enfant"
    title: qsTr("Jeux de mémoire")
    
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
                    text: "←"
                    font.pixelSize: 28
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: stackView.pop()
                Layout.alignment: Qt.AlignLeft
            }

            Label {
                text: "Jeux de mémoire"
                font.pixelSize: 24
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }
            
            Item {
                Layout.preferredWidth: 48
            }
        }
    }
    
    // Effet sonore pour le clic
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
            height: 680
            orientation: ListView.Horizontal
            spacing: 30
            clip: true
            flickDeceleration: 1500
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Animation fluide pour le swipe
            highlightMoveDuration: 300
            highlightMoveVelocity: -1
            
            // Points indicateurs de pagination
            footer: Item {
                width: categoryListView.width
                height: 50
                
                Row {
                    height: 20
                    spacing: 10
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Repeater {
                        model: 3 // Nombre de jeux de mémoire
                        
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
                    title: "Memory Cards" 
                    emoji: "🃏" 
                    color: "#E91E63"
                    bgColor: "#FCE4EC"
                    pageName: "MemoryCardsPage.qml"
                    description: "Retournez les cartes et trouvez les paires"
                }
                ListElement { 
                    title: "Séquence de couleurs" 
                    emoji: "🌈" 
                    color: "#9C27B0"
                    bgColor: "#F3E5F5"
                    pageName: "ColorSequencePage.qml"
                    description: "Mémorisez et reproduisez la séquence"
                }
                ListElement { 
                    title: "Simon Says" 
                    emoji: "🔴" 
                    color: "#FF5722"
                    bgColor: "#FBE9E7"
                    pageName: "SimonSaysPage.qml"
                    description: "Suivez la séquence de sons et lumières"
                }
            }
            
            // Délégué pour le ListView qui affiche chaque bouton
            delegate: Item {
                width: 560
                height: 680
                
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
                        anchors.top: parent.top
                        anchors.topMargin: 120
                        
                        // Emoji expressif
                        Text {
                            text: model.emoji
                            font.pixelSize: 120
                            color: model.color
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Description du jeu
                    Text {
                        text: model.description
                        font.pixelSize: 18
                        font.family: "Roboto"
                        color: "#666666"
                        width: parent.width - 40
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 380
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
                        font.pixelSize: model.title.length > 15 ? 28 : 32
                        font.family: "Roboto"
                        font.bold: true
                        width: parent.width - 40
                        height: 80
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 30
                        color: model.color
                    }
                    
                    // Zone cliquable
                    MouseArea {
                        anchors.fill: parent
                        
                        onClicked: {
                            clickSound.play()
                            parent.scale = 0.95
                            
                            console.log("Lancement du jeu de mémoire " + model.title)
                            stackView.push(model.pageName, { "appMode": memoryGamesMenuPage.appMode })
                            
                            // Remettre l'échelle à 1 après un court délai
                            resetScaleTimer.start()
                        }
                        
                        Timer {
                            id: resetScaleTimer
                            interval: 200
                            onTriggered: parent.parent.scale = 1.0
                        }
                        
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.9
                        onExited: parent.opacity = 1.0
                    }
                }
            }
        }
    }
    
    // Fond décoratif
    Rectangle {
        anchors.fill: parent
        color: Style.backgroundColor
        opacity: 0.5
        z: -1
    }
}
