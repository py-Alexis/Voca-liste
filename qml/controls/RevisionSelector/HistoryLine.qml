import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: historyLine

    property int parentWidth: 200

    property bool pair: false
    property color backgroundColorIsPair: "#282C34"
    property color backgroundColorNotPair: "#2C313C"
    property color textColor: "#ffffff"

    property string date: "date \nmqsldfkj"
    property string time: "time"
    property string lv: "lv => lv"
    property int nbMistakes: 0
    property string mistakes: "mistkes qmdlkj fqmdslfjk mqdlsjk fmqldsj fmlsqd jfmlqsdj fmlqdsjf mlqdsj fmlqdf jmlqdjf mqlsdfj mqsldfj kmlsfjk lmqjfmqljf mlqsd fmqsldf jqmld jmqldsf mqlsdjf mqldfj mqdflj"
    property string mode: "QCM"
    property string direction: "default"


    anchors.left: parent.left
    anchors.leftMargin: 0
    width: parentWidth

    color: if(pair){backgroundColorIsPair}else{backgroundColorNotPair}
    height: if(dayLabelHistory.height >= mistakeLabelHistory.height){
                dayLabelHistory.height + 13
            }else{
                mistakeLabelHistory.height + 13
            }

    Row{
        id: row
        anchors.fill: parent

        Label{
            id: dayLabelHistory
            text: date
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 8


        }
        Label{
            id: modeLabelHistory
            text: mode
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 8


        }
        Label{
            id: directionLabelHistory
            text: direction
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 8


        }
        Label{
            id: timeLabelHistory
            text: lv
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 8
        }

        Label{
            id: lvLabelHistory
            text: time
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 8
        }


        Label{
            id: nbMistakeLabelHistory
            text: nbMistakes
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 8
        }

        Label{
            id: mistakeLabelHistory
            text: mistakes
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            leftPadding: 5
            font.pointSize: 10

            width: (parent.width / 8) * 2
        }
    }
}



/*##^##
Designer {
    D{i:0;height:40;width:800}
}
##^##*/
