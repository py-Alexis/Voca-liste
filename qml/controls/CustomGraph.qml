import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.15
import QtQuick.Shapes 1.15
import "../../qml"

Item {
    id: bg

    property bool startAnimation: false
    property bool startAnimation2: false
    property string reload: ""
    property int reload_: 0

    property int popupHistoryX: -1
    property int popupHistoryY: -1

    property int indexHover:-1
    property var lvs: []

    onReloadChanged: if(reload_ == 0){reload_ = 1}else{destroy()}
    
    onIndexHoverChanged: {
        if(indexHover === -1){
            popupHistory.visible = false
        }else{
            popupHistory.visible = true

            if (popupHistoryX === -1){
                popupHistoryX = ((graph.width * (((parseInt(indexHover)+1) * 2) -1) * (1/((lvs.length*2) - 1))) - (popupHistory.width + 25)) + 45
                popupHistoryY = ((graph.height * ((100 - lvs[indexHover][5])/ 100)) - 20) + graph.anchors.bottomMargin

                popupHistory.x = popupHistoryX
                popupHistory.y = popupHistoryY
            }else{
                popupHistoryX = ((graph.width * (((parseInt(indexHover)+1) * 2) -1) * (1/((lvs.length*2) - 1))) - (popupHistory.width + 25)) + 45
                popupHistoryY = ((graph.height * ((100 - lvs[indexHover][5])/ 100)) - 20) + graph.anchors.bottomMargin

                animationX.running = true
                animationY.running = true
            }


            datePopUp.text = lvs[indexHover][0]
            modePopUp.text = `mode: ${lvs[indexHover][6]}`
            directionPopUp.text = `direction: ${lvs[indexHover][7]}`
            lvPopUp.text = `niveau: ${lvs[indexHover][1]}`
            timeSpendPopUp.text = `durée: ${lvs[indexHover][2]}`
            if(lvs[indexHover][3] === 0){
                nbMistakePopUp.text = "aucune erreurs"
            }else if(lvs[indexHover][3] === 1){
                nbMistakePopUp.text = `${lvs[indexHover][3]}`
            }else{
                nbMistakePopUp.text = `${lvs[indexHover][3]}`
            }
        }

    }

    QtObject{
        id: internal

        function createGraph(history){
            var path = `Path { id: myPath; startX: 45; startY: graph.height + graph.anchors.bottomMargin;`
            var len = history.length
            var circleDiameter = 12
            var offset = 0


            for(const index in history){
                var lv = history[index][5]
                lvs.push(history[index])

                // create factor variable (coor_x = rectangle.width * x_factor)
                var x_factor = 0
                if(index === "0"){
                    x_factor = 1/((len*2) - 1)
                    offset = x_factor
                }else{
                    x_factor = (((parseInt(index)+1) * 2) -1) * offset
                }
                var y_factor = (100 - lv)/ 100

                // create the circles
                var circleString = `import QtQuick 2.15; import "../controls";import "../../qml"; Rectangle{id: circle; property bool animationRunning: startAnimation; property bool animationFinished: false; onAnimationRunningChanged: circleAnimation.running = true; height: ${circleDiameter}; width: height; radius: height / 2; x: (graph.width * ${x_factor}) - 6; y: if(animationFinished){(graph.height) * ${y_factor} - 6}else{graph.height} color: accent_color; PropertyAnimation { id: circleAnimation; target: circle; property: "y"; to: (graph.height) * ${y_factor} - 6; duration: 750; easing.type: Easing.InOutQuint; onFinished: {animationFinished = true; startAnimation2 = true}}}`
                var circleObject =  Qt.createQmlObject(circleString, graph,"circle")

                // add this point to the path
                path += `PathCurve { x: (graph.width * ${x_factor})+45; y: (graph.height * ${y_factor})+graph.anchors.bottomMargin }`

                // create button that handle mouse hover
                var hoverString = `import QtQuick 2.15;import QtQuick.Controls 2.2; import "../controls"; import "../../qml"; Button{width: graph.width * ${offset * 2};anchors.top: parent.top;anchors.bottom: parent.bottom;anchors.topMargin: 0;anchors.bottomMargin: 0;background: Rectangle{color: 'transparent';}onHoveredChanged:{if(hovered){indexHover = ${index}}else{indexHover = -1}}}`
                var newHoverObject=  Qt.createQmlObject(hoverString,graphRow,"hover")

            }

            // create the path
            path += "}"
            var line = `import QtQuick 2.15; import "../../qml"; Canvas {property bool animationRunning: startAnimation2;clip: false; onAnimationRunningChanged:animation2.running = true; id: canva; anchors.fill: parent ; contextType: "2d" ; ${path} onPaint: { context.strokeStyle = accent_color; context.path = myPath; context.lineWidth = 3; context.lineCap = "round"; context.stroke()}opacity:0; PropertyAnimation { id: animation2; target: canva; property: "opacity"; to: 1; duration: 500; easing.type: Easing.InOutQuint}}`
            var newObjectLine = Qt.createQmlObject(line, graphContainer,"graphLine")

            startAnimation = true
        }
    }

    Label {
        id: noData

        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 25
        anchors.horizontalCenter: parent.horizontalCenter

        color: medium_text_color

        text: "NO DATA"

        opacity: 0.3
    }
    Item{
        id: graphContainer
        anchors.fill: parent
        Column {
            id: unitColumn
            width: 45
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: (graphContainer.height - (6*20)) / 12
            anchors.topMargin: anchors.bottomMargin
            spacing: (graphContainer.height - (6*20)) / 6

            Repeater {
                anchors.fill: parent
                id: repeaterUnit
                model: ["100%", "80%", "60%", "40%", "20%", "0%"]
                Label{
                    text: modelData
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 9
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    color: medium_text_color
                    height: 20

                }
            }
        }

        Rectangle{
            id: graph
            anchors.left: unitColumn.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 10
            anchors.leftMargin: 0
            anchors.bottomMargin: ((graphContainer.height - (6*20)) / 12) + 10
            anchors.topMargin: anchors.bottomMargin
            color: "transparent"
            clip: false

            Repeater{
                anchors.fill: parent
                id: repeaterLine
                model: 6

                Rectangle{
                    x: 0
                    y: (graph.height / 5) * index
                    height: 3
                    radius: 3
                    color: light_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                }
            }
            Row{
                id: graphRow
                anchors.fill: parent
            }
        }

        Rectangle{
            id: popupHistory

            color: darker_color
            height: datePopUp.height + modePopUp.height + directionPopUp.height + lvPopUp.height + nbMistakePopUp.height + timeSpendPopUp.height + 45
            width: 180
            visible: false
            opacity: .93
            radius: 10
            z: 1

            transformOrigin: Item.Top

            Column{
                id: column
                anchors.fill: parent

                Item{
                    height: 5
                    width: 10
                }Label{
                    id: datePopUp

                    color: light_text_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    font.pointSize: 11
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                }

                Item{
                    height: 12
                    width: 10
                }Label{
                    id: modePopUp

                    color: light_text_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.pointSize: 9
                    anchors.rightMargin: 0
                    anchors.leftMargin: 10
                }Item{
                    height: 3
                    width: 10
                }Label{
                    id: directionPopUp

                    color: light_text_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.pointSize: 9
                    anchors.rightMargin: 0
                    anchors.leftMargin: 10
                }

                Item{
                    height: 13
                    width: 10
                }Label{
                    id: lvPopUp

                    color: light_text_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.pointSize: 9
                    anchors.rightMargin: 0
                    anchors.leftMargin: 10
                }Item{
                    height: 3
                    width: 10
                }Label{
                    id: timeSpendPopUp

                    color: light_text_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.pointSize: 9
                    anchors.rightMargin: 0
                    anchors.leftMargin: 10
                }Item{
                    height: 3
                    width: 10
                }Label{
                    id: nbMistakePopUp

                    color: light_text_color
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.pointSize: 9
                    anchors.rightMargin: 0
                    anchors.leftMargin: 10
                }
            }

            Item{
                id: triangle

                height: 20
                anchors.left: popupHistory.right
                anchors.top: popupHistory.top
                anchors.topMargin: 10
                anchors.leftMargin: -.2
                width: Math.sqrt((height*height)/2)

                Shape{
                    anchors.fill: parent

                    containsMode: Shape.FillContains

                    ShapePath{
                        fillColor: darker_color
                        strokeColor: darker_color

                        startX: 0; startY: 0
                        PathLine{x: triangle.width; y: triangle.height / 2}
                        PathLine{x: 0; y: triangle.height}
                    }
                }
            }

            PropertyAnimation { id: animationX; target: popupHistory; property: "x"; to: popupHistoryX; duration: 100; easing.type: Easing.InOutQuint}
            PropertyAnimation { id: animationY; target: popupHistory; property: "y"; to: popupHistoryY; duration: 100; easing.type: Easing.InOutQuint}
        }

    }

    Connections{
        target: backend

        function onSendHistory(history){
            // [[date, lvString, timeSpent, nbMistake, mistakes, lvNumber],
            // ['23 Jul 2021\n18 : 51', '50.0% -> 33.3%', '00:09', 4, 'mistake1 mistake2 mistake3 mistake4', 33.3] ...]

            if(history.length === 0){
                noData.visible = true
                graphContainer.visible = false
            }else{
                noData.visible = false
                graphContainer.visible = true
                internal.createGraph(history)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.5;height:300;width:480}
}
##^##*/
