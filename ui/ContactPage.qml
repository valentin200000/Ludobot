import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import "."

Page {
    id: contactPage
    title: qsTr("Contacts")
    
    // Utilise le mode global de l'application défini dans main.qml
    
    background: Rectangle { 
        color: "#FFF8EE" // Couleur de fond claire
    }

    // Modèle pour les contacts
    ListModel {
        id: contactModel
    }
    
    // Connexion au signal contactsLoaded du chargeur de contacts
    Connections {
        target: contactLoader
        function onContactsLoaded(contacts) {
            console.log("Signal contactsLoaded reçu avec " + contacts.length + " contacts")
            // Vider d'abord le modèle existant
            contactModel.clear()
            
            // Ajouter chaque contact au modèle
            for (var i = 0; i < contacts.length; i++) {
                contactModel.append(contacts[i])
            }
            
            console.log("Total des contacts chargés: " + contactModel.count)
        }
    }
    
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
                    console.log("Retour depuis la page Contact");
                    stackView.pop();
                }
                Layout.alignment: Qt.AlignLeft
            }

            Label {
                text: "Contacts"
                font.pixelSize: 28 // Taille augmentée
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }
            
            // Bouton Modifier qui n'apparaît qu'en mode parent
            ToolButton {
                visible: appMode === "parent"
                contentItem: Text {
                    text: "✏️" // Emoji crayon pour modifier
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    console.log("Ouverture de l'éditeur de contacts");
                    editContactsDialog.open();
                }
                Layout.alignment: Qt.AlignRight
            }
            
            Item {
                // Spacer
                Layout.preferredWidth: 16
            }
        }
    }
    
    // Chargement des contacts au démarrage
    Component.onCompleted: {
        console.log("Démarrage de la page Contact")
        // Charger les contacts depuis le fichier CSV via le ContactLoader
        var contacts = contactLoader.loadContacts()
        console.log("Chargement des contacts demandé")
        
        // Si aucun contact n'est chargé, charger manuellement
        if (contactModel.count === 0) {
            chargerContactsManuellement()
        }
    }
    
    // Fonction pour charger manuellement les contacts en cas d'échec
    function chargerContactsManuellement() {
        console.log("Chargement manuel des contacts");
        
        // Contacts d'urgence
        contactModel.append({"service": "Urgence", "profession": "pompiers", "nom": "Centre de secours", "telephone": "18"});
        contactModel.append({"service": "Urgence", "profession": "SAMU", "nom": "Service d'aide médicale urgente", "telephone": "15"});
        contactModel.append({"service": "Urgence", "profession": "Police", "nom": "Commissariat", "telephone": "17"});
        contactModel.append({"service": "Urgence", "profession": "Appel d'urgence européen", "nom": "Centre d'appel", "telephone": "112"});
        
        // Contacts de santé
        contactModel.append({"service": "Santé", "profession": "Médecin", "nom": "Dr. Martin", "telephone": "01 23 45 67 89"});
        contactModel.append({"service": "Santé", "profession": "Infirmière", "nom": "Mme. Dubois", "telephone": "01 23 45 67 90"});
        contactModel.append({"service": "Santé", "profession": "Pharmacie", "nom": "Pharmacie Centrale", "telephone": "01 23 45 67 91"});
        contactModel.append({"service": "Santé", "profession": "Dentiste", "nom": "Dr. Petit", "telephone": "01 23 45 67 92"});
        
        // Contacts d'établissement
        contactModel.append({"service": "Établissement", "profession": "Directeur", "nom": "M. Leroy", "telephone": "01 23 45 67 93"});
        contactModel.append({"service": "Établissement", "profession": "Secrétariat", "nom": "Mme. Bernard", "telephone": "01 23 45 67 94"});
        contactModel.append({"service": "Établissement", "profession": "Maintenance", "nom": "M. Thomas", "telephone": "01 23 45 67 95"});
        contactModel.append({"service": "Établissement", "profession": "Cuisine", "nom": "M. Richard", "telephone": "01 23 45 67 96"});
        
        // Contacts de services
        contactModel.append({"service": "Services", "profession": "Coiffeur", "nom": "Salon Élégance", "telephone": "01 23 45 67 97"});
        contactModel.append({"service": "Services", "profession": "Pédicure", "nom": "Mme. Robert", "telephone": "01 23 45 67 98"});
        contactModel.append({"service": "Services", "profession": "Kinésithérapeute", "nom": "M. Durand", "telephone": "01 23 45 67 99"});
        contactModel.append({"service": "Services", "profession": "Psychologue", "nom": "Dr. Moreau", "telephone": "01 23 45 68 00"});
        
        console.log("Total des contacts chargés manuellement: " + contactModel.count);
    }
    
    // Contenu principal - Tableau de contacts
    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        
        Column {
            width: parent.width
            spacing: 16
            
            // En-tête du tableau
            Rectangle {
                width: parent.width
                height: 70 // Hauteur augmentée
                color: "#F57C00" // Orange accentColor
                radius: 8
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    Text {
                        width: parent.width * 0.25
                        height: parent.height
                        text: "Service"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 22 // Taille augmentée
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        width: parent.width * 0.25
                        height: parent.height
                        text: "Profession"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 22 // Taille augmentée
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        width: parent.width * 0.25
                        height: parent.height
                        text: "Nom"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 22 // Taille augmentée
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        width: parent.width * 0.25
                        height: parent.height
                        text: "Téléphone"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 22 // Taille augmentée
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
            
            // Liste des contacts
            ListView {
                id: contactListView
                width: parent.width
                height: contentHeight
                model: contactModel
                interactive: false
                spacing: 8
                
                delegate: Rectangle {
                    width: contactListView.width
                    height: 90 // Hauteur augmentée
                    color: index % 2 === 0 ? "#f5f5f5" : "white"
                    radius: 4
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        
                        Text {
                            width: parent.width * 0.25
                            height: parent.height
                            text: service
                            color: "#1a1a1a" // Couleur de texte primaire
                            font.pixelSize: 20 // Taille augmentée
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                        
                        Text {
                            width: parent.width * 0.25
                            height: parent.height
                            text: profession
                            color: "#1a1a1a" // Couleur de texte primaire
                            font.pixelSize: 20 // Taille augmentée
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                        
                        Text {
                            width: parent.width * 0.25
                            height: parent.height
                            text: nom
                            color: "#1a1a1a" // Couleur de texte primaire
                            font.pixelSize: 20 // Taille augmentée
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                        
                        Rectangle {
                            width: parent.width * 0.25
                            height: parent.height
                            color: "transparent"
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Text {
                                    text: "📞" // Emoji téléphone
                                    font.pixelSize: 24 // Taille augmentée
                                    color: "#F57C00" // Orange accentColor
                                }
                                
                                Text {
                                    text: telephone
                                    color: "#F57C00" // Orange accentColor
                                    font.pixelSize: 22 // Taille augmentée
                                    font.bold: true
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Appel au numéro: " + telephone);
                                    callDialog.contactName = nom;
                                    callDialog.contactPhone = telephone;
                                    callDialog.open();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dialogue d'appel téléphonique
    Dialog {
        id: callDialog
        title: "Appel téléphonique"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400)
        
        property string contactName: ""
        property string contactPhone: ""
        
        contentItem: Column {
            spacing: 20
            anchors.margins: 20
            
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Appel à " + callDialog.contactName
                font.pixelSize: 22 // Taille augmentée
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "📞 " + callDialog.contactPhone
                font.pixelSize: 28 // Taille augmentée
                font.bold: true
                color: "#F57C00" // Orange accentColor
            }
            
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Simulation d'appel"
                font.pixelSize: 18 // Taille augmentée
                color: "gray"
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Raccrocher"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: callDialog.close()
                Material.background: "red"
                Material.foreground: "white"
            }
        }
    }
    
    // Dialogue d'édition des contacts
    Dialog {
        id: editContactsDialog
        title: "Modifier les contacts"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 600)
        height: Math.min(parent.height * 0.9, 700)
        
        // Fonction pour ouvrir le fichier CSV dans un éditeur externe
        function openCSVEditor() {
            // Utiliser le composant Python pour ouvrir le fichier CSV
            contactLoader.openCSVEditor()
        }
        
        contentItem: Column {
            spacing: 20
            anchors.margins: 20
            
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Édition du fichier contacts.csv"
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Le fichier contacts.csv contient tous les contacts affichés dans cette page. Vous pouvez l'éditer directement pour ajouter, modifier ou supprimer des contacts."
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Format du fichier:\nService,Profession,Nom,Telephone"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Exemple:\nUrgence,pompiers,Centre de secours,18"
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
                    editContactsDialog.openCSVEditor()
                }
            }
            
            Button {
                text: "Actualiser les contacts"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 60
                font.pixelSize: 20
                Material.background: "#4CAF50" // Vert
                Material.foreground: "white"
                onClicked: {
                    // Recharger les contacts depuis le fichier CSV
                    contactLoader.loadContacts()
                    console.log("Rechargement des contacts demandé")
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Fermer"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: editContactsDialog.close()
                Material.background: "#757575" // Gris
                Material.foreground: "white"
            }
        }
    }
}
