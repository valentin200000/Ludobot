import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Effects
import "."

Page {
    id: appointmentReminderPage
    background: Rectangle { 
        color: Style.backgroundColor 
    }
    
    property int selectedAge: 65
    property string appMode: "parent"

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
                text: "Rappel Rendez-vous"
                font.pixelSize: Style.fontSizeLarge
                font.family: appFont.family
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: Style.textColorPrimary
            }
            
            Item { 
                width: backButton.width 
            }
        }
    }

    // Contenu central
    Item {
        anchors.fill: parent
        anchors.topMargin: Style.spacingLarge

        Text {
            anchors.centerIn: parent
            text: "Rappel Rendez-vous\n\nEn construction..."
            font.pixelSize: Style.fontSizeLarge
            font.family: appFont.family
            color: Style.textColorPrimary
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
