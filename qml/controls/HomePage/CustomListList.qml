import QtQuick 2.15
import QtQuick.Controls 2.15


Button {
    id: listButton

    property string currentListName: "" // List currently selected
    property bool pairColor: false
    property string listName: "liste name"
    property string listMode: "None" // => dictionnaire  :  ou langue

    property color textColor: "#ffffff"
    property color mediumTextColor: "#5f6a82"
    property color btnColorIsPair: "#1c1d20"
    property color btnColorActive: "#00a1f1"
    property color backgroundColor: "#2C313C"

    property int reload: 0

    onReloadChanged: destroy()

    width: 340
    height: labelListName.height + 17
    visible: true
    anchors.left: parent.left
    anchors.leftMargin: 20


    QtObject{
        id: internal

        property var isActive: if(currentListName == listName){true}else{false}
    }



    Label{
        id: labelListName

        anchors.verticalCenter: parent.verticalCenter

        anchors.left: parent.left
        anchors.leftMargin: 10

        text: listName

        color: textColor

        width: (parent.width / 5) * 4
        font.pointSize: 9
        wrapMode: Text.Wrap


    }

    Label{
        id: labelListMode

        anchors.verticalCenter: parent.verticalCenter

        anchors.right: parent.right
        horizontalAlignment: Text.AlignRight
        anchors.rightMargin: 10

        text: listMode

        color: mediumTextColor

        width: parent.width / 5
        wrapMode: Label.Wrap


    }



    background: Rectangle{
        color: internal.isActive ? btnColorActive : pairColor ? backgroundColor: btnColorIsPair
        opacity: if(listButton.down){listButton.down ? 0.7 : 1}else{listButton.hovered ? 0.85 : 1}
        radius: 3

    }


}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.66}
}
##^##*/
