import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: btnText

    //CUSTOM PROPERTIES
    property string textBtn: "nouveau"

    property color btnTextColor: "#5f6a82"
    property color btnTextColorDown: "#ffffff"

    QtObject{
        id: internal

        property var dynamicColor: if(btnText.down){btnTextColor}else{btnText.hovered ? btnTextColorDown: btnTextColor}
    }


    width: textofthebtn.width + 20
    height: parent.height

    font.pointSize: 10

    background: Rectangle{
        id: bgBtn
        color: "#00000000"
   }

    contentItem: Item{
        id: content

        Text{
            id: textofthebtn
            color: internal.dynamicColor
            text: textBtn
            font.pointSize: btnText.font.pointSize
            
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left

            anchors.leftMargin: 0
        }
    }
}
