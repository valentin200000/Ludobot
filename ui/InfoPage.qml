import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: infoPage
    title: qsTr("Informations utiles")
    
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
                text: "Informations utiles"
                font.pixelSize: 24
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }
        }
    }

    // Liste des informations
    ListView {
        id: infoListView
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        clip: true

        model: ListModel {
            ListElement { 
                title: "Établissement" 
                emoji: "🏠" 
                color: "#2196F3"
                bgColor: "#E3F2FD"
                description: "Nom : EHPAD Les Jardins du Temps\n\nAdresse : 12, rue des Lilas, 75012 Paris\n\nAccueil : ouvert de 8h00 à 20h00\n\nAccès : Parking visiteurs gratuit, arrêt de bus « Résidence Seniors » à 100 m"
            }
            ListElement { 
                title: "Horaires de visite" 
                emoji: "🕒" 
                color: "#E91E63"
                bgColor: "#FCE4EC"
                description: "Lundi → Dimanche : 10h00 – 18h00\n\nSorties accompagnées possibles jusqu'à 20h00 (prévenir l'accueil)\n\nFermeture du portail : 20h00"
            }
            ListElement { 
                title: "Santé & sécurité" 
                emoji: "❤️" 
                color: "#3F51B5"
                bgColor: "#E8EAF6"
                description: "Urgence infirmière : poste 112\n\nMédecin de garde : disponible en journée (demander à l'accueil)\n\nRappels médicaux :\n9h00 → Distribution médicaments du matin\n14h00 → Rendez-vous kiné\nConsignes de sécurité :\nIssues de secours signalées par des panneaux verts\nEn cas d'incendie → suivre les instructions du personnel\nRobot équipé de capteurs anti-chute et d'arrêt d'urgence"
            }
            ListElement { 
                title: "Contacts utiles" 
                emoji: "📞" 
                color: "#009688"
                bgColor: "#E0F2F1"
                description: "Accueil principal : 01 23 45 67 89\n\nInfirmière de garde : poste 112\n\nResponsable animations : poste 215\n\nService administratif : poste 301\n\nFamilles & visiteurs (assistance) : 06 12 34 56 78"
            }
        }

        // Délégué pour afficher chaque information
        delegate: Rectangle {
            width: infoListView.width
            height: contentColumn.height + 32
            radius: 15
            color: "white"

            // Bordure légère
            border.width: 1
            border.color: "#DDDDDD"

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

                    // Titre de l'information
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

                // Description de l'information
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
