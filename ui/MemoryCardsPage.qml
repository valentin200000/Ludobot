import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: memoryCardsPage
    title: qsTr("Memory Cards")
    
    property string appMode: "enfant"
    property int score: 0
    property int moves: 0
    property var flippedCards: []
    property bool canFlip: true
    property int pairsFound: 0
    property int totalPairs: 8
    
    // Symboles pour les cartes
    property var cardSymbols: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼"]
    property var gameCards: []
    
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
                text: "Memory Cards"
                font.pixelSize: 24
                font.family: "Roboto"
                Layout.fillWidth: true
                color: "white"
            }
            
            Label {
                text: "Score: " + score
                font.pixelSize: 18
                color: "white"
            }
        }
    }

    // Interface de jeu
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Informations de jeu
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Mouvements: " + moves
                font.pixelSize: 20
                font.family: "Roboto"
                color: Style.primaryColor
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: "Paires: " + pairsFound + "/" + totalPairs
                font.pixelSize: 20
                font.family: "Roboto"
                color: Style.primaryColor
            }
        }

        // Grille de cartes 4x4
        GridLayout {
            id: cardGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 10
            columnSpacing: 10
            
            Repeater {
                model: 16
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    radius: 10
                    color: gameCards[index] && gameCards[index].flipped ? "#E3F2FD" : "#2196F3"
                    border.width: 2
                    border.color: gameCards[index] && gameCards[index].matched ? "#4CAF50" : "#1976D2"
                    
                    Text {
                        anchors.centerIn: parent
                        text: gameCards[index] && gameCards[index].flipped ? gameCards[index].symbol : "?"
                        font.pixelSize: gameCards[index] && gameCards[index].flipped ? 48 : 36
                        color: gameCards[index] && gameCards[index].flipped ? "#333" : "white"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        enabled: canFlip && gameCards[index] && !gameCards[index].flipped && !gameCards[index].matched
                        
                        onClicked: {
                            flipCard(index)
                        }
                    }
                    
                    // Animation de retournement
                    Behavior on color {
                        ColorAnimation { duration: 300 }
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
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Aide"
                font.pixelSize: 18
                Material.background: "#FF9800"
                Material.foreground: "white"
                onClicked: showHint()
            }
        }
    }

    // Dialogue de victoire
    Dialog {
        id: winDialog
        title: "Félicitations !"
        modal: true
        anchors.centerIn: parent
        
        contentItem: Column {
            spacing: 20
            padding: 20
            
            Text {
                text: "🎉 Vous avez gagné ! 🎉"
                font.pixelSize: 24
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
            
            Text {
                text: "Score final: " + score + " points"
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
            
            Text {
                text: "Mouvements: " + moves
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
                    winDialog.close()
                    startNewGame()
                }
            }
            Button {
                text: "Retour"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: {
                    winDialog.close()
                    stackView.pop()
                }
            }
        }
    }

    function startNewGame() {
        // Réinitialiser les variables
        score = 0
        moves = 0
        pairsFound = 0
        flippedCards = []
        canFlip = true
        
        // Créer les cartes (2 de chaque symbole)
        var cards = []
        for (var i = 0; i < cardSymbols.length; i++) {
            cards.push({ symbol: cardSymbols[i], flipped: false, matched: false })
            cards.push({ symbol: cardSymbols[i], flipped: false, matched: false })
        }
        
        // Mélanger les cartes
        for (var j = cards.length - 1; j > 0; j--) {
            var k = Math.floor(Math.random() * (j + 1))
            var temp = cards[j]
            cards[j] = cards[k]
            cards[k] = temp
        }
        
        gameCards = cards
    }

    function flipCard(index) {
        if (!canFlip || gameCards[index].flipped || gameCards[index].matched) {
            return
        }
        
        gameCards[index].flipped = true
        flippedCards.push(index)
        
        // Force la mise à jour de l'affichage
        gameCards = gameCards.slice()
        
        if (flippedCards.length === 2) {
            canFlip = false
            moves++
            
            // Vérifier si les cartes correspondent
            checkMatch.start()
        }
    }

    Timer {
        id: checkMatch
        interval: 1000
        onTriggered: {
            var card1 = gameCards[flippedCards[0]]
            var card2 = gameCards[flippedCards[1]]
            
            if (card1.symbol === card2.symbol) {
                // Paire trouvée
                card1.matched = true
                card2.matched = true
                pairsFound++
                score += 10
                
                if (pairsFound === totalPairs) {
                    // Jeu terminé
                    winDialog.open()
                }
            } else {
                // Pas de correspondance, retourner les cartes
                card1.flipped = false
                card2.flipped = false
            }
            
            // Force la mise à jour de l'affichage
            gameCards = gameCards.slice()
            
            flippedCards = []
            canFlip = true
        }
    }

    function showHint() {
        // Montrer brièvement toutes les cartes
        canFlip = false
        for (var i = 0; i < gameCards.length; i++) {
            if (!gameCards[i].matched) {
                gameCards[i].flipped = true
            }
        }
        gameCards = gameCards.slice()
        
        hintTimer.start()
    }

    Timer {
        id: hintTimer
        interval: 2000
        onTriggered: {
            for (var i = 0; i < gameCards.length; i++) {
                if (!gameCards[i].matched) {
                    gameCards[i].flipped = false
                }
            }
            gameCards = gameCards.slice()
            canFlip = true
        }
    }

    Component.onCompleted: {
        startNewGame()
    }
}
