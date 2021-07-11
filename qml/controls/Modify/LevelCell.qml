import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "../Modify"
import "../../scripts/color_mixer.js" as Co


Item {
    id: cell
    //public
    property int cellHeight: 30
    property int cellWidth: 100

    property int cellText: -1
    property int row: 0
    property int column: 0

    property color cellColor: "#ffffff"
    property int provisoire: 0


    height: cellHeight
    width: cellWidth

    QtObject{
        id: internal

        property color dynamicTextColor: if(cellText === -1){customTable.mediumTextColor}
                                         else if(cellText === 0){customTable.textColor}
                                         else if(cellText === 1){Co.mix_hexes(String(customTable.textColor),String(customTable.textColor), String(customTable.cellSelected))}
                                         else if(cellText === 2 || cellText === 3){Co.mix_hexes(String(customTable.textColor), String(customTable.cellSelected))}
                                         else if(cellText === 4){Co.mix_hexes(String(customTable.textColor), String(customTable.cellSelected), String(customTable.cellSelected))}
                                         else if(cellText === 5){Co.mix_hexes(String(customTable.textColor), String(customTable.cellSelected), String(customTable.cellSelected), String(customTable.cellSelected))}
                                         else if(cellText === 6){customTable.cellSelected}

    }

    Rectangle{
        id: recangle
        color: if (row%2 == 0){customTable.pairCellColor}else{customTable.impaireCellColor}

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        radius: 5


        TextInput{
            id: cellInput

            readOnly: true
            color: internal.dynamicTextColor
            selectionColor: customTable.cellSelected
            selectedTextColor: "#000000"
            anchors.fill: parent
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            anchors.rightMargin: 20
            font.pointSize: 10
            selectByMouse: false
            antialiasing: true

            text: if(cellText === -1){"Pas de donnée"} else if(cellText === 0){"inconnu"}
                  else if(cellText === 1){"débutant"} else if(cellText === 2 || cellText === 3){"intermédiaire"}
                  else if(cellText === 4){"avancé"} else if(cellText === 5){"maitrisé"} else if(cellText === 6){"prafait"}


        }
    }
}


