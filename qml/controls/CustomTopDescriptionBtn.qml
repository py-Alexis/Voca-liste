import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: btnTopDescriptionBar

    //CUSTOM PROPERTIES
    property url btnIconSource: "../../images/settings_icon.svg"

    property string tooltipText: "settings"

    property color btnColorMouseOver: "#23282e"
    property color btnColorClicked: "#00a1f1"
    property color btnLogoColor: "#ffffff"

    QtObject{
        id: internal

        property var dynamicColor: if(btnTopDescriptionBar.down){
                                            btnTopDescriptionBar.down ? btnColorClicked : btnLogoColor
                                           } else{
                                            btnTopDescriptionBar.hovered ? btnColorMouseOver : btnLogoColor
                                           }
    }

    width: 25
    height: 25


    /*
    ToolTip{
        parent: parent
        text: toolTip
        visible: hovered
        opacity:  0.8

        background: Rectangle{
            color: "lightblue"
        }

        contentItem: Item{
            id: contentItem
            Text{
                text: tooltipText
            }
        }
    }
    */

    background: Rectangle{
        id: bgBtn
        color: "#00000000"

        Image {
            id: iconBtn
            anchors.verticalCenter: parent.verticalCenter
            source: btnIconSource
            mipmap: true
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            height: 16
            width: 16



            antialiasing: true

        }
        ColorOverlay {
            anchors.fill: iconBtn
            source: iconBtn
            antialiasing: false
            color: internal.dynamicColor
        }

   }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:4;height:25;width:25}
}
##^##*/
