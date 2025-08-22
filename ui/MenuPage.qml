import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: menuPage
    title: qsTr("Menu de la semaine")
    // Propriétés pour la gestion des jours et dates
    property string currentDay: getCurrentDay()
    property var days: ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
    property int currentDayIndex: getCurrentDayIndex()
    property var dates: getDatesOfWeek()
    
    // Icônes pour les types de repas
    property var mealIcons: ({
        "petit-déjeuner": "🥐",    // Croissant
        "déjeuner": "🍽️",         // Assiette
        "goûter": "🧁",           // Cupcake
        "dîner": "🍲",            // Pot de nourriture
        "entrée": "🥗",           // Salade
        "plat": "🍖",             // Viande
        "dessert": "🍰",          // Gâteau
        "default": "🍴"           // Couverts par défaut
    })
    // appMode est passé par le parent via stackView.push; défaut sécurisé: "enfant"
    property string appMode: "enfant"
    
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
                onClicked: {
                    console.log("Retour depuis la page Menu");
                    if (StackView.view) {
                        StackView.view.pop()
                    } else if (typeof stackView !== 'undefined' && stackView) {
                        stackView.pop()
                    }
                }
            }

            Label {
                text: "Menu de la semaine"
                font.pixelSize: 24
                font.family: "Roboto"
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "white"
            }

            ToolButton {
                visible: (typeof root !== 'undefined' && root.appMode ? root.appMode : appMode) === "parent"
                contentItem: Text {
                    text: "✎" // Emoji crayon pour modifier
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: editMenuDialog.open()
            }
        }
    }

    // Navigation des jours
    RowLayout {
        id: dayNavigation
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 16
        }
        height: 60

        ToolButton {
            text: "←"
            font.pixelSize: 32
            onClicked: {
                currentDayIndex = (currentDayIndex - 1 + days.length) % days.length
                currentDay = days[currentDayIndex]
                // Charger le menu du jour sélectionné
                loadMenuForDay(currentDay)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Label {
                text: currentDay
                font.pixelSize: 32
                font.bold: true
                font.family: "Roboto"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Style.primaryColor
            }
            
            Label {
                text: formatDate(dates[currentDayIndex])
                font.pixelSize: 24
                font.family: "Roboto"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Style.accentColor
            }
        }

        ToolButton {
            text: "→"
            font.pixelSize: 32
            onClicked: {
                currentDayIndex = (currentDayIndex + 1) % days.length
                currentDay = days[currentDayIndex]
                // Charger le menu du jour sélectionné
                loadMenuForDay(currentDay)
            }
        }
    }

    // Grille des repas
    ListView {
        id: mealGrid
        anchors {
            top: dayNavigation.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 16
        }
        model: ListModel {
            ListElement { heure: "08:00"; type: "petit-déjeuner"; nom: "Petit-déjeuner" }
            ListElement { heure: "12:00"; type: "déjeuner"; nom: "Déjeuner" }
            ListElement { heure: "16:00"; type: "goûter"; nom: "Goûter" }
            ListElement { heure: "19:00"; type: "dîner"; nom: "Dîner" }
        }
        spacing: 16
        clip: true

        delegate: Rectangle {
            width: mealGrid.width
            height: mealGrid.height / 4 - 12 // Divise l'espace disponible en 4 avec un peu d'espace pour le spacing
            radius: 10
            color: "white"
            border.color: "#FF9800"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Heure du repas
                Label {
                    text: model.heure
                    font.pixelSize: 28
                    font.bold: true
                    font.family: "Roboto"
                    color: "#FF9800"
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                }

                // Détails du repas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#FFF3E0"
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: getMealIcon(model.type)
                            font.pixelSize: 36
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: model.nom
                                font.pixelSize: 28
                                font.family: "Roboto"
                                font.bold: true
                                color: "#FF9800"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: getMenuForTime(model.heure) || "Menu non défini"
                                font.pixelSize: 24
                                font.family: "Roboto"
                                color: "#FF9800"
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }

    property var currentMenus: []

    function getMenuForTime(time) {
        // Rechercher le menu correspondant à l'heure
        for (var i = 0; i < currentMenus.length; i++) {
            if (currentMenus[i].heure === time) {
                return currentMenus[i].plat
            }
        }
        return "Menu non disponible"
    }

    // Connexion au signal menusLoaded du chargeur de menus
    Connections {
        target: menuLoader
        function onMenusLoaded(menus) {
            console.log("Signal menusLoaded reçu avec " + menus.length + " menus")
            currentMenus = menus
            // Force le rafraîchissement de la vue
            mealGrid.model.clear()
            mealGrid.model.append({heure: "08:00", type: "petit-déjeuner", nom: "Petit-déjeuner"})
            mealGrid.model.append({heure: "12:00", type: "déjeuner", nom: "Déjeuner"})
            mealGrid.model.append({heure: "16:00", type: "goûter", nom: "Goûter"})
            mealGrid.model.append({heure: "19:00", type: "dîner", nom: "Dîner"})
            console.log("Vue des menus rafraîchie")
        }
    }

    function loadMenuForDay(day) {
        console.log("Chargement du menu pour " + day)
        // Charger les menus depuis le fichier CSV via le MenuLoader
        var menus = menuLoader.loadMenus(day)
        console.log("Chargement des menus demandé")
    }

    // Fonctions utilitaires pour la gestion des dates
    function getCurrentDay() {
        var days = ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
        var today = new Date()
        return days[today.getDay()]
    }
    
    function getCurrentDayIndex() {
        var currentDay = getCurrentDay()
        return days.indexOf(currentDay)
    }
    
    function getDatesOfWeek() {
        var dates = []
        var today = new Date()
        var dayOfWeek = today.getDay() // 0 = Dimanche
        
        // Ajuster pour que Lundi soit 0
        dayOfWeek = dayOfWeek === 0 ? 6 : dayOfWeek - 1
        
        // Revenir au début de la semaine (Lundi)
        var monday = new Date(today)
        monday.setDate(today.getDate() - dayOfWeek)
        
        // Générer les dates pour chaque jour
        for (var i = 0; i < 7; i++) {
            var date = new Date(monday)
            date.setDate(monday.getDate() + i)
            dates.push(date)
        }
        
        return dates
    }
    
    function formatDate(date) {
        var jours = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
        var mois = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
        
        var jour = jours[date.getDay()]
        var jourNum = date.getDate()
        var moisStr = mois[date.getMonth()]
        var annee = date.getFullYear()
        
        return jour + ' ' + jourNum + ' ' + moisStr + ' ' + annee
    }
    
    function getMealIcon(mealType) {
        return mealIcons[mealType] || mealIcons.default
    }
    
    Component.onCompleted: {
        console.log("Démarrage de la page Menu")
        // Charger le menu du jour actuel
        loadMenuForDay(currentDay)
    }
    
    // Dialogue d'édition du menu
    Dialog {
        id: editMenuDialog
        title: "Modifier le menu"
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 600)
        height: Math.min(parent.height * 0.9, 700)
        
        contentItem: Column {
            spacing: 20
            anchors.margins: 20
            
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Édition du fichier menu.csv"
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Le fichier menu.csv contient tous les menus affichés dans cette page. Vous pouvez l'éditer directement pour ajouter, modifier ou supprimer des plats."
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Format du fichier:\nJour,Heure,Type,Plat"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Exemple:\nLundi,12:00,déjeuner,Salade verte, poulet rôti, légumes"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
                color: Style.accentColor
            }
            
            Button {
                text: "Ouvrir l'éditeur"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 60
                font.pixelSize: 20
                Material.background: Style.accentColor
                Material.foreground: "white"
                onClicked: {
                    menuLoader.openCSVEditor()
                }
            }
            
            Button {
                text: "Actualiser le menu"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 60
                font.pixelSize: 20
                Material.background: "#4CAF50" // Vert
                Material.foreground: "white"
                onClicked: {
                    // Recharger le menu depuis le fichier CSV
                    loadMenuForDay(currentDay)
                    console.log("Rechargement du menu demandé")
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Fermer"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: editMenuDialog.close()
                Material.background: "#757575" // Gris
                Material.foreground: "white"
            }
        }
    }
}
