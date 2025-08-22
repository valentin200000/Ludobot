import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import "."

Page {
    id: roomPage
    title: qsTr("Information Résident")
    
    background: Rectangle { 
        color: "#FFF8EE" // Couleur de fond claire
    }
    
    // Connexion au signal roomFound du chargeur de chambres
    Connections {
        target: residentRoomLoader
        function onRoomFound(nom, batiment, etage, chambre) {
            console.log("Signal roomFound reçu")
            resultDialog.nom = nom
            resultDialog.batiment = batiment
            resultDialog.etage = etage
            resultDialog.chambre = chambre
            resultDialog.open()
        }
    }
    
    // Le mode peut être passé lors de la navigation; défaut sécurisé 'enfant'
    property string appMode: "enfant"

    // Navigation Header
    header: ToolBar {
        id: toolbar
        Material.foreground: "white"
        Material.background: "#F57C00" // Orange accentColor
        height: 60 // Hauteur augmentée

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            ToolButton {
                contentItem: Text {
                    text: "←" // Emoji flèche gauche
                    font.pixelSize: 28
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    console.log("Retour depuis la page Information Résident");
                    // Utiliser la référence du StackView hôte pour un retour fiable
                    var view = StackView.view ? StackView.view : (typeof stackView !== 'undefined' ? stackView : null);
                    if (view) {
                        console.log("Avant pop, depth=", view.depth);
                        view.pop(); // pop d'une seule page
                        console.log("Après pop, depth=", view.depth);
                    } else {
                        console.log("Aucun StackView disponible pour pop()");
                    }
                }
                Layout.alignment: Qt.AlignLeft
            }

            Label {
                text: "Information Résident"
                font.pixelSize: 28 // Taille augmentée
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }

            // Bouton Modifier qui n'apparaît qu'en mode parent
            ToolButton {
                visible: (typeof root !== 'undefined' && root.appMode ? root.appMode : appMode) === "parent"
                contentItem: Text {
                    text: "✏️" // Emoji crayon pour modifier
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    console.log("Ouverture de l'éditeur de chambres");
                    editRoomsDialog.open();
                }
                Layout.alignment: Qt.AlignRight
            }
            
            Item {
                // Spacer
                Layout.preferredWidth: 16
            }
            
            Item {
                // Spacer
                Layout.preferredWidth: 16
            }
        }
    }
    
    // Contenu principal
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Rectangle {
            Layout.fillWidth: true
            height: 200
            color: "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8
                
                Label {
                    width: parent.width
                    text: "Entrez le nom du résident"
                    font.pixelSize: 48
                    horizontalAlignment: Text.AlignHCenter
                }
                
                TextField {
                    id: searchField
                    width: parent.width
                    height: 120
                    font.pixelSize: 44
                    placeholderText: ""
                    horizontalAlignment: Text.AlignHCenter
                    
                    background: Rectangle {
                        radius: 8
                        border.color: "#F57C00"
                        border.width: 2
                    }
                }
                
                Button {
                    width: parent.width
                    height: 120
                    text: "🔍 Rechercher"
                    font.pixelSize: 44
                    
                    Material.background: "#F57C00"
                    Material.foreground: "white"
                    
                    onClicked: {
                        if (searchField.text.trim() !== "") {
                            console.log("Recherche pour:", searchField.text)
                            if (!residentRoomLoader.searchRoom(searchField.text)) {
                                // Si aucun résident n'est trouvé
                                notFoundDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dialogue de résultat
    Dialog {
        id: resultDialog
        title: "Chambre trouvée"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 600)
        
        property string nom: ""
        property string batiment: ""
        property string etage: ""
        property string chambre: ""
        
        contentItem: Column {
            spacing: 40
            width: parent.width
            
            Label {
                width: parent.width
                text: resultDialog.nom
                font.pixelSize: 48
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            Label {
                width: parent.width
                text: "🏢 Bâtiment " + resultDialog.batiment
                font.pixelSize: 44
                horizontalAlignment: Text.AlignHCenter
            }
            
            Label {
                width: parent.width
                text: "🔢 Étage " + resultDialog.etage
                font.pixelSize: 44
                horizontalAlignment: Text.AlignHCenter
            }
            
            Label {
                width: parent.width
                text: "🚪 Chambre " + resultDialog.chambre
                font.pixelSize: 44
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Fermer"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: resultDialog.close()
                Material.background: "#757575"
                Material.foreground: "white"
                font.pixelSize: 32
            }
        }
    }
    
    // Dialogue "Résident non trouvé"
    Dialog {
        id: notFoundDialog
        title: "Résident non trouvé"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 400)
        
        contentItem: Label {
            text: "Aucun résident trouvé avec ce nom."
            font.pixelSize: 44
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        
        footer: DialogButtonBox {
            Button {
                text: "OK"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: notFoundDialog.close()
                Material.background: "#757575"
                Material.foreground: "white"
                font.pixelSize: 32
            }
        }
    }
    
    // Dialogue d'édition des chambres
    Dialog {
        id: editRoomsDialog
        title: "Modifier les chambres"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 600)
        height: Math.min(parent.height * 0.9, 700)
        
        // Fonction pour ouvrir le fichier CSV dans un éditeur externe
        function openCSVEditor() {
            // Utiliser le composant Python pour ouvrir le fichier CSV
            residentRoomLoader.openCSVEditor()
        }
        
        contentItem: Column {
            spacing: 20
            anchors.margins: 20
            
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Édition du fichier resident_rooms.csv"
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Le fichier resident_rooms.csv contient toutes les informations des chambres. Vous pouvez l'éditer directement pour ajouter, modifier ou supprimer des chambres."
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Format du fichier:\nnom,batiment,etage,chambre"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Exemple:\nDupont,A,2,201"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
                color: "#F57C00" // Orange accentColor
            }
            
            Button {
                text: "Ouvrir l'éditeur"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 60
                font.pixelSize: 20
                Material.background: "#F57C00" // Orange accentColor
                Material.foreground: "white"
                onClicked: {
                    editRoomsDialog.openCSVEditor()
                }
            }
            
            Button {
                text: "Actualiser les chambres"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 60
                font.pixelSize: 20
                Material.background: "#4CAF50" // Vert
                Material.foreground: "white"
                onClicked: {
                    // Recharger les chambres depuis le fichier CSV
                    residentRoomLoader.loadRooms()
                    console.log("Rechargement des chambres demandé")
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Fermer"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: editRoomsDialog.close()
                Material.background: "#757575" // Gris
                Material.foreground: "white"
            }
        }
    }
}
