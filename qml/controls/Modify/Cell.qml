import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Modify"
import "../../pages"

Item {
    id: cell
    //public
    property int cellHeight: 30
    property int cellWidth: 100

    property string cellText: ""
    property int row: 0
    property int column: 0

    property var currentCell: [customTable.currentRow, customTable.currentColumn]
    property var getCellToSelected: getCellToSelected_

    //private
    property bool readonly: true
    property int inputheight: cellInput.height

    height: cellHeight
    width: cellWidth

    onCurrentCellChanged: {
        if(recangle.border.width != 0){
            recangle.border.width = 0
            mouseArea.visible = true
            cell.z = 0
            readonly = true

        }
    }

    onGetCellToSelectedChanged: {
        if( getCellToSelected[0] !== -1 && getCellToSelected[1] !== -1){
            if(getCellToSelected[0] === row && getCellToSelected[1] === column){
                customTable.currentColumn = column
                customTable.currentRow = row
                recangle.border.width = 3
                cell.z = 10
                readonly = false
                mouseArea.visible = false
                cellInput.forceActiveFocus()
            }

        }
    }

    QtObject{
        id: internal
        function nextCellEnter(){
            if(column != 2){
                getCellToSelected_ = [row, column + 1]
            }else{
                if(row !== rowCount - 1){
                    getCellToSelected_ = [row + 1, 0]
                }else{
                    backend.new_line_on_enter() // this function just tell the modify qml to create a new line
                }
            }
        }

        function nextCell(){
            if(column != 2){
                getCellToSelected_ = [row, column + 1]
            }else{
                if(row !== rowCount - 1){
                    getCellToSelected_ = [row + 1, 0]
                }else{
                    currentRow = -1
                    currentColumn = -1
                }
            }
        }
    }




    Rectangle{
        id: recangle
        color: if (row%2 == 0){customTable.pairCellColor}else{customTable.impaireCellColor}
        border.width: 0
        border.color: customTable.cellSelected

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

            readOnly: readonly
            text: cellText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 20
            color: customTable.textColor
            selectionColor: customTable.cellSelected
            selectedTextColor: "#000000"
            font.pointSize: 10
            selectByMouse: true
            wrapMode: TextInput.Wrap

            onAccepted:{
                internal.nextCellEnter()
            }

            // on tab pressed => Keys.onPressed: { if (event.key === Qt.Key_Tab) internal.nextCellEnter() } mais enleve le focus sur l'input

            onTextEdited: {
                backend.update_word(currentList, row, column, text)
            }


        }
        MouseArea{
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                customTable.currentColumn = column
                customTable.currentRow = row
                recangle.border.width = 3
                cell.z = 10
                readonly = false
                visible = false
            }
        }
    }


}


