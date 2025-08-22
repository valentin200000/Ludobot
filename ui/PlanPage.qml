import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

import "."

Page {
    id: planPage
    title: qsTr("Plan de l'établissement")

    // Header avec bouton retour
    header: ToolBar {
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
            }

            Label {
                text: planPage.title
                font.pixelSize: 24
                font.family: "Roboto"
                color: "white"
                Layout.fillWidth: true
            }

            // Spacer pour aligner le titre
            Item {
                Layout.preferredWidth: 48
            }
        }
    }

    // Contenu principal
    Image {
        id: planImage
        source: "../quizzes/plan.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }
}
