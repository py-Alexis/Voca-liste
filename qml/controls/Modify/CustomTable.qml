import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../"

Item {
    id: customTable
    anchors.fill: parent

    property int currentRow: -1 // -1 => no cell selected
    property int currentColumn: -1

    property int rowCount: 0

    property color pairCellColor: medium_color
    property color impaireCellColor:light_color
    property color cellSelected: accent_color
    property color textColor: light_text_color
    property color mediumTextColor: medium_text_color

    property var getCellToSelected_: [-1,-1]

    property int reload: 0

    property bool full: false // To fix the fact that signal are send twice

    onReloadChanged: {destroy()}

    QtObject{
        id: internal

        function appendRow(rowContent){
            var object = Qt.createQmlObject(`import QtQuick 2.0; import "../Modify"; TableRow{mot:"${rowContent[0]}"; definition:"${rowContent[1]}"; context: "${rowContent[2]}"; niveau: ${rowContent[3]} ; rowNumber: ${rowCount}}`, column, "modify")
            rowCount = rowCount + 1
        }
    }

    // header
    Rectangle{
        id: tableContainer
    }

    ScrollView{
        id: scrollView
        anchors.fill: parent
        clip: true



        Column{
            id: column
            anchors.fill: parent


        }
    }

    Connections{
        target: backend

        function onSendWordList(data, newline){
            if (full === false){
                for(const index in data){
                    internal.appendRow(data[index])
                }
                if(newline === true){
                    scrollView.ScrollBar.vertical.position = 10
                    getCellToSelected_ = [rowCount - 1, 0]
                }
                full = true
            }
        }

        function onGetCurrentRow(fonction){
            if (fonction === "suppLine"){
            backend.del_line(currentList, currentRow)
            }else if (fonction === "resetLv"){
                backend.reset_lv(currentList, currentRow)
            }

        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
