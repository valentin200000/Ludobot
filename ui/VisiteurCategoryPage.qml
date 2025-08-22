import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtMultimedia 5.15
import QtQuick.Effects
import "."

Page {
    id: visiteurCategoryPage
    // Mode d'application global (lié à root, défaut enfant)
    property string appMode: typeof root !== 'undefined' && root.appMode ? root.appMode : "enfant"
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
    
    // Propriété pour stocker le type de catégorie visiteur
    property string categoryType: "plan" // "plan", "activity", "info"
    property string categoryTitle: "Catégories"

    // En-tête avec titre dynamique
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
                text: categoryTitle
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

    // Fonction pour obtenir les catégories selon le type
    function getCategories() {
        // Différentes catégories selon le type sélectionné
        if (categoryType === "plan") {
            return [
                {name: "Rez-de-chaussée", icon: "🏠", color: "#2196F3", iconBg: "#E3F2FD", isEmoji: true},
                {name: "1er étage", icon: "🔝", color: "#E91E63", iconBg: "#FCE4EC", isEmoji: true},
                {name: "Extérieur", icon: "🌳", color: "#00BCD4", iconBg: "#E0F7FA", isEmoji: true}
            ];
        } 
        else if (categoryType === "activity") {
            return [
                {name: "Programme du jour", icon: "📅", color: "#2196F3", iconBg: "#E3F2FD", isEmoji: true},
                {name: "Activités hebdo", icon: "🎭", color: "#E91E63", iconBg: "#FCE4EC", isEmoji: true},
                {name: "Événements spéciaux", icon: "🎉", color: "#00BCD4", iconBg: "#E0F7FA", isEmoji: true},
                {name: "Activités & Loisirs", icon: "🎮", color: "#4CAF50", iconBg: "#E8F5E9", isEmoji: true, pageName: "ActivitiesPage.qml"}
            ];
        }
        else if (categoryType === "info") {
            return [
                {name: "Personnel de l'établissement", icon: "👥", color: "#2196F3", iconBg: "#E3F2FD", isEmoji: true, isLocked: true},
                {name: "Consignes info résident", icon: "📋", color: "#E91E63", iconBg: "#FCE4EC", isEmoji: true, isLocked: true},
                {name: "À propos", icon: "ℹ️", color: "#00BCD4", iconBg: "#E0F7FA", isEmoji: true}
            ];
        }
        return [];
    }

    // Effet sonore simulé (Timer stub, évite dépendances Audio/SoundEffect)
    Timer {
        id: clickSound
        interval: 5
        repeat: false
        function play() { start() }
    }
    
    // Vue principale
    Item {
        anchors.fill: parent
        
        // Row principal avec des cartes horizontales
        Row {
            id: categoryRow
            anchors.centerIn: parent
            spacing: 20
            
            Repeater {
                model: getCategories()
                
                delegate: Rectangle {
                    id: categoryCard
                    width: 250
                    height: 300
                    radius: 10
                    color: "white"
                    opacity: modelData.isLocked ? 0.7 : 1.0

                    // Effet de flou pour les éléments verrouillés (MultiEffect)
                    layer.enabled: modelData.isLocked
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: modelData.isLocked ? 0.2 : 0.0
                    }
                    
                    // Barre de couleur en haut
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: modelData.color
                        radius: 10
                        anchors.top: parent.top
                        
                        // Pour garder les coins carrés en bas
                        Rectangle {
                            width: parent.width
                            height: parent.height / 2
                            color: parent.color
                            anchors.bottom: parent.bottom
                        }
                    }
                    
                    // Cercle pour l'icône
                    Rectangle {
                        width: 120
                        height: 120
                        radius: width/2
                        color: modelData.iconBg

                        // Icône de cadenas pour les éléments verrouillés
                        Text {
                            visible: modelData.isLocked
                            text: "🔒"
                            font.pixelSize: 24
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                                rightMargin: 5
                                bottomMargin: 5
                            }
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 60
                        
                        // Emoji
                        Text {
                            text: modelData.icon
                            font.pixelSize: 60
                            color: modelData.color
                            anchors.centerIn: parent
                            font.family: appFont.family
                            font.bold: true
                            visible: modelData.isEmoji
                        }
                        
                        // Image
                        Image {
                            source: "assets/icons/" + modelData.icon + ".svg"
                            width: parent.width * 0.6
                            height: width
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit
                            visible: !modelData.isEmoji
                        }
                    }
                    
                    // Bouton de lecture
                    Rectangle {
                        width: 50
                        height: 50
                        radius: width/2
                        color: "white"
                        border.width: 2
                        border.color: "black"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: categoryText.top
                        anchors.bottomMargin: 15
                        
                        Text {
                            text: "▶"
                            font.pixelSize: 24
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Texte du bouton
                    Text {
                        id: categoryText
                        text: modelData.name
                        font.pixelSize: 20
                        font.family: appFont.family
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 20
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (modelData.isLocked) {
                                return;
                            }
                            parent.scale = 0.95
                            clickSound.play()
                            Timer.setTimeout(function() {
                                parent.scale = 1.0
                                if (categoryType === "plan") {
                                    stackView.push("MapViewPage.qml", {
                                        "mapTitle": modelData.name,
                                        "mapIcon": modelData.icon,
                                        "mapColor": modelData.color,
                                        "floorLevel": modelData.name.includes("Rez") ? 0 : 
                                                     modelData.name.includes("1er") ? 1 : -1
                                    })
                                } 
                                else if (categoryType === "activity") {
                                    if (modelData.pageName) {
                                        stackView.push(modelData.pageName, { "appMode": visiteurCategoryPage.appMode })
                                    } else {
                                        stackView.push("ActivityPage.qml", {
                                            "activityType": modelData.name.includes("jour") ? "daily" : 
                                                           modelData.name.includes("hebdo") ? "weekly" : "special",
                                            "activityTitle": modelData.name,
                                            "activityIcon": modelData.icon,
                                            "activityColor": modelData.color,
                                            "appMode": visiteurCategoryPage.appMode
                                        })
                                    }
                                }
                                else if (categoryType === "info") {
                                    stackView.push("InfoPage.qml", {
                                        "infoType": modelData.name.includes("Services") ? "services" :
                                                   modelData.name.includes("Contacts") ? "contacts" : "about",
                                        "infoTitle": modelData.name,
                                        "infoIcon": modelData.icon,
                                        "infoColor": modelData.color
                                    })
                                }
                            }, 200)
                        }
                        
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.9
                        onExited: parent.opacity = 1.0
                    }
                    
                    Behavior on scale { NumberAnimation { duration: 100 } }
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
}
