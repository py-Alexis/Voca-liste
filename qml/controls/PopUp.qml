import QtQuick 2.0
import QtGraphicalEffects 1.15

Rectangle{
    property string popUpText: ""

    property color rectangleColor: "#1C1D20"
    property color textColor: "#ffffff"

    id: popUpContainer
    color: "transparent"
    height: popUpMessage.height + 13
    width: popUpMessage.width + 20

    Rectangle{
        id: popUp
        color: rectangleColor
        anchors.fill: parent
        radius: 5

        Text{
            id: popUpMessage
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            font.pointSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: textColor
            text: popUpText

            anchors.verticalCenter: parent.verticalCenter

        }
    }

    DropShadow{
            id: dropShadow
            anchors.fill: popUp
            horizontalOffset: 2
            verticalOffset: 2
            radius: 8
            samples: 17
            color: "#000000"//"#80000000"
            source: popUp
            z:-1
            visible: true

        }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.66}
}
##^##*/
