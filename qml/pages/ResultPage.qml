import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import "../controls"
import "../controls/Modify"
import "../"
import "../controls/Revision"

Item {
    id: renamePage

    property string destroy_: ""

    QtObject{
        id: internal

        function createGraph(){
            var objectString = "import QtQuick 2.15; import '../pages'; import '../controls/HomePage'; CustomGraph{reload: destroy_; z:100; visible: true; id: customGraph; anchors.fill: graph}"
            var newObject =  Qt.createQmlObject(objectString, graph,"graph")
        }
    }


    Item{
        id: title
        width: 200
        height: 60
        anchors.top: parent.top
        anchors.topMargin: 41
        anchors.horizontalCenter: parent.horizontalCenter

        Label{
            id: listName

            color: light_text_color
            font.pointSize: 17

            anchors.horizontalCenter: parent.horizontalCenter
        }
        Row{
            anchors.top: listName.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Label{
                id: listMode

                color: medium_text_color
                font.pointSize: 11
            }
            Label {
                color: medium_text_color

                text: "|"
                font.pointSize: 11
            }
            Label{
                id: revisionModeLabel

                color: medium_text_color
                font.pointSize: 11
            }
            Label {
                color: medium_text_color

                text: "|"
                font.pointSize: 11
            }

            Label{
                id: revisionDirectionLabel

                color: medium_text_color
                font.pointSize: 11
            }
        }
    }

    Item{
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.leftMargin: 20
        anchors.bottomMargin: 50
        anchors.topMargin: 20

        Column{
            id: column
            anchors.left: parent.left
            anchors.right: graph.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            clip: true

            Label{
                text: "Résultat"
                anchors.left: parent.left
                font.pointSize: 16
                anchors.leftMargin: 15
                color: medium_text_color
            }

            Item{
                height: 5
                width: 5
            }
            Label{
                id: resultLabel
                text: "35 / 37"
                anchors.left: parent.left
                font.pointSize: 30
                anchors.leftMargin: 15
                color: accent_color
            }

            Item{
                height: 40
                width: 5
            }
            Label{
                text: "Temps"
                anchors.left: parent.left
                font.pointSize: 16
                anchors.leftMargin: 15
                color: medium_text_color
            }

            Item{
                height: 5
                width: 5
            }
            Label{
                id: timeLabel
                text: "00:05:35"
                anchors.left: parent.left
                font.pointSize: 30
                anchors.leftMargin: 15
                color: accent_color
            }

            Item{
                height: 40
                width: 5
            }
            Label{
                text: "Niveau de la liste"
                anchors.left: parent.left
                font.pointSize: 16
                anchors.leftMargin: 15
                color: medium_text_color
            }

            Item{
                height: 5
                width: 5
            }
            Label{
                id: percentageLabel
                text: "25%"
                anchors.left: parent.left
                font.pointSize: 30
                anchors.leftMargin: 15
                color: accent_color
            }

            Item{
                height: 40
                width: 5
            }
            Label{
                text: "Erreur"
                anchors.left: parent.left
                font.pointSize: 16
                anchors.leftMargin: 15
                color: medium_text_color
            }

            Item{
                height: 5
                width: 5
            }
            Label{
                id: mistakeLabel

                text: ""
                color: if(text === "Aucune erreur"){light_text_color}else{accent_color}

                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.Wrap
                anchors.rightMargin: 15
                font.pointSize: 12
                anchors.leftMargin: 15
            }
        }

        Rectangle{
            id: graph
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.leftMargin: 250
            anchors.rightMargin: 0
            radius: 5

            color: medium_color
        }
    }

    Row{
        id: bottomBtn
        anchors.right: content.right
        anchors.top: content.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.rightMargin: 5
        anchors.topMargin: 0
        spacing: 5

        SaveBtn{
            id: cancelBtn

            text: "Page d'accueil"
            anchors.verticalCenter: parent.verticalCenter

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

            text: "Relancer"
            anchors.verticalCenter: parent.verticalCenter


            btnColor: accent_color
            btnTextColor: light_text_color

            onClicked: {
                stackView.replace(Qt.resolvedUrl("../pages/RevisionSelector.qml"))
                backend.getListInfo(currentList)
            }
        }
    }
    Connections{
        target: backend

        function onIntializeResult(info){
            //[revision_mode, revision_direction, result, percentage, time_spend, mistake]
            internal.createGraph()
            listName.text = currentList
            listMode.text = currentMode

            revisionModeLabel.text = info[0]
            revisionDirectionLabel.text = info[1]
            resultLabel.text = info[2]
            percentageLabel.text = info[3]
            timeLabel.text = info[4]
            if(info[5] !== ""){
                mistakeLabel.text = info[5]
            }else{
                mistakeLabel.text = "Aucune erreur"
            }


        }

        function onSendCloseAsk(){
            backend.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.66;height:1000;width:1000}
}
##^##*/
