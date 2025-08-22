import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: colorSequencePage
    title: qsTr("Séquence de couleurs")
    
    property string appMode: "enfant"
    property int score: 0
    property int level: 1
    property var sequence: []
    property var playerSequence: []
    property int currentStep: 0
    property bool showingSequence: false
    property bool playerTurn: false
    
    // Couleurs disponibles
    property var colors: [
        { name: "Rouge", color: "#F44336", lightColor: "#FFCDD2" },
        { name: "Bleu", color: "#2196F3", lightColor: "#BBDEFB" },
        { name: "Vert", color: "#4CAF50", lightColor: "#C8E6C9" },
        { name: "Jaune", color: "#FFEB3B", lightColor: "#FFF9C4" },
        { name: "Violet", color: "#9C27B0", lightColor: "#E1BEE7" },
        { name: "Orange", color: "#FF9800", lightColor: "#FFE0B2" }
    ]
    
    background: Rectangle { 
        color: Style.backgroundColor
    }

    header: ToolBar {
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
            }

            Label {
                text: "Séquence de couleurs"
                font.pixelSize: 24
                font.family: "Roboto"
                Layout.fillWidth: true
                color: "white"
            }
            
            Label {
                text: "Niveau: " + level
                font.pixelSize: 18
                color: "white"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Informations de jeu
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Score: " + score
                font.pixelSize: 24
                font.family: "Roboto"
                font.bold: true
                color: Style.primaryColor
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: showingSequence ? "Mémorisez la séquence..." : 
                      playerTurn ? "À votre tour !" : "Prêt ?"
                font.pixelSize: 20
                font.family: "Roboto"
                color: showingSequence ? "#FF9800" : playerTurn ? "#4CAF50" : Style.primaryColor
            }
        }

        // Grille de couleurs 2x3
        GridLayout {
            id: colorGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 400
            columns: 3
            rowSpacing: 15
            columnSpacing: 15
            
            Repeater {
                model: 6
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 150
                    radius: 20
                    color: colors[index].color
                    border.width: 4
                    border.color: "#333"
                    
                    property bool highlighted: false
                    
                    // Animation de surbrillance
                    SequentialAnimation {
                        id: highlightAnimation
                        PropertyAnimation {
                            target: parent
                            property: "color"
                            to: colors[index].lightColor
                            duration: 200
                        }
                        PropertyAnimation {
                            target: parent
                            property: "color"
                            to: colors[index].color
                            duration: 200
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: colors[index].name
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                        style: Text.Outline
                        styleColor: "black"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        enabled: playerTurn
                        
                        onClicked: {
                            if (playerTurn) {
                                highlightAnimation.start()
                                playerChoice(index)
                            }
                        }
                        
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = 1.0
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                }
            }
        }

        // Boutons de contrôle
        RowLayout {
            Layout.fillWidth: true
            
            Button {
                text: "Nouvelle partie"
                font.pixelSize: 18
                Material.background: Style.accentColor
                Material.foreground: "white"
                onClicked: startNewGame()
                enabled: !showingSequence
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Commencer"
                font.pixelSize: 18
                Material.background: "#4CAF50"
                Material.foreground: "white"
                onClicked: startSequence()
                enabled: !showingSequence && !playerTurn
                visible: sequence.length === 0
            }
        }
    }

    // Dialogue de fin de partie
    Dialog {
        id: gameOverDialog
        title: "Partie terminée"
        modal: true
        anchors.centerIn: parent
        
        property bool won: false
        
        contentItem: Column {
            spacing: 20
            padding: 20
            
            Text {
                text: gameOverDialog.won ? "🎉 Excellent ! 🎉" : "😔 Dommage !"
                font.pixelSize: 24
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
            
            Text {
                text: gameOverDialog.won ? 
                      "Vous avez atteint le niveau " + level + " !" :
                      "Vous avez atteint le niveau " + level
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
            
            Text {
                text: "Score final: " + score + " points"
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Rejouer"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: {
                    gameOverDialog.close()
                    startNewGame()
                }
            }
            Button {
                text: "Retour"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: {
                    gameOverDialog.close()
                    stackView.pop()
                }
            }
        }
    }

    function startNewGame() {
        score = 0
        level = 1
        sequence = []
        playerSequence = []
        currentStep = 0
        showingSequence = false
        playerTurn = false
    }

    function startSequence() {
        // Ajouter une nouvelle couleur à la séquence
        var randomColor = Math.floor(Math.random() * colors.length)
        sequence.push(randomColor)
        
        playerSequence = []
        currentStep = 0
        showingSequence = true
        playerTurn = false
        
        // Commencer à montrer la séquence
        showSequenceStep(0)
    }

    function showSequenceStep(step) {
        if (step >= sequence.length) {
            // Séquence terminée, au tour du joueur
            showingSequence = false
            playerTurn = true
            return
        }
        
        var colorIndex = sequence[step]
        var colorRect = colorGrid.children[colorIndex]
        
        // Animer la couleur
        colorRect.children[0].start() // highlightAnimation
        
        // Passer à l'étape suivante après un délai
        sequenceTimer.colorIndex = colorIndex
        sequenceTimer.nextStep = step + 1
        sequenceTimer.start()
    }

    Timer {
        id: sequenceTimer
        interval: 800
        property int colorIndex: 0
        property int nextStep: 0
        
        onTriggered: {
            showSequenceStep(nextStep)
        }
    }

    function playerChoice(colorIndex) {
        playerSequence.push(colorIndex)
        
        // Vérifier si le choix est correct
        if (playerSequence[playerSequence.length - 1] !== sequence[playerSequence.length - 1]) {
            // Mauvaise réponse
            playerTurn = false
            gameOverDialog.won = false
            gameOverDialog.open()
            return
        }
        
        // Si la séquence est complète
        if (playerSequence.length === sequence.length) {
            // Séquence correcte !
            score += level * 10
            level++
            playerTurn = false
            
            if (level > 10) {
                // Victoire complète
                gameOverDialog.won = true
                gameOverDialog.open()
            } else {
                // Niveau suivant
                nextLevelTimer.start()
            }
        }
    }

    Timer {
        id: nextLevelTimer
        interval: 1500
        onTriggered: {
            startSequence()
        }
    }

    Component.onCompleted: {
        startNewGame()
    }
}
