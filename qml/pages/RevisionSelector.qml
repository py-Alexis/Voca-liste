import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import "../controls"
import "../controls/RevisionSelector"
import "../"
import "../pages"

Item {
    id: revisionSelector

    property int nbWord: -1

    QtObject{
        id: internal

        function createHistory(history){
            var paire = true
            for (const index in history){
                var newObject = Qt.createQmlObject(`import QtQuick 2.0; import "../controls/RevisionSelector"; import "../../qml"; HistoryLine{parentWidth: historyScrollView.width;pair: ${paire}; date: "${history[index][0]}";mode: "${history[index][6]}"; direction: "${history[index][7]}"; lv: "${history[index][1]}"; time: "${history[index][2]}"; score: "${history[index][3]}"; mistakes: "${history[index][4]}"; backgroundColorIsPair: medium_color; backgroundColorNotPair: light_color; textColor: light_text_color}`,historyColumn,"revisionSelector")
                paire = !paire
            }
        }
    }


    CustomTopDescriptionBtn {
        id: homeBtn

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: -1
        anchors.leftMargin: 39

        btnLogoColor: medium_text_color
        btnColorMouseOver: light_text_color
        btnColorClicked: accent_color
        btnIconSource: "../../images/home_icon.svg"

        onClicked: {
            stackViewDirection = false
            stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
            stackViewDirection = true
            currentList = ""
            backend.get_list_list()
        }
    }

    Rectangle{
        id: bg
        color: light_color
        anchors.fill: parent
        anchors.topMargin: 25

        Label {
            id: listName

            color: light_text_color

            anchors.top: parent.top
            font.pointSize: 17
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row{
            id: listInfo

            anchors.top: listName.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Label {
                id: listMode

                color: medium_text_color

                font.pointSize: 11
            }

            Label {
                color: medium_text_color

                text: "|"
                font.pointSize: 11
            }

            Label {
                id: listNbWord

                color: medium_text_color

                text: qsTr("Label")
                font.pointSize: 11
            }

            Label {
                color: medium_text_color

                text: "|"
                font.pointSize: 11
            }

            Label {
                id: listLv

                color: medium_text_color

                text: qsTr("Label")
                font.pointSize: 11
            }
        }

        Row{
            id: selection
            anchors.top: listInfo.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 50
            //spacing: 50

            Column{
                id: modeSelectorColumn

                spacing: 5
                Label{
                    id: modeSelectorLabel
                    text: "Mode de révision:"
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    color: light_text_color
                    font.pointSize: 9
                }

                TabBar{
                    id: modeSelector

                    background: Rectangle{
                        color: "#00000000" // couleur de la séparation
                    }

                    TabButton{
                        text: "QCM"
                        width: implicitWidth

                        checkable: if(nbWord < 4){false}else{true}
                        opacity: if(nbWord < 4){0.5}else{1}

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                            if(nbWord < 4){
                                popUp.popUpText = "la liste doit comporter au moins 4 mots pour utiliser ce mode"
                                showPopUp.running = true
                            }
                        }

                    }TabButton{
                        id: ecrireBtn
                        text: "Ecrire"
                        width: implicitWidth

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                            if(currentMode === "dictionnaire"){defaultDirection.checked = true}
                        }
                    }
                }
            }

            Item{height: 1; width: 50}

            Column{
                id: directionSelectorColumn

                spacing: 5
                Label{
                    id: directionSelectorLabel
                    text: "Sens de révision:"
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    color: light_text_color
                    font.pointSize: 9
                }

                TabBar{
                    id: directionSelector

                    background: Rectangle{
                        color: "#00000000" // couleur de la séparation
                    }

                    TabButton{
                        id: defaultDirection

                        text: if(currentMode === "langue"){"Traduction => Expression"}else{"Définition => Mot"}
                        width: implicitWidth

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {

                        }
                    }
                    TabButton{
                        text: if(currentMode === "langue"){"Expression => Traduction"}else{"Mot => Définition"}
                        width: implicitWidth

                        checkable: if(currentMode === "dictionnaire" && ecrireBtn.checked){false}else{true}
                        opacity: if(currentMode === "dictionnaire" && ecrireBtn.checked){0.5}else{1}

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                            if(currentMode === "dictionnaire" && ecrireBtn.checked){
                                popUp.popUpText = "ce mode n'est pas disponible pour les listes dictionnaires"
                                showPopUp.running = true
                            }
                        }
                    }
                    TabButton{
                        id: aleatoire
                        text: "Aléatoire"
                        width: implicitWidth

                        checkable: if(currentMode === "dictionnaire" && ecrireBtn.checked){false}else{true}
                        opacity: if(currentMode === "dictionnaire" && ecrireBtn.checked){0.5}else{1}

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                            if(currentMode === "dictionnaire" && ecrireBtn.checked){
                                popUp.popUpText = "ce mode n'est pas disponible pour les listes dictionnaires"
                                showPopUp.running = true
                            }
                        }
                    }
                }
            }

            Item{height: 1; width: 50}

            Column{
                id: nbWordSelectorColumn

                spacing: 5
                Label{
                    id: nbWordSelectorLabel
                    text: "nombre de mots:"
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    color: light_text_color
                    font.pointSize: 9
                }

                TabBar{
                    id: nbWordSelector

                    background: Rectangle{
                        color: "#00000000" // couleur de la séparation
                    }

                    TabButton{
                        id: allListBtn

                        text: "Toute la liste"
                        width: implicitWidth

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                        }

                    }TabButton{
                        id: lastTimeBtn
                        text: "Mêmes mots que la dernière fois"
                        width: implicitWidth

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                        }
                    }TabButton{
                        id: partOfListBtn
                        text: "Partie de la liste"
                        width: implicitWidth

                        contentItem: Text{
                            color: parent.checked ? light_text_color: medium_text_color
                            text: parent.text
                            font: parent.font
                        }

                        background: Rectangle{
                            color: parent.checked ? accent_color: medium_color
                            opacity: parent.down ? 0.75: 1
                            radius: 3
                        }

                        onClicked: {
                        }
                    }
                }
            }

            Item{height: 1; width: 5}

            Rectangle{
                id: nbWordSelectorContainer

                height: nbWordSelectorInput.height + 12
                width: 40

                color: medium_color
                opacity: if(partOfListBtn.checked){1}else{0.6}

                radius: 3
                anchors.top: parent.top
                anchors.topMargin: nbWordSelectorLabel.height + 5

                TextInput{
                    id: nbWordSelectorInput

                    text: "10"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5

                    color: light_text_color
                    opacity: if(partOfListBtn.checked){1}else{0.6}
                    readOnly: if(partOfListBtn.checked){false}else{true}

                    validator: IntValidator {bottom: 1; top: 9999}

                    maximumLength: 4
                    selectedTextColor: "#000000"
                    selectionColor: accent_color
                }
            }
        }

        Rectangle{
            id: historyContainer

            color: medium_color
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: selection.bottom
            anchors.bottom: bottomBtn.top
            anchors.rightMargin: 60
            anchors.leftMargin: 60
            anchors.bottomMargin: 40
            anchors.topMargin: 25

            radius: 5

            Label {
                id: noData

                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 25
                anchors.horizontalCenter: parent.horizontalCenter

                color: medium_text_color

                text: "NO DATA"

                opacity: 0.3
            }

            Rectangle{
                id: historyHeader

                height: 20
                color: "#00000000"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.rightMargin: 20
                anchors.leftMargin: 20


                Label{
                    id: dayLabelHistory
                    text: "Date"
                    color: medium_text_color

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    width: parent.width / 8


                }

                Label{
                    id: modeLabelHistory
                    text: "Mode"
                    color: medium_text_color

                    anchors.left: dayLabelHistory.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    width: parent.width / 8
                }

                Label{
                    id: directionLabelHistory
                    text: "Direction"
                    color: medium_text_color

                    anchors.left: modeLabelHistory.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    width: parent.width / 8
                }

                Label{
                    id: lvLabelHistory
                    text: "Niveau"
                    color: medium_text_color

                    anchors.left: directionLabelHistory.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    width: parent.width / 8
                }

                Label{
                    id: timeLabelHistory
                    text: "Durée"
                    color: medium_text_color

                    anchors.left: lvLabelHistory.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    width: parent.width / 8
                }

                Label{
                    id: scoreLabelHistory
                    text: "Score"
                    color: medium_text_color

                    anchors.left: timeLabelHistory.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0

                    width: parent.width / 8
                }

                Label{
                    id: mistakeLabelHistory
                    text: "Erreur"
                    color: medium_text_color

                    anchors.left: scoreLabelHistory.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 5
                    font.pointSize: 10
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                }

            }

            ScrollView {
                id: historyScrollView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: historyHeader.bottom
                anchors.bottom: parent.bottom
                clip: true

                anchors.topMargin: 10
                anchors.rightMargin: 20
                anchors.leftMargin: 20

                Column{
                    id: historyColumn
                    anchors.fill: parent

                }
            }
        }

        Row{
            id: bottomBtn

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 15


            SaveBtn{
                id: cancelBtn

                text: "Annuler"

                btnTextColor: light_text_color
                btnColor: medium_color

                onClicked: {
                    stackViewDirection = false
                    stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
                    stackViewDirection = true
                    currentList = ""
                    backend.get_list_list()
                }
            }
            SaveBtn{
                id: startRevisionBtn

                text: "Lancer la revision"


                btnColor: accent_color
                btnTextColor: light_text_color

                onClicked: {
                    var mode = "" // write or QCM
                    var direction = "" // default (definition => mot); opposite (mot => definition); random
                    var scope = "" // all; last; int
                    var ok = true

                    if(ecrireBtn.checked){
                        mode = "write"

                    }else{
                        mode = "QCM"
                    }

                    if(aleatoire.checked){
                        direction = "random"
                    }else if(defaultDirection.checked){
                        direction = "default"
                    }else{
                        direction = "opposite"
                    }

                    if(allListBtn.checked){
                        scope = "all"
                    }else if(lastTimeBtn.checked){
                        if(noData.visible){
                            popUp.popUpText = "Vous n'avez jamais révisé cette liste"
                            showPopUp.running = true
                            ok = false
                        }
                        else{
                            scope = "last"
                        }
                    }else{
                        if(nbWordSelectorInput.text === "0" || nbWordSelectorInput.text === "00" || nbWordSelectorInput.text === "000" || nbWordSelectorInput.text === "0000"){
                            popUp.popUpText = "Vous ne pouvez pas réviser 0 mot"
                            showPopUp.running = true
                            ok = false
                        }else if(parseInt(nbWordSelectorInput.text) < 4){
                            popUp.popUpText = "Vous devez réviser au moins 4"
                            showPopUp.running = true
                            ok = false
                        }else if(parseInt(nbWordSelectorInput.text) >= nbWord){
                            scope = "all"
                        }else{
                            scope = nbWordSelectorInput.text
                        }
                    }

                    if(ok){
                        stackView.replace(Qt.resolvedUrl("../pages/RevisionPage.qml"))
                        backend.start_revision(currentList, mode, direction, scope)
                    }
                }
            }
        }

        PopUp{
            id: popUp

            opacity: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter

            rectangleColor: darker_color
            textColor: light_text_color

            PropertyAnimation { id: showPopUp; target: popUp; property: "opacity"; to: 1; duration: 750; easing.type: Easing.InOutQuint; onFinished: waitPopUp.running = true}
            // not ideal but it's the only way I find to let the popUp a bit before it vanish
            PropertyAnimation { id: waitPopUp; target: popUp; property: "opacity"; to: 1; duration: 2000; easing.type: Easing.InOutQuint; onFinished: hidePopUp.running = true}
            PropertyAnimation { id: hidePopUp; target: popUp; property: "opacity"; to: 0; duration: 500; easing.type: Easing.InOutQuint}

        }
    }


    Connections{
        target: backend

        function onSendCloseAsk(){
            backend.close()
        }

        function onSendListInfo(data){ // data = [nbWord_, lv, history]

            listName.text = currentList
            listMode.text = `mode: ${currentMode}`

            nbWord = data[0]
            listNbWord.text = `${data[0]} mots`
            listLv.text = `${data[1]} %`

            if(nbWord < 4){
                ecrireBtn.checked = true
            }

            var history = data[2]
            if(history.length === 0){
                noData.visible = true
                historyHeader.visible = false
                historyContainer.color = medium_color
            }else{
                noData.visible = false
                historyHeader.visible = true
                historyContainer.color = "transparent"
                internal.createHistory(data[2])
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:700}
}
##^##*/
