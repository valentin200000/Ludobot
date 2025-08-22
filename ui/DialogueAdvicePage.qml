import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: dialogueAdvicePage
    title: qsTr("Conseils pour le dialogue")
    
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
                text: "Conseils pour le dialogue"
                font.pixelSize: 24
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }
        }
    }

    // Liste des conseils
    ListView {
        id: adviceListView
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        clip: true

        model: ListModel {
            ListElement { 
                title: "Écouter avec attention" 
                emoji: "👂" 
                color: "#2196F3"
                bgColor: "#E3F2FD"
                description: "• Laissez le temps de parler sans interrompre\n\n• Reformulez pour vérifier que vous avez bien compris\n\n• Évitez de finir leurs phrases, même s'ils cherchent leurs mots\n\nExemple : 'Tu parlais de ton frère tout à l'heure, c'était lequel ?'"
            }
            ListElement { 
                title: "Utiliser un ton doux et calme" 
                emoji: "😊" 
                color: "#E91E63"
                bgColor: "#FCE4EC"
                description: "• Parlez lentement, distinctement\n\n• Adaptez le volume sans crier (sauf problème auditif)\n\n• Utilisez un ton affectueux, jamais infantilisant"
            }
            ListElement { 
                title: "Se mettre à leur niveau" 
                emoji: "👀" 
                color: "#3F51B5"
                bgColor: "#E8EAF6"
                description: "• Asseyez-vous pour être à leur hauteur si la personne est assise\n\n• Maintenez un contact visuel\n\n• Montrez de l'intérêt non verbal : hochements de tête, sourires, regard chaleureux"
            }
            ListElement { 
                title: "Poser des questions ouvertes" 
                emoji: "❓" 
                color: "#009688"
                bgColor: "#E0F2F1"
                description: "• Encouragez-les à raconter, partager des souvenirs\n\n• Favorisez les échanges naturels\n\nExemple : 'Qu'est-ce que tu aimais faire quand tu étais jeune ?'"
            }
            ListElement { 
                title: "Respecter leur rythme" 
                emoji: "💭" 
                color: "#FFC107"
                bgColor: "#FFF8E1"
                description: "• Laissez des silences, ils peuvent faire partie de la communication\n\n• Ne pas précipiter la conversation\n\n• Évitez de poser plusieurs questions d'affilée"
            }
            ListElement { 
                title: "Adapter si troubles cognitifs" 
                emoji: "🧠" 
                color: "#8BC34A"
                bgColor: "#F1F8E9"
                description: "• Utilisez des phrases simples\n\n• Donnez des repères concrets (date, lieu, heure)\n\n• Ne jamais corriger brusquement ou confronter ('Non, tu te trompes !') → préférez reformuler doucement"
            }
            ListElement { 
                title: "Valoriser leur parole" 
                emoji: "💬" 
                color: "#FF9800"
                bgColor: "#FFF3E0"
                description: "• Montrez que leur mémoire a de la valeur\n\n• Ne banalisez pas leurs inquiétudes, même si elles vous semblent mineures\n\n• Encouragez les récits positifs ou drôles"
            }
            ListElement { 
                title: "À éviter" 
                emoji: "🚫" 
                color: "#F44336"
                bgColor: "#FFEBEE"
                description: "• Ne pas parler à leur place ou comme à un enfant\n\n• Ne pas parler trop vite ou en langage trop technique\n\n• Ne pas démentir brutalement une illusion ou une confusion (ex : 'Non, ta mère est morte depuis 20 ans !') → préférez l'écoute empathique"
            }
        }

        // Délégué pour afficher chaque conseil
        delegate: Rectangle {
            width: adviceListView.width
            height: contentColumn.height + 32
            radius: 15
            color: "white"

            // Bordure rouge pour "À éviter", légère pour les autres
            border.width: model.title === "À éviter" ? 2 : 1
            border.color: model.title === "À éviter" ? "#F44336" : "#DDDDDD"

            ColumnLayout {
                id: contentColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 16
                }
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Cercle pour l'emoji
                    Rectangle {
                        width: 80
                        height: 80
                        radius: width/2
                        color: model.bgColor

                        Text {
                            text: model.emoji
                            font.pixelSize: 36
                            anchors.centerIn: parent
                        }
                    }

                    // Titre du conseil
                    Text {
                        text: model.title
                        font.pixelSize: 28
                        font.bold: true
                        font.family: "Roboto"
                        color: model.color
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }

                // Description du conseil
                Text {
                    text: model.description
                    font.pixelSize: 24
                    font.family: "Roboto"
                    color: "#333333"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    lineHeight: 1.4
                }
            }
        }
    }
}
