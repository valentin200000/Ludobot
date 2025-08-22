import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects
import "."

ApplicationWindow {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    title: "LudoBot"
    flags: Qt.Window | Qt.FramelessWindowHint
    visibility: Window.FullScreen
    Material.theme: Style.isDarkTheme ? Material.Dark : Material.Light
    Material.accent: Style.accentColor
    Material.primary: Style.primaryColor
    Material.background: Style.backgroundColor

    property font appFont: Qt.font({
        family: "Roboto, Arial, Helvetica, sans-serif",
        pixelSize: Style.fontSizeMedium
    })

    // Mode global : "parent" ou "enfant"
    property string appMode: "enfant" // Démarre en mode enfant par défaut
    // Age global sélectionné par le parent
    property int globalSelectedAge: 3
    
    // Objet global pour les fonctions accessibles depuis n'importe où
    property QtObject appGlobals: QtObject {
        // Fonction pour montrer la page d'accueil interne avec bouton JOUER
        function showInternalWelcomePage() {
            // Vérifier s'il y a des pages à supprimer
            while (stackView.depth > 1) {
                stackView.pop(null, StackView.Immediate)
            }
            // Remplacer la page actuelle par la page d'accueil interne
            stackView.replace(null, welcomePage.createObject(stackView))
            console.log("Page d'accueil interne affichée")
        }
    }

    // Bandeau de mode parent/enfant visible sur toutes les pages
    Rectangle {
        id: modeSwitchBanner
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 60
        color: Style.surfaceColor
        z: 10 // Pour s'assurer qu'il reste au-dessus des autres éléments
        
        // Ombre légère en bas
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.15)
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 2
            shadowBlur: 4
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Style.spacingMedium
            spacing: Style.spacingMedium
            
            Image {
                // Affiche l'icône correspondant au mode actif
                source: modeSwitch.checked ? "assets/icons/parent.svg" : "assets/icons/kid.svg"
                sourceSize.width: 24
                sourceSize.height: 24
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                fillMode: Image.PreserveAspectFit
            }
            
            Text {
                // Affiche le mode actif à gauche du switch
                text: modeSwitch.checked ? "Mode Parent" : "Mode Enfant"
                font {
                    family: appFont.family
                    pixelSize: Style.fontSizeLarge
                    weight: Font.Medium
                }
                color: Style.textColorPrimary
                Layout.fillWidth: true
            }
            
            // Switch standard mais plus grand et plus visible
            Switch {
                id: modeSwitch
                checked: appMode === "parent" // Inversé : checked = mode parent
                onCheckedChanged: {
                    // Si on passe de enfant à parent (checked=true), demander un code
                    if (checked && appMode !== "parent") {
                        // Annuler le switch pour le moment
                        checked = false;
                        // Montrer la page de code PIN
                        var component = Qt.createComponent("ParentCodePage.qml");
                        if (component.status === Component.Ready) {
                            var parentCodePage = stackView.push(component);
                            // Écouter un signal quand le code est validé
                            parentCodePage.codeAccepted.connect(function() {
                                // Activer le mode parent seulement après validation du code
                                appMode = "parent";
                                modeSwitch.checked = true;
                            });
                        }
                    } else {
                        // Pour passer de parent à enfant, pas besoin de code
                        appMode = checked ? "parent" : "enfant";
                    }
                }
                Material.accent: Style.accentColor
                scale: 2.0 // Agrandit le switch de 100%
                Layout.alignment: Qt.AlignVCenter
            }
            
            // Espace pour séparer le switch des boutons
            Item {
                width: 10
            }
            
            // La configuration WiFi est accessible depuis la page des réglages
            
            // Bouton réglages (icône uniquement) - visible seulement en mode parent
            RoundButton {
                id: settingsButton
                visible: appMode === "parent"
                icon.source: "assets/icons/settings.svg"
                icon.width: 24
                icon.height: 24
                icon.color: Style.textColorPrimary
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Material.background: Style.surfaceColor
                Material.elevation: 1
                scale: 1.2 // Légèrement agrandi pour harmoniser avec le switch
                onClicked: {
                    console.log("Opening settings page")
                    stackView.push("SettingsPage.qml")
                }
            }
            
            // Espace entre les boutons
            Item {
                width: 10
                visible: appMode === "parent"
            }
            
            // Bouton quitter (croix) - visible seulement en mode parent
            RoundButton {
                visible: appMode === "parent"
                text: "✕" // Croix Unicode
                font.pixelSize: 20
                font.bold: true
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Material.background: Style.dangerColor
                Material.foreground: "white"
                Material.elevation: 1
                scale: 1.2 // Légèrement agrandi pour harmoniser avec le switch
                onClicked: Qt.quit()
            }
        }
    }

    StackView {
        id: stackView
        anchors {
            top: modeSwitchBanner.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        initialItem: "WelcomePage.qml"
        Component.onCompleted: {
            console.log("StackView initialItem:", initialItem);
        }
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Style.animationDurationNormal
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Style.animationDurationNormal
            }
        }
        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Style.animationDurationNormal
            }
        }
        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Style.animationDurationNormal
            }
        }
    }

    Component {
        id: welcomePage
        Page {
            background: Rectangle {
                color: Style.backgroundColor
            }

            Rectangle {
                anchors.fill: parent
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
                }

                Item {
                    id: headerSection
                    width: parent.width
                    height: parent.height * 0.4
                    anchors.top: parent.top

                    Image {
                        id: logoImage
                        source: "assets/LudoBot.png"
                        width: 300
                        height: 300
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        
                        // Animation subtile de pulsation
                        SequentialAnimation on scale {
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 1.05; duration: 2000; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.05; to: 1.0; duration: 2000; easing.type: Easing.InOutQuad }
                        }

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#80000000"
                            shadowHorizontalOffset: 0
                            shadowVerticalOffset: 4
                            shadowBlur: 15
                            colorization: 0.1
                            colorizationColor: Style.accentColor
                        }
                    }

                    Text {
                        id: titleText
                        text: "LudoBot"
                        color: Style.accentColor // Utilise la couleur orange du logo
                        font {
                            family: appFont.family
                            pixelSize: Style.fontSizeHeader
                            weight: Font.Bold
                        }
                        anchors {
                            top: logoImage.bottom
                            topMargin: Style.spacingSmall
                            horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Text {
                        id: subtitleText
                        text: "Apprenez en vous amusant"
                        color: Style.textColorSecondary
                        font {
                            family: appFont.family
                            pixelSize: Style.fontSizeMedium
                        }
                        anchors {
                            top: titleText.bottom
                            topMargin: Style.spacingTiny
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    // Le switch a été déplacé dans un bandeau global en haut de l'application
                }

                Rectangle {
                    id: menuSection
                    anchors {
                        top: headerSection.bottom
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    color: "transparent"

                    GridLayout {
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.9, 600)
                        columnSpacing: Style.spacingMedium
                        rowSpacing: Style.spacingMedium
                        columns: width > 500 ? 2 : 1

                        // Gros bouton jouer
                        Button {
                            Layout.fillWidth: true
                            text: "JOUER"
                            Layout.preferredHeight: 120 // Plus grand
                            Layout.preferredWidth: Math.min(parent.width * 0.8, 500)
                            Layout.alignment: Qt.AlignHCenter
                            Material.background: Style.accentColor // Orange pour le bouton JOUER
                            Material.foreground: "white"
                            Material.elevation: Style.elevation2
                            font.pixelSize: Style.fontSizeXLarge
                            font.weight: Font.Bold
                            onClicked: {
                                // Aller directement sur PlayPage avec l'âge global pour tous les modes
                                stackView.push("PlayPage.qml", {"selectedAge": globalSelectedAge, "appMode": appMode})
                            }
                            contentItem: RowLayout {
                                spacing: Style.spacingMedium
                                Item { width: Style.spacingMedium }
                                Image {
                                    source: "assets/icons/play.svg"
                                    sourceSize.width: 36
                                    sourceSize.height: 36
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    fillMode: Image.PreserveAspectFit
                                }
                                Text {
                                    text: parent.parent.text
                                    font {
                                        family: appFont.family
                                        pixelSize: Style.fontSizeXLarge
                                        weight: Font.Bold
                                    }
                                    color: "white"
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Le switch a été déplacé en haut de la page

                        // Les boutons réglages et quitter ont été déplacés dans le bandeau du haut
                    }
                }
            }
        }
    }
}
