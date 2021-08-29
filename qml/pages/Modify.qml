import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import "../controls"
import "../controls/Modify"
import "../controls/HomePage"
import "../"

Item{
    id: modifyPage
    property int reload_: 0

    QtObject{
        id: internal

        function destroyTable(){
            reload_ = 1
            reload_ = 0
            createTable()

        }

        function createTable(){
            var object = Qt.createQmlObject(`import QtQuick 2.0; import "../controls/Modify"; CustomTable{id: customTable; anchors.fill: parent; reload: reload_}`, customTableContainer, "oui")
        }

    }



    Rectangle{
        id: rectangle
        anchors.fill: parent
        anchors.topMargin: 25

        color: light_color

        Rectangle {
            id: buttonBar
            height: 30
            color: medium_color
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 20
            anchors.leftMargin: 20
            anchors.topMargin: 20

            radius: 5

            CustomTextButton{
                id: resetLevelBtn
                anchors.left: parent.left
                rightPadding: 0
                anchors.rightMargin: 0
                textBtn: "Reinitialiser la progression |"

                btnTextColor: light_text_color
                btnTextColorDown: medium_text_color

                onClicked: {
                    internal.destroyTable()
                    backend.reset_lv(currentList, -2)
                }
            }

            CustomTextButton{
                id: renameBtn
                anchors.left: resetLevelBtn.right
                anchors.leftMargin: -10
                textBtn: "Renomer la liste |"

                btnTextColor: light_text_color
                btnTextColorDown: medium_text_color

                onClicked: {
                    currentListLabel.readOnly = false
                    currentListLabel.focus = true
                }
            }

            Rectangle{
                id: titleRectangle

                color: light_color
                height: parent.height
                radius: parent.radius
                anchors.horizontalCenter: parent.horizontalCenter
                width: currentListLabel.width + 75

                TextInput {
                    id: currentListLabel

                    text: ""

                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 15
                    anchors.horizontalCenter: parent.horizontalCenter

                    color: light_text_color

                    readOnly: true

                    selectByMouse: true
                    selectedTextColor: "#000000"
                    selectionColor: accent_color

                    onTextEdited: {
                        let pos = cursorPosition
                        let str = String(text)
                        // To Do check if name alerady exist

                        // check if there is any forbidden char
                        if(str.indexOf("|")>-1 || str.indexOf(".")>-1 || str.indexOf("<")>-1 || str.indexOf(">")>-1 || str.indexOf(":")>-1 || str.indexOf("*")>-1 || str.indexOf("/")>-1 || str.indexOf("\\")>-1 || str.indexOf('"')>-1 || str.indexOf('?')>-1){
                            var forbiddenChar =  ["|", ".", "<", ">", ":", "*", "/", "\\", '"', "?"]
                            for(const i in forbiddenChar){
                                text = text.replace(forbiddenChar[i], "")
                            }
                            cursorPosition = pos -1

                        }
                    }
                    onFocusChanged: {
                        if(! currentListLabel.activeFocus){
                            currentListLabel.readOnly = true
                        }
                    }

                    onAccepted: {
                        currentListLabel.readOnly = true
                    }

                }
            }

            CustomTextButton{
                id: newlineBtn
                anchors.right: parent.right
                anchors.rightMargin: 0
                textBtn: "| nouvelle ligne"

                btnTextColor: light_text_color
                btnTextColorDown: medium_text_color

                onClicked: {
                    internal.destroyTable()
                    backend.new_line(currentList)
                }
            }

            CustomTextButton{
                id: supplineBtn
                anchors.right: newlineBtn.left
                anchors.rightMargin: -10
                textBtn: "| supprimer ligne"

                btnTextColor: light_text_color
                btnTextColorDown: medium_text_color

                onClicked: {
                    internal.destroyTable()
                    backend.del_line(currentList, -2)

                    internal.destroyTable()
                    backend.get_words(currentList)
                }
            }


        }

        Rectangle{
            id: listDataModification
            color: "#00000000"

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: buttonBar.bottom
            anchors.bottom: tableHeader.top
            anchors.bottomMargin: 0
            anchors.rightMargin: 60
            anchors.leftMargin: 60
            anchors.topMargin: 15

            Label{
                id: labelMode

                text: "mode :"
                anchors.verticalCenter: parent.verticalCenter

                color: light_text_color
            }

            TabBar{
                id: modeSelector
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: labelMode.right
                anchors.leftMargin: 10


                background: Rectangle{
                    color: "#00000000" //medium_text_color // couleur de la séparation
                }

                TabButton{
                    text: "langue"
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
                        backend.change_mode(currentList, text)
                        currentMode = text
                    }
                }

                TabButton{
                    text: "dictionnaire"
                    width: implicitWidth
                    checked: if(currentMode === "dictionnaire"){true}else{false}

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
                        backend.change_mode(currentList, text)
                        currentMode = text
                    }
                }
            }

            Label{
                id: labelCategorie

                text: "catégorie :"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: modeSelector.right
                anchors.leftMargin: 40

                color: light_text_color
            }

            Rectangle{
                id: categorieSelectorContainer
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: labelCategorie.right
                anchors.leftMargin: 10

                height: categorieSelector.height + 12
                width: 150

                color: medium_color
                radius: 3

                TextInput{
                    id: categorieSelector

                    text: ""
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5

                    color: light_text_color

                    wrapMode: TextInput.Wrap
                    selectByMouse: true
                    selectedTextColor: "#000000"
                    selectionColor: accent_color

                    onTextEdited: backend.update_category(currentList, text)
                }
            }


        }

        Rectangle{
            id: tableHeader
            width: 0
            height: 30
            color: "#00000000"

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 130
            anchors.rightMargin: 20
            anchors.leftMargin: 20

            Row{
                id: row
                anchors.fill: parent
                Rectangle{
                    width: parent.width / 5
                    color: "#00000000"
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    Label{
                        text: if(currentMode === "langue"){"Expression"}else{"Mot"}
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 0
                        color: medium_text_color
                    }
                }
                Rectangle{
                    width: parent.width / 5
                    color: "#00000000"
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    Label{
                        text: if(currentMode === "langue"){"Traduction"}else{"Définition"}
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 0
                        color: medium_text_color
                    }
                }
                Rectangle{
                    width: (parent.width / 5)*2
                    color: "#00000000"
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    Label{
                        text: qsTr("Contexte")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 0
                        color: medium_text_color
                    }
                }
                Rectangle{
                    width: parent.width / 5
                    color: "#00000000"
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    Label{
                        text: qsTr("Niveau")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignRight
                        anchors.leftMargin: 0
                        anchors.rightMargin: 20
                        color: medium_text_color
                    }
                }
            }
        }

        Rectangle{
            id: customTableContainer
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: saveBtn.top
            anchors.bottomMargin: 10
            anchors.rightMargin: 20
            anchors.leftMargin: 20
            anchors.topMargin: 160

        }

        SaveBtn{
            id: saveBtn

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.rightMargin: 20

            btnTextColor: light_text_color
            btnColor: accent_color

            onClicked: {backend.check_list(currentList, currentListLabel.text)}

            MessageDialog{
                id: saveDialog

                text: ""
                detailedText: "les deux premières cases de chaques lignes doivent être remplies"
            }

        }

        SaveBtn{
            id: cancelBtn

            textBtn: "Annuler"

            anchors.right: saveBtn.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.rightMargin: 5

            btnTextColor: light_text_color
            btnColor: medium_color

            onClicked: {areYouSureDialog.open()}

            MessageDialog{
                id: areYouSureDialog

                title: "Etes vous sûr"
                text: "Etes vous sûr d'annuler; toutes les modifications seront perdu (cette action est irreversible)"
                detailedText: ""

                standardButtons: StandardButton.Yes | StandardButton.No

                icon: StandardIcon.Critical

                onYes:{
                    backend.get_backup()
                    stackViewDirection = false
                    stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
                    stackViewDirection = true
                    currentList = ""
                    currentMode = ""
                    backend.get_list_list()
                }

            }

            MessageDialog{
                id: areYouSureDialogClose

                title: "Etes vous sûr"
                text: "Etes vous sûr de quitter; toutes les modifications seront perdu (cette action est irreversible)"
                detailedText: ""

                standardButtons: StandardButton.Yes | StandardButton.No

                icon: StandardIcon.Critical
                onYes:{
                    backend.get_backup()
                    backend.close()
                }
            }
        }
    }

    Connections{

        target: backend

        function onSendCreateTable(categorie){
            if (currentListLabel.text === ""){
                currentListLabel.text = currentList
            }
            internal.destroyTable()
            categorieSelector.text = categorie
            backend.get_words(currentList)
        }

        function onSendNewFile(){
            console.log("-----------------------")
            if (currentListLabel.text === ""){
                currentListLabel.text = currentList
            }
        }

        function onCheckedList(message){
            if(message === "ok"){
                stackViewDirection = false
                stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
                stackViewDirection = true
                currentList = ""
            }else if(message === "le nom de la liste ne peut pas être vide" || message === "le nom de la liste existe déjà"){
                saveDialog.detailedText = ""
                saveDialog.text = message
                saveDialog.open()
            }else if(message === "deux mots/expressions sont identiques" || message === "deux définitions/traductions sont identiques"){
                saveDialog.detailedText = ""
                saveDialog.text = message
                saveDialog.open()
            }else{
                saveDialog.text = message
                saveDialog.detailedText = "les deux premières cases de chaques lignes doivent être remplies"
                saveDialog.open()
            }
        }

        function onSendCloseAsk(){
            areYouSureDialogClose.open()
        }

        function onSendNewLineOnEnter(){
            internal.destroyTable()
            backend.new_line(currentList)
        }
    }

}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:3;height:480;width:640}
}
##^##*/
