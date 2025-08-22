import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects
import "."

Page {
    id: settingsPage
    background: Rectangle { color: Style.backgroundColor }

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
                icon.source: "assets/icons/arrow_back.svg"
                icon.width: 24
                icon.height: 24
                flat: true
                onClicked: stackView.pop()
                Material.foreground: Style.textColorPrimary
            }

            Label {
                text: "Réglages"
                font.pixelSize: Style.fontSizeXLarge
                font.family: appFont.family
                font.weight: Font.Medium
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: Style.textColorPrimary
            }

            Item { width: backButton.width }
        }
    }

    ScrollView {
        id: settingsScrollView
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: settingsColumn
            spacing: Style.spacingMedium
            width: settingsScrollView.width - Style.spacingMedium * 2

            SettingsCard {
                title: "Volume"
                icon: "assets/icons/volume_up.svg"
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Style.spacingMedium
                    Layout.fillWidth: true
                    Layout.margins: Style.spacingMedium

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingMedium

                        Image {
                            source: "assets/icons/volume_down.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Slider {
                            id: volumeSlider
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            from: 0
                            to: 1.0
                            value: volumeController ? volumeController.volume : 0.5
                            live: true
                            snapMode: Slider.SnapAlways
                            stepSize: 0.01
                            onValueChanged: volumeText.text = Math.round(value * 100) + "%"
                            onPressedChanged: {
                                if (!pressed && volumeController)
                                    volumeController.set_volume(value)
                            }
                            Material.accent: Style.accentColor
                        }

                        Image {
                            source: "assets/icons/volume_up.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            id: volumeText
                            text: Math.round(volumeSlider.value || 0) + "%"
                            color: Style.textColorPrimary
                            font.family: appFont.family
                            font.pixelSize: Style.fontSizeMedium
                            font.weight: Font.Medium
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
            
            SettingsCard {
                title: "Luminosité"
                icon: "assets/icons/brightness_medium.svg"
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: Style.spacingMedium
                    Layout.fillWidth: true
                    Layout.margins: Style.spacingMedium

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingMedium

                        Image {
                            source: "assets/icons/brightness_low.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Slider {
                            id: brightnessSlider
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            from: 0
                            to: 1.0
                            value: brightnessController ? brightnessController.brightness : 0.5
                            live: true
                            snapMode: Slider.SnapAlways
                            stepSize: 0.01
                            
                            // Mettre à jour le texte quand le curseur change
                            onValueChanged: {
                                brightnessText.text = Math.round(value * 100) + "%"
                            }
                            
                            // Appliquer la valeur uniquement quand l'utilisateur relâche le curseur
                            onPressedChanged: {
                                if (!pressed && brightnessController) {
                                    brightnessController.set_brightness(value)
                                }
                            }
                            
                            Material.accent: Style.accentColor
                            
                            // Se conncecter une seule fois au début pour initialiser
                            Component.onCompleted: {
                                if (brightnessController) {
                                    // Initialiser le curseur avec la valeur actuelle du système
                                    value = brightnessController.brightness
                                    brightnessText.text = Math.round(value * 100) + "%"
                                }
                            }
                        }

                        Image {
                            source: "assets/icons/brightness_high.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            id: brightnessText
                            text: Math.round(brightnessSlider.value || 0) + "%"
                            color: Style.textColorPrimary
                            font.family: appFont.family
                            font.pixelSize: Style.fontSizeMedium
                            font.weight: Font.Medium
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            SettingsCard {
                title: "Vibration"
                icon: "assets/icons/vibration.svg"
                Layout.fillWidth: true

                RowLayout {
                    spacing: Style.spacingMedium
                    Layout.fillWidth: true
                    Layout.margins: Style.spacingMedium

                    Text {
                        text: "Activer les vibrations"
                        color: Style.textColorPrimary
                        font.family: appFont.family
                        font.pixelSize: Style.fontSizeMedium
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: vibrationSwitch
                        checked: settingsController ? settingsController.vibration_enabled : true
                        onCheckedChanged: {
                            if (settingsController) settingsController.vibration_enabled = vibrationSwitch.checked
                        }
                        Material.accent: Style.accentColor
                    }
                }
            }

            SettingsCard {
                title: "Wi-Fi"
                icon: "assets/icons/wifi.svg"
                Layout.fillWidth: true

                RowLayout {
                    spacing: Style.spacingMedium
                    Layout.fillWidth: true
                    Layout.margins: Style.spacingMedium

                    Label {
                        text: "Configurer la connexion Wi-Fi"
                        font.family: appFont.family
                        font.pixelSize: Style.fontSizeMedium
                        color: Style.textColorSecondary
                        Layout.fillWidth: true
                    }

                    Button {
                        id: wifiButton
                        text: "Configurer"
                        Material.background: Style.accentColor
                        Material.foreground: "white"
                        font.family: appFont.family
                        font.pixelSize: Style.fontSizeMedium
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 120
                        
                        // Action pour ouvrir la page de configuration WiFi
                        onClicked: {
                            stackView.push("WifiPage.qml")
                        }
                    }
                }
            }

            SettingsCard {
                title: "Apparence"
                icon: "assets/icons/palette.svg"
                Layout.fillWidth: true

                RowLayout {
                    spacing: Style.spacingMedium
                    Layout.fillWidth: true
                    Layout.margins: Style.spacingMedium

                    Text {
                        text: "Mode sombre"
                        color: Style.textColorPrimary
                        font.family: appFont.family
                        font.pixelSize: Style.fontSizeMedium
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: darkModeSwitch
                        checked: settingsController ? settingsController.is_dark_mode : false
                        onCheckedChanged: {
                            if (settingsController) settingsController.is_dark_mode = checked
                        }
                        Material.accent: Style.accentColor
                    }
                }
            }
        }
    }

    component SettingsCard: Pane {
        id: settingsCard
        property string title: ""
        property string icon: ""
        default property alias content: contentLayout.children

        Material.background: Style.surfaceColor
        Material.elevation: Style.elevation1
        implicitHeight: headerRow.height + contentLayout.height + Style.spacingLarge
        Layout.fillWidth: true
        padding: 0
        clip: true

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.15)
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 2
            shadowBlur: 8
        }

        background: Rectangle {
            color: Style.surfaceColor
            radius: Style.radiusMedium
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Pane {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                padding: 0
                Material.elevation: 0
                Material.background: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(Style.accentColor.r, Style.accentColor.g, Style.accentColor.b, 0.1)
                    visible: true
                }

                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    anchors.leftMargin: Style.spacingMedium
                    anchors.rightMargin: Style.spacingMedium
                    spacing: Style.spacingMedium

                    Image {
                        source: icon
                        sourceSize.width: 24
                        sourceSize.height: 24
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        text: title
                        font.family: appFont.family
                        font.pixelSize: Style.fontSizeLarge
                        font.weight: Font.Medium
                        color: Style.textColorPrimary
                        Layout.fillWidth: true
                    }
                }
            }

            ColumnLayout {
                id: contentLayout
                Layout.fillWidth: true
                spacing: Style.spacingMedium
            }
        }
    }
    
    Popup {
        id: savePopup
        anchors.centerIn: parent
        width: 300
        height: 160
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Style.animationDurationNormal }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Style.animationDurationNormal }
        }
        
        background: Rectangle {
            color: Style.surfaceColor
            radius: Style.radiusLarge
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.2)
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 4
                shadowBlur: 12
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.spacingLarge
            spacing: Style.spacingLarge
            
            Image {
                source: "assets/icons/check_circle.svg"
                sourceSize.width: 48
                sourceSize.height: 48
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Paramètres sauvegardés !"
                font.family: appFont.family
                font.pixelSize: Style.fontSizeLarge
                font.weight: Font.Medium
                color: Style.textColorPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            
            Button {
                text: "OK"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                Material.background: Style.accentColor
                Material.foreground: "white"
                font.family: appFont.family
                font.pixelSize: Style.fontSizeMedium
                onClicked: savePopup.close()
            }
        }
    }
}
