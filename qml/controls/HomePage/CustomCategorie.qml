import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property string text_: "Categorie"
    property color backgroundColor: "#282C34"
    property color textColor: "#ffffff"

    property int reload: 0

    onReloadChanged: destroy()

    id: settingsInterfaceGraphique
    color: backgroundColor
    width: 40
    height: settingsGraphiqueLabel.height + 20

    Rectangle{
        width: settingsGraphiqueLabel.width + 20

        radius: 5
        color: parent.color
        height: parent.height
    }

    Label {
        id: settingsGraphiqueLabel
        text: text_
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pointSize: 10
        color: textColor
    }
}
