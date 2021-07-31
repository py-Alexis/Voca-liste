import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import "../controls"
import "../controls/Modify"
import "../"
import "../pages"

Item {
    id: revisionSelector

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
            stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
            currentList = ""
            backend.getListList()
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
            spacing: 50

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

                        visible: if(currentMode === "dictionnaire" && ecrireBtn.checked){false}else{true}

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
                        id: aleatoire
                        text: "Aléatoire"
                        width: implicitWidth

                        visible: if(currentMode === "dictionnaire" && ecrireBtn.checked){false}else{true}

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

        }

        Rectangle{
            id: history

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
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 25
                anchors.horizontalCenter: parent.horizontalCenter

                color: medium_text_color

                text: "NO DATA"

                opacity: 0.3
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
                    stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
                    currentList = ""
                    backend.getListList()
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

                    stackView.replace(Qt.resolvedUrl("../pages/RevisionPage.qml"))
                    backend.startRevision(currentList, currentMode, mode, direction)
                }
            }
        }
    }


    Connections{
        target: backend

        function onSendCloseAsk(){
            backend.close()
        }

        function onSendListInfo(nbWord, lv){
            listName.text = currentList
            listMode.text = `mode: ${currentMode}`

            listNbWord.text = `${nbWord} mots`
            listLv.text = `${lv} %`
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
