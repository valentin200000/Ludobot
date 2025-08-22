import QtQuick
import QtQuick.Controls.Material 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "."

Page {
    id: activitiesPage
    title: qsTr("Activités & Loisirs")
    // Propriétés pour la gestion des jours et dates
    property string currentDay: getCurrentDay()
    property var days: ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
    property int currentDayIndex: getCurrentDayIndex()
    property var dates: getDatesOfWeek()
    
    // Icônes pour les types d'activités
    property var activityIcons: ({
        "gym": "🏃",        // 🏃 Course
        "mémoire": "🧠",    // 🧠 Cerveau
        "jardinage": "🌱",  // 🌱 Pousse
        "cuisine": "🍳",    // 🍳 Cuisine
        "musique": "🎵",    // 🎵 Note de musique
        "jeux": "🎲",       // 🎲 Dé
        "art": "🎨",        // 🎨 Palette
        "lecture": "📖",    // 📖 Livre
        "cinéma": "🍿",    // 🍿 Pop-corn
        "goûter": "🍰",    // 🍰 Gâteau
        "relaxation": "🧘",  // 🧘 Méditation
        "default": "⭐"         // ⭐ Étoile par défaut
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
                    console.log("Retour depuis la page Activités & Loisirs");
                    if (StackView.view) {
                        StackView.view.pop()
                    } else if (typeof stackView !== 'undefined' && stackView) {
                        stackView.pop()
                    }
                }
            }

            Label {
                text: "Activités & Loisirs"
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
                onClicked: editActivitiesDialog.open()
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
                activitiesLoader.loadActivities(currentDay)
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
                activitiesLoader.loadActivities(currentDay)
            }
        }
    }

    // Grille des heures
    ListView {
        id: timeGrid
        anchors {
            top: dayNavigation.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 16
        }
        model: ListModel {
            ListElement { debut: "09:00"; fin: "11:00"; type: "activity" }
            ListElement { debut: "11:00"; fin: "13:00"; type: "meal" }
            ListElement { debut: "13:00"; fin: "16:00"; type: "activity" }
            ListElement { debut: "18:00"; fin: "20:00"; type: "meal" }
        }
        spacing: 16
        clip: true

        delegate: Rectangle {
            width: timeGrid.width
            height: timeGrid.height / 4 - 12 // Divise l'espace disponible en 4 avec un peu d'espace pour le spacing
            radius: 10
            color: "white"
            border.color: model.type === "meal" ? "#FF9800" : Style.primaryColor
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Plage horaire
                Label {
                    text: model.debut + "\n" + model.fin
                    font.pixelSize: 28
                    font.bold: true
                    font.family: "Roboto"
                    color: model.type === "meal" ? "#FF9800" : Style.primaryColor
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                }

                // Activité ou Repas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: model.type === "meal" ? "#FFF3E0" : Style.primaryColorLight
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: model.type === "meal" ? "🍽️" : getActivityIcon(getActivityForTime(model.debut).activite)
                            font.pixelSize: 36
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: model.type === "meal" ? "Repas" : (getActivityForTime(model.debut) ? getActivityForTime(model.debut).activite : "Pas d'activité")
                                font.pixelSize: 28
                                font.family: "Roboto"
                                font.bold: true
                                color: model.type === "meal" ? "#FF9800" : Style.primaryColor
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.type === "meal" ? "Restaurant" : (getActivityForTime(model.debut) ? getActivityForTime(model.debut).lieu : "")
                                font.pixelSize: 24
                                font.family: "Roboto"
                                color: model.type === "meal" ? "#FF9800" : Style.primaryColor
                                visible: true
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    property var currentActivities: []

    function getActivityForTime(time) {
        // Convertir 09:00 en 9:00 pour la comparaison
        var searchTime = time.replace(/^0/, '')
        for (var i = 0; i < currentActivities.length; i++) {
            if (currentActivities[i].heure === searchTime) {
                return currentActivities[i]
            }
        }
        return null
    }

    // Connexion au signal activitiesLoaded du chargeur d'activités
    Connections {
        target: activitiesLoader
        function onActivitiesLoaded(activities) {
            console.log("Signal activitiesLoaded reçu avec " + activities.length + " activités")
            currentActivities = activities
            // Force le rafraîchissement de la vue
            timeGrid.model.clear()
            timeGrid.model.append({debut: "09:00", fin: "11:00", type: "activity"})
            timeGrid.model.append({debut: "11:00", fin: "13:00", type: "meal"})
            timeGrid.model.append({debut: "13:00", fin: "16:00", type: "activity"})
            timeGrid.model.append({debut: "18:00", fin: "20:00", type: "meal"})
            console.log("Vue rafraîchie")
        }
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
    
    function getActivityIcon(activity) {
        var activityLower = activity.toLowerCase()
        
        if (activityLower.includes("gym") || activityLower.includes("marche")) return activityIcons.gym
        if (activityLower.includes("mémoire")) return activityIcons.mémoire
        if (activityLower.includes("jardin")) return activityIcons.jardinage
        if (activityLower.includes("cuisine")) return activityIcons.cuisine
        if (activityLower.includes("musique") || activityLower.includes("chant")) return activityIcons.musique
        if (activityLower.includes("jeux") || activityLower.includes("loto")) return activityIcons.jeux
        if (activityLower.includes("art") || activityLower.includes("créatif")) return activityIcons.art
        if (activityLower.includes("lecture") || activityLower.includes("journal")) return activityIcons.lecture
        if (activityLower.includes("cinéma") || activityLower.includes("film")) return activityIcons.cinéma
        if (activityLower.includes("goûter")) return activityIcons.goûter
        if (activityLower.includes("relax") || activityLower.includes("sophrologie")) return activityIcons.relaxation
        
        return activityIcons.default
    }
    
    Component.onCompleted: {
        console.log("Démarrage de la page Activités")
        // Charger les activités depuis le fichier CSV via le ActivitiesLoader
        var activities = activitiesLoader.loadActivities(currentDay)
        console.log("Chargement des activités demandé")
    }
    
    // Dialogue d'édition des activités
    Dialog {
        id: editActivitiesDialog
        title: "Modifier les activités"
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
                text: "Édition du fichier activities.csv"
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Le fichier activities.csv contient toutes les activités affichées dans cette page. Vous pouvez l'éditer directement pour ajouter, modifier ou supprimer des activités."
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Format du fichier:\nJour,Heure,Activité,Lieu"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
            }
            
            Text {
                width: parent.width
                text: "Exemple:\nLundi,09:00,Gymnastique douce,Salle d'activités"
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
                    activitiesLoader.openCSVEditor()
                }
            }
            
            Button {
                text: "Actualiser les activités"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 60
                font.pixelSize: 20
                Material.background: "#4CAF50" // Vert
                Material.foreground: "white"
                onClicked: {
                    // Recharger les activités depuis le fichier CSV
                    activitiesLoader.loadActivities(currentDay)
                    console.log("Rechargement des activités demandé")
                }
            }
        }
        
        footer: DialogButtonBox {
            Button {
                text: "Fermer"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: editActivitiesDialog.close()
                Material.background: "#757575" // Gris
                Material.foreground: "white"
            }
        }
    }
}
