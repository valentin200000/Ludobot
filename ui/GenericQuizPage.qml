import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."

Page {
    id: genericQuizPage
    background: Rectangle { color: Style.backgroundColor }
    
    // Propriétés passées lors de la navigation
    property string subject: ""
    
    // Propriétés pour les paramètres du quiz
    property int selectedAge: 6
    property int correctAnswers: 0
    property int questionNumber: 1
    property int totalQuestions: 10
    
    // Questions et état
    property var questions: []
    property var currentQuestion: null
    property bool questionAnswered: false
    
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
        icon.source: "assets/icons/arrow_back.svg"
        icon.width: 32
        icon.height: 32
        flat: true
        onClicked: stackView.pop()
        z: 10
    }
    
    // Initialiser les questions au chargement de la page
    Component.onCompleted: {
        console.log("DEBUG - GenericQuizPage.qml - Component.onCompleted pour " + subject)
        loadQuestions()
    }

    // Mode Enfant en haut à droite
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 16
        width: 120
        height: 40
        radius: 20
        color: "#E8F5E9"
        border.width: 2
        border.color: "#4CAF50"
        
        Text {
            anchors.centerIn: parent
            text: "Mode Enfant"
            color: "#2E7D32"
            font.pixelSize: 14
            font.bold: true
        }
    }

    // Charger les questions depuis le CSV
    function loadQuestions() {
        console.log("DEBUG - Début du chargement des questions pour " + subject)
        console.log("DEBUG - Âge: " + selectedAge)
        
        try {
            var fileName = getCSVFileName(subject)
            console.log("DEBUG - Fichier CSV: " + fileName)
            
            // Utiliser le chargeur Python pour récupérer les questions
            if (typeof chargeurQuiz !== 'undefined') {
                var questionsData = chargeurQuiz.charger_questions(fileName, selectedAge)
                if (questionsData && questionsData.length > 0) {
                    questions = questionsData.slice(0, totalQuestions)
                    console.log("Questions chargées depuis Python: " + questions.length)
                    
                    if (questions.length > 0) {
                        currentQuestion = questions[0]
                        questionNumber = 1
                        totalQuestions = questions.length
                        console.log("Première question: " + currentQuestion.question)
                    }
                } else {
                    console.log("Aucune question trouvée, utilisation de questions par défaut")
                    loadDefaultQuestions()
                }
            } else {
                console.log("Chargeur Python non disponible, utilisation de questions par défaut")
                loadDefaultQuestions()
            }
        } catch (e) {
            console.error("Erreur lors du chargement: " + e)
            loadDefaultQuestions()
        }
    }
    
    // Obtenir le nom du fichier CSV selon la matière
    function getCSVFileName(subject) {
        switch(subject) {
            case "objets": return "Objets.csv"
            case "maths": return "maths.csv"
            case "histoire": return "histoire.csv"
            case "geographie": return "geographie.csv"
            case "francais": return "francais.csv"
            case "science": return "science.csv"
            case "culturegeneral": return "culturegeneral.csv"
            default: return "Objets.csv"
        }
    }
    
    // Questions par défaut si le chargement CSV échoue
    function loadDefaultQuestions() {
        var defaultQuestions = {
            "objets": [
                {
                    question: "Où est l'endroit où nous dormons ?",
                    answers: ["La salle de bain", "Notre chambre", "Le salon", "La cuisine"],
                    correct: "Notre chambre"
                },
                {
                    question: "Où est l'endroit où nous mangeons ?",
                    answers: ["Le garage", "Le jardin", "La cuisine", "La chambre"],
                    correct: "La cuisine"
                }
            ],
            "maths": [
                {
                    question: "Combien font 2 + 2 ?",
                    answers: ["3", "4", "5", "6"],
                    correct: "4"
                },
                {
                    question: "Combien font 5 - 3 ?",
                    answers: ["1", "2", "3", "4"],
                    correct: "2"
                }
            ],
            "histoire": [
                {
                    question: "Qui était le roi de France ?",
                    answers: ["Louis XIV", "Napoléon", "Jules César", "Charlemagne"],
                    correct: "Louis XIV"
                }
            ],
            "geographie": [
                {
                    question: "Quelle est la capitale de la France ?",
                    answers: ["Lyon", "Marseille", "Paris", "Toulouse"],
                    correct: "Paris"
                }
            ]
        }
        
        questions = defaultQuestions[subject] || defaultQuestions["objets"]
        console.log("Questions par défaut chargées: " + questions.length)
        
        if (questions && questions.length > 0) {
            currentQuestion = questions[0]
            questionNumber = 1
            totalQuestions = questions.length
            console.log("Première question par défaut: " + currentQuestion.question)
        }
    }
    
    // Vérifier si la réponse est correcte
    function checkAnswer(index) {
        if (!questionAnswered) {
            questionAnswered = true
            
            var selectedAnswer = currentQuestion.answers[index]
            console.log("Réponse sélectionnée: " + selectedAnswer)
            
            if (selectedAnswer === currentQuestion.correct) {
                console.log("Bonne réponse !")
                correctAnswers++
                robotFace.state = "happy"
            } else {
                console.log("Mauvaise réponse. La bonne réponse était: " + currentQuestion.correct)
                robotFace.state = "sad"
            }
            
            // Passer automatiquement à la question suivante après un délai
            autoNextTimer.start()
        }
    }
    
    // Passer à la question suivante
    function nextQuestion() {
        if (questionNumber < questions.length) {
            questionNumber++
            currentQuestion = questions[questionNumber - 1]
            questionAnswered = false
            
            // Réinitialiser l'état du visage robot
            robotFace.state = ""
        } else {
            showResults()
        }
    }
    
    // Afficher les résultats
    function showResults() {
        console.log("Affichage des résultats: " + correctAnswers + "/" + totalQuestions)
        quizContent.visible = false
        resultsPage.visible = true
        
        // Démarrer le timer pour retourner à la page des matières
        returnTimer.start()
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
        
        // Affichage du score en haut
        Rectangle {
            id: scoreBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            color: "#E8F5E9"
            
            Text {
                anchors.centerIn: parent
                text: "Question " + questionNumber + "/" + totalQuestions + " - Score: " + correctAnswers
                color: "#2E7D32"
                font.pixelSize: 18
                font.bold: true
            }
        }
        
        // Zone de question avec le visage robot
        Rectangle {
            id: questionBox
            anchors.top: scoreBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            height: parent.height * 0.25
            color: "#FFE082" // Jaune pastel
            radius: 10
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                // Visage robot expressif (à gauche)
                Rectangle {
                    id: robotFace
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    color: "#64B5F6" // Bleu clair
                    radius: width / 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        font.pixelSize: 40
                        font.bold: true
                        color: "#0D47A1"
                    }
                    
                    // États du visage robot
                    states: [
                        State {
                            name: "happy"
                        },
                        State {
                            name: "sad"
                        }
                    ]
                }
                
                // Texte de la question
                Text {
                    Layout.fillWidth: true
                    text: currentQuestion ? currentQuestion.question : "Chargement..."
                    wrapMode: Text.WordWrap
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    color: "#000000"
                }
            }
        }
        
        // Grille de boutons pour les réponses (comme dans votre screenshot)
        Grid {
            id: answersGrid
            anchors.top: questionBox.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            columns: 2
            spacing: 10
            
            Repeater {
                id: buttonRepeater
                model: currentQuestion ? Math.min(currentQuestion.answers.length, 4) : 0
                
                Rectangle {
                    id: answerButton
                    width: (answersGrid.width - answersGrid.spacing) / 2
                    height: (answersGrid.height - answersGrid.spacing) / 2
                    color: buttonColors[index]
                    radius: 10
                    
                    property bool isCorrect: currentQuestion && currentQuestion.answers[index] === currentQuestion.correct
                    
                    // Forme blanche en haut
                    Item {
                        id: symbolShape
                        width: 80
                        height: 80
                        anchors.top: parent.top
                        anchors.topMargin: 15
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        // Carré (index 0)
                        Rectangle {
                            anchors.fill: parent
                            visible: index === 0
                            color: "white"
                        }
                        
                        // Cercle (index 1)
                        Rectangle {
                            anchors.fill: parent
                            visible: index === 1
                            color: "white"
                            radius: width / 2
                        }
                        
                        // Triangle (index 2)
                        Canvas {
                            anchors.fill: parent
                            visible: index === 2
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.beginPath();
                                ctx.moveTo(width/2, 10);
                                ctx.lineTo(10, height-10);
                                ctx.lineTo(width-10, height-10);
                                ctx.closePath();
                                ctx.fillStyle = "white";
                                ctx.fill();
                            }
                        }
                        
                        // Losange (index 3)
                        Canvas {
                            anchors.fill: parent
                            visible: index === 3
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.beginPath();
                                ctx.moveTo(width/2, 10);
                                ctx.lineTo(10, height/2);
                                ctx.lineTo(width/2, height-10);
                                ctx.lineTo(width-10, height/2);
                                ctx.closePath();
                                ctx.fillStyle = "white";
                                ctx.fill();
                            }
                        }
                    }
                    
                    // Texte de la réponse
                    Text {
                        anchors.top: symbolShape.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: currentQuestion ? currentQuestion.answers[index] : ""
                        wrapMode: Text.WordWrap
                        color: "white"
                        font.pixelSize: 32
                        font.bold: true
                    }
                    
                    // Zone cliquable
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!questionAnswered) {
                                // Changer la couleur du bouton en fonction de la réponse
                                if (isCorrect) {
                                    answerButton.color = "#4CAF50" // Vert pour une bonne réponse
                                } else {
                                    answerButton.color = "#F44336" // Rouge pour une mauvaise réponse
                                }
                                
                                // Vérifier la réponse
                                checkAnswer(index)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Page de résultats
    Rectangle {
        id: resultsPage
        anchors.fill: parent
        visible: false
        color: "#F5F5F5"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 32
            
            Text {
                Layout.fillWidth: true
                text: "Quiz Terminé !"
                color: "#0D47A1"
                font.pixelSize: 48
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: "Ton score est de " + correctAnswers + "/" + totalQuestions
                color: "#2E7D32"
                font.pixelSize: 28
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Rectangle {
                width: 180
                height: 50
                color: "#607D8B"
                radius: 25
                Layout.alignment: Qt.AlignHCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "Retour à l'accueil"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        returnTimer.stop()
                        stackView.pop()
                    }
                }
            }
        }
    }
}
