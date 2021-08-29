import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import "../controls"
import "../controls/HomePage"
import "../"
import "../pages"


Item {
    id: homePage
    property bool listIsSelected: false
    property bool modifierClicked: false
    property string destroy_: ""
    property int reloadList: 0
    property int reloadGraph: 0

    // is used to prevent the user from revising an empty list
    property int currentListNbWord: -1


    QtObject{
        id: internal

        function createCategorie(listlist){
            var paire = false

            if(listlist.hasOwnProperty('None')){
                // lists without categories are displayed at the top without the box with the category name
                for (const list in listlist["None"]){
                    var objectString_ = `import QtQuick 2.0; import QtQuick.Controls 2.15; import "../controls/HomePage"; import "../"; CustomListList{listName: "${listlist["None"][list][0]}"; listMode: "${listlist["None"][list][1]}" ;btnColorIsPair: medium_color; btnColorActive: accent_color; backgroundColor: light_color; textColor: light_text_color;currentListName: currentList;pairColor:${paire}; onClicked: internal.listClick(listName, listMode); reload: reloadList}`
                    paire = !paire

                    var newObject_ = Qt.createQmlObject(objectString_,settingsColumn,"home");
                }

                delete listlist["None"]
            }
            for (const categorie in listlist){

                // the two newitem are just there to adjust the vertical spacing (I don't know how to do otherwise in a column)
                var newItem = Qt.createQmlObject('import QtQuick 2.0;import "../controls/HomePage";CustomSpacing{itemHeight: 20;itemWidth: 1; reload: reloadList}',settingsColumn,"home");

                // Creation of the box with the category
                var objectString = `import QtQuick 2.0; import QtQuick.Controls 2.15; import "../controls/HomePage"; import "../"; CustomCategorie{text_: "${categorie}"; backgroundColor: medium_color;textColor: light_text_color; reload: reloadList}`
                var newObject = Qt.createQmlObject(objectString,settingsColumn,"home");

                var newItem_ = Qt.createQmlObject('import QtQuick 2.0;import "../controls/HomePage";CustomSpacing{itemHeight: 10;itemWidth: 1; reload: reloadList}',settingsColumn,"home");

                paire = false

                for (const list in listlist[categorie]){
                    var objectString_ = `import QtQuick 2.0; import QtQuick.Controls 2.15; import "../controls/HomePage"; import "../"; CustomListList{listName: "${listlist[categorie][list][0]}"; listMode: "${listlist[categorie][list][1]}" ;btnColorIsPair: medium_color; btnColorActive: accent_color; backgroundColor: light_color; textColor: light_text_color;currentListName: currentList;pairColor:${paire}; onClicked: internal.listClick(listName, listMode); reload: reloadList}`
                    paire = !paire

                    var newObject_ = Qt.createQmlObject(objectString_,settingsColumn,"home");


                }
            }
        }

        function listClick(clikedListName, clikedListMode){
            modifierClicked = false

            if (currentList === clikedListName){
                currentList = ""
                currentMode = ""
                listIsSelected = false
                destroy_ = ""
            }else{
                destroy_ = clikedListName
                currentList = clikedListName
                currentMode = clikedListMode
                listIsSelected = true
                backend.getWords(clikedListName)

            }
        }

        function createWordDisplay(wordList){

            var pair = true
            for (const word in wordList) {
                var obejct = Qt.createQmlObject(`import QtQuick 2.0;import QtQuick.Controls 2.15;import "../controls/HomePage";import "../";CustomWordDisplay {id: test ;parentWidth: listMotScrollView.width;destroy: destroy_; isPair : ${pair}; mot:"${wordList[word][0]}"; definition:"${wordList[word][1]}" ;context: "${wordList[word][2]}" ; niveau: ${wordList[word][3]} ; textColor: light_text_color ; btnColorIsPair: light_color; btnColorNotPair: medium_color; accentColor: accent_color}`,listMotColumn,"home");
                pair = !pair
            }
        }

        function reloadListList(){
            currentList = ""
            currentMode = ""
            listIsSelected = false
            reloadList = reloadList + 1
            reloadList = reloadList - 1
            backend.getListList()
        }

        function createGraph(){
            var objectString = "import QtQuick 2.15; import '../pages'; import '../controls/HomePage'; CustomGraph{reload: destroy_; z:100; visible: true; id: customGraph; anchors.fill: graph}"
            var newObject =  Qt.createQmlObject(objectString, graph,"graph")
        }
    }

    Rectangle{
        id: bg
        anchors.fill: parent
        anchors.topMargin: 25

        Rectangle {
            id: listList

            width: 375
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip: true
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0

            color: light_color

            Rectangle{
                id: listListHeader
                height: 30
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 20
                anchors.leftMargin: 20
                anchors.topMargin: 20
                radius: 5

                color: medium_color

                CustomTextButton{
                    id: nouveauBtn
                    textBtn: "nouveau |"

                    btnTextColor: light_text_color
                    btnTextColorDown: medium_text_color

                    onClicked: newFolder()//stackView.push(Qt.resolvedUrl("../pages/Modify.qml"))

                    Dialog {
                        id: newFolderDialog
                        title: "New folder"
                        height: 150
                        width: 300
                        standardButtons: StandardButton.Ok | StandardButton.Cancel

                        TextField {
                            id: newFolderInput
                            width: parent.width * 0.75
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            focus: true
                        }

                        onAccepted:{
                            console.log(newFolderInput.text)
                            backend.checkName(newFolderInput.text)
                            newFolderInput.text = ""
                        }
                        onRejected:{
                            newFolderInput.text = ""
                        }
                    }

                    MessageDialog{
                        id: messageDialog

                        title: "Problème avec la création de la liste"
                        text: ""
                        detailedText: ""

                        standardButtons: StandardButton.Ok

                        icon: StandardIcon.Warning


                    }
                    function newFolder() {
                        newFolderDialog.open()
                        newFolderInput.focus = true
                    }
                }
                CustomTextButton{
                    id: importBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    textBtn: "| import"

                    btnTextColor: light_text_color
                    btnTextColorDown: medium_text_color

                    onClicked: fileImport.open()

                    FileDialog{
                        id: fileImport
                        title: "Choisir le fichier à importer"
                        folder: shortcuts.desktop
                        selectMultiple: true
                        nameFilters: ["fichier de liste (*.json)"]
                        onAccepted: {
                            backend.importListe(fileImport.fileUrls)
                            internal.reloadListList()
                        }
                    }
                }
            }


            Rectangle {
                id: listListContainer
                color: "#00000000"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: listListHeader.bottom
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 20

                ScrollView {
                    id: settingsScrollView
                    anchors.fill: parent
                    clip: true

                    Column {
                        id: settingsColumn
                        anchors.fill: parent
                    }
                }
            }


        }

        Rectangle {
            id: detailList

            anchors.left: listList.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.leftMargin: 0
            anchors.bottomMargin: 0
            anchors.topMargin: 0

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

                visible: listIsSelected

                CustomTextButton{
                    id: reviseBtn
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    textBtn: "Réviser |"

                    btnTextColor: if(currentListNbWord === 0){medium_text_color}else{light_text_color}
                    btnTextColorDown: medium_text_color


                    onClicked: {
                        if (currentListNbWord !== 0){
                            stackView.replace(Qt.resolvedUrl("../pages/RevisionSelector.qml"))
                            backend.getListInfo(currentList)
                        }else{
                            popUp.popUpText = "cette liste est vide"
                            showPopUp.running = true
                        }
                    }
                }

                Rectangle{
                    color: light_color
                    height: parent.height
                    radius: parent.radius
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: currentListLabel.width + 75

                    Label {
                        id: currentListLabel
                        text: currentList
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 15
                        anchors.horizontalCenter: parent.horizontalCenter



                        color: light_text_color
                    }
                }


                CustomTextButton{
                    id: modifyBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    textBtn: "| modifier"

                    btnTextColor: light_text_color
                    btnTextColorDown: medium_text_color

                    onClicked: {modifierClicked = true; stackView.replace(Qt.resolvedUrl("../pages/Modify.qml")); backend.createTable(currentList)}
                }

                CustomTextButton{
                    id: supBtn
                    anchors.right: modifyBtn.left
                    anchors.rightMargin: -10
                    textBtn: "| supprimer"

                    btnTextColor: light_text_color
                    btnTextColorDown: medium_text_color

                    onClicked: areYouSureDialog.open()

                    MessageDialog{
                        id: areYouSureDialog

                        title: "Etes vous sûr"
                        text: "Etes vous sûr de supprimer cette liste (cette action est irreversible)"
                        detailedText: ""

                        standardButtons: StandardButton.Yes | StandardButton.No

                        icon: StandardIcon.Critical

                        onYes:{
                            backend.supprimer(currentList)
                            internal.reloadListList()

                        }
                    }
                }
            }

            Rectangle {
                id: graph
                height: parent.height / 2.5
                color: medium_color
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: buttonBar.bottom
                anchors.rightMargin: 20
                anchors.leftMargin: 20
                anchors.topMargin: 20

                radius: 5
                z: 2

                visible: listIsSelected
            }

            Rectangle{
                id: wordDisplayHeader

                height: labelMot.height+10

                color: light_color
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: graph.bottom
                anchors.topMargin: 20
                anchors.rightMargin: 20
                anchors.leftMargin: 20

                visible: listIsSelected

                Row{
                    id: row
                    anchors.fill: parent

                    Label{
                        id: labelMot
                        leftPadding: 5
                        width: (parent.width) / 5
                        color: medium_text_color

                        text: if(currentMode === "langue"){"Expression"}else{"Mot"}
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Label.Wrap
                    }

                    Label{
                        id: labelDef
                        leftPadding: 5
                        width: (parent.width) / 5
                        color: medium_text_color

                        text: if(currentMode === "langue"){"Traduction"}else{"Définition"}
                        anchors.verticalCenter: parent.verticalCenter

                        wrapMode: Label.Wrap
                    }
                    Label{
                        id: labelContext
                        leftPadding: 5
                        width: (2 * (parent.width)) / 5
                        color: medium_text_color

                        text: "Contexte"
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Label.Wrap
                    }
                    Label{
                        id: labelLv
                        rightPadding: 15
                        width: (parent.width) / 5
                        color: medium_text_color

                        text: "Niveau"
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        wrapMode: Label.Wrap
                    }
                }
            }

            Rectangle{
                id: wordDisplay

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: wordDisplayHeader.bottom
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.leftMargin: 20
                anchors.bottomMargin: 20
                anchors.topMargin: 0

                visible: listIsSelected
                color: "#00000000"

                ScrollView {
                    id: listMotScrollView
                    anchors.fill: parent
                    clip: true

                    Column{
                        id: listMotColumn
                        anchors.fill: parent
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

        // Custom Top Bar
        function onSendListList(listlist){
            internal.createCategorie(listlist)
        }

        // On List Click
        function onSendWordList(wordlist){
            if (modifierClicked === false){
                internal.createWordDisplay(wordlist)
                internal.createGraph()
                listIsSelected = true
                currentListNbWord = wordlist.length

            }
        }

        function onSendCheckedName(result){
            if(result === "charatere invalide"){
                messageDialog.open()
                messageDialog.text = "Le nom de la liste ne peux pas contenir de caratères spéciaux"
                messageDialog.detailedText = "Le nom de la liste ne peux pas contenir |, ., <, >, :, “, /, \\, ?, *"
            }else if(result === "existe déjà"){
                messageDialog.open()
                messageDialog.text = "Cette liste existe déjà"
                messageDialog.detailedText = ""
            }else if (result === "erreur"){
                console.log("erreur")
            }else {
                currentList = result
                currentMode = "langue"
                stackView.replace(Qt.resolvedUrl("../pages/Modify.qml"))
            }
        }

        // when the user changes the theme the graph needs to be refreshed
        function onSendTheme(){
            if(currentList !== ""){
                destroy_ = "qmlsdkfj"
                destroy_ = currentList
                backend.getWords(currentList)
            }
        }

        function onSendCloseAsk(){
            backend.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.9;height:480;width:980}
}
##^##*/

