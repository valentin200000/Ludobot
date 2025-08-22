import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: simonSaysPage
    title: qsTr("Simon Says")
    
    property string appMode: "enfant"
    property int score: 0
    property int level: 1
    property var sequence: []
    property var playerSequence: []
    property bool showingSequence: false
    property bool playerTurn: false
    property bool gameActive: false
    
    // Couleurs Simon avec sons
    property var simonColors: [
        { name: "Rouge", color: "#F44336", activeColor: "#FFCDD2", sound: "🔴" },
        { name: "Vert", color: "#4CAF50", activeColor: "#C8E6C9", sound: "🟢" },
        { name: "Bleu", color: "#2196F3", activeColor: "#BBDEFB", sound: "🔵" },
        { name: "Jaune", color: "#FFEB3B", activeColor: "#FFF9C4", sound: "🟡" }
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
                text: "Simon Says"
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
                text: showingSequence ? "Regardez et écoutez..." : 
                      playerTurn ? "Répétez la séquence !" : 
                      gameActive ? "Prêt pour le niveau " + level : "Appuyez sur Jouer"
                font.pixelSize: 18
                font.family: "Roboto"
                color: showingSequence ? "#FF9800" : playerTurn ? "#4CAF50" : Style.primaryColor
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Cercle central Simon
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 500
            
            // Cercle principal
            Rectangle {
                id: simonCircle
                width: Math.min(parent.width, parent.height) * 0.8
                height: width
                radius: width / 2
                color: "#333333"
                border.width: 8
                border.color: "#222222"
                anchors.centerIn: parent
                
                // Logo Simon au centre
                Rectangle {
                    width: parent.width * 0.3
                    height: width
                    radius: width / 2
                    color: "#1a1a1a"
                    anchors.centerIn: parent
                    border.width: 4
                    border.color: "#444444"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "SIMON"
                        font.pixelSize: parent.width * 0.15
                        font.bold: true
                        color: "white"
                    }
                }
                
                // Quadrants colorés
                Repeater {
                    model: 4
                    
                    Item {
                        width: simonCircle.width
                        height: simonCircle.height
                        
                        Rectangle {
                            id: quadrant
                            width: simonCircle.width * 0.45
                            height: simonCircle.height * 0.45
                            color: simonColors[index].color
                            
                            property bool isActive: false
                            property int quadrantIndex: index
                            
                            // Position des quadrants
                            x: index % 2 === 0 ? simonCircle.width * 0.05 : simonCircle.width * 0.5
                            y: index < 2 ? simonCircle.height * 0.05 : simonCircle.height * 0.5
                            
                            // Forme de quadrant (quart de cercle)
                            Rectangle {
                                anchors.fill: parent
                                color: quadrant.isActive ? simonColors[index].activeColor : simonColors[index].color
                                
                                // Masque pour créer la forme de quart de cercle
                                layer.enabled: true
                                layer.effect: Item {
                                    Rectangle {
                                        width: parent.width * 2
                                        height: parent.height * 2
                                        radius: width / 2
                                        x: index % 2 === 0 ? 0 : -parent.width
                                        y: index < 2 ? 0 : -parent.height
                                        color: "black"
                                    }
                                }
                                
                                // Séparateurs
                                Rectangle {
                                    width: index % 2 === 0 ? parent.width : 4
                                    height: index % 2 === 0 ? 4 : parent.height
                                    color: "#333333"
                                    x: index % 2 === 0 ? 0 : parent.width - 4
                                    y: index < 2 ? parent.height - 4 : 0
                                }
                            }
                            
                            // Icône sonore
                            Text {
                                anchors.centerIn: parent
                                text: simonColors[index].sound
                                font.pixelSize: 40
                                opacity: quadrant.isActive ? 1.0 : 0.7
                            }
                            
                            // Animation d'activation
                            SequentialAnimation {
                                id: activateAnimation
                                PropertyAnimation {
                                    target: quadrant
                                    property: "isActive"
                                    to: true
                                    duration: 0
                                }
                                PauseAnimation { duration: 600 }
                                PropertyAnimation {
                                    target: quadrant
                                    property: "isActive"
                                    to: false
                                    duration: 0
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: playerTurn
                                
                                onClicked: {
                                    if (playerTurn) {
                                        activateAnimation.start()
                                        playerChoice(quadrant.quadrantIndex)
                                    }
                                }
                                
                                onPressed: {
                                    if (playerTurn) {
                                        quadrant.isActive = true
                                    }
                                }
                                
                                onReleased: {
                                    if (playerTurn) {
                                        quadrant.isActive = false
                                    }
                                }
                            }
                        }
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
                text: gameActive ? "Recommencer" : "Jouer"
                font.pixelSize: 18
                Material.background: "#4CAF50"
                Material.foreground: "white"
                onClicked: startGame()
                enabled: !showingSequence && !playerTurn
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
                text: gameOverDialog.won ? "🎉 Fantastique ! 🎉" : "💥 Erreur !"
                font.pixelSize: 24
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
            
            Text {
                text: gameOverDialog.won ? 
                      "Vous êtes un maître Simon !" :
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
        showingSequence = false
        playerTurn = false
        gameActive = false
    }

    function startGame() {
        gameActive = true
        startLevel()
    }

    function startLevel() {
        // Ajouter une nouvelle couleur à la séquence
        var randomColor = Math.floor(Math.random() * 4)
        sequence.push(randomColor)
        
        playerSequence = []
        showingSequence = true
        playerTurn = false
        
        // Commencer à montrer la séquence après un délai
        showSequenceTimer.start()
    }

    Timer {
        id: showSequenceTimer
        interval: 1000
        onTriggered: {
            showSequenceStep(0)
        }
    }

    function showSequenceStep(step) {
        if (step >= sequence.length) {
            // Séquence terminée, au tour du joueur
            showingSequence = false
            playerTurn = true
            return
        }
        
        var colorIndex = sequence[step]
        
        // Activer le quadrant
        var quadrants = simonCircle.children
        for (var i = 1; i < quadrants.length; i++) { // Skip le logo central
            var quadrant = quadrants[i].children[0]
            if (quadrant.quadrantIndex === colorIndex) {
                quadrant.children[0].children[0].start() // activateAnimation
                break
            }
        }
        
        // Passer à l'étape suivante
        sequenceStepTimer.nextStep = step + 1
        sequenceStepTimer.start()
    }

    Timer {
        id: sequenceStepTimer
        interval: 800
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
            gameActive = false
            gameOverDialog.won = false
            gameOverDialog.open()
            return
        }
        
        // Si la séquence est complète
        if (playerSequence.length === sequence.length) {
            // Séquence correcte !
            score += level * 5
            level++
            playerTurn = false
            
            if (level > 15) {
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
            startLevel()
        }
    }

    Component.onCompleted: {
        startNewGame()
    }
}
