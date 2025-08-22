import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."

Page {
    id: parentCodePage
    
    // Signal émis quand le code a été correctement saisi
    signal codeAccepted()
    
    // Propriétés pour le code
    property string correctCode: "0000"
    property string currentCode: ""
    property string errorMessage: ""
    
    // Fond de la page
    Rectangle {
        anchors.fill: parent
        color: Style.backgroundColor
    }
    
    // Barre supérieure avec titre et bouton retour
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
        color: Style.surfaceColor
        
        // Bouton retour avec emoji flèche
        Rectangle {
            id: backButton
            width: 50
            height: 50
            radius: 25
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            
            Text {
                text: "←" // Emoji flèche gauche
                anchors.centerIn: parent
                font.pixelSize: 32
                color: Style.textColorPrimary
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: stackView.pop()
            }
        }
        
        // Titre
        Text {
            text: "Code d'accès"
            anchors.centerIn: parent
            font.pixelSize: 24
            font.bold: true
            color: Style.textColorPrimary
        }
    }
    
    // Contenu principal
    Column {
        anchors.top: headerBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 30
        
        // Texte d'instructions
        Text {
            text: "Entrez le code parent"
            font.pixelSize: 24
            color: Style.textColorPrimary
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        
        // Affichage des points pour le code saisi
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter
            
            Repeater {
                model: 4
                
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: index < currentCode.length ? Style.accentColor : "transparent"
                    border.color: Style.textColorSecondary
                    border.width: 2
                    
                    Text {
                        text: index < currentCode.length ? "\u2022" : ""
                        anchors.centerIn: parent
                        font.pixelSize: 40
                        color: "white"
                    }
                }
            }
        }
        
        // Message d'erreur
        Text {
            text: errorMessage
            color: "#F44336" // Rouge
            font.pixelSize: 18
            visible: errorMessage !== ""
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        
        // Espace flexible
        Item {
            height: 20
            width: 1
        }
        
        // Pavé numérique
        GridLayout {
            id: keypad
            columns: 3
            rowSpacing: 10
            columnSpacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Générer les boutons 1-9
            Repeater {
                model: 9
                
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 40
                    color: Style.surfaceColor
                    border.color: Style.textColorSecondary
                    border.width: 1
                    
                    Text {
                        text: (index + 1).toString()
                        anchors.centerIn: parent
                        font.pixelSize: 32
                        color: Style.textColorPrimary
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (currentCode.length < 4) {
                                currentCode += (index + 1).toString()
                                errorMessage = ""
                            }
                        }
                    }
                }
            }
            
            // Bouton Clear
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 40
                color: "#FFEB3B" // Jaune
                
                Text {
                    text: "C"
                    anchors.centerIn: parent
                    font.pixelSize: 32
                    color: "#000000"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentCode = ""
                        errorMessage = ""
                    }
                }
            }
            
            // Bouton 0
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 40
                color: Style.surfaceColor
                border.color: Style.textColorSecondary
                border.width: 1
                
                Text {
                    text: "0"
                    anchors.centerIn: parent
                    font.pixelSize: 32
                    color: Style.textColorPrimary
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (currentCode.length < 4) {
                            currentCode += "0"
                            errorMessage = ""
                        }
                    }
                }
            }
            
            // Bouton retour arrière
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 40
                color: "#F44336" // Rouge
                
                Text {
                    text: "⌫" // Symbole retour arrière
                    anchors.centerIn: parent
                    font.pixelSize: 32
                    color: "white"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (currentCode.length > 0) {
                            currentCode = currentCode.substring(0, currentCode.length - 1)
                            errorMessage = ""
                        }
                    }
                }
            }
        }
        
        // Bouton de validation
        Rectangle {
            width: parent.width * 0.8
            height: 60
            radius: 30
            color: currentCode.length === 4 ? Style.accentColor : Style.textColorSecondary
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                text: "Valider"
                anchors.centerIn: parent
                font.pixelSize: 24
                font.bold: true
                color: "white"
            }
            
            MouseArea {
                anchors.fill: parent
                enabled: currentCode.length === 4
                onClicked: {
                    if (currentCode === correctCode) {
                        // Code correct
                        root.appMode = "parent"
                        codeAccepted()
                        stackView.pop()
                    } else {
                        // Code incorrect
                        errorMessage = "Code incorrect, veuillez réessayer"
                        currentCode = ""
                    }
                }
            }
        }
    }
}
