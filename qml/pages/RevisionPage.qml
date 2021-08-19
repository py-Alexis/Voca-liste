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
    id: revisionPage

    property int index: 1
    property int nbWord: -1

    property string revisionMode: ""
    property string revisionDirection: ""
    property string currentDirection: "" // to know the direction in random direction mode

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

        onClicked: {areYouSureDialogHome.open()}
    }

    Rectangle{
        id: bg
        anchors.fill: parent
        anchors.topMargin: 25
        color: light_color

        Rectangle{
            id: title
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 16

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

        Label{
            id: indexIndicator

            text: `${index} / ${nbWord}`
            anchors.right: parent.right
            anchors.top: parent.top
            font.pointSize: 11
            anchors.rightMargin: 15
            anchors.topMargin: 20
            color: light_text_color
        }

        StackView{
            id: stackViewRevision
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 100
            anchors.bottomMargin: 25
            anchors.rightMargin: 150
            anchors.leftMargin: 150

            replaceEnter: Transition {
                XAnimator {
                    from: (stackView.mirrored ? -1 : 1) * stackView.width
                    to: 0
                    duration: 850
                    easing.type: Easing.InOutQuint
                }
            }

            replaceExit: Transition {
                XAnimator {
                    from: 0
                    to: (stackView.mirrored ? -1 : 1) * -stackView.width
                    duration: 850
                    easing.type: Easing.InOutQuint
                }
            }
        }// end StackView

        MessageDialog{
            id: areYouSureDialogClose

            title: "Etes vous sûr"
            text: "Etes vous sûr de quitter; la progression ne sera pas enregistrer (cette action est irreversible)"
            detailedText: ""

            standardButtons: StandardButton.Yes | StandardButton.No

            icon: StandardIcon.Critical

            onYes:{backend.close()}

        }

        MessageDialog{
            id: areYouSureDialogHome

            title: "Etes vous sûr"
            text: "Etes vous sûr de quitter; la progression ne sera pas enregistrer (cette action est irreversible)"
            detailedText: ""

            standardButtons: StandardButton.Yes | StandardButton.No

            icon: StandardIcon.Critical

            onYes: {
                stackView.replace(Qt.resolvedUrl("../pages/HomePage.qml"))
                currentList = ""
                currentMode = ""
                backend.getListList()
            }

        }
    }

    Connections{
        target: backend

        function onInitializeRevision(info){ // For some reason when the signal is define as Signal(str, str, int) it crash sometime so I put everything in a list
            listName.text = currentList
            listMode.text = currentMode

            revisionModeLabel.text = info[0]
            revisionMode = info[0]
            revisionDirectionLabel.text = info[1] // To Do : change text to mot => definition...
            revisionDirection = info[1]

            nbWord = info[2]


            if (revisionMode === "QCM"){
                stackViewRevision.replace(Qt.resolvedUrl("../pages/Revision/Qcm.qml"))
            }else if(revisionMode === "write"){
                stackViewRevision.replace(Qt.resolvedUrl("../pages/Revision/Write.qml"))
            }
        }

        function onSendCloseAsk(){
            areYouSureDialogClose.open()
        }

        function onSend_call_next_word(){
            index += 1

            if(revisionMode == "QCM"){
                stackViewRevision.replace(Qt.resolvedUrl("../pages/Revision/Qcm.qml"))
            }else if(revisionMode === "write"){
                stackViewRevision.replace(Qt.resolvedUrl("../pages/Revision/Write.qml"))
            }
            backend.next_word(revisionMode, revisionDirection, index)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
