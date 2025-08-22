import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."

Page {
    id: subjectQuizPage
    background: Rectangle { color: Style.backgroundColor }
    
    // Propriétés pour les paramètres du quiz
    property string questionSubject: "maths"
    property int selectedAge: 6
    property int correctAnswers: 0
    property int questionNumber: 1
    property int totalQuestions: 10
    
    // Questions et état
    property var questions: []
    property var currentQuestion: null
    property bool questionAnswered: false
    
    // Émojis pour les boutons de réponse
    property var buttonSymbols: [
        "🔺",  // Triangle
        "💎",  // Diamant
        "🔵",  // Cercle bleu
        "🟩"   // Carré vert
    ]
    
    // Couleurs pour les boutons de réponse
    property var buttonColors: [
        "#2979FF", // Bleu
        "#FFC107", // Jaune/Orange
        "#9C27B0", // Violet
        "#FF5722"  // Orange
    ]
    
    // Bouton de retour en haut à gauche
    RoundButton {
        id: backButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 16
        text: "↩️"
        font.pixelSize: 28
        icon.width: 32
        icon.height: 32
        flat: true
        onClicked: stackView.pop()
        z: 10 // S'assurer que le bouton est au-dessus des autres éléments
    }
    
    // Initialiser les questions au chargement de la page
    Component.onCompleted: {
        console.log("DEBUG - SubjectQuizPage.qml - Component.onCompleted")
        console.log("DEBUG - Matière reçue: '" + questionSubject + "'")
        console.log("DEBUG - subjectLoader disponible: " + (typeof subjectLoader !== "undefined"))
        
        // Vérifier que subjectLoader est disponible
        if (typeof subjectLoader === "undefined" || subjectLoader === null) {
            console.error("ERREUR CRITIQUE: subjectLoader n'est pas disponible dans le contexte QML")
            // Continuer quand même pour voir si on peut charger des questions par défaut
        }
        
        // Essayer de charger les questions
        try {
            loadQuestions()
        } catch (e) {
            console.error("ERREUR lors du chargement des questions: " + e)
        }
    }
    
    // Charger les questions depuis le CSV
    function loadQuestions() {
        console.log("DEBUG - Début du chargement des questions")
        console.log("DEBUG - Matière: '" + questionSubject + "', âge: " + selectedAge)
        console.log("DEBUG - Type de la matière: " + typeof questionSubject)
        
        try {
            // Vérifier que le subjectLoader est disponible
            if (typeof subjectLoader === "undefined" || subjectLoader === null) {
                console.error("ERREUR: subjectLoader n'est pas disponible dans le contexte QML")
                currentQuestion = {
                    question: "Erreur: subjectLoader n'est pas disponible",
                    answers: ["Retour"],
                    correct: "Retour"
                }
                return
            }
            
            console.log("Appel de subjectLoader.loadQuestions avec: '" + questionSubject + "', " + selectedAge)
            
            // Utiliser quizController comme solution de secours si subjectLoader ne fonctionne pas
            var result = null
            try {
                // Essayer d'abord avec subjectLoader
                result = subjectLoader.loadQuestions(questionSubject, selectedAge)
                console.log("Résultat du chargement avec subjectLoader: " + (result ? "OK" : "NULL"))
            } catch (e) {
                console.error("ERREUR avec subjectLoader: " + e)
                // Essayer avec quizController en secours
                try {
                    if (typeof quizController !== "undefined" && quizController !== null) {
                        console.log("Tentative avec quizController...")
                        result = quizController.loadQuestions(questionSubject, selectedAge)
                        console.log("Résultat du chargement avec quizController: " + (result ? "OK" : "NULL"))
                    }
                } catch (e2) {
                    console.error("ERREUR avec quizController: " + e2)
                }
            }
            
            if (result) {
                questions = result
                console.log("Nombre de questions chargées: " + questions.length)
            } else {
                console.error("ERREUR: Aucun résultat retourné par les chargeurs de questions")
                // Créer des questions par défaut directement dans QML
                questions = [
                    {
                        question: "Combien font 2 + 2 ?",
                        answers: ["4", "3", "5", "6"],
                        correct: "4"
                    },
                    {
                        question: "Quelle est la capitale de la France ?",
                        answers: ["Paris", "Lyon", "Marseille", "Bordeaux"],
                        correct: "Paris"
                    }
                ]
                console.log("Questions par défaut créées: " + questions.length)
            }
            
            if (questions && questions.length > 0) {
                currentQuestion = questions[0]
                questionNumber = 1
                totalQuestions = questions.length
                console.log("Première question: " + currentQuestion.question)
            } else {
                console.error("Aucune question trouvée")
                currentQuestion = {
                    question: "Aucune question disponible",
                    answers: ["Retour"],
                    correct: "Retour"
                }
            }
        } catch (e) {
            console.error("Erreur: " + e)
            currentQuestion = {
                question: "Erreur: " + e,
                answers: ["Retour"],
                correct: "Retour"
            }
        }
    }
    
    // Vérifier si la réponse est correcte
    function checkAnswer(index) {
        if (!questionAnswered) {
            questionAnswered = true
            
            var selectedAnswer = currentQuestion.answers[index]
            var isCorrect = (selectedAnswer === currentQuestion.correct)
            
            if (isCorrect) {
                correctAnswers++
                console.log("Bonne réponse!")
                robotFace.state = "happy" // Visage robot heureux
            } else {
                console.log("Mauvaise réponse!")
                robotFace.state = "sad" // Visage robot triste
            }
            
            // Passer à la question suivante après 2 secondes
            autoNextTimer.start()
        }
    }
    
    // Passer à la question suivante
    function nextQuestion() {
        questionNumber++
        questionAnswered = false
        
        // Réinitialiser l'expression du visage robot
        robotFace.state = ""
        
        if (questionNumber > questions.length) {
            // Fin du quiz
            showResults()
        } else {
            currentQuestion = questions[questionNumber - 1]
            
            // Réinitialiser les couleurs des boutons
            resetButtonColors()
        }
    }
    
    // Réinitialiser les couleurs des boutons
    function resetButtonColors() {
        // Cette fonction sera appelée pour réinitialiser les couleurs des boutons
        // à chaque nouvelle question
        console.log("Réinitialisation des couleurs des boutons")
        
        // Attendre que les éléments du Repeater soient créés
        Qt.callLater(function() {
            for (var i = 0; i < buttonRepeater.count; i++) {
                var item = buttonRepeater.itemAt(i)
                if (item) {
                    item.color = buttonColors[i]
                    console.log("Bouton " + i + " réinitialisé à la couleur " + buttonColors[i])
                }
            }
        })
    }
    
    // Afficher les résultats
    function showResults() {
        console.log("Affichage des résultats: " + correctAnswers + "/" + totalQuestions)
        quizContent.visible = false
        resultsPage.visible = true
        
        // Mettre à jour le score
        resultScore.text = "Ton score est de " + correctAnswers + "/" + totalQuestions
        
        // Mettre à jour le message en fonction du score
        var percentage = correctAnswers / totalQuestions
        if (percentage >= 0.8) {
            resultMessage.text = "Excellent travail ! Tu es très fort !"
            resultRobotFace.state = "happy"
        } else if (percentage >= 0.6) {
            resultMessage.text = "Bon travail ! Continue comme ça !"
            resultRobotFace.state = "happy"
        } else if (percentage >= 0.4) {
            resultMessage.text = "Pas mal ! Tu peux encore t'améliorer !"
            resultRobotFace.state = "happy"
        } else {
            resultMessage.text = "Continue à t'entraîner, tu vas y arriver !"
            resultRobotFace.state = "sad"
        }
        
        // Démarrer le timer pour retourner à la page des matières
        returnTimer.start()
    }
    
    // Initialisation
    Component.onCompleted: {
        loadQuestions()
    }
    
    // Timer pour passer automatiquement à la question suivante
    Timer {
        id: autoNextTimer
        interval: 2000
        repeat: false
        onTriggered: {
            nextQuestion()
        }
    }
    
    // Timer pour retourner à la page des matières
    Timer {
        id: returnTimer
        interval: 5000
        repeat: false
        onTriggered: {
            stackView.pop()
        }
    }
    
    // Interface utilisateur principale
    Item {
        id: quizContent
        anchors.fill: parent
        visible: true
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            // Espace pour le bouton de retour
            Item {
                Layout.preferredHeight: 40
            }
            
            // Barre de score en haut
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#E8F5E9"
                border.color: "#81C784"
                border.width: 1
                radius: 20
                
                Rectangle {
                    anchors.centerIn: parent
                    width: scoreText.width + 40
                    height: 30
                    radius: 15
                    color: "#81C784"
                    
                    Text {
                        id: scoreText
                        anchors.centerIn: parent
                        text: "Question " + questionNumber + "/" + totalQuestions + " - Score: " + correctAnswers
                        color: "black"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }
            
            Item { Layout.preferredHeight: 20 } // Espacement
            
            // Zone de question avec visage robot
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: parent.height * 0.25
                color: "#FFE082" // Jaune pastel
                radius: 20
                border.color: "#FFD54F"
                border.width: 2
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    // Visage robot expressif
                    Rectangle {
                        id: robotFace
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100
                        color: "#64B5F6" // Bleu clair
                        radius: width / 2
                        
                        // Yeux du robot
                        Rectangle {
                            id: leftEye
                            width: parent.width * 0.2
                            height: parent.height * 0.2
                            radius: height / 2
                            color: "#0D47A1"
                            x: parent.width * 0.25
                            y: parent.height * 0.3
                        }
                        
                        Rectangle {
                            id: rightEye
                            width: parent.width * 0.2
                            height: parent.height * 0.2
                            radius: height / 2
                            color: "#0D47A1"
                            x: parent.width * 0.55
                            y: parent.height * 0.3
                        }
                        
                        // Bouche du robot
                        Rectangle {
                            id: mouth
                            width: parent.width * 0.5
                            height: parent.height * 0.1
                            radius: height / 2
                            color: "#0D47A1"
                            x: parent.width * 0.25
                            y: parent.height * 0.65
                            
                            Rectangle {
                                id: mouthCover
                                visible: false
                                width: parent.width
                                height: parent.height / 2
                                color: "#64B5F6"
                                anchors.bottom: parent.bottom
                            }
                        }
                        
                        // États du visage robot
                        states: [
                            State {
                                name: "happy"
                                PropertyChanges { target: leftEye; height: parent.height * 0.15; radius: height / 2 }
                                PropertyChanges { target: rightEye; height: parent.height * 0.15; radius: height / 2 }
                                PropertyChanges { target: mouth; height: parent.height * 0.15; radius: height / 2 }
                                PropertyChanges { target: mouthCover; visible: false }
                            },
                            State {
                                name: "sad"
                                PropertyChanges { target: leftEye; height: parent.height * 0.05; radius: 0 }
                                PropertyChanges { target: rightEye; height: parent.height * 0.05; radius: 0 }
                                PropertyChanges { target: mouth; height: parent.height * 0.15; radius: 0 }
                                PropertyChanges { target: mouthCover; visible: true }
                            }
                        ]
                        
                        // Transitions entre les états
                        transitions: [
                            Transition {
                                from: ""; to: "happy"
                                ParallelAnimation {
                                    PropertyAnimation { target: leftEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: rightEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: mouth; properties: "height,radius"; duration: 300 }
                                }
                            },
                            Transition {
                                from: ""; to: "sad"
                                ParallelAnimation {
                                    PropertyAnimation { target: leftEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: rightEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: mouth; properties: "height,radius"; duration: 300 }
                                }
                            },
                            Transition {
                                from: "happy"; to: ""
                                ParallelAnimation {
                                    PropertyAnimation { target: leftEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: rightEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: mouth; properties: "height,radius"; duration: 300 }
                                }
                            },
                            Transition {
                                from: "sad"; to: ""
                                ParallelAnimation {
                                    PropertyAnimation { target: leftEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: rightEye; properties: "height,radius"; duration: 300 }
                                    PropertyAnimation { target: mouth; properties: "height,radius"; duration: 300 }
                                }
                            }
                        ]
                    }
                    
                    // Texte de la question
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: currentQuestion ? currentQuestion.question : "Chargement..."
                        color: "black"
                        font.pixelSize: 84 // Texte agrandi x3
                        font.bold: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            
            Item { Layout.preferredHeight: 20 } // Espacement
            
            // Grille de boutons de réponse
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                columns: 2
                rows: 2
                columnSpacing: 20
                rowSpacing: 20
                
                Repeater {
                    id: buttonRepeater
                    model: currentQuestion ? Math.min(currentQuestion.answers.length, 4) : 0
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: buttonColors[index]
                        radius: 10
                        
                        property bool isCorrect: currentQuestion ? 
                                                currentQuestion.answers[index] === currentQuestion.correct : false
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15
                            
                            // Symbole géométrique
                            Text {
                                text: buttonSymbols[index]
                                color: "white"
                                font.pixelSize: 72 // Agrandi x2
                                font.bold: true
                            }
                            
                            // Texte de la réponse
                            Text {
                                Layout.fillWidth: true
                                text: currentQuestion ? currentQuestion.answers[index] : ""
                                color: "white"
                                font.pixelSize: 72 // Agrandi x3
                                font.bold: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                        
                        // Zone de clic
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (!questionAnswered) {
                                    checkAnswer(index)
                                    
                                    // Effet visuel pour la réponse
                                    if (isCorrect) {
                                        parent.color = "#4CAF50" // Vert pour bonne réponse
                                    } else {
                                        parent.color = "#F44336" // Rouge pour mauvaise réponse
                                        
                                        // Mettre en évidence la bonne réponse
                                        for (var i = 0; i < buttonRepeater.count; i++) {
                                            var item = buttonRepeater.itemAt(i)
                                            if (item && item.isCorrect) {
                                                item.color = "#4CAF50"
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Page de résultats
    Item {
        id: resultsPage
        anchors.fill: parent
        visible: false
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 32
            
            Text {
                Layout.fillWidth: true
                text: "Félicitations !"
                color: Style.textColorPrimary
                font.pixelSize: 48
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Visage robot expressif pour les résultats
            // Emoji expressif pour les résultats
            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                
                // Utiliser des émojis pour les expressions faciales
                Text {
                    id: resultEmoji
                    anchors.fill: parent
                    text: correctAnswers >= totalQuestions * 0.7 ? "😄" : (correctAnswers >= totalQuestions * 0.4 ? "😐" : "😔")
                    font.pixelSize: 140
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    // Animation d'échelle pour un effet rebondissant
                    SequentialAnimation {
                        running: resultsPage.visible
                        loops: 1
                        
                        PropertyAnimation {
                            target: resultEmoji
                            property: "scale"
                            from: 0.5
                            to: 1.2
                            duration: 400
                            easing.type: Easing.OutBack
                        }
                        
                        PropertyAnimation {
                            target: resultEmoji
                            property: "scale"
                            from: 1.2
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutBounce
                        }
                    }
                }
            }
            
            Text {
                id: resultScore
                Layout.fillWidth: true
                text: "Ton score est de 0/0"
                color: Style.textColorPrimary
                font.pixelSize: 36
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                id: resultMessage
                Layout.fillWidth: true
                text: "Bravo !"
                color: Style.textColorPrimary
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: "Retour à la page des matières dans 5 secondes..."
                color: Style.textColorSecondary
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
