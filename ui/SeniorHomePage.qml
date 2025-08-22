import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: seniorHomePage
    background: Rectangle { 
        color: Style.backgroundColor
        
        // Logo en tant qu'image de fond avec transparence
        Image {
            id: backgroundLogo
            source: "assets/LudoBot.png"
            width: parent.width * 1.5
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.7
            opacity: 0.07
            fillMode: Image.PreserveAspectFit
            z: 0
        }
    }
    
    header: ToolBar {
        id: toolbar
        height: 70
        Material.background: Style.surfaceColor
        Material.elevation: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            RoundButton {
                id: backButton
                contentItem: Text {
                    text: "←" // Emoji flèche gauche
                    font.pixelSize: 24
                    color: Style.textColorPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                flat: true
                onClicked: stackView.pop()
            }

            Label {
                text: "Choix du Profil"
                font.pixelSize: 24
                font.family: appFont.family
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: Style.textColorPrimary
            }
            
            // Espacement pour équilibrer le header
            Item { 
                width: backButton.width 
            }
        }
    }
    
    // Contenu principal
    Item {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        
        // Titre principal
        Text {
            id: welcomeText
            text: "Bienvenue"
            font.pixelSize: 32
            font.weight: Font.Bold
            font.family: appFont.family
            color: Style.textColorPrimary
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Sous-titre
        Text {
            id: subtitleText
            text: "Choisissez votre profil"
            font.pixelSize: 22
            font.weight: Font.Medium
            font.family: appFont.family
            color: Style.textColorSecondary
            anchors.top: welcomeText.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Conteneur pour les cartes principales (Visiteur et Résident)
        Row {
            id: cardsContainer
            anchors.top: subtitleText.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            height: parent.height * 0.5
            spacing: 40
            
            // Carte Visiteur
            Item {
                id: visitorItem
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                
                Rectangle {
                    id: visitorCard
                    width: parent.width
                    height: parent.width * 1.2
                    radius: 10
                    color: Style.surfaceColor
                    anchors.centerIn: parent
                    
                    // Ombre simulée avec un rectangle légèrement plus grand en arrière-plan
                    Rectangle {
                        z: -1
                        anchors.centerIn: parent
                        width: parent.width + 4
                        height: parent.height + 4
                        radius: parent.radius
                        color: "#20000000"
                        opacity: 0.5
                    }
                    
                    // Cercle pour l'icône
                    Rectangle {
                        id: visitorIconBg
                        width: parent.width * 0.6
                        height: width
                        radius: width / 2
                        color: "#E8F5E9"  // Couleur pastel verte
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.1
                        
                        // Emoji centré
                        Text {
                            anchors.centerIn: parent
                            text: "👪"  // Emoji famille
                            font.pixelSize: parent.width * 0.6
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // Titre avec style du thème
                    Text {
                        id: visitorTitle
                        text: "Visiteur"
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        font.family: appFont.family
                        color: Style.primaryColor
                        anchors.top: visitorIconBg.bottom
                        anchors.topMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Description
                    Text {
                        text: "Accès aux activités et informations"
                        font.pixelSize: 16
                        font.family: appFont.family
                        color: Style.textColorSecondary
                        width: parent.width - 40
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        anchors.top: visitorTitle.bottom
                        anchors.topMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    
                    // Zone cliquable
                    MouseArea {
                        anchors.fill: parent
                        
                        // Animation au clic
                        onPressed: {
                            parent.scale = 0.95
                        }
                        
                        onReleased: {
                            parent.scale = 1.0
                        }
                        
                        onCanceled: {
                            parent.scale = 1.0
                        }
                        
                        onClicked: {
                            // Accès direct au mode visiteur (sans code)
                            stackView.push("VisiteurPage.qml")
                        }
                    }
                    
                    // Transition fluide
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                }
                
                // Texte sous la carte
                Text {
                    text: "Mode Visiteur"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                    font.family: appFont.family
                    color: Style.textColorPrimary
                    anchors.top: visitorCard.bottom
                    anchors.topMargin: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // Carte Résident
            Item {
                id: residentItem
                width: (parent.width - parent.spacing) / 2
                height: parent.height
                
                Rectangle {
                    id: residentCard
                    width: parent.width
                    height: parent.width * 1.2
                    radius: 10
                    color: Style.surfaceColor
                    anchors.centerIn: parent
                    
                    // Ombre simulée
                    Rectangle {
                        z: -1
                        anchors.centerIn: parent
                        width: parent.width + 4
                        height: parent.height + 4
                        radius: parent.radius
                        color: "#20000000"
                        opacity: 0.5
                    }
                    
                    // Cercle pour l'icône
                    Rectangle {
                        id: residentIconBg
                        width: parent.width * 0.6
                        height: width
                        radius: width / 2
                        color: "#FFF3E0"  // Couleur pastel orange
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height * 0.1
                        
                        // Emoji centré
                        Text {
                            anchors.centerIn: parent
                            text: "👴"  // Emoji personne âgée
                            font.pixelSize: parent.width * 0.6
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // Titre avec style du thème
                    Text {
                        id: residentTitle
                        text: "Résident(e)"
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        font.family: appFont.family
                        color: Style.accentColor
                        anchors.top: residentIconBg.bottom
                        anchors.topMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Description
                    Text {
                        text: "Accès à votre espace personnel"
                        font.pixelSize: 16
                        font.family: appFont.family
                        color: Style.textColorSecondary
                        width: parent.width - 40
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        anchors.top: residentTitle.bottom
                        anchors.topMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    
                    // Zone cliquable
                    MouseArea {
                        anchors.fill: parent
                        
                        // Animation au clic
                        onPressed: {
                            parent.scale = 0.95
                        }
                        
                        onReleased: {
                            parent.scale = 1.0
                        }
                        
                        onCanceled: {
                            parent.scale = 1.0
                        }
                        
                        onClicked: {
                            // Accès direct sans code PIN
                            stackView.push("ResidentPage.qml")
                        }
                    }
                    
                    // Transition fluide
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                }
                
                // Texte sous la carte
                Text {
                    text: "Mode Résident"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                    font.family: appFont.family
                    color: Style.textColorPrimary
                    anchors.top: residentCard.bottom
                    anchors.topMargin: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    
}
