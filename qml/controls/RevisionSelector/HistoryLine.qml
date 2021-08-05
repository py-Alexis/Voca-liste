import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: historyLine

    property bool pair: false
    property color backgroundColorIsPair: "#282C34"
    property color backgroundColorNotPair: "#2C313C"
    property color textColor: "#ffffff"

    property string date: "date \nmqsldfkj"
    property string time: "time"
    property string lv: "lv => lv"
    property int nbMistakes: 0
    property string mistakes: "mistkes qmdlkj fqmdslfjk mqdlsjk fmqldsj fmlsqd jfmlqsdj fmlqdsjf mlqdsj fmlqdf jmlqdjf mqlsdfj mqsldfj kmlsfjk lmqjfmqljf mlqsd fmqsldf jqmld jmqldsf mqlsdjf mqldfj mqdflj"

    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0

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

            width: parent.width / 6


        }
        Label{
            id: timeLabelHistory
            text: lv
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 6
        }

        Label{
            id: lvLabelHistory
            text: time
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 6
        }


        Label{
            id: nbMistakeLabelHistory
            text: nbMistakes
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            font.pointSize: 10

            width: parent.width / 6
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

            width: (parent.width / 6) * 2
        }
    }
}



/*##^##
Designer {
    D{i:0;height:40;width:700}
}
##^##*/
