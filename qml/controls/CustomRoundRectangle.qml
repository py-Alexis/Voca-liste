import QtQuick 2.0

Rectangle {
    id: mainRectangle
    property bool topRight: false
    property bool topLeft: false
    property bool bottomRight: false
    property bool bottomLeft: false

    Grid {
        id: grid
        anchors.fill: parent
        columns: 2

        Rectangle{
            radius: if(topLeft){mainRectangle.radius}else{0}
            color: mainRectangle.color
            height: mainRectangle.height / 2
            width: mainRectangle.width / 2
        }
        Rectangle{
            radius: if(topRight){mainRectangle.radius}else{0}
            color: mainRectangle.color
            height: mainRectangle.height / 2
            width: mainRectangle.width / 2
        }
        Rectangle{
            radius: if(bottomLeft){mainRectangle.radius}else{0}
            color: mainRectangle.color
            height: mainRectangle.height / 2
            width: mainRectangle.width / 2
        }
        Rectangle{
            radius: if(bottomRight){mainRectangle.radius}else{0}
            color: mainRectangle.color
            height: mainRectangle.height / 2
            width: mainRectangle.width / 2
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:400;width:400}
}
##^##*/
