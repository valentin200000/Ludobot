import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects
import "."

Page {
    id: categoryPage
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
            anchors.topMargin: parent.height * 0.7 // Position plus basse sur l'écran
            opacity: 0.07 // Très léger pour ne pas gêner la lecture
            fillMode: Image.PreserveAspectFit
            z: 0 // S'assurer qu'il reste en arrière-plan
        }
    }

    // Fonction pour obtenir les catégories avec leurs propriétés
    function getCategories() {
        return [
            {name: "Grand Parent", icon: "👴", color: "#6A5ACD", iconBg: "#EDEDFA", mode: "parent", age: 65, isEmoji: true},
            {name: "Enfant", icon: "👶", color: "#4CAF50", iconBg: "#E8F5E9", mode: "enfant", age: globalSelectedAge, isEmoji: true},
            {name: "Formation", icon: "🎓", color: "#2196F3", iconBg: "#E3F2FD", mode: "formation", age: 30, isEmoji: true}
        ];
    }

    header: ToolBar {
        id: toolbar
        height: 70
        Material.background: Style.surfaceColor
        Material.elevation: Style.elevation2

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.spacingMedium
            anchors.rightMargin: Style.spacingMedium

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
                text: "Choisissez votre profil"
                font.pixelSize: Style.fontSizeXLarge
                font.family: appFont.family
                font.weight: Font.Medium
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: Style.textColorPrimary
            }
        }
    }

    ScrollView {
        id: horizontalScrollView
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true
        contentWidth: categoryRow.width

        // Centrer le contenu verticalement
        Item {
            width: categoryRow.width
            height: parent.height
            
            // Rangée horizontale pour les cartes
            Row {
                id: categoryRow
                spacing: Style.spacingLarge * 2
                anchors.centerIn: parent

                // Modèle de données pour les catégories
                Repeater {
                    model: getCategories()
                    
                    delegate: Item {
                        id: categorySquare
                        width: 400
                        height: 500
                        
                        property int animationDuration: Style.animationDurationFast

                        Rectangle {
                            id: cardBackground
                            width: parent.width
                            height: parent.width
                            anchors.top: parent.top
                            color: Style.surfaceColor
                            radius: Style.radiusMedium
                            
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: Qt.rgba(0, 0, 0, 0.15)
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 2
                                shadowBlur: 8
                            }

                            states: [
                                State {
                                    name: "pressed"
                                    PropertyChanges {
                                        target: cardBackground
                                        scale: 0.95
                                    }
                                }
                            ]

                            transitions: [
                                Transition {
                                    to: "pressed"
                                    NumberAnimation { properties: "scale"; duration: categorySquare.animationDuration; easing.type: Easing.OutQuad }
                                },
                                Transition {
                                    from: "pressed"
                                    NumberAnimation { properties: "scale"; duration: categorySquare.animationDuration; easing.type: Easing.OutQuad }
                                }
                            ]
                            
                            Rectangle {
                                id: colorBar
                                width: parent.width
                                height: Style.spacingMedium * 3
                                color: modelData.color
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                radius: parent.radius
                                
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: parent.height / 2
                                    color: parent.color
                                }
                            }

                            Item {
                                anchors.fill: parent
                                anchors.topMargin: colorBar.height + Style.spacingMedium * 2
                                anchors.leftMargin: Style.spacingMedium * 2
                                anchors.rightMargin: Style.spacingMedium * 2
                                anchors.bottomMargin: Style.spacingMedium * 2

                                Rectangle {
                                    id: iconBackground
                                    width: parent.width * 0.7
                                    height: width
                                    color: modelData.iconBg
                                    radius: width / 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    
                                    // Affichage d'emoji ou d'image selon le type
                                    Text {
                                        id: emojiIcon
                                        visible: modelData.isEmoji === true
                                        text: modelData.icon
                                        font.pixelSize: parent.width * 0.6
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    Image {
                                        id: iconImage
                                        visible: !modelData.isEmoji
                                        source: "assets/icons/" + (modelData.mode === "parent" ? "elder" : modelData.mode === "enfant" ? "kid" : "education") + ".svg"
                                        width: parent.width * 0.6
                                        height: width
                                        anchors.centerIn: parent
                                        fillMode: Image.PreserveAspectFit
                                    }
                                }

                                Text {
                                    text: modelData.name
                                    font.pixelSize: Style.fontSizeLarge * 1.5
                                    font.weight: Font.DemiBold
                                    font.family: appFont.family
                                    color: modelData.color
                                    anchors.top: iconBackground.bottom
                                    anchors.topMargin: Style.spacingLarge
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: cardMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onPressed: cardBackground.state = "pressed"
                                onReleased: cardBackground.state = ""
                                
                                onClicked: {
                                    appMode = modelData.mode
                                    
                                    // Redirection spéciale pour le mode enfant
                                    if (modelData.mode === "enfant") {
                                        // Redirection vers la page d'accueil interne avec bouton JOUER
                                        appMode = "enfant"
                                        
                                        // Appel de la fonction via l'objet global défini dans main.qml
                                        appGlobals.showInternalWelcomePage()
                                    } else if (modelData.mode === "parent") {
                                        // Vérifier le mode actuel
                                        if (root.appMode === "parent") {
                                            // En mode parent, accès direct sans code
                                            stackView.push("VisiteurPage.qml", {"selectedAge": modelData.age, "appMode": modelData.mode})
                                        } else {
                                            // En mode enfant, demander le code
                                            stackView.push("ParentCodePage.qml")
                                        }
                                    
                                    } else {
                                        // Pour le mode formation, on garde le comportement normal
                                        stackView.push("PlayPage.qml", {"selectedAge": modelData.age, "appMode": modelData.mode})
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: Style.fontSizeMedium * 2
                            font.weight: Font.Medium
                            font.family: appFont.family
                            color: Style.textColorPrimary
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            anchors.top: cardBackground.bottom
                            anchors.topMargin: Style.spacingMedium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    // Indicateur de défilement horizontal
    PageIndicator {
        id: indicator
        count: Math.ceil(categoryRow.width / horizontalScrollView.width)
        currentIndex: Math.floor(horizontalScrollView.contentItem.contentX / (horizontalScrollView.width - Style.spacingMedium * 2))
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Style.spacingMedium
        visible: count > 1
        
        delegate: Rectangle {
            implicitWidth: 10
            implicitHeight: 10
            radius: width / 2
            color: index === indicator.currentIndex ? Style.accentColor : Style.textColorTertiary
            opacity: index === indicator.currentIndex ? 1 : 0.5
        }
    }

    // Bouton retour en bas de l'écran
    RoundButton {
        id: backButtonBottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Style.spacingMedium
        anchors.bottomMargin: Style.spacingMedium
        icon.source: "assets/icons/arrow_back.svg"
        icon.width: 24
        icon.height: 24
        width: 56
        height: 56
        Material.background: Style.surfaceColor
        Material.elevation: Style.elevation2
        onClicked: stackView.pop()
    }

    // Simple touch area for swipe navigation
    MouseArea {
        anchors.fill: parent
        property real startX: 0
        property real threshold: 50
        
        onPressed: function(mouse) {
            startX = mouse.x
        }
        
        onReleased: function(mouse) {
            var delta = mouse.x - startX
            if (Math.abs(delta) > threshold) {
                if (delta > 0 && horizontalScrollView.contentItem.contentX > 0) {
                    // Swipe right - go to previous
                    horizontalScrollView.contentItem.contentX -= horizontalScrollView.width * 0.8
                } else if (delta < 0 && horizontalScrollView.contentItem.contentX < categoryRow.width - horizontalScrollView.width) {
                    // Swipe left - go to next
                    horizontalScrollView.contentItem.contentX += horizontalScrollView.width * 0.8
                }
            }
        }
        
        // Allow child mouse areas to handle their own events
        propagateComposedEvents: true
    }
}
