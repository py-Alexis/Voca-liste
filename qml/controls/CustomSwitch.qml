import QtQuick 2.15
import QtQuick.Controls 2.15

Switch {
    property real size: 1 // Multiplicateur de la taille
    property int textPadding: 0
    property color textColor: "#5f6a82"
    property color backgroundChecked: "#00a1f1"
    property color backgroundUnChecked: "#2C313C"
    property color circleDown: "#282C34"
    property color circleChecked: "#2C313C"
    property color circleUnChecked: "#00a1f1"


    id: customSwitch
    text: qsTr("custom Switch")


    indicator: Rectangle {
            implicitWidth: 48 * parent.size
            implicitHeight: 26 * parent.size
            x: customSwitch.leftPadding
            y: parent.height / 2 - height / 2
            radius: 13 * parent.size
            color: customSwitch.checked ? backgroundChecked : backgroundUnChecked  //fond du bouton
            border.color: customSwitch.checked ? backgroundChecked : backgroundUnChecked // bordure du bouton

            Rectangle {
                x: customSwitch.checked ? parent.width - width : 0
                width: 26 * customSwitch.size
                height: 26 * customSwitch.size
                radius: 13 * customSwitch.size
                color: customSwitch.down ? circleDown : (customSwitch.checked ? circleChecked: circleUnChecked)
                border.color: customSwitch.checked ? backgroundChecked : backgroundUnChecked
            }
        }

    contentItem: Text{
        text: customSwitch.text
        font: customSwitch.font
        color: textColor

        verticalAlignment: Text.AlignVCenter
        leftPadding: customSwitch.indicator.width + customSwitch.spacing + textPadding
        }

}
