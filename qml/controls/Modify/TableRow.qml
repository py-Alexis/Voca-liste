import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Modify"

Rectangle{
    id: tableRow
    property string mot: "mot"
    property string definition: "défintion"
    property string context: ""
    property int niveau: -1

    property int rowNumber: 0

    height: if(motCell.inputheight >= defCell.inputheight && motCell.inputheight >= contextCell.inputheight){
                motCell.inputheight + 14
            }else if(defCell.inputheight >= motCell.inputheight && defCell.inputheight >= contextCell.inputheight){
                defCell.inputheight + 14
            }else if(contextCell.inputheight >= motCell.inputheight && contextCell.inputheight >= defCell.inputheight){
                contextCell.inputheight + 14
            }


    width: row.width
    radius: 5
    color: if (rowNumber%2 == 0){customTable.pairCellColor}else{customTable.impaireCellColor}


    Row{
        id: row

        Cell{
            id: motCell

            cellText: mot
            row: rowNumber
            column:0
            cellWidth: scrollView.width / 5
            cellHeight: tableRow.height
        }
        Cell{
            id: defCell
            cellText: definition
            row: rowNumber
            column:1
            cellWidth: scrollView.width / 5
            cellHeight: tableRow.height
        }
        Cell{
            id: contextCell
            cellText: context
            row: rowNumber
            column:2
            cellWidth: (scrollView.width / 5)*2
            cellHeight: tableRow.height
        }
        LevelCell{
            id: levelCell

            cellText: niveau
            row: rowNumber
            column:3
            cellWidth: scrollView.width / 5
            cellHeight: tableRow.height
        }
    }
}


