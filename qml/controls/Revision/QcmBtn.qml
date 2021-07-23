import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: saveBtn

    //CUSTOM PROPERTIES
    property string textBtn: "Mot"

    property color btnTextColor: "#ffffff"
    property color btnColor: "#282C34"

    height: textofthebtn.height + 7

    font.pointSize: 11
    text: textBtn

    background: Rectangle{
        id: bgBtn
        color: btnColor
        opacity: if(saveBtn.down){
                     saveBtn.down ? 0.6 : 1
                    } else{
                     saveBtn.hovered ? 0.8 : 1
                    }

        radius: 5


   }

    contentItem: Item{
        id: content

        Text{
            id: textofthebtn
            color: btnTextColor
            text: saveBtn.text
            font.pointSize: saveBtn.font.pointSize

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

        }
    }
}
